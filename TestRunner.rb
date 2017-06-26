require "test/unit"
require "test/unit/ui/console/testrunner"

class Game_Battler
  attr_accessor :note
  attr_accessor :id
end

battler = Game_Battler.new
battler.note = ""
#battler.note = "<OmoSystem:container:bladder:weak>"
#battler.note = "<OmoSystem:container:bladder:very_numb>"
#battler.note = "<OmoSystem:container:bladder:weak><OmoSystem:container:bladder:numb>"
battler.id = 1

bladder = OmoSystem::Container.new(battler, "bladder")
rounds = 0
while bladder.fatigue < bladder.need_threshold
  bladder.simulate_step
  rounds = rounds + 1
end
print("Need to pee after ", rounds, " rounds with a volume of ", bladder.volume, ".\n")
while bladder.fatigue < bladder.desperate_threshold
  bladder.simulate_step
  rounds = rounds + 1
end
print("Desperate after ", rounds, " rounds with a volume of ", bladder.volume, ".\n")
while bladder.fatigue < bladder.bursting_threshold
  bladder.simulate_step
  rounds = rounds + 1
end
print("Bursting after ", rounds, " rounds with a volume of ", bladder.volume, ".\n")
