
// This netlink class shares a list to two devices
// This allows skipping of sending many many packets
// just to update simple data
/datum/netlink
	var/server_id
	var/server_network
	var/port
	var/connections = 0 // total links to this
	var/updated = 0 // counts data has been udpate, use to test if things have changed
	var/passkey = null // sends auth data used to check if we can connect or send data to a device
	var/list/data

/datum/netlink/New(list/data)
	ASSERT(data != null)
	src.data = data
	..()

/datum/netlink/Destroy()
	passkey = null
	data = null
	return ..()

/datum/netlink/proc/operator[](idx)
	if(QDELETED(src))
		return data[idx]
	else
		throw NETWORK_ERROR_DISCONNECTED

/datum/netlink/proc/operator[]=(idx, V)
	// is it posable to worry about racing conditions?
	if(QDELETED(src))
		if(data[idx] != V)
			updated++
			data[idx] = V
	else
		throw NETWORK_ERROR_DISCONNECTED

/datum/netdata
	//this requires some thought later on but for now it's fine. (WarlockD) ARRRRG
	// Packets are kind of shaped like IPX.  IPX had a network, a node (aka id) and a port.
	// Special case with receiver_id == null, that wil broadcast to the network_id
	// Also, if the network id is not the same for both sender and receiver the packet is dropped.
	var/sender_id
	var/receiver_id
	var/network_id
	var/list/data = list()
	var/passkey = null // sends auth data used to check if we can connect or send data to a device

/datum/netdata/proc/operator[](idx)
	if(data)
		return data[idx]

/datum/netdata/proc/operator[]=(idx, V)
	if(data)
		return data[idx] = V

/datum/netdata/New(list/data = null)
	if(!data)
		data = list()
	src.data = data

/datum/netdata/Destroy()
	data = null
	passkey = null
	return ..()

/datum/netdata/proc/clone(deep_copy=FALSE)
	var/datum/netdata/C = new
	C.sender_id = sender_id
	C.receiver_id = receiver_id
	C.network_id = network_id
	C.passkey = passkey
	if(deep_copy)
		C.data = deepCopyList(data)
	else
		C.data = data

// this proc just swaps the sender/receiver's id so we don't have to make a new packet
// if we are sending a return message
/datum/netdata/proc/make_return(list/new_data)
	var/temp
	temp = sender_id
	sender_id = receiver_id
	receiver_id = temp
	if(new_data)
		data = new_data

/datum/netdata/proc/json_to_data(json)
	data = json_decode(json)

/datum/netdata/proc/json_append_to_data(json)
	data |= json_decode(json)

/datum/netdata/proc/data_to_json()
	return json_encode(data)

/datum/netdata/proc/json_list_generation_admin()	//for admin logs and such.
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
