/*
*	LOADOUT ITEM DATUMS FOR THE SHOE SLOT
*/

/// Shoe Slot Items (Deletes overrided items)
GLOBAL_LIST_INIT(loadout_shoes, generate_loadout_items(/datum/loadout_item/shoes))

/datum/loadout_item/shoes
	category = LOADOUT_ITEM_SHOES

/datum/loadout_item/shoes/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(initial(outfit_important_for_life.shoes))
		.. ()
		return TRUE

/datum/loadout_item/shoes/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(override_items == LOADOUT_OVERRIDE_BACKPACK && !visuals_only)
		if(outfit.shoes)
			LAZYADD(outfit.backpack_contents, outfit.shoes)
		outfit.shoes = item_path
	else
		outfit.shoes = item_path

/*
*	JACKBOOTS
*/

/datum/loadout_item/shoes/jackboots
	name = "Jackboots"
	item_path = /obj/item/clothing/shoes/jackboots
	requires_purchase = FALSE

/*
*	MISC BOOTS
*/

/datum/loadout_item/shoes/winter_boots
	name = "Winter Boots"
	item_path = /obj/item/clothing/shoes/winterboots

/datum/loadout_item/shoes/work_boots
	name = "Work Boots"
	item_path = /obj/item/clothing/shoes/workboots

/datum/loadout_item/shoes/mining_boots
	name = "Mining Boots"
	item_path = /obj/item/clothing/shoes/workboots/mining

/datum/loadout_item/shoes/russian_boots
	name = "Russian Boots"
	item_path = /obj/item/clothing/shoes/russian

/*
*	COWBOY
*/

/datum/loadout_item/shoes/brown_cowboy_boots
	name = "Brown Cowboy Boots"
	item_path = /obj/item/clothing/shoes/cowboy

/datum/loadout_item/shoes/black_cowboy_boots
	name = "Black Cowboy Boots"
	item_path = /obj/item/clothing/shoes/cowboy/black

/datum/loadout_item/shoes/white_cowboy_boots
	name = "White Cowboy Boots"
	item_path = /obj/item/clothing/shoes/cowboy/white


/*
*	SNEAKERS
*/

/datum/loadout_item/shoes/greyscale_sneakers
	name = "Colorable Sneakers"
	item_path = /obj/item/clothing/shoes/sneakers

/datum/loadout_item/shoes/black_sneakers
	name = "Black Sneakers"
	item_path = /obj/item/clothing/shoes/sneakers/black

/datum/loadout_item/shoes/blue_sneakers
	name = "Blue Sneakers"
	item_path = /obj/item/clothing/shoes/sneakers/blue

/datum/loadout_item/shoes/brown_sneakers
	name = "Brown Sneakers"
	item_path = /obj/item/clothing/shoes/sneakers/brown

/datum/loadout_item/shoes/green_sneakers
	name = "Green Sneakers"
	item_path = /obj/item/clothing/shoes/sneakers/green

/datum/loadout_item/shoes/purple_sneakers
	name = "Purple Sneakers"
	item_path = /obj/item/clothing/shoes/sneakers/purple

/datum/loadout_item/shoes/orange_sneakers
	name = "Orange Sneakers"
	item_path = /obj/item/clothing/shoes/sneakers/orange

/datum/loadout_item/shoes/yellow_sneakers
	name = "Yellow Sneakers"
	item_path = /obj/item/clothing/shoes/sneakers/yellow

/datum/loadout_item/shoes/white_sneakers
	name = "White Sneakers"
	item_path = /obj/item/clothing/shoes/sneakers/white


/*
*	MISC
*/

/datum/loadout_item/shoes/laceup
	name = "Laceup Shoes"
	item_path = /obj/item/clothing/shoes/laceup

/datum/loadout_item/shoes/disco
	name = "Green Snakeskin Shoes"
	item_path = /obj/item/clothing/shoes/discoshoes


/datum/loadout_item/shoes/griffin
	name = "Griffon Boots"
	item_path = /obj/item/clothing/shoes/griffin

/datum/loadout_item/shoes/sandals
	name = "Sandals"
	item_path = /obj/item/clothing/shoes/sandal

/datum/loadout_item/shoes/heels
	name = "Colorable Heels"
	item_path = /obj/item/clothing/shoes/heels

/*
*	JOB-RESTRICTED
*/

/datum/loadout_item/shoes/jester
	name = "Jester Shoes"
	item_path = /obj/item/clothing/shoes/clown_shoes/clown_jester_shoes
	restricted_roles = list(JOB_CLOWN)

/*
*	DONATOR
*/

/datum/loadout_item/shoes/donator
	donator_only = TRUE
	requires_purchase = FALSE


/datum/loadout_item/shoes/donator/rainbow
	name = "Rainbow Converse"
	item_path = /obj/item/clothing/shoes/sneakers/rainbow

/// EVERYTHING NOVA RELATED
//NOTES
//Glass will fuck you up if you're wearing wraps

//I changed my mind lol, I'm adding it all - Knight

/datum/loadout_item/shoes/nova/jackboots/recolorable
	name = "Recolorable Jackboots"
	item_path = /obj/item/clothing/shoes/jackboots/recolorable
	requires_purchase = FALSE

/datum/loadout_item/shoes/nova/colorable_laceups
	name = "Recolorable Laceups"
	item_path = /obj/item/clothing/shoes/colorable_laceups
	requires_purchase = FALSE

/datum/loadout_item/shoes/nova/colorable_sandals
	name = "Recolorable Sandals"
	item_path = /obj/item/clothing/shoes/colorable_sandals
	requires_purchase = FALSE

/datum/loadout_item/shoes/nova/wraps/colorable
	name = "colourable foot wraps"
	item_path = /obj/item/clothing/shoes/wraps/colourable
	requires_purchase = FALSE

/datum/loadout_item/shoes/nova/wraps/cloth
	name = "cloth foot wraps"
	item_path = /obj/item/clothing/shoes/wraps/cloth
	requires_purchase = FALSE

/datum/loadout_item/shoes/nova/wraps/swag
	name = "gilded foot wraps"
	item_path = /obj/item/clothing/shoes/wraps

/datum/loadout_item/shoes/nova/wraps/drip
	name = "silver leg wraps"
	item_path = /obj/item/clothing/shoes/wraps/silver

/datum/loadout_item/shoes/nova/jungleboots
	name = "jungle boots"
	item_path = /obj/item/clothing/shoes/jungleboots

/datum/loadout_item/shoes/nova/kimshoes
	name = "aerostatic boots"
	item_path = /obj/item/clothing/shoes/kimshoes


//Stuff I didn't add earlier


/datum/loadout_item/shoes/kneeboot
	name = "Knee Boots"
	item_path = /obj/item/clothing/shoes/jackboots/knee

/datum/loadout_item/shoes/jackboots/frontier
	name = "Heavy Frontier Boots"
	item_path = /obj/item/clothing/shoes/jackboots/frontier_colonist

/*
*	MISC BOOTS
*/

/datum/loadout_item/shoes/timbs
	name = "Fashionable Boots"
	item_path = /obj/item/clothing/shoes/jackboots/timbs

/*
*	COWBOY
*/

/datum/loadout_item/shoes/cowboyboots
	name = "Cowboy Boots (Brown)"
	item_path = /obj/item/clothing/shoes/cowboyboots

/datum/loadout_item/shoes/cowboyboots_black
	name = "Cowboy Boots (Black)"
	item_path = /obj/item/clothing/shoes/cowboyboots/black

/*
*	LEG WRAPS PART II (no protection = free)
*/

/datum/loadout_item/shoes/redcuffs
	name = "Red Leg Wraps"
	item_path = /obj/item/clothing/shoes/wraps/red
	requires_purchase = FALSE

/datum/loadout_item/shoes/bluecuffs
	name = "Blue Leg Wraps"
	item_path = /obj/item/clothing/shoes/wraps/blue
	requires_purchase = FALSE

/*
*	MISC
*/

/datum/loadout_item/shoes/high_heels
	name = "High Heels"
	item_path = /obj/item/clothing/shoes/high_heels

/datum/loadout_item/shoes/black_heels
	name = "Fancy Heels"
	item_path = /obj/item/clothing/shoes/fancy_heels

/datum/loadout_item/shoes/sportshoes
	name = "Sport Shoes"
	item_path = /obj/item/clothing/shoes/sports

/datum/loadout_item/shoes/rollerskates
	name = "Roller Skates"
	item_path = /obj/item/clothing/shoes/wheelys/rollerskates

/datum/loadout_item/shoes/wheelys
	name = "Wheely-Heels"
	item_path = /obj/item/clothing/shoes/wheelys

/*
*	SEASONAL
*/

/datum/loadout_item/shoes/christmas
	name = "Red Christmas Boots"
	item_path = /obj/item/clothing/shoes/winterboots/christmas

/datum/loadout_item/shoes/christmas/green
	name = "Green Christmas Boots"
	item_path = /obj/item/clothing/shoes/winterboots/christmas/green


/*
*	JOB-RESTRICTED
*/

/datum/loadout_item/shoes/clown_shoes/pink
	name = "Pink Clown Shoes"
	item_path = /obj/item/clothing/shoes/clown_shoes/pink
	restricted_roles = list(JOB_CLOWN)
	requires_purchase = FALSE
