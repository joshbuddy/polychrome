module Polychrome
  module SQL
    class Model
      attr_accessor :id

      def initialize(**values)
        values.each do |name, val|
          send("#{name}=", val)
        end
        Context.current.add(self)

        return unless self.class.class_variable_defined?(:@@_fetchers)

        self.class.class_variable_get(:@@_fetchers).each do |fetcher|
          state = Fetcher::State.new
          state.fetcher = fetcher
          instance_variable_set(fetcher.attr_name, state)
        end
      end

      def self.get(id)
        results = Context.connection["select * from #{tablename} where id = ?", id].first
        new(**results)
      end

      def self.tablename
        to_s.downcase.pluralize
      end

      def self.sql(statement, *vars)
        puts "statement: #{statement} vars: #{vars.inspect}"
        results = Context.connection[statement, *vars]
        p results.count
        results.map { |r| new(**r) }
      end

      def self.many(name, &lookup)
        fetcher = Fetcher.new(name, lookup)
        if class_variable_defined?(:@@_fetchers)
          class_variable_set(:@@_fetchers, class_variable_get(:@@_fetchers) << fetcher)
        else
          class_variable_set(:@@_fetchers, [fetcher])
        end

        cls = self
        define_method(name) do
          puts "self is #{self}"
          state = instance_variable_get(fetcher.attr_name)
          puts "state is #{self} #{state}"
          unless state.executed
            puts "RUNNING FETCHER!"
            fetcher.execute(Context.current.all(cls))
          end
          state.value
        end
      end

      def insert!
        Context.connection.execute("insert into #{self.class.tablename} (id) VALUES (?)", [id])
      end
    end
  end
end
