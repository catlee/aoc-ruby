require "test_helper"
require "tmpdir"

class AocTest < Minitest::Test
  def setup
    ENV.delete('AOC_SESSION')
    ENV.delete('AOC_YEAR')
  end

  def test_that_it_has_a_version_number
    refute_nil ::AoC::VERSION
  end

  def test_get_year_directory
    Dir.mktmpdir("2019") do |tmpdir|
      Dir.chdir(tmpdir)
      assert_equal AoC.get_year, 2019
    end
  end

  def test_get_year_env
    ENV['AOC_YEAR'] = "2032"
    Dir.mktmpdir("2019") do |tmpdir|
      Dir.chdir(tmpdir)
      assert_equal AoC.get_year, 2032
    end
  end
end
