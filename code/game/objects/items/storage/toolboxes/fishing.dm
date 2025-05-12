
/obj/item/storage/toolbox/fishing
	name = "fishing toolbox"
	desc = "Contains everything you need for your fishing trip."
	icon_state = "teal"
	inhand_icon_state = "toolbox_teal"
	material_flags = NONE
	custom_price = PAYCHECK_CREW * 3
	storage_type = /datum/storage/toolbox/fishing

	///How much holding this affects fishing difficulty
	var/fishing_modifier = -4

/obj/item/storage/toolbox/fishing/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, fishing_modifier, ITEM_SLOT_HANDS)

/obj/item/storage/toolbox/fishing/PopulateContents()
	new /obj/item/bait_can/worm(src)
	new /obj/item/fishing_rod/unslotted(src)
	new /obj/item/fishing_hook(src)
	new /obj/item/fishing_line(src)
	new /obj/item/paper/paperslip/fishing_tip(src)

/obj/item/storage/toolbox/fishing/small
	name = "compact fishing toolbox"
	desc = "Contains everything you need for your fishing trip. Except for the bait."
	w_class = WEIGHT_CLASS_NORMAL
	force = 5
	throwforce = 5
	storage_type = /datum/storage/toolbox/fishing/small

/obj/item/storage/toolbox/fishing/small/PopulateContents()
	new /obj/item/fishing_rod/unslotted(src)
	new /obj/item/fishing_hook(src)
	new /obj/item/fishing_line(src)
	new /obj/item/paper/paperslip/fishing_tip(src)

/obj/item/storage/toolbox/fishing/master
	name = "super fishing toolbox"
	desc = "Contains (almost) EVERYTHING you need for your fishing trip."
	icon_state = "gold"
	inhand_icon_state = "toolbox_gold"
	fishing_modifier = -10

/obj/item/storage/toolbox/fishing/master/PopulateContents()
	new /obj/item/fishing_rod/telescopic/master(src)
	new /obj/item/storage/box/fishing_hooks/master(src)
	new /obj/item/storage/box/fishing_lines/master(src)
	new /obj/item/bait_can/super_baits(src)
	new /obj/item/reagent_containers/cup/fish_feed(src)
	new /obj/item/aquarium_kit(src)
	new /obj/item/fish_analyzer(src)
