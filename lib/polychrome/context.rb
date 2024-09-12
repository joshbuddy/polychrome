# frozen_string_literal: true

require "objspace"

module Polychrome
  class Context
    class << self
      attr_accessor :connection
    end

    def self.current
      STACK.last
    end

    def all(cls)
      ObjectSpace.each_object(cls)
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
