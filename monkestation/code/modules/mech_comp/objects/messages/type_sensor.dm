/obj/item/mcobject/messaging/type_sensor
	name = "type sensor"

	icon = 'monkestation/icons/obj/mechcomp.dmi'
	icon_state = "comp_collector"
	base_icon_state = "comp_collector"

	///the path to the object we are scanning for
	var/object_path
	///the string passed when type is found
	var/fire_string = ""

/obj/item/mcobject/messaging/type_sensor/Initialize(mapload)
	. = ..()

	MC_ADD_CONFIG("Change Type", swap_type)
	MC_ADD_CONFIG("Clear Type", clear_type)
	MC_ADD_CONFIG("Set Fire String", set_fire_string)
	MC_ADD_INPUT("change", swap_type)
	MC_ADD_INPUT("clear", clear_type)

/obj/item/mcobject/messaging/type_sensor/proc/set_fire_string(mob/user, obj/item/tool)
	var/string = tgui_input_text(user, "Set Firing Message", "Type Sensor", fire_string)

	if(!string)
		return
	fire_string = string
	say("Firing String has been set to: [string]")
	return TRUE

/obj/item/mcobject/messaging/type_sensor/proc/swap_type()
	var/atom/movable/picked_atom
	for(var/atom/movable/listed_atoms in src.loc)
		if(listed_atoms == src)
			continue
		if(listed_atoms.anchored)
			continue

		picked_atom = listed_atoms
		break

	object_path = picked_atom.type
	say("Now scanning for [picked_atom.name].")
	return TRUE

/obj/item/mcobject/messaging/type_sensor/proc/clear_type()
	object_path = null
	say("Cleared scanning type.")
	return TRUE

/obj/item/mcobject/messaging/type_sensor/proc/check_type(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(arrived.type != object_path)
		return FALSE
	fire(fire_string)
	return TRUE

/obj/item/mcobject/messaging/type_sensor/attackby_secondary(obj/item/weapon, mob/user, params)
	. = ..()
	object_path = weapon.type
	say("Now scanning for [weapon.name]")

/obj/item/mcobject/messaging/type_sensor/set_anchored(anchorvalue)
	. = ..()
	switch(anchorvalue)
		if(TRUE)
			RegisterSignal(get_turf(src), COMSIG_ATOM_ENTERED, PROC_REF(check_type))
		else
			UnregisterSignal(get_turf(src), COMSIG_ATOM_ENTERED)
