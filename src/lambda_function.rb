# frozen_string_literal: true

# require 'nothing'

# Responds with a hello world

# @return [Hash] Payload
def handler(event:, context:) # rubocop:disable Lint/UnusedMethodArgument
  {
    "statusCode": 200,
    "body": 'Hello World!'
  }
end
