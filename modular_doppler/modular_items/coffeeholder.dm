/obj/item/storage/coffee
	name = "coffee holder"
	desc = "An intern's best friend."
	icon = 'modular_doppler/modular_items/icons/coffeeholder.dmi'
	icon_state = "holder"
	inhand_icon_state = "cawfeeinhand"
	lefthand_file = 'modular_doppler/modular_items/icons/coffeeholder_lefthand.dmi'
	righthand_file = 'modular_doppler/modular_items/icons/coffeeholder_righthand.dmi'
	drop_sound = 'sound/items/handling/cardboard_box/cardboardbox_drop.ogg'
	pickup_sound = 'sound/items/handling/cardboard_box/cardboardbox_pickup.ogg'
	var/foldable_result = /obj/item/stack/sheet/cardboard
	max_integrity = 500

/obj/item/storage/coffee/update_icon_state()
	icon_state = "[initial(icon_state)][contents.len]"
	return ..()

/obj/item/storage/coffee/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.max_total_storage = 8
	atom_storage.max_slots = 4
	atom_storage.set_holdable(list(
		/obj/item/reagent_containers/cup/glass/coffee,
	))
	update_appearance()

/obj/item/storage/coffee/full
	name = "coffee 4-pack"
	desc = "For the enterprising and suffering worker!"

/obj/item/storage/coffee/full/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/reagent_containers/cup/glass/coffee(src)
