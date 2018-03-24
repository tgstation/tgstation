/datum/netdata				//this requires some thought later on but for now it's fine.
	var/network_id

	var/list/recipient_ids = list()
	var/sender_id

	var/plaintext_data
	var/plaintext_data_secondary
	var/encrypted_passkey

	var/list/passkey

// Process data before sending it
/datum/netdata/proc/pre_send(datum/component/ntnet_interface/interface)
	// Decrypt the passkey.
	if(encrypted_passkey && !passkey)
		var/result = XorEncrypt(hextostr(encrypted_passkey, TRUE), SScircuit.cipherkey)
		if(length(result) > 1)
			passkey = json_decode(XorEncrypt(hextostr(encrypted_passkey, TRUE), SScircuit.cipherkey))

	// Encrypt the passkey.
	if(!encrypted_passkey && passkey)
		encrypted_passkey = strtohex(XorEncrypt(json_encode(passkey), SScircuit.cipherkey))

	// If there is no sender ID, set the default one.
	if(!sender_id && interface)
		sender_id = interface.hardware_id


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
	.["data"] = plaintext_data
	.["data_secondary"] = plaintext_data_secondary
	.["passkey"] = encrypted_passkey

/datum/netdata/proc/generate_netlog()
	return "[json_encode(json_list_generation_netlog())]"
