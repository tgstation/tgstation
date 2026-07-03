/obj/effect/mapping_helpers/airlock/access/all/command/blueshield/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_BLUESHIELD
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/command/blueshield/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_BLUESHIELD
	return access_list
