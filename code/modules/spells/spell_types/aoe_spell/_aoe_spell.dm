/**
 * ## Pointed spells
 *
 * A spell that iterates over atoms nearby the caster and casts a spell on them.
 * By default, cast_on_thing_in_aoe is cast on ALL ATOMS in the radius of the spell (sans caster).
 *
 * However, by overriding is_valid_target,
 * you can allow the spell to only target turfs, or mobs, or doors, or whatever.
 * Or, by overriding get_things_to_cast_on,
 * you can only pass in the atoms you want to cast the spell on. Your choice.
 */
/datum/action/cooldown/spell/aoe
	/// The outside radius of the aoe.
	var/outer_radius = 7
	/// The inside radius of the aoe. If set to 0, the caster's turf will be exluded.
	var/inner_radius = -1

/datum/action/cooldown/spell/aoe/is_valid_target(atom/cast_on)
	if(cast_on == owner)
		return FALSE

	return isatom(cast_on)

// At this point, cast_on == owner. Either works.
/datum/action/cooldown/spell/aoe/cast(atom/cast_on)
	. = ..()
	for(var/atom/thing_to_target as anything in get_things_to_cast_on(cast_on))
		if(!is_valid_target(turf_to_target))
			continue
		cast_on_thing_in_aoe(thing_to_target)

/datum/action/cooldown/spell/aoe/proc/get_things_to_cast_on(atom/center)
	if(inner_radius >= 0)
		return range(outer_radius, center) - range(inner_radius, center)

	return range(outer_radius, center)

/// Override this for your spell! not cast().
/datum/action/cooldown/spell/aoe/proc/cast_on_thing_in_aoe(atom/cast_on)
	CRASH("[type] did not implement cast_on_thing_in_aoe and either has no effects or implemented the spell incorrectly.")
