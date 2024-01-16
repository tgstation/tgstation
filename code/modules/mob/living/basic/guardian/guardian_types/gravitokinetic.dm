/// Somewhat durable guardian who can increase gravity in an area
/mob/living/basic/guardian/gravitokinetic
	guardian_type = GUARDIAN_GRAVITOKINETIC
	melee_damage_lower = 15
	melee_damage_upper = 15
	damage_coeff = list(BRUTE = 0.75, BURN = 0.75, TOX = 0.75, STAMINA = 0, OXY = 0.75)
	playstyle_string = span_holoparasite("As a <b>gravitokinetic</b> type, you can right-click to make the gravity on the ground stronger, and punching applies this effect to a target.")
	creator_name = "Gravitokinetic"
	creator_desc = "Attacks will apply crushing gravity to the target. Can target the ground as well to slow targets advancing on you, but you are not immune to your own such effects."
	creator_icon = "gravitokinetic"
	/// Targets we have applied our gravity effects on.
	var/list/gravity_targets = list()
	/// Distance at which our ability works
	var/gravity_power_range = 10
	/// Gravity added on punches.
	var/punch_gravity = 5
	/// Gravity added to turfs.
	var/turf_gravity = 3

/mob/living/basic/guardian/gravitokinetic/Initialize(mapload, datum/guardian_fluff/theme)
	. = ..()
	AddElement(/datum/element/forced_gravity, 1)

	var/static/list/container_connections = list(
		COMSIG_MOVABLE_MOVED = PROC_REF(on_moved),
	)
	AddComponent(/datum/component/connect_containers, src, container_connections)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/mob/living/basic/guardian/gravitokinetic/set_summoner(mob/living/to_who, different_person)
	. = ..()
	if (!QDELETED(src))
		return
	to_who.AddElement(/datum/element/forced_gravity, 1)

/mob/living/basic/guardian/gravitokinetic/cut_summoner(different_person)
	summoner?.RemoveElement(/datum/element/forced_gravity, 1)
	return ..()

/mob/living/basic/guardian/gravitokinetic/death(gibbed)
	. = ..()
	clear_gravity()

/mob/living/basic/guardian/gravitokinetic/recall_effects()
	. = ..()
	if (length(gravity_targets))
		to_chat(src, span_bolddanger("You have released your gravitokinetic powers!"))
	clear_gravity()

/mob/living/basic/guardian/gravitokinetic/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if (!. || !isliving(target) || target == src || target == summoner || shares_summoner(target) || gravity_targets[target])
		return
	to_chat(src, span_bolddanger("Your punch has applied heavy gravity to [target]!"))
	add_gravity(target, punch_gravity)
	to_chat(target, span_userdanger("Everything feels really heavy!"))
	return TRUE

/mob/living/basic/guardian/gravitokinetic/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	if (LAZYACCESS(modifiers, RIGHT_CLICK) && proximity_flag && !gravity_targets[attack_target] && can_unarmed_attack())
		slam_turf(attack_target)
		return
	return ..()

/// Apply forced gravity to the floor
/mob/living/basic/guardian/gravitokinetic/proc/slam_turf(turf/open/slammed)
	if (!isopenturf(slammed) || isgroundlessturf(slammed))
		return
	visible_message(span_danger("[src] slams their fist into the [slammed]!"), span_notice("You amplify gravity around the [slammed]."))
	do_attack_animation(slammed)
	add_gravity(slammed, turf_gravity)

/// Remove our forced gravity from all targets
/mob/living/basic/guardian/gravitokinetic/proc/clear_gravity()
	for(var/gravity_target in gravity_targets)
		remove_gravity(gravity_target)

/// Make something heavier
/mob/living/basic/guardian/gravitokinetic/proc/add_gravity(atom/target, new_gravity = 3)
	if (gravity_targets[target])
		return
	target.AddElement(/datum/element/forced_gravity, new_gravity)
	gravity_targets[target] = new_gravity
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_target_moved))
	playsound(src, 'sound/effects/gravhit.ogg', 100, TRUE)

/// Stop making something heavier
/mob/living/basic/guardian/gravitokinetic/proc/remove_gravity(atom/target, too_far = FALSE)
	if (isnull(gravity_targets[target]))
		return
	if (too_far)
		to_chat(src, span_bolddanger("You are too far away from [target] to amplify gravity's hold on them!"))
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	target.RemoveElement(/datum/element/forced_gravity, gravity_targets[target])
	gravity_targets -= target

/// When we or something we are inside move check if we are now too far away
/mob/living/basic/guardian/gravitokinetic/proc/on_moved()
	for(var/gravity_target in gravity_targets)
		if (get_dist(src, gravity_target) > gravity_power_range)
			remove_gravity(gravity_target, too_far = TRUE)

/// When something we put gravity on moves check if it's too far away
/mob/living/basic/guardian/gravitokinetic/proc/on_target_moved(atom/movable/moving_target, old_loc, dir, forced)
	SIGNAL_HANDLER
	if (get_dist(src, moving_target) > gravity_power_range)
		remove_gravity(moving_target, too_far = TRUE)
