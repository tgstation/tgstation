#define WAND_OPEN "open"
#define WAND_BOLT "bolt"
#define WAND_EMERGENCY "emergency"

/obj/item/door_remote
	icon_state = "gangtool-white"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	icon = 'icons/obj/device.dmi'
	name = "control wand"
	desc = "Remotely controls airlocks."
	w_class = WEIGHT_CLASS_TINY
	var/mode = WAND_OPEN
	var/region_access = REGION_GENERAL
	var/list/access_list
	network_id = NETWORK_DOOR_REMOTES

/obj/item/door_remote/Initialize(mapload)
	. = ..()
	access_list = SSid_access.get_region_access_list(list(region_access))
	RegisterSignal(src, COMSIG_COMPONENT_NTNET_NAK, .proc/bad_signal)

/obj/item/door_remote/proc/bad_signal(datum/source, datum/netdata/data, error_code)
	SIGNAL_HANDLER
	if(QDELETED(data.user))
		return // can't send a message to a missing user
	if(error_code == NETWORK_ERROR_UNAUTHORIZED)
		to_chat(data.user, span_notice("This remote is not authorized to modify this door."))
	else
		to_chat(data.user, span_notice("Error: [error_code]"))

/obj/item/door_remote/attack_self(mob/user)
	var/static/list/desc = list(WAND_OPEN = "Open Door", WAND_BOLT = "Toggle Bolts", WAND_EMERGENCY = "Toggle Emergency Access")
	switch(mode)
		if(WAND_OPEN)
			mode = WAND_BOLT
		if(WAND_BOLT)
			mode = WAND_EMERGENCY
		if(WAND_EMERGENCY)
			mode = WAND_OPEN
	balloon_alert(user, "mode: [desc[mode]]")

// Airlock remote works by sending NTNet packets to whatever it's pointed at.
/obj/item/door_remote/afterattack(atom/A, mob/user)
	. = ..()
	var/datum/component/ntnet_interface/target_interface = A.GetComponent(/datum/component/ntnet_interface)

	// Try to find an airlock in the clicked turf
	if(!target_interface)
		var/obj/machinery/door/airlock/door = locate() in get_turf(A)
		if(door)
			target_interface = door.GetComponent(/datum/component/ntnet_interface)

	if(!target_interface)
		return

	user.set_machine(src)
	// Generate a control packet.
	var/datum/netdata/data = new(list("data" = mode,"data_secondary" = "toggle"))
	data.receiver_id = target_interface.hardware_id
	data.passkey = access_list
	data.user = user // for responce message

	ntnet_send(data)

/obj/item/door_remote/omni
	name = "omni door remote"
	desc = "This control wand can access any door on the station."
	icon_state = "gangtool-yellow"
	region_access = REGION_ALL_STATION

/obj/item/door_remote/captain
	name = "command door remote"
	icon_state = "gangtool-yellow"
	region_access = REGION_COMMAND

/obj/item/door_remote/chief_engineer
	name = "engineering door remote"
	icon_state = "gangtool-orange"
	region_access = REGION_ENGINEERING

/obj/item/door_remote/research_director
	name = "research door remote"
	icon_state = "gangtool-purple"
	region_access = REGION_RESEARCH

/obj/item/door_remote/head_of_security
	name = "security door remote"
	icon_state = "gangtool-red"
	region_access = REGION_SECURITY

/obj/item/door_remote/quartermaster
	name = "supply door remote"
	desc = "Remotely controls airlocks. This remote has additional Vault access."
	icon_state = "gangtool-green"
	region_access = REGION_SUPPLY

/obj/item/door_remote/chief_medical_officer
	name = "medical door remote"
	icon_state = "gangtool-blue"
	region_access = REGION_MEDBAY

/obj/item/door_remote/civilian
	name = "civilian door remote"
	icon_state = "gangtool-white"
	region_access = REGION_GENERAL

#undef WAND_OPEN
#undef WAND_BOLT
#undef WAND_EMERGENCY
