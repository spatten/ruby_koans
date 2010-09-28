require File.expand_path(File.dirname(__FILE__) + '/edgecase')

include Java

# Concepts
# * Pull in a java class
# * calling a method, Camel vs snake
# * Resovling module/class name conflicts
# * Showing what gets returned
# * Ruby Strings  VS Java Strings
# * Calling custom java class
# * Calling Ruby from java???

class AboutJavaInterop < EdgeCase::Koan
  def test_using_a_java_library_class
    java_array = java.util.ArrayList.new
    assert_equal __(Java::JavaUtil::ArrayList), java_array.class
  end

  def test_java_class_can_be_referenced_using_both_ruby_and_java_like_syntax
    assert_equal __(true), Java::JavaUtil::ArrayList == java.util.ArrayList
  end

  def test_include_class_includes_class_in_module_scope
    assert_nil defined?(TreeSet) # __
    include_class "java.util.TreeSet"
    assert_equal __("constant"), defined?(TreeSet)
  end

  # THINK ABOUT IT:
  #
  # What if we use:
  #
  #   include_class "java.lang.String"
  #
  # What would be the value of the String constant after this
  # include_class is run?  Would it be useful to provide a way of
  # aliasing java classes to different names?

  JString = java.lang.String
  def test_also_java_class_can_be_given_ruby_aliases
    java_string = JString.new("A Java String")
    assert_equal __(java.lang.String), java_string.class
    assert_equal __(java.lang.String), JString
  end

  def test_can_directly_call_java_methods_on_java_objects
    java_string = JString.new("A Java String")
    assert_equal __("a java string"), java_string.toLowerCase
  end

  def test_jruby_provides_snake_case_versions_of_java_methods
    java_string = JString.new("A Java String")
    assert_equal __("a java string"), java_string.to_lower_case
  end

  def test_jruby_provides_question_mark_versions_of_boolean_methods
    java_string = JString.new("A Java String")
    assert_equal __(true), java_string.endsWith("String")
    assert_equal __(true), java_string.ends_with("String")
    assert_equal __(true), java_string.ends_with?("String")
  end

  def test_java_string_are_not_ruby_strings
    ruby_string = "A Java String"
    java_string = java.lang.String.new(ruby_string)
    assert_equal __(true), java_string.is_a?(java.lang.String)
    assert_equal __(false), java_string.is_a?(String)
  end

  def test_java_strings_can_be_compared_to_ruby_strings_maybe
    ruby_string = "A Java String"
    java_string = java.lang.String.new(ruby_string)
    assert_equal __(false), ruby_string == java_string
    assert_equal __(true), java_string == ruby_string

    # THINK ABOUT IT:
    #
    # Is there any possible way for this to be more wrong?
    #
    # SERIOUSLY, THINK ABOUT IT:
    #
    # Why do you suppose that Ruby and Java strings compare like that?
    #
    # ADVANCED THINK ABOUT IT:
    #
    # Is there a way to make Ruby/Java string comparisons commutative?
    # How would you do it?
  end

  def test_however_most_methods_returning_strings_return_ruby_strings
    java_array = java.util.ArrayList.new
    assert_equal __("[]"), java_array.toString
    assert_equal __(true), java_array.toString.is_a?(String)
    assert_equal __(false), java_array.toString.is_a?(java.lang.String)
  end

  def test_java_collections_are_enumerable
    java_array = java.util.ArrayList.new
    java_array << "one" << "two" << "three"
    assert_equal __(["ONE", "TWO", "THREE"]), java_array.map { |item| item.upcase }
  end

  # ------------------------------------------------------------------

  # Open the Java ArrayList class and add a new method.
  class Java::JavaUtil::ArrayList
    def multiply_all
      result = 1
      each do |item|
        result *= item
      end
      result
    end
  end

  def test_java_class_are_open_from_ruby
    java_array = java.util.ArrayList.new
    java_array.add_all([1,2,3,4,5])

    assert_equal __(120), java_array.multiply_all
  end

end
