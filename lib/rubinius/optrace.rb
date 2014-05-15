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

    # The :results array is a of <inst_ptr, CompiledCode, thread_id> arrays
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
      @trace = Array.new
      @results.each do |r|
        elm = Array.new
        elm << r[2]
        elm << r[1].decode.select { |t| t.ip == r[0] }
        @trace << elm
      end
      @trace
    end

    def print_trace 
      res = String.new
      self.trace if @trace.nil?
      @trace.each { |t| res << "#{t[0]}:   #{t[1][0]}\n" }
      res
    end

  end
end

