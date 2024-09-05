module Polychrome
  module SQL
    class Fetcher
      class State
        attr_accessor :value, :executed, :fetcher
      end

      attr_reader :name, :attr_name

      def initialize(name, lookup)
        @name = name
        @lookup = lookup
        @attr_name = :"@_fetcher_state_#{name}"
      end

      def execute(objs)
        ids = objs.map(&:id)
        value = @lookup.call(ids)
        puts "attr_name: #{attr_name} #{value.inspect}"
        objs.each_with_index do |obj, i|
          state = obj.__getobj__.instance_variable_get(attr_name)
          state.value = value[ids[i]]
          state.executed = true
        end
      end
    end
  end
end
