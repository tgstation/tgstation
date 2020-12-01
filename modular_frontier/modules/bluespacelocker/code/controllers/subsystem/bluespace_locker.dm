SUBSYSTEM_DEF(bluespace_locker)
	name = "Bluespace Locker"
	flags = SS_NO_FIRE
	var/obj/structure/closet/bluespace/internal/internal_locker = null
	var/obj/structure/closet/bluespace/external/external_locker = null

/datum/controller/subsystem/bluespace_locker/Initialize()
	bluespaceify_random_locker()
	if(external_locker)
		external_locker.take_contents()
	return ..()

/datum/controller/subsystem/bluespace_locker/proc/bluespaceify_random_locker()
	if(external_locker)
		return
	// basically any normal-looking locker that isn't a secure one
	var/list/valid_lockers = typecacheof(typesof(/obj/structure/closet) - typesof(/obj/structure/closet/body_bag)\
	- typesof(/obj/structure/closet/secure_closet) - typesof(/obj/structure/closet/cabinet)\
	- typesof(/obj/structure/closet/cardboard) - typesof(/obj/structure/closet/crate)\
	- typesof(/obj/structure/closet/supplypod) - typesof(/obj/structure/closet/stasis)\
	- typesof(/obj/structure/closet/abductor) - typesof(/obj/structure/closet/bluespace), only_root_path = TRUE)

	var/list/lockers_list = list()
	for(var/obj/structure/closet/L in world)
		if(is_station_level(L.z) && is_type_in_typecache(L, valid_lockers))
			lockers_list += L
	if(!lockers_list.len)
		// Congratulations, you managed to destroy all the lockers somehow.
		// Now let's make a new one.
		var/targetturf = find_safe_turf()
		if(!targetturf)
			if(GLOB.blobstart.len > 0)
				targetturf = get_turf(pick(GLOB.blobstart))
			else
				CRASH("Unable to find a blobstart landmark")
		lockers_list += new /obj/structure/closet(targetturf)
	var/obj/structure/closet/L = pick(lockers_list)

	var/obj/structure/closet/bluespace/external/E = new(L.loc)
	E.contents = L.contents
	E.name = L.name
	E.desc = L.desc
	if(L.opened)
		E.open()
	E.icon = L.icon
	E.icon_state = L.icon_state
	E.icon_door = L.icon_door
	E.icon_door_override = L.icon_door_override
	E.icon_welded = L.icon_welded
	qdel(L)

	relink_lockers()

/datum/controller/subsystem/bluespace_locker/proc/relink_lockers()
	if(!internal_locker)
		return
	//var/area/A = get_area(internal_locker)
	//A.global_turf_object = external_locker
	internal_locker.update_mirage()
	if(!external_locker)
		return
	if(external_locker.opened)
		internal_locker.close()
	else
		internal_locker.contents += external_locker.contents
		internal_locker.open()
		internal_locker.dump_contents()
	internal_locker.update_icon()
	external_locker.update_icon()
