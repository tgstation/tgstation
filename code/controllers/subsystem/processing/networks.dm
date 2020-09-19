PROCESSING_SUBSYSTEM_DEF(networks)
	name = "Networks"
	priority = FIRE_PRIORITY_NETWORKS
	wait = 1
	stat_tag = "NET"
	flags = SS_KEEP_TIMING
	init_order = INIT_ORDER_NETWORKS

	// This is a tree network.  These are the trunks
	var/datum/ntnet/station/station_network

	var/list/interfaces_by_hardware_id = list()
	var/list/networks = list()

/datum/controller/subsystem/processing/networks/Initialize()
	station_network = new
	station_network.register_map_supremecy()
	. = ..()

/datum/controller/subsystem/processing/networks/proc/find_or_create_network(network_id, network_parent_id=null)
	var/datum/ntnet/net
	if(network_parent_id == null)
		net = station_network
	else if(networks[network_parent_id])
		net = networks[network_parent_id]
	else
		net = new(network_parent_id) // create the parent network
	return net.create_child(network_id)


/// I think we should do this more like a routable ip address
/datum/controller/subsystem/processing/networks/proc/get_next_HID()
	do
		var/string = md5("[num2text(rand(HID_RESTRICTED_END, 999999999), 12)]")
		if(!string)
			log_runtime("Could not generagea m5 hash from address, problem with md5?")
			return		//errored
		. = "[copytext_char(string, 1, 9)]"		//16 ^ 8 possibilities I think.
	while(interfaces_by_hardware_id[.])
	interfaces_by_hardware_id[.] = TRUE


