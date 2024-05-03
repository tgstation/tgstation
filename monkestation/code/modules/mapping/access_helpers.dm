/obj/effect/mapping_helpers/airlock/access/any/payload_windoor(obj/machinery/door/window/windoor)
	if(windoor.req_access != null)
		log_mapping("[src] at [AREACOORD(src)] tried to set req_one_access, but req_access was already set!")
	else
		var/list/access_list = get_access()
		windoor.req_one_access += access_list

/obj/effect/mapping_helpers/airlock/access/all/payload_windoor(obj/machinery/door/window/windoor)
	if(windoor.req_one_access != null)
		log_mapping("[src] at [AREACOORD(src)] tried to set req_one_access, but req_access was already set!")
	else
		var/list/access_list = get_access()
		windoor.req_access += access_list


/obj/effect/mapping_helpers/airlock/access/all/service/kitchen/east_offset
	offset_dir = EAST

/obj/effect/mapping_helpers/airlock/access/all/service/theatre/east_offset
	offset_dir = EAST

/obj/effect/mapping_helpers/airlock/access/all/service/bar/west_offset
	offset_dir = WEST

/obj/effect/mapping_helpers/airlock/access/any/engineering/maintenance/east_offset
	offset_dir = EAST

/obj/effect/mapping_helpers/airlock/access/any/engineering/maintenance/west_offset
	offset_dir = WEST

/obj/effect/mapping_helpers/airlock/access/any/security/permabrig/get_access()
	. = ..()
	. += list(ACCESS_PERMABRIG, ACCESS_BRIG)
