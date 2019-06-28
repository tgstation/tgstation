# Introduction to the "spacestation413" Folder

## Why do we use it?

Same reason [HippieStation does.](https://github.com/HippieStation/HippieStation/blob/master/hippiestation/README.md) For ease of use, I've copied the rest here with some choice edits to make sure people aren't adding "hippie -- reason" to the spacestation413 code.

## What does it mean to modularize something?

Something is modular when it exists independent from the rest of the code. This means that by simply adding something modular to the DME file, it will exist in-game. It is not always possible to completely modularize something, but if standards are followed correctly, then there should be few to none conflicts with /tg/station in the future.

## Please mark your changes

All modifications to non-413 files should be marked.

- Single line changes should have `// 413 -- reason` at the end of the exact line that was edited
- Multi line changes start with `// 413 -- reason` and end with `// 413 end`. The reason MUST be included in the change in all cases, so that future coders looking at the line will know why it is needed.
- The reason should generally be about what it was before, or what the change is.
- Commenting out some /tg/ code must be done by putting `/* 413 start -- reason` one line before the commented out code, with said line having only the comment itself, and `413 end */` one line after the commented out code, always in an empty line.
- Some examples:
```
var/obj/O = new(fourthirteen) // 413 -- added 413 argument to new
```
```
/* 413 start -- mirrored in our file
/proc/del_everything
	del(world)
	del(O)
	del(everything)
413 end */
```

Once marking your changes to the /tg/ files with the proper comment standards, be sure to include the file path of the tg file in our changes.md in this folder. Keep the alphabetical order.


### tgstation.dme versus spacestation413.dme

Do not alter the tgstation.dme file. All additions and removals should be to the spacestation413.dme file. Do not manually add files to the dme! Check the file's box in the Dream Maker program. The Dream Maker does not always use alphabetical order, and manually adding a file can cause it to reorder. This means that down the line, many PRs will contain this reorder when it could have been avoided in the first place.

### Icons, code, and sounds

Icons are notorious for conflicts. Because of this, **ALL NEW ICONS** must go in the "spacestation413/icons" folder. There are to be no exceptions to this rule. Sounds don't cause conflicts, but for the sake of organization they are to go in the "spacestation413/sounds" folder. No exceptions, either. Unless absolutely necessary, code should go in the "spacestation413/code" folder. Small changes outside of the folder should be done with "hook" procs. Larger changes should simply mirror the file in the "spacestation413/code" folder.

If a multiline addition needs to be made outside of the "spacestation413" folder, then it should be done by adding a proc called "hook" proc. This proc will be defined inside of the "spacestation413" folder. By doing this, a large number of things can be done by adding just one line of code outside of the folder! If possible, also add a comment in the 413 file pointing at the file and proc where the "hook" proc is called, it can be helpful during upstream merges and such.

If a file must be completely changed, re-create it with the changes inside of the "spacestation413/code" folder. **Make sure to follow the file's path correctly** (i.e. code/modules/clothing/clothing.dm.) Then, remove the original file from the spacestation413.dme and add the new one.

### Defines

Defines only work if they come before the code in which they are used. Because of this, please put all defines in the `code/__DEFINES/~ss413_defines' path. Use an existing file, or create a new one if necessary.

## Specific cases and examples

### Clothing

New clothing items should be a subtype of "/obj/item/clothing/CLOTHINGTYPE/spacestation413" inside of the respective clothing file. For example, replace CLOTHINGTYPE with ears to get "/obj/item/clothing/ears/spacestation413" inside of "ears.dm" in "code/modules/clothing." If the file does not exist, create it and follow this format.

### Actions and spells

New actions and spells should use the "spacestation413/icons/mob/actions.dmi" file. If it is a spell, put the code for the spell in "spacestation413/code/modules/spells." To make sure that the spell uses the 413 icon, please add "action_icon = 'spacestation413/icons/mob/actions.dmi'" and the "action_icon_state" var.

### Reagents

New reagents should go inside "spacestation413/code/modules/reagents/drug_reagents.dm." In this case, "drug_reagents" is an example, so please use or create a "toxins.dm" if you are adding a new toxin, etc. Recipes should go inside "spacestation413/code/modules/reagents/recipes/drug_reagents.dm." Once again, "drug_reagents" has been used as an example.
