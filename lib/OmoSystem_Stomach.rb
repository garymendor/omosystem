#======================================================================
# OmoSystem::Stomach
# Simulates the behavior of a stomach.
#======================================================================
# Author::      Gary Mendor (mailto:gary.mendor@gmail.com)
# Copyright::   Copyright (c) 2017 Gary Mendor
# License::     MIT
#======================================================================
module OmoSystem
  class Stomach
    # The maximum volume of the stomach, in mL.
    attr_reader :volume
    # The stomach volume at which the person feels full, in mL.
    attr_reader :fullness
    # The base rate of digestion (conversion of calories into nutrition), in mL/tick.
    attr_reader :digestion_rate
    # The rate at which liquids are processed to the intestine, in mL/tick.
    attr_reader :liquid_rate
    # The scaling factor for which solids vs. liquids are processed, as a logarithmic factor.)
    attr_reader :solid_exponent

    # The current volume of liquid, in mL.
    attr_reader :liquid
    # The current volume of undigested calories, in mL.
    attr_reader :calories
    # The current volume of digested calories, in mL.
    attr_reader :nutrition
    # The current volume of roughage, in mL.
    attr_reader :roughage

    # The output target (small intestine).
    attr_reader :output_target

    def initialize
      @volume = 1000.0
      @fullness = 500.0
      @digestion_rate = 0.001
      @liquid_rate = 9.6
      @solid_exponent = -16.0

      @liquid = 0.0
      @calories = 0.0
      @nutrition = 0.0
      @roughage = 0.0
    end

    # Sets up the stomach.
    def setup(output_target, modifiers)
      @output_target = output_target
    end
    
    # Receive new content.
    def receive(liquid, calories, nutrition, roughage)
      @liquid = @liquid + liquid
      @calories = @calories + calories
      @nutrition = @nutrition + nutrition
      @roughage = @roughage + roughage
    end

    # Run a single step of the simulation.
    def simulate
      # Digest food
      _digested = [@calories, @digestion_rate].min
      @calories = @calories - _digested
      @nutrition = @nutrition + _digested

      # Determine how much food to move.
      _solid_volume = @nutrition + @roughage
      _movable_volume = _solid_volume + @liquid
      return if _movable_volume < @digestion_rate    # Avoid dividing by zero
      _transfer_volume = @liquid_rate * Math.exp(solid_volume * @solid_exponent / _movable_volume)
      _transfer_volume = [_transfer_volume, _movable_volume].min

      # Move content
      _liquid_transfer = _transfer_volume * @liquid / _movable_volume
      _nutrition_transfer = _transfer_volume * @nutrition / _movable_volume
      _roughage_transfer = _transfer_volume * @roughage / _movable_volume
      receive(-_liquid_transfer, 0, -_nutrition_transfer, -_roughage_transfer)
      @output_target.receive(_liquid_transfer, 0, _nutrition_transfer, _roughage_transfer)
    end
  end
end