/datum/action/cooldown/mob_cooldown/dash
	name = "Dash"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Allows you to dash towards a position."
	cooldown_time = 1.5 SECONDS
	/// The range of the dash
	var/dash_range = 4
	/// The distance you will be from the target after you dash
	var/pick_range = 5

/datum/action/cooldown/mob_cooldown/dash/Activate(atom/target_atom)
	StartCooldown(360 SECONDS, 360 SECONDS)
	dash_to(target_atom)
	StartCooldown()

/datum/action/cooldown/mob_cooldown/dash/proc/dash_to(atom/dash_target)
	var/list/accessable_turfs = list()
	var/self_dist_to_target = 0
	var/turf/own_turf = get_turf(owner)
	if(!QDELETED(dash_target))
		self_dist_to_target += get_dist(dash_target, own_turf)
	for(var/turf/open/check_turf in RANGE_TURFS(dash_range, own_turf))
		var/turf_dist_to_target = 0
		if(!QDELETED(dash_target))
			turf_dist_to_target += get_dist(dash_target, check_turf)
		if(get_dist(owner, check_turf) >= dash_range && turf_dist_to_target <= self_dist_to_target && !islava(check_turf) && !ischasm(check_turf))
			var/valid = TRUE
			for(var/turf/T in get_line(own_turf, check_turf))
				if(T.is_blocked_turf(TRUE))
					valid = FALSE
					continue
			if(valid)
				accessable_turfs[check_turf] = turf_dist_to_target
	var/turf/target_turf
	if(!QDELETED(dash_target))
		var/closest_dist = dash_range
		for(var/t in accessable_turfs)
			if(accessable_turfs[t] < closest_dist)
				closest_dist = accessable_turfs[t]
		for(var/t in accessable_turfs)
			if(accessable_turfs[t] != closest_dist)
				accessable_turfs -= t
	if(!LAZYLEN(accessable_turfs))
		return
	target_turf = pick(accessable_turfs)
	var/turf/step_back_turf = get_step(target_turf, get_cardinal_dir(target_turf, own_turf))
	var/turf/step_forward_turf = get_step(own_turf, get_cardinal_dir(own_turf, target_turf))
	new /obj/effect/temp_visual/small_smoke/halfsecond(step_back_turf)
	new /obj/effect/temp_visual/small_smoke/halfsecond(step_forward_turf)
	var/obj/effect/temp_visual/decoy/fading/halfsecond/D = new (own_turf, owner)
	owner.forceMove(step_back_turf)
	playsound(own_turf, 'sound/weapons/punchmiss.ogg', 40, TRUE, -1)
	owner.alpha = 0
	animate(owner, alpha = 255, time = 5)
	SLEEP_CHECK_DEATH(0.2 SECONDS, owner)
	D.forceMove(step_forward_turf)
	owner.forceMove(target_turf)
	playsound(target_turf, 'sound/weapons/punchmiss.ogg', 40, TRUE, -1)
	SLEEP_CHECK_DEATH(0.1 SECONDS, owner)
