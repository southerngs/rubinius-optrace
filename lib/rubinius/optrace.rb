require "rubinius/optrace/version"

module Rubinius

  class Optrace 
    def self.test_method
      puts "Optrace gem loaded"
    end

    def self.loaded(flag)
      @loaded = flag
    end

    def self.loaded?
      @loaded == true
    end

    def self.load
      return if loaded?

      Rubinius::Tooling.load File.expand_path('../optrace/optrace', __FILE__)
      loaded true

      self
    end

    # :results is an array of [Integer, CompiledCode] instances
    attr_reader :results

    def initialize
      self.class.load
    end

    def start
      Rubinius::Tooling.enable
      self
    end

    def stop
      @results = Rubinius::Tooling.disable
      self
    end

    #TODO: This is slow. Might want to optimize or memoize the result
    def trace 
      trace = Array.new
      @results.each do |r|
        ip = r[0]
        trace << r[1].decode.select { |t| t.ip == ip }
      end
      trace
    end

  end
end
