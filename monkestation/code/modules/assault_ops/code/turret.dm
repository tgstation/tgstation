GLOBAL_LIST_EMPTY(turret_id_refs)

/obj/machinery/porta_turret
	var/system_id //The ID for this turret

/obj/machinery/porta_turret/Initialize(mapload)
	. = ..()
	if(system_id)
		if(!GLOB.turret_id_refs[system_id])
			GLOB.turret_id_refs[system_id] = list()
		GLOB.turret_id_refs[system_id][src] = TRUE

/obj/machinery/porta_turret/Destroy()
	if(system_id && GLOB.turret_id_refs[system_id])
		GLOB.turret_id_refs[system_id] -= src
		if(!length(GLOB.turret_id_refs[system_id]))
			GLOB.turret_id_refs -= system_id
	return ..()

/obj/machinery/turretid
	var/system_id //The ID system for turrets, will get any turrets with the same ID and put them in controlled turrets

/obj/machinery/turretid/post_machine_initialize()
	. = ..()
	if(system_id && GLOB.turret_id_refs[system_id])
		for(var/i in GLOB.turret_id_refs[system_id])
			var/obj/machinery/porta_turret/T = i
			turrets |= WEAKREF(T)

