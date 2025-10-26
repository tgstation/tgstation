// This datum is merely a singleton instance that allows for custom "can be applied" behaviors without instantiating a wound instance.
// For example: You can make a pregen_data subtype for your wound that overrides can_be_applied_to to only apply to specifically slimeperson limbs.
// Without this, you're stuck with very static initial variables.

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
	var/require_any_biostate = FALSE

	/// If false, we will iterate through wounds on a given limb, and if any match our type, we wont add our wound.
	var/duplicates_allowed = FALSE

	/// If we require BIO_BLOODED, we will not add our wound if this is true and the limb cannot bleed.
	var/ignore_cannot_bleed = TRUE // a lot of bleed wounds should still be applied for purposes of mangling flesh

	/// A list of bodyzones we are applicable to.
	var/list/viable_zones = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	/// The type of attack that can generate this wound.
	/// E.g. WOUND_SLASH = A sharp attack can cause this, WOUND_BLUNT = an attack with no sharpness/an attack with sharpness against a limb with mangled exterior can cause this.
	var/required_wounding_type

	/// The weight that will be used if, by the end of wound selection, there are multiple valid wounds. This will be inserted into pick_weight, so use integers.
	var/weight = WOUND_DEFAULT_WEIGHT

	/// The minimum injury roll a attack must get to generate us. Affected by our wound's threshold_penalty and series_threshold_penalty, as well as the attack's wound_bonus. See check_wounding_mods().
	var/threshold_minimum

	/// The series of wounds this is in. See wounds.dm (the defines file) for a more detailed explanation - but tldr is that no 2 wounds of the same series can be on a limb.
	var/wound_series

	/// If true, we will attempt to, during a random wound roll, overpower and remove other wound typepaths from the possible wounds list using competition_mode.
	var/compete_for_wounding = TRUE
	/// The competition mode with which we will remove other wounds from a possible wound roll assuming [compete_for_wounding] is TRUE. See wounds.dm, the defines file, for more information on what these do.
	var/competition_mode = WOUND_COMPETITION_OVERPOWER_LESSERS

	/// A list of BIO_ defines that will be iterated over in order to determine the scar file our wound will generate.
	/// Use generate_scar_priorities to create a custom list.
	var/list/scar_priorities

/datum/wound_pregen_data/New()
	. = ..()

	if (!abstract)
		if (required_limb_biostate == null)
			stack_trace("required_limb_biostate null - please set it! occurred on: [src.type]")
		if (wound_path_to_generate == null)
			stack_trace("wound_path_to_generate null - please set it! occurred on: [src.type]")

	scar_priorities = generate_scar_priorities()

/// Should return a list of BIO_ biostate priorities, in order. See [scar_priorities] for further documentation.
/datum/wound_pregen_data/proc/generate_scar_priorities()
	RETURN_TYPE(/list)

	var/list/priorities = list(
		"[BIO_FLESH]",
		"[BIO_BONE]",
	)

	return priorities

// this proc is the primary reason this datum exists - a singleton instance so we can always run this proc even without the wound existing
/**
 * Args:
 * * obj/item/bodypart/limb: The limb we are considering.
 * * suggested_wounding_typs: The wounding type to be checked against the wounding type we require. Defaults to required_wounding_type.
 * * datum/wound/old_wound: If we would replace a wound, this would be said wound. Nullable.
 * * random_roll = FALSE: If this is in the context of a random wound generation, and this wound wasn't specifically checked.
 *
 * Returns:
 * FALSE if the limb cannot be wounded, if the wounding types don't match ours (via wounding_types_valid()), if we have a higher severity wound already in our series,
 * if we have a biotype mismatch, if the limb isn't in a viable zone, or if there's any duplicate wound types.
 * TRUE otherwise.
 */
/datum/wound_pregen_data/proc/can_be_applied_to(obj/item/bodypart/limb, suggested_wounding_type = required_wounding_type, datum/wound/old_wound, random_roll = FALSE, duplicates_allowed = src.duplicates_allowed, care_about_existing_wounds = TRUE)
	SHOULD_BE_PURE(TRUE)

	if (!istype(limb))
		return FALSE

	if (random_roll && !can_be_randomly_generated)
		return FALSE

	if (!wounding_types_valid(suggested_wounding_type))
		return FALSE

	if (care_about_existing_wounds)
		for (var/datum/wound/preexisting_wound as anything in limb.wounds)
			var/datum/wound_pregen_data/pregen_data = GLOB.all_wound_pregen_data[preexisting_wound.type]
			if (pregen_data.wound_series == wound_series)
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
	if (require_any_biostate)
		if (!(biostate & required_limb_biostate))
			return FALSE
	else if (!((biostate & required_limb_biostate) == required_limb_biostate)) // check for all
		return FALSE

	return TRUE

/**
 * A simple getter for [weight], with arguments supplied to allow custom behavior.
 *
 * Args:
 * * obj/item/bodypart/limb: The limb we are contemplating being added to. Nullable.
 * * woundtype: The woundtype of the assumed attack that would generate us. Nullable.
 * * damage: The raw damage that would cause us. Nullable.
 * * attack_direction: The direction of the attack that'd cause us. Nullable.
 * * damage_source: The entity that would cause us. Nullable.
 *
 * Returns:
 * Our weight.
 */
/datum/wound_pregen_data/proc/get_weight(obj/item/bodypart/limb, woundtype, damage, attack_direction, damage_source)
	return weight

/// Returns TRUE if we use WOUND_ALL or our wounding type
/datum/wound_pregen_data/proc/wounding_types_valid(suggested_wounding_type)
	if (required_wounding_type == WOUND_ALL)
		return TRUE
	return suggested_wounding_type == required_wounding_type

/**
 * A simple getter for [threshold_minimum], with arguments supplied to allow custom behavior.
 *
 * Args:
 * * obj/item/bodypart/part: The limb we are contemplating being added to.
 * * attack_direction: The direction of the attack that'd generate us. Nullable.
 * * damage_source: The source of the damage that'd cause us. Nullable.
 */
/datum/wound_pregen_data/proc/get_threshold_for(obj/item/bodypart/part, attack_direction, damage_source)
	return threshold_minimum

/// Returns a new instance of our wound datum.
/datum/wound_pregen_data/proc/generate_instance(obj/item/bodypart/limb, ...)
	RETURN_TYPE(/datum/wound)

	return new wound_path_to_generate

/datum/wound_pregen_data/Destroy(force)
	var/error_message = "[src], a singleton wound pregen data instance, was destroyed! This should not happen!"
	if (force)
		error_message += " NOTE: This Destroy() was called with force == TRUE. This instance will be deleted and replaced with a new one."
	stack_trace(error_message)

	if (!force)
		return QDEL_HINT_LETMELIVE

	. = ..()

	GLOB.all_wound_pregen_data[wound_path_to_generate] = new src.type //recover
