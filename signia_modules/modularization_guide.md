# Modularization handbook: Wallstation edition
<Written by vect0r and heavily inspired by novasector and sections shamelessly stolen from it>

## Not following this guide *will* result in your Pull Request being closed
## What are "core files"?
Very simply, core files are the code that we have from /tg/ and is not our own code.
## Why we do this
Having a separate codebase is a lot of work. It's very easy to fall behind with outdated code. A way to solve this issue is by getting updates from a codebase that is more active. In this case, we choose /tg/station.
In isolation, updating from /tg/ is simple process, but adding new & unique features to Wallstation, if done improperly, will exponentially increase the amount of work it takes to mirror PRs from tgstation.

## How does a conflict happen?
Here is a relatively simple merge conflict that can happen if we are not careful.
```
/obj/item/melee/weapon
	force = 30
```
We decide to change the force of this object in the core code
```
/obj/item/melee/weapon
  //START OF SIGNIA EDIT
	force = 50
  //END OF SIGNIA EDIT
```
This works well until the upstream repository changes the same lines
```
/obj/item/melee/weapon
	force = 10
```
Then we will get a merge conflict, where we have to decide which of the two edits we want to use. Merge conflicts occur when competing changes are made to the same line of a file, or when one person edits a file and another person deletes the same file. For more information, see "[About merge conflicts](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/addressing-merge-conflicts/about-merge-conflicts).

## How we solve it
This is something we do not want to do manually, and something that we do not trust an automated system to do well. But thankfully, there is a simple solution, modularization.

How does it work? All that means is that the vast majority of our changes are in the ``signia_modules`` folder, which is exclusive to our repository and can't conflict with upstream changes as it does not exist upstream. Any changes that cannot be put into this folder must be **CLEARLY LABELED** where they start and where they end.

## How modularization works
Think about what you want you want to do with your PR, and then pick an ID for your module. E.g. `DISABLER_SNIPER` or `XENOARCHEAOLOGY` - We will use this in future documentation. It is essentially your module ID. It must be uniform throughout the entire module. All references MUST be exactly the same. This is to allow for easy searching.

Then establish your core folder from where you'll be applying your changes, which is normally your module ID. E.g. `signia_modular/modules/disabler_sniper`

## Assets: images, sounds, icons and binaries

Git doesn't handle conflicts of binary files (sounds, images, icons etc) well at all, therefore changes to core binary files are absolutely forbidden, unless you have a really *really* ***really*** good reason to do otherwise.

All assets added by your changes should be placed into the same modular folder as your code. This means everything is kept inside your module folder, sounds, icons and code files.

- ***Example:*** You're adding a new lavaland mob.

  First, create your module folder. E.g. `signia_modules/modules/lavalandmob`

Next,  create sub-folders for each component. E.g. `/code` for code,  `/sounds` for sound files and `/icons` for any icon files.

  After doing this, set your references within the code.

  ```
    /mob/lavaland/newmob
      icon = 'signia_modules/modules/lavalandmob/icons/mob.dmi'
      icon_state = "dead_1"
      sound = 'signia_modules/modules/lavalandmob/sounds/boom.ogg'
  ```

  This ensures your code is fully modular and will make it easier to ammend and review.

- Other assets, binaries and tools, should usually be handled likewise, depending on the case-by-case context. When in doubt, ask a maintainer or other contributors for tips and suggestions.

### The `master_files` Folder

Always put any modular overrides of icons, sound, code, etc. inside this folder, it **must** follow the core code folder layout.

Example: `code/modules/mob/living/living.dm` -> `signia_modules/master_files/code/modules/mob/living/living.dm`

This will make it easier to figure out what changed about a base file without having to search through proc definitions.

It also helps prevent modules needlessly overriding the same proc multiple times. More information on these types of edits come later.

### Fully modular portions of your code

This section will be fairly straightforward, however, we will try to go over the basics and give simple examples, as the guide is aimed at new contributors likewise.

The most important thing to remember is unless it is absolutely vital **do not touch core codebase files**.

In short, most of the modular code will be placed in the subfolders of your main module folder **`signia_modules/modules/yourmodule/code/`**, with similar rules as with the assets. Do not mirror core code folder structures inside your modular folder.

For example, `signia_modules/modules/xenoarcheaology/code` containing all the code, tools, items and machinery related to it.

Such modules **need** to have a `readme.md` in their folder, containing the following:

- links to the PRs that implemented this module or made any significant changes to it
- short description of the module
- list of files changed in the core code, with a short description of the change, and a list of changes in other modular files that are not part of the same module, that were necessary for this module to function properly
- (optionally) a bit more elaborative documentation for future-proofing the code,  that will be useful further development and maintenance
- credits


## Modular Overrides

Note, that it is possible to append code in front, or behind a core proc, in a modular fashion, without editing the original proc, through referring to the parent proc, using `. = ..()` or `..()`. And likewise, it is possible to add a new var to an existing atom, without editing the core files.

**Note about proc overrides: Just because you can, doesn't mean you should!!**

In general they are a good idea and encouraged whenever it is possible to do so. However this is not a hard rule, and sometimes Wallstation edits are preferable. Just try to use your common sense about it.

For example: do not copy paste an entire TG proc into a modular override, make one small change, and then bill it as 'fully modular'. These procs are an absolute nightmare to maintain because once something changes upstream you have to update the overridden proc.

Sometimes you aren't even aware the override exists if it compiles fine and doesn't cause any bugs. This often causes features that were added upstream to be missing here. So yeah. Avoid that. It's okay if something isn't fully modular. Sometimes it's the better choice.

The best candidates for modular proc overrides are ones where you can just tack something on after calling the parent, or weave a parent call cleverly in the middle somewhere to achieve your desired effect.

Performance should also be considered when you are overriding a hot proc (like Life() for example), as each additional call adds overhead. signia edits are much more performant in those cases. For most procs this won't be something you have to think about, though.

### These modular overrides should be kept in `master_files`, and you should avoid putting them inside modules as much as possible.

To keep it simple, let's assume you wanted to make guns spark when shot, for simulating muzzle flash or whatever other reasons, and you potentially want to use it with all kinds of guns.

You could start, in a modular file, by adding a var.

```
/obj/item/gun
    var/muzzle_flash = TRUE
```

And it will work just fine. Afterwards, let's say you want to check that var and spawn your sparks after firing a shot.
Knowing the original proc being called by shooting is

```
/obj/item/gun/proc/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
```

you can define a child proc for it, that will get inserted into the inheritance chain of the related procs (big words, but in simple cases like this, you don't need to worry)

```
/obj/item/gun/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
    . = ..() //. is the default return value, we assign what the parent proc returns to it, as we call it before ours
    if(muzzle_flash)
        spawn_sparks(src) //For simplicity, I assume you've already made a proc for this
```

### Non-modular changes to the core code - IMPORTANT

Every once in a while, there comes a time, where editing the core files becomes inevitable.

Please be sure to log these in the module readme.md. **Any** file changes.

In those cases, we've decided to apply the following convention, with examples:

- **Addition:**

  ```
  //SIGNIA EDIT BEGIN - SHUTTLE_TOGGLE - (Optional Reason/comment)
  var/adminEmergencyNoRecall = FALSE
  var/lastMode = SHUTTLE_IDLE
  var/lastCallTime = 6000
  //SIGNIA EDIT END
  ```

- **Removal:**

  ```byond
  //SIGNIA EDIT BEGIN - SHUTTLE_TOGGLE - (Optional Reason/comment)
  /*
  for(var/obj/docking_port/stationary/S in stationary)
    if(S.id = id)
      return S
  */
  //SIGNIA EDIT END
    ```

  And for any removals that are moved to different files:

  ```
  //SIGNIA EDIT BEGIN - SHUTTLE_TOGGLE - (Moved to signia_modular/shuttle_toggle/randomverbs.dm)
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
  message_admins(span_adminnotice("[key_name_admin(usr)] admin-called the emergency shuttle."))
  return
  */
  //SIGNIA EDIT END
  ```

- **Change:**

  ```byond
  //SIGNIA EDIT BEGIN - SHUTTLE_TOGGLE - (Optional Reason/comment)
  //if(SHUTTLE_STRANDED, SHUTTLE_ESCAPE) - SIGNIA EDIT - ORIGINAL
  if(SHUTTLE_STRANDED, SHUTTLE_ESCAPE, SHUTTLE_DISABLED)
  //SIGNIA EDIT END
      return 1
  ```


### Defines

Due to the way byond loads files, it is necessary to make a different folder for handling our modular defines.
That folder is **`code/__DEFINES/~signia_defines`**, in which you can add them to the existing files, or create those files as necessary.

If you have a define that's used in more than one file, it **must** be declared here.

If you have a define that's used in one file, and won't be used anywhere else, declare it at the top, and `#undef MY_DEFINE` at the bottom of the file. This is to keep context menus clean, and to prevent confusion by those using IDEs with autocomplete.

### Module folder layout

To keep ensure most modules are easy to navigate and to keep control of the amount of files and folders being made in the repository, you are required to follow this layout.

Ensure the folder names are exactly as stated.

Top most folder: module_id

**DO NOT COPY THE CORE CODE FILE STRUCTURE IN YOUR MODULE!!**

**Code**: Any .DM files must go in here.

- Good: /signia_modular/modules/example_module/code/badguy.dm
- Bad: /signia_modular/modules/example_module/code/modules/antagonists/traitors/badguy.dm

**Icons**: Any .DMI files must go in here.

- Good: /signia_modular/modules/example_module/icons/mining_righthand.dmi
- Bad: /signia_modular/modules/example_module/icons/mob/inhands/equipment/mining_righthand.dmi

**Sound**: Any SOUND files must go in here.

- Good: See above.
- Bad: See above.

The readme should go into the parent folder, module_id.

**DO NOT MIX AND MATCH FILE TYPES IN FOLDERS! THE CODE FOLDER IS FOR CODE, SAME WITH SOUND AND ICONS**

## Modular TGUI

TGUI is another exceptional case, since it uses javascript and isn't able to be modular in the same way that DM code is.
ALL of the tgui files are located in `/tgui/packages/tgui/interfaces` and its subdirectories; there is no specific folder for Wallstation Sector UIs.
### Modifying upstream files

When modifying upstream TGUI files the same rules apply as modifying upstream DM code, however the grammar for comments may be slightly different.

You can do both `// SIGNIA EDIT` and `/* SIGNIA EDIT */`, though in some cases you may have to use one over the other.

In general try to keep your edit comments on the same line as the change. Preferably inside the JSX tag. e.g:

```js
<Button
	onClick={() => act('spin', { high_quality: true })}
	icon="rat" // SIGNIA EDIT ADDITION
</Button>
```

```js
<Button
	onClick={() => act('spin', { high_quality: true })}
	// SIGNIA EDIT ADDITION START - another example, multiline changes
	icon="rat"
	tooltip="spin the rat."
	// SIGNIA EDIT ADDITION END
</Button>
```

```js
<SomeThing someProp="whatever" /* it also works in self-closing tags */ />
```

If that is not possible, you can wrap your edit in curly brackets e.g.

```js
{/* SIGNIA EDIT ADDITION START */}
<SomeThing>
	someProp="whatever"
</SomeThing>
{/* SIGNIA EDIT ADDITION END */}
```

### Creating new TGUI files

**IMPORTANT! When creating a new TGUI file from scratch, please add the following at the very top of the file (line 1):**
```js
// THIS IS A SIGNIA UI FILE
```

This way they are easily identifiable as modular TGUI .tsx/.jsx files. You do not have to do anything further, and there will never be any need for a Wallstation edit comment in a modular TGUI file.

## Afterword

It might seem like a lot to take in, but if we remain consistent, it will save us a lot of headache in the long run, once we start having to resolve conflicts manually.
Thanks to a bit more scrupulous documentation, it will be immediately obvious what changes were done, where and by which commit, things will be a lot less ambiguous and messy.

Best of luck in your coding. Remember that the community is there for you, if you ever need help.
### And a shoutout to Novasector who has the file I have based this one on
