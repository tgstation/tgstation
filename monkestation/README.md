# The Modular Folder

## Introduction

Monkestation is a downstream fork of [tgstation](https://github.com/tgstation/tgstation), meaning that our code is originally based off of them. In addition, from time-to-time, will pull PRs into our codebase from theirs. The difficulty of pulling upstream PRs is made significantly easier with **modularization**.

## Important note - TEST YOUR PULL REQUESTS

You are responsible for the testing of your content. You should not mark a pull request ready for review until you have actually tested it. If you require a separate client for testing, you can use a guest account by logging out of BYOND and connecting to your test server. Test merges are not for bug finding, they are for stress tests where local testing simply doesn't allow for this.

### The nature of conflicts

For example, let's have an original

```byond
var/something = 1
```

in the core code, that we decide to change from 1 to 2 on our end,

```diff
- var/something = 1
+ var/something = 2 //MONKESTATION EDIT
```

but then our upstream introduces a change in their codebase, changing it from 1 to 4

```diff
- var/something = 1
+ var/something = 4
```

As easy of an example as it is, it results in a relatively simple conflict, in the form of

```byond
var/something = 2 //MONKESTATION EDIT
```

where we pick the preferable option manually.

### The Solution

That is something that cannot and likely shouldn't be resolved automatically, because it might introduce errors and bugs that will be very hard to track down, not to even bring up more complex examples of conflicts, such as ones that involve changes that add, remove and move lines of code all over the place.

tl;dr it tries its best but ultimately is just a dumb program, therefore, we must ourselves do work to ensure that it can do most of the work, while minimizing the effort spent on manual involvement, in the cases where the conflicts will be inevitable.

Our answer to this is modularization of the code.

**Modularization** means, that most of the changes and additions we do, will be kept in a separate **`monkestation/`** folder, as independent from the core code as possible, and those which absolutely cannot be modularized, will need to be properly marked by comments. More details will be found in the next section.

## The Modularization Protocol

Always start by thinking of the theme/purpose of your work. It's oftentimes a good idea to see if there isn't an already existing one, that you should append to.

**If it's a tgcode-specific tweak or bugfix, first course of action should be an attempt to discuss and PR it upstream, and then cherry-pick pulling the PR down here.**

The `/monkestation` folder will look fairly similar to tgstation's, following the same file structure. Thus, if you are modularizing something, attempt to mirror the tgcode file structure in the `/monkestation` folder as best as possible.

### Maps

Tgcode map edits can, unfortunately, not be modularized. As such, it is heavily recommended to attempt PRing it to tgstation first if it is a simple fix or QOL change.

### Assets: images, sounds, icons and binaries

Git doesn't handle conflicts of binary files well at all, therefore changes to core binary files are absolutely forbidden, unless you have a really *really* ***really*** good reason to do otherwise.

All assets added should be placed in the `/monkestation` folder.

- ***Example:*** You're adding a new lavaland mob.

  First of all, you want to find a regular lavaland mob's file path, which would be `code/modules/mob/living/simple_animal/hostile/mining_mobs/`.
  
  Next, you want to mirror that in the `/monkestation` folder, making it `/monkestation/code/modules/mob/living/simple_animal/hostile/mining_mobs/your_new_mob_here.dm`

  Then, you add the new mob to that new file in the `/monkestation` folder, like so.

  ```byond
    /mob/lavaland/newmob
      icon = 'monkestation/icons/mob.dmi'
      icon_state = "dead_1"
      sound = 'monkestation/sounds/boom.ogg'
  ```

  This ensures your code is fully modular and will make it easier for future edits.

- Other assets, binaries and tools, should usually be handled likewise, depending on the case-by-case context. When in doubt, ask a maintainer or other contributors for tips and suggestions.

## Modular Overrides (Important!!)

Note, that it is possible to append code in front, or behind a core proc, in a modular fashion, without editing the original proc, through referring the parent proc, using `..()`, in one of the following forms.  And likewise, it is possible to add a new var to an existing datum or obj, without editing the core files.


To keep it simple, let's assume you wanted to make guns spark when shot, for simulating muzzle flash or whatever other reasons, and you want potentially to use it with all kinds of guns.

You could start, in a modular file, by adding a var.

```byond
/obj/item/gun
    var/muzzle_flash = TRUE
```

And it will work just fine. Afterwards, let's say you want to check that var and spawn your sparks after firing a shot.
Knowing the original proc being called by shooting is

```byond
/obj/item/gun/proc/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
```

You can define a child proc for it, that will get inserted into the inheritance chain of the related procs (big words, but in simple cases like this, you don't need to worry)

```byond
/obj/item/gun/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
    . = ..() //. is the default return value, we assign what the parent proc returns to it, as we call it before ours
    if(muzzle_flash)
        spawn_sparks(src) //For simplicity, I assume you've already made a proc for this
```

And that wraps the basics of it up.

### Non-modular Changes to the Core Code - IMPORTANT

Every once in a while, there comes a time, where editing the core files becomes inevitable.

In those cases, this is the following convention, with examples:

- **Addition:**

  ```byond
  //MONKESTATION EDIT START
  var/adminEmergencyNoRecall = FALSE
  var/lastMode = SHUTTLE_IDLE
  var/lastCallTime = 6000
  //MONKESTATION EDIT END
  ```

- **Removal:**

  ```byond
  //MONKESTATION REMOVAL START
  /*
  for(var/obj/docking_port/stationary/S in stationary)
    if(S.id = id)
      return S
  */
  //MONKESTATION REMOVAL END
  WARNING("couldn't find dock with id: [id]")
  ```


- **Change:**

  ```byond
  //MONKESTATION EDIT START
  //if(SHUTTLE_STRANDED, SHUTTLE_ESCAPE) - MONKESTATION EDIT ORIGINAL
  if(SHUTTLE_STRANDED, SHUTTLE_ESCAPE, SHUTTLE_DISABLED)
  //MONKESTATION EDIT END
      return 1
  ```

## Afterword

It might seem like a lot to take in, but if we remain consistent, it will save a lot of maintainer headache in the long run, once we start having to resolve conflicts manually.
Thanks to a bit more scrupulous documentation, it will be immediately obvious what changes were done and where and by which features, and things will be a lot less ambiguous and messy.

Best of luck in your coding. Remember that the community is there for you, if you ever need help.
