/// Shoe Slot Items (Deletes overrided items)
/datum/loadout_category/shoes
	category_name = "Shoes"
	category_ui_icon = FA_ICON_SHOE_PRINTS
	type_to_generate = /datum/loadout_item/shoes
	tab_order = 1

/datum/loadout_item/shoes
	abstract_type = /datum/loadout_item/shoes

/datum/loadout_item/shoes/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	outfit.shoes = item_path

/datum/loadout_item/shoes/sneakers
	name = "Sneakers (Colorable)"
	item_path = /obj/item/clothing/shoes/sneakers

/datum/loadout_item/shoes/sandals_laced
	name = "Sandals (Laced)"
	item_path = /obj/item/clothing/shoes/sandal/laced

/datum/loadout_item/shoes/sandals_cook_laced
	name = "Sandals (Cook, Laced)"
	item_path = /obj/item/clothing/shoes/cookflops/laced

/datum/loadout_item/shoes/laceup
	name = "Shoes (Laceup)"
	item_path = /obj/item/clothing/shoes/laceup

/datum/loadout_item/shoes/kindle_kicks
	name = "Kindle Kicks"
	item_path = /obj/item/clothing/shoes/kindle_kicks

/datum/loadout_item/shoes/cowboy_brown
	name = "Shoes (Cowboy, Brown)"
	item_path = /obj/item/clothing/shoes/cowboy/laced

/datum/loadout_item/shoes/cowboy_white
	name = "Shoes (Cowboy, White)"
	item_path = /obj/item/clothing/shoes/cowboy/white/laced

/datum/loadout_item/shoes/cowboy_black
	name = "Shoes (Cowboy, Black)"
	item_path = /obj/item/clothing/shoes/cowboy/black/laced

/datum/loadout_item/shoes/swag
	name = "Shoes (Swag)"
	item_path = /obj/item/clothing/shoes/swagshoes

/datum/loadout_item/shoes/glow_shoes
	name = "Shoes (Glowing, Colorable)"
	item_path = /obj/item/clothing/shoes/glow

/datum/loadout_item/shoes/saints
	name = "Shoes (Saints)"
	item_path = /obj/item/clothing/shoes/saints

/datum/loadout_item/shoes/jockboots
	name = "Shoes (Jock)"
	item_path = /obj/item/clothing/shoes/jockboots

/datum/loadout_item/shoes/jackboots
	name = "Shoes (Jack)" // :clueless:
	item_path = /obj/item/clothing/shoes/jackbros

/datum/loadout_item/shoes/roller
	name = "Shoes (Skate)"
	item_path = /obj/item/clothing/shoes/wheelys/rollerskates
	additional_displayed_text = list("Cumbersome")
