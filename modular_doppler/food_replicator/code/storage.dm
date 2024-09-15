/obj/item/storage/pouch/cin_medipens
	name = "colonial medipen pouch"
	desc = "A pouch for your (medi-)pens that goes in your pocket."
	icon = 'modular_doppler/food_replicator/icons/pouch.dmi'
	icon_state = "medipen_pouch"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/pouch/cin_medipens/update_icon_state()
	icon_state = "[initial(icon_state)]_[contents.len]"
	return ..()

/obj/item/storage/pouch/cin_medipens/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/storage/pouch/cin_medipens/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_TINY
	atom_storage.max_total_storage = 4
	atom_storage.max_slots = 4
	atom_storage.can_hold = typecacheof(list(/obj/item/reagent_containers/hypospray/medipen, /obj/item/pen, /obj/item/flashlight/pen))

/obj/item/storage/pouch/cin_medkit
	name = "colonial first aid kit"
	desc = "A medical case that goes in your pocket. Can be used to store things unrelated to medicine, except for guns, ammo and raw materials."
	icon = 'modular_doppler/food_replicator/icons/pouch.dmi'
	icon_state = "cfak"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/pouch/cin_medkit/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL
	atom_storage.max_total_storage = 8
	atom_storage.max_slots = 4
	atom_storage.cant_hold = typecacheof(list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/stack/sheet))
