/datum/action/cooldown/mob_cooldown/ice_breath
	name = "Ice Breath"
	desc = "Fire a cold line of fire towards the enemy!"
	button_icon = 'icons/effects/magic.dmi'
	button_icon_state = "fireball"
	cooldown_time = 3 SECONDS
	melee_cooldown_time = 0 SECONDS
	click_to_activate = TRUE
	///the range of fire
	var/fire_range = 4

/datum/action/cooldown/mob_cooldown/ice_breath/Activate(atom/target_atom)
	var/turf/target_fire_turf = get_ranged_target_turf_direct(owner, target_atom, fire_range)
	var/list/burn_turfs = get_line(owner, target_fire_turf) - get_turf(owner)
	// This proc sleeps
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(dragon_fire_line), owner, /* burn_turfs = */ burn_turfs, /* frozen = */ TRUE)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/ice_breathe_all_directions
	name = "Fire all directions"
	desc = "Unleash lines of cold fire in all directions"
	button_icon = 'icons/effects/fire.dmi'
	button_icon_state = "1"
	cooldown_time = 4 SECONDS
	melee_cooldown_time = 0 SECONDS
	click_to_activate = FALSE
	///the range of fire
	var/fire_range = 6

/datum/action/cooldown/mob_cooldown/ice_breathe_all_directions/Activate(atom/target_atom)
	for(var/direction in GLOB.cardinals)
		var/turf/target_fire_turf = get_ranged_target_turf(owner, direction, fire_range)
		var/list/burn_turfs = get_line(owner, target_fire_turf) - get_turf(owner)
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(dragon_fire_line), owner, burn_turfs, frozen = TRUE)
	StartCooldown()
	return TRUE
