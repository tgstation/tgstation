//Thing meant for allowing datums and objects to access an NTnet network datum.
/datum/proc/ntnet_receive(datum/netdata/data)
	return

/datum/proc/ntnet_receive_broadcast(datum/netdata/data)
	return

/datum/proc/ntnet_send(datum/netdata/data, netid)
	var/datum/component/ntnet_interface/NIC = GetComponent(/datum/component/ntnet_interface)
	if(!NIC)
		return FALSE
	return NIC.__network_send(data, netid)

/datum/component/ntnet_interface
	var/hardware_id			//text. this is the true ID. do not change this. stuff like ID forgery can be done manually.
	var/datum/ntnet/network = null
	var/differentiate_broadcast = TRUE				//If false, broadcasts go to ntnet_receive. NOT RECOMMENDED.

/datum/component/ntnet_interface/Initialize(network_name=null)			//Don't force ID unless you know what you're doing!
	hardware_id = "[SSnetworks.get_next_HID()]"
	SSnetworks.register_interface(src, network_name)	// default to station
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL), .proc/OnMultitool)

/datum/component/ntnet_interface/Destroy()
	SSnetworks.unregister_interface(src)
	UnregisterSignal(thing, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL))
	return ..()

/datum/component/ntnet_interface/proc/__network_receive(datum/netdata/data)			//Do not directly proccall!
	SEND_SIGNAL(parent, COMSIG_COMPONENT_NTNET_RECEIVE, data)
	if(differentiate_broadcast && data.broadcast)
		parent.ntnet_receive_broadcast(data)
	else
		parent.ntnet_receive(data)

/datum/component/ntnet_interface/proc/__network_send(datum/netdata/data, netid)			//Do not directly proccall!
	network.process_data_transmit(src, data)
	return TRUE

// Returns a multitool from a user depending on their mobtype.
// Shamelessly coppied from telecoms and remote components
// ... though now that I think about this, the ui should be hooked up to the multi tool
/datum/component/remote_materials/proc/OnMultitool(datum/source, mob/user, obj/item/I)
	SIGNAL_HANDLER

	if(!I.multitool_check_buffer(user, I))
		return COMPONENT_BLOCK_TOOL_ATTACK
	var/obj/item/multitool/M = I
	if (!QDELETED(M.buffer) && istype(M.buffer, /obj/machinery/ore_silo))
		if (silo == M.buffer)
			to_chat(user, "<span class='warning'>[parent] is already connected to [silo]!</span>")
			return COMPONENT_BLOCK_TOOL_ATTACK
		if (silo)
			silo.connected -= src
			silo.updateUsrDialog()
		else if (mat_container)
			mat_container.retrieve_all()
			qdel(mat_container)
		silo = M.buffer
		silo.connected += src
		silo.updateUsrDialog()
		mat_container = silo.GetComponent(/datum/component/material_container)
		to_chat(user, "<span class='notice'>You connect [parent] to [silo] from the multitool's buffer.</span>")
		return COMPONENT_BLOCK_TOOL_ATTACK

/datum/component/ntnet_interface/proc/get_multitool(mob/user)
	var/obj/item/multitool/P = null
	// Let's double check
	if(!issilicon(user) && istype(user.get_active_held_item(), /obj/item/multitool))
		P = user.get_active_held_item()
	else if(isAI(user))
		var/mob/living/silicon/ai/U = user
		P = U.aiMulti
	else if(iscyborg(user) && in_range(user, src))
		if(istype(user.get_active_held_item(), /obj/item/multitool))
			P = user.get_active_held_item()
	return P

/datum/component/ntnet_interface/proc/canAccess(mob/user)
	if(issilicon(user) || in_range(user, src))
		return TRUE
	return FALSE
