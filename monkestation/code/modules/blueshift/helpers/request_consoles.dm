//requests console helpers
/obj/effect/mapping_helpers/requests_console
	desc = "You shouldn't see this. Report it please."
	late = TRUE

/obj/effect/mapping_helpers/requests_console/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_mapping("[src] spawned outside of mapload!")
		return INITIALIZE_HINT_QDEL

	return INITIALIZE_HINT_LATELOAD

/obj/effect/mapping_helpers/requests_console/LateInitialize()
	var/obj/machinery/airalarm/target = locate(/obj/machinery/requests_console) in loc
	if(isnull(target))
		var/area/target_area = get_area(target)
		log_mapping("[src] failed to find a requests console at [AREACOORD(src)] ([target_area.type]).")
	else
		payload(target)

	qdel(src)

/// Fills out the request console's variables
/obj/effect/mapping_helpers/requests_console/proc/payload(obj/machinery/requests_console/console)
	return

/obj/effect/mapping_helpers/requests_console/announcement
	name = "request console announcement helper"
	icon_state = "requests_console_announcement_helper"

/obj/effect/mapping_helpers/requests_console/announcement/payload(obj/machinery/requests_console/console)
	console.can_send_announcements = TRUE

/obj/effect/mapping_helpers/requests_console/assistance
	name = "request console assistance requestable helper"
	icon_state = "requests_console_assistance_helper"

/obj/effect/mapping_helpers/requests_console/assistance/payload(obj/machinery/requests_console/console)
	GLOB.req_console_assistance |= console.department

/obj/effect/mapping_helpers/requests_console/supplies
	name = "request console supplies requestable helper"
	icon_state = "requests_console_supplies_helper"

/obj/effect/mapping_helpers/requests_console/supplies/payload(obj/machinery/requests_console/console)
	GLOB.req_console_supplies |= console.department

/obj/effect/mapping_helpers/requests_console/information
	name = "request console information relayable helper"
	icon_state = "requests_console_information_helper"

/obj/effect/mapping_helpers/requests_console/information/payload(obj/machinery/requests_console/console)
	GLOB.req_console_information |= console.department

/obj/effect/mapping_helpers/requests_console/ore_update
	name = "request console ore update helper"
	icon_state = "requests_console_ore_update_helper"

/obj/effect/mapping_helpers/requests_console/ore_update/payload(obj/machinery/requests_console/console)
	console.receive_ore_updates = TRUE
