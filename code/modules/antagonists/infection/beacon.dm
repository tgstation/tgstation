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

/*
	Beacons, infectious creatures and structures are completely unable to cross the barriers that these generate
*/

/obj/structure/beacon_generator
	name = "beacon generator"
	icon = 'icons/mob/infection/infection.dmi'
	icon_state = "generator"
	light_range = 4
	desc = "It sustains the barriers."
	density = TRUE
	anchored = TRUE
	move_force = INFINITY
	move_resist = INFINITY
	layer = FLY_LAYER
	max_integrity = 1000
	resistance_flags = INDESTRUCTIBLE
	// Stores the walls that this beacon is generating, to be destroyed when the beacon is destroyed
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
	C.max_infection_points += 50
	C.infection_core.point_rate++
	C.add_points(C.max_infection_points)
	to_chat(C, "<span class='notice'>You feel pure energy surge through you...</span>")
	for(var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/spore in C.infection_mobs)
		spore.add_points(200)
		to_chat(spore, "<span class='notice'>You feel pure energy surge through you...</span>")
	if(GLOB.infection_beacons.len > 0)
		INVOKE_ASYNC(src, .proc/destroyed_announcement)
	return ..()

/*
	Delayed announcement that occurs when the becaon has been destroyed
*/
/obj/structure/beacon_generator/proc/destroyed_announcement(beacons_left = GLOB.infection_beacons.len)
	sleep(80)
	priority_announce("A beacon has been consumed by the infection, only [num2text(beacons_left)] remain[beacons_left == 1 ? "s" : ""].","CentCom Biohazard Division", 'sound/misc/notice1.ogg')

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
	explosion(src, 1, 2, 4, 10, FALSE, TRUE, 5, TRUE, FALSE)
	for(var/obj/structure/infection/I in orange(10, src))
		if(istype(I, /obj/structure/infection/core))
			continue
		qdel(I)
	qdel(src)

/obj/structure/beacon_generator/attack_animal(mob/living/simple_animal/M)
	playsound(src, 'sound/effects/bang.ogg', 50, 1)
	to_chat(M, "<span class='warning'>This is far too strong for you to destroy.</span>")
	. = ..()

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

/*
	Creates the walls for the beacon generator.
	They are generated 5 spaces behind the beacon and then extend out on opposite sides to the ends of the z level.
	Essentially cutting off any infection creatures from passing the beacon without destroying it.
*/
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