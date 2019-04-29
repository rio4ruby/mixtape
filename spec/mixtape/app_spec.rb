# frozen_string_literal: true

require 'mixtape/app'
require 'rio'

RSpec.describe Mixtape::App, '::run' do
  let(:input_data) do
    {
      users: [{ id: '100', name: 'n1' }, { id: '101', name: 'n2' }],
      songs: [{ id: '100', artist: 'a1', title: 't1' }, { id: '101', artist: 'a2', title: 't2' }],
      playlists: [{ id: '100', user_id: '100', song_ids: ['100'] }]
    }
  end

  context 'input files' do
    let(:changes_data) do
      {
        changes: []
      }
    end
    it 'fails if input file does not exist' do
      rio('input.json').rm
      rio('changes.json').puts!(changes_data.to_json)
      expect { Mixtape::App.run('input.json', 'changes.json', 'output.json') }.to raise_error(Mixtape::Exception)
    end
    it 'fails if changes file does not exist' do
      rio('input.json').puts!(input_data.to_json)
      rio('changes.json').rm
      expect { Mixtape::App.run('input.json', 'changes.json', 'output.json') }.to raise_error(Mixtape::Exception)
    end
    it 'fails with bad input data' do
      rio('input.json').puts!(input_data.to_json.chop)
      rio('changes.json').puts!(changes_data.to_json)
      expect { Mixtape::App.run('input.json', 'changes.json', 'output.json') }.to raise_error(Mixtape::Exception)
    end
    it 'fails with bad changes data' do
      rio('input.json').puts!(input_data.to_json)
      rio('changes.json').puts!(changes_data.to_json.chop)
      expect { Mixtape::App.run('input.json', 'changes.json', 'output.json') }.to raise_error(Mixtape::Exception)
    end
  end

  context 'add_new_playlist_for_user' do
    let(:changes_data) do
      {
        changes: [
          { action: 'add_new_playlist_for_user', user_id: '101', song_ids: ['101'] }
        ]
      }
    end
    it 'makes the change' do
      rio('input.json').puts!(input_data.to_json)
      rio('changes.json').puts!(changes_data.to_json)
      Mixtape::App.run('input.json', 'changes.json', 'output.json')
      ans = JSON.parse(rio('output.json').read)
      expect(ans['playlists'].size).to eq 2
      expect(ans['playlists'].last['user_id']).to eq '101'
      expect(ans['playlists'].last['song_ids']).to eq ['101']
    end
    it 'works when at least one song exists' do
      rio('input.json').puts!(input_data.to_json)
      changes_data[:changes].first[:song_ids] = %w[666 101]
      rio('changes.json').puts!(changes_data.to_json)
      Mixtape::App.run('input.json', 'changes.json', 'output.json')
      ans = JSON.parse(rio('output.json').read)
      expect(ans['playlists'].size).to eq 2
      expect(ans['playlists'].last['song_ids']).to eq %w[666 101]
    end
    it 'fails when user does non exist' do
      rio('input.json').puts!(input_data.to_json)
      changes_data[:changes].first[:user_id] = '666'
      rio('changes.json').puts!(changes_data.to_json)
      expect { Mixtape::App.run('input.json', 'changes.json', 'output.json') }.to raise_error(Mixtape::Exception::MissingUser)
    end
    it 'fails when playlist does not contain at least one existing song' do
      rio('input.json').puts!(input_data.to_json)
      changes_data[:changes].first[:song_ids] = ['666']
      rio('changes.json').puts!(changes_data.to_json)
      expect { Mixtape::App.run('input.json', 'changes.json', 'output.json') }.to raise_error(Mixtape::Exception::NoSongsExist)
    end
    it 'fails when playlist is empty' do
      rio('input.json').puts!(input_data.to_json)
      changes_data[:changes].first[:song_ids] = []
      rio('changes.json').puts!(changes_data.to_json)
      expect { Mixtape::App.run('input.json', 'changes.json', 'output.json') }.to raise_error(Mixtape::Exception::NoSongsExist)
    end
  end

  context 'add_song_to_playlist' do
    let(:changes_data) do
      {
        changes: [
          { action: 'add_song_to_playlist', song_id: '101', playlist_id: '100' }
        ]
      }
    end
    it 'makes the change' do
      rio('input.json').puts!(input_data.to_json)
      rio('changes.json').puts!(changes_data.to_json)
      Mixtape::App.run('input.json', 'changes.json', 'output.json')
      ans = JSON.parse(rio('output.json').read)
      expect(ans['playlists'].first['song_ids'].include?('101')).to eq true
    end
    it 'fails when song does non exist' do
      rio('input.json').puts!(input_data.to_json)
      changes_data[:changes].first[:song_id] = '666'
      rio('changes.json').puts!(changes_data.to_json)
      expect { Mixtape::App.run('input.json', 'changes.json', 'output.json') }.to raise_error(Mixtape::Exception::MissingSong)
    end
    it 'fails when playlist does non exist' do
      rio('input.json').puts!(input_data.to_json)
      changes_data[:changes].first[:playlist_id] = '666'
      rio('changes.json').puts!(changes_data.to_json)
      expect { Mixtape::App.run('input.json', 'changes.json', 'output.json') }.to raise_error(Mixtape::Exception::MissingPlaylist)
    end
  end

  context 'remove_playlist' do
    let(:changes_data) do
      {
        changes: [
          { action: 'remove_playlist', playlist_id: '100' }
        ]
      }
    end
    it 'makes the change' do
      rio('input.json').puts!(input_data.to_json)
      rio('changes.json').puts!(changes_data.to_json)
      Mixtape::App.run('input.json', 'changes.json', 'output.json')
      ans = JSON.parse(rio('output.json').read)
      expect(ans['playlists']).to be_empty
    end
    it 'fails when playlist does non exist' do
      rio('input.json').puts!(input_data.to_json)
      changes_data[:changes].first[:playlist_id] = '666'
      rio('changes.json').puts!(changes_data.to_json)
      expect { Mixtape::App.run('input.json', 'changes.json', 'output.json') }.to raise_error(Mixtape::Exception::MissingPlaylist)
    end
  end
end
