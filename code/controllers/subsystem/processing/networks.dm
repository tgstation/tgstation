PROCESSING_SUBSYSTEM_DEF(networks)
	name = "Networks"
	priority = FIRE_PRIORITY_NETWORKS
	wait = 1
	stat_tag = "NET"
	flags = SS_KEEP_TIMING
	init_order = INIT_ORDER_NETWORKS
	var/datum/ntnet/station/station_network
	var/assignment_hardware_id = HID_RESTRICTED_END
	var/list/networks_by_id = list()				//id = network
	var/list/interfaces_by_id = list()				//hardware id = component interface

/datum/controller/subsystem/processing/networks/Initialize()
	station_network = new
	station_network.register_map_supremecy()
	. = ..()

/datum/controller/subsystem/processing/networks/proc/register_network(datum/ntnet/network)
	if(!networks_by_id[network.network_id])
		networks_by_id[network.network_id] = network
		return TRUE
	return FALSE

/datum/controller/subsystem/processing/networks/proc/unregister_network(datum/ntnet/network)
	networks_by_id -= network.network_id
	return TRUE

/datum/controller/subsystem/processing/networks/proc/register_interface(datum/component/ntnet_interface/D)
	if(!interfaces_by_id[D.hardware_id])
		interfaces_by_id[D.hardware_id] = D
		return TRUE
	return FALSE

/datum/controller/subsystem/processing/networks/proc/unregister_interface(datum/component/ntnet_interface/D)
	interfaces_by_id -= D.hardware_id
	return TRUE
