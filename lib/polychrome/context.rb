# frozen_string_literal: true

require "weakref"

module Polychrome
  class Context
    class << self
      attr_accessor :connection
    end

    def self.current
      STACK.last
    end

    def initialize
      @map = {}
    end

    def add(o)
      @map[o.class] ||= []
      @map[o.class] << WeakRef.new(o)
    end

    def all(cls)
      @map[cls] || []
    end

    def with
      STACK << self
      yield
    ensure
      STACK.pop
    end

    # define at end
    STACK = [new]
  end
end
