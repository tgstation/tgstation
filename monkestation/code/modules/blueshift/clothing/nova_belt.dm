/obj/item/storage/belt/medbandolier
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/belts.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/belt.dmi'
	name = "medical bandolier"
	desc = "A pocketed, pine green belt slung like a sash over the shoulder. Features numerous pockets for medicines and poisons alike. Now is coward healing time."
	icon_state = "med_bandolier"
	worn_icon_state = "med_bandolier"

/obj/item/storage/belt/medbandolier/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_slots = 14
	atom_storage.max_total_storage = 35
	atom_storage.set_holdable(list(
		/obj/item/dnainjector,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/medigel,
		/obj/item/storage/pill_bottle,
		/obj/item/implanter
		))

/obj/item/storage/belt/military/nri
	name = "green tactical belt"
	desc = "A green tactical belt made for storing military grade hardware."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/belts.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/belt.dmi'
	icon_state = "russian_green_belt"
	inhand_icon_state = "security"
	worn_icon_state = "russian_green_belt"

/obj/item/storage/belt/military/nri/captain
	name = "black tactical belt"
	desc = "A black tactical belt made for storing military grade hardware."
	icon_state = "russian_black_belt"
	worn_icon_state = "russian_black_belt"

/obj/item/storage/belt/military/nri/medic
	name = "blue tactical belt"
	desc = "A blue tactical belt made for storing military grade hardware."
	icon_state = "russian_white_belt"
	worn_icon_state = "russian_white_belt"

/obj/item/storage/belt/military/nri/engineer
	name = "brown tactical belt"
	desc = "A brown tactical belt made for storing military grade hardware."
	icon_state = "russian_brown_belt"
	worn_icon_state = "russian_brown_belt"

/obj/item/storage/belt/military/nri/plus_mre/PopulateContents()
	new /obj/item/storage/box/nri_survival_pack/raider(src)

/obj/item/storage/belt/military/nri/soldier/PopulateContents()
	generate_items_inside(list(
		/obj/item/ammo_box/magazine/lanca = 4,
		/obj/item/knife/combat = 1,
		/obj/item/grenade/smokebomb = 1,
		/obj/item/grenade/frag = 1,
	),src)

/obj/item/storage/belt/military/nri/heavy/PopulateContents()
	generate_items_inside(list(
		/obj/item/ammo_box/magazine/m9mm_aps = 4,
		/obj/item/knife/combat = 1,
		/obj/item/grenade/smokebomb = 1,
		/obj/item/grenade/frag = 1,
	),src)

/obj/item/storage/belt/military/nri/captain/full/PopulateContents()
	generate_items_inside(list(
		/obj/item/ammo_box/magazine/lanca = 4,
		/obj/item/knife/combat = 1,
		/obj/item/grenade/smokebomb = 1,
		/obj/item/grenade/frag = 1,
	),src)

/obj/item/storage/belt/military/nri/medic/full/PopulateContents()
	generate_items_inside(list(
		/obj/item/ammo_box/magazine/miecz = 4,
		/obj/item/knife/combat = 1,
		/obj/item/grenade/smokebomb = 1,
		/obj/item/grenade/frag = 1,
	),src)

/obj/item/storage/belt/military/nri/engineer/full/PopulateContents()
	generate_items_inside(list(
		/obj/item/ammo_box/magazine/miecz = 4,
		/obj/item/knife/combat = 1,
		/obj/item/grenade/smokebomb = 1,
		/obj/item/grenade/frag = 1,
	),src)

/obj/item/storage/box/nri_survival_pack/raider
	w_class = WEIGHT_CLASS_SMALL
	desc = "A box filled with useful emergency items, supplied by the NRI. It feels particularily light."

/obj/item/storage/box/nri_survival_pack/raider/PopulateContents()
	new /obj/item/oxygen_candle(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/stack/spacecash/c1000(src)
	new /obj/item/storage/pill_bottle/iron(src)
	new /obj/item/reagent_containers/hypospray/medipen(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/crowbar/red(src)
