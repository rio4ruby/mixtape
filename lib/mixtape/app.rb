# frozen_string_literal: true

require 'json'
require_relative 'exception'
require_relative 'input'
require_relative 'input_index'
require_relative 'changes_processor'

module Mixtape
  class App
    attr_reader :input_file, :changes_file, :output_file
    def initialize(input_file, changes_file, output_file)
      @input_file = input_file
      @changes_file = changes_file
      @output_file = output_file
    end

    def input
      @input ||= Mixtape::Input.new(input_file)
    end

    def changes
      @changes ||= Mixtape::Input.new(changes_file)
    end

    def index
      @index ||= Mixtape::InputIndex.new(input)
    end

    def self.run(*args)
      new(*args).run
    end

    def run
      Mixtape::ChangesProcessor.process(index, changes)
      File.open(output_file, 'w') do |file|
        file.puts(JSON.pretty_generate(input.data))
      end
      return true
    rescue Mixtape::Exception => e
      $stderr.puts e.to_s
      return false
    end
  end
end
