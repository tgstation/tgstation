/datum/netdata
	//this requires some thought later on but for now it's fine. (WarlockD) ARRRRG
	// Packets are kind of shaped like IPX.  IPX had a network, a node (aka id) and a port.
	// receiver_id == null, its a brodcast packet to that network
	// all these should be strings and numbers.  If a device wants to be smart and cashe
	// them, then they should manualy go though SSnetworks and find the device there 
	var/sender_network
	var/sender_id
	var/sender_port
	var/receiver_network
	var/receiver_id
	var/receiver_port
	var/list/data = list()
	var/passkey = null


/datum/netdata/Destroy()
	data = null
	return ..()

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
	.["network_id"] = network.network_id

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
