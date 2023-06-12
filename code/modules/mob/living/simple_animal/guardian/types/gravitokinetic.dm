//gravitokinetic
/mob/living/simple_animal/hostile/guardian/gravitokinetic
	melee_damage_lower = 15
	melee_damage_upper = 15
	damage_coeff = list(BRUTE = 0.75, BURN = 0.75, TOX = 0.75, CLONE = 0.75, STAMINA = 0, OXY = 0.75)
	playstyle_string = span_holoparasite("As a <b>gravitokinetic</b> type, you can right-click to make the gravity on the ground stronger, and punching applies this effect to a target.")
	magic_fluff_string = span_holoparasite("..And draw the Singularity, an anomalous force of terror.")
	tech_fluff_string = span_holoparasite("Boot sequence complete. Gravitokinetic modules loaded. Holoparasite swarm online.")
	carp_fluff_string = span_holoparasite("CARP CARP CARP! Caught one! It's a gravitokinetic carp! Now do you understand the gravity of the situation?")
	miner_fluff_string = span_holoparasite("You encounter... Bananium, a master of gravity business.")
	creator_name = "Gravitokinetic"
	creator_desc = "Attacks will apply crushing gravity to the target. Can target the ground as well to slow targets advancing on you, but this will affect the user."
	creator_icon = "gravitokinetic"
	/// Targets we have applied our effects on.
	var/list/gravity_targets = list()
	/// Distance in which our ability works
	var/gravity_power_range = 10
	/// Gravity added on punches.
	var/punch_gravity = 5
	/// Gravity added to turfs.
	var/turf_gravity = 3

/mob/living/simple_animal/hostile/guardian/gravitokinetic/Initialize(mapload, theme)
	. = ..()
	AddElement(/datum/element/forced_gravity, 1)

/mob/living/simple_animal/hostile/guardian/gravitokinetic/set_summoner(mob/to_who, different_person)
	. = ..()
	to_who.AddElement(/datum/element/forced_gravity, 1)

/mob/living/simple_animal/hostile/guardian/gravitokinetic/cut_summoner(different_person)
	summoner.RemoveElement(/datum/element/forced_gravity, 1)
	return ..()

///Removes gravity from affected mobs upon guardian death to prevent permanent effects
/mob/living/simple_animal/hostile/guardian/gravitokinetic/death()
	. = ..()
	for(var/gravity_target in gravity_targets)
		remove_gravity(gravity_target)

/mob/living/simple_animal/hostile/guardian/gravitokinetic/AttackingTarget(atom/attacked_target)
	. = ..()
	if(isliving(target) && !hasmatchingsummoner(attacked_target) && target != src && target != summoner && !gravity_targets[target])
		to_chat(src, span_bolddanger("Your punch has applied heavy gravity to [target]!"))
		add_gravity(target, punch_gravity)
		to_chat(target, span_userdanger("Everything feels really heavy!"))

/mob/living/simple_animal/hostile/guardian/gravitokinetic/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	if(LAZYACCESS(modifiers, RIGHT_CLICK) && proximity_flag && !gravity_targets[target])
		slam_turf(attack_target)
		return
	return ..()

/mob/living/simple_animal/hostile/guardian/gravitokinetic/proc/slam_turf(turf/open/slammed)
	if(!isopenturf(slammed) || isgroundlessturf(slammed))
		to_chat(src, span_warning("You cannot add gravity to this!"))
		return
	visible_message(span_danger("[src] slams their fist into the [slammed]!"), span_notice("You modify the gravity of the [slammed]."))
	do_attack_animation(slammed)
	add_gravity(slammed, turf_gravity)

/mob/living/simple_animal/hostile/guardian/gravitokinetic/recall_effects()
	to_chat(src, span_bolddanger("You have released your gravitokinetic powers!"))
	for(var/gravity_target in gravity_targets)
		remove_gravity(gravity_target)

/mob/living/simple_animal/hostile/guardian/gravitokinetic/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	for(var/gravity_target in gravity_targets)
		if(get_dist(src, gravity_target) > gravity_power_range)
			remove_gravity(gravity_target)

/mob/living/simple_animal/hostile/guardian/gravitokinetic/proc/add_gravity(atom/target, new_gravity = 3)
	if(gravity_targets[target])
		return
	target.AddElement(/datum/element/forced_gravity, new_gravity)
	gravity_targets[target] = new_gravity
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(distance_check))
	playsound(src, 'sound/effects/gravhit.ogg', 100, TRUE)

/mob/living/simple_animal/hostile/guardian/gravitokinetic/proc/remove_gravity(atom/target)
	if(isnull(gravity_targets[target]))
		return
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	target.RemoveElement(/datum/element/forced_gravity, gravity_targets[target])
	gravity_targets -= target

/mob/living/simple_animal/hostile/guardian/gravitokinetic/proc/distance_check(atom/movable/moving_target, old_loc, dir, forced)
	SIGNAL_HANDLER
	if(get_dist(src, moving_target) > gravity_power_range)
		remove_gravity(moving_target)
