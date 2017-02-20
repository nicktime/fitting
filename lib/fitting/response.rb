module Fitting
  class Response
    attr_accessor :status, :body, :schemas

    def initialize(env_response, expect_request)
      @status = env_response.status
      @body = env_response.body
      @schemas = expect_request.find_responses(status: @status).map{|response|response['body']} if expect_request
      @fully_validates = set_fully_validate if @schemas
      self
    end

    def set_fully_validate
      @valid = false
      fully_validates = []
      @schemas.map do |old_schema|
        fully_validate = JSON::Validator.fully_validate(old_schema, @body)
        fully_validates.push(fully_validate)
        @valid = true if fully_validate == []
      end
      fully_validates
    end

    def to_hash
      {
        'status' => @status,
        'body' => @body,
        'schemas' => @schemas,
        'fully_validates' => @fully_validates,
        'valid' => @valid
      }
    end
  end
end
