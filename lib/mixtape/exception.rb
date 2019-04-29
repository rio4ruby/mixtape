# frozen_string_literal: true

module Mixtape
  class Exception < StandardError
    def initialize(msg = 'unknown mixtape error')
      super
    end
    class MissingSong < RuntimeError
      def initialize(id)
        super("Song with id '#{id}' does not exist")
      end
    end
    class MissingPlaylist < RuntimeError
      def initialize(id)
        super("Playlist with id '#{id}' does not exist")
      end
    end
    class MissingUser < RuntimeError
      def initialize(id)
        super("User with id '#{id}' does not exist")
      end
    end
    class NoSongsExist < RuntimeError
      def initialize
        super('No songs exist in the list')
      end
    end
  end
end
