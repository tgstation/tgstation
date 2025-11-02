/// This number is multiplied by the duration remaining (IN SECONDS, NOT DECISECONDS)
/// of the eye blur status effect to determine the intensity of the blur on the user
#define BLUR_DURATION_TO_INTENSITY 0.05

/// Applies a blur to the user's screen, increasing in strength depending on duration remaining.
/datum/status_effect/eye_blur
	id = "eye_blur"
	tick_interval = 1 SECONDS
	alert_type = null
	remove_on_fullheal = TRUE

/datum/status_effect/eye_blur/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/eye_blur/on_apply()
	if(owner.mob_biotypes & (MOB_ROBOTIC|MOB_SPIRIT|MOB_SPECIAL))
		return FALSE

	// Refresh the blur when a client jumps into the mob, in case we get put on a clientless mob with no hud
	RegisterSignals(owner, list(COMSIG_MOB_LOGIN, SIGNAL_ADDTRAIT(TRAIT_SIGHT_BYPASS), SIGNAL_REMOVETRAIT(TRAIT_SIGHT_BYPASS)), PROC_REF(update_blur))

	// Apply initial blur
	update_blur()
	return TRUE

/datum/status_effect/eye_blur/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_LOGIN)
	if(!owner.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = owner.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.remove_filter("eye_blur")

/datum/status_effect/eye_blur/tick(seconds_between_ticks)
	// Blur lessens the closer we are to expiring, so we update per tick.
	update_blur()

/// Updates the blur of the owner of the status effect.
/// Also a signal proc for [COMSIG_MOB_LOGIN], to trigger then when the mob gets a client.
/datum/status_effect/eye_blur/proc/update_blur(datum/source)
	SIGNAL_HANDLER

	if(!owner.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = owner.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	if(HAS_TRAIT(owner, TRAIT_SIGHT_BYPASS))
		game_plane_master_controller.remove_filter("eye_blur")
		return

	var/time_left_in_seconds = duration / 10
	var/amount_of_blur = clamp(time_left_in_seconds * BLUR_DURATION_TO_INTENSITY, 0.6, 3)
	game_plane_master_controller.add_filter("eye_blur", 1, gauss_blur_filter(amount_of_blur))

#undef BLUR_DURATION_TO_INTENSITY
