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

/datum/loadout_item/shoes/medical
	name = "Medical Shoes"
	item_path = /obj/item/clothing/shoes/medical

/datum/loadout_item/shoes/sneakers
	name = "Sneakers"
	item_path = /obj/item/clothing/shoes/sneakers

/datum/loadout_item/shoes/sneakers_rainbow
	name = "Rainbow Sneakers"
	item_path = /obj/item/clothing/shoes/sneakers/rainbow

/datum/loadout_item/shoes/jackboots
	name = "Jackboots"
	item_path = /obj/item/clothing/shoes/jackboots

/datum/loadout_item/shoes/jackboots/greyscale
	name = "Custom Jackboots"
	item_path = /obj/item/clothing/shoes/jackboots/recolorable

/datum/loadout_item/shoes/workboots
	name = "Work Boots"
	item_path = /obj/item/clothing/shoes/workboots

/datum/loadout_item/shoes/workboots_mining
	name = "Mining Boots"
	item_path = /obj/item/clothing/shoes/workboots/mining

/datum/loadout_item/shoes/laceup
	name = "Lace-Up Shoes"
	item_path = /obj/item/clothing/shoes/laceup

/datum/loadout_item/shoes/sandal
	name = "Sandals"
	item_path = /obj/item/clothing/shoes/sandal

/datum/loadout_item/shoes/magboots
	name = "Magboots"
	item_path = /obj/item/clothing/shoes/magboots

/datum/loadout_item/shoes/winterboots
	name = "Winter Boots"
	item_path = /obj/item/clothing/shoes/winterboots

/datum/loadout_item/shoes/clown_shoes
	name = "Clown Shoes"
	item_path = /obj/item/clothing/shoes/clown_shoes

/datum/loadout_item/shoes/jester_shoes
	name = "Jester Shoes"
	item_path = /obj/item/clothing/shoes/jester_shoes

/datum/loadout_item/shoes/wheelys
	name = "Wheelys"
	item_path = /obj/item/clothing/shoes/wheelys

/datum/loadout_item/shoes/cowboy
	name = "Cowboy Boots"
	item_path = /obj/item/clothing/shoes/cowboy

/datum/loadout_item/shoes/cowboy/lizard
	name = "Lizard Cowboy Boots"
	item_path = /obj/item/clothing/shoes/cowboy/lizard

/datum/loadout_item/shoes/pirate
	name = "Pirate Boots"
	item_path = /obj/item/clothing/shoes/pirate

/datum/loadout_item/shoes/colonial_boots
	name = "Colonial Half-boots"
	item_path = /obj/item/clothing/shoes/jackboots/colonial

/datum/loadout_item/shoes/colonial_boots/greyscale
	name = "Custom Colonial Half-boots"
	item_path = /obj/item/clothing/shoes/jackboots/colonial/greyscale

/datum/loadout_item/shoes/frontier_boots
	name = "Heavy Boots"
	item_path = /obj/item/clothing/shoes/jackboots/frontier_colonist

/datum/loadout_item/shoes/greyscale_laceups
	name = "Custom Laceups"
	item_path = /obj/item/clothing/shoes/colorable_laceups

/datum/loadout_item/shoes/greyscale_sandals
	name = "Custom Sandals"
	item_path = /obj/item/clothing/shoes/colorable_sandals

/datum/loadout_item/shoes/wraps
	name = "Cloth Footwraps"
	item_path = /obj/item/clothing/shoes/wraps

/datum/loadout_item/shoes/wraps/leggy
	name = "Cloth Legwraps"
	item_path = /obj/item/clothing/shoes/wraps/leggy

/datum/loadout_item/shoes/wraps/aerostatic
	name = "Aerostatic Boots"
	item_path = /obj/item/clothing/shoes/kim

/datum/loadout_item/shoes/wraps/disco
	name = "Green Lizardskin Shoes"
	item_path = /obj/item/clothing/shoes/discoshoes

/datum/loadout_item/shoes/wraps/swag
	name = "Drip Shoes"
	item_path = /obj/item/clothing/shoes/swagshoes

/datum/loadout_item/shoes/wraps/skates
	name = "Roller Skates"
	item_path = /obj/item/clothing/shoes/wheelys/rollerskates

/datum/loadout_item/shoes/rollerblades
	name = "Inline Skates"
	item_path = /obj/item/clothing/shoes/rollerblades
