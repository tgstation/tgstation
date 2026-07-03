/obj/effect/mapping_helpers/airlock/access/all/command/magistrate/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MAGISTRATE
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/command/magistrate/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MAGISTRATE
	return access_list
