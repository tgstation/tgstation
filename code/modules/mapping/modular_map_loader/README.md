# Modular Map Loader

## Concept

Modular map loading is a system to allow maps to be generated with random variants by selecting from a set of pre-made modules. The system is designed to be as simple as possible for mappers to use, with a minimum of interaction with the code required.

## Implementation

### /obj/modular_map_root

This root object handled picking and loading in map modules. It has two variables, and one proc.

- `var/config_file` - A string, points to a TOML configuration file, which is used to hold the information necessary to pull the correct map files and place them on the correct roots. This will be the same for all roots on a map.
- `var/key` - A string, used to pull a list of `.dmm` files from the configuration file.
- `load_map()` - Called asynchronously in the root's `Initialize()`. This proc creates a new instance of `/datum/map_template/map_module`, ingests the configuration file `config_file` points to, and picks a `.dmm` file path which maps to the root's `key`, by picking a random filename from among those which `key` maps to, and appending it to a folder path. This file path is passed into the map templace instance's `load()`, and the template takes over.

INITIALIZE_IMMEDIATE is used to ensure the ruins are loaded at the right time to avoid runtime errors related to lighting.

### /datum/map_template/map_module

This map templace subtype is responsible for loading in the module, it has two variables and two relevant procs.

- `var/x_offset` and `var/y_offset` - Integers, used to store the offsets used to correctly align the module when it is loaded.
- `load()` - Extends the functionality of the general map template's `load()` to allow a map to be specified at runtime. This means `preload_size()` must be called again here as the template's map file has been changed. The origin turf for the map to be loaded from is set using the offsets, and the map is loaded as per the parent.
- `preload_size()` - Extends the functionality of the general map template's `preload_size()` to run the `discover_offset` proc, calculating the offset of `/obj/modular_map_connector` and setting the offset variables accordingly.

### /obj/modular_map_connector

This object is used only to determine the offsets to be used on loading, and has no other functionality.

### TOML configuration

This TOML file is used to map between a list of `.dmm` files and a string key. The file consists of two parts. The first is a line

```
directory = "_maps/etc/"
```

which points at a folder containing the `.dmm` files of the modules used in the map. The second is a series of tables

```
[rooms.example]
modules = ["example_1.dmm", "example_2.dmm"]
```

which contains the mapping between the key `"example"` and the list of filenames `["example_1.dmm", "example_2.dmm"]`.

### /datum/unit_test/modular_map_loader

This is the unit test for modular map loading. It performs two checks on every subtype of `/obj/modular_map_root`. First it checks if the file `config_file` points at, and if it does not the test is failed because the file does not exist. If it does exist, it then attempts to read the file, if this is null it means the fild is not valid TOML, and the test is failed because the TOML file is invalid.

## How-To

This section will cover the basics of how to use map modules as a mapper. If you want a concrete example to look at, the space ruin `_maps/RandomRuins/SpaceRuins/DJstation.dmm` and its associated code, configuration and modules employ all the techniques covered in this tutorial.

### The Main Map

First we need to create a map, as we usually would. Let's say we want to create a new space ruin `foobar.dmm`, and we put it in the appropriate folder as usual, `_maps/RandomRuins/SpaceRuins/foobar.dmm`. We now need to create three more things.

- `code/modules/ruins/spaceruin_code/foobar.dm` - A code file like would be used to store any code specific to this map.
- `strings/modular_maps/foobar.toml`- A configuration file, this will be looked at in more detail later.
- `_maps/RandomRuins/SpaceRuins/foobar/` - A new subfolder, which is where we will put the `.dmm` files for the modules.

In `code/modules/ruins/spaceruin_code/foobar.dm` we need to add a small piece of code to define a new modular map root type for our map, which should look like this

```
/obj/modular_map_root/foobar
	config_file = "strings/modular_maps/foobar.toml"
```

This means when we place root objects `/obj/modular_map_root` in our new map, we use this subtype that points to the correct configuration file.

When creating our main map, we place one of these roots in the location we want to generate a module at. Typically this would be placed at a natural landmark, such as a doorway. We then edit the varaibles of the placed root object, and set the `key` var to some string, let's use `key = vault`. Make the rest of the map, ensuring that every root you want to use a unique set of modules has a unique `key`.

### Module Maps

Now we need to make the modules to be placed on our roots. These will be saved in the folder we created earlier, `_maps/RandomRuins/SpaceRuins/foobar/`. Modules do not have to be the same size, so long as all modules will fit properly on the root without running into other parts of the map.

When making a module, you need to include a connector object `/obj/modular_map_connector`. When the module is loaded, it will be offset so this connector is placed on top of the root on the main map.

We will be making the first variant of our vault module, so we save this as `vault_1.dmm`, following the format `[key]_[number].dmm`. Keep doing this until all your modules have been made.

If you wish, you can also place another root on a module, if for some reason that module's position is dependent on the current one. IF you do this, make sure you've placed a root with the same key on every variant of the current module (unless you only want it to appear on certain varaints of this one.)

### Configuration

Now we go back to our configuration file `strings/modular_maps/foobar.toml`. Say we ended up using three different sets of modules in our map, `vault`, `airlock` and `bathroom`, each of which have two variants. We want our `.toml` file to look like this

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

> My map still isn't working and I don't know what's wrong!

Ping Thunder12345#9999 in the #coding-general channel of our discord if you need help with any problems.
