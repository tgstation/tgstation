# LOADOUT CATEGORIES

Most loadout categories are added in, if it is one that is stock TG just add in additional items in the respecitve files.

If you need to add more categories the following format should be followed:

## Format

```DM
/datum/loadout_category/<category name here>
    category_name = "<category name here>"
    category_ui_icon = FA_ICON_GLASSES // A Fontawesome icon to be used for the Category item
    type_to_generate = /datum/loadout_item/<category item here>
    tab_order = /datum/loadout_category/head::tab_order + 1 //This is where it will place the item in the tab order

/datum/loadout_item/<category item here>
    abstract_type = /datum/loadout_item/glasses

/datum/loadout_item/<category item here>/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
    if(outfit.glasses)
        LAZYADD(outfit.backpack_contents, outfit.glasses) // This will dictate if the item will go into the backpack if the slot is already occupied
    outfit.glasses = item_path
```
