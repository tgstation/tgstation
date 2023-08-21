GLOBAL_LIST_INIT_TYPED(all_wound_pregen_data, /datum/wound_pregen_data, generate_wound_static_data())

/proc/generate_wound_static_data()
	RETURN_TYPE(/list/datum/wound_pregen_data)

	var/list/datum/wound_pregen_data/data = list()

	for (var/datum/wound_pregen_data/path as anything in typecacheof(path = /datum/wound_pregen_data, ignore_root_path = TRUE))
		if (initial(path.abstract))
			continue

		var/datum/wound_pregen_data/pregen_data = new path
		data[pregen_data.wound_path_to_generate] = pregen_data

	return data

// singleton instances
/datum/wound_pregen_data
	var/datum/wound/wound_path_to_generate

	var/abstract = FALSE

	var/required_limb_biostate
	var/check_for_any = FALSE

	var/duplicates_allowed = FALSE

	var/ignore_cannot_bleed = TRUE // a lot of bleed wounds should still be applied for purposes of mangling flesh

	var/list/viable_zones = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

/datum/wound_pregen_data/New()
	. = ..()

	if (!abstract)
		if (required_limb_biostate == null)
			stack_trace("required_limb_biostate null - please set it! occured on: [src.type]")
		if (wound_path_to_generate == null)
			stack_trace("wound_path_to_generate null - please set it! occured on: [src.type]")

// this proc is the primary reason this datum exists - a singleton instance so we can always run this proc even without the wound existing
/datum/wound_pregen_data/proc/can_be_applied_to(obj/item/bodypart/limb, wound_type, datum/wound/old_wound)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_BE_PURE(TRUE)

	if (!istype(limb) || !limb.owner)
		return FALSE

	if (HAS_TRAIT(limb.owner, TRAIT_NEVER_WOUNDED) || (limb.owner.status_flags & GODMODE))
		return FALSE

	if (wound_type != initial(wound_path_to_generate.wound_type))
		return
	else
		for (var/datum/wound/preexisting_wound as anything in limb.wounds)
			if (preexisting_wound.wound_series == initial(wound_path_to_generate.wound_series))
				if (preexisting_wound.severity >= initial(wound_path_to_generate.severity))
					return FALSE

	if (!ignore_cannot_bleed && ((required_limb_biostate & BIO_BLOODED) && !limb.can_bleed()))
		return FALSE

	if (check_for_any)
		if (!(limb.biological_state & required_limb_biostate))
			return FALSE
	else if (!((limb.biological_state & required_limb_biostate) == required_limb_biostate)) // check for all
		return FALSE

	if (!(limb.body_zone in viable_zones))
		return FALSE

	// we accept promotions and demotions, but no point in redundancy. This should have already been checked wherever the wound was rolled and applied for (see: bodypart damage code), but we do an extra check
	// in case we ever directly add wounds
	if (!duplicates_allowed)
		for (var/datum/wound/preexisting_wound as anything in limb.wounds)
			if (preexisting_wound.type == wound_path_to_generate && (preexisting_wound != old_wound))
				return FALSE
	return TRUE

/datum/wound_pregen_data/proc/generate_instance(obj/item/bodypart/limb, ...)
	RETURN_TYPE(/datum/wound)

	return new wound_path_to_generate

/datum/wound_pregen_data/Destroy(force, ...)
	stack_trace("[src], a singleton wound pregen data instance, was destroyed! This should not happen!")

	if (!force)
		return

	. = ..()

	GLOB.all_wound_pregen_data[wound_path_to_generate] = new src.type //recover
