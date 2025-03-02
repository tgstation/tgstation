//CONTAINS: Evidence bags

/obj/item/evidencebag
	name = "evidence bag"
	desc = "An empty evidence bag."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "evidenceobj"
	inhand_icon_state = ""
	w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON
	drop_sound = 'sound/items/evidence_bag/evidence_bag_drop.ogg'
	pickup_sound = 'sound/items/evidence_bag/evidence_bag_pickup.ogg'
	sound_vary = TRUE

/obj/item/evidencebag/Initialize(mapload)
	. = ..()
	create_storage(
		max_slots = 1,
		max_specific_storage = WEIGHT_CLASS_NORMAL,
	)
	atom_storage.allow_quick_gather = TRUE
	atom_storage.collection_mode = COLLECT_ONE
	RegisterSignal(atom_storage, COMSIG_STORAGE_STORED_ITEM, PROC_REF(on_insert))
	RegisterSignal(atom_storage, COMSIG_STORAGE_REMOVED_ITEM, PROC_REF(on_remove))
	atom_storage.rustle_sound = 'sound/items/evidence_bag/evidence_bag_zip.ogg'
	atom_storage.remove_rustle_sound = 'sound/items/evidence_bag/evidence_bag_unzip.ogg'

/obj/item/evidencebag/update_desc(updates)
	. = ..()
	if(!atom_storage.get_total_weight())
		desc = src::desc
		return
	var/obj/item/inserted = locate(/obj/item) in atom_storage.real_location
	desc = "An evidence bag containing [inserted]. [inserted.desc]"

/obj/item/evidencebag/update_icon_state()
	. = ..()
	if(!atom_storage.get_total_weight())
		icon_state = "evidenceobj"
		return
	icon_state = "evidence"

/obj/item/evidencebag/update_overlays()
	. = ..()
	if(!atom_storage.get_total_weight())
		return
	var/obj/item/inserted = locate(/obj/item) in atom_storage.real_location
	var/mutable_appearance/in_evidence = new(inserted)
	in_evidence.plane = FLOAT_PLANE
	in_evidence.layer = FLOAT_LAYER
	in_evidence.pixel_x = 0
	in_evidence.pixel_y = 0
	. += in_evidence
	. += "evidence"

/obj/item/evidencebag/proc/on_insert(datum/storage/storage, obj/item/to_insert, mob/user, force)
	SIGNAL_HANDLER

	update_weight_class(to_insert.w_class)

/obj/item/evidencebag/proc/on_remove(datum/storage/storage, obj/item/to_remove, atom/remove_to_loc, silent)
	SIGNAL_HANDLER

	if(!atom_storage.get_total_weight())
		update_weight_class(WEIGHT_CLASS_TINY)

/obj/item/evidencebag/attack_self(mob/user)
	if(!atom_storage.get_total_weight())
		to_chat(user, span_notice("[src] is empty."))
		return
	user.visible_message(span_notice("[user] empties [src]."), span_notice("You empty [src]."),\
	span_hear("You hear someone rustle around in a plastic bag, and remove something."))
	playsound(src,'sound/items/evidence_bag/evidence_bag_unzip.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, ignore_walls = FALSE)
	atom_storage.remove_all()

/obj/item/storage/box/evidence
	name = "evidence bag box"
	desc = "A box claiming to contain evidence bags."

/obj/item/storage/box/evidence/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/evidencebag(src)
