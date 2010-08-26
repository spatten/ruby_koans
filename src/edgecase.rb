#!/usr/bin/env ruby
# -*- ruby -*-

require 'test/unit/assertions'

class FillMeInError < StandardError
end

def in_ruby_version(version)
  yield if RUBY_VERSION =~ /^#{version}/
end

def __(value="FILL ME IN", value19=:mu)
  if RUBY_VERSION < "1.9"
    value
  else
    (value19 == :mu) ? value : value19
  end
end

def _n_(value=999999, value19=:mu)
  if RUBY_VERSION < "1.9"
    value
  else
    (value19 == :mu) ? value : value19
  end
end

def ___(value=FillMeInError)
  value
end

class Object
  def ____(method=nil)
    if method
      self.send(method)
    end
  end

  in_ruby_version("1.9") do
    public :method_missing
  end
end

module EdgeCase

  module Color
    #shamelessly stolen from redgreen
    COLORS = { :clear => 0, :red => 31, :green => 32, :yellow => 33, :blue => 34, :magenta => 35, :cyan => 36 }
    def self.method_missing(color_name, *args)
      color(color_name) + args.first + color(:clear) 
    end 
    def self.color(color)
      "\e[#{COLORS[color.to_sym]}m"
    end 
  end

  class Sensei
    attr_reader :failure, :failed_test

    in_ruby_version("1.8") do
      AssertionError = Test::Unit::AssertionFailedError
    end

    in_ruby_version("1.9") do
      if defined?(MiniTest)
        AssertionError = MiniTest::Assertion
      else
        AssertionError = Test::Unit::AssertionFailedError
      end
    end

    def initialize
      @pass_count = 0
      @failure = nil
      @failed_test = nil
    end

    def accumulate(test)
      if test.passed?
        @pass_count += 1
        puts Color.green("  #{test.name} has expanded your awareness.")
      else
        puts Color.red("  #{test.name} has damaged your karma.")
        @failed_test = test
        @failure = test.failure
        throw :edgecase_exit
      end
    end

    def failed?
      ! @failure.nil?
    end

    def assert_failed?
      failure.is_a?(AssertionError)
    end

    def report
      if failed?
        puts
        puts Color.green("You have not yet reached enlightenment ...")
        puts Color.red(failure.message)
        puts
        puts Color.green("Please meditate on the following code:")
        if assert_failed?
          #puts find_interesting_lines(failure.backtrace)
          puts find_interesting_lines(failure.backtrace).collect {|l| Color.red(l) }
        else
          puts Color.red(failure.backtrace)
        end
        puts
      end
      puts Color.green(say_something_zenlike)
    end

    def find_interesting_lines(backtrace)
      backtrace.reject { |line|
        line =~ /test\/unit\/|edgecase\.rb/
      }
    end

    # Hat's tip to Ara T. Howard for the zen statements from his
    # metakoans Ruby Quiz (http://rubyquiz.com/quiz67.html)
    def say_something_zenlike
      puts
      if !failed?
        zen_statement =  "Mountains are again merely mountains"
      else
        zen_statement = case (@pass_count % 10)
        when 0
          "mountains are merely mountains"
        when 1, 2
          "learn the rules so you know how to break them properly"
        when 3, 4
          "remember that silence is sometimes the best answer"
        when 5, 6
          "sleep is the best meditation"
        when 7, 8
          "when you lose, don't lose the lesson"
        else
          "things are not what they appear to be: nor are they otherwise"
        end
      end
      zen_statement
    end
  end

  class Koan
    include Test::Unit::Assertions

    attr_reader :name, :failure

    def initialize(name)
      @name = name
      @failure = nil
    end

    def passed?
      @failure.nil?
    end

    def failed(failure)
      @failure = failure
    end

    def setup
    end

    def teardown
    end

    # Class methods for the EdgeCase test suite.
    class << self
      def inherited(subclass)
        subclasses << subclass
      end

      def method_added(name)
        testmethods << name unless tests_disabled?
      end

      def run_tests(accumulator)
        puts
        puts Color.green("Thinking #{self}")
        testmethods.each do |m|
          self.run_test(m, accumulator) if Koan.test_pattern =~ m.to_s
        end
      end

      def run_test(method, accumulator)
        test = self.new(method)
        test.setup
        begin
          test.send(method)
        rescue StandardError, EdgeCase::Sensei::AssertionError => ex
          test.failed(ex)
        ensure
          begin
            test.teardown
          rescue StandardError, EdgeCase::Sensei::AssertionError => ex
            test.failed(ex) if test.passed?
          end
        end
        accumulator.accumulate(test)
      end

      def end_of_enlightenment
        @tests_disabled = true
      end

      def command_line(args)
        args.each do |arg|
          case arg
          when /^-n\/(.*)\/$/
            @test_pattern = Regexp.new($1)
          when /^-n(.*)$/
            @test_pattern = Regexp.new(Regexp.quote($1))
          else
            if File.exist?(arg)
              load(arg)
            else
              fail "Unknown command line argument '#{arg}'"
            end
          end
        end
      end

      # Lazy initialize list of subclasses
      def subclasses
        @subclasses ||= []
      end

       # Lazy initialize list of test methods.
      def testmethods
        @test_methods ||= []
      end

      def tests_disabled?
        @tests_disabled ||= false
      end

      def test_pattern
        @test_pattern ||= /^test_/
      end

    end
  end
end

END {
  EdgeCase::Koan.command_line(ARGV)
  zen_master = EdgeCase::Sensei.new
  catch(:edgecase_exit) {
    EdgeCase::Koan.subclasses.each do |sc|
      sc.run_tests(zen_master)
    end
  }
  zen_master.report
}
