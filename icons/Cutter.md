## Guide to the icon cutter

### What are cut icons?

There are some icons in ss13 that are essentially stitched together from a smaller set of icon states.

Anything to do with smoothing is a prime example of this. We need icon states for every possible combination of smoothing directions, but it would be impossible to make those manually.

So instead we take a base set of directions, typically no connections, north/south, east/west, north/south/east/west, and all, and then slice them up and stitch them together.

Jobs like this are what the icon cutter is for.

### How does the cutter work?

The cutter has a bunch of different modes. It'll take input for all of them tho.

It will always take a .toml file as input, that file descibes the cutter mode to use, alongside any config settings or the template to pull from (templates are stored in the cutter_templates folder).

The toml file will be named like this. name.input_extension.toml. So if I have a config mode that works with pngs (all of them) it'll look like name.png.toml

It'll then use the name.png file to make name.dmi


## Smoothing stuff

Our cutter has several different modes that do different things with different inputs.

Most cutter stuff in our repo uses the BitmaskSlice mode, you can find info about it [here](https://github.com/actioninja/hypnagogic/blob/master/examples/bitmask-slice.toml)
 
### How do I modify a smoothed icon?

Modify the png, then recompile the game/run build.bat, it will automatically generate the dmi output.

### How do I make a smoothed icon?

Make a png file called {dmi_name}.png. It should be 5 times as wide as the dmi's width, and as tall as the dmi's height

Create a config file called {dmi_name}.png.toml, set its template to one you want to use.

If you want to make something with nonstandard bounds set the relevant config, you can read the examples found [here](https://github.com/actioninja/hypnagogic/tree/master/examples) to understand different mode's configs 

If you want to give a particular smoothing junction a unique icon state use the prefabs var, and add a new state to the png.

If you want to make the smoothed icon animated, add another row of states below your first one. Each new row is a new frame, you define delays inside the config file.

Once you're done, just run build.bat or recompile, and it'll be generated.
