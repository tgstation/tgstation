/datum/netdata
	//this requires some thought later on but for now it's fine. (WarlockD) ARRRRG
	// Packets are kind of shaped like IPX.  IPX had a network, a node (aka id) and a port.
	// receiver_id == null, its a brodcast packet to that network
	// all these should be strings and numbers.  If a device wants to be smart and cashe
	// them, then they should manualy go though SSnetworks and find the device there
	var/sender_network
	var/sender_id
	var/sender_port = "normal_data"
	var/receiver_network
	var/receiver_id
	var/receiver_port = "normal_data"
	var/list/data = list()
	var/passkey = null // for encryption?  Originaly used for a silly rot13 encryption on the packet


/datum/netdata/New(list/data = null)
	src.data = data || list()
	
/datum/netdata/Destroy()
	data = null
	return ..()

/datum/netdata/proc/clone(deep_copy=FALSE)
	var/datum/netdata/C = new
	C.sender_network = sender_network
	C.sender_id = sender_id
	C.sender_port = sender_port
	C.receiver_network = receiver_network
	C.receiver_id = receiver_id
	C.receiver_port = receiver_port
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
	temp = sender_port
	sender_port = receiver_port
	receiver_port = temp
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
	.["sender_port"] = sender_port
	.["receiver_network"] = receiver_network
	.["receiver_id"] = receiver_id
	.["receiver_port"] = receiver_port
	.["data_list"] = data

/datum/netdata/proc/generate_netlog()
	return "[json_encode(json_list_generation_netlog())]"
