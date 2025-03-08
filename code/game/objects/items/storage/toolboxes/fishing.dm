/obj/item/storage/toolbox/fishing
	name = "fishing toolbox"
	desc = "Contains everything you need for your fishing trip."
	icon_state = "fishing"
	inhand_icon_state = "artistic_toolbox"
	material_flags = NONE
	custom_price = PAYCHECK_CREW * 3
	storage_type = /datum/storage/toolbox/fishing

	///How much holding this affects fishing difficulty
	var/fishing_modifier = -4

/obj/item/storage/toolbox/fishing/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/adjust_fishing_difficulty, fishing_modifier, ITEM_SLOT_HANDS)

/obj/item/storage/toolbox/fishing/PopulateContents()
	return list(
		/obj/item/bait_can/worm,
		/obj/item/fishing_rod/unslotted,
		/obj/item/fishing_hook,
		/obj/item/fishing_line,
		/obj/item/paper/paperslip/fishing_tip,
	)

/obj/item/storage/toolbox/fishing/small
	name = "compact fishing toolbox"
	desc = "Contains everything you need for your fishing trip. Except for the bait."
	w_class = WEIGHT_CLASS_NORMAL
	force = 5
	throwforce = 5
	storage_type = /datum/storage/toolbox/fishing/small

/obj/item/storage/toolbox/fishing/small/PopulateContents()
	return list(
		/obj/item/fishing_rod/unslotted,
		/obj/item/fishing_hook,
		/obj/item/fishing_line,
		/obj/item/paper/paperslip/fishing_tip,
	)

/obj/item/storage/toolbox/fishing/master
	name = "super fishing toolbox"
	desc = "Contains (almost) EVERYTHING you need for your fishing trip."
	icon_state = "gold"
	inhand_icon_state = "toolbox_gold"
	fishing_modifier = -10

/obj/item/storage/toolbox/fishing/master/PopulateContents()
	return list(
		/obj/item/fishing_rod/telescopic/master,
		/obj/item/storage/box/fishing_hooks/master,
		/obj/item/storage/box/fishing_lines/master,
		/obj/item/bait_can/super_baits,
		/obj/item/reagent_containers/cup/fish_feed,
		/obj/item/aquarium_kit,
		/obj/item/fish_analyzer,
	)
