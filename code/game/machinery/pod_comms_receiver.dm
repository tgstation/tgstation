/obj/machinery/pod_comms_receiver
	name = "pod comms receiver"
	icon = 'icons/obj/machines/drone_dispenser.dmi'
	icon_state = "on"
	density = TRUE
	// access of this machine affects what pods can use it
	//todo circuit for this
	max_integrity = 500

// leaving this as empty incase someone wants to like to make traps or something idk
/obj/machinery/pod_comms_receiver/proc/receive(pod, list/access)

/obj/machinery/pod_comms_receiver/door
	desc = "This device intercepts info bursts from space pods, and toggles the linked door if authorized."
	/// the blastdoor controller
	var/obj/item/assembly/control/control_device
	/// id of the door we control
	var/door_id
	/// do we allow our panel to be opened
	var/is_cover_openable = TRUE

/obj/machinery/pod_comms_receiver/door/Initialize(mapload)
	. = ..()
	control_device = new(src)
	control_device = control_device
	control_device.id = door_id

/obj/machinery/pod_comms_receiver/door/Destroy(force)
	. = ..()
	QDEL_NULL(control_device)

/obj/machinery/pod_comms_receiver/door/screwdriver_act(mob/living/user, obj/item/tool)
	if(!is_cover_openable)
		return ITEM_INTERACT_BLOCKING
	if(default_deconstruction_screwdriver(user, "[icon_state]+o", icon_state, tool))
		update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/pod_comms_receiver/door/multitool_act(mob/living/user, obj/item/tool)
	return panel_open ? control_device?.multitool_act(user, tool) : NONE

/obj/machinery/pod_comms_receiver/door/receive(obj/vehicle/sealed/space_pod/pod, list/access)
	if(check_access_list(access))
		control_device.activate()
		for(var/occupant in pod?.occupants)
			to_chat(occupant, span_notice("[icon2html(src, occupant)] [src] (East [x] North [y]) - <b>Access Granted</b>"))
	else
		for(var/occupant in pod?.occupants)
			to_chat(occupant, span_warning("[icon2html(src, occupant)] [src] (East [x] North [y]) - <b>Access Denied</b>"))

/obj/machinery/pod_comms_receiver/door/randomizer
	var/randomization_range

/obj/machinery/pod_comms_receiver/door/randomizer/post_machine_initialize()
	. = ..()
	var/new_id = rand(0, 500)
	control_device.id = new_id
	for(var/obj/machinery/door/poddoor/door in range(randomization_range || world.view, loc))
		if(door.id != door_id)
			continue
		door.id = new_id
