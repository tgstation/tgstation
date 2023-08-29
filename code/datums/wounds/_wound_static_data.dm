// This datum is merely a singleton instance that allows for custom "can be applied" behaviors without instantiating a wound instance.
// For example: You can make a pregen_data subtype for your wound that overrides can_be_applied_to to only apply to specifically slimeperson limbs.
// Without this, youre stuck with very static initial variables.

GLOBAL_LIST_INIT_TYPED(all_wound_pregen_data, /datum/wound_pregen_data, generate_wound_static_data())

/proc/generate_wound_static_data()
	RETURN_TYPE(/list/datum/wound_pregen_data)

	var/list/datum/wound_pregen_data/data = list()

	for (var/datum/wound_pregen_data/path as anything in typecacheof(path = /datum/wound_pregen_data, ignore_root_path = TRUE))
		if (initial(path.abstract))
			continue

		if (!isnull(data[initial(path.wound_path_to_generate)]))
			stack_trace("pre-existing pregen data for [initial(path.wound_path_to_generate)] when [path] was being considered: [data[initial(path.wound_path_to_generate)]]. \
						this is definitely a bug, and is probably because one of the two pregen data have the wrong wound typepath defined. [path] will not be instantiated")

			continue

		var/datum/wound_pregen_data/pregen_data = new path
		data[pregen_data.wound_path_to_generate] = pregen_data

	return data

/// A singleton datum that holds pre-gen and static data about a wound. Each wound datum should have a corresponding wound_pregen_data.
/datum/wound_pregen_data
	/// The typepath of the wound we will be handling and storing data of. NECESSARY IF THIS IS A NON-ABSTRACT TYPE!
	var/datum/wound/wound_path_to_generate

	/// Will this be instantiated?
	var/abstract = FALSE

	/// If true, our wound can be selected in ordinary wound rolling. If this is set to false, our wound can only be directly instantiated by use of specific typepath.
	var/can_be_randomly_generated = TRUE

	/// A list of biostates a limb must have to receive our wound, in wounds.dm.
	var/required_limb_biostate
	/// If false, we will check if the limb has all of our required biostates instead of just any.
	var/check_for_any = FALSE

	/// If false, we will iterate through wounds on a given limb, and if any match our type, we wont add our wound.
	var/duplicates_allowed = FALSE

	/// If we require BIO_BLOODED, we will not add our wound if this is true and the limb cannot bleed.
	var/ignore_cannot_bleed = TRUE // a lot of bleed wounds should still be applied for purposes of mangling flesh

	/// A list of bodyzones we are applicable to.
	var/list/viable_zones = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

/datum/wound_pregen_data/New()
	. = ..()

	if (!abstract)
		if (required_limb_biostate == null)
			stack_trace("required_limb_biostate null - please set it! occured on: [src.type]")
		if (wound_path_to_generate == null)
			stack_trace("wound_path_to_generate null - please set it! occured on: [src.type]")

// this proc is the primary reason this datum exists - a singleton instance so we can always run this proc even without the wound existing
/**
 * Args:
 * * obj/item/bodypart/limb: The limb we are considering.
 * * wound_type: The type of the "wound acquisition attempt". Example: A slashing attack cannot proc a blunt wound, so wound_type = WOUND_SLASH would
 * fail if we expect WOUND_BLUNT. Defaults to the wound type we expect.
 * * datum/wound/old_wound: If we would replace a wound, this would be said wound. Nullable.
 * * random_roll = FALSE: If this is in the context of a random wound generation, and this wound wasn't specifically checked.
 *
 * Returns:
 * FALSE if the limb cannot be wounded, if wound_type is not ours, if we have a higher severity wound already in our series,
 * if we have a biotype mismatch, if the limb isnt in a viable zone, or if theres any duplicate wound types.
 * TRUE otherwise.
 */
/datum/wound_pregen_data/proc/can_be_applied_to(obj/item/bodypart/limb, wound_type = initial(wound_path_to_generate.wound_type), datum/wound/old_wound, random_roll = FALSE)
	SHOULD_BE_PURE(TRUE)

	if (!istype(limb) || !limb.owner)
		return FALSE

	if (random_roll && !can_be_randomly_generated)
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

	if (!biostate_valid(limb.biological_state))
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

/// Returns true if we have the given biostates, or any biostate in it if check_for_any is true. False otherwise.
/datum/wound_pregen_data/proc/biostate_valid(biostate)
	if (check_for_any)
		if (!(biostate & required_limb_biostate))
			return FALSE
	else if (!((biostate & required_limb_biostate) == required_limb_biostate)) // check for all
		return FALSE

	return TRUE

/// Returns a new instance of our wound datum.
/datum/wound_pregen_data/proc/generate_instance(obj/item/bodypart/limb, ...)
	RETURN_TYPE(/datum/wound)

	return new wound_path_to_generate

/datum/wound_pregen_data/Destroy(force, ...)
	stack_trace("[src], a singleton wound pregen data instance, was destroyed! This should not happen!")

	if (!force)
		return

	. = ..()

	GLOB.all_wound_pregen_data[wound_path_to_generate] = new src.type //recover
