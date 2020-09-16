PROCESSING_SUBSYSTEM_DEF(networks)
	name = "Networks"
	priority = FIRE_PRIORITY_NETWORKS
	wait = 1
	stat_tag = "NET"
	flags = SS_KEEP_TIMING
	init_order = INIT_ORDER_NETWORKS
	var/datum/ntnet/station/station_network
	var/datum/ntnet/station/syndicate_network
	var/list/networks_by_id = list()				//id = network
	var/list/interfaces_by_hardware_id = list()

/datum/controller/subsystem/processing/networks/Initialize()
	station_network = new
	syndicate_network = new
	station_network.register_map_supremecy()
	. = ..()

/datum/controller/subsystem/processing/networks/proc/register_network(network=null, datum/ntnet/parent=null)
	var/datum/ntnet/net = null
	if(!network)
		net = station_network
	else if(istext(network))
		if(!networks_by_id[network])
			if(!parent)
				parent = station_network
			net = new/datum/ntnet(network, parent) // always a parrent to the main network
			networks_by_id[network] = net
			log_network("Network created for [parent] with the name '[network]'")
	else if(istype(network, /datum/ntnet)) // custom network, like for sindies or charlie
		net = network
	if(!net)
		log_runtime("No network created and not sure why?")
	return net



/// I think we should do this more like a routable ip address
/datum/controller/subsystem/processing/networks/proc/get_next_HID()
	// lets get rid of recursion
	var/static/list/collision_check = list()
	do
		var/string = md5("[num2text(rand(HID_RESTRICTED_END, 999999999), 12)]")
		if(!string)
			log_runtime("Could not generagea m5 hash from address, problem with md5?")
			return		//errored
		. = "[copytext_char(string, 1, 9)]"		//16 ^ 8 possibilities I think.
	while(collision_check[.])
	collision_check[.] = TRUE


/datum/controller/subsystem/processing/networks/proc/register_interface(datum/component/ntnet_interface/I, network)
		I.hardware_id = "[get_next_HID()]"
		interfaces_by_hardware_id[I.hardware_id] = I
		var/datum/ntnet/net = register_network(network)	// default to station
		net.interface_connect(I)

/datum/controller/subsystem/processing/networks/proc/unregister_interface(datum/component/ntnet_interface/I)
		I.network.interface_disconnect(I)
		interfaces_by_hardware_id[I.hardware_id] = null
		interfaces_by_hardware_id.Remove(I.hardware_id)



