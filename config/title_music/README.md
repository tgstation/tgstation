# Title Music Configuration

The `sounds` folder contains audio files used as title music. These files must be in the `.json` format.

## Schema

Each `.json` file can be either a single object or an array of objects, adhering to the following schema:

* url (required)  Publicly accessible web address of the MP3 audio file.
* title (required)  Song title.
* duration (required)  Song duration in deciseconds (10 seconds = 100 deciseconds).
* artist (optional)  Name of the artist.
* genre (optional)  Genre classification (e.g., Electronic, Rock).
* lobby (optional)  Set to `true` for the song to play in the lobby (defaults to `false`).
* jukebox (optional)  Set to `true` for the song to be playable on the in-game jukebox (defaults to `false`).


## Examples

**Minimal Track**

```json
{
  "url": "https://publicallyAccessibleWebsite.example/path/to/soundfile.mp3",
  "title": "Song Title",
  "duration": 2150
}
```

**Full Example**

```json
{
  "url": "https://files.catbox.moe/oe3r2f.mp3",
  "title": "Look Forward",
  "duration": 2470,
  "artist": "Skyline",
  "genre": "Electronic",
  "lobby": true,
  "jukebox": true
}
```

## Grouping Tracks

For artists with multiple tracks, it's recommended to create a single `.json` file as an array of objects.

**Example (chronoquest.json)**

```json
[
  {
    "url": "https://files.catbox.moe/cdf7ab.mp3",
    "title": "Future Imperfect",
    "duration": 1820,
    "artist": "Chronoquest",
    "genre": "Electronic",
    "lobby": true,
    "jukebox": true
  },
  {
    "url": "https://files.catbox.moe/aude0k.mp3",
    "title": "Space Station 3",
    "duration": 1960,
    "artist": "Chronoquest",
    "genre": "Electronic",
    "lobby": true,
    "jukebox": true
  },
  {
    "url": "https://files.catbox.moe/cjx1lj.mp3",
    "title": "Sitar Warriors",
    "duration": 1400,
    "artist": "Chronoquest",
    "genre": "Electronic",
    "lobby": true,
    "jukebox": true
  }
]
```

### Sidenotes

This folder *used* to accept BYOND sound file formats, but:
- sending files to the client is slow, and you'd have to hyper-compress the shit out of those files if you want a chance at the client NOT stalling the game, because file transfers lock the game until done.
- lobby music sounded like shit because of how compressed the files were
- *do i need to go on?*
