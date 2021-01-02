# Map Merger

The **Map Merger** is a collection of scripts that keep this repository's maps
in a format which is easier to track in Git and less likely to cause merge
conflicts. When merge conflicts do occur, it can sometimes resolve them.

For detailed troubleshooting instructions and other tips, visit the
[Map Merger] wiki article.

## Installation

To install the [Git hooks], open the `tools/hooks/` folder and double-click
`Install.bat`. Linux users run `tools/hooks/install.sh`.

## Manual Use

If using a Git GUI which is not compatible with the hooks:

* Before committing, double-click `Run Before Committing.bat`
* When a merge has map conflicts, double-click `Resolve Map Conflicts.bat`

The console will show whether the operation succeeded.

For more details, see the [Map Merger] wiki article.

## What Map Merging Is

The "map merge" operation describes the process of rewriting a map file written
by the DreamMaker map editor to A) use a format more amenable to Git's conflict
resolution and B) differ in the least amount textually from the previous
version of the map while maintaining all the actual changes. It requires an old
version of the map to use as a reference and a new version of the map which
contains the desired changes.

Map Merge 2 adds multi-Z support, automatic handling of key overflow, better
merge conflict prevention, and a real merge conflict resolver.

## Code Structure

Frontend scripts are meant to be run directly. They obey the environment
variables `TGM` to set whether files are saved in TGM (1) or DMM (0) format,
and `MAPROOT` to determine where maps are kept. By default, TGM is used and
the map root is autodetected. Each script may either prompt for the desired map
or be run with command-line parameters indicating which maps to act on. The
scripts include:

* `convert.py` for converting maps to and from the TGM format. Used by
  `tgm2dmm.bat` and `dmm2tgm.bat`.
* `mapmerge.py` for running the map merge on map backups saved by
  `Prepare Maps.bat`. Used by `mapmerge.bat`

Implementation modules:

* `dmm.py` includes the map reader and writer.
* `mapmerge.py` includes the implementation of the map merge operation.
* `frontend.py` includes the common code for the frontend scripts.

`precommit.py` is run by the [Git hooks] if installed, and merges the new
version of any map saved in the index (`git add`ed) with the old version stored
in Git when run.

[Map Merger]: https://tgstation13.org/wiki/Map_Merger
[Git hooks]: ../hooks/README.md
