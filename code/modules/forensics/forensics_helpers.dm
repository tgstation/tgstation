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
		old = GET_ATOM_BLOOD_DNA_LENGTH(suspect_gloves)
		if(suspect_gloves.transfer_blood > 1) //bloodied gloves transfer blood to touched objects
			if(add_blood_DNA(GET_ATOM_BLOOD_DNA(suspect_gloves)) && GET_ATOM_BLOOD_DNA_LENGTH(suspect_gloves) > old) //only reduces the bloodiness of our gloves if the item wasn't already bloody
				suspect_gloves.transfer_blood -= 1
	else if(suspect.blood_in_hands > 1)
		old = GET_ATOM_BLOOD_DNA_LENGTH(suspect)
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

/// Fetch current blood color
/atom/proc/get_blood_dna_color()
	if (cached_blood_color)
		return cached_blood_color

	var/list/blood_DNA = GET_ATOM_BLOOD_DECALS(src)
	if (!length(blood_DNA))
		return

	cached_blood_color = get_color_from_blood_list(blood_DNA)
	return cached_blood_color

/// Check if we have any emissive blood on us
/// is_worn - When TRUE, we're fetching the value for mob overlays, in which case we bypass the cache
/atom/proc/get_blood_emissive_alpha(is_worn = FALSE)
	if (cached_blood_emissive && !is_worn)
		return cached_blood_emissive

	var/list/blood_DNA = GET_ATOM_BLOOD_DECALS(src)
	if (!length(blood_DNA))
		return 0

	var/blood_alpha = 0
	for (var/blood_key in blood_DNA)
		var/datum/blood_type/blood_type = blood_DNA[blood_key]
		blood_alpha += blood_type.get_emissive_alpha(src, is_worn)

	blood_alpha /= length(blood_DNA)
	if (!is_worn)
		cached_blood_emissive = blood_alpha
	return blood_alpha

/// Adds blood dna to the atom
/atom/proc/add_blood_DNA(list/blood_DNA_to_add, list/datum/disease/diseases) //ASSOC LIST DNA = BLOODTYPE
	return FALSE

/obj/add_blood_DNA(list/blood_DNA_to_add, list/datum/disease/diseases)
	if (QDELETED(src))
		return
	. = ..()
	if (isnull(blood_DNA_to_add))
		return .
	if (!islist(blood_DNA_to_add))
		CRASH("add_blood_DNA on [src] ([type]) has been passed a non-list blood_DNA_to_add ([blood_DNA_to_add])!")
	for (var/blood_key in blood_DNA_to_add)
		if (isnull(blood_DNA_to_add[blood_key]))
			CRASH("add_blood_DNA on [src] ([type]) has been passed bad blood_DNA_to_add ([blood_key] - [blood_DNA_to_add[blood_key]] key-value pair)!")
	cached_blood_color = null
	cached_blood_emissive = null
	if (forensics)
		forensics.inherit_new(blood_DNA = blood_DNA_to_add)
	else
		forensics = new(src, blood_DNA = blood_DNA_to_add)
	return TRUE

/obj/effect/decal/cleanable/blood/add_blood_DNA(list/blood_DNA_to_add, list/datum/disease/diseases)
	var/first_dna = GET_ATOM_BLOOD_DNA_LENGTH(src)
	if(!..())
		return FALSE
	if(dried)
		return TRUE
	// Imperfect, ends up with some blood types being double-set-up, but harmless (for now)
	for(var/blood_key in blood_DNA_to_add)
		var/datum/blood_type/blood_type = blood_DNA_to_add[blood_key]
		// We shouldn't ever get no valid blood types with BLOOD_COVER_TURFS and first_dna == 0 here so we're safe
		if(blood_type.blood_flags & BLOOD_COVER_TURFS)
			blood_type.set_up_blood(src, first_dna == 0)
	add_diseases(diseases)
	update_appearance()
	add_atom_colour(get_blood_dna_color(), FIXED_COLOUR_PRIORITY)
	return TRUE

/obj/item/add_blood_DNA(list/blood_DNA_to_add, list/datum/disease/diseases)
	if(item_flags & NO_BLOOD_ON_ITEM)
		return FALSE
	return ..()

/obj/item/clothing/gloves/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	. = ..()
	if (. && has_blood_flag(blood_dna, BLOOD_COVER_ITEMS))
		transfer_blood = min(transfer_blood, rand(2, 4))

/turf/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	var/obj/effect/decal/cleanable/blood/splatter/blood_splatter = locate() in src
	var/blood_flags = has_blood_flag(blood_dna, BLOOD_COVER_TURFS|BLOOD_ADD_DNA|BLOOD_TRANSFER_VIRAL_DATA)
	if(!blood_splatter)
		if(blood_flags & BLOOD_COVER_TURFS)
			blood_splatter = new /obj/effect/decal/cleanable/blood/splatter(src, diseases, blood_dna)
	else
		if(blood_flags & BLOOD_ADD_DNA)
			blood_splatter.add_blood_DNA(blood_dna)
		if(blood_flags & BLOOD_TRANSFER_VIRAL_DATA)
			blood_splatter.add_diseases(diseases)
	return !QDELETED(blood_splatter) ? blood_splatter : null

/turf/closed/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	return FALSE

/obj/item/clothing/under/add_blood_DNA(list/blood_DNA_to_add, list/datum/disease/diseases)
	. = ..()
	if(!.)
		return
	for(var/obj/item/clothing/accessory/thing_accessory as anything in attached_accessories)
		if(prob(66))
			continue
		thing_accessory.add_blood_DNA(blood_DNA_to_add)

/mob/living/carbon/human/add_blood_DNA(list/blood_DNA_to_add, list/datum/disease/diseases)
	return add_blood_DNA_to_items(blood_DNA_to_add, diseases = diseases)

/// Adds blood DNA to certain slots the mob is wearing
/mob/living/carbon/human/proc/add_blood_DNA_to_items(
	list/blood_DNA_to_add,
	target_flags = ITEM_SLOT_ICLOTHING|ITEM_SLOT_OCLOTHING|ITEM_SLOT_GLOVES|ITEM_SLOT_HEAD|ITEM_SLOT_MASK,
	list/datum/disease/diseases,
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
	var/slots_to_bloody = target_flags & ~check_covered_slots()
	var/list/all_worn = get_equipped_items()
	for(var/obj/item/thing as anything in all_worn)
		if(thing.slot_flags & slots_to_bloody)
			thing.add_blood_DNA(blood_DNA_to_add, diseases)
		if(thing.body_parts_covered & HANDS)
			dirty_hands = FALSE
		if(thing.body_parts_covered & FEET)
			dirty_feet = FALSE

	if(slots_to_bloody & ITEM_SLOT_HANDS)
		for(var/obj/item/thing in held_items)
			thing.add_blood_DNA(blood_DNA_to_add)

	cached_blood_color = null
	cached_blood_emissive = null
	if(!has_blood_flag(blood_DNA_to_add, BLOOD_COVER_MOBS))
		update_clothing(slots_to_bloody)
		return

	if(dirty_hands || dirty_feet || !length(all_worn))
		if(isnull(forensics))
			forensics = new(src)
		forensics.inherit_new(blood_DNA = blood_DNA_to_add)

	if(dirty_hands)
		blood_in_hands = min(blood_in_hands, rand(2, 4))

	if(dirty_feet)
		AddComponent(/datum/component/bloodysoles/feet, blood_DNA_to_add) // Add blood to our feet

	update_clothing(slots_to_bloody)
	return TRUE

/mob/living/add_blood_DNA(list/blood_DNA_to_add, list/datum/disease/diseases)
	if(QDELING(src))
		return FALSE
	if(!length(blood_DNA_to_add))
		return FALSE
	if(isnull(forensics))
		forensics = new(src)
	cached_blood_color = null
	cached_blood_emissive = null
	forensics.inherit_new(blood_DNA = blood_DNA_to_add)
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
