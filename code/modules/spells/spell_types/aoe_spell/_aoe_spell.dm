/**
 * ## AOE spells
 *
 * A spell that iterates over atoms near the caster and casts a spell on them.
 * Calls cast_on_thing_in_aoe on all atoms returned by get_things_to_cast_on by default.
 */
/datum/action/cooldown/spell/aoe
	/// The max amount of targets we can affect via our AOE. 0 = unlimited
	var/max_targets = 0
	/// Should we shuffle the targets lift after getting them via get_things_to_cast_on?
	var/shuffle_targets_list = FALSE
	/// The radius of the aoe.
	var/aoe_radius = 7

/datum/action/cooldown/spell/aoe/is_valid_target(atom/cast_on)
	return isturf(cast_on.loc)

// At this point, cast_on == owner. Either works.
// Don't extend this for your spell! Look at cast_on_thing_in_aoe.
/datum/action/cooldown/spell/aoe/cast(atom/cast_on)
	. = ..()
	// Get every atom around us to our aoe cast on
	var/list/atom/things_to_cast_on = get_things_to_cast_on(cast_on)
	// If set, shuffle the list of things we're going to cast on to remove any existing order
	if(shuffle_targets_list)
		shuffle_inplace(things_to_cast_on)

	SEND_SIGNAL(src, COMSIG_SPELL_AOE_ON_CAST, things_to_cast_on, cast_on)

	// Now go through and cast our spell where applicable
	var/num_targets = 0
	for(var/thing_to_target in things_to_cast_on)
		if(max_targets > 0 && num_targets >= max_targets)
			continue

		cast_on_thing_in_aoe(thing_to_target, cast_on)
		num_targets++

/**
 * Gets a list of atoms around [center] that are within range and going to be affected by our aoe.
 * You should override this on a subtype basis to change what your spell affects.
 *
 * For example, if you want to only cast on atoms in view instead of range.
 * Or, if you only want living mobs in the list.
 *
 * When using range / view, it's handy to remember the byond optimization they have by casting to an atom type.
 *
 * Returns a list of atoms.
 */
/datum/action/cooldown/spell/aoe/proc/get_things_to_cast_on(atom/center)
	RETURN_TYPE(/list)

	var/list/things = list()
	// Default behavior is to get all atoms in range, center and owner not included.
	for(var/atom/nearby_thing in range(aoe_radius, center))
		if(nearby_thing == owner || nearby_thing == center)
			continue

		things += nearby_thing

	return things

/**
 * Actually cause effects on the thing in our aoe.
 * Override this for your spell! Not cast().
 *
 * Arguments
 * * victim - the atom being affected by our aoe
 * * caster - the mob who cast the aoe
 */
/datum/action/cooldown/spell/aoe/proc/cast_on_thing_in_aoe(atom/victim, atom/caster)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("[type] did not implement cast_on_thing_in_aoe and either has no effects or implemented the spell incorrectly.")
