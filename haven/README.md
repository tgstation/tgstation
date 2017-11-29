###### Special thanks to [HippieStation](https://github.com/HippieStation/HippieStation/blob/master/hippiestation/README.md) for the help.

# Introduction to the "haven" Folder

## Why do we use it?

Trying to keep up to date with /TG/Station as an upstream while also creating unique modifications to the code results in a mess of merge conflicts that can be impossible to keep up with. By keeping our unique code in this folder, conflicts can be avoided as nothing will overwrite the files that the upstream may modify.

## What does it mean to modularize something?

Something is modular when it exists independent from the rest of the code. This means that by simply adding something modular to the DME file, it will exist in-game. It is not always possible to completely modularize something, but if standards are followed correctly, then there should be few to none conflicts with /tg/station in the future.

## Please mark your changes

All modifications to non-haven files should be marked.

- Multi line changes start with `// HAVEN start` and end with `// HAVEN end`
- You can put a messages with a change if it isn't obvious, like this: `// HAVEN start - reason`
  - Should generally be about the reason the change was made, what it was before, or what the change is
  - Multi-line messages should start with `// HAVEN start` and use `/* Multi line message here */` for the message itself
- Single line changes should have `// HAVEN` or `// HAVEN - reason`

If you need to mirror a file, or function into a haven-specific file, please leave behind a comment stating where it went.

```
// HAVEN start - Mirrored this function in <file> for <reason>
bunch of shitcode here
// HAVEN stop
```

Once you mirror a file, please follow the above for marking your changes, this way we know what needs to be updated when a file has been mirrored.


### tgstation.dme versus outerhaven.dme

Do not alter the tgstation.dme file. All additions and removals should be to the outerhaven.dme file. Do not manually add files to the dme! Check the file's box in the Dream Maker program. The Dream Maker does not always use alphabetical order, and manually adding a file can cause it to reorder. This means that down the line, many PRs will contain this reorder when it could have been avoided in the first place.

### Icons, code, and sounds

Icons are notorious for conflicts. Because of this, **ALL NEW ICONS** must go in the "haven/icons" folder. There are to be no exceptions to this rule. Sounds rarely cause conflicts, but for the sake of organization they are to go in the "haven/sounds" folder. No exceptions, either. Unless absolutely necessary, code should go in the "haven/code" folder. Small changes outside of the folder should be done with hook-procs. Larger changes should simply mirror the file in the "haven/code" folder.

### Defines

Defines only work if they come before the code in which they are used. Because of this, please put all defines in the `code/__DEFINES/~haven_defines' path. Use an existing file, or create a new one if necessary.

If a small addition needs to be made outside of the "haven" folder, then it should be done by adding a proc. This proc will be defined inside of the "haven" folder. By doing this, a large number of things can be done by adding just one line of code outside of the folder! If a file must be changed a lot, re-create it with the changes inside of the "haven/code" folder. **Make sure to follow the file's path correctly** (i.e. code/modules/clothing/clothing.dm.) Then, remove the original file from the outerhaven.dme and add the new one.

#### If you modify TG files, don't forget to update haven/changed.md!

## Specific cases and examples

### Clothing

New clothing items should be a subtype of "/obj/item/clothing/CLOTHINGTYPE/haven" inside of the respective clothing file. For example, replace CLOTHINGTYPE with ears to get "/obj/item/clothing/ears/haven" inside of "ears.dm" in "code/modules/clothing." If the file does not exist, create it and follow this format.

### Actions and spells

New actions and spells should use the "haven/icons/mob/actions.dmi" file. If it is a spell, put the code for the spell in "haven/code/modules/spells." To make sure that the spell uses the Haven icon, please add "action_icon = 'haven/icons/mob/actions.dmi'" and the "action_icon_state" var.

### Reagents

New reagents should go inside "haven/code/modules/reagents/drug_reagents.dm." In this case, "drug_reagents" is an example, so please use or create a "toxins.dm" if you are adding a new toxin. Recipes should go inside "haven/code/modules/reagents/recipes/drug_reagents.dm." Once again, "drug_reagents" has been used as an example.

---

### Thank you for following these rules! Please contact a maintainer if you have any questions about modular code or the "haven" folder.
