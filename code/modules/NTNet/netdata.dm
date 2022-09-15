// This netlink class shares a list to two devices
// This allows skipping of sending many many packets
// just to update simple data
/datum/netlink
	var/server_id
	var/server_network
	var/port
	var/passkey = null // sends auth data used to check if we can connect or send data to a device
	var/list/data

/datum/netlink/New(datum/component/ntnet_interface/conn, port)
	data = conn.registered_sockets[port]
	ASSERT(data != null)
	server_id = conn.hardware_id
	server_network = conn.network.network_id
	src.port = port
	RegisterSignal(conn, COMSIG_COMPONENT_NTNET_PORT_DESTROYED, .proc/_server_disconnected)
	..()

/datum/netlink/proc/_server_disconnected(datum/component/com)
	SIGNAL_HANDLER
	data = null

/datum/netlink/Destroy()
	passkey = null
	data = null
	return ..()

// If you don't want to use this fine, but this just shows how the system works

// I hate you all.  I want to operator overload []
// So fuck you all, Do NOT access data directly you freaks
// or this breaks god knows what.
// FINE, you don't have to use get, is dirty or even clean
// proc overhead is WAY more important than fucking clarity or
// sealed classes.   But for the LOVE OF GOD make sure _updated
// is set if your going to do this.
/datum/netlink/proc/get(idx)
	return data ? data[idx] : null

/datum/netlink/proc/put(idx, V)
	// is it posable to do this async without worry about racing conditions?
	if(data && data[idx] != V)
		data["_updated"] = TRUE
		data[idx] = V


/datum/netlink/proc/is_dirty()
	return data && data["_updated"]

/datum/netlink/proc/clean()
	if(data)
		data["_updated"] = FALSE

/datum/netlink/proc/is_connected()
	return data != null



/datum/netdata
	//this requires some thought later on but for now it's fine. (WarlockD) ARRRRG
	// Packets are kind of shaped like IPX.  IPX had a network, a node (aka id) and a port.
	// Special case with receiver_id == null, that wil broadcast to the network_id
	// Also, if the network id is not the same for both sender and receiver the packet is dropped.
	var/sender_id
	var/receiver_id
	var/network_id
	var/passkey = null // sends auth data used to check if we can connect or send data to a device
	var/list/data = list()
	// Used for packet queuing
	var/datum/netdata/next = null
	var/mob/user = null // used for sending error messages

/datum/netdata/New(list/data = null)
	if(!data)
		data = list()
	src.data = data

/datum/netdata/Destroy()
	data = null
	passkey = null
	next = null
	user = null
	return ..()

/datum/netdata/proc/clone(deep_copy=FALSE)
	var/datum/netdata/C = new
	C.sender_id = sender_id
	C.receiver_id = receiver_id
	C.network_id = network_id
	C.passkey = passkey
	C.user = user
	C.next = null
	if(deep_copy)
		C.data = deep_copy_list(data)
	else
		C.data = data
	return C


/datum/netdata/proc/json_to_data(json)
	data = json_decode(json)

/datum/netdata/proc/json_append_to_data(json)
	data |= json_decode(json)

/datum/netdata/proc/data_to_json()
	return json_encode(data)

/datum/netdata/proc/json_list_generation_admin() //for admin logs and such.
	. = list()
	. |= json_list_generation()

/datum/netdata/proc/json_list_generation()
	. = list()
	. |= json_list_generation_netlog()

/datum/netdata/proc/json_list_generation_netlog()
	. = list()
	.["network_id"] = network_id
	.["sender_id"] = sender_id
	.["receiver_id"] = receiver_id
	.["data_list"] = data

/datum/netdata/proc/generate_netlog()
	return "[json_encode(json_list_generation_netlog())]"
