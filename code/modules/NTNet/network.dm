/*
 * # /datum/ntnet
 *
 * This class defines each network of the world.  Each root network is accessible by any device
 * on the same network but NOT accessible to any other "root" networks.  All normal devices only have
 * one network and one network_id.
 *
 * This thing replaces radio.  Think of wifi but better, bigger and bolder!  The idea is that any device
 * on a network can reach any other device on that same network if it knows the hardware_id.  You can also
 * search or broadcast to devices if you know what branch you wish.  That is to say you can broadcast to all
 * devices on "SS13.ATMOS.SCRUBBERS" to change the settings of all the scrubbers on the station or to
 * "SS13.AREA.FRED_HOME.SCRUBBERS" to all the scrubbers at one area.  However devices CANNOT communicate cross
 * networks normality.
 *
 */

/datum/ntnet
	/// The full network name for this network ex. SS13.ATMOS.SCRUBBERS
	var/network_id
	/// The network name part of this leaf ex ATMOS
	var/network_node_id
	/// All devices on this network.  ALL devices on this network, not just this branch.
	/// This list is shared between all leaf networks so we don't have to keep going to the
	/// parents on lookups.  It is an associated list of hardware_id AND tag_id's
	var/list/root_devices
	/// This lists has all the networks in this node.  Each name is fully qualified
	/// ie. SS13.ATMOS.SCRUBBERS, SS13.ATMOS.VENTS, etc
	var/list/networks
	/// All the devices on this branch of the network
	var/list/linked_devices
	/// Network children.  Associated list using the network_node_id of the child as the key
	var/list/children
	/// Parrnt of the network.  If this is null, we are a oot network
	var/datum/ntnet/parent

/*
 * Creates a new network
 *
 * Used for /datum/controller/subsystem/networks/proc/create_network so do not
 * call yourself as new doesn't do any checking itself
 *
 * Arguments:
 * * net_id - Fully qualified network id for this network
 * * net_part_id - sub part of a network if this is a child of P
 * * P - Parent network, this will be attached to that network.
 */
/datum/ntnet/New(net_id, net_part_id, datum/ntnet/P = null)
	linked_devices = list()
	children = list()
	network_id = net_id

	if(P)
		network_node_id = net_part_id
		parent = P
		parent.children[network_node_id] = src
		root_devices = parent.root_devices
		networks = parent.networks
		networks[network_id] = src
	else
		network_node_id = net_id
		parent = null
		networks = list()
		root_devices = linked_devices
		SSnetworks.root_networks[network_id] = src

	SSnetworks.networks[network_id] = src

	SSnetworks.add_log("Network was created: [network_id]")

	return ..()

/// A network should NEVER be deleted.  If you don't want to show it exists just check if its
/// empty
/datum/ntnet/Destroy(force)
	networks -= network_id
	if(children.len > 0 || linked_devices.len > 0)
		CRASH("Trying to delete a network with devices still in them")

	if(parent)
		parent.children.Remove(network_id)
		parent = null
	else
		SSnetworks.root_networks.Remove(network_id)

	SSnetworks.networks.Remove(network_id)

	root_devices = null
	networks = null
	network_node_id = null
	SSnetworks.add_log("Network was destroyed: [network_id]")
	network_id = null

	return ..()

/*
 * Collects all the devices on this branch of the network and maybe its
 * children
 *
 * Used for broadcasting, this will collect all the interfaces on this
 * network and by default everything below this branch.  Will return an
 * empty list if no devices were found
 *
 * Arguments:
 * * include_children - Include the children of all branches below this
 */
/datum/ntnet/proc/collect_interfaces(include_children=TRUE)
	if(!include_children || children.len == 0)
		return linked_devices.Copy()
	else
		/// Please no recursion.  Byond hates recursion
		var/list/devices = list()
		var/list/queue = list(src) // add ourselves
		while(queue.len)
			var/datum/ntnet/net = queue[queue.len--]
			if(net.children.len > 0)
				for(var/net_id in net.children)
					queue += networks[net_id]
			devices += net.linked_devices
		return devices


/**
 * Add this interface to this branch of the network.
 *
 * This will add a network interface to this branch of the network.
 * If the interface already exists on the network it will add it and
 * give the alias list in the interface this branch name.  If the interface
 * has an id_tag it will add that name to the root_devices for map lookup
 *
 * Arguments:
 * * interface - ntnet component of the device to add to the network
 */
/datum/ntnet/proc/add_interface(datum/component/ntnet_interface/interface)
	if(interface.network)
		/// If we are doing a hard jump to a new network, log it
		log_telecomms("The device {[interface.hardware_id]} is jumping networks from '[interface.network.network_id]' to '[network_id]'")
		interface.network.remove_interface(interface, TRUE)
	interface.network ||= src
	interface.alias[network_id] = src // add to the alias just to make removing easier.
	linked_devices[interface.hardware_id] = interface
	root_devices[interface.hardware_id] = interface
	if(interface.id_tag != null) // could be a type, never know
		root_devices[interface.id_tag] = interface

/*
 * Remove this interface from the network
 *
 * This will remove an interface from this network and null the network field on the
 * interface.  Be sure that add_interface is run as soon as posable as an interface MUST
 * have a network
 *
 * Arguments:
 * * interface - ntnet component of the device to remove to the network
 * * remove_all_alias - remove ALL references to this device on this network
 */
/datum/ntnet/proc/remove_interface(datum/component/ntnet_interface/interface, remove_all_alias=FALSE)
	if(!interface.alias[network_id])
		log_telecomms("The device {[interface.hardware_id]} is trying to leave a '[network_id]'' when its on '[interface.network.network_id]'")
		return
	// just cashing it
	var/hardware_id = interface.hardware_id
	// Handle the quick case
	interface.alias.Remove(network_id)
	linked_devices.Remove(hardware_id)
	if(remove_all_alias)
		var/datum/ntnet/net
		for(var/id in interface.alias)
			net = interface.alias[id]
			net.linked_devices.Remove(hardware_id)

	// Now check if there are more than meets the eye
	if(interface.network == src || remove_all_alias)
		// Ok, so we got to remove this network, but if we have an alias we are still "on" the network
		// so we need to shift down to one of the other networks on the alias list.  If the alias list
		// is empty, fuck it and remove it from the network.
		if(interface.alias.len > 0)
			interface.network = interface.alias[1] // ... whatever is there.
		else
			// ok, hard remove from everything then
			root_devices.Remove(interface.hardware_id)
			if(interface.id_tag != null) // could be a type, never know
				root_devices.Remove(interface.id_tag)
			interface.network = null

/*
 * Move interface to another branch of the network
 *
 * This function is a lightweight way of moving an interface from one branch to another like a gps
 * device going from one area to another.  Target network MUST be this network or it will fail
 *
 * Arguments:
 * * interface - ntnet component of the device to move
 * * target_network - qualified network id to move to
 * * original_network - qualified network id from the original network if not this one
 */
/datum/ntnet/proc/move_interface(datum/component/ntnet_interface/interface, target_network, original_network = null)
	var/datum/ntnet/net = original_network == null ? src : networks[original_network]
	var/datum/ntnet/target = networks[target_network]
	if(!target || !net)
		log_telecomms("The device {[interface.hardware_id]} is trying to move to a network ([target_network]) that is not on ([network_id])")
		return
	if(target.linked_devices[interface.hardware_id])
		log_telecomms("The device {[interface.hardware_id]} is trying to move to a network ([target_network]) it is already on.")
		return
	if(!net.linked_devices[interface.hardware_id])
		log_telecomms("The device {[interface.hardware_id]} is trying to move to a network ([target_network]) but its not on ([net.network_id]) ")
		return
	net.linked_devices.Remove(interface.hardware_id)
	target.linked_devices[interface.hardware_id] = interface
	interface.alias.Remove(net.network_id)
	interface.alias[target.network_id] = target
