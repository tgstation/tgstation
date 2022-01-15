# Modular Map Loader (MML)

## Concept

## Implementation

## How-To

This section will cover the basics of how to use map modules as a mapper. If you want a concrete example to look at, the space ruin `_maps/RandomRuins/SpaceRuins/DJstation.dmm` and its associated code, configuration and modules employ all the techniques covered in this tutorial.

### The Main Map

First we need to create a map, as we usually would. Let's say we want to create a new space ruin `foobar.dmm`, and we put it in the appropriate folder as usual, `_maps/RandomRuins/SpaceRuins/foobar.dmm`. We now need to create three more things.

* `code/modules/ruins/spaceruin_code/foobar.dm` - A code file like would be used to store any code specific to this map.
* `code/modules/ruins/spaceruin_code/foobar.toml`- A configuration file, this will be looked at in more detail later.
* `_maps/RandomRuins/SpaceRuins/foobar/` - A new subfolder, which is where we will put the `.dmm` files for the modules.

In `code/modules/ruins/spaceruin_code/foobar.dm` we need to add a small piece of code to define a new modular map root type for our map, which should look like this

```
/obj/modular_map_root/foobar
	config_file = "code/modules/ruins/spaceruin_code/foobar.toml"
```

This means when we place root objects `/obj/modular_map_root` in our new map, we use this subtype that points to the correct configuration file.

When creating our main map, we place one of these roots in the location we want to generate a module at. Typically this would be placed at a natural landmark, such as a doorway. We then edit the varaibles of the placed root object, and set the `key` var to some string, let's use `key = vault`. Make the rest of the map, ensuring that every root you want to use a unique set of modules has a unique `key`.

### Module Maps

Now we need to make the modules to be placed on our roots. These will be saved in the folder we created earlier, `_maps/RandomRuins/SpaceRuins/foobar/`. Modules do not have to be the same size, so long as all modules will fit properly on the root without running into other parts of the map.

When making a module, you need to include a connector object `/obj/modular_map_connector`. When the module is loaded, it will be offset so this connector is placed on top of the root on the main map.

We will be making the first variant of our vault module, so we save this as `vault_1.dmm`, following the format `[key]_[number].dmm`. Keep doing this until all your modules have been made.

If you wish, you can also place another root on a module, if for some reason that module's position is dependent on the current one. IF you do this, make sure you've placed a root with the same key on every variant of the current module (unless you only want it to appear on certain varaints of this one.)

### Configuration

Now we go back to our configuration file `code/modules/ruins/spaceruin_code/foobar.toml`. Say we ended up using three different sets of modules in our map, `vault`, `airlock` and `bathroom`, each of which have two variants. We want our `.toml` file to look like this

```
directory = "_maps/RandomRuins/SpaceRuins/foobar/"

[rooms.vault]
modules = ["vault_1.dmm", "vault_2.dmm"]

[rooms.airlock]
modules = ["airlock_1.dmm", "airlock_2.dmm"]

[rooms.bathroom]
modules = ["bathroom_1.dmm", "bathroom_2.dmm"]
```

Let's break down what is happening here.

`directory = "_maps/RandomRuins/SpaceRuins/foobar/"` points to the folder where our modules are stored.

`[rooms.vault]` identifies the following line as being the modules for a root with `key = vault`.

`modules = ["vault_1.dmm", "vault_2.dmm"]` specifies which map files within the folder are to be associated with this key.

Once this configuration is done, the map should be fully functional. Compile and run, place your map somewhere, and continue doing this until you have satisfied yourself that everything looks how you expected it to. Remember to do everything else you need to do when adding any new ruin, or whatever kind of map you made.

### Common Mistakes

> My map has modules that didn't load!

Check your configuration is correct. Do the filenames given for the problem root match the names of the map files? Is the key specified in the configuration file the same as the one on the root in the map?

> A module is loading in the wrong location!

Check the positioning of the connector is correct, and that only one is placed on the module.

> My ruin is spawning too close to or overlapping with something!

Make sure your main map is large enough to fully contain the most expansive variation that can possibly be chosen.

> Parts of my map are overlapping with each other!

Make sure modules placed adjacent or close to each other have no combination of variants which can overlap with each other, this may take some trial and error in complicated cases.
