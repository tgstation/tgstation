/proc/isassembly(O)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/isassembly() called tick#: [world.time]")
	if(istype(O, /obj/item/device/assembly))
		return 1
	return 0

/proc/isigniter(O)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/isigniter() called tick#: [world.time]")
	if(istype(O, /obj/item/device/assembly/igniter))
		return 1
	return 0

/proc/isinfared(O)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/isinfared() called tick#: [world.time]")
	if(istype(O, /obj/item/device/assembly/infra))
		return 1
	return 0

/proc/isprox(O)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/isprox() called tick#: [world.time]")
	if(istype(O, /obj/item/device/assembly/prox_sensor))
		return 1
	return 0

/proc/issignaler(O)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/issignaler() called tick#: [world.time]")
	if(istype(O, /obj/item/device/assembly/signaler))
		return 1
	return 0

/proc/istimer(O)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/istimer() called tick#: [world.time]")
	if(istype(O, /obj/item/device/assembly/timer))
		return 1
	return 0

/*
Name:	IsSpecialAssembly
Desc:	If true is an object that can be attached to an assembly holder but is a special thing like a plasma can or door
*/

/obj/proc/IsSpecialAssembly()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/proc/IsSpecialAssembly() called tick#: [world.time]")
	return 0

/*
Name:	IsAssemblyHolder
Desc:	If true is an object that can hold an assemblyholder object
*/
/obj/proc/IsAssemblyHolder()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/proc/IsAssemblyHolder() called tick#: [world.time]")
	return 0