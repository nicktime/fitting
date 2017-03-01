require 'fitting/version'
require 'fitting/configuration'
require 'fitting/documentation/response/route'
require 'fitting/documentation/request/route'
require 'fitting/storage/responses'
require 'fitting/storage/documentation'
require 'fitting/report/response'
require 'fitting/matchers/response_matcher'

module Fitting
  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end

module RSpec
  module Core
    # Provides the main entry point to run a suite of RSpec examples.
    class Runner
      alias origin_run_specs run_specs

      def run_specs(example_groups)
        origin_run_specs(example_groups)

        response_routes = Fitting::Documentation::Response::Route.new(
          Fitting::Storage::Documentation.hash,
          Fitting::Storage::Responses.all
        )
        request_routes = Fitting::Documentation::Request::Route.new(response_routes)

        valid_count = response_routes.coverage.size
        valid_percentage = response_routes.cover_ratio
        total_count = response_routes.all.size
        invalid_count = response_routes.not_coverage.size
        invalid_percentage = 100.0 - response_routes.cover_ratio
        puts "API responses conforming to the blueprint: #{valid_count} (#{valid_percentage}% of #{total_count})."
        puts "API responses with validation errors or untested: #{invalid_count} (#{invalid_percentage}% of #{total_count})."
        puts
        puts "Conforming responses: \n#{response_routes.to_hash['coverage'].join("\n")} \n\n"
        puts "Non-conforming responses: \n#{response_routes.to_hash['not coverage'].join("\n")}\n\n"
        Fitting::Report::Response.new('report_response.yaml', response_routes).save
        Fitting::Report::Response.new('report_request_by_response.yaml', request_routes).save
      end
    end
  end
end
