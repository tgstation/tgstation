/obj/item/clothing/glasses/science/proc/enable(mob/M)
	M.virusView()

/obj/item/clothing/glasses/science/proc/disable(mob/M)
	M.stopvirusView()

/obj/item/clothing/glasses/science/equipped(mob/M, slot)
	..()
	if(slot != ITEM_SLOT_EYES)
		return
	enable(M)
	RegisterSignal(M, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(clear_effects))

/obj/item/clothing/glasses/science/proc/clear_effects(mob/living/source, obj/item/dropped_item)
	SIGNAL_HANDLER
	if(dropped_item != src)
		return

	if (!source.client)
		return
	disable(source)
	UnregisterSignal(source, list(COMSIG_MOB_UNEQUIPPED_ITEM))

/mob/proc/virusView()
	if(!client)
		return
	GLOB.science_goggles_wearers.Add(src)
	for (var/obj/item/I in GLOB.infected_items)
		if (I.pathogen)
			client.images |= I.pathogen
	for (var/mob/living/L in GLOB.infected_contact_mobs)
		if (L.pathogen)
			client.images |= L.pathogen
	for (var/obj/effect/pathogen_cloud/C as anything in GLOB.pathogen_clouds)
		if (C.pathogen)
			client.images |= C.pathogen
	for (var/obj/effect/decal/cleanable/C in GLOB.infected_cleanables)
		if (C.pathogen)
			client.images |= C.pathogen

/mob/proc/stopvirusView()
	if(!client)
		return
	GLOB.science_goggles_wearers.Remove(src)
	for (var/obj/item/I in GLOB.infected_items)
		client.images -= I.pathogen
	for (var/mob/living/L in GLOB.infected_contact_mobs)
		client.images -= L.pathogen
	for(var/obj/effect/pathogen_cloud/C as anything in GLOB.pathogen_clouds)
		client.images -= C.pathogen
	for (var/obj/effect/decal/cleanable/C in GLOB.infected_cleanables)
		client.images -= C.pathogen
