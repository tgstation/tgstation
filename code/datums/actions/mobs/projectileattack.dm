/datum/action/cooldown/mob_cooldown/projectile_attack
	name = "Projectile Attack"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Fires a set of projectiles at a selected target."
	cooldown_time = 15
	/// The type of the projectile to be fired
	var/projectile_type
	/// If the projectile should home in on its target
	var/has_homing = FALSE
	/// The turning speed if there is homing
	var/homing_turn_speed = 30
	/// The variance in the projectiles direction
	var/default_projectile_spread = 0
	/// The multiplier to the projectiles speed (a value of 2 makes it twice as slow, 0.5 makes it twice as fast)
	var/projectile_speed_multiplier = 1

/datum/action/cooldown/mob_cooldown/projectile_attack/New(Target, projectile, homing, spread)
	. = ..()
	if(projectile)
		projectile_type = projectile
	if(homing)
		has_homing = homing
	if(spread)
		default_projectile_spread = spread

/datum/action/cooldown/mob_cooldown/projectile_attack/Activate(atom/target_atom)
	StartCooldown(100)
	SEND_SIGNAL(owner, COMSIG_PROJECTILE_FIRING_STARTED)
	attack_sequence(owner, target_atom)
	SEND_SIGNAL(owner, COMSIG_PROJECTILE_FIRING_FINISHED)
	StartCooldown()

/datum/action/cooldown/mob_cooldown/projectile_attack/proc/attack_sequence(mob/living/firer, atom/target)
	shoot_projectile(firer, target, null, firer, rand(-default_projectile_spread, default_projectile_spread), null)

/datum/action/cooldown/mob_cooldown/projectile_attack/proc/shoot_projectile(atom/origin, atom/target, set_angle, mob/firer, projectile_spread, speed_multiplier)
	var/turf/startloc = get_turf(origin)
	var/turf/endloc = get_turf(target)
	if(!startloc || !endloc)
		return
	var/obj/projectile/P = new projectile_type(startloc)
	if(!isnum(speed_multiplier))
		speed_multiplier = projectile_speed_multiplier
	P.speed *= speed_multiplier
	P.preparePixelProjectile(endloc, startloc, null, projectile_spread)
	P.firer = firer
	if(target)
		P.original = target
	if(has_homing)
		P.homing_turn_speed = homing_turn_speed
		P.set_homing_target(target)
	if(isnum(set_angle))
		P.fire(set_angle)
		return
	P.fire()
	return P

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire
	name = "Rapid Fire"
	icon_icon = 'icons/obj/guns/energy.dmi'
	button_icon_state = "kineticgun"
	desc = "Fires projectiles repeatedly at a given target."
	cooldown_time = 15
	projectile_type = /obj/projectile/colossus/snowball
	default_projectile_spread = 45
	/// Total shot count
	var/shot_count = 60
	/// Delay between shots
	var/shot_delay = 1

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/attack_sequence(mob/living/firer, atom/target)
	for(var/i in 1 to shot_count)
		shoot_projectile(firer, target, null, firer, rand(-default_projectile_spread, default_projectile_spread), null)
		SLEEP_CHECK_DEATH(shot_delay, src)

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/shrapnel
	name = "Shrapnel Fire"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Fires projectiles that will split into shrapnel after a period of time."
	cooldown_time = 60
	projectile_type = /obj/projectile/colossus/frost_orb
	has_homing = TRUE
	default_projectile_spread = 180
	shot_count = 8
	shot_delay = 10
	var/shrapnel_projectile_type = /obj/projectile/colossus/ice_blast
	var/shrapnel_angles = list(0, 60, 120, 180, 240, 300)
	var/break_time = 2 SECONDS

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/shrapnel/attack_sequence(mob/living/firer, atom/target)
	for(var/i in 1 to shot_count)
		var/obj/projectile/to_explode = shoot_projectile(firer, target, null, firer, rand(-default_projectile_spread, default_projectile_spread), null)
		addtimer(CALLBACK(src, .proc/explode_into_shrapnel, firer, target, to_explode), break_time)
		SLEEP_CHECK_DEATH(shot_delay, src)

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/shrapnel/proc/explode_into_shrapnel(mob/living/firer, atom/target, obj/projectile/to_explode)
	if(!to_explode)
		return
	qdel(to_explode)
	for(var/angle in shrapnel_angles)
		// no speed multiplier for shrapnel
		shoot_projectile(firer, target, angle, firer, null, 1)

/datum/action/cooldown/mob_cooldown/projectile_attack/spiral_shots
	name = "Spiral Shots"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Fires projectiles in a spiral pattern."
	cooldown_time = 30
	projectile_type = /obj/projectile/colossus
	/// Whether or not the attack is the enraged form
	var/enraged = FALSE

/datum/action/cooldown/mob_cooldown/projectile_attack/spiral_shots/attack_sequence(mob/living/firer, atom/target)
	SEND_SIGNAL(owner, COMSIG_SPIRAL_ATTACK_START)
	if(enraged)
		SLEEP_CHECK_DEATH(10, firer)
		INVOKE_ASYNC(src, .proc/create_spiral_attack, firer, target, TRUE)
		create_spiral_attack(firer, target, FALSE)
		return
	create_spiral_attack(firer, target)
	SEND_SIGNAL(owner, COMSIG_SPIRAL_ATTACK_FINISHED)

/datum/action/cooldown/mob_cooldown/projectile_attack/spiral_shots/proc/create_spiral_attack(mob/living/firer, atom/target, negative = pick(TRUE, FALSE))
	var/counter = 8
	for(var/i in 1 to 80)
		if(negative)
			counter--
		else
			counter++
		if(counter > 16)
			counter = 1
		if(counter < 1)
			counter = 16
		shoot_projectile(firer, target, counter * 22.5, firer, null, null)
		playsound(get_turf(firer), 'sound/magic/clockwork/invoke_general.ogg', 20, TRUE)
		SLEEP_CHECK_DEATH(1, firer)

/datum/action/cooldown/mob_cooldown/projectile_attack/random_aoe
	name = "All Directions"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "at_shield2"
	desc = "Fires projectiles in all directions."
	cooldown_time = 30
	projectile_type = /obj/projectile/colossus

/datum/action/cooldown/mob_cooldown/projectile_attack/random_aoe/attack_sequence(mob/living/firer, atom/target)
	var/turf/U = get_turf(firer)
	playsound(U, 'sound/magic/clockwork/invoke_general.ogg', 300, TRUE, 5)
	for(var/i in 1 to 32)
		shoot_projectile(firer, target, rand(0, 360), firer, null, null)

/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast
	name = "Shotgun Fire"
	icon_icon = 'icons/obj/guns/ballistic.dmi'
	button_icon_state = "shotgun"
	desc = "Fires projectiles in a shotgun pattern."
	cooldown_time = 20
	projectile_type = /obj/projectile/colossus
	var/list/shot_angles = list(12.5, 7.5, 2.5, -2.5, -7.5, -12.5)

/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/New(Target, projectile, homing, spread, list/angles)
	. = ..()
	if(angles)
		shot_angles = angles

/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/attack_sequence(mob/living/firer, atom/target)
	fire_shotgun(firer, target, shot_angles)

/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/proc/fire_shotgun(mob/living/firer, atom/target, list/chosen_angles)
	playsound(firer, 'sound/magic/clockwork/invoke_general.ogg', 200, TRUE, 2)
	for(var/spread in chosen_angles)
		shoot_projectile(firer, target, null, firer, spread, null)

/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/pattern
	name = "Alternating Shotgun Fire"
	desc = "Fires projectiles in an alternating shotgun pattern."
	projectile_type = /obj/projectile/colossus/ice_blast
	shot_angles = list(list(-40, -20, 0, 20, 40), list(-30, -10, 10, 30))
	var/shot_count = 5

/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/pattern/attack_sequence(mob/living/firer, atom/target)
	for(var/i in 1 to shot_count)
		var/list/pattern = shot_angles[i % length(shot_angles) + 1] // changing patterns
		fire_shotgun(firer, target, pattern)
		SLEEP_CHECK_DEATH(8, firer)

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots
	name = "Directional Shots"
	icon_icon = 'icons/obj/guns/ballistic.dmi'
	button_icon_state = "pistol"
	desc = "Fires projectiles in specific directions."
	cooldown_time = 40
	projectile_type = /obj/projectile/colossus
	var/list/firing_directions

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/New(Target, projectile, homing, spread, list/dirs)
	. = ..()
	if(dirs)
		firing_directions = dirs
	else
		firing_directions = GLOB.alldirs.Copy()

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/attack_sequence(mob/living/firer, atom/target)
	fire_in_directions(firer, target, firing_directions)

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/proc/fire_in_directions(mob/living/firer, atom/target, list/dirs)
	if(!islist(dirs))
		dirs = GLOB.alldirs.Copy()
	playsound(firer, 'sound/magic/clockwork/invoke_general.ogg', 200, TRUE, 2)
	for(var/d in dirs)
		var/turf/E = get_step(firer, d)
		shoot_projectile(firer, E, null, firer, null, null)

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/alternating
	name = "Alternating Shots"
	desc = "Fires projectiles in alternating directions."

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/alternating/attack_sequence(mob/living/firer, atom/target)
	fire_in_directions(firer, target, GLOB.diagonals)
	SLEEP_CHECK_DEATH(10, firer)
	fire_in_directions(firer, target, GLOB.cardinals)
	SLEEP_CHECK_DEATH(10, firer)
	fire_in_directions(firer, target, GLOB.diagonals)
	SLEEP_CHECK_DEATH(10, firer)
	fire_in_directions(firer, target, GLOB.cardinals)
