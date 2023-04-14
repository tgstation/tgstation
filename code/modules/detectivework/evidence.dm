//CONTAINS: Evidence bags

/obj/item/evidencebag
	name = "evidence bag"
	desc = "An empty evidence bag."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "evidenceobj"
	inhand_icon_state = ""
	w_class = WEIGHT_CLASS_TINY
	var/can_take_items_out = TRUE

/obj/item/evidencebag/afterattack(obj/item/target, mob/user,proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || loc == target)
		return
	evidencebagEquip(target, user)
	return . | AFTERATTACK_PROCESSED_ITEM

/obj/item/evidencebag/attackby(obj/item/attacking_item, mob/user, params)
	if(evidencebagEquip(attacking_item, user))
		return TRUE

/obj/item/evidencebag/handle_atom_del(atom/deleting_atom)
	cut_overlays()
	w_class = initial(w_class)
	icon_state = initial(icon_state)
	desc = initial(desc)

/obj/item/evidencebag/proc/evidencebagEquip(obj/item/stored, mob/user)
	if(!istype(stored) || stored.anchored)
		return

	if(loc.atom_storage && stored.atom_storage)
		to_chat(user, span_warning("No matter what way you try, you can't get [stored] to fit inside [src]."))
		return TRUE //begone infinite storage ghosts, begone from me

	if(HAS_TRAIT(stored, TRAIT_NO_STORAGE_INSERT))
		to_chat(user, span_warning("No matter what way you try, you can't get [stored] to fit inside [src]."))
		return TRUE

	if(istype(stored, /obj/item/evidencebag))
		to_chat(user, span_warning("You find putting an evidence bag in another evidence bag to be slightly absurd."))
		return TRUE //now this is podracing

	if(loc in stored.get_all_contents()) // fixes tg #39452, evidence bags could store their own location, causing I to be stored in the bag while being present inworld still, and able to be teleported when removed.
		to_chat(user, span_warning("You find putting [stored] in [src] while it's still inside it quite difficult!"))
		return

	if(stored.w_class > WEIGHT_CLASS_NORMAL)
		to_chat(user, span_warning("[stored] won't fit in [src]!"))
		return

	if(contents.len)
		to_chat(user, span_warning("[src] already has something inside it!"))
		return

	if(!isturf(stored.loc)) //If it isn't on the floor. Do some checks to see if it's in our hands or a box. Otherwise give up.
		if(stored.loc.atom_storage) //in a container.
			stored.loc.atom_storage.remove_single(user, stored, src)
		if(!user.dropItemToGround(stored))
			return

	user.visible_message(span_notice("[user] puts [stored] into [src]."), span_notice("You put [stored] inside [src]."),\
	span_hear("You hear a rustle as someone puts something into a plastic bag."))

	icon_state = "evidence"

	var/mutable_appearance/in_evidence = new(stored)
	in_evidence.plane = FLOAT_PLANE
	in_evidence.layer = FLOAT_LAYER
	in_evidence.pixel_x = 0
	in_evidence.pixel_y = 0
	add_overlay(in_evidence)
	add_overlay("evidence") //should look nicer for transparent stuff. not really that important, but hey.

	desc = "An evidence bag containing [stored]. [stored.desc]"
	stored.forceMove(src)
	w_class = stored.w_class
	return TRUE

/obj/item/evidencebag/attack_self(mob/user)
	if(!can_take_items_out)
		return
	if(contents.len)
		var/obj/item/stored_item = contents[1]
		user.visible_message(span_notice("[user] takes [stored_item] out of [src]."), span_notice("You take [stored_item] out of [src]."),\
		span_hear("You hear someone rustle around in a plastic bag, and remove something."))
		cut_overlays() //remove the overlays
		user.put_in_hands(stored_item)
		w_class = WEIGHT_CLASS_TINY
		icon_state = "evidenceobj"
		desc = "An empty evidence bag."

	else
		to_chat(user, span_notice("[src] is empty."))
		icon_state = "evidenceobj"
	return

/obj/item/storage/box/evidence
	name = "evidence bag box"
	desc = "A box claiming to contain evidence bags."

/obj/item/storage/box/evidence/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/evidencebag(src)
