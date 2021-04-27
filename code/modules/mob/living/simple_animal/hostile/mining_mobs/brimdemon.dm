/mob/living/simple_animal/hostile/asteroid/brimdemon
	name = "brimdemon"
	desc = "A beast from demonic flesh. Fires a blood laser barrage, known to humans as a \"brimbeam\"."
	icon = 'icons/mob/brimdemon.dmi'
	icon_state = "brimdemon"
	icon_living = "brimdemon"
	icon_dead = "brimdemon_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak_emote = list("cackles")
	emote_hear = list("cackles","screeches")
	combat_mode = TRUE
	ranged = TRUE
	ranged_cooldown_time = 5 SECONDS
	vision_range = 9
	retreat_distance = 2
	speed = 5
	move_to_delay = 5
	maxHealth = 200
	health = 200
	obj_damage = 15
	melee_damage_lower = 7.5
	melee_damage_upper = 7.5
	rapid_melee = 2 // every second attack
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	butcher_results = list(/obj/item/food/meat/slab = 2)
	loot = list()
	robust_searching = TRUE
	footstep_type = FOOTSTEP_MOB_CLAW
	deathmessage = "screams in agony as they get fcking OWNED."
	deathsound = 'sound/magic/demon_dies.ogg'
	/// Are we charging/firing? If yes stops our movement.
	var/firing = FALSE
	/// A list of all the beam parts.
	var/list/beamparts = list()

/mob/living/simple_animal/hostile/asteroid/brimdemon/OpenFire()
	if(firing)
		to_chat(src, "<span class='warning'>You are already firing!</span>")
		return
	face_atom(target)
	firing = TRUE
	icon_state = "brimdemon_firing"
	move_resist = MOVE_FORCE_VERY_STRONG
	add_overlay("brimdemon_telegraph_dir")
	visible_message("<span class='danger'>[src] starts charging!</span>", "<span class='notice'>You start charging...</span>")
	addtimer(CALLBACK(src, .proc/fire_laser), 1.5 SECONDS)
	ranged_cooldown = world.time + ranged_cooldown_time

/mob/living/simple_animal/hostile/asteroid/brimdemon/death()
	firing = FALSE
	cut_overlay("brimdemon_telegraph_dir")
	move_resist = initial(move_resist)
	return ..()

/mob/living/simple_animal/hostile/asteroid/brimdemon/Goto(target, delay, minimum_distance)
	if(firing)
		return FALSE
	..()

/mob/living/simple_animal/hostile/asteroid/brimdemon/MoveToTarget(list/possible_targets)
	if(firing)
		return FALSE
	if((target in possible_targets) && ISDIAGONALDIR(get_dir(src, target)))
		if(get_dist(src, target) == minimum_distance)
			sidestep()
		else
			Goto(target,move_to_delay,minimum_distance)
		possible_targets -= target
	..()

/mob/living/simple_animal/hostile/asteroid/brimdemon/Move(list/possible_targets)
	if(firing)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/asteroid/brimdemon/proc/fire_laser()
	if(stat == DEAD)
		return
	visible_message("<span class='danger'>[src] fires a brimbeam!</span>", "<span class='notice'>You fire a brimbeam!</span>")
	playsound(src, 'sound/creatures/brimdemon.ogg', 100, FALSE, 0, 3)
	cut_overlay("brimdemon_telegraph_dir")
	var/turf/target_turf = get_ranged_target_turf(src, dir, 10)
	var/turf/origin_turf = get_turf(src)
	var/list/affected_turfs = getline(origin_turf, target_turf) - origin_turf
	for(var/turf/affected_turf in affected_turfs)
		var/blocked = FALSE
		if(affected_turf.opacity)
			blocked = TRUE
		for(var/obj/potential_block in affected_turf.contents)
			if(potential_block.opacity)
				blocked = TRUE
				break
		if(blocked)
			break
		var/atom/new_brimbeam = new /obj/effect/brimbeam(affected_turf)
		new_brimbeam.dir = dir
		beamparts += new_brimbeam
		for(var/mob/living/hit_mob in affected_turf.contents)
			if(istype(hit_mob, /mob/living/simple_animal/hostile/asteroid/brimdemon))
				continue
			hit_mob.adjustFireLoss(25)
			to_chat(hit_mob, "<span class='userdanger'>You're hit by [src]'s brimbeam!</span>")
	if(length(beamparts))
		var/atom/last_brimbeam = beamparts[length(beamparts)]
		last_brimbeam.icon_state = "brimbeam_end"
		var/atom/first_brimbeam = beamparts[1]
		first_brimbeam.icon_state = "brimbeam_start"
	addtimer(CALLBACK(src, .proc/end_laser), 2 SECONDS)

/mob/living/simple_animal/hostile/asteroid/brimdemon/proc/end_laser()
	if(stat != DEAD)
		icon_state = initial(icon_state)
	move_resist = initial(move_resist)
	firing = FALSE
	for(var/obj/effect/brimbeam/beam in beamparts)
		animate(beam, time = 0.5 SECONDS, alpha = 0)
		QDEL_IN(beam, 0.5 SECONDS)
		beamparts -= beam

/obj/effect/brimbeam
	name = "brimbeam"
	icon = 'icons/mob/brimdemon.dmi'
	icon_state = "brimbeam_mid"
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_power = 3
	light_range = 2

/obj/effect/brimbeam/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/effect/brimbeam/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/effect/brimbeam/process()
	for(var/mob/living/hit_mob in get_turf(src))
		damage(hit_mob)

/obj/effect/brimbeam/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(isliving(AM))
		damage(AM)

/obj/effect/brimbeam/proc/damage(mob/living/hit_mob)
	if(istype(hit_mob, /mob/living/simple_animal/hostile/asteroid/brimdemon))
		return
	hit_mob.adjustFireLoss(5)
	to_chat(hit_mob, "<span class='danger'>You're damaged by [src]!</span>")
