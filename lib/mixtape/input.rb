# frozen_string_literal: true

require 'json'
require 'forwardable'
require_relative './exception'

module Mixtape
  # defines the input of data.
  # currently this comes from a json file.
  # The #data method returns the parsed json from that file.
  class Input
    extend Forwardable

    attr_reader :file_name
    def initialize(file_name)
      @file_name = file_name
    end

    def data
      @data ||= JSON.parse(json)
    rescue Errno::ENOENT => e
      raise Mixtape::Exception, "File '#{file_name}' does not exist. Error is '#{e}'"
    rescue JSON::ParserError => e
      raise Mixtape::Exception, "File '#{file_name}' does not contain valid json. #{e}"
    end

    # delegate some common hash operations to the data field.
    def_delegators :data, :keys, :[]

    private

    def json
      File.read(file_name)
    end
  end
end
