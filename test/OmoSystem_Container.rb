require 'test/unit'
require 'mocha/test_unit'
require './OmoSystemModule.rb'

module OmoSystemTest
  class Container < Test::Unit::TestCase
    def test_setup_battler__with_battler_object__creates_bladder_and_bowel
      # Arrange
      battler = Game_Battler.new
      bladder = {}
      bowel = {}
      OmoSystem::Container.expects(:new).with(battler, "bladder").returns(bladder)
      OmoSystem::Container.expects(:new).with(battler, "bowel").returns(bowel)

      # Act
      OmoSystem::Container.setup_battler(battler)

      # Assert
      assert_same(bladder, battler.bladder, "battler.bladder not initialized")
      assert_same(bowel, battler.bowel, "battler.bowel not initialized")
    end
  end
end

require 'test/unit/ui/console/testrunner'
Test::Unit::UI::Console::TestRunner.run(OmoSystemTest::Container)