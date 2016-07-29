<<<<<<< HEAD
// See _DEFINES/is_helpers.dm for type helpers

/*
Name:	IsSpecialAssembly
Desc:	If true is an object that can be attached to an assembly holder but is a special thing like a plasma can or door
*/

/obj/proc/IsSpecialAssembly()
	return 0

/*
Name:	IsAssemblyHolder
Desc:	If true is an object that can hold an assemblyholder object
*/
/obj/proc/IsAssemblyHolder()
=======
/proc/isassembly(O)
	if(istype(O, /obj/item/device/assembly))
		return 1
	return 0

/proc/isigniter(O)
	if(istype(O, /obj/item/device/assembly/igniter))
		return 1
	return 0

/proc/isinfared(O)
	if(istype(O, /obj/item/device/assembly/infra))
		return 1
	return 0

/proc/isprox(O)
	if(istype(O, /obj/item/device/assembly/prox_sensor))
		return 1
	return 0

/proc/issignaler(O)
	if(istype(O, /obj/item/device/assembly/signaler))
		return 1
	return 0

/proc/istimer(O)
	if(istype(O, /obj/item/device/assembly/timer))
		return 1
	return 0

/*
Name:	IsSpecialAssembly
Desc:	If true is an object that can be attached to an assembly holder but is a special thing like a plasma can or door
*/

/obj/proc/IsSpecialAssembly()
	return 0

/*
Name:	IsAssemblyHolder
Desc:	If true is an object that can hold an assemblyholder object
*/
/obj/proc/IsAssemblyHolder()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	return 0