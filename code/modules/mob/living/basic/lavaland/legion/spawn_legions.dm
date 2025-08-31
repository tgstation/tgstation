/// Spawns a little worm nearby
/datum/action/cooldown/mob_cooldown/skull_launcher
	name = "Launch Legion"
	desc = "Propel a living piece of your body to a distant location."
	button_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	button_icon_state = "legion_head"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	click_to_activate = TRUE
	cooldown_time = 4 SECONDS
	melee_cooldown_time = 0
	shared_cooldown = NONE
	/// If a mob is not clicked directly, inherit targeting data from this blackboard key and setting it upon this target key
	var/ai_target_key = BB_BASIC_MOB_CURRENT_TARGET
	/// What are we actually spawning?
	var/spawn_type = /mob/living/basic/mining/legion_brood
	/// How far can we fire?
	var/max_range = 7

/datum/action/cooldown/mob_cooldown/skull_launcher/IsAvailable(feedback)
	. = ..()
	if (!.)
		return
	if (!isturf(owner.loc))
		owner.balloon_alert(owner, "no room!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/skull_launcher/Activate(atom/target)
	var/turf/target_turf = get_turf(target)

	if (get_dist(owner, target_turf) > max_range)
		target_turf = get_ranged_target_turf_direct(owner, target_turf, max_range)

	if (target_turf.is_blocked_turf())
		var/list/near_turfs = RANGE_TURFS(1, target_turf) - target_turf
		for (var/turf/check_turf as anything in near_turfs)
			if (check_turf.is_blocked_turf())
				near_turfs -= check_turf
		if (length(near_turfs))
			target_turf = pick(near_turfs)
		else if(target_turf.is_blocked_turf(exclude_mobs = TRUE))
			owner.balloon_alert(owner, "no room!")
			StartCooldown(0.5 SECONDS)
			return

	var/ai_target = isliving(target) ? target : null
	if (isnull(ai_target))
		ai_target = owner.ai_controller?.blackboard[ai_target_key]

	var/target_dir = get_dir(owner, target)

	var/obj/effect/temp_visual/legion_skull_depart/launch = new(get_turf(owner))
	launch.set_appearance(spawn_type)
	launch.dir = target_dir
	new /obj/effect/temp_visual/legion_brood_indicator(target_turf)
	var/obj/effect/temp_visual/legion_skull_land/land = new(target_turf)
	land.dir = target_dir
	land.set_appearance(spawn_type, CALLBACK(src, PROC_REF(spawn_skull), target_turf, ai_target))
	StartCooldown()

/// Actually create a mob
/datum/action/cooldown/mob_cooldown/skull_launcher/proc/spawn_skull(turf/spawn_location, target)
	var/mob/living/basic/mining/legion_brood/brood = new spawn_type(spawn_location)
	if (istype(brood))
		brood.assign_creator(owner)
	brood.ai_controller?.set_blackboard_key(ai_target_key, target)
	brood.dir = get_dir(owner, spawn_location)
	if (!isnull(target))
		brood.face_atom(target)
	else
		brood.dir = get_dir(owner, spawn_location)


/// Animation for launching a skull
/obj/effect/temp_visual/legion_skull_depart
	name = "legion brood launch"
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "legion_head"
	duration = 0.25 SECONDS

/// Copy appearance from the passed atom type
/obj/effect/temp_visual/legion_skull_depart/proc/set_appearance(atom/spawned_type)
	icon = initial(spawned_type.icon)
	icon_state = initial(spawned_type.icon_state)
	animate(src, alpha = 0, pixel_y = 72, time = duration)

/// Animation for landing a skull
/obj/effect/temp_visual/legion_skull_land
	name = "legion brood land"
	duration = 0.5 SECONDS
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "legion_head"
	alpha = 0
	pixel_y = 72

/// Copy appearance from the passed atom type and store what to do on animation complete
/obj/effect/temp_visual/legion_skull_land/proc/set_appearance(atom/spawned_type, datum/callback/on_completed)
	icon = initial(spawned_type.icon)
	icon_state = initial(spawned_type.icon_state)
	animate(src, alpha = 0, pixel_y = 72, time = duration / 2)
	animate(alpha = 255, pixel_y = 0, time = duration / 2)
	addtimer(on_completed, duration, TIMER_DELETE_ME)

/// A skull is going to be here! Oh no!
/obj/effect/temp_visual/legion_brood_indicator
	name = "legion brood land"
	duration = 0.75 SECONDS
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	icon = 'icons/mob/telegraphing/telegraph.dmi'
	icon_state = "skull"

/obj/effect/temp_visual/legion_brood_indicator/Initialize(mapload)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS)
	animate(alpha = 0, time = 0.25 SECONDS)
