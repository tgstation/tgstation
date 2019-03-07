/obj/structure/beacon_generator
	name = "beacon generator"
	icon = 'icons/mob/infection.dmi'
	icon_state = "generator"
	light_range = 4
	desc = "It sustains the barriers."
	density = TRUE
	anchored = TRUE
	layer = FLY_LAYER
	CanAtmosPass = ATMOS_PASS_PROC
	max_integrity = 1000
	resistance_flags = INDESTRUCTIBLE
	var/list/walls = list()

/obj/structure/beacon_generator/Initialize(mapload)
	START_PROCESSING(SSobj,src)
	. = ..()
	GLOB.infection_beacons += src
	update_icon()

/obj/structure/beacon_generator/Destroy()
	STOP_PROCESSING(SSobj,src)
	for(var/obj/structure/beacon_wall/D in walls)
		qdel(D)
	GLOB.infection_beacons -= src
	return ..()

/obj/structure/beacon_generator/process()
	obj_integrity = min(obj_integrity + 10, max_integrity)
	update_icon()

/obj/structure/beacon_generator/blob_act()
	obj_integrity -= 50
	update_icon()
	if(obj_integrity <= 0)
		playsound(src.loc, 'sound/magic/repulse.ogg', 300, 1, 10, pressure_affected = FALSE)
		for(var/obj/structure/infection/core/C in GLOB.infection_cores)
			var/mob/camera/commander/OM = C.overmind
			OM.playsound_local(OM, 'sound/magic/repulse.ogg', 300, 1)
		var/explodeloc = src.loc
		qdel(src)
		for(var/i = 1 to 5)
			for(var/atom/A in urange(i, explodeloc) - urange(i - 1, explodeloc))
				A.ex_act(EXPLODE_LIGHT)
				if(istype(A, /obj/structure/infection))
					var/obj/structure/infection/INF = A
					INF.take_damage(1000, BRUTE, "bomb", 0)
			sleep(4)
	else
		playsound(src.loc, 'sound/effects/empulse.ogg', 300, 1, 10, pressure_affected = FALSE)
		for(var/obj/structure/infection/core/C in GLOB.infection_cores)
			var/mob/camera/commander/OM = C.overmind
			OM.playsound_local(OM, 'sound/effects/empulse.ogg', 300, 1)

/obj/structure/beacon_generator/update_icon()
	vis_contents.Cut()
	var/obj/effect/overlay/vis/shield_overlay = new
	shield_overlay.icon = 'icons/effects/effects.dmi'
	shield_overlay.icon_state = "shield"
	shield_overlay.layer = layer
	var/matrix/M = matrix()
	var/scale = (obj_integrity / max_integrity) * 3
	M.Scale(scale, scale)
	shield_overlay.transform = M
	vis_contents += shield_overlay

/obj/structure/beacon_generator/proc/generateWalls()
	var/direction = dir
	var/turf/from = get_ranged_target_turf(src, turn(direction, 180), 5)
	var/turf/first = get_edge_target_turf(from, turn(direction, 90))
	var/turf/second = get_edge_target_turf(from, turn(direction, -90))
	var/list/firstside = getline(from, first) - from
	var/list/secondside = getline(from, second) - from
	var/obj/structure/beacon_wall/original = new /obj/structure/beacon_wall(from.loc)
	original.forceMove(from)
	walls += original
	for(var/i = 1 to (firstside.len > secondside.len ? firstside.len : secondside.len))
		var/turf/firstfound = i <= firstside.len ? firstside[i] : null
		var/turf/secondfound = i <= secondside.len ? secondside[i] : null
		if(firstfound)
			var/obj/structure/beacon_wall/B = new /obj/structure/beacon_wall(firstfound.loc)
			B.forceMove(firstfound)
			walls += B
		if(secondfound)
			var/obj/structure/beacon_wall/B = new /obj/structure/beacon_wall(secondfound.loc)
			B.forceMove(secondfound)
			walls += B
		playsound(src.loc, 'sound/mecha/mechstep.ogg', 300, 1, 10, pressure_affected = FALSE)
		sleep(2)

/obj/structure/beacon_generator/singularity_act()
	return

/obj/structure/beacon_generator/singularity_pull()
	return

/obj/structure/beacon_generator/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /mob/living/simple_animal/hostile/infection))
		return 0
	if(istype(mover, /obj/structure/infection))
		return 0
	return 1

/obj/structure/beacon_wall
	name = "beacon wall"
	icon = 'icons/mob/infection.dmi'
	icon_state = "beaconbarrier"
	light_range = 4
	desc = "A generated wall keeping any infection out."
	density = FALSE
	anchored = TRUE
	layer = FLY_LAYER
	CanAtmosPass = ATMOS_PASS_NO
	resistance_flags = INDESTRUCTIBLE

/obj/structure/beacon_wall/blob_act()
	return

/obj/structure/beacon_wall/singularity_act()
	return

/obj/structure/beacon_wall/singularity_pull()
	return

/obj/structure/beacon_wall/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /mob/living/simple_animal/hostile/infection))
		return 0
	if(istype(mover, /obj/structure/infection))
		return 0
	return 1