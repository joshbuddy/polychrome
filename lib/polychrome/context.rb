# frozen_string_literal: true

require "weakref"

module Polychrome
  class Context
    class << self
      attr_accessor :connection
    end

    def initialize
      @objs = {}
    end

    def self.current
      STACK.last
    end

    def add(instance)
      @objs[instance.class] ||= []
      @objs[instance.class] << WeakRef.new(instance)
    end

    def all(cls)
      @objs[cls]
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
