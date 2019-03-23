/obj/structure/infection/turret
	name = "infection turret"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob"
	desc = "A solid wall with a radiating material on the inside."
	max_integrity = 150
	point_return = 4
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 90, "acid" = 90)
	upgrade_type = "Turret"
	cost_per_level = 70
	extra_description = "Fires faster and further, and irradiates the target."
	var/damaged_icon = "infection_turret_damaged"
	var/damaged_desc = "A weakened wall with leaking radiating material."
	var/damaged_name = "weakened strong infection"
	var/frequency = 1 // amount of times the turret will fire per process tick (1 second)
	var/scan_range = 7 // range to search for targets

/obj/structure/infection/turret/Initialize()
	START_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/infection/turret/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/infection/turret/do_upgrade()
	frequency++
	scan_range++
	if(infection_level == 2)
		extra_description = "Fires faster and further, and disorients the target."

/obj/structure/infection/turret/update_icon()
	cut_overlays()
	color = null
	var/mutable_appearance/infection_overlay = mutable_appearance('icons/mob/blob.dmi', "blob")
	if(overmind)
		infection_overlay.color = overmind.infection_color
	add_overlay(infection_overlay)
	add_overlay(mutable_appearance('icons/mob/infection.dmi', "infection_turret"))

/obj/structure/infection/turret/Life()
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

/obj/structure/infection/turret/proc/in_faction(mob/target)
	if(ROLE_INFECTION in target.faction)
		return TRUE
	return FALSE

/obj/structure/infection/turret/proc/tryToShootAt(list/atom/movable/targets)
	while(targets.len > 0)
		var/atom/movable/M = pick(targets)
		targets -= M
		if(target(M))
			return 1

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

/obj/structure/infection/turret/proc/shootAt(atom/movable/target)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if(!istype(T) || !istype(U))
		return

	update_icon()
	var/obj/item/projectile/A = new /obj/item/projectile/bullet/infection(T)
	playsound(loc, 'sound/weapons/gunshot_smg.ogg', 75, 1)

	if(infection_level == 2)
		A.irradiate = 1
	if(infection_level == 3)
		A.jitter = 1
		A.eyeblur = 1

	//Shooting Code:
	A.preparePixelProjectile(target, T)
	A.firer = src
	A.fire()
	return A

/obj/item/projectile/bullet/infection
	name = "projectile infection"
	icon = 'icons/mob/infection.dmi'
	icon_state = "bullet"
	damage = 20
	damage_type = BRUTE
	pass_flags = PASSTABLE | PASSBLOB
	nodamage = FALSE
	flag = "bullet"
	hitsound_wall = "ricochet"
	impact_effect_type = /obj/effect/temp_visual/impact_effect
