# frozen_string_literal: true

module Mixtape
  class ChangesProcessor
    attr_reader :index, :changes
    def initialize(index, changes)
      @index = index
      @changes = changes.data['changes']
    end

    def self.process(index, changes)
      new(index, changes).process
    end

    def process
      changes.each do |change|
        action = change.delete('action')
        next unless valid_action?(action)

        __send__(action, change)
      end
    end

    # Add an existing song to an existing playlist
    def add_song_to_playlist(param)
      song_id = param['song_id']
      playlist_id = param['playlist_id']
      raise Mixtape::Exception::MissingSong, song_id unless song?(song_id)
      raise Mixtape::Exception::MissingPlaylist, playlist_id unless playlist?(playlist_id)

      # While it is unreasonable that a playlist should exist without a 'song_ids' field we will cover for that.
      playlist(playlist_id)['song_ids'] ||= []
      playlist(playlist_id)['song_ids'].append(song_id)
    end

    # Add a new playlist for an existing user; the playlist should contain at least one existing song.
    def add_new_playlist_for_user(param)
      user_id = param['user_id']
      song_ids = param['song_ids']
      # make sure user exists and at least one song_id exists
      raise Mixtape::Exception::MissingUser, user_id unless user?(user_id)
      raise Mixtape::Exception::NoSongsExist unless any_songs_exist?(*song_ids)

      new_playlist = new_playlist_for_user(user_id, *song_ids)
      playlists_data.append(new_playlist)
      playlists_index[new_playlist['id']] = new_playlist
    end

    # remove an existing playlist
    def remove_playlist(param)
      playlist_id = param['playlist_id']
      raise Mixtape::Exception::MissingPlaylist, playlist_id unless playlist?(playlist_id)

      playlists_data.delete_if { |el| el['id'] == playlist_id }
      playlists_index.delete(playlist_id)
    end

    private

    def input
      index.input
    end

    def data
      input.data
    end

    def valid_action?(action)
      %w[add_song_to_playlist add_new_playlist_for_user remove_playlist].include?(action)
    end

    # Songs

    def song(id)
      songs_index[id]
    end

    def song?(id)
      !song(id).nil?
    end

    def songs_index
      index['songs']
    end

    def all_song_ids
      songs_index.keys
    end

    def any_songs_exist?(*song_ids)
      !(song_ids & all_song_ids).empty?
    end

    # Playlists

    def playlists_index
      index['playlists']
    end

    def playlists_data
      data['playlists']
    end

    def playlist(id)
      playlists_index[id]
    end

    def playlist?(id)
      !playlist(id).nil?
    end

    def all_playlist_ids
      playlists_index.keys
    end

    def next_playlist_id
      (all_playlist_ids.map(&:to_i).max + 1).to_s
    end

    # Users

    def user(id)
      users_index[id]
    end

    def user?(id)
      !user(id).nil?
    end

    def users_index
      index['users']
    end

    def new_playlist_for_user(user_id, *song_ids)
      {
        'id' => next_playlist_id,
        'user_id' => user_id,
        'song_ids' => song_ids
      }
    end
  end
end
