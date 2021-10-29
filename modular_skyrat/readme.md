# The modularization handbook - Skyrat style, v0.1

**Failure to follow this guide will result in your PR being denied.**

## Introduction

To develop and maintain a separate codebase is a big task, that many have failed and suffered the consequences of, such as outdated, and messy code.
It's not necessarily the fault of lack of skill of the people maintaining it, merely the lack of resources and how much continuous effort such an endeavor takes.

One of the solutions for such, is to base our server on a solid codebase, that is primarily maintained by somebody else, in this case tgstation, and insert our content in a modular fashion, while following the general direction of the upstream, mirroring any changes they do for parity.

Git, as a version control system, is very useful, however it is just a very methodical thing, that follows its many algorithms, that sadly cannot always intelligently resolve certain changes in the code in an unambiguous way, giving us conflicts, that need to be resolved in a manual fashion.

Due to maintainability being one of the main reasons behind our rebase to another codebase, **this protocol will seriously be enforced.**
A well organized, documented and atomized code saves our maintainers a lot of headache, when being reviewed.
Don't dump on them the work that you could have done yourself.

This document is meant to be updated and changed, whenever any new exceptions are added onto it. It might be worth it to check, from time to time, whether we didn't define a more unique standardized way of handling some common change.

### The nature of conflicts

For example, let's have an original

```byond
var/something = 1
```

in the core code, that we decide to change from 1 to 2 on our end,

```diff
- var/something = 1
+ var/something = 2 //SKYRAT EDIT
```

but then our upstream introduces a change in their codebase, changing it from 1 to 4

```diff
- var/something = 1
+ var/something = 4
```

As easy of an example as it is, it results in a relatively simple conflict, in the form of

```byond
var/something = 2 //SKYRAT EDIT
```

where we pick the preferable option manually.

### The solution

That is something that cannot and likely shouldn't be resolved automatically, because it might introduce errors and bugs that will be very hard to track down, not to even bring up more complex examples of conflicts, such as ones that involve changes that add, remove and move lines of code all over the place.

tl;dr it tries its best but ultimately is just a dumb program, therefore, we must ourselves do work to ensure that it can do most of the work, while minimizing the effort spent on manual involvement, in the cases where the conflicts will be inevitable.

Our answer to this is modularization of the code.

**Modularization** means, that most of the changes and additions we do, will be kept in a separate **`modular_skyrat/`** folder, as independent from the core code as possible, and those which absolutely cannot be modularized, will need to be properly marked by comments, specifying where the changes start, where they end, and which feature they are a part of, but more on that in the next section.

## The modularization protocol

Always start by thinking of the theme/purpose of your work. It's oftentimes a good idea to see if there isn't an already existing one, that you should append to.
**If it's a tgcode-specific tweak or bugfix, first course of action should be an attempt to discuss and PR it upstream, instead of needlessly modularizing it here.**

Otherwise, pick a new ID for your module. E.g. `DNA-FEATURE-WINGS` or `XENOARCHEAOLOGY` or `SHUTTLE_TOGGLE` - We will use this in future documentation. It is essentially your module ID. It must be uniform throughout the entire module. All references MUST be exactly the same.

And then you'll want to establish your core folder that you'll be working out of which is normally your module ID. E.g. `modular_skyrat/modules/shuttle_toggle`

### Maps

The major station maps have their equivalents in the same folder as the originals, but with their filename having a `_skyrat` suffix.

If you wanted to add some location to the CentCom z-level, a'la whatever off-station location that isn't meant to be reachable or escapable through normal means, we have our own separate z-level, in `_maps/map_files/generic/Offstation_skyrat.dmm`. That z-level, by design, has the same traits as the CentCom z-level, meaning that teleporters and a lot of other things will simply refuse to work there.

If you plan to edit space ruins and so on, currently, it should be discussed with a maintainer and likely should be PRed upstream, to tgstation repository.

### Assets: images, sounds, icons and binaries

Git doesn't handle conflicts of binary files well at all, therefore changes to core binary files are absolutely forbidden, unless you have a really *really* ***really*** good reason to do otherwise.

All assets added by us should be placed into the same modular folder as your code. This means everything is kept inside your module folder, sounds, icons and code files.

- ***Example:*** You're adding a new lavaland mob.
  First of all you create your modular folder. E.g. `modular_skyrat/modules/lavalandmob`

  And then you'd want to create sub-folders for each component. E.g. `/code` for code and `/sounds` for sound files and `/icons` for any icon files.

  After doing this you'd want to change the references within the code.

  ```byond
    /mob/lavaland/newmob
      icon = 'modular_skyrat/modules/lavalandmob/icons/mob.dmi'
      icon_state = "dead_1"
      sound = 'modular_skyrat/modules/lavalandmob/sounds/boom.ogg'
  ```

  This ensures your code is fully modular and will make it easier for future edits.

- Other assets, binaries and tools, should usually be handled likewise, depending on the case-by-case context. When in doubt, ask a maintainer or other contributors for tips and suggestions.

- Any additional clothing icon files you add MUST go into the existing files in master_files clothing section.

### Fully modular portions of your code

This section will be fairly straightforward, however, I will try to go over the basics and give simple examples, as the guide is aimed at new contributors likewise.

The rule of thumb is that if you don't absolutely have to, you shouldn't make any changes to core codebase files.

In short, most of the modular code will be placed in the subfolders of your main module folder **`modular_skyrat/modules/yourmodule/code/`**, with similar rules as with the assets, in terms of correspondence to the main code locations.
In case of new content, however, there's a bit more freedom allowed, and it is heavily encouraged to put thematic feature groups under **`modular_skyrat/modules/yourmodule/code`** in their own separate folder, to ensure they're easy to find, manage and maintain.
For example, `modular_skyrat/modules/xenoarcheaology/code` containing all the code, tools, items and machinery related to it.

Such modules, unless _very_ simple, **need** to have a `readme.dm` in their folder, containing the following:

- links to the PRs that implemented this module or made any significant changes to it
- short description of the module
- list of files changed in the core code, with a short description of the change, and a list of changes in other modular files that are not part of the same module, that were necessary for this module to function properly
- (optionally) a bit more elaborative documentation for future-proofing the code,  that will be useful further development and maintenance
- credits

***Template:***

```md
https://github.com/Skyrat-SS13/Skyrat-tg/pull/<!--PR Number-->

## Title: <!--Title of your addition-->

MODULE ID: <!-- uppercase, underscore_connected name of your module, that you use to mark files-->

### Description:

<!-- Here, try to describe what your PR does, what features it provides and any other directly useful information -->

### TG Proc/File Changes:

- N/A
<!-- If you had to edit, or append to any core procs in the process of making this PR, list them here. APPEND: Also, please include any files that you've changed. .DM files that is. -->

### Defines:

- N/A
<!-- If you needed to add any defines, mention the files you added those defines in -->

### Master file additions

- N/A
<!-- Any master file changes you've made to existing master files or if you've added a new master file. Please mark either as #NEW or #CHANGE -->

### Included files that are not contained in this module:

- N/A
<!-- Likewise, be it a non-modular file or a modular one that's not contained within the folder belonging to this specific module, it should be mentioned here -->

### Credits:

<!-- Here go the credits to you, dear coder, and in case of collaborative work or ports, credits to the original source of the code -->
```

Each such feature/content set should be considered a separate module, and each of its files should be marked with an uppercase comment
**`//SKYRAT MODULE NAME`**, for example **`//SKYRAT MODULE CLONING`**, the name being preferably one word, or in case of multiple, joined with underscores. In case of a file that contains code from multiple modules, portions of it should usually be clamped between
**`//SKYRAT MODULE - CLONING -- BEGIN`** and **`//SKYRAT MODULE - CLONING -- END`** for easy searching of all files related to a specific feature set (why will it come in handy will become more obvious in the next section)

**Important:**
Note, that it is possible to append code in front, or behind a core proc, in a modular fashion, without editing the original proc, through referring the parent proc, using `..()`, in one of the following forms.  And likewise, it is possible to add a new var to an existing datum or obj, without editing the core files.

To keep it simple, let's assume you wanted to make guns spark when shot, for simulating muzzle flash or whatever other reasons, and you want potentially to use it with all kinds of guns.
You could start, in a modular file, by adding a var

```byond
/obj/item/gun
    var/muzzle_flash = TRUE
```

And it will work just fine. Afterwards, let's say you want to check that var and spawn your sparks after firing a shot.
Knowing the original proc being called by shooting is

```byond
/obj/item/gun/proc/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
```

you can define a child proc for it, that will get inserted into the inheritance chain of the related procs (big words, but in simple cases like this, you don't need to worry)

```byond
/obj/item/gun/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
    . = ..() //. is the default return value, we assign what the parent proc returns to it, as we call it before ours
    if(muzzle_flash)
        spawn_sparks(src) //For simplicity, I assume you've already made a proc for this
```

And that wraps the basics of it up.

### Non-modular changes to the core code - IMPORTANT

Every once in a while, there comes a time, where editing the core files becomes inevitable.

Please be sure to log these in the module readme.dm. Any file changes.

In those cases, we've decided to apply the following convention, with examples:

- **Addition:**

  ```byond
  //SKYRAT EDIT ADDITION BEGIN - SHUTTLE_TOGGLE
  var/adminEmergencyNoRecall = FALS
  var/lastMode = SHUTTLE_IDLE
  var/lastCallTime = 6000
  //SKYRAT EDIT ADDITION END
  ```

- **Removal:**

  ```byond
  //SKYRAT EDIT REMOVAL BEGIN - SHUTTLE_TOGGLE
  /*
  for(var/obj/docking_port/stationary/S in stationary)
    if(S.id = id)
      return S
  */
  //SKYRAT EDIT REMOVAL END
  WARNING("couldn't find dock with id: [id]")
  ```

  And for any removals that are moved to different files:

  ```byond
  //SKYRAT EDIT REMOVAL BEGIN - SHUTTLE_TOGGLE - (Moved to modular_skyrat/shuttle_toggle/randomverbs.dm)
  /*
  /client/proc/admin_call_shuttle()
  set category = "Admin - Events"
  set name = "Call Shuttle"

  if(EMERGENCY_AT_LEAST_DOCKED)
    return

  if(!check_rights(R_ADMIN))
    return

  var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
  if(confirm != "Yes")
    return

  SSshuttle.emergency.request()
  SSblackbox.record_feedback("tally", "admin_verb", 1, "Call Shuttle") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
  log_admin("[key_name(usr)] admin-called the emergency shuttle.")
  message_admins("<span class='adminnotice'>[key_name_admin(usr)] admin-called the emergency shuttle.</span>")
  return
  */
  //SKYRAT EDIT REMOVAL END
  ```

- **Change:**

  ```byond
  //SKYRAT EDIT CHANGE BEGIN - SHUTTLE_TOGGLE
  //if(SHUTTLE_STRANDED, SHUTTLE_ESCAPE) - SKYRAT EDIT - ORIGINAL
  if(SHUTTLE_STRANDED, SHUTTLE_ESCAPE, SHUTTLE_DISABLED)
  //SKYRAT EDIT CHANGE END
      return 1
  ```

## Exceptional cases of modular code

From every rule, there's exceptions, due to many circumstances. Don't think about it too much.

### Defines

Due to the way byond loads files, it has become necessary to make a different folder for handling our modular defines.
That folder is **`code/__DEFINES/~skyrat_defines`**, in which you can add them to the existing files, or create those files as necessary.

## Exemplary PR's

Here are a couple PR's that are great examples of the guide being followed, reference them if you are stuck:

- <https://github.com/Skyrat-SS13/Skyrat-tg/pull/241>
- <https://github.com/Skyrat-SS13/Skyrat-tg/pull/111>

## Afterword

It might seem like a lot to take in, but if we remain consistent, it will save us a lot of headache in the long run, once we start having to resolve conflicts manually.
Thanks to a bit more scrupulous documentation, it will be immediately obvious what changes were done and where and by which features, things will be a lot less ambiguous and messy.

Best of luck in your coding. Remember that the community is there for you, if you ever need help.
