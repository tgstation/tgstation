//Thing meant for allowing datums and objects to access a NTnet network datum.
/datum/proc/ntnet_recieve(datum/netdata/data)
	return

/datum/proc/ntnet_send(datum/netdata/data, netid)
	GET_COMPONENT(NIC, /datum/component/ntnet_interface)
	if(!NIC)
		return FALSE
	return NIC.__network_send(data, netid)

/datum/component/ntnet_interface
	var/hardware_id			//text
	var/network_name = ""			//text
	var/list/networks_connected_by_id = list()		//id = datum/ntnet

/datum/component/ntnet_interface/Initialize(force_name = "NTNet Device", autoconnect_station_network = TRUE)			//Don't force ID unless you know what you're doing!
	hardware_id = "[SSnetworks.get_next_HID()]"
	network_name = force_name
	SSnetworks.register_interface(src)
	if(autoconnect_station_network)
		register_connection(SSnetworks.station_network)

/datum/component/ntnet_interface/Destroy()
	unregister_all_connections()
	SSnetworks.unregister_interface(src)
	return ..()

/datum/component/ntnet_interface/proc/__network_recieve(datum/netdata/data)			//Do not directly proccall!
	parent.SendSignal(COMSIG_COMPONENT_NTNET_RECIEVE, data)
	parent.ntnet_recieve(data)

/datum/component/ntnet_interface/proc/__network_send(datum/netdata/data, netid)			//Do not directly proccall!
	// Process data before sending it
	data.pre_send(src)

	if(netid)
		if(networks_connected_by_id[netid])
			var/datum/ntnet/net = networks_connected_by_id[netid]
			return net.process_data_transmit(src, data)
		return FALSE
	for(var/i in networks_connected_by_id)
		var/datum/ntnet/net = networks_connected_by_id[i]
		net.process_data_transmit(src, data)
	return TRUE

/datum/component/ntnet_interface/proc/register_connection(datum/ntnet/net)
	if(net.interface_connect(src))
		networks_connected_by_id[net.network_id] = net
	return TRUE

/datum/component/ntnet_interface/proc/unregister_all_connections()
	for(var/i in networks_connected_by_id)
		unregister_connection(networks_connected_by_id[i])
	return TRUE

/datum/component/ntnet_interface/proc/unregister_connection(datum/ntnet/net)
	net.interface_disconnect(src)
	networks_connected_by_id -= net.network_id
	return TRUE
