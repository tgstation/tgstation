GLOBAL_LIST_INIT(commander_phrases, list("He says the phrase."))

GLOBAL_LIST_EMPTY(infection_beacons)
GLOBAL_LIST_EMPTY(beacon_spawns)

/obj/effect/landmark/beacon_start
	name = "beaconstart"
	icon_state = "beacon_start"

/obj/effect/landmark/beacon_start/Initialize(mapload)
	. = ..()
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
	icon = 'icons/mob/infection/infection.dmi'
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
	. = ..()
	START_PROCESSING(SSobj,src)
	GLOB.infection_beacons += src
	update_icon()

/obj/structure/beacon_generator/Destroy()
	STOP_PROCESSING(SSobj,src)
	for(var/obj/structure/beacon_wall/D in walls)
		qdel(D)
	GLOB.infection_beacons -= src
	var/mob/camera/commander/C = GLOB.infection_commander
	C.upgrade_points++
	for(var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/spore in C.infection_mobs)
		spore.add_points(200)
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
	if(obj_integrity > 0)
		playsound(src.loc, 'sound/effects/empulse.ogg', 300, 1, 10, pressure_affected = FALSE)
		return
	playsound(src.loc, 'sound/magic/repulse.ogg', 300, 1, 10, pressure_affected = FALSE)
	var/mob/camera/commander/OM = GLOB.infection_commander
	OM.playsound_local(OM, 'sound/magic/repulse.ogg', 300, 1)
	explosion(src, 5, 10, 20, 20, FALSE, TRUE, 5, TRUE, FALSE)
	qdel(src)

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
	icon = 'icons/mob/infection/infection.dmi'
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