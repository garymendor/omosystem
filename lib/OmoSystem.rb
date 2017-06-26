#======================================================================
# OmoSystem
# A module for simulating bodily functions and the effects thereof.
#======================================================================
module OmoSystem
  class ContainerBuff
    attr_reader :id
    attr_reader :type
    attr_reader :stat_name
    attr_reader :offset
    attr_reader :percentage

    # Examples
    # <OmoSystem:buff:bladder:strength:20%>
    def initialize(id, type, stat_name, offset, percentage)
      @id = id
      @type = type
      @stat_name = stat_name
      @offset = offset
      @percentage = percentage
    end

    def ContainerBuff.from_note(id, note)
      buffs = []
      index = 0
      note.scan(/<OmoSystem:buff:[^>]*>/) do |subnote|
        /<OmoSystem:buff:([^:]*?):([^:]*?):([^>]*?)>/ =~ subnote
        type = $1
        stat_name = $2
        amount = $3
        offset = 0.0
        percentage = 0.0
        if amount[-1] == "%" then
          percentage = amount[0..-2].to_i
        else
          offset = amount.to_i
        end
        buffs.push(ContainerBuff.new(id + "_" + index.to_s, type, stat_name, offset, percentage))
        index = index + 1
      end
      buffs
    end

    def ContainerBuff.from_state(state_id)
      return nil if $data_states[state_id] == nil || $data_states[state_id].note == nil
      ContainerBuff.new("state_" + state_id.to_s, $data_states[state_id].note)
    end

    def apply(value); (value*@percentage)/100.0 + offset; end
  end

  class Container

    # TODO: Make data-driven
    @@standard_types = { \
      "bladder" => { \
        "default" => { \
          "capacity" => 120.0, \
          "strength" => 120.0, \
          "need_threshold" => 5, \
          "desperate_threshold" => 50, \
          "bursting_threshold" => 100, \
          "fill_rate" => 0.4, \
          "night_scale" => 4.0 \
        }, \
        "weak" => "<OmoSystem:buff:bladder:strength:50%>", \
        "numb" => "<OmoSystem:buff:bladder:need_threshold:50><OmoSystem:buff:bladder:desperate_threshold:75>", \
        "very_numb" => "<OmoSystem:buff:bladder:need_threshold:80><OmoSystem:buff:bladder:desperate_threshold:90>", \
        "bedwetter" => "<OmoSystem:buff:bladder:night_scale:50%>", \
        "none" => "<OmoSystem:buff:bladder:fill_rate:0%>" \
      }, \
      "bowel" => {\
        "default" => { \
          "capacity" => 120.0, \
          "strength" => 120.0, \
          "need_threshold" => 5, \
          "desperate_threshold" => 50, \
          "bursting_threshold" => 100, \
          "fill_rate" => 0.05, \
          "night_scale" => 4.0 \
        }, \
        "none" => "<OmoSystem:buff:bowel:fill_rate:0%>" \
      } \
    }

    def self.setup_battler(battler)
      battler.bladder = Container.new(battler, "bladder")
      battler.bowel = Container.new(battler, "bowel")
    end

    def self.load_urge_states
      @@urge_states_by_type = {"bladder" => {}, "bowel" => {}}
      for state in $data_states
        next if state == nil || state.note == nil
        if /<OmoSystem:urge:([^:]?*):([^>]?*)>/ =~ state.note then
          container_type = $1
          state_type = $2
          @@urge_states_by_type[container_type][state_type] = state.id
        end
      end
    end
    
    attr_reader :battler
    attr_reader :type
    attr_accessor :volume
    attr_accessor :fatigue
    attr_accessor :leaks

    # <OmoSystem:container:bladder:weak>
    def initialize(battler, type)
      @battler = battler
      @type = type
      @base_stats = {}
      @buffs = {}
      @volume = 0
      @fatigue = 0
      @leaks = 0
      @urge_states = @@urge_states_by_type[type]
      setup_from_notes
    end

    def setup_from_notes
      @base_stats = @@standard_types[@type]["default"].clone
      note = nil
      note = @battler.actor.note if @battler.is_a?(Game_Actor)
      note = @battler.enemy.note if @battler.is_a?(Game_Enemy)
      return if note == nil
      note.scan(/<OmoSystem:container:[^>]*?>/) do |category_item|
        /<OmoSystem:container:([^:]*?):([^>]*?)>/ =~ category_item
        type = $1
        category = $2
        next if type != @type
        
        category_note = @@standard_types[@type][category]
        buffs = ContainerBuff.from_note("battler_" + @battler.id.to_s, category_note)
        buffs.each do |buff|
          if buff.type == @type then
            @base_stats[buff.stat_name] = buff.apply(@base_stats[buff.stat_name])
          end
        end
      end
    end

    def _get_stat(name)
      base_value = @base_stats[name]
    end

    def capacity; _get_stat("capacity"); end
    def strength; _get_stat("strength"); end
    def need_threshold; _get_stat("need_threshold"); end
    def desperate_threshold; _get_stat("desperate_threshold"); end
    def bursting_threshold; _get_stat("bursting_threshold"); end
    def fill_rate; _get_stat("fill_rate"); end
    def night_scale; _get_stat("night_scale"); end

    def has_urge_state?(name)
      state_id = @urge_states[name]
      false if state_id == nil
      @battler.state?(state_id)
    end
    
    def need?
      has_urge_state?("need")
    end
    
    def desperate?
      has_urge_state?("desperate")
    end
    
    def bursting?
      has_urge_state?("bursting")
    end
    
    def leaking?
      has_urge_state?("leaking")
    end
    
    def has_urge?
      need? || desperate? || bursting?
    end

    def simulate_step
      @volume = @volume + fill_rate
      _update_fatigue
      something_happened = _update_desperation
      something_happened
    end
    
    def simulate_until_something_happens
      rounds = 0
      while !simulate_step do
        rounds = rounds+1
      end
      rounds
    end

    def _update_fatigue
      net_fatigue = 0
      
      # Fatigue
      if !leaking? && @volume > capacity then
        _fatigue_chance = Math.log(@volume - capacity) / Math.log(strength)
        while _fatigue_chance >= 1 do
          net_fatigue = net_fatigue + 1
          _fatigue_chance = _fatigue_chance - 1
        end
        net_fatigue = net_fatigue + 1 if rand() < _fatigue_chance
      end
      
      # Recovery
      net_fatigue = net_fatigue - 1
      net_fatigue = @fatigue if @fatigue + net_fatigue < 0
      @fatigue = @fatigue + net_fatigue

      print(@type, " volume=", @volume," fatigue=", @fatigue, "\n") if net_fatigue != 0
      
      net_fatigue
    end
    
    def _update_desperation
      set_state = false
      if (@fatigue <= need_threshold - 5) then
        urge_state_id = nil
        set_state = true
      elsif (@fatigue >= need_threshold) && (@fatigue <= desperate_threshold - 5) then
        urge_state_id = @urge_states["need"]
        set_state = true
      elsif (@fatigue >= desperate_threshold) && (@fatigue <= bursting_threshold - 5) then
        urge_state_id = @urge_states["desperate"]
        set_state = true
      elsif (@fatigue >= bursting_threshold) then
        urge_state_id = @urge_states["bursting"]
        set_state = true
      end
      return false if !set_state
      
      state_changed = (urge_state_id == nil && has_urge?)
      state_changed = state_changed || !@battler.state?(urge_state_id) if urge_state_id != nil
      print(@type, " new state=", urge_state_id, ", has_urge?=", has_urge? ," volume=", @volume, " fatigue=", @fatigue, "\n") if state_changed

      @urge_states.each do |stateName, id|
        if id == urge_state_id then
          @battler.add_state(id)
        else
          @battler.remove_state(id)
        end
      end
      
      state_changed
    end
  end
end