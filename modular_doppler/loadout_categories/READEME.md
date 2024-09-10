# LOADOUT CATEGORIES

Most loadout categories are added in, if it is one that is stock TG just add in additional items in the respecitve files.

If you need to add more categories or items the following format should be followed:

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

```DM
    /datum/loadout_item/pocket_items/<Logical name for the loadout item>
        name = "<Name that will show up in the loadout menu>"
        item_path = <The items actual path>
        /* Here there could be additional vars specified current list of possible vars as follows:
            restricted_roles // If the item is only allowed on specific roles I.E Security Items
            blacklisted_roles // If the item cannot be given to specific roles I.E. Prisoner
            restricted_species // If the item would cause issues with a species
            required_season = null // If the item is a seasonal one and should only show up then
            erp_item = FALSE // If the item is suggestive
            erp_box = FALSE // If the item is suggestive and should be put in a box
        /*
```

## Helper Functions

### Post equip Item

`/datum/loadout_item/proc/post_equip_item`
This proc particulalrly is useful if you wish for a specific item to do something after it gets equipped to the character. As an exapmple take the wallet, equip it on the ID card slot then just put the ID into the wallet so you dont have to put your own ID in your wallet. Useful for that sort of thing.

### Pre equip Item

`/datum/loadout_item/proc/pre_equip_item`
Useful for doing checks on a item before it gets equipped for whatever reason, most of the time check to see if the slot would affect someone who has a item there they need to survive, I.E. Plasmamen.

### Can be applied to

`/datum/loadout_item/proc/can_be_applied_to`
Checkes if the item passes requirements and isn't blacklisted based on role or species or restricted to specific role
