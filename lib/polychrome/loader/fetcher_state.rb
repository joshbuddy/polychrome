# frozen_string_literal: true

module Polychrome
  module Loader
    class FetcherState
      attr_reader :results, :fetched

      def initialize(fetcher)
        @fetcher = fetcher
        @fetched = false
        @results = nil
      end

      def fetch
        @fetcher.fetch unless fetched

        results
      end

      def results=(results)
        @results = results
        @fetched = true
      end
    end
  end
end
