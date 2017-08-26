# Introduction to the "hippiestation" Folder

## Why do we use it?

Recently, HippieStation has tried to keep /tg/station as an upstream and to stay up-to-date with it. Previous attempts failed due to the number of conflicts, so the coders have decided to keep everything modularized. The more code in the "hippiestation" folder, the fewer conflicts will exist in future updates.

## What does it mean to modularize something?

Something is modular when it exists independent from the rest of the code. This means that by simply adding something modular to the DME file, it will exist in-game. It is not always possible to completely modularize something, but if standards are followed correctly, then there should be few to none conflicts with /tg/station in the future.

### tgstation.dme versus hippiestation.dme

Do not alter the tgstation.dme file. All additions and removals should be to the hippiestation.dme file. Do not manually add files to the dme! Check the file's box in the Dream Maker program. The Dream Maker does not always use alphabetical order, and manually adding a file can cause it to reorder. This means that down the line, many PRs will contain this reorder when it could have been avoided in the first place.

### Icons, code, and sounds

Icons are notorious for conflicts. Because of this, **ALL NEW ICONS** must go in the "hippiestation/icons" folder. There are to be no exceptions to this rule. Sounds don't cause conflicts, but for the sake of organization they are to go in the "hippiestation/sounds" folder. No exceptions, either. Unless absolutely necessary, code should go in the "hippiestation/code" folder. Small changes outside of the folder should be done with hook-procs. Larger changes should simply mirror the file in the "hippiestation/code" folder.

### Defines

Defines only work if they come before the code in which they are used. Because of this, please put all defines in the `code/__DEFINES/~hippie_defines' path. Use an existing file, or create a new one if necessary.

If a small addition needs to be made outside of the "hippiestation" folder, then it should be done by adding a proc. This proc will be defined inside of the "hippiestation" folder. By doing this, a large number of things can be done by adding just one line of code outside of the folder! If a file must be changed a lot, re-create it with the changes inside of the "hippiestation/code" folder. **Make sure to follow the file's path correctly** (i.e. code/modules/clothing/clothing.dm.) Then, remove the original file from the hippiestation.dme and add the new one.

## Specific cases and examples

### Clothing

New clothing items should be a subtype of "/obj/item/clothing/CLOTHINGTYPE/hippie" inside of the respective clothing file. For example, replace CLOTHINGTYPE with ears to get "/obj/item/clothing/ears/hippie" inside of "ears.dm" in "code/modules/clothing." If the file does not exist, create it and follow this format.

### Actions and spells

New actions and spells should use the "hippiestation/icons/mob/actions.dmi" file. If it is a spell, put the code for the spell in "hippiestation/code/modules/spells." To make sure that the spell uses the Hippie icon, please add "action_icon = 'hippiestation/icons/mob/actions.dmi'" and the "action_icon_state" var.

### Reagents

New reagents should go inside "hippiestation/code/modules/reagents/drug_reagents.dm." In this case, "drug_reagents" is an example, so please use or create a "toxins.dm" if you are adding a new toxin. Recipes should go inside "hippiestation/code/modules/reagents/recipes/drug_reagents.dm." Once again, "drug_reagents" has been used as an example.