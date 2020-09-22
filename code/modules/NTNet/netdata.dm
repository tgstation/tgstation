
// This netlink class shares a list to two devices
// This allows skiping of all the messy connection interfaces
//

/datum/netlink
	var/server_id
	var/server_network
	var/port
	var/connections = 0 // total links to this
	var/last_update
	var/passkey = null // sends auth data used to check if we can connect or send data to a device
	var/list/data

/datum/netlink/New(list/data)
	ASSERT(data != null)
	src.data = data
	last_update = world.time
	..()

// returns if the the data was refreshed
/datum/netlink/proc/updated()
	if(data["timestamp"] && data["timestamp"] > last_update)
		last_update = data["timestamp"]
		return TRUE

/datum/netlink/Destroy()
	passkey = null
	last_update = null
	return ..()

/datum/netlink/proc/operator[](idx)
	// is it posable to worry about racing conditions?
	if(data || QDELETED(src))
		return data[idx]
	else
		throw NETWORK_ERROR_DISCONNECTED

/datum/netlink/proc/operator[]=(idx, V)
	// is it posable to worry about racing conditions?
	if(data  || QDELETED(src))
		data[idx] = V
	else
		throw NETWORK_ERROR_DISCONNECTED

/datum/netdata
	//this requires some thought later on but for now it's fine. (WarlockD) ARRRRG
	// Packets are kind of shaped like IPX.  IPX had a network, a node (aka id) and a port.
	// receiver_id == null, its a brodcast packet to that network
	// all these should be strings and numbers.  If a device wants to be smart and cashe
	// them, then they should manualy go though SSnetworks and find the device there
	var/sender_network
	var/sender_id
	var/receiver_network
	var/receiver_id
	var/port = null
	var/list/data = list()
	var/passkey = null // sends auth data used to check if we can connect or send data to a device

/datum/netdata/proc/operator[](idx)
	if(data)
		return data[idx]

/datum/netdata/proc/operator[]=(idx, V)
	if(data)
		return data[idx] = V

/datum/netdata/New(list/data = null)
	src.data = data || list()

/datum/netdata/Destroy()
	data = null
	return ..()



/datum/netdata/proc/clone(deep_copy=FALSE)
	var/datum/netdata/C = new
	C.sender_network = sender_network
	C.sender_id = sender_id
	C.receiver_network = receiver_network
	C.receiver_id = receiver_id
	C.port = port
	C.passkey = passkey
	if(deep_copy)
		C.data = deepCopyList(data)
	else
		C.data = data

// this proc just changes the sender/reciever's so we don't have to make a new packet
/datum/netdata/proc/make_return(list/new_data)
	var/temp
	temp = sender_network
	sender_network = receiver_network
	receiver_network = temp
	temp = sender_id
	sender_id = receiver_id
	receiver_id = temp
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
	.["sender_network"] = sender_network
	.["sender_id"] = sender_id
	.["receiver_network"] = receiver_network
	.["receiver_id"] = receiver_id
	.["potr"] = port
	.["data_list"] = data

/datum/netdata/proc/generate_netlog()
	return "[json_encode(json_list_generation_netlog())]"
