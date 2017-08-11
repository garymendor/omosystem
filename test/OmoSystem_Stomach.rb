#======================================================================
# OmoSystemTest::Stomach
# Tests the OmoSystem::Stomach module.
#======================================================================
# Author::      Gary Mendor (mailto:gary.mendor@gmail.com)
# Copyright::   Copyright (c) 2017 Gary Mendor
# License::     MIT
#======================================================================
require 'test/unit'
require 'mocha/test_unit'
require './OmoSystemModule.rb'

module OmoSystemTest
  class Stomach < Test::Unit::TestCase
    def test_initialize__with_default_parameters__sets_expected_defaults
      # Arrange
      # Act
      result = OmoSystem::Stomach.new

      # Assert
      assert_equal(1000.0, result.volume)
      assert_equal(500.0, result.fullness)
      assert_equal(0.001, result.digestion_rate)
      assert_equal(9.6, result.liquid_rate)
      assert_equal(-16.0, result.solid_exponent)

      assert_equal(0.0, result.liquid)
      assert_equal(0.0, result.calories)
      assert_equal(0.0, result.nutrition)
      assert_equal(0.0, result.roughage)
    end
    
    def test_receive__with_normal_values__updates_content_values
      # Arrange
      value = OmoSystem::Stomach.new
      
      # Act
      value.receive(1.0, 2.0, 3.0, 4.0)
      
      # Assert
      assert_equal(1.0, value.liquid)
      assert_equal(2.0, value.calories)
      assert_equal(3.0, value.nutrition)
      assert_equal(4.0, value.roughage)
    end
  end
end
