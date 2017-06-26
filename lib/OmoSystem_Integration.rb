class Game_Battler
  attr_accessor :bladder
  attr_accessor :bowel
  
  def simulate_step
    something_happened = @bladder.simulate_step if @bladder != nil
    something_happened = @bowel.simulate_step || something_happened if @bowel != nil
    something_happened
  end
  
  def simulate_until_something_happens
    rounds = 0
    while !simulate_step do
      rounds = rounds+1
    end
    rounds
  end
end

class Game_Actor
  attr_accessor :fill_on_movement
  alias :setup_OmoSystem :setup
  
  def setup(actor_id)
    setup_OmoSystem(actor_id)
    @fill_on_movement = false
    OmoSystem::Container.setup_battler(self)
  end
  
  alias :on_player_walk_OmoSystem :on_player_walk
  def on_player_walk
    on_player_walk_OmoSystem
    if (@fill_on_movement) then
      simulate_step
    end
  end
end

module DataManager
  class <<self; alias :load_normal_database_OmoSystem :load_normal_database; end
  def self.load_normal_database
    load_normal_database_OmoSystem
    OmoSystem::Container.load_urge_states
  end
end