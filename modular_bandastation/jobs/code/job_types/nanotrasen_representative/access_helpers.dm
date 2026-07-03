/obj/effect/mapping_helpers/airlock/access/all/command/nanotrasen_representative/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_NANOTRASEN_REPRESENTATIVE
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/command/nanotrasen_representative/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_NANOTRASEN_REPRESENTATIVE
	return access_list
