# frozen_string_literal: true

module Polychrome
  module Loader
    class Fetcher
      attr_reader :target_class, :name, :type, :getter, :loader

      def initialize(target_class, name, type, getter, loader)
        @target_class = target_class
        @name = name
        @type = type
        @getter = getter
        @loader = loader
      end

      def fetch
        siblings = Context.current.all(target_class)
        ids = siblings.map { |o| o.send(getter) }
        results = loader.call(ids, nil)
        siblings.each_with_index do |s, i|
          s._fetcher(name).results = results[ids[i]]
        end
      end
    end
  end
end
