
/obj/item/clothing/glasses/science
	///are we toggled
	var/toggled = FALSE

/obj/item/clothing/glasses/science/attack_self(mob/user, modifiers)
	. = ..()
	toggled = !toggled
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human = user
	if(toggled && human.glasses == src)
		enable(user)

/obj/item/clothing/glasses/science/proc/enable(mob/M)
	if (toggled)
		GLOB.science_goggles_wearers.Add(M)
		/*
		for (var/obj/item/I in infected_items)
			if (I.pathogen)
				M.client.images |= I.pathogen
		for (var/mob/living/L in infected_contact_mobs)
			if (L.pathogen)
				M.client.images |= L.pathogen\
		*/
		for (var/obj/effect/pathogen_cloud/C as anything in GLOB.pathogen_clouds)
			if (C.pathogen)
				M.client.images |= C.pathogen
		/*
		for (var/obj/effect/decal/cleanable/C in infected_cleanables)
			if (C.pathogen)
				M.client.images |= C.pathogen
		*/

/obj/item/clothing/glasses/science/proc/disable(mob/M)
	GLOB.science_goggles_wearers.Remove(M)
	/*
	for (var/obj/item/I in infected_items)
		M.client.images -= I.pathogen
	for (var/mob/living/L in infected_contact_mobs)
		M.client.images -= L.pathogen
	*/
	for(var/obj/effect/pathogen_cloud/C as anything in GLOB.pathogen_clouds)
		M.client.images -= C.pathogen
	/*
	for (var/obj/effect/decal/cleanable/C in infected_cleanables)
		M.client.images -= C.pathogen
	*/

/obj/item/clothing/glasses/science/equipped(mob/M, slot)
	..()
	if(slot != ITEM_SLOT_EYES)
		return
	if(toggled)
		enable(M)
		RegisterSignal(M, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(clear_effects))


/obj/item/clothing/glasses/science/proc/clear_effects(mob/living/source, obj/item/dropped_item)
	SIGNAL_HANDLER

	if (!source.client)
		return
	disable(source)
	UnregisterSignal(source, list(COMSIG_MOB_UNEQUIPPED_ITEM))
