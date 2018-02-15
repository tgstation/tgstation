/datum/ntnet_service
	var/name = "Unknown Network Service"
	var/description = "This service does not specify what it does."
	var/service_id = NETWORK_SERVICE_ID_UNKNOWN
	var/unique = FALSE			//If this is TRUE, the network will use its service ID. Otherwise, it will not be registered to an ID. Any other service on the same ID will prevent it from being added.
	var/datum/ntnet/parent

/datum/ntnet_service/New(datum/ntnet/new_parent, override = FALSE)
	if(!istype(new_parent) && !override)
		qdel(src)
		return
	if(!new_parent.add_network_service(src))
		qdel(src)
		return
	parent = new_parent
	AddComponent(/datum/component/ntnet_interface, name, FALSE, parent)

/datum/ntnet_service/proc/service_process()
	return

/datum/ntnet_service/proc/is_operational(zlevel)
	return parent.check_relay_operation(zlevel)

/datum/ntnet_service/proc/on_network_transmit(datum/component/ntnet_interface/sender, datum/netdata/data)
	return
