var/global/list/all_docking_ports = list()

/obj/structure/docking_port
	name = "docking port"
	icon = 'icons/obj/structures.dmi'
	icon_state = "docking_shuttle"
	dir = NORTH

	density = 0
	anchored = 1
	invisibility = 60 //Only ghosts can see

	var/areaname = "space"

	var/obj/structure/docking_port/docked_with

	var/list/used_by_shuttles = list() //List of all shuttles which use this in any way

/obj/structure/docking_port/New()
	.=..()
	all_docking_ports |= src

/obj/structure/docking_port/Destroy()
	.=..()
	all_docking_ports -= src

//just in case
/obj/structure/docking_port/singuloCanEat()
	return //we are eternal

/obj/structure/docking_port/ex_act()
	return //we are eternal

/obj/structure/docking_port/cultify()
	return //we are eternal

/obj/structure/docking_port/shuttle_act()
	return

/obj/structure/docking_port/proc/link_to_shuttle(var/datum/shuttle/S)
	used_by_shuttles |= S
	return

/obj/structure/docking_port/proc/unlink_from_shuttle(var/datum/shuttle/S)
	used_by_shuttles -= S
	return

/obj/structure/docking_port/proc/undock()
	if(docked_with)
		if(docked_with.docked_with == src)
			docked_with.docked_with = null
		docked_with = null
		return 1

/obj/structure/docking_port/proc/dock(var/obj/structure/docking_port/D)
	D.docked_with = src
	src.docked_with = D

/obj/structure/docking_port/proc/get_docking_turf()
	return get_step(get_turf(src),src.dir)

/obj/structure/docking_port/proc/must_rotate(var/obj/structure/docking_port/D) //Returns the angle by which src must rotate to face D
	if(!D) return 0
	return ( (dir2angle(turn(src.dir, 180)) - dir2angle(D.dir)) % 360)

//SHUTTLE PORTS

/obj/structure/docking_port/shuttle //this guy is installed on shuttles and connects to obj/structure/docking_port/destination
	icon_state = "docking_shuttle"
	areaname = "shuttle"

	var/datum/shuttle/linked_shuttle

/obj/structure/docking_port/shuttle/link_to_shuttle(var/datum/shuttle/S)
	.=..()
	if(linked_shuttle)
		unlink_from_shuttle(linked_shuttle)

	src.linked_shuttle = S
	src.areaname = S.name
	S.linked_port = src

/obj/structure/docking_port/shuttle/unlink_from_shuttle(var/datum/shuttle/S)
	.=..()
	if(!S) S = linked_shuttle

	if(linked_shuttle == S)
		linked_shuttle = null

	if(S.linked_port == src)
		S.linked_port = null

	src.areaname = "unassigned docking port"

/obj/structure/docking_port/shuttle/can_shuttle_move(datum/shuttle/S)
	if(S.linked_port == src)
		return 1
	return 0

//DESTINATION PORTS

/obj/structure/docking_port/destination //this guy is installed on stations and connects to shuttles
	icon_state = "docking_station"

	var/min_x = 0
	var/max_x = 255

	var/min_y = 0
	var/max_y = 255

/obj/structure/docking_port/destination/proc/calculate_bounds(var/from)
	if(istype(from,/datum/shuttle))
		var/datum/shuttle/S = from

		if(!S || !S.linked_area || !S.linked_port) return

		var/turf/shuttle = S.linked_port.get_docking_turf()
		var/turf/us = get_turf(src)

		var/datum/coords/offset = new(us.x-shuttle.x, us.y-shuttle.y)

		for(var/turf/T in S.linked_area.get_turfs())
			var/new_x = T.x + offset.x_pos
			var/new_y = T.y + offset.y_pos

			if(new_x > min_x) min_x = new_x
			if(new_x < max_x) max_x = new_x

			if(new_y > min_y) min_y = new_y
			if(new_y < max_y) max_y = new_y

	else if(istype(from,/obj/structure/docking_port/destination))
		var/obj/structure/docking_port/destination/D = from

		src.min_x = src.x - D.x + D.min_x
		src.min_y = src.y - D.y + D.min_y
		src.max_x = src.x - D.x + D.max_x
		src.max_y = src.y - D.y + D.max_y

/obj/structure/docking_port/destination/link_to_shuttle(var/datum/shuttle/S)
	..()
	S.docking_ports |= src

/obj/structure/docking_port/destination/unlink_from_shuttle(var/datum/shuttle/S)
	..()
	S.docking_ports -= src

/obj/structure/docking_port/destination/can_shuttle_move(datum/shuttle/S)
	if(src in S.docking_ports_aboard)
		return 1
	return 0

//SILLY PROC
/proc/select_port_from_list(var/mob/user, var/message="Select a docking port", var/title="Admin abuse", var/list/list) //like input
	if(!list || !user) return

	var/list/choices = list()
	for(var/obj/structure/docking_port/destination/D in list)
		var/name = "[D.name] ([D.areaname])"
		choices += name
		choices[name] = D

	var/choice = input(user,message,title) in choices as text|null

	var/obj/structure/docking_port/destination/D = choices[choice]
	if(D) return D
	return 0
