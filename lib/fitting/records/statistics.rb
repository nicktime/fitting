module Fitting
  class Records
    class Statistics
      def initialize(requests)
        @requests = requests
        @all_responses = 0
        @cover_responses = 0
        @not_cover_responses = 0
      end

      def to_s(requests)
        requests.inject([]) do |res, request|
          res.push("#{request.method}\t#{request.path}")
        end.join("\n")
      end

      def percent(divider, dividend)
        return 0 if divider == 0
        (dividend.to_f / divider.to_f * 100.0).round(2)
      end

      def statistics_with_conformity_lists
        check_responses
        @requests
        [
          'Fully conforming requests:',
          to_s(coverage_fully),
          '',
          'Partially conforming requests:',
          to_s(coverage_partially),
          '',
          'Non-conforming requests:',
          to_s(coverage_non),
          '',
          "API requests with fully implemented responses: #{coverage_fully.size} (#{percent(@requests.size, coverage_fully.size)}% of #{@requests.size}).",
          "API requests with partially implemented responses: #{coverage_partially.size} (#{percent(@requests.size, coverage_partially.size)}% of #{@requests.size}).",
          "API requests with no implemented responses: #{coverage_non.size} (#{percent(@requests.size, coverage_non.size)}% of #{@requests.size}).",
          '',
          "API responses conforming to the blueprint: #{@cover_responses} (#{percent(@all_responses, @cover_responses)}% of #{@all_responses}).",
          "API responses with validation errors or untested: #{@not_cover_responses} (#{percent(@all_responses, @not_cover_responses)}% of #{@all_responses})."
        ].join("\n")
      end

      def check_responses
        @requests.to_a.map do |request|
          request.responses.to_a.map do |response|
            response.json_schemas.map do |json_schema|
              if json_schema.bodies == []
                @not_cover_responses += 1
              else
                @cover_responses += 1
              end
              @all_responses += 1
            end
          end
        end
      end

      def coverage_fully
        @coverage_fully ||= @requests.inject([]) do |res, request|
          next res unless request.state == 'fully'
          res.push(request)
        end
      end

      def coverage_non
        @coverage_non ||= @requests.inject([]) do |res, request|
          next res unless request.state == 'non'
          res.push(request)
        end
      end

      def coverage_partially
        @coverage_partially ||= @requests.inject([]) do |res, request|
          next res unless request.state == 'partially'
          res.push(request)
        end
      end
    end
  end
end
