#define WENDIGO_ENRAGED (health <= maxHealth*0.5)

/*

Difficulty: Hard

*/

/mob/living/simple_animal/hostile/megafauna/wendigo
	name = "wendigo"
	desc = "A mythological man-eating legendary creature, the sockets of it's eyes track you with an unsatiated hunger."
	health = 2500
	maxHealth = 2500
	icon_state = "wendigo"
	icon_living = "wendigo"
	icon_dead = "wendigo_dead"
	icon = 'icons/mob/simple/icemoon/64x64megafauna.dmi'
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	weather_immunities = list(TRAIT_SNOWSTORM_IMMUNE)
	speak_emote = list("roars")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	vision_range = 9
	aggro_vision_range = 18 // man-eating for a reason
	speed = 6
	move_to_delay = 6
	ranged = TRUE
	pixel_x = -16
	base_pixel_x = -16
	gps_name = "Berserk Signal"
	loot = list()
	butcher_results = list()
	guaranteed_butcher_results = list(/obj/item/wendigo_blood = 1, /obj/item/wendigo_skull = 1)
	crusher_loot = list(/obj/item/crusher_trophy/wendigo_horn)
	wander = FALSE
	del_on_death = FALSE
	blood_volume = BLOOD_VOLUME_NORMAL
	achievement_type = /datum/award/achievement/boss/wendigo_kill
	crusher_achievement_type = /datum/award/achievement/boss/wendigo_crusher
	score_achievement_type = /datum/award/score/wendigo_score
	death_message = "falls to the ground in a bloody heap, shaking the arena."
	death_sound = 'sound/effects/gravhit.ogg'
	footstep_type = FOOTSTEP_MOB_HEAVY
	summon_line = "GwaHOOOOOOOOOOOOOOOOOOOOO"
	/// Saves the turf the megafauna was created at (spawns exit portal here)
	var/turf/starting
	/// Range for wendigo stomping when it moves
	var/stomp_range = 1
	/// Stores directions the mob is moving, then calls that a move has fully ended when these directions are removed in moved
	var/stored_move_dirs = 0
	/// Time before the wendigo can scream again
	var/scream_cooldown_time = 10 SECONDS
	/// Teleport Ability
	var/datum/action/cooldown/mob_cooldown/teleport/teleport
	/// Shotgun Ability
	var/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/wendigo/shotgun_blast
	/// Ground Slam Ability
	var/datum/action/cooldown/mob_cooldown/ground_slam/ground_slam
	/// Alternating Projectiles Ability
	var/datum/action/cooldown/mob_cooldown/projectile_attack/alternating_circle/alternating_circle
	/// Spiral Projectiles Ability
	var/datum/action/cooldown/mob_cooldown/projectile_attack/spiral_shots/wendigo/spiral
	/// Wave Projectiles Ability
	var/datum/action/cooldown/mob_cooldown/projectile_attack/wave/wave
	/// Stores the last scream time so it doesn't spam it
	COOLDOWN_DECLARE(scream_cooldown)

/mob/living/simple_animal/hostile/megafauna/wendigo/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	teleport = new(src)
	shotgun_blast = new(src)
	ground_slam = new(src)
	alternating_circle = new(src)
	spiral = new(src)
	wave = new(src)
	teleport.Grant(src)
	shotgun_blast.Grant(src)
	ground_slam.Grant(src)
	alternating_circle.Grant(src)
	spiral.Grant(src)
	wave.Grant(src)

/mob/living/simple_animal/hostile/megafauna/wendigo/Initialize(mapload)
	. = ..()
	starting = get_turf(src)

/mob/living/simple_animal/hostile/megafauna/wendigo/OpenFire()
	update_cooldowns(list(COOLDOWN_UPDATE_SET_MELEE = 10 SECONDS, COOLDOWN_UPDATE_SET_RANGED = 10 SECONDS))
	if(WENDIGO_ENRAGED)
		speed = 4
		move_to_delay = 4
	else
		stomp_range = initial(stomp_range)
		speed = initial(speed)
		move_to_delay = initial(move_to_delay)

	if(client)
		return

	var/mob/living/living_target = target
	if(istype(living_target) && living_target.stat == DEAD)
		return

	if(COOLDOWN_FINISHED(src, scream_cooldown))
		chosen_attack = rand(1, 3)
	else
		chosen_attack = rand(1, 2)
	switch(chosen_attack)
		if(1)
			ground_slam.Activate(target)
		if(2)
			teleport.Activate(target)
			if(WENDIGO_ENRAGED)
				shotgun_blast.Activate(target)
		if(3)
			do_teleport(src, starting, 0,  channel=TELEPORT_CHANNEL_BLUESPACE, forced = TRUE)
			var/shockwave_attack
			if(WENDIGO_ENRAGED)
				shockwave_attack = rand(1, 3)
			else
				shockwave_attack = rand(1, 2)
			switch(shockwave_attack)
				if(1)
					alternating_circle.enraged = WENDIGO_ENRAGED
					alternating_circle.Activate(target)
				if(2)
					spiral.enraged = WENDIGO_ENRAGED
					spiral.Activate(target)
				if(3)
					wave.Activate(target)
			update_cooldowns(list(COOLDOWN_UPDATE_SET_MELEE = 3 SECONDS, COOLDOWN_UPDATE_SET_RANGED = 3 SECONDS))

/mob/living/simple_animal/hostile/megafauna/wendigo/Move(atom/newloc, direct)
	stored_move_dirs |= direct
	. = ..()
	// Remove after anyways in case the movement was prevented
	stored_move_dirs &= ~direct

/mob/living/simple_animal/hostile/megafauna/wendigo/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	stored_move_dirs &= ~movement_dir
	if(!stored_move_dirs)
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(wendigo_slam), src, stomp_range, 1, 8)

/proc/wendigo_scream(mob/owner)
	SLEEP_CHECK_DEATH(5, owner)
	playsound(owner.loc, 'sound/magic/demon_dies.ogg', 600, FALSE, 10)
	var/pixel_shift = rand(5, 15)
	animate(owner, pixel_z = pixel_shift, time = 1, loop = 20, flags = ANIMATION_RELATIVE)
	animate(pixel_z = -pixel_shift, time = 1, flags = ANIMATION_RELATIVE)
	for(var/mob/living/dizzy_target in get_hearers_in_view(7, owner) - owner)
		dizzy_target.set_dizzy_if_lower(12 SECONDS)
		to_chat(dizzy_target, span_danger("[owner] screams loudly!"))
	SLEEP_CHECK_DEATH(1 SECONDS, owner)

/proc/wendigo_slam(mob/owner, range, delay, throw_range)
	var/turf/origin = get_turf(owner)
	if(!origin)
		return
	var/list/all_turfs = RANGE_TURFS(range, origin)
	for(var/sound_range = 0 to range)
		playsound(origin,'sound/effects/bamf.ogg', 600, TRUE, 10)
		for(var/turf/stomp_turf in all_turfs)
			if(get_dist(origin, stomp_turf) > sound_range)
				continue
			new /obj/effect/temp_visual/small_smoke/halfsecond(stomp_turf)
			for(var/mob/living/hit_mob in stomp_turf)
				if(hit_mob == owner || hit_mob.throwing)
					continue
				to_chat(hit_mob, span_userdanger("[owner]'s ground slam shockwave sends you flying!"))
				var/turf/thrownat = get_ranged_target_turf_direct(owner, hit_mob, throw_range, rand(-10, 10))
				hit_mob.throw_at(thrownat, 8, 2, null, TRUE, force = MOVE_FORCE_OVERPOWERING, gentle = TRUE)
				hit_mob.apply_damage(20, BRUTE, wound_bonus=CANT_WOUND)
				shake_camera(hit_mob, 2, 1)
			all_turfs -= stomp_turf
		SLEEP_CHECK_DEATH(delay, owner)

/mob/living/simple_animal/hostile/megafauna/wendigo/death(gibbed, list/force_grant)
	if(health > 0)
		return

	if(!true_spawn)
		return ..()

	var/obj/effect/portal/permanent/one_way/exit = new /obj/effect/portal/permanent/one_way(starting)
	exit.id = "wendigo arena exit"
	exit.add_atom_colour(COLOR_RED_LIGHT, ADMIN_COLOUR_PRIORITY)
	exit.set_light(20, 1, COLOR_SOFT_RED)
	return ..()

/obj/projectile/colossus/wendigo_shockwave
	name = "wendigo shockwave"
	speed = 2
	/// If wave movement is enabled
	var/wave_movement = FALSE
	/// Amount the angle changes every pixel move
	var/wave_speed = 15
	/// Amount of movements this projectile has made
	var/pixel_moves = 0

/obj/projectile/colossus/wendigo_shockwave/spiral
	damage = 15

/obj/projectile/colossus/wendigo_shockwave/wave
	speed = 8
	wave_movement = TRUE
	wave_speed = 10

/obj/projectile/colossus/wendigo_shockwave/wave/alternate
	wave_speed = -10

/obj/projectile/colossus/wendigo_shockwave/pixel_move(trajectory_multiplier, hitscanning = FALSE)
	. = ..()
	if(wave_movement)
		pixel_moves++
		set_angle(original_angle + pixel_moves * wave_speed)

/obj/item/wendigo_blood
	name = "bottle of wendigo blood"
	desc = "A bottle of viscous red liquid... You're not actually going to drink this, are you?"
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "vial"

/obj/item/wendigo_blood/attack_self(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(!human_user.mind)
		return
	to_chat(human_user, span_danger("Power courses through you! You can now shift your form at will."))
	var/datum/action/cooldown/spell/shapeshift/polar_bear/transformation_spell = new(user.mind || user)
	transformation_spell.Grant(user)
	playsound(human_user.loc, 'sound/items/drink.ogg', rand(10,50), TRUE)
	qdel(src)

/obj/item/crusher_trophy/wendigo_horn
	name = "wendigo horn"
	desc = "A gnarled horn ripped from the skull of a wendigo. Suitable as a trophy for a kinetic crusher."
	icon_state = "wendigo_horn"
	denied_type = /obj/item/crusher_trophy/wendigo_horn

/obj/item/crusher_trophy/wendigo_horn/effect_desc()
	return "melee hits inflict twice as much damage"

/obj/item/crusher_trophy/wendigo_horn/add_to(obj/item/kinetic_crusher/crusher, mob/living/user)
	. = ..()
	if(.)
		crusher.AddComponent(/datum/component/two_handed, force_wielded=40)

/obj/item/crusher_trophy/wendigo_horn/remove_from(obj/item/kinetic_crusher/crusher, mob/living/user)
	. = ..()
	if(.)
		crusher.AddComponent(/datum/component/two_handed, force_wielded=20)

/obj/item/wendigo_skull
	name = "wendigo skull"
	desc = "A bloody skull torn from a murderous beast, the soulless eye sockets seem to constantly track your movement."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "wendigo_skull"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0

#undef WENDIGO_ENRAGED
