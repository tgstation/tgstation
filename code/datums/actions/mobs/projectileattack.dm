/datum/action/cooldown/mob_cooldown/projectile_attack
	name = "Projectile Attack"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Fires a set of projectiles at a selected target."
	cooldown_time = 1.5 SECONDS
	/// The type of the projectile to be fired
	var/projectile_type
	/// The sound played when a projectile is fired
	var/projectile_sound
	/// If the projectile should home in on its target
	var/has_homing = FALSE
	/// The turning speed if there is homing
	var/homing_turn_speed = 30
	/// The variance in the projectiles direction
	var/default_projectile_spread = 0
	/// The multiplier to the projectiles speed (a value of 2 makes it twice as slow, 0.5 makes it twice as fast)
	var/projectile_speed_multiplier = 1

/datum/action/cooldown/mob_cooldown/projectile_attack/Activate(atom/target_atom)
	StartCooldown(360 SECONDS, 360 SECONDS)
	attack_sequence(owner, target_atom)
	StartCooldown()

/datum/action/cooldown/mob_cooldown/projectile_attack/proc/attack_sequence(mob/living/firer, atom/target)
	shoot_projectile(firer, target, null, firer, rand(-default_projectile_spread, default_projectile_spread), null)

/datum/action/cooldown/mob_cooldown/projectile_attack/proc/shoot_projectile(atom/origin, atom/target, set_angle, mob/firer, projectile_spread, speed_multiplier, override_projectile_type, override_homing)
	var/turf/startloc = get_turf(origin)
	var/turf/endloc = get_turf(target)
	if(!startloc || !endloc)
		return
	var/obj/projectile/our_projectile
	if(override_projectile_type)
		our_projectile = new override_projectile_type(startloc)
	else
		our_projectile = new projectile_type(startloc)
	if(!isnum(speed_multiplier))
		speed_multiplier = projectile_speed_multiplier
	our_projectile.speed *= speed_multiplier
	our_projectile.preparePixelProjectile(endloc, startloc, null, projectile_spread)
	our_projectile.firer = firer
	if(target)
		our_projectile.original = target
	if(override_homing == null && has_homing || override_homing)
		our_projectile.homing_turn_speed = homing_turn_speed
		our_projectile.set_homing_target(target)
	if(isnum(set_angle))
		our_projectile.fire(set_angle)
		return
	our_projectile.fire()
	return our_projectile

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire
	name = "Rapid Fire"
	icon_icon = 'icons/obj/guns/energy.dmi'
	button_icon_state = "kineticgun"
	desc = "Fires projectiles repeatedly at a given target."
	cooldown_time = 1.5 SECONDS
	projectile_type = /obj/projectile/colossus/snowball
	default_projectile_spread = 45
	/// Total shot count
	var/shot_count = 60
	/// Delay between shots
	var/shot_delay = 0.1 SECONDS

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/attack_sequence(mob/living/firer, atom/target)
	for(var/i in 1 to shot_count)
		shoot_projectile(firer, target, null, firer, rand(-default_projectile_spread, default_projectile_spread), null)
		SLEEP_CHECK_DEATH(shot_delay, src)

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/direct
	shot_count = 40
	default_projectile_spread = 5

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/shrapnel
	name = "Shrapnel Fire"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Fires projectiles that will split into shrapnel after a period of time."
	cooldown_time = 6 SECONDS
	projectile_type = /obj/projectile/colossus/frost_orb
	has_homing = TRUE
	default_projectile_spread = 180
	shot_count = 8
	shot_delay = 1 SECONDS
	var/shrapnel_projectile_type = /obj/projectile/colossus/ice_blast
	var/shrapnel_angles = list(0, 60, 120, 180, 240, 300)
	var/shrapnel_spread = 60
	var/break_time = 2 SECONDS

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/shrapnel/attack_sequence(mob/living/firer, atom/target)
	for(var/i in 1 to shot_count)
		var/obj/projectile/to_explode = shoot_projectile(firer, target, null, firer, rand(-default_projectile_spread, default_projectile_spread), null)
		addtimer(CALLBACK(src, .proc/explode_into_shrapnel, firer, target, to_explode), break_time)
		SLEEP_CHECK_DEATH(shot_delay, src)

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/shrapnel/proc/explode_into_shrapnel(mob/living/firer, atom/target, obj/projectile/to_explode)
	if(!to_explode)
		return
	for(var/angle in shrapnel_angles)
		// no speed multiplier for shrapnel
		shoot_projectile(to_explode, target, angle + rand(-shrapnel_spread, shrapnel_spread), firer, null, 1, shrapnel_projectile_type, FALSE)
	qdel(to_explode)

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/shrapnel/strong
	name = "Strong Shrapnel Fire"
	shot_count = 16
	shot_delay = 0.5 SECONDS

/datum/action/cooldown/mob_cooldown/projectile_attack/spiral_shots
	name = "Spiral Shots"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Fires projectiles in a spiral pattern."
	cooldown_time = 3 SECONDS
	projectile_type = /obj/projectile/colossus
	projectile_sound = 'sound/magic/clockwork/invoke_general.ogg'
	/// Whether or not the attack is the enraged form
	var/enraged = FALSE

/datum/action/cooldown/mob_cooldown/projectile_attack/spiral_shots/attack_sequence(mob/living/firer, atom/target)
	if(enraged)
		SLEEP_CHECK_DEATH(1 SECONDS, firer)
		INVOKE_ASYNC(src, .proc/create_spiral_attack, firer, target, TRUE)
		create_spiral_attack(firer, target, FALSE)
		return
	create_spiral_attack(firer, target)

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
		playsound(get_turf(firer), projectile_sound, 20, TRUE)
		SLEEP_CHECK_DEATH(0.1 SECONDS, firer)

/datum/action/cooldown/mob_cooldown/projectile_attack/spiral_shots/colossus
	cooldown_time = 1.5 SECONDS

/datum/action/cooldown/mob_cooldown/projectile_attack/spiral_shots/colossus/Activate(atom/target_atom)
	SLEEP_CHECK_DEATH(1.5 SECONDS, owner)
	return ..()

/datum/action/cooldown/mob_cooldown/projectile_attack/random_aoe
	name = "All Directions"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "at_shield2"
	desc = "Fires projectiles in all directions."
	cooldown_time = 3 SECONDS
	projectile_type = /obj/projectile/colossus
	projectile_sound = 'sound/magic/clockwork/invoke_general.ogg'

/datum/action/cooldown/mob_cooldown/projectile_attack/random_aoe/attack_sequence(mob/living/firer, atom/target)
	var/turf/U = get_turf(firer)
	playsound(U, projectile_sound, 300, TRUE, 5)
	for(var/i in 1 to 32)
		shoot_projectile(firer, target, rand(0, 360), firer, null, null)

/datum/action/cooldown/mob_cooldown/projectile_attack/random_aoe/colossus
	cooldown_time = 1.5 SECONDS

/datum/action/cooldown/mob_cooldown/projectile_attack/random_aoe/colossus/Activate(atom/target_atom)
	SLEEP_CHECK_DEATH(1.5 SECONDS, owner)
	return ..()

/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast
	name = "Shotgun Fire"
	icon_icon = 'icons/obj/guns/ballistic.dmi'
	button_icon_state = "shotgun"
	desc = "Fires projectiles in a shotgun pattern."
	cooldown_time = 2 SECONDS
	projectile_type = /obj/projectile/colossus
	projectile_sound = 'sound/magic/clockwork/invoke_general.ogg'
	var/list/shot_angles = list(12.5, 7.5, 2.5, -2.5, -7.5, -12.5)

/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/attack_sequence(mob/living/firer, atom/target)
	fire_shotgun(firer, target, shot_angles)

/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/proc/fire_shotgun(mob/living/firer, atom/target, list/chosen_angles)
	playsound(firer, projectile_sound, 200, TRUE, 2)
	for(var/spread in chosen_angles)
		shoot_projectile(firer, target, null, firer, spread, null)


/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/colossus
	cooldown_time = 0.5 SECONDS

/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/colossus/Activate(atom/target_atom)
	SLEEP_CHECK_DEATH(1.5 SECONDS, owner)
	return ..()

/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/pattern
	name = "Alternating Shotgun Fire"
	desc = "Fires projectiles in an alternating shotgun pattern."
	projectile_type = /obj/projectile/colossus/ice_blast
	projectile_sound = null
	shot_angles = list(list(-40, -20, 0, 20, 40), list(-30, -10, 10, 30))
	var/shot_count = 5

/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/pattern/attack_sequence(mob/living/firer, atom/target)
	for(var/i in 1 to shot_count)
		var/list/pattern = shot_angles[i % length(shot_angles) + 1] // changing patterns
		fire_shotgun(firer, target, pattern)
		SLEEP_CHECK_DEATH(0.8 SECONDS, firer)


/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/pattern/circular
	name = "Circular Shotgun Fire"
	shot_angles = list(list(0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330), list(-30, -15, 0, 15, 30))

/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/pattern/circular/complete
	shot_angles = list(list(-180, -140, -100, -60, -20, 20, 60, 100, 140), list(-160, -120, -80, -40, 0, 40, 80, 120, 160))

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots
	name = "Directional Shots"
	icon_icon = 'icons/obj/guns/ballistic.dmi'
	button_icon_state = "pistol"
	desc = "Fires projectiles in specific directions."
	cooldown_time = 4 SECONDS
	projectile_type = /obj/projectile/colossus
	projectile_sound = 'sound/magic/clockwork/invoke_general.ogg'
	var/list/firing_directions

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/New(Target)
	. = ..()
	if(!firing_directions)
		firing_directions = GLOB.alldirs.Copy()

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/attack_sequence(mob/living/firer, atom/target)
	fire_in_directions(firer, target, firing_directions)

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/proc/fire_in_directions(mob/living/firer, atom/target, list/dirs)
	if(!islist(dirs))
		dirs = GLOB.alldirs.Copy()
	playsound(firer, projectile_sound, 200, TRUE, 2)
	for(var/d in dirs)
		var/turf/E = get_step(firer, d)
		shoot_projectile(firer, E, null, firer, null, null)

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/alternating
	name = "Alternating Shots"
	desc = "Fires projectiles in alternating directions."

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/alternating/attack_sequence(mob/living/firer, atom/target)
	fire_in_directions(firer, target, GLOB.diagonals)
	SLEEP_CHECK_DEATH(1 SECONDS, firer)
	fire_in_directions(firer, target, GLOB.cardinals)
	SLEEP_CHECK_DEATH(1 SECONDS, firer)
	fire_in_directions(firer, target, GLOB.diagonals)
	SLEEP_CHECK_DEATH(1 SECONDS, firer)
	fire_in_directions(firer, target, GLOB.cardinals)

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/alternating/colossus
	cooldown_time = 2.5 SECONDS

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/alternating/colossus/Activate(atom/target_atom)
	SLEEP_CHECK_DEATH(1.5 SECONDS, owner)
	return ..()

/datum/action/cooldown/mob_cooldown/projectile_attack/kinetic_accelerator
	name = "Fire Kinetic Accelerator"
	icon_icon = 'icons/obj/guns/energy.dmi'
	button_icon_state = "kineticgun"
	desc = "Fires a kinetic accelerator projectile at the target."
	cooldown_time = 1.5 SECONDS
	projectile_type = /obj/projectile/kinetic/miner
	projectile_sound = 'sound/weapons/kenetic_accel.ogg'

/datum/action/cooldown/mob_cooldown/projectile_attack/kinetic_accelerator/Activate(atom/target_atom)
	. = ..()
	playsound(owner, projectile_sound, 200, TRUE, 2)
	owner.visible_message(span_danger("[owner] fires the proto-kinetic accelerator!"))
	owner.face_atom(target_atom)
	new /obj/effect/temp_visual/dir_setting/firing_effect(owner.loc, owner.dir)

/datum/action/cooldown/mob_cooldown/projectile_attack/colossus_final
	name = "Titan's Finale"
	desc = "A single-use ability that shoots a large amount of projectiles around you."
	cooldown_time = 2.5 SECONDS

/datum/action/cooldown/mob_cooldown/projectile_attack/colossus_final/Activate(atom/target_atom)
	StartCooldown(360 SECONDS, 360 SECONDS)
	attack_sequence(owner, target_atom)
	StartCooldown()
	Remove(owner)

/datum/action/cooldown/mob_cooldown/projectile_attack/colossus_final/attack_sequence(mob/living/firer, atom/target)
	var/mob/living/simple_animal/hostile/megafauna/colossus/colossus
	if(istype(firer, /mob/living/simple_animal/hostile/megafauna/colossus))
		colossus = firer
		colossus.say("Perish.", spans = list("colossus", "yell"))

	var/finale_counter = 10
	for(var/i in 1 to 20)
		if(finale_counter > 4 && colossus)
			colossus.telegraph()
			colossus.shotgun_blast.attack_sequence(firer, target)

		if(finale_counter > 1)
			finale_counter -= 1

		var/turf/start_turf = get_turf(firer)
		for(var/turf/target_turf in RANGE_TURFS(12, start_turf))
			if(prob(min(finale_counter, 2)) && target_turf != get_turf(firer))
				shoot_projectile(firer, target_turf, null, firer, null, null)

		SLEEP_CHECK_DEATH(finale_counter + 1, firer)

	for(var/i in 1 to 3)
		if(colossus)
			colossus.telegraph()
			colossus.random_shots.attack_sequence(firer, target)
		finale_counter += 6
		SLEEP_CHECK_DEATH(finale_counter, firer)

	for(var/i in 1 to 3)
		if(colossus)
			colossus.telegraph()
			colossus.dir_shots.attack_sequence(firer, target)
		SLEEP_CHECK_DEATH(1 SECONDS, firer)
