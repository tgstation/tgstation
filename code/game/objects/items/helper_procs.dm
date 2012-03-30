/*/proc/parse_zone(zone)
	if(zone == "r_hand") return "right hand"
	else if (zone == "l_hand") return "left hand"
	else if (zone == "l_arm") return "left arm"
	else if (zone == "r_arm") return "right arm"
	else if (zone == "l_leg") return "left leg"
	else if (zone == "r_leg") return "right leg"
	else if (zone == "l_foot") return "left foot"
	else if (zone == "r_foot") return "right foot"
	else return zone*/

/proc/text2dir(direction)
	switch(uppertext(direction))
		if("NORTH")
			return 1
		if("SOUTH")
			return 2
		if("EAST")
			return 4
		if("WEST")
			return 8
		if("NORTHEAST")
			return 5
		if("NORTHWEST")
			return 9
		if("SOUTHEAST")
			return 6
		if("SOUTHWEST")
			return 10
		else
	return

/proc/get_turf(turf/location as turf)
	while (location)
		if (istype(location, /turf))
			return location

		location = location.loc
	return null

/proc/get_turf_or_move(turf/location as turf)
	location = get_turf(location)
	return location



/proc/dir2text(direction)
	switch(direction)
		if(1.0)
			return "north"
		if(2.0)
			return "south"
		if(4.0)
			return "east"
		if(8.0)
			return "west"
		if(5.0)
			return "northeast"
		if(6.0)
			return "southeast"
		if(9.0)
			return "northwest"
		if(10.0)
			return "southwest"
		else
	return

/proc/is_type_in_list(var/atom/A, var/list/L)
	for(var/type in L)
		if(istype(A, type))
			return 1
	return 0

//Quick type checks for some tools
var/global/list/common_tools = list(
/obj/item/weapon/cable_coil,
/obj/item/weapon/wrench,
/obj/item/weapon/weldingtool,
/obj/item/weapon/screwdriver,
/obj/item/weapon/wirecutters,
/obj/item/device/multitool,
/obj/item/weapon/crowbar)

/proc/istool(O)
	if(O && is_type_in_list(O, common_tools))
		return 1
	return 0

/proc/iswrench(O)
	if(istype(O, /obj/item/weapon/wrench))
		return 1
	return 0

/proc/iswelder(O)
	if(istype(O, /obj/item/weapon/weldingtool))
		return 1
	return 0

/proc/iscoil(O)
	if(istype(O, /obj/item/weapon/cable_coil))
		return 1
	return 0

/proc/iswirecutter(O)
	if(istype(O, /obj/item/weapon/wirecutters))
		return 1
	return 0

/proc/isscrewdriver(O)
	if(istype(O, /obj/item/weapon/screwdriver))
		return 1
	return 0

/proc/ismultitool(O)
	if(istype(O, /obj/item/device/multitool))
		return 1
	return 0

/proc/iscrowbar(O)
	if(istype(O, /obj/item/weapon/crowbar))
		return 1
	return 0
