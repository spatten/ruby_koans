require File.expand_path(File.dirname(__FILE__) + '/edgecase')

class AboutModules < EdgeCase::Koan
  module Nameable
    def set_name(new_name)
      @name = new_name
    end

    def here
      :in_module
    end
  end

  def test_cant_instantiate_modules
    assert_raise(___(NoMethodError)) do
      Nameable.new
    end
  end

  # ------------------------------------------------------------------

  class Dog
    include Nameable

    attr_reader :name

    def initialize
      @name = "Fido"
    end

    def bark
      "WOOF"
    end

    def here
      :in_object
    end
  end

  def test_normal_methods_are_available_in_the_object
    fido = Dog.new
    assert_equal __("WOOF"), fido.bark
  end

  def test_module_methods_are_also_availble_in_the_object
    fido = Dog.new
    assert_nothing_raised(Exception) do # __
      fido.set_name("Rover")
    end
  end

  def test_module_methods_can_affect_instance_variables_in_the_object
    fido = Dog.new
    assert_equal __("Fido"), fido.name
    fido.set_name("Rover")
    assert_equal __("Rover"), fido.name
  end

  def test_classes_can_override_module_methods
    fido = Dog.new
    assert_equal __(:in_object), fido.here
  end
end
