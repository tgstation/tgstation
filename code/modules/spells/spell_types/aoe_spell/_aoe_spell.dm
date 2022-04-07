/**
 * ## AOE spells
 *
 * A spell that iterates over atoms nearby the caster and casts a spell on them.
 * By default, cast_on_thing_in_aoe is cast on ALL ATOMS in the radius of the spell (sans caster).
 *
 * However, by overriding is_affected_by_aoe,
 * you can allow the spell to only target turfs, or mobs, or doors, or whatever.
 * Or, by overriding get_things_to_cast_on,
 * you can only pass in the atoms you want to cast the spell on. Your choice.
 */
/datum/action/cooldown/spell/aoe
	/// The max amount of targets we can affect via our AOE. 0 = unlimited
	var/max_targets = 0
	/// The outside radius of the aoe.
	var/outer_radius = 7
	/// The inside radius of the aoe. If set to 0, the caster's turf will be exluded.
	var/inner_radius = -1

// At this point, cast_on == owner. Either works.
/datum/action/cooldown/spell/aoe/cast(atom/cast_on)
	. = ..()
	// Get every atom around us to our aoe cast on
	var/list/atom/things_to_cast_on = get_things_to_cast_on(cast_on)
	// If we have a target limit, shuffle it (for fariness)
	if(max_targets > 0)
		things_to_cast_on = shuffle(things_to_cast_on)

	SEND_SIGNAL(src, COMSIG_SPELL_AOE_ON_CAST, things_to_cast_on, cast_on)

	// Now go through and cast our spell where applicable
	var/num_targets = 0
	for(var/atom/thing_to_target as anything in things_to_cast_on)
		if(!is_affected_by_aoe(cast_on, thing_to_target))
			continue
		if(max_targets > 0 && num_targets >= max_targets)
			continue

		cast_on_thing_in_aoe(thing_to_target, cast_on)
		num_targets++

// MELBERT TODO: this needs to be reworked, unoptimized
/**
 * Gets a list of atoms around [center]
 * that are within range and affected by our aoe.
 */
/datum/action/cooldown/spell/aoe/proc/get_things_to_cast_on(atom/center)
	if(inner_radius >= 0)
		return range(outer_radius, center) - range(inner_radius, center)

	return range(outer_radius, center)

/**
 * Checks if the past atom [thing]
 * is valid and affected by our aoe spell.
 */
/datum/action/cooldown/spell/aoe/proc/is_affected_by_aoe(atom/center, atom/thing)
	if(thing == owner || thing == center)
		return FALSE

	return isatom(thing)

/**
 * Actually cause effects on the thing in our aoe.
 * Override this for your spell! not cast().
 *
 * Arguments
 * * victim - the atom being affected by our aoe
 * * caster - the mob who cast the aoe
 */
/datum/action/cooldown/spell/aoe/proc/cast_on_thing_in_aoe(atom/victim, atom/caster)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("[type] did not implement cast_on_thing_in_aoe and either has no effects or implemented the spell incorrectly.")
