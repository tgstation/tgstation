#define MOOK_ATTACK_NEUTRAL 0
#define MOOK_ATTACK_WARMUP 1
#define MOOK_ATTACK_ACTIVE 2
#define MOOK_ATTACK_STRIKE 3

//Fragile but highly aggressive wanderers that pose a large threat in numbers.
//They'll attempt to leap at their target from afar using their hatchets.
/mob/living/basic/mook
	name = "wanderer"
	desc = "This unhealthy looking primitive is wielding a rudimentary hatchet, swinging it with wild abandon. One isn't much of a threat, but in numbers they can quickly overwhelm a superior opponent."
	icon = 'icons/mob/simple/jungle/mook.dmi'
	icon_state = "mook"
	icon_living = "mook"
	icon_dead = "mook_dead"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	maxHealth = 45
	health = 45
	melee_damage_lower = 30
	melee_damage_upper = 30
	pass_flags_self = LETPASSTHROW
	attack_sound = 'sound/weapons/rapierhit.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	death_sound = 'sound/voice/mook_death.ogg'
	var/attack_state = MOOK_ATTACK_NEUTRAL


/mob/living/basic/mook/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(pre_attack))
	var/datum/action/cooldown/mob_cooldown/mook_leap/leap = new(src)
	leap.Grant(src)

/mob/living/basic/mook/proc/pre_attack(atom/target)
	SIGNAL_HANDLER

	if(attack_state == MOOK_ATTACK_STRIKE)
		return COMPONENT_HOSTILE_NO_ATTACK

	change_combatant_state(state = MOOK_ATTACK_STRIKE)
	addtimer(CALLBACK(src, PROC_REF(change_combatant_state), MOOK_ATTACK_NEUTRAL), 0.3 SECONDS)

/mob/living/basic/mook/proc/change_combatant_state(state)
	attack_state = state
	update_appearance(UPDATE_ICON)

/mob/living/basic/mook/update_icon_state()
	. = ..()
	if(stat == DEAD)
		return
	switch(attack_state)
		if(MOOK_ATTACK_NEUTRAL)
			icon_state = "mook"
		if(MOOK_ATTACK_WARMUP)
			icon_state = "mook_warmup"
		if(MOOK_ATTACK_ACTIVE)
			icon_state = "mook_leap"
		if(MOOK_ATTACK_STRIKE)
			icon_state = "mook_strike"

/mob/living/basic/mook/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force, gentle = FALSE, quickstart = TRUE)
	ADD_TRAIT(src, TRAIT_UNDENSE, LEAPING_TRAIT)
	change_combatant_state(state = MOOK_ATTACK_ACTIVE)
	return ..()

/mob/living/basic/mook/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	REMOVE_TRAIT(src, TRAIT_UNDENSE, LEAPING_TRAIT)
	change_combatant_state(state = MOOK_ATTACK_NEUTRAL)

/mob/living/basic/mook/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()

	if(!istype(mover, /mob/living/basic/mook))
		return FALSE

	var/mob/living/basic/mook/mook_moover = mover
	if(mook_moover.attack_state == MOOK_ATTACK_ACTIVE)
		return TRUE

/mob/living/simple_animal/hostile/jungle/mook/death()
	desc = "A deceased primitive. Upon closer inspection, it was suffering from severe cellular degeneration and its garments are machine made..."//Can you guess the twist
	return ..()

/datum/action/cooldown/mob_cooldown/mook_leap
	name = "Mook leap"
	button_icon = 'icons/effects/beam.dmi'
	button_icon_state = "solar_beam"
	desc = "Leap towards the enemy!"
	cooldown_time = 7 SECONDS
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS
	///telegraph time before jumping
	var/wind_up_time = 2 SECONDS
	///are we a mook?
	var/is_mook = FALSE
	///intervals between each of our attacks
	var/attack_interval = 0.4 SECONDS
	///how many times do we attack if we reach the target?
	var/times_to_attack = 4

/datum/action/cooldown/mob_cooldown/mook_leap/Grant(mob/grant_to)
	. = ..()
	if(isnull(owner))
		return
	is_mook = istype(owner, /mob/living/basic/mook)

/datum/action/cooldown/mob_cooldown/mook_leap/IsAvailable(feedback)
	. = ..()

	if(!.)
		return FALSE

	if(!is_mook)
		return TRUE

	var/mob/living/basic/mook/mook_owner = owner
	if(mook_owner.attack_state != MOOK_ATTACK_NEUTRAL)
		if(feedback)
			mook_owner.balloon_alert(mook_owner, "still recovering!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/mook_leap/Activate(atom/target)
	if(owner.CanReach(target))
		attack_combo(target)
		StartCooldown()
		return TRUE

	if(is_mook)
		var/mob/living/basic/mook/mook_owner = owner
		mook_owner.change_combatant_state(state = MOOK_ATTACK_WARMUP)

	addtimer(CALLBACK(src, PROC_REF(launch_towards_target), target), wind_up_time)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/mook_leap/proc/launch_towards_target(atom/target)
	new /obj/effect/temp_visual/mook_dust(get_turf(owner))
	playsound(get_turf(owner), 'sound/weapons/thudswoosh.ogg', 25, TRUE)
	playsound(owner, 'sound/voice/mook_leap_yell.ogg', 100, TRUE)
	var/turf/target_turf = get_turf(target)

	if(!target_turf.is_blocked_turf())
		owner.throw_at(target = target_turf, range = 7, speed = 1, spin = FALSE, callback = CALLBACK(src, PROC_REF(attack_combo), target))
		return

	var/list/open_turfs = list()

	for(var/turf/possible_turf in get_adjacent_open_turfs(target))
		if(possible_turf.is_blocked_turf())
			continue
		open_turfs += possible_turf

	if(!length(open_turfs))
		return

	var/turf/final_turf = get_closest_atom(/turf, open_turfs, owner)
	owner.throw_at(target = final_turf, range = 7, speed = 1, spin = FALSE, callback = CALLBACK(src, PROC_REF(attack_combo), target))

/datum/action/cooldown/mob_cooldown/mook_leap/proc/attack_combo(atom/target)
	if(!owner.CanReach(target))
		return FALSE

	for(var/i in 0 to (times_to_attack - 1))
		addtimer(CALLBACK(src, PROC_REF(attack_target), target), i * attack_interval)

/datum/action/cooldown/mob_cooldown/mook_leap/proc/attack_target(atom/target)
	if(!owner.CanReach(target) || owner.stat == DEAD)
		return
	var/mob/living/basic/basic_owner = owner
	basic_owner.melee_attack(target, ignore_cooldown = TRUE)

/obj/effect/temp_visual/mook_dust
	name = "dust"
	desc = "It's just a dust cloud!"
	icon = 'icons/mob/simple/jungle/mook.dmi'
	icon_state = "mook_leap_cloud"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	base_pixel_y = -16
	base_pixel_x = -16
	duration = 10

#undef MOOK_ATTACK_NEUTRAL
#undef MOOK_ATTACK_WARMUP
#undef MOOK_ATTACK_ACTIVE
#undef MOOK_ATTACK_STRIKE
