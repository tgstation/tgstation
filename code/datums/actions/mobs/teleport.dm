/datum/action/cooldown/mob_cooldown/teleport
	name = "Teleport"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Allows you to teleport a certain distance away from a position in a random direction."
	cooldown_time = 10 SECONDS
	/// The distance from the target
	var/radius = 6

/datum/action/cooldown/mob_cooldown/teleport/Activate(atom/target_atom)
	disable_cooldown_actions()
	teleport_to(target_atom)
	StartCooldown()
	enable_cooldown_actions()
	return TRUE

/// Handles randomly teleporting the owner around the target in view
/datum/action/cooldown/mob_cooldown/teleport/proc/teleport_to(atom/teleport_target)
	var/list/possible_ends = view(radius, teleport_target.loc) - view(radius - 1, teleport_target.loc)
	for(var/turf/closed/cant_teleport_turf in possible_ends)
		possible_ends -= cant_teleport_turf
	if(!possible_ends.len)
		return
	var/turf/end = pick(possible_ends)
	do_teleport(owner, end, 0,  channel=TELEPORT_CHANNEL_BLUESPACE, forced = TRUE)
