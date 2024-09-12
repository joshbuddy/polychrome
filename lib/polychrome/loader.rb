require_relative "loader/fetcher"
require_relative "loader/fetcher_state"

module Polychrome
  module Loader
    def self.included(cls)
      cls.class_variable_set(:@@fetchers, {})
      cls.extend(ClassMethods)
    end

    module ClassMethods
      def load_many(name, get:, &loader)
        class_variable_get(:@@fetchers)[name] = Fetcher.new(self, name, :many, get, loader)
      end

      def load_one(name, get:, &loader)
        class_variable_get(:@@fetchers)[name] = Fetcher.new(self, name, :one, get, loader)
      end
    end

    def load(name)
      _fetcher(name).fetch
    end

    def _fetcher(name)
      ivar_name = :"@_fetcher_#{name}"
      if instance_variable_defined?(ivar_name)
        instance_variable_get(ivar_name)
      else
        fetchers = self.class.class_variable_get(:@@fetchers)
        fetcher = fetchers[name] or raise "no loader named #{name}"
        fetcher_state = FetcherState.new(fetcher)
        instance_variable_set(ivar_name, fetcher_state)
        fetcher_state
      end
    end
  end
end
