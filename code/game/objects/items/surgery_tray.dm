/**
 * surgery trays
 *
 * a storage object that displays tools in its contents, and can be folded up and carried. click it to draw a random tool
 *
 */


/datum/storage/medicart
	max_total_storage = 30
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_slots = 14

/datum/storage/medicart/New()
	. = ..()
	set_holdable(list(
		/obj/item/blood_filter,
		/obj/item/bonesetter,
		/obj/item/cautery,
		/obj/item/circular_saw,
		/obj/item/clothing/mask/surgical,
		/obj/item/hemostat,
		/obj/item/razor,
		/obj/item/retractor,
		/obj/item/scalpel,
		/obj/item/stack/medical/bone_gel,
		/obj/item/stack/sticky_tape/surgical,
		/obj/item/surgical_drapes,
		/obj/item/surgicaldrill,
	))

/obj/item/surgery_tray
	name = "surgery tray"
	desc = "A Deforest brand medical cart. It is a folding model, meaning the wheels on the bottom can be retracted and the body used as a tray."
	icon = 'icons/obj/medicart.dmi'
	icon_state = "tray"
	w_class = WEIGHT_CLASS_BULKY
	slowdown = 1
	item_flags = SLOWS_WHILE_IN_HAND

	var/tray_toggled = TRUE

	var/obj/item/stack/medical/bone_gel/bone_gel
	var/obj/item/stack/sticky_tape/surgical/surgical_tape
	var/obj/item/blood_filter/blood_filter

	var/obj/item/razor/surgery/razor
	var/obj/item/bonesetter/bonesetter
	var/obj/item/surgical_drapes/surgical_drapes

	var/obj/item/surgicaldrill/surgical_drill
	var/obj/item/cautery/cautery
	var/obj/item/circular_saw/circular_saw
	var/obj/item/hemostat/hemostat
	var/obj/item/retractor/retractor
	var/obj/item/scalpel/scalpel

/obj/item/surgery_tray/deployed
	tray_toggled = FALSE

/obj/item/surgery_tray/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/medicart)
	PopulateContents()
	AddElement(/datum/element/noisy_movement)
	AddElement(/datum/element/drag_pickup)
	set_tray_mode(tray_toggled)
	register_context()

/obj/item/surgery_tray/Destroy(force)
	QDEL_NULL(bone_gel)
	QDEL_NULL(surgical_tape)
	QDEL_NULL(razor)
	QDEL_NULL(blood_filter)
	QDEL_NULL(bonesetter)
	QDEL_NULL(surgical_drapes)
	QDEL_NULL(surgical_drill)
	QDEL_NULL(cautery)
	QDEL_NULL(circular_saw)
	QDEL_NULL(hemostat)
	QDEL_NULL(retractor)
	QDEL_NULL(scalpel)
	return ..()

/obj/item/surgery_tray/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_LMB] = "Fumble with tools"
	context[SCREENTIP_CONTEXT_RMB] = "Remove a specific tool"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/surgery_tray/update_icon_state()
	. = ..()
	icon_state = tray_toggled ? "tray" : "medicart"

/obj/item/surgery_tray/update_desc()
	. = ..()
	if(tray_toggled)
		desc = "The wheels and bottom storage of this medical cart have been stowed away, \
			leaving a cumbersome tray in it's place."
	else
		desc = "A Deforest brand medical cart. It is a folding model, meaning the wheels on the \
			bottom can be retracted and the body used as a tray."

/obj/item/surgery_tray/update_overlays()
	. = ..()
	if(surgical_drapes)
		. |= "drapes"
	if(blood_filter)
		. += "filter"
	if(razor)
		. += "razor"
	if(bonesetter)
		. += tray_toggled ? "bonesetter_out" : "bonesetter"
	if(surgical_tape)
		. += tray_toggled ? "tape_out" : "tape"
	if(bone_gel)
		. += tray_toggled ? "gel_out" : "gel"

	if(scalpel)
		switch(scalpel.type)
			if(/obj/item/scalpel/alien)
				. += "scalpel_alien"
			if(/obj/item/scalpel/advanced)
				. += "scalpel_advanced"
			if(/obj/item/scalpel/cruel)
				. += "scalpel_cruel"
			else
				. += "scalpel_normal"
	if(cautery)
		switch(cautery.type)
			if(/obj/item/cautery/alien)
				. += "cautery_alien"
			if(/obj/item/cautery/advanced)
				. += "cautery_advanced"
			if(/obj/item/cautery/cruel)
				. += "cautery_cruel"
			else
				. += "cautery_normal"
	if(hemostat)
		switch(hemostat.type)
			if(/obj/item/hemostat/alien)
				. += "hemostat_alien"
			if(/obj/item/hemostat/cruel)
				. += "hemostat_cruel"
			else
				. += "hemostat_normal"
	if(retractor)
		switch(retractor.type)
			if(/obj/item/retractor/alien)
				. += "retractor_alien"
			if(/obj/item/retractor/advanced)
				. += "retractor_advanced"
			if(/obj/item/retractor/cruel)
				. += "retractor_cruel"
			else
				. += "retractor_normal"
	if(surgical_drill)
		switch(surgical_drill.type)
			if(/obj/item/surgicaldrill/alien)
				. += "drill_alien"
			else
				. += "drill_normal"
	if(circular_saw)
		switch(circular_saw.type)
			if(/obj/item/circular_saw/alien)
				. += "saw_alien"
			else
				. += "saw_normal"

/obj/item/surgery_tray/Entered(obj/item/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(istype(arrived, /obj/item/blood_filter))
		if(blood_filter && blood_filter.toolspeed <= arrived.toolspeed)
			return
		blood_filter = arrived
	else if(istype(arrived, /obj/item/cautery))
		if(cautery && cautery.toolspeed <= arrived.toolspeed)
			return
		cautery = arrived
	else if(istype(arrived, /obj/item/circular_saw))
		if(circular_saw && circular_saw.toolspeed <= arrived.toolspeed)
			return
		circular_saw = arrived
	else if(istype(arrived, /obj/item/hemostat))
		if(hemostat && hemostat.toolspeed <= arrived.toolspeed)
			return
		hemostat = arrived
	else if(istype(arrived, /obj/item/surgicaldrill))
		if(surgical_drill && surgical_drill.toolspeed <= arrived.toolspeed)
			return
		surgical_drill = arrived
	else if(istype(arrived, /obj/item/retractor))
		if(retractor && retractor.toolspeed <= arrived.toolspeed)
			return
		retractor = arrived
	else if(istype(arrived, /obj/item/scalpel))
		if(scalpel && scalpel.toolspeed <= arrived.toolspeed)
			return
		scalpel = arrived
	else if(istype(arrived, /obj/item/bonesetter))
		if(bonesetter)
			return
		bonesetter = arrived
	else if(istype(arrived, /obj/item/razor))
		if(razor)
			return
		razor = arrived
	else if(istype(arrived, /obj/item/stack/medical/bone_gel))
		if(bone_gel)
			return
		bone_gel = arrived
	else if(istype(arrived, /obj/item/stack/sticky_tape/surgical))
		if(surgical_tape)
			return
		surgical_tape = arrived
	else if(istype(arrived, /obj/item/surgical_drapes))
		if(surgical_drapes)
			return
		surgical_drapes = arrived

/obj/item/surgery_tray/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == blood_filter)
		var/obj/item/blood_filter/other_filter = locate() in contents
		blood_filter = other_filter || null
	else if(gone == bonesetter)
		var/obj/item/bonesetter/other_bonesetter = locate() in contents
		bonesetter = other_bonesetter || null
	else if(gone == cautery)
		var/obj/item/cautery/other_cautery = locate() in contents
		cautery = other_cautery || null
	else if(gone == circular_saw)
		var/obj/item/circular_saw/other_saw = locate() in contents
		circular_saw = other_saw || null
	else if(gone == hemostat)
		var/obj/item/hemostat/other_hemostat = locate() in contents
		hemostat = other_hemostat || null
	else if(gone == razor)
		var/obj/item/razor/other_razor = locate() in contents
		razor = other_razor || null
	else if(gone == surgical_drill)
		var/obj/item/surgicaldrill/other_drill = locate() in contents
		surgical_drill = other_drill || null
	else if(gone == retractor)
		var/obj/item/retractor/other_retractor = locate() in contents
		retractor = other_retractor || null
	else if(gone == bone_gel)
		var/obj/item/stack/medical/bone_gel/other_gel = locate() in contents
		bone_gel = other_gel || null
	else if(gone == surgical_tape)
		var/obj/item/stack/sticky_tape/other_tape = locate() in contents
		surgical_tape = other_tape || null
	else if(gone == surgical_drapes)
		var/obj/item/surgical_drapes/other_drapes = locate() in contents
		surgical_drapes = other_drapes || null

/obj/item/surgery_tray/proc/PopulateContents()
	blood_filter = new(src)
	bonesetter = new(src)
	razor = new(src)
	if(!cautery)
		cautery = new(src)
	if(!hemostat)
		hemostat = new(src)
	if(!retractor)
		retractor = new(src)
	if(!scalpel)
		scalpel = new(src)
	circular_saw = new(src)
	bone_gel = new(src)
	surgical_tape = new(src)
	surgical_drapes = new(src)
	surgical_drill = new(src)
	var/static/list/items_inside = list(
		/obj/item/clothing/mask/surgical = 1,
	)
	generate_items_inside(items_inside, src)

///Sets the surgery tray's deployment state. Silent if user is null.
/obj/item/surgery_tray/proc/set_tray_mode(new_mode, mob/user)
	tray_toggled = new_mode
	density = !tray_toggled

	if(user)
		user.visible_message(span_notice("[user] [tray_toggled ? "retracts" : "extends"] [src]'s wheels."), span_notice("You [tray_toggled ? "retract" : "extend"] [src]'s wheels."))

	if(tray_toggled)
		interaction_flags_item |= INTERACT_ITEM_ATTACK_HAND_PICKUP
		pass_flags |= PASSTABLE
	else
		interaction_flags_item &= ~INTERACT_ITEM_ATTACK_HAND_PICKUP
		pass_flags &= ~PASSTABLE

	update_appearance()

/obj/item/surgery_tray/equipped(mob/user, slot, initial)
	. = ..()
	if(!tray_toggled)
		set_tray_mode(TRUE, user)

/obj/item/surgery_tray/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return
	var/turf/open/placement_turf = get_turf(user)
	if(isgroundlessturf(placement_turf) || isclosedturf(placement_turf))
		balloon_alert(user, "can't deploy!")
		return TRUE
	if(!user.transferItemToLoc(src, placement_turf))
		balloon_alert(user, "tray stuck!")
		return TRUE
	set_tray_mode(FALSE, user)
	return

/obj/item/surgery_tray/attack_hand(mob/living/user)
	if(!user.can_perform_action(src, NEED_HANDS))
		return ..()
	var/obj/item/grabbies = pick(contents)
	if(grabbies)
		atom_storage.remove_single(user, grabbies, drop_location())
		user.put_in_hands(grabbies)
	return TRUE

/obj/item/surgery_tray/morgue
	name = "autopsy tray"
	desc = "A Deforest brand surgery tray, made for use in morgues. It is a folding model, \
		meaning the wheels on the bottom can be extended outwards, making it a cart."

/obj/item/surgery_tray/morgue/PopulateContents()
	cautery = new /obj/item/cautery/cruel(src)
	hemostat = new /obj/item/hemostat/cruel(src)
	retractor = new /obj/item/retractor/cruel(src)
	scalpel = new /obj/item/scalpel/cruel(src)
	return ..()
