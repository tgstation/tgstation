# The modularization handbook - Skyraptor Style, V0.1

## Failure to follow this guide will probably get your PR denied.

## Introduction
Developing & maintaining a codebase touched by a thousand hands as hand #1001 is a nightmarish task.  Doing so when you're also expecting to be working alongside hands #1002, #1003, etc, *and* trying to keep everything from exploding if you ever have to update?  Beyond nightmarish.  To that end, Skyraptor follows the same modularization principles as Skyrat, Daedalus Dock, and many others; base the server on a solid codebase maintained by *other developers* - in this case, tgstation - and either insert or change as much as possible in a strictly modular fashion whilst following the coding principles of our upstream & mirroring changes as needed for parity.

The rationale behind this is simple - Git is a powerful tool, but just like any other program, it has no comprehension of the intent behind changes or conflicts & so the job of resolving them falls to the developers at merge-time.  The less of tgstation's original code we change, the fewer conflicts arise - and the more time we can dedicate to our own features.  To that end, we *modularize* our content and changes by taking advantage of DM's unique format - more on this below.  All-new content can simply be added in a module (e.g, modular_skyraptor/modules/cool_new_hats) without ever touching any original TG code - and where possible, changes can be made by hooking into the original code and overriding it rather than overwriting the actual TG files and creating potential merge conflicts down the line.

This document is meant to be updated and changed, whenever any new exceptions are added onto it. It might be worth it to check, from time to time, whether we didn't define a more unique standardized way of handling some common change.

## Important - TEST YOUR PRS!!
You are responsible for thorough testing of the changes you make.  This means run a local server (see the [guide](.github/guides/RUNNING_A_SERVER.md) here), test all the features or changes you made, and make a *good-faith effort* to test anything that could potentially be impacted.  SS13 is deeply interconnected & even minute changes can end up having dramatic ripple-effects; be vigilant!

## What are merge conflicts, and how do we solve them?
Merge conflicts arise when changes need to be made in code sourced from upstream (tgstation) - as an example, we have a toy object that prints two numbers when used in-hand, incrementing one of them after it's done.

```byond
/obj/item/number_toy
	name = "number toy"
	desc = "It prints funny numbers for the whole world to see!"
	var/something = 6

/obj/item/number_toy/attack_self(mob/user)
	to_chat(world, "THE NUMBER TOY HAS BEEN ACTIVATED.  Its SOMETHING is [something]!")
	var/local_something = 60
	to_chat(world, "THE NUMBER TOY IS DONE ACTIVATING.  Its LOCAL_SOMETHING is [local_something]!")
	something = something + 1
```

If we want to change the value of the numbers printed, we have to change the contents of its variables.  The easy way to do it - and the way you would if you were making this PR upstream - is to simply...change the variables, as below.

```diff
- var/something = 6		//ORIGINAL VALUE
+ var/something = 1336	//OUR EDIT
```

But then, what if upstream decides they'd like to make it into a meme, too?  They change it to 1337.

```diff
- var/something = 6
+ var/something = 1337
```

This presents a conflict for Git when it tries to merge the latest from upstream - which value does it choose?

```diff
- var/something = 6
+ var/something = 1336	//OUR EDIT
+ var/something = 1337	//UPSTREAM VALUE
```

In this case, it's an easy fix - we can just choose the value we wanted by hand.

```byond
var/something = 1336	//SKYRAPTOR EDIT
```

### Basic Modularization: Overrides for Dummies
For changes like this, we can easily *override* the original values from a new file, allowing us to make a pretty wide number of changes without ever having to modfiy the original code - and as such, without ever having to worry about merge conflicts.

Say we wanted to, once again, change the number toy's output value - but this time, in a modular fashion.  In a new file, e.g ``modular_skyraptor/modules/number_toy_rework/newnumbers.dm``, we can make changes and additions to the number_toy item just as if we were writing them in the original file.

```byond
/obj/item/number_toy
	var/something = 1336
```

With just those two lines, the number toy will now always have an initial SOMETHING value of 1336 - no matter if upstream changes it to 7, 1337, 0, 64, or any other number - and all without ever causing merge conflicts, as it's in an entirely different file from upstream.  In much the same fashion, we could also give it a new name & description:

```byond
/obj/item/number_toy
	name = "elite number toy"
	desc = "It starts at the funny number now!"
	var/something = 1336
```

And we can even add whole new variables, too:

```byond
/obj/item/number_toy
	name = "elite number toy"
	desc = "It starts at the funny number now!"
	var/something = 1336
	var/something2 = 1330
```

### Proc Additions: . = ..() for Dummies
BYOND's DM language is object-oriented, much like many modern languages, and features a robust system for extending, altering, and overriding functions - which we can use to our advantage via this little magic snippet:

```byond
. = ..()
```

In a nutshell - this snippet lets you run & continue from the parent function, at any point within your own code.  If you want to modify values before running the parent function, you'd put it after your code - or vice-versa, if you want to continue on after the end of the parent function, all whilst retaining the return value ``.`` of the parent function.  To demonstrate this visually, let's look at the original interaction function of the number toy:

```byond
/obj/item/number_toy/attack_self(mob/user)
	to_chat(world, "THE NUMBER TOY HAS BEEN ACTIVATED.  Its SOMETHING is [something]!")
	var/local_something = 60
	to_chat(world, "THE NUMBER TOY IS DONE ACTIVATING.  Its LOCAL_SOMETHING is [local_something]!")
	something = something + 1
```

Let's say we want to increment its ``something`` a second time, for a total of +2 per use instead of +1.  Where we position the ``. = ..()`` is important to determine the end-result behaviour!  For instance, if we put our code *before* it...

```byond
/obj/item/number_toy/attack_self(mob/user)
	something = something + 1
	. = ..()
```

It's equivalent to the following code:

```byond
/obj/item/number_toy/attack_self(mob/user)
	something = something + 1	//This increments BEFORE printing, meaning the starting value of Something is never seen by the end user!
	//. = ..() expands to the full parent function, here:
	to_chat(world, "THE NUMBER TOY HAS BEEN ACTIVATED.  Its SOMETHING is [something]!")
	var/local_something = 60
	to_chat(world, "THE NUMBER TOY IS DONE ACTIVATING.  Its LOCAL_SOMETHING is [local_something]!")
	something = something + 1
```

So if we want the arguably more "expected" result of a +2 increment *after* printing, we need to run the parent function and *then* increment:

```byond
/obj/item/number_toy/attack_self(mob/user)
	. = ..()
	something = something + 1
```

This expands out to the following code:

```byond
/obj/item/number_toy/attack_self(mob/user)
	//. = ..() expands to the full parent function, here:
	to_chat(world, "THE NUMBER TOY HAS BEEN ACTIVATED.  Its SOMETHING is [something]!")
	var/local_something = 60
	to_chat(world, "THE NUMBER TOY IS DONE ACTIVATING.  Its LOCAL_SOMETHING is [local_something]!")
	something = something + 1
	//beginning of our modular code
	something = something + 1	//This increments AFTER printing, meaning that the expected +2 increment is displayed!
```

We can even use new variables added via modular changes, like Something2 from above:

```byond
/obj/item/number_toy/attack_self(mob/user)
	. = ..()
	something = something + 1
	to_chat(world, "Something2 exists now, too!  Here it is: [something2]!")
```

### Non-Modular Changes, Oh No!
Sometimes changes emerge that are hard, if not downright impossible to properly modularize - in these scenarios, we have to *document thoroughly* and be as sparing as possible with the changes being made.  Continuing with the number toy example - it's always printed the number 60 from the variable local_something.  What if we want to change that?  We could try to use the same technique as the double-increment...

```byond
/obj/item/number_toy/attack_self(mob/user)
	. = ..()
	local_something = 1337
```

But this won't work!  By changing it *after* the function runs & finishes printing, there's no discernible effect!  What if we move it to happen before?

```byond
/obj/item/number_toy/attack_self(mob/user)
	local_something = 1337
	. = ..()
```

This code will fail to compile because ``local_something`` doesn't exist yet!  And if we define it properly...

```byond
/obj/item/number_toy/attack_self(mob/user)
	var/local_something = 1337
	. = ..()
```

This *still* won't work - as even if it compiles correctly, the original code sets ``local_something`` to 60 *after* our code sets it to 1337, meaning it might as well have never run!  In scenarios like this, you'll have to make changes to the *base code*, and so it's important to *label your changes clearly* - otherwise you're creating headaches down the line for when a merge conflict inevitably emerges.  So instead of silently altering the value of local_something, you *label it clearly*, like so:

```byond
/obj/item/number_toy/attack_self(mob/user)
	to_chat(world, "THE NUMBER TOY HAS BEEN ACTIVATED.  Its SOMETHING is [something]!")
	var/local_something = 1337 //SKYRAPTOR EDIT: 1337, up from 60
	to_chat(world, "THE NUMBER TOY IS DONE ACTIVATING.  Its LOCAL_SOMETHING is [local_something]!")
	something = something + 1
```

If your edits need to take up multiple lines, it's best to keep the *original version commented out* with a notice, like so:

```byond
/obj/item/number_toy/attack_self(mob/user)
	to_chat(world, "THE NUMBER TOY HAS BEEN ACTIVATED.  Its SOMETHING is [something]!")
	//SKYRAPTOR CHANGE BEGIN - ORIGINAL
	/*var/local_something = 60
	to_chat(world, "THE NUMBER TOY IS DONE ACTIVATING.  Its LOCAL_SOMETHING is [local_something]!")*/
	//SKYRAPTOR CHANGE BEGIN - NEW CODE
	var/local_something = 1337
	to_chat(world, "WOOO LOCAL_SOMETHING IS: [local_something]!!1!")
	//SKYRAPTOR CHANGE END
	something = something + 1
```

Or if you want to completely remove the use of local_something, comment it out with *removal notices*:

```byond
/obj/item/number_toy/attack_self(mob/user)
	to_chat(world, "THE NUMBER TOY HAS BEEN ACTIVATED.  Its SOMETHING is [something]!")
	//SKYRAPTOR REMOVAL BEGIN
	/*var/local_something = 60
	to_chat(world, "THE NUMBER TOY IS DONE ACTIVATING.  Its LOCAL_SOMETHING is [local_something]!")*/
	//SKYRAPTOR REMOVAL END
	something = something + 1
```

Similarly, anything you want to *add* should be surrounded with *addition notices*:

```byond
/obj/item/number_toy/attack_self(mob/user)
	to_chat(world, "THE NUMBER TOY HAS BEEN ACTIVATED.  Its SOMETHING is [something]!")
	var/local_something = 60
	to_chat(world, "THE NUMBER TOY IS DONE ACTIVATING.  Its LOCAL_SOMETHING is [local_something]!")
	//SKYRAPTOR ADDITION BEGIN
	local_something = local_something + 1
	to_chat(world, "THE NUMBER TOY IS FULLY DONE ACTIVATING.  Its LOCAL_SOMETHING is now [local_something]!")
	//SKYRAPTOR ADDITION END
	something = something + 1
```

Finally, if your reworks are *part of a module*, make sure to *label them as such* by including your Module ID - more on that below.  Similarly, if you're moving code *into* a modular file for easier edits, make sure to *label which file it's being moved to* in your notices!



## Modularization Protocol
Start out by considering the theme & area of your module - make sure there isn't one already made to suit that purpose!  For instance, if you're planning on reworking everyday sprites like *walls*, *airlocks*, or *tools*, consider the AESTHETICS module (`modular_skyraptor/modules/aesthetics`) instead of making a new one!  If you're planning a bugfix to the *underlying tgcode*, please try to **PR it upstream first** so we can mirror it; not only does it make every server that uses TG as a base better, but it means if someone else fixes the bug on TG down the line, we won't have merge conflicts.

If you can't find a module that fits your work, and it's not going to just be a flat-out TG bugfix, pick a new ID for your module, such as `CORPORATE_HAT_REWORK` or `MAGIC_SPAWN_BUTTON` - simple and informative is best!  This ID is meant to be used for documentation & clarity, so it's important that its use be *uniform throughout the entire module* for ease of search.  Once you've got an ID picked, make a core folder to work from, named after your module ID; for instance, `modular_skyraptor/modules/cool_new_hats`, alongside subfolders for `code`, `icons`, `sound`, etc.

### Assets: images, sounds, icons and binaries
Git does ***NOT*** like handling conflicts of binary files, like *images* and *sounds*.  For this reason, absolutely **do not** mess around with tgcode binary stuff unless you have a really, *really*, ***really*** good reason to do so.  If you need new assets, put them into the appropriate subfolder of your module - e.g, `modular_skyraptor/modules/cool_new_hats/icons/homestar_hat.dmi` or `modular_skyraptor/modules/cool_new_hats/sounds/hat_spin.ogg`.  If you still really need to change assets *used in basecode* & can't just include overrides in AESTHETICS or similar, that is the purpose of the `master_files` directory - this is where modified versions of base-TG DMIs and sounds should go, alongside the code files dictating their overrides - info below courtesy of Skyrat's documentation.

#### The `master_files` Folder
You should always put any modular overrides of icons, sound, code, etc. inside this folder, and it **must** follow the core code folder layout.

Example: `code/modules/mob/living/living.dm` -> `modular_skyraptor/master_files/code/modules/mob/living/living.dm`

This is to make it easier to figure out what changed about a base file without having to search through proc definitions. 

It also helps prevent modules needlessly overriding the same proc multiple times. More information on these types of edits come later.

### Fully modular additions
Wherever possible, all modular code you make for your modules should go in **`modular_skyraptor/modules/yourmodule/code/`** and any necessary subfolders for organization.

All modules, unless _very_ simple, **need** to have a `readme.md` in their folder, containing the following:

- links to the PRs that implemented this module or made any significant changes to it
- a short description of the module
- list of files changed in the core code, with a short description of the change, and a list of changes in other modular files that are not part of the same module, that were necessary for this module to function properly
- (optionally) a bit more elaborative documentation for future-proofing the code,  that will be useful further development and maintenance
- credits

***Template:*** [Here](module_template.md)



## Defines
Due to the order in which BYOND loads files, any defines your modules add need to go into a unique subfolder - **`code/__DEFINES/~skyraptor_defines`** - and under a DM file matching the ID of your module (e.g, `code/__DEFINES/~skyraptor_defines/corporate_hat_rework.dm`)

If you have a define that's used in more than one file, **put it in there**, while any defines used only within a single file should be declared at the top of their DM, and **undefined** at the end with `#undef MY_DEFINE` at the bottom to avoid bloat in context menus or IDEs.


## Species Addition Specifics
If you're adding a new species with an associated language, *be sure to give it a bespoke icon file*!  We're doing this to avoid merge conflicts with binaries.  Additionally, if they're intended to be a roundstart species, make sure to include their language in get_possible_languages for the baseline tongue class!  This ensures that people taking languages for quirk points will be able to speak it!  Unless you have a *really good reason* why most critters SHOULDN'T be able to verbalize it, you're hampering QOL and character customization for people playing linguists- and that's no good!

```/obj/item/organ/internal/tongue/get_possible_languages()
	return ..() + /datum/language/your_language_here```



## Afterword
This has been quite the wall of text, to be sure, but it is for the better - the cleaner we can write our code, the easier it is to maintain the server & keep everything moving.  Massive thanks to the contribs who wrote up Skyrat's modularization guide - much of their design philosophy is still present here.