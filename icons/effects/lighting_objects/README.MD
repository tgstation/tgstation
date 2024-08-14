## Lighting Objects

This is a short aside about lighting objects
See [the main visuals guide](/.github/guides/VISUALS.md#lighting) for more info, I just want to talk about how these work practically.

Ok so each turf is split up into corners, bottom left, bottom right, top left, top right.
Each corner gets its own color, and the intensity of that color determines how much each "corner" impacts each pixel (with all 4 colors summing to 255 on each pixel).

What happens if we want to render tall walls though? we only want to show the sides you can see, and we want lighting to like "form" to the wall right?

Well that's really not that hard. Instead of using the standard icon, we can use one generated for that wall. That's why you'll see 3 different splitvis cutter configs here. One is for black, one is for fullbright and the final is for anything in between.

If you modify them, remember to insert their output into lighting_object.dmi (this is an optimization lighting code is slow can't afford to change icon constantly)

It's a bit hard to tell what's going on just looking straight at it since alpha is a component, and that makes things hard to see.
Opening the png in byond and setting things to not show alpha helps a lot.

The main idea is rather then just a flat square, we shape our gradients to match the shape of the wall, and how light would interact with it.

This was done using a python script to generate the gradients for each "bit". The script is adapted from work done by Mister-Moriarty for goonstation, can find the original [here](https://github.com/goonstation/goonstation/pull/14322) and the version we use [here](./light_gen.py)

