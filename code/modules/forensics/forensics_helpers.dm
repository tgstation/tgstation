/// Adds a list of fingerprints to the atom
/atom/proc/add_fingerprint_list(list/fingerprints_to_add) //ASSOC LIST FINGERPRINT = FINGERPRINT
	if (QDELETED(src))
		return
	if (isnull(fingerprints_to_add))
		return
	if (forensics)
		forensics.inherit_new(fingerprints = fingerprints_to_add)
	else
		forensics = new(src, fingerprints = fingerprints_to_add)
	return TRUE

/// Adds a single fingerprint to the atom
/atom/proc/add_fingerprint(mob/suspect, ignoregloves = FALSE) //Set ignoregloves to add prints irrespective of the mob having gloves on.
	if (QDELETED(src))
		return
	if (isnull(forensics))
		forensics = new(src)
	forensics.add_fingerprint(suspect, ignoregloves)
	return TRUE

/// Add a list of fibers to the atom
/atom/proc/add_fiber_list(list/fibers_to_add) //ASSOC LIST FIBERTEXT = FIBERTEXT
	if (QDELETED(src))
		return
	if (isnull(fibers_to_add))
		return
	if (forensics)
		forensics.inherit_new(fibers = fibers_to_add)
	else
		forensics = new(src, fibers = fibers_to_add)
	return TRUE

/// Adds a single fiber to the atom
/atom/proc/add_fibers(mob/living/carbon/human/suspect)
	if (QDELETED(src))
		return
	var/old = 0
	if(suspect.gloves && istype(suspect.gloves, /obj/item/clothing))
		var/obj/item/clothing/gloves/suspect_gloves = suspect.gloves
		old = length(GET_ATOM_BLOOD_DNA(suspect_gloves))
		if(suspect_gloves.transfer_blood > 1) //bloodied gloves transfer blood to touched objects
			if(add_blood_DNA(GET_ATOM_BLOOD_DNA(suspect_gloves)) && GET_ATOM_BLOOD_DNA_LENGTH(suspect_gloves) > old) //only reduces the bloodiness of our gloves if the item wasn't already bloody
				suspect_gloves.transfer_blood -= 1
	else if(suspect.blood_in_hands > 1)
		old = length(GET_ATOM_BLOOD_DNA(suspect))
		if(add_blood_DNA(GET_ATOM_BLOOD_DNA(suspect)) && GET_ATOM_BLOOD_DNA_LENGTH(suspect) > old)
			suspect.blood_in_hands -= 1
	if (isnull(forensics))
		forensics = new(src)
	forensics.add_fibers(suspect)
	return TRUE

/// Adds a list of hiddenprints to the atom
/atom/proc/add_hiddenprint_list(list/hiddenprints_to_add) //NOTE: THIS IS FOR ADMINISTRATION FINGERPRINTS, YOU MUST CUSTOM SET THIS TO INCLUDE CKEY/REAL NAMES! CHECK FORENSICS.DM
	if (QDELETED(src))
		return
	if (isnull(hiddenprints_to_add))
		return
	if (forensics)
		forensics.inherit_new(hiddenprints = hiddenprints_to_add)
	else
		forensics = new(src, hiddenprints = hiddenprints_to_add)
	return TRUE

/// Adds a single hiddenprint to the atom
/atom/proc/add_hiddenprint(mob/suspect)
	if (QDELETED(src))
		return
	if (isnull(forensics))
		forensics = new(src)
	forensics.add_hiddenprint(suspect)
	return TRUE

/// Adds blood dna to the atom
/atom/proc/add_blood_DNA(list/blood_DNA_to_add) //ASSOC LIST DNA = BLOODTYPE
	return FALSE

/obj/add_blood_DNA(list/blood_DNA_to_add)
	if (QDELETED(src))
		return
	. = ..()
	if (isnull(blood_DNA_to_add))
		return .
	if (forensics)
		forensics.inherit_new(blood_DNA = blood_DNA_to_add)
	else
		forensics = new(src, blood_DNA = blood_DNA_to_add)
	return TRUE

/obj/item/add_blood_DNA(list/blood_DNA_to_add)
	if(item_flags & NO_BLOOD_ON_ITEM)
		return FALSE
	return ..()

/obj/item/clothing/gloves/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	transfer_blood = rand(2, 4)
	return ..()

/turf/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	var/obj/effect/decal/cleanable/blood/splatter/blood_splatter = locate() in src
	if(!blood_splatter)
		blood_splatter = new /obj/effect/decal/cleanable/blood/splatter(src, diseases)
	if(!QDELETED(blood_splatter))
		blood_splatter.add_blood_DNA(blood_dna) //give blood info to the blood decal.
		return TRUE //we bloodied the floor
	return FALSE

/turf/closed/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	return FALSE

/obj/item/clothing/under/add_blood_DNA(list/blood_DNA_to_add)
	. = ..()
	if(!.)
		return
	for(var/obj/item/clothing/accessory/thing_accessory as anything in attached_accessories)
		if(prob(66))
			continue
		thing_accessory.add_blood_DNA(blood_DNA_to_add)

/mob/living/carbon/human/add_blood_DNA(list/blood_DNA_to_add, list/datum/disease/diseases)
	return add_blood_DNA_to_items(blood_DNA_to_add)

/// Adds blood DNA to certain slots the mob is wearing
/mob/living/carbon/human/proc/add_blood_DNA_to_items(
	list/blood_DNA_to_add,
	target_flags = ITEM_SLOT_ICLOTHING|ITEM_SLOT_OCLOTHING|ITEM_SLOT_GLOVES|ITEM_SLOT_HEAD|ITEM_SLOT_MASK,
)
	if(QDELING(src))
		return FALSE
	if(!length(blood_DNA_to_add))
		return FALSE

	// Don't messy up our jumpsuit if we're got a coat
	if((target_flags & ITEM_SLOT_OCLOTHING) && (wear_suit?.body_parts_covered & CHEST))
		target_flags &= ~ITEM_SLOT_ICLOTHING

	var/dirty_hands = !!(target_flags & (ITEM_SLOT_GLOVES|ITEM_SLOT_HANDS))
	var/dirty_feet = !!(target_flags & ITEM_SLOT_FEET)
	var/slots_to_bloody = target_flags & ~check_obscured_slots()
	var/list/all_worn = get_equipped_items()
	for(var/obj/item/thing as anything in all_worn)
		if(thing.slot_flags & slots_to_bloody)
			thing.add_blood_DNA(blood_DNA_to_add)
		if(thing.body_parts_covered & HANDS)
			dirty_hands = FALSE
		if(thing.body_parts_covered & FEET)
			dirty_feet = FALSE

	if(slots_to_bloody & ITEM_SLOT_HANDS)
		for(var/obj/item/thing in held_items)
			thing.add_blood_DNA(blood_DNA_to_add)

	if(dirty_hands || dirty_feet || !length(all_worn))
		if(isnull(forensics))
			forensics = new(src)
		forensics.inherit_new(blood_DNA = blood_DNA_to_add)
		if(dirty_hands)
			blood_in_hands = rand(2, 4)
	update_clothing(slots_to_bloody)
	return TRUE

/*
 * Transfer all the fingerprints and hidden prints from [src] to [transfer_to].
 */
/atom/proc/transfer_fingerprints_to(atom/transfer_to)
	transfer_to.add_fingerprint_list(GET_ATOM_FINGERPRINTS(src))
	transfer_to.add_hiddenprint_list(GET_ATOM_HIDDENPRINTS(src))
	transfer_to.fingerprintslast = fingerprintslast

/*
 * Transfer all the fibers from [src] to [transfer_to].
 */
/atom/proc/transfer_fibers_to(atom/transfer_to)
	transfer_to.add_fiber_list(GET_ATOM_FIBRES(src))
