// Receives comms bursts from pods to call receive()
/obj/machinery/pod_comms_receiver
	name = "pod comms receiver"
	icon = 'icons/obj/structures.dmi'
	icon_state = "podcommsreceiver" //sprite by ArcaneMusic
	density = TRUE
	max_integrity = 500

/// Proc called by a space pods comms array when activated in range, pod is the pod, access is an access list of the comms array
/obj/machinery/pod_comms_receiver/proc/receive(pod, list/access)
	return

/obj/machinery/pod_comms_receiver/door
	desc = "This device intercepts info bursts from space pods, and toggles the linked door if authorized."
	circuit = /obj/item/circuitboard/machine/podcommsreceiverdoor
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
	QDEL_NULL(control_device)
	return ..()

/obj/machinery/pod_comms_receiver/door/screwdriver_act(mob/living/user, obj/item/tool)
	if(!is_cover_openable)
		return ITEM_INTERACT_BLOCKING
	default_deconstruction_screwdriver(user, "[icon_state]+o", icon_state, tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/pod_comms_receiver/door/multitool_act(mob/living/user, obj/item/tool)
	return panel_open ? control_device?.multitool_act(user, tool) : NONE

/obj/machinery/pod_comms_receiver/door/receive(obj/vehicle/sealed/space_pod/pod, list/access)
	var/pretext = span_notice("[icon2html(src, occupant)] [src] (East [x] North [y]) - ")
	if(check_access_list(access))
		control_device.activate()
		for(var/occupant in pod?.occupants)
			to_chat(occupant, span_notice("[pretext]<b>Access Granted</b>"))
	else
		for(var/occupant in pod?.occupants)
			to_chat(occupant, span_warning("[pretext]<b>Access Denied</b>"))

// This randomizes its own ID then the ID of nearby poddoors to the same ID
/obj/machinery/pod_comms_receiver/door/randomizer
	/// range at which we randomize IDs for poddoors
	var/randomization_range

/obj/machinery/pod_comms_receiver/door/randomizer/post_machine_initialize()
	. = ..()
	var/new_id = rand(0, 500)
	control_device.id = new_id
	for(var/obj/machinery/door/poddoor/door in range(randomization_range || world.view, loc))
		if(door.id != door_id)
			continue
		door.id = new_id
