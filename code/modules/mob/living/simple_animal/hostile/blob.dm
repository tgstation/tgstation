//Do not spawn
/mob/living/simple_animal/hostile/blob
	icon = 'icons/mob/nonhuman-player/blob.dmi'
	pass_flags = PASSBLOB
	faction = list(ROLE_BLOB)
	bubble_icon = "blob"
	speak_emote = null //so we use verb_yell/verb_say/etc
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	unique_name = 1
	combat_mode = TRUE
	// ... Blob colored lighting
	lighting_cutoff_red = 20
	lighting_cutoff_green = 40
	lighting_cutoff_blue = 30
	initial_language_holder = /datum/language_holder/empty
	retreat_distance = null //! retreat doesn't obey pass_flags, so won't work on blob mobs.
	/// Blob camera that controls the blob
	var/mob/camera/blob/overmind = null
	/// If this is related to anything else
	var/independent = FALSE
	/// The factory blob tile that generated this blob minion
	var/obj/structure/blob/special/factory/factory

///override to use astar/JPS instead of walk_to so we can take our blob pass_flags into account.
/mob/living/simple_animal/hostile/blob/Goto(target, delay, minimum_distance)
	if(prevent_goto_movement)
		return FALSE
	if(target == src.target)
		approaching_target = TRUE
	else
		approaching_target = FALSE

	SSmove_manager.jps_move(moving = src, chasing = target, delay = delay, repath_delay = 2 SECONDS, minimum_distance = minimum_distance, simulated_only = FALSE, skip_first = TRUE, timeout = 5 SECONDS, flags = MOVEMENT_LOOP_IGNORE_GLIDE)
	return TRUE
