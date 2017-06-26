#======================================================================
# VXA_DefaultScripts.rb
#======================================================================
# Stub definitions of default RPGMaker script objects used by the
# OmoSystem module.
#======================================================================

require 'rpg/base_item'
require 'rpg/state'

$data_states = [
  nil,
  begin; s = RPG::State.new; s.id = 1; s.note = "<OmoSystem:urge:bladder:need>"; s; end,
  begin; s = RPG::State.new; s.id = 2; s.note = "<OmoSystem:urge:bladder:desperate>"; s; end,
  begin; s = RPG::State.new; s.id = 3; s.note = "<OmoSystem:urge:bladder:bursting>"; s; end,
  begin; s = RPG::State.new; s.id = 4; s.note = "<OmoSystem:urge:bladder:leaking>"; s; end,
  begin; s = RPG::State.new; s.id = 5; s.note = "<OmoSystem:urge:bowel:need>"; s; end,
  begin; s = RPG::State.new; s.id = 6; s.note = "<OmoSystem:urge:bowel:desperate>"; s; end,
  begin; s = RPG::State.new; s.id = 7; s.note = "<OmoSystem:urge:bowel:bursting>"; s; end,
  begin; s = RPG::State.new; s.id = 8; s.note = "<OmoSystem:urge:bowel:leaking>"; s; end
]

class Game_Battler
  attr_accessor :id
end

class Game_Actor < Game_Battler
  attr_accessor :actor

  def setup(actor_id)
  end

  def state?
  end

  def add_state(state)
  end

  def remove_state(state)
  end

  def on_player_walk
  end
end

module DataManager
  def self.load_normal_database
  end
end