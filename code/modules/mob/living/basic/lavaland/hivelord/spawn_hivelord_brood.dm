/// Spawns a little worm nearby
/datum/action/cooldown/mob_cooldown/hivelord_spawn
	name = "Spawn Brood"
	desc = "Release an attack form to an adjacent square to attack your target or anyone nearby."
	button_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	button_icon_state = "hivelord_brood"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	click_to_activate = TRUE
	cooldown_time = 2 SECONDS
	melee_cooldown_time = 0
	shared_cooldown = NONE
	/// If a mob is not clicked directly, inherit targetting data from this blackboard key and setting it upon this target key
	var/ai_target_key = BB_BASIC_MOB_CURRENT_TARGET
	/// What are we actually spawning?
	var/spawn_type = /mob/living/basic/hivelord_brood
	/// Do we automatically fire with no cooldown when damaged?
	var/trigger_on_hit = TRUE
	/// Minimum time between triggering on hit
	var/on_hit_delay = 1 SECONDS
	/// Delay between triggering on hit
	COOLDOWN_DECLARE(on_hit_cooldown)

/datum/action/cooldown/mob_cooldown/hivelord_spawn/Grant(mob/granted_to)
	. = ..()
	if (isnull(owner))
		return
	if (trigger_on_hit)
		RegisterSignal(owner, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

/datum/action/cooldown/mob_cooldown/hivelord_spawn/Remove(mob/removed_from)
	UnregisterSignal(removed_from, COMSIG_ATOM_WAS_ATTACKED)
	return ..()

/datum/action/cooldown/mob_cooldown/hivelord_spawn/Activate(atom/target)
	. = ..()
	if (!spawn_brood(target, target_turf = get_turf(target)))
		StartCooldown(0.5 SECONDS)
		return
	StartCooldown()

/// Called when someone whacks us
/datum/action/cooldown/mob_cooldown/hivelord_spawn/proc/on_attacked(atom/victim, atom/attacker, attack_flags)
	SIGNAL_HANDLER
	if (!trigger_on_hit || !(attack_flags & ATTACKER_DAMAGING_ATTACK) || !COOLDOWN_FINISHED(src, on_hit_cooldown))
		return
	COOLDOWN_START(src, on_hit_cooldown, on_hit_delay)
	spawn_brood(attacker, target_turf = get_step_away(owner, attacker), feedback = FALSE)

/// Spawn a funny little worm
/datum/action/cooldown/mob_cooldown/hivelord_spawn/proc/spawn_brood(target, turf/target_turf, feedback = TRUE)
	var/ai_target = isliving(target) ? target : null
	if (isnull(ai_target))
		ai_target = owner.ai_controller?.blackboard[ai_target_key]

	var/dir_to_target = get_dir(owner, target_turf)
	var/list/target_turfs = list()
	for(var/i in -1 to 1)
		var/turn_amount = rand(-1, 1) * 45
		var/test_dir = turn(dir_to_target, turn_amount)
		var/turf/test_turf = get_step(owner, test_dir)
		if (test_turf.is_blocked_turf(exclude_mobs = TRUE))
			continue
		target_turfs += test_turf

	if (!length(target_turfs))
		if (feedback)
			owner.balloon_alert(owner, "no room!")
		StartCooldown(0.5 SECONDS)
		return FALSE

	var/turf/land_turf = pick(target_turfs)
	var/obj/effect/temp_visual/hivebrood_spawn/forecast = new(land_turf)
	forecast.create_from(spawn_type, get_turf(owner), CALLBACK(src, PROC_REF(complete_spawn), land_turf, ai_target))
	StartCooldown()

	return TRUE

/// Actually create a mob
/datum/action/cooldown/mob_cooldown/hivelord_spawn/proc/complete_spawn(turf/spawn_turf, target)
	var/mob/living/brood = new spawn_type(spawn_turf)
	brood.faction = owner.faction
	brood.ai_controller?.set_blackboard_key(ai_target_key, target)
	brood.dir = get_dir(owner, spawn_turf)

#define BROOD_ARC_Y_OFFSET 8
#define BROOD_ARC_ROTATION 45

/// Fast animation to show a worm spawning
/obj/effect/temp_visual/hivebrood_spawn
	name = "brood spawn"
	duration = 0.3 SECONDS
	alpha = 0

/// Set up our visuals and start a timer for a callback
/obj/effect/temp_visual/hivebrood_spawn/proc/create_from(mob/living/spawn_type, turf/spawn_from, datum/callback/on_completed)
	addtimer(on_completed, duration, TIMER_DELETE_ME)

	var/turf/my_turf = get_turf(src)
	dir = get_dir(spawn_from, my_turf)
	var/move_x = (my_turf.x - spawn_from.x) * world.icon_size
	var/move_y = (my_turf.y - spawn_from.y) * world.icon_size
	pixel_x = -move_x
	pixel_y = -move_y

	icon = initial(spawn_type.icon)
	icon_state = initial(spawn_type.icon_state)


	animate(src, pixel_x = 0, time = duration)
	animate(src, pixel_y = BROOD_ARC_Y_OFFSET - (move_y * 0.5), time = duration * 0.5, flags = ANIMATION_PARALLEL, easing = SINE_EASING | EASE_OUT)
	animate(pixel_y = 0, time = duration * 0.5, easing = SINE_EASING | EASE_IN)
	animate(src, alpha = 255, time = duration * 0.5, flags = ANIMATION_PARALLEL)

	if (dir & (NORTH | EAST))
		transform = matrix().Turn(-BROOD_ARC_ROTATION)
		animate(src, transform = matrix(), time = duration, flags = ANIMATION_PARALLEL)
	else
		transform = matrix().Turn(BROOD_ARC_ROTATION)
		animate(src, transform = matrix(), time = duration, flags = ANIMATION_PARALLEL)

#undef BROOD_ARC_Y_OFFSET
#undef BROOD_ARC_ROTATION
