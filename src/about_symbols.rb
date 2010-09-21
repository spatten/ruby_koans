require File.expand_path(File.dirname(__FILE__) + '/edgecase')

class AboutSymbols < EdgeCase::Koan
  def test_symbols_are_symbols
    symbol = :ruby
    assert_equal __(true), symbol.is_a?(Symbol)
  end

  def test_symbols_are_not_strings
    symbol = :ruby
    assert_equal __(false), symbol.is_a?(String)
    assert_equal __(false), symbol.eql?("ruby")
  end

  def test_symbols_have_unique_identity
    symbol1 = :identity
    symbol2 = :identity
    symbol3 = :something_else

    assert symbol1 == __(symbol2)
    assert symbol1 != __(symbol2)
  end

  def test_identical_symbols_are_represented_by_a_single_internal_object
    symbol1 = :identity
    symbol2 = :identity

    assert symbol1.equal?(__(symbol2))
    assert_equal __(symbol1.object_id), symbol2.object_id
  end

  def test_method_names_become_symbols
    all_symbols = Symbol.all_symbols

    assert_equal __(true), all_symbols.include?(:test_method_names_are_symbols)
  end

  RubyConstant = "This string is assigned to a constant."
  def test_constants_become_symbols
    all_symbols = Symbol.all_symbols

    assert_equal true, all_symbols.include?(__(:RubyConstant))
  end

  def test_symbols_can_be_made_from_strings
    string = "catsAndDogs"
    assert_equal __(:catsAndDogs), string.to_sym
  end

  def test_symbols_with_spaces_can_by_built
    symbol = :"cats and dogs"

    assert_equal symbol, __("cats and dogs").to_sym
  end

  def test_interpolated_symbols_become_strings
    symbol = :cats
    string = "It is raining #{symbol} and dogs."

    assert_equal __('It is raining cats and dogs.'), string
  end

  def test_symbols_cannot_be_concatenated
    assert_raise(__(NoMethodError)) do
      :cats + :dogs
    end
  end
end
