// "Ey' boss.. -that man botherin' yous?
// Sprites -Cannibal Hunter

//greyscale_config
/datum/greyscale_config/henchmen
	name = "henchmen"
	icon_file = 'monkestation/icons/mob/clothing/costumes/henchmen/henchmen_item.dmi'
	json_config = 'monkestation/code/datums/greyscale/json_configs/henchmen.json'
	expected_colors = 1
/datum/greyscale_config/henchmen_worn
	name = "henchmen_worn"
	icon_file = 'monkestation/icons/mob/clothing/costumes/henchmen/henchmen_worn.dmi'
	json_config = 'monkestation/code/datums/greyscale/json_configs/henchmen.json'
	expected_colors = 1

//clothing
/obj/item/clothing/head/henchmen_hat
	name = "henchmen cap"
	desc = "Alright boss.. I'll handle it."
	icon = 'monkestation/icons/mob/clothing/costumes/henchmen/henchmen_item.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/henchmen/henchmen_worn.dmi'
	icon_state = "greyscale_cap"
	greyscale_colors = "#201b1a"
	greyscale_config = /datum/greyscale_config/henchmen
	greyscale_config_worn = /datum/greyscale_config/henchmen_worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/suit/jacket/henchmen_coat
	name = "henchmen coat"
	desc = "Alright boss.. I'll handle it."
	icon = 'monkestation/icons/mob/clothing/costumes/henchmen/henchmen_item.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/henchmen/henchmen_worn.dmi'
	icon_state = "greyscale_coat"
	greyscale_colors = "#201b1a"
	greyscale_config = /datum/greyscale_config/henchmen
	greyscale_config_worn = /datum/greyscale_config/henchmen_worn
	flags_1 = IS_PLAYER_COLORABLE_1
/obj/item/clothing/suit/jacket/henchmen_coat/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)

//loadout_item
/datum/loadout_item/head/henchmen_hat
	name = "Henchmen Cap"
	item_path = /obj/item/clothing/head/henchmen_hat
/datum/loadout_item/suit/henchmen_coat
	name = "Henchmen Coat"
	item_path = /obj/item/clothing/suit/jacket/henchmen_coat

//store_item
/datum/store_item/head/henchmen_hat
	name = "Henchmen Cap"
	item_path = /obj/item/clothing/head/henchmen_hat
	item_cost = 15000
/datum/store_item/suit/henchmen_coat
	name = "Henchmen Coat"
	item_path = /obj/item/clothing/suit/jacket/henchmen_coat
	item_cost = 20000

//traitor
/obj/item/clothing/head/henchmen_hat/traitor
	name = "armored henchmen cap"
	desc = "Alright boss.. I'll handle it. It seems to be armored."
	armor_type = /datum/armor/suit_armor
	greyscale_colors = "#240d0d"

/obj/item/clothing/suit/jacket/henchmen_coat/traitor
	name = "armored henchmen coat"
	desc = "Alright boss.. I'll handle it. It seems to be armored."
	armor_type = /datum/armor/suit_armor
	greyscale_colors = "#240d0d"

/obj/item/storage/box/syndicate/henchmen_traitor_outfit
	name = "henchmen outfit box"

/obj/item/storage/box/syndicate/henchmen_traitor_outfit/PopulateContents()
	var/static/items_inside = list(
		/obj/item/clothing/head/henchmen_hat/traitor = 1,
		/obj/item/clothing/suit/jacket/henchmen_coat/traitor = 1,
		/obj/item/clothing/under/color/black = 1,
		/obj/item/clothing/gloves/color/light_brown = 1,
		/obj/item/clothing/shoes/laceup = 1,
		/obj/item/switchblade = 1,
	)
	generate_items_inside(items_inside,src)

/obj/item/storage/backpack/duffelbag/henchmen_traitor_outfits
/obj/item/storage/backpack/duffelbag/henchmen_traitor_outfits/PopulateContents()
	var/static/items_inside = list(
		/obj/item/storage/box/syndicate/henchmen_traitor_outfit = 5,
	)
	generate_items_inside(items_inside,src)

/datum/uplink_item/bundles_tc/henchmen_traitor_outfits
	name = "Henchmen Bundle"
	desc = "A set of five armored henchmen outfits! Each set comes with a cap, coat, uniform, gloves, shoes, and a switchblade!"
	item = /obj/item/storage/backpack/duffelbag/henchmen_traitor_outfits
	cost = 4
