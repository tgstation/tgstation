GLOBAL_LIST_INIT(commander_phrases, list("He says the phrase."))

GLOBAL_LIST_EMPTY(infection_beacons)
GLOBAL_LIST_EMPTY(beacon_spawns)

/obj/effect/landmark/beacon_start
	name = "beaconstart"
	icon_state = "beacon_start"

/obj/effect/landmark/beacon_start/Initialize(mapload)
	..()
	GLOB.beacon_spawns += src

/obj/effect/landmark/beacon_start/west
	name = "beaconstartwest"
	dir = WEST

/obj/effect/landmark/beacon_start/east
	name = "beaconstarteast"
	dir = EAST

/obj/effect/landmark/beacon_start/north
	name = "beaconstartnorth"
	dir = NORTH

/obj/effect/landmark/beacon_start/south
	name = "beaconstartsouth"
	dir = SOUTH

/obj/structure/beacon_generator
	name = "beacon generator"
	icon = 'icons/mob/blob.dmi'
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
	var/mob/camera/commander/C = GLOB.infection_commander
	C.upgrade_points++
	C.all_upgrade_points++
	for(var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/spore in C.infection_mobs)
		spore.upgrade_points++
	if(GLOB.infection_beacons.len > 1)
		addtimer(CALLBACK(src, .proc/destroyed_announcement), 80)
	return ..()

/obj/structure/beacon_generator/proc/destroyed_announcement()
	priority_announce("We've lost a beacon, we only have [GLOB.infection_beacons.len] left. Remember, [pick(GLOB.commander_phrases)]","Biohazard Containment Commander", 'sound/misc/notice1.ogg')

/obj/structure/beacon_generator/process()
	obj_integrity = min(obj_integrity + 10, max_integrity)
	update_icon()

/obj/structure/beacon_generator/blob_act()
	obj_integrity -= 50
	update_icon()
	if(obj_integrity <= 0)
		playsound(src.loc, 'sound/magic/repulse.ogg', 300, 1, 10, pressure_affected = FALSE)
		var/mob/camera/commander/OM = GLOB.infection_commander
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
			playsound(B.loc, 'sound/mecha/mechstep.ogg', 300, 1, 10, pressure_affected = FALSE)
		if(secondfound)
			var/obj/structure/beacon_wall/B = new /obj/structure/beacon_wall(secondfound.loc)
			B.forceMove(secondfound)
			walls += B
			playsound(B.loc, 'sound/mecha/mechstep.ogg', 300, 1, 10, pressure_affected = FALSE)
		sleep(2)

/obj/structure/beacon_generator/singularity_act()
	return

/obj/structure/beacon_generator/singularity_pull()
	return

/obj/structure/beacon_wall
	name = "beacon wall"
	icon = 'icons/mob/blob.dmi'
	icon_state = "beaconbarrier"
	light_range = 4
	desc = "A generated wall keeping any infection out."
	density = FALSE
	anchored = TRUE
	layer = FLY_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	CanAtmosPass = ATMOS_PASS_NO
	resistance_flags = INDESTRUCTIBLE

/obj/structure/beacon_wall/blob_act()
	return

/obj/structure/beacon_wall/singularity_act()
	return

/obj/structure/beacon_wall/singularity_pull()
	return

/obj/structure/beacon_wall/CanPass(atom/movable/mover, turf/target)
	if(mover.GetComponent(/datum/component/no_beacon_crossing))
		return FALSE
	return TRUE

/datum/component/no_beacon_crossing
	var/atom/parentatom

/datum/component/no_beacon_crossing/Initialize()
	parentatom = parent
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/check_passed)

/datum/component/no_beacon_crossing/proc/check_passed()
	if(isobj(parentatom.loc))
		return
	// if you somehow got past a beacon wall then time to die
	var/obj/structure/beacon_generator/closest
	var/obj/structure/infection/core/C = GLOB.infection_core
	if(!C)
		return
	for(var/obj/structure/beacon_generator/BG in GLOB.infection_beacons)
		if(!closest)
			closest = BG
			continue
		if(get_dist(C, closest) > get_dist(C, BG))
			closest = BG
	var/obj/structure/beacon_wall/edge = closest.walls[1]
	var/facingdir = closest.dir
	var/should_die = FALSE
	if(facingdir == NORTH && edge.y <= parentatom.y)
		should_die = TRUE
	if(facingdir == SOUTH && edge.y >= parentatom.y)
		should_die = TRUE
	if(facingdir == EAST && edge.x >= parentatom.x)
		should_die = TRUE
	if(facingdir == WEST && edge.x <= parentatom.x)
		should_die = TRUE
	if(isobj(parentatom.loc))
		should_die = FALSE // don't kill them if they're in a locker, or something is holding them
	if(should_die)
		// time to go
		parentatom.visible_message("[parentatom] dissolves into nothing as the energy of the beacons destroys it!")
		playsound(get_turf(parentatom), 'sound/effects/supermatter.ogg', 50, 1)
		if(isliving(parent))
			var/mob/living/todie = parent
			todie.death()
		else
			qdel(parent)
