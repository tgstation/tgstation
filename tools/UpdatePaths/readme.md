# UpdatePaths

## How To Use:

Drag one of the scripts in the “Scripts” folder onto the .bat file “Update Paths” to open it with the `.bat` file (or use the Python script directly depending on your operating system). Let the script run to completion.

Use this tool before using MapMerge2 or opening the map in an map editor. This is because the map editor may discard any unknown paths not found in the /tg/station environment (or what it builds after parsing `tgstation.dme`).

## Scriptmaking:

This tool updates paths in the game to new paths. For instance:

If you have a path labeled `/obj/structure/door/airlock/science/closed/rd` and wanted it to be `/obj/structure/door/airlock/science/rd/closed`, this tool would update it for you! This is extremely helpful if you want to be nice to people who have to resolve merge conflicts from the PRs that you make updating these areas.

---

### How do I do it?

Simply create a `.TXT` file and type this on a line:

#### Tried and True - Part One

```txt
/obj/structure/door/airlock/science/closed/rd : /obj/structure/door/airlock/science/rd/closed{@OLD}
```

The path on the left is the old, the path on the right is the new. It is seperated by a ":"
If you want to make multiple path changes in one script, simply add more changes on new lines.

Putting `{@OLD}` is important since otherwise, UpdatePaths will automatically discard the old variables attached to the old path. Adding `{@OLD}` to the right-hand side will ensure that every single variable from the old path will be applied to the new path.

You'll want to save your `.TXT` file with a name that is descriptive of what it does, as well as the associated PR Number to your PR. So, it would look like `PRNUMBER_RD_AIRLOCK_REPATH.txt`. Both of these are for book-keeping purposes, so that intent is clear to anyone who looks at the file. They can also easily reference the PR number that the script was made in to determine _why_ it was made, and if it is still needed.

---

### What does it look like?

Alright, so we've already made the [script](#tried-and-true---part-one). So, let's say we have this example map key in the [TGM Format](https://hackmd.io/@tgstation/ry4-gbKH5#TGM-Format).

#### Tried and True - Part Two

```dm
"a" = (
/obj/structure/door/airlock/science/closed/rd{
	dir = 4;
	name = "RD Airlock"
	},
/turf/open/floor/iron,
/area/science/rd),
```

Now, after you drag and drop your script onto the `Update Paths.bat` file, it will look like this:

```dm
"a" = (
/obj/structure/door/airlock/science/rd/closed{
	dir = 4;
	name = "RD Airlock"
	},
/turf/open/floor/iron,
/area/science/rd),
```

It worked! Great!

---

### On Variable Editing

If you do not want any variable edits to carry over, you can simply skip adding the `{@OLD}` tag. This will make the script change the path, and discard all variables associated to the old path. So, continuing with the same example mentioned above, lets run the following script:

### Discarding Old Variables

```txt
/obj/structure/door/airlock/science/closed/rd : /obj/structure/door/airlock/science/rd/closed
```
On this example map key:

```dm
"a" = (
/obj/structure/door/airlock/science/rd/closed{
	dir = 4;
	name = "RD Airlock"
	},
/turf/open/floor/iron,
/area/science/rd),
```
You will then result the following:


```dm
"a" = (
/obj/structure/door/airlock/science/closed/rd,
/turf/open/floor/iron,
/area/science/rd),
```

As expected, all variables were discarded. This is only really useful in certain edgecases, and you shouldn't do something like this trivially in case someone has lovably named a variable special since it'll just nuke it.

There are also a bunch of neat features you can use with UpdatePaths variable filtering, with it all documented here: [https://github.com/tgstation/tgstation/blob/master/tools/UpdatePaths/\_\_main\_\_.py#L9](https://github.com/tgstation/tgstation/blob/master/tools/UpdatePaths/__main__.py#L9). However, let's spin it all out for you here as well:

### Deleting Entire Paths

Alright, you did a large refactor and you got rid of some shoddy paths. Great! So, let's make a script to delete that old path from all of our map files. Let's say we want to delete `/mob/living/deez_nuts`. We can do that by simply adding the following to our script:

```txt
/mob/living/deez_nuts : @DELETE
```

So, now when you have the following example map keys:

```dm
"a" = (
/turf/open/floor/carpet,
/area/meme_zone),
"b" = (
/mob/living/deez_nuts{
	goteem = 1;
	desc = "these jokes are still funny"
	},
/turf/open/floor/carpet,
/area/meme_zone),
```

And you run the script, you will get the following:

```dm
"a" = (
/turf/open/floor/carpet,
/area/meme_zone),
```

Presto, like it never existed. Note how both the "a" and "b" files were able to combine into the same dictionary key, since the "b" key was deleted entirely, and since "a" and 'b" now matched, UpdatePaths was able to just clean that up for you. It'll also update the map itself to reflect this as well. Now that is something your Search & Replace tool can't do!

### Multiple Path Output

UpdatePaths has the powerful ability to output multiple paths from a single input path. Let's say that you have a snowflake turf (`/turf/open/floor/iron/i_like_spawning_mobs`) with some behavior that you atomize out into some spawner `/obj/mob_spawner` that can work on every single turf. So, let's script that out. 

```txt
/turf/open/floor/iron/i_like_spawning_mobs : /obj/mob_spawner, /turf/open/floor/iron
```
So, now when you have the following example map keys:

```dm
"a" = (
/turf/open/floor/iron/i_like_spawning_mobs,
/area/station/kitchen),
```

Running the script will mutate this into:

```dm
"a" = (
/obj/mob_spawner,
/turf/open/floor/iron,
/area/station/kitchen),
```
Remember that this is a kind of silly example, but this is one of the things that UpdatePaths was built to do- help coders fix shitty code without having to bug out over how maps don't compile.

### Subtype Handling

This is one of UpdatePaths' more recent features. It allows you to specify a generic base path that you've done a major refactor on, and then easily specify the gamut of subtypes you want to swap it to. Let's say you have a `/obj/item/weapon/big_chungus` base path that you want to refactor to `/obj/item/big_chungus`. However, you also have subtypes like `/obj/item/weapon/big_chungus/funny`, `/obj/item/weapon/big_chungus/really_large`, etc. You can do that by simply adding the following to your script:

```txt
/obj/item/weapon/big_chungus/@SUBTYPES : /obj/item/big_chungus/@SUBTYPES{@OLD}
```

So, let's assume we have the following map file:

```dm
"a" = (
/obj/item/weapon/big_chungus,
/obj/item/weapon/big_chungus/funny{
	name = "funny big chungus"
	},
/obj/item/weapon/big_chungus/really_large{
	name = "really large big chungus"
	},
/turf/open/floor/iron,
/area/station/maintainence/fore/greater),
```

Running the script will update this into:

```dm
"a" = (
/obj/item/big_chungus,
/obj/item/big_chungus/funny{
	name = "funny big chungus"
	},
/obj/item/big_chungus/really_large{
	name = "really large big chungus"
	},
/turf/open/floor/iron,
/area/station/maintainence/fore/greater),
```

Note how since you kept in `{@OLD}`, it was able to retain the re-named variables of the subtypes.


### Old Path Variable Filtering

Alright, there's a few subsections here. This is how you are able to filter out old paths to ensure you target something precise. Let's just go through them one by one.

#### Property Filtration (feat. `@SKIP`)

##### Method: Open Mind To All Possibilities

Alright, you saw something cool in a map that you wanted to expand upon codeside. So, you make the new path `/mob/living/basic/mouse/tom` with all sorts of nice behavior. However, you don't want to just replace all of the old `/mob/living/basic/mouse` paths with the new one, you want to only replace the ones that have a `name` variable of "Tom". You can do that by simply adding the following to your script:

```txt
/mob/living/basic/mouse{name="Tom"} : /mob/living/basic/mouse/tom{@OLD;name=@SKIP}
```

In this test example, you already set the name of the Mob to "Tom", so you don't need to worry about that, so first you'll insert `@OLD`, because you want to retain all the other variables, and then add `@SKIP` in order to skip adding that variable to the new path. Its important that '@OLD' goes before '@SKIP', otherwise the script won't see the variables to skip and will just keep all of them anyway. So, let's assume we have the following map file:

```dm
"a" = (
/mob/living/basic/mouse{
	name = "Tom";
	desc = "A mouse named Tom";
	pixel_x = 12
	},
/mob/living/basic/mouse{
	name = "Tina";
	pixel_x = -12
	},
/turf/open/floor/iron,
/area/station/prison),
```

Running the script will update this into:

```dm
"a" = (
/mob/living/basic/mouse/tom{
	desc = "A mouse named Tom";
	pixel_x = 12
	},
/mob/living/basic/mouse{
	name = "Tina";
	pixel_x = -12
	},
/turf/open/floor/iron,
/area/station/prison),
```

Notice how since you `@SKIP`'d the name, it doesn't need to re-apply itself, and since you added (the global) `@OLD`, it was able to keep the `desc` and `pixel_x` variable. Also, cute little mouse named Tina goes unfazed through this change.

---

##### Method: I Don't Care About Soulful Var-Edits

That's cool, but let's say you have this same example, but let's say that you don't want to carry over the `desc` variable either (because you did that code-side). In fact, you don't want to carry over any variables beyond the `pixel_x`. You can choose to only copy over one variable with the following script entry:

```txt
/mob/living/basic/mouse{name="Tom"} : /mob/living/basic/mouse/tom{pixel_x = @OLD}
```
The following is also supported, but it's not recommended since it's harder to read because it doesn't really mesh with the TGM format:

```txt
/mob/living/basic/mouse{name="Tom"} : /mob/living/basic/mouse/tom{@OLD:pixel_x}
```

So, let's assume we have the following map file:

```dm
"a" = (
/mob/living/basic/mouse{
	name = "Tom";
	desc = "A mouse named Tom";
	pixel_x = -12
	},
/mob/living/basic/mouse{
	name = "Tina";
	pixel_x = 12
	},
/turf/open/floor/iron,
/area/station/prison),
```

You would then get the following output:

```dm
"a" = (
/mob/living/basic/mouse/tom{
	pixel_x = -12
	},
/mob/living/basic/mouse{
	name = "Tina";
	pixel_x = 12
	},
/turf/open/floor/iron,
/area/station/prison),
```

As you would have wished, only the `pixel_x` variable copied through. This is pretty constraining and might not match up to certain needs of the repository (or other repositories), so recommend using the [first example](#method-open-mind-to-all-possibilities) when possible.

#### Method: Keep All The Soul!

Okay, let's say that you want to change all instances of `/obj/structure/sink` that have `dir=2` to `dir=1` for a laugh. However, there's an issue. You see, 2 is SOUTH in DM directions, (1 is NORTH), and code-side, `/obj/structure/sink` has `dir = 2` by default and doesn't show up in the map editor. You would have to do something like this:

```txt
/obj/structure/sink{@UNSET} : /obj/structure/sink{dir=1}
```

`@UNSET` will only apply to the change to paths that do not have any variable edits. So, let's assume we have the following map file:

```dm
"a" = (
/obj/structure/sink,
/turf/open/floor/iron,
/area/station/bathroom),
"b" = (
/obj/structure/sink{
	dir = 8
	name = "Money Hole"
	},
/turf/open/floor/iron,
/area/station/bathroom),
```

You would then get the following output:

```dm
"a" = (
/obj/structure/sink{
	dir = 1
	},
/turf/open/floor/iron,
/area/station/bathroom),
"b" = (
/obj/structure/sink{
	dir = 8
	name = "Money Hole"
	},
/turf/open/floor/iron,
/area/station/bathroom),
```

Note how we keep the "Money Hole" intact, while still managing to extrapolate the `dir` variable to 1 on the sink that had absolutely no variables set on it. This is useful for when you want to change a variable that is not shown in the map editor, but you want to keep the rest of the variables intact.

### Blend it all together

All of the examples provided within are not mutually exclusive! They can be mixed-and-matched in several ways (old scripts might have a few good examples of these), and the only limit here is your imagination. You can do some very powerful things with UpdatePaths, with your scripts lasting for years to come.

## Why should I care?

UpdatePaths is an incredible valuable tool to the following populations:
- Mappers who have mapping PRs that take a long time to create, and that will need to be updated as progression goes on. Having an UpdatePaths file makes it much more simple to get them to compile their map properly, and not lose paths.
- Downstreams who have additional maps to the ones we have. You obviously can't Search & Replace fix for a whole downstream, but you can give them the ammunition (UpdatePaths script) for them to quickly and easily resolve that problem.
- You! As you've seen, you can do a lot of clever and powerful tools that respect the TGM format, from Old Path Filtering to Multiple Path Output- and you can do it all with a simple text file! Otherwise, you would be stuck in absolute RegEx hell, and still end up missing on several potential edge cases. UpdatePaths is built on the same framework that builds the TGM format, so it's incredibly reliable in finding and replacing paths.
