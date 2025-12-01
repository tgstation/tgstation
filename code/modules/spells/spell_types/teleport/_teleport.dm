
/**
 * ## Teleport Spell
 *
 * Teleports the caster to a turf selected by get_destinations().
 */
/datum/action/cooldown/spell/teleport
	sound = 'sound/items/weapons/zapbang.ogg'

	school = SCHOOL_TRANSLOCATION

	/// What channel the teleport is done under.
	var/teleport_channel = TELEPORT_CHANNEL_MAGIC
	/// Whether we force the teleport to happen (ie, it cannot be blocked by noteleport areas or blessings or whatever)
	var/force_teleport = FALSE
	/// A list of flags related to determining if our destination target is valid or not.
	var/destination_flags = NONE
	/// The sound played on arrival, after the teleport.
	var/post_teleport_sound = 'sound/items/weapons/zapbang.ogg'

/datum/action/cooldown/spell/teleport/cast(atom/cast_on)
	. = ..()
	var/list/turf/destinations = get_destinations(cast_on)
	if(!length(destinations))
		CRASH("[type] failed to find a teleport destination.")

	do_teleport(cast_on, pick(destinations), asoundout = post_teleport_sound, channel = teleport_channel, forced = force_teleport)

/// Gets a list of destinations that are valid
/datum/action/cooldown/spell/teleport/proc/get_destinations(atom/center)
	CRASH("[type] did not implement get_destinations and either has no effects or implemented the spell incorrectly.")

/// Checks if the passed turf is a valid destination.
/datum/action/cooldown/spell/teleport/proc/is_valid_destination(turf/selected)
	if(isspaceturf(selected) && (destination_flags & TELEPORT_SPELL_SKIP_SPACE))
		return FALSE
	if(selected.density && (destination_flags & TELEPORT_SPELL_SKIP_DENSE))
		return FALSE
	if(selected.is_blocked_turf(exclude_mobs = TRUE) && (destination_flags & TELEPORT_SPELL_SKIP_BLOCKED))
		return FALSE

	return TRUE

/**
 * ### Radius Teleport Spell
 *
 * A subtype of teleport that will teleport the caster
 * to a random turf within a radius of themselves.
 */
/datum/action/cooldown/spell/teleport/radius_turf
	/// The inner radius around the caster that we can teleport to
	var/inner_tele_radius = 1
	/// The outer radius around the caster that we can teleport to
	var/outer_tele_radius = 2

/datum/action/cooldown/spell/teleport/radius_turf/get_destinations(atom/center)
	var/list/valid_turfs = list()
	var/list/possibles = RANGE_TURFS(outer_tele_radius, center)
	if(inner_tele_radius > 0)
		possibles -= RANGE_TURFS(inner_tele_radius, center)

	for(var/turf/nearby_turf as anything in possibles)
		if(!is_valid_destination(nearby_turf))
			continue

		valid_turfs += nearby_turf

	// If there are valid turfs around us?
	// Screw it, allow 'em to teleport to ANY nearby turf.
	return length(valid_turfs) ? valid_turfs : possibles

/datum/action/cooldown/spell/teleport/radius_turf/is_valid_destination(turf/selected)
	. = ..()
	if(!.)
		return FALSE

	// putting them at the edge is dumb
	if(selected.x > world.maxx - outer_tele_radius || selected.x < outer_tele_radius)
		return FALSE
	if(selected.y > world.maxy - outer_tele_radius || selected.y < outer_tele_radius)
		return FALSE

	return TRUE

/**
 * ### Area Teleport Spell
 *
 * A subtype of teleport that will teleport the caster
 * to a random turf within a selected (or random) area.
 */
/datum/action/cooldown/spell/teleport/area_teleport
	force_teleport = TRUE // Forced, as the Wizard Den is noteleport and wizards couldn't escape otherwise.
	destination_flags = TELEPORT_SPELL_SKIP_BLOCKED
	/// The last area we chose to teleport / where we're currently teleporting to, if mid-cast
	var/last_chosen_area_name
	/// If FALSE, the caster can select the destination area. If TRUE, they will teleport to somewhere randomly instead.
	var/randomise_selection = FALSE
	/// If the invocation appends the selected area when said. Requires invocation mode shout or whisper.
	var/invocation_says_area = TRUE

/datum/action/cooldown/spell/teleport/area_teleport/get_destinations(atom/center)
	var/list/valid_turfs = list()
	for(var/turf/possible_destination as anything in get_area_turfs(GLOB.teleportlocs[last_chosen_area_name]))
		if(!is_valid_destination(possible_destination))
			continue

		valid_turfs += possible_destination

	return valid_turfs

/datum/action/cooldown/spell/teleport/area_teleport/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	var/area/target_area
	if(randomise_selection)
		target_area = pick(GLOB.teleportlocs)
	else
		target_area = tgui_input_list(cast_on, "Chose an area to teleport to.", "Teleport", GLOB.teleportlocs)

	if(QDELETED(src) || QDELETED(cast_on) || (owner && !can_cast_spell()))
		return . | SPELL_CANCEL_CAST
	if(!target_area || isnull(GLOB.teleportlocs[target_area]))
		return . | SPELL_CANCEL_CAST

	last_chosen_area_name = target_area

/datum/action/cooldown/spell/teleport/area_teleport/cast(atom/cast_on)
	if(isliving(cast_on))
		var/mob/living/living_cast_on = cast_on
		living_cast_on.buckled?.unbuckle_mob(cast_on, force = TRUE)
	return ..()

/datum/action/cooldown/spell/teleport/area_teleport/invocation(mob/living/invoker)
	var/area/last_chosen_area = GLOB.teleportlocs[last_chosen_area_name]

	if(!invocation_says_area || isnull(last_chosen_area))
		return ..()

	switch(invocation_type)
		if(INVOCATION_SHOUT)
			invoker.say("[invocation], [uppertext(last_chosen_area.name)]!", forced = "spell ([src])")
		if(INVOCATION_WHISPER)
			invoker.whisper("[invocation], [uppertext(last_chosen_area.name)].", forced = "spell ([src])")
