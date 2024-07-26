/// Base pouch type. Fits in pockets, as its main gimmick.
/obj/item/storage/pouch
	name = "storage pouch"
	desc = "It's a nondescript pouch made with dark fabric. It has a clip, for fitting in pockets."
	icon = 'monkestation/code/modules/assault_ops/icons/storage.dmi'
	icon_state = "survival"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FLAMMABLE
	slot_flags = ITEM_SLOT_POCKETS

/obj/item/storage/pouch/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL
	atom_storage.max_slots = 5

/obj/item/storage/pouch/ammo
	name = "ammo pouch"
	desc = "A pouch for your ammo that goes in your pocket."
	icon = 'monkestation/code/modules/assault_ops/icons/storage.dmi'
	icon_state = "ammopouch"
	w_class = WEIGHT_CLASS_BULKY
	custom_price = PAYCHECK_CREW * 4
	// this is just to have post_reskin called later
	uses_advanced_reskins = TRUE
	unique_reskin = list(
		"Ammo Pouch" = list(
			RESKIN_ICON_STATE = "ammopouch"
		),
		"Casing Pouch" = list(
			RESKIN_ICON_STATE = "casingpouch"
		),
	)

/obj/item/storage/pouch/ammo/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 12
	atom_storage.max_slots = 3
	atom_storage.numerical_stacking = FALSE
	atom_storage.can_hold = typecacheof(list(/obj/item/ammo_box/magazine, /obj/item/ammo_casing, /obj/item/stock_parts/cell/microfusion))

/obj/item/storage/pouch/ammo/post_reskin(mob/our_mob)
	if(icon_state == "casingpouch")
		name = "casing pouch"
		desc = "A pouch for your ammo that goes in your pocket, carefully segmented for holding shell casings and nothing else."
		atom_storage.can_hold = typecacheof(list(/obj/item/ammo_casing))
		atom_storage.max_specific_storage = WEIGHT_CLASS_TINY
		atom_storage.numerical_stacking = TRUE
		atom_storage.max_slots = 10
		atom_storage.max_total_storage = WEIGHT_CLASS_TINY * 10


/obj/item/storage/pouch/medpens
	name = "medpen pouch"
	desc = "A pouch containing several different types of lifesaving medipens."
	icon = 'monkestation/code/modules/assault_ops/icons/storage.dmi'
	icon_state = "medpen_pouch"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_POCKETS

/obj/item/storage/pouch/medpens/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 30
	atom_storage.max_slots = 5
	atom_storage.numerical_stacking = FALSE
	atom_storage.can_hold = typecacheof(list(/obj/item/reagent_containers/hypospray))

/obj/item/storage/pouch/medpens/PopulateContents()
	new /obj/item/reagent_containers/hypospray/medipen/blood_loss(src)
	new /obj/item/reagent_containers/hypospray/medipen/oxandrolone(src)
	new /obj/item/reagent_containers/hypospray/medipen/salacid(src)
	new /obj/item/reagent_containers/hypospray/medipen/salbutamol(src)
	new /obj/item/reagent_containers/hypospray/medipen/stimulants(src)
