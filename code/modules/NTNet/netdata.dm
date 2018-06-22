/datum/netdata				//this requires some thought later on but for now it's fine.
	var/network_id

	var/autopasskey = TRUE

	var/list/recipient_ids = list()
	var/sender_id
	var/broadcast = FALSE			//Whether this is a broadcast packet.

	var/list/data = list()

	var/list/passkey

// Process data before sending it
/datum/netdata/proc/pre_send(datum/component/ntnet_interface/interface)
	// Decrypt the passkey.
	if(autopasskey)
		if(data["encrypted_passkey"] && !passkey)
			var/result = XorEncrypt(hextostr(data["encrypted_passkey"], TRUE), SScircuit.cipherkey)
			if(length(result) > 1)
				passkey = json_decode(XorEncrypt(hextostr(data["encrypted_passkey"], TRUE), SScircuit.cipherkey))

			// Encrypt the passkey.
			if(!data["encrypted_passkey"] && passkey)
				data["encrypted_passkey"] = strtohex(XorEncrypt(json_encode(passkey), SScircuit.cipherkey))

	// If there is no sender ID, set the default one.
	if(!sender_id && interface)
		sender_id = interface.hardware_id

/datum/netdata/proc/standard_format_data(primary, secondary, passkey)
	data["data"] = primary
	data["data_secondary"] = secondary
	data["encrypted_passkey"] = passkey

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
	.["network_id"] = network_id

/datum/netdata/proc/json_list_generation_netlog()
	. = list()
	.["recipient_ids"] = recipient_ids
	.["sender_id"] = sender_id
	.["data_list"] = data

/datum/netdata/proc/generate_netlog()
	return "[json_encode(json_list_generation_netlog())]"
