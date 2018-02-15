/datum/netdata				//this requires some thought later on but for now it's fine.
	var/network_id

	var/list/recipient_ids = list()
	var/sender_id

	var/plaintext_data
	var/plaintext_data_secondary
	var/plaintext_passkey

/datum/netdata/New(pldata, pldatas, plkey)
	if(!islist(pldata))
		plaintext_data = pldata
	else
		plaintext_data_from_list(pldata)
	if(!islist(pldatas))
		plaintext_data_secondary = pldatas
	else
		plaintext_data_secondary_from_list(pldatas)
	plaintext_passkey = plkey

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
	.["plaintext_data"] = plaintext_data
	.["plaintext_data_secondary"] = plaintext_data_secondary
	.["plaintext_passkey"] = plaintext_passkey

/datum/netdata/proc/generate_netlog()
	return "[json_encode(json_list_generation_netlog())]"

/datum/netdata/proc/plaintext_data_from_list(list/json)
	plaintext_data = json_encode(json)

/datum/netdata/proc/plaintext_data_secondary_from_list(list/json)
	plaintext_data_secondary = json_encode(json)
