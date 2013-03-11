/*
/obj/machinery/travel
	name = "travel thingie"
	desc = "it is used for travel idunno"
	icon = 'travel.dmi'
	density = 1
	anchored = 1

	//note - didn't use a single loc list just because it's easier to edit via adminmagics if this is done this way
	var/list/z_connect = list() //the z position of the tiles it connects to
	var/list/x_connect = list() //the x position of the tiles it connects to
	var/list/y_connect = list() //the y position of the tiles it connects to

/obj/machinery/travel/ladder
	icon_state = "ladder_up"
	name = "ladder"
	desc = "It is a ladder."

/obj/machinery/travel/elevator
	icon_state = "elevator_closed"
	name = "elevator"
	desc = "It is an elevator. The display shows \"1\"."

	var/current_floor = 1 //current floor the elevator is on. do NOT confuse with current z-level of the elevator
	var/list/elevators_connected = list() //list of elevators it is connected to
	var/list/floors = list() //dependant on the number of elevators, converts z-levels to floors, basically
*/

/obj/machinery/travel/ladder/New()
	for(var/i=src.z,i<=world.maxz,i++)
		var/isladder = 0
		for(var/obj/machinery/travel/ladder/L in locate(src.x,src.y,i))
			if(L==src)
				continue
			src.x_connect[i] = L.x
			src.y_connect[i] = L.y
			src.z_connect[i] = L.z
			L.icon_state = "ladder_down"
			L.x_connect[src.z] = src.x
			L.y_connect[src.z] = src.y
			L.z_connect[src.z] = src.z
			isladder = 1
			L.connected = src.z
		if(isladder)
			src.connected = i
			break
	if(!src.connected)
		for(var/i=1,i<=src.z,i++)
			var/isladder = 0
			for(var/obj/machinery/travel/ladder/L in locate(src.x,src.y,i))
				if(L==src)
					continue
				src.x_connect[i] = L.x
				src.y_connect[i] = L.y
				src.z_connect[i] = L.z
				src.icon_state = "ladder_down"
				L.x_connect[src.z] = src.x
				L.y_connect[src.z] = src.y
				L.z_connect[src.z] = src.z
				isladder = 1
				L.connected = src.z
			if(isladder)
				src.connected = i
				break

	..()

/obj/machinery/travel/ladder/attack_hand(mob/user as mob)
	if(!src.connected)
		return
	user.x = src.x_connect[src.connected]
	user.y = src.y_connect[src.connected]
	user.z = src.z_connect[src.connected]

/*
/obj/machinery/travel/elevator/proc/check_connect()
	for(var/i=1,i<=world.maxz,i++)
		var/iselevator = 0
		for(var/obj/machinery/travel/elevator/E in src.x,src.y,i)
			src.elevators_connected[i] = E
			src.x_connect[i] = E.x
			src.y_connect[i] = E.y
			src.z_connect[i] = E.z
			iselevator = 1
		if(!iselevator)
			src.elevators_connected[i] = null
			src.x_connect[i] = null
			src.y_connect[i] = null
			src.z_connect[i] = null
*/