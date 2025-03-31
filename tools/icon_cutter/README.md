# Hypnagogic

## What is this?

This folder will hold a set of cached versions of hypnagogic, our icon cutter. We autodownload the tagged version from github on build.

## How is it used?

The cutter works off 2 inputs. A file, typically a png, and a toml config file in the format `{filename}.{other input extension}.toml`

The input resource is transformed by the cutter following a set of rules set out in the .toml file.
Typically these are very basic. We have a set of templates in repo stored in [cutter_templates/](../../cutter_templates/) and most uses just copy from them.

You can find more information about it in its repository, found [here](https://github.com/actioninja/hypnagogic), the examples subfolder in particular contains fully detailed explanations of all the config values for the different types of cutting (there are more then one)

## How does it work?

Anytime you build the game, CBT will check and see if any of the files that the cutter cares about have been modified
If they have been, the cutter will perform a full runthrough, and compile all inputs down into typically dmis

These dmis can then be committed, and badabing badaboom we have autocut sprites.

If you want to change the cutter version we have a set of  config values in [dependancies.sh](../../dependencies.sh) that control it.
