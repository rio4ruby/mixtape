# frozen_string_literal: true

module Mixtape
  class InputIndex
    extend Forwardable

    attr_reader :input
    def initialize(input)
      @input = input
      build_index
    end

    def index
      @index ||= Hash[data_tables.map { |tbl_name| [tbl_name, {}] }]
    end

    # delegate some common hash operations to the index.
    def_delegators :index, :[], :[]=, :keys

    private

    def build_index
      data_tables.each do |tbl_name|
        input[tbl_name].each do |ent|
          index[tbl_name][ent['id']] = ent
        end
      end
    end

    def data_tables
      input.keys
    end
  end
end
