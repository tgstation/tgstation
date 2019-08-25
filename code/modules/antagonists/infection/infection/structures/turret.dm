/*
	A turret that fires at enemies that enter its radius
*/

/obj/structure/infection/turret
	name = "infection turret"
	desc = "A solid wall with a radiating material on the inside."
	icon = 'icons/mob/infection/crystaline_infection_medium.dmi'
	icon_state = "crystalturret-layer"
	pixel_x = -16
	pixel_y = -4
	max_integrity = 150
	point_return = 10
	build_time = 100
	upgrade_subtype = /datum/infection_upgrade/turret
	// the amount of times the turret will fire every time it finds a target
	var/frequency = 1
	// the range that this turret will search to find targets
	var/scan_range = 8
	// the projectile shot from this turret
	var/projectile_type = /obj/item/projectile/bullet/infection
	// the projectiles sound when it is fired
	var/projectile_sound = 'sound/effects/crystal_fire.ogg'
	// the sound when the projectile hits the person
	var/hit_sound = 'sound/effects/crystal_turret_hitsound.ogg'

/obj/structure/infection/turret/Initialize()
	. = ..()
	dir = NORTH
	START_PROCESSING(SSobj, src)

/obj/structure/infection/turret/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/infection/turret/update_icon()
	. = ..()
	underlays.Cut()
	var/mutable_appearance/turret_base = mutable_appearance('icons/mob/infection/crystaline_infection_medium.dmi', "crystalturret-base")
	var/mutable_appearance/infection_base = mutable_appearance('icons/mob/infection/infection.dmi', "normal")
	turret_base.dir = dir
	infection_base.pixel_x = -pixel_x
	infection_base.pixel_y = -pixel_y
	underlays += turret_base
	underlays += infection_base

/obj/structure/infection/turret/Life()
	if(!overmind)
		return
	var/list/targets = list()
	for(var/mob/A in view(scan_range, src))
		if(A.invisibility > SEE_INVISIBLE_LIVING)
			continue

		if(isanimal(A))
			var/mob/living/simple_animal/SA = A
			if(SA.stat || in_faction(SA)) //don't target if dead or in faction
				continue
			targets += SA
			continue

		if(issilicon(A))
			var/mob/living/silicon/sillycone = A

			if(ispAI(A))
				continue

			if(sillycone.stat || in_faction(sillycone))
				continue

			targets += sillycone
			continue

		if(iscarbon(A))
			var/mob/living/carbon/C = A

			if(C.stat == DEAD)
				continue

			if(!in_faction(C))
				targets += C

	for(var/A in GLOB.mechas_list)
		if((get_dist(A, src) < scan_range) && can_see(src, A, scan_range))
			targets += A

	if(targets.len)
		tryToShootAt(targets)

/*
	Checks if they're in the infection faction and to ignore them as a target
*/
/obj/structure/infection/turret/proc/in_faction(mob/target)
	if(ROLE_INFECTION in target.faction)
		return TRUE
	return FALSE

/*
	Tries to shoot at the target
*/
/obj/structure/infection/turret/proc/tryToShootAt(list/atom/movable/targets)
	while(targets.len > 0)
		var/atom/movable/M = pick(targets)
		targets -= M
		if(target(M))
			return 1

/*
	If we can actually shoot them, queue up all of the shots that need to happen
*/
/obj/structure/infection/turret/proc/target(atom/movable/target)
	if(target && frequency)
		var/diffTime = SSprocessing.wait / frequency
		var/timePassed = 0
		while(timePassed < SSprocessing.wait)
			setDir(get_dir(src, target)) //even if you can't shoot, follow the target
			addtimer(CALLBACK(src, .proc/shootAt, target), timePassed)
			timePassed += diffTime
		return 1
	return

/*
	Actually fire the projectile at the target now
*/
/obj/structure/infection/turret/proc/shootAt(atom/movable/target)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if(!istype(T) || !istype(U))
		return

	setDir(get_dir(src, target))
	update_icon()
	var/obj/item/projectile/bullet/infection/A = new projectile_type(T)
	playsound(loc, projectile_sound, 75, 1, pressure_affected = FALSE)
	A.hitsound = hit_sound

	//Shooting Code:
	A.preparePixelProjectile(target, T)
	A.firer = src
	A.fired_from = src
	A.fire()
	return A

/obj/item/projectile/bullet/infection
	name = "energy shot"
	icon = 'icons/mob/infection/crystal_effect.dmi'
	icon_state = "lightning-projectile"
	layer = ABOVE_MOB_LAYER
	damage = 15
	speed = 2.5
	damage_type = BRUTE
	pass_flags = PASSTABLE | PASSBLOB
	nodamage = FALSE
	flag = "bullet"
	hitsound_wall = "ricochet"
	impact_effect_type = /obj/effect/temp_visual/impact_effect

/obj/item/projectile/bullet/infection/flak
	name = "energy burst"
	damage = 10
	speed = 2

/obj/structure/infection/turret/core
	name = "core turret"
	desc = "A turret for the core of the infection. It holds destructive capabilities that many might find unbeatable."
	point_return = -1
	upgrade_subtype = null

/obj/structure/infection/turret/core/Initialize()
	. = ..()
	AddComponent(/datum/component/summoning, list(/mob/living/simple_animal/hostile/infection/infectionspore), 10, 4, 0, "forms from the raw energy!", 'sound/effects/blobattack.ogg')
