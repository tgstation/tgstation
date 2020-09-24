/*  So why are we doing this here?  Because its a mess I tell you.
First, everything on the network must BE on the network for it to be resolved.
This cannot be done in LateInitialize because that is run PER map template.
So if we have many map templates and the maps don't properly setup separate networks
for each templates, ruins and such,  runtime start happening when machines cannot
find their devices out when it cannot find the map tags to build
devices.  So, FUCK IT.  We have an atmosinit to get around this problem, why
not have one for the network as well!

Networks InitializeNetwork runs on Init, UNLESS its on mapload.  On mapload we don't
run it and wait for the subsystem to run it.

If LateInitialize worked AFTER full map load worked, we wouldn't be in this mess
*/



PROCESSING_SUBSYSTEM_DEF(networks)
	name = "Networks"
	priority = FIRE_PRIORITY_NETWORKS
	wait = 1
	stat_tag = "NET"
	flags = SS_KEEP_TIMING
	init_order = INIT_ORDER_NETWORKS

	var/datum/ntnet/station/station_network
	var/list/init_interface_queue = list()

	var/list/interfaces_by_hardware_id = list()
	var/list/networks = list()
	// Used with map tags to look up hardware address
	var/list/network_tag_to_hardware_id = list()

/datum/controller/subsystem/processing/networks/Initialize()
	station_network = new
	station_network.register_map_supremecy()
	// lets register some basic networks
	create_network(NETWORK_ATMOS)
	create_network(NETWORK_ATMOS_AIRALARMS)
	create_network(NETWORK_ATMOS_SCUBBERS)
	create_network(NETWORK_ATMOS_ALARMS)
	create_network(NETWORK_ATMOS_CONTROL)
	create_network(NETWORK_TOOLS)
	create_network(NETWORK_TOOLS_REMOTES)
	create_network(NETWORK_AIRLOCKS)
	. = ..()

// Do NOT use this to find hid address.  Use the network.  This is ONLY to short circuit to find
// the parent device
/datum/controller/subsystem/processing/networks/proc/lookup_interface(tag_or_hid)
	var/hid = network_tag_to_hardware_id[tag_or_hid]
	if(!hid) // its a hid
		hid = tag_or_hid
	return interfaces_by_hardware_id[hid]

/datum/controller/subsystem/processing/networks/proc/create_network_from_string(network_name, datum/ntnet/root = null)
	to_chat(world, "Creating network [network_name]")
	return create_network(splittext_char(network_name,"."), root)

// verifies the network name has the right letters in it.  Might need to expand unwanted punctuations

/datum/controller/subsystem/processing/networks/proc/verify_network_name(name)
	return istext(name) && name[1] != "." && name[length(name)] != "."&& findtext(name,"\[ \n-;:\]*") == 0


// create a network name from a list containing the network tree
/datum/controller/subsystem/processing/networks/proc/network_list_to_string(list/tree)
	ASSERT(tree && tree.len > 0) // this should be obvious but JUST in case.
	for(var/part in tree)
		if(!istext(part))
			log_runtime("Cannot create network with [part]")
			return null // not a valid tree
		if(!verify_network_name(part) && findtext(name,".")==0) // and no stray dots
			log_runtime("Cannot create network with [part]")
			return null 	// name part wrong
	return tree.Join(".")

// create a network tree from a network string
/datum/controller/subsystem/processing/networks/proc/network_string_to_list(name)
	if(!verify_network_name(name))
		return null // bad name, no list
	return splittext(name,".") // should we do a splittext_char?  I doubt we really need unicode in network names

// finds OR creates a network from a simple string like "SS13.ATMOS.AIRALRM", runtimes if error
/datum/controller/subsystem/processing/networks/proc/create_network_simple(network_id)
	if(!verify_network_name(network_id))
		log_runtime("Network '[network_id]' is invalid")
		throw EXCEPTION("Network '[network_id]' is invalid")
	if(network_id in networks)
		return networks[network_id] // don't worry about it
	var/list/network_tree = network_string_to_list(network_id)
	ASSERT(network_tree.len > 0)
	var/network_name_part = ""
	var/datum/ntnet/parent = null
	var/datum/ntnet/network = null
	for(var/i in 1 to network_tree.len)
		if(i>1)
			network_name_part += "."
		network_name_part += network_tree[i]
		network = networks[network_name_part]
		if(!network)
			network = new(network_name_part, parent)
		parent = network
	to_chat(world, "Netowrk created final [network.network_id]")
	return network // and we are done!


// This will create OR find a network.  This is a heavy function as it can handle something like "BASENETWORK", "ATMOS.AIRALARM", "AREA.3"
// or even network tree lists (at a latter date).  you should use create_network_simple to check for networks but use this on map startup
/datum/controller/subsystem/processing/networks/proc/create_network(...)
	var/list/network_tree = list()
	for(var/part in args)
		if(!istext(part))
			log_runtime("We only take text parts of a create_network, what you doing?")
			return null // we only take text parts
		network_tree += network_string_to_list(part)
	return create_network_simple(network_tree.Join("."))


// so we have a special situation here.  Because mapping is stupid, we have to dynamically create networks on the fly
// so if this fails, it needs to runtime.  But as long as the network id is valid it should be fine
/datum/controller/subsystem/processing/networks/proc/interface_connect(datum/component/ntnet_interface/device, network_id)
	if(device.network)
		interface_disconnect(device) // disconnect it from the previous network
	var/datum/ntnet/network = create_network_simple(network_id)
	ASSERT(network)
	network.linked_devices[device.hardware_id] = device
	network.root_devices[device.hardware_id] = device
	device.network = network

/datum/controller/subsystem/processing/networks/proc/interface_disconnect(datum/component/ntnet_interface/device)
	if(device.network)
		device.network.linked_devices.Remove(device.hardware_id)
		device.network.root_devices.Remove(device.hardware_id)
		device.network = null


// collect all interfaces as well as children.  It looks wonky to stop recursion
/datum/controller/subsystem/processing/networks/proc/collect_interfaces(network_id)
	var/datum/ntnet/network = create_network_simple(network_id)
	ASSERT(network)
	var/list/datum/ntnet/queue = list(network)
	. = list()

	while(queue.len)
		network = queue[queue.len--]
		if(network.children.len)
			queue += network.children
		. += network.linked_devices


// I think we should do this more like a routerable ip address
/datum/controller/subsystem/processing/networks/proc/get_next_HID()
	do
		var/string = md5("[num2text(rand(HID_RESTRICTED_END, 999999999), 12)]")
		if(!string)
			log_runtime("Could not generate m5 hash from address, problem with md5?")
			return		//errored
		. = "[copytext_char(string, 1, 9)]"		//16 ^ 8 possibilities I think.
	while(interfaces_by_hardware_id[.])
	interfaces_by_hardware_id[.] = TRUE


