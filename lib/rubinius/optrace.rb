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
      @started = true
      self
    end

    def stop
      if @started then
        @results = Rubinius::Tooling.disable
        @started = false
        @stopped = true
      end
      self
    end

    #TODO: This is slow. Might want to optimize or memoize the result
    def trace 
      return nil unless @stopped
      trace = nil
      @results.each do |r|
        ip = r[0]
        trace << r[1].decode.select { |t| t.ip == ip }
      end
      trace
    end
  end
end

