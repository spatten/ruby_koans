require File.expand_path(File.dirname(__FILE__) + '/edgecase')

class AboutHashes < EdgeCase::Koan
  def test_creating_hashes
    empty_hash = Hash.new
    assert_equal __(Hash), empty_hash.class
    assert_equal({}, empty_hash) # __
    assert_equal __(0), empty_hash.size
  end

  def test_hash_literals
    hash = { :one => "uno", :two => "dos" }
    assert_equal __(2), hash.size
  end

  def test_accessing_hashes
    hash = { :one => "uno", :two => "dos" }
    assert_equal __("uno"), hash[:one]
    assert_equal __("dos"), hash[:two]
    assert_equal __(nil), hash[:doesnt_exist]
  end

  def test_changing_hashes
    hash = { :one => "uno", :two => "dos" }
    hash[:one] = "eins"

    expected = { :one => __("eins"), :two => "dos" }
    assert_equal __(true), expected == hash

    # Bonus Question: Why was "expected" broken out into a variable
    # rather than used as a literal?
  end

  def test_hash_is_unordered
    hash1 = { :one => "uno", :two => "dos" }
    hash2 = { :two => "dos", :one => "uno" }

    assert_equal __(true), hash1 == hash2
  end

  def test_hash_keys
    hash = { :one => "uno", :two => "dos" }
    assert_equal __(2), hash.keys.size
    assert_equal __(true), hash.keys.include?(:one)
    assert_equal __(true), hash.keys.include?(:two)
    assert_equal __(Array), hash.keys.class
  end

  def test_hash_values
    hash = { :one => "uno", :two => "dos" }
    assert_equal __(2), hash.values.size
    assert_equal __(true), hash.values.include?("uno")
    assert_equal __(true), hash.values.include?("dos")
    assert_equal __(Array), hash.values.class
  end

  def test_combining_hashes
    hash = { "jim" => 53, "amy" => 20, "dan" => 23 }
    new_hash = hash.merge({ "jim" => 54, "jenny" => 26 })

    assert_equal __(true), hash != new_hash

    expected = { "jim" => __(54), "amy" => 20, "dan" => 23, "jenny" => __(26) }
    assert_equal __(true), expected == new_hash
  end
end
