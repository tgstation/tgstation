/obj/machinery/defibrillator_mount/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, clamps_locked)
	return .

/obj/machinery/defibrillator_mount/on_object_saved(map_string, turf/current_loc, list/obj_blacklist)
	var/list/defib_mount_contents = list()
	if(defib)
		defib_mount_contents += defib

	if(defib_mount_contents.len)
		save_stored_contents(map_string, current_loc, obj_blacklist, defib_mount_contents)

/obj/machinery/defibrillator_mount/PersistentInitialize()
	. = ..()
	var/obj/item/defibrillator/defib_unit = locate(/obj/item/defibrillator) in contents
	defib = defib_unit

	if(is_operational && defib)
		begin_processing()

	update_appearance()
