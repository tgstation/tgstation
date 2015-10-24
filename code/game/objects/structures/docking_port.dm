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

/obj/structure/docking_port/New()
	.=..()
	all_docking_ports |= src

/obj/structure/docking_port/Destroy()
	.=..()
	all_docking_ports -= src

	undock()

	for(var/datum/shuttle/S in shuttles) //Go through every existing shuttle and remove references
		if(src == S.current_port) S.current_port = null
		if(src == S.transit_port) S.transit_port = null
		if(src == S.destination_port) S.destination_port = null

//just in case
/obj/structure/docking_port/singuloCanEat()
	return //we are eternal

/obj/structure/docking_port/ex_act()
	return //we are eternal

/obj/structure/docking_port/cultify()
	return //we are eternal

/obj/structure/docking_port/shuttle_act(datum/shuttle/S)
	if(istype(src,/obj/structure/docking_port/shuttle))
		var/obj/structure/docking_port/shuttle/D = src
		message_admins("<span class='notice'>WARNING: A shuttle docking port linked to [D.linked_shuttle ? "[D.linked_shuttle.name] ([D.linked_shuttle.type])" : "nothing"] has been destroyed by [S.name] ([S.type]). The linked shuttle will be broken! [formatJumpTo(get_turf(src))]</span>")
	return ..()

/obj/structure/docking_port/proc/link_to_shuttle(var/datum/shuttle/S)
	return

/obj/structure/docking_port/proc/unlink_from_shuttle(var/datum/shuttle/S)
	return

/obj/structure/docking_port/proc/undock()
	if(docked_with)
		if(docked_with.docked_with == src)
			docked_with.docked_with = null
		docked_with = null
		return 1

/obj/structure/docking_port/proc/dock(var/obj/structure/docking_port/D)
	undock()

	D.docked_with = src
	src.docked_with = D

/obj/structure/docking_port/proc/get_docking_turf()
	return get_step(get_turf(src),src.dir)

//SHUTTLE PORTS

/obj/structure/docking_port/shuttle //this guy is installed on shuttles and connects to obj/structure/docking_port/destination
	icon_state = "docking_shuttle"
	areaname = "shuttle"

	var/datum/shuttle/linked_shuttle

/obj/structure/docking_port/shuttle/Destroy()
	message_admins("<span class='warning'>WARNING: A shuttle docking port (linked to [linked_shuttle ? (linked_shuttle.name) : "nothing"]) has been deleted.</span>")
	if(linked_shuttle)
		unlink_from_shuttle(linked_shuttle)

	..()

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

	var/base_turf_type			= /turf/space
	var/base_turf_icon			= null
	var/base_turf_icon_state	= null

/obj/structure/docking_port/destination/New()
	.=..()

	//The following few lines exist to make shuttle corners and the syndicate base Less Shit :*
	if(src.z in (1 to map.zLevels.len))
		base_turf_type = get_base_turf(src.z)

	var/datum/zLevel/L = get_z_level(src)
	if(istype(L,/datum/zLevel/centcomm)) //If the docking port is at z-level 2 (the one with the transit areas)
		var/turf/T = get_turf(src)
		if(istype(T, /turf/space))	//Placed on space
			base_turf_type = T.type //This ensures that once a shuttle leaves transit, its turfs are replaced with MOVING SPACE instead of STATIC SPACE
		else			//Not placed on space
			var/area/syndicate_mothership/A = get_area(src)
			if(istype(A))
				base_turf_type			= T.type
				base_turf_icon			= T.icon
				base_turf_icon_state	= T.icon_state

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

/obj/structure/docking_port/destination/shuttle_act() //These guys don't get destroyed
	return 0

//SILLY PROC
/proc/select_port_from_list(var/mob/user, var/message="Select a docking port", var/title="Admin abuse", var/list/list) //like input
	if(!list || !user) return

	var/list/choices = list("Cancel")
	for(var/obj/structure/docking_port/destination/D in list)
		var/name = "[D.name] ([D.areaname])"
		choices += name
		choices[name] = D

	var/choice = input(user,message,title) in choices as text|null

	var/obj/structure/docking_port/destination/D = choices[choice]
	if(istype(D)) return D
	return 0
