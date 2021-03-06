#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"helper.rb")

class McryptBasicsTest < Test::Unit::TestCase
  
  def test_instantiate_basic
    mc = Mcrypt.new(:tripledes, :cbc)
    assert_not_nil mc
  end

  def test_invalid_algorithm_or_mode
    # blatantly incorrect algorithm
    assert_raise Mcrypt::InvalidAlgorithmOrModeError do
        Mcrypt.new(:no_such_algorithm, :cbc)
    end
    # blatantly incorrect mode
    assert_raise Mcrypt::InvalidAlgorithmOrModeError do
        Mcrypt.new(:tripledes, :no_such_mode)
    end
    # bad combination of otherwise valid algo/mode
    assert_raise Mcrypt::InvalidAlgorithmOrModeError do
        Mcrypt.new(:wake, :cbc)
    end
  end

  def test_canonicalization
    assert_equal "rijndael-256", Mcrypt.new(:rijndael_256, :cfb).algorithm
    assert_equal "rijndael-256", Mcrypt.new("rijndael-256", :cfb).algorithm
  end

  def test_mode_accessor
    assert_equal "cfb", Mcrypt.new(:rijndael_256, :cfb).mode
    assert_equal "cfb", Mcrypt.new(:rijndael_256, "cfb").mode
  end

  def test_padding_initialization
    assert_equal :pkcs, Mcrypt.new(:twofish, :cfb, nil, nil, true).padding
    assert_equal :pkcs, Mcrypt.new(:twofish, :cfb, nil, nil, :pkcs).padding
    assert_equal :pkcs, Mcrypt.new(:twofish, :cfb, nil, nil, "pkcs").padding
    assert_equal :pkcs, Mcrypt.new(:twofish, :cfb, nil, nil, "pkcs7").padding
    assert_equal :pkcs, Mcrypt.new(:twofish, :cfb, nil, nil, "pkcs5").padding

    assert_equal :zeros, Mcrypt.new(:twofish, :cfb, nil, nil, :zeros).padding
    assert_equal :zeros, Mcrypt.new(:twofish, :cfb, nil, nil, :zeroes).padding

    assert_equal false, Mcrypt.new(:twofish, :cfb, nil, nil, :none).padding
    assert_equal false, Mcrypt.new(:twofish, :cfb, nil, nil, "none").padding
    assert_equal false, Mcrypt.new(:twofish, :cfb, nil, nil, false).padding
    assert_equal false, Mcrypt.new(:twofish, :cfb, nil, nil, nil).padding
    assert_equal false, Mcrypt.new(:twofish, :cfb, nil, nil, "").padding
  end
  
  def test_key_size
    assert_equal 24, Mcrypt.new(:tripledes, :cbc).key_size
  end

  def test_block_size
  end
  
  def test_key_size
    assert_equal 24, Mcrypt.new(:tripledes, :cbc).key_size
  end

  def test_block_size
    assert_equal 32, Mcrypt.new(:rijndael_256, :cfb).block_size
    assert_equal 8, Mcrypt.new(:des, :cbc).block_size
  end

  def test_iv_size
    assert_equal 32, Mcrypt.new(:rijndael_256, :cfb).iv_size
    assert_equal 8, Mcrypt.new(:des, :cbc).iv_size
    assert_nil Mcrypt.new(:tripledes, :ecb).iv_size
  end

  def test_block_algorithm_b
    assert_equal true, Mcrypt.new(:tripledes, :cbc).block_algorithm?
    assert_equal false, Mcrypt.new(:wake, :stream).block_algorithm?
  end

  def test_block_mode_b
    assert_equal true, Mcrypt.new(:tripledes, :cbc).block_mode?
    assert_equal false, Mcrypt.new(:wake, :stream).block_mode?
  end

  def test_block_algorithm_mode_b
    assert_equal true, Mcrypt.new(:tripledes, :cbc).block_algorithm_mode?
    assert_equal false, Mcrypt.new(:wake, :stream).block_algorithm_mode?
  end

  def test_mode_has_iv_b
    assert_equal true, Mcrypt.new(:tripledes, :cbc).has_iv?
    assert_equal false, Mcrypt.new(:tripledes, :ecb).has_iv?
  end

  def test_key_sizes
    assert_equal [16,24,32], Mcrypt.new(:twofish, :cbc).key_sizes
    assert_equal [32], Mcrypt.new(:wake, :stream).key_sizes
    assert_equal (1..128).to_a, Mcrypt.new(:rc2, :cbc).key_sizes
  end

  def test_algorithm_version
    assert_kind_of Integer, Mcrypt.new(:rijndael_256, :cfb).algorithm_version
  end

  def test_mode_version
    assert_kind_of Integer, Mcrypt.new(:rijndael_256, :cfb).mode_version
  end

  # CLASS METHODS
  def test_class_algorithms
    assert_equal ['tripledes','twofish'], Mcrypt.algorithms.grep(/tripledes|twofish/).sort
  end

  def test_class_modes
    assert_equal ['cbc','cfb'], Mcrypt.modes.grep(/\A(cbc|cfb)\Z/).sort
  end

  def test_class_block_algorithm_b
    assert_equal true, Mcrypt.block_algorithm?(:tripledes)
    assert_equal false, Mcrypt.block_algorithm?(:wake)
  end

  def test_class_key_size
    assert_equal 24, Mcrypt.key_size(:tripledes)
  end

  def test_class_block_size
    assert_equal 32, Mcrypt.block_size(:rijndael_256)
    assert_equal 8, Mcrypt.block_size(:des)
  end

  def test_class_key_sizes
    assert_equal [16,24,32], Mcrypt.key_sizes(:twofish)
    assert_equal [32], Mcrypt.key_sizes(:wake)
    assert_equal (1..128).to_a, Mcrypt.key_sizes(:rc2)
  end

  def test_class_block_algorithm_mode_b
    assert_equal true, Mcrypt.block_algorithm_mode?(:cbc)
    assert_equal true, Mcrypt.block_algorithm_mode?(:cfb)
    assert_equal false, Mcrypt.block_algorithm_mode?(:stream)
  end

  def test_class_block_mode_b
    assert_equal true, Mcrypt.block_mode?(:cbc)
    assert_equal false, Mcrypt.block_mode?(:cfb)
    assert_equal false, Mcrypt.block_mode?(:stream)
  end

  def test_class_algorithm_version
    assert_kind_of Integer, Mcrypt.algorithm_version(:rijndael_256)
  end

  def test_class_mode_version
    assert_kind_of Integer, Mcrypt.mode_version(:cfb)
  end

  def test_class_algorithm_info
    info = Mcrypt.algorithm_info(:rijndael_256)
    assert_equal true, info[:block_algorithm]
    assert_equal 32, info[:block_size]
    assert_equal 32, info[:key_size]
    assert_equal [16,24,32], info[:key_sizes]
    assert_kind_of Integer, info[:algorithm_version]
  end

  def test_class_mode_info
    info = Mcrypt.mode_info(:cbc)
    assert_equal true, info[:block_mode]
    assert_equal true, info[:block_algorithm_mode]
    assert_kind_of Integer, info[:mode_version]

    info = Mcrypt.mode_info(:cfb)
    assert_equal false, info[:block_mode]
    assert_equal true, info[:block_algorithm_mode]
    assert_kind_of Integer, info[:mode_version]

    info = Mcrypt.mode_info(:stream)
    assert_equal false, info[:block_mode]
    assert_equal false, info[:block_algorithm_mode]
    assert_kind_of Integer, info[:mode_version]
  end

  def test_bad_key_length_is_rejected
    assert_raise Mcrypt::InvalidKeyError do
      Mcrypt.new(:tripledes,:cbc,"0"*64)
    end
  end

  def test_good_key_length_is_not_rejected
    assert_nothing_raised do
      Mcrypt.new(:tripledes,:cbc,"0"*24)
    end
  end

  def test_bad_iv_length_is_rejected
    assert_raise Mcrypt::InvalidIVError do
      Mcrypt.new(:tripledes,:cbc,"0"*24,"0"*32)
    end
  end

  def test_good_iv_length_is_not_rejected
    assert_nothing_raised do
      Mcrypt.new(:tripledes,:cbc,"0"*24,"0"*8)
    end
  end

  def test_unused_iv_is_rejected
    # positive case is tested implicitly in test_good_iv_length_is_not_rejected
    assert_raise Mcrypt::InvalidIVError do
      Mcrypt.new(:tripledes,:ecb,"0"*24,"0"*8)
    end
  end

end
