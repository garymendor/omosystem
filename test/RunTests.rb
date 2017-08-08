require './OmoSystem_Stomach'
require './OmoSystem_Container'
require 'test/unit/ui/console/testrunner'

module OmoSystemTest
  class AllTests
    def self.suite
      suite = Test::Unit::TestSuite.new
      suite << OmoSystemTest::Container.suite
      suite << OmoSystemTest::Stomach.suite
      return suite
    end
  end
end

Test::Unit::UI::Console::TestRunner.run(OmoSystemTest::AllTests)
