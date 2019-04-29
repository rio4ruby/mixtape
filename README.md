# mixtape
Transforms mixtape with specific changes

## Overview

**mixtape-transform** is a console application that
applies a batch of changes to an input file in order to create an output
file.

The program takes three parameters
* a mixtape.json file containing the current mixtape contents.
* a changes.json file containing the changes that are to be applied.
* the output file for the transformed mixtape.json file.

## Usage

$ mixtape-transform <input-file> <changes-file> <output-file>

## Details

### Basic Parameters

#### Input File

The input JSON file consists of a set of users, songs, and playlists

For example:

```json
{
  "users": [
    {
      "id": "1",
      "name": "Albin Jaye"
    },
    {
      "id": "2",
      "name": "Dipika Crescentia"
    },
  ],
  "playlists": [
    {
      "id": "1",
      "user_id": "2",
      "song_ids": [
        "1",
        "2"
      ]
    },
    {
      "id": "2",
      "user_id": "2",
      "song_ids": [
        "2",
      ]
    }
  ],
  "songs": [
    {
      "id": "1",
      "artist": "Camila Cabello",
      "title": "Never Be the Same"
    },
    {
      "id": "2",
      "artist": "Zedd",
      "title": "The Middle"
    },
  ]
}
```
#### Changes File

There are 3 supported changes

   1. Add an existing song to an existing playlist.
   2. Add a new playlist for an existing user; the playlist should contain at least one existing song.
   3. Remove an existing playlist.

For example:
```json
{
    "changes" : [
        {
            "action" : "add_song_to_playlist",
            "song_id" : "1",
            "playlist_id" : "2"
        },
        {
            "action" : "add_new_playlist_for_user",
            "user_id" : "1",
            "song_ids" : [
                "3",
                "5",
                "7",
                "9"
            ]
        },
        {
            "action" : "remove_playlist",
            "playlist_id" : "3"
        }
    ]
}
```
#### Output file

The output file will be the same as the input file after the changes have been applied.

### Testing

The source includes limited rspec tests to test basic functionality.

Running the tests require 2 additional gems:
* rspec
* rio
* 

### Future Enhancements

The usefullness of this program is limited by the fact that it reads the entire
input file and changes into memory before processing.

To get around this a couple of options are:
* Use a file back data store for the input files.
* Use a database to store ihe input
