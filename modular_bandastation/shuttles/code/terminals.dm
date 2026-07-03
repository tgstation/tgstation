/obj/machinery/computer/shuttle/syndicate/sit
	name = "syndicate shuttle recall terminal"
	desc = "Use this if your friends left you behind."
	shuttleId = "syndicate_sit"
	possible_destinations = "syndicate_sit;syndicate_z5;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s;syndicate_custom"

/obj/machinery/computer/shuttle/syndicate/sst
	name = "syndicate shuttle recall terminal"
	desc = "Use this if your friends left you behind."
	shuttleId = "syndicate_sst"
	possible_destinations = "syndicate_sst;syndicate_z5;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s;syndicate_custom"

/**
 * Not sure now if we need to declare war if we use these shuttles
 * Probably not. If we want it, so we'll have to modify "is_infiltrator_docked_at_syndiebase" proc
 */
/obj/machinery/computer/shuttle/syndicate/sit/launch_check(mob/user)
	return allowed(user)

/obj/machinery/computer/shuttle/syndicate/sst/launch_check(mob/user)
	return allowed(user)

/obj/machinery/computer/shuttle/nanotrasen/drop_pod
	name = "nanotrasen assault pod control"
	desc = "Controls the drop pod's launch system."
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "pod_off"
	icon_keyboard = null
	icon_screen = "pod_on"
	light_color = LIGHT_COLOR_BLUE
	req_access = list(ACCESS_CENT_GENERAL)
	shuttleId = "assault_pod_nt"
	possible_destinations = null

// Assault Pod Control
/obj/item/assault_pod/nanotrasen
	shuttle_id = "assault_pod_nt"
	lzname = "assault_pod_nt"

/obj/machinery/computer/shuttle/argos
	name = "transport argos console"
	desc = "A console that controls the transport Argos."
	icon_screen = "teleport"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/argos
	shuttleId = "argos"
	possible_destinations = "argos_home;argos_trurl;argos_custom"
	req_access = list(ACCESS_CENT_GENERAL)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/circuitboard/computer/argos
	name = "Transport Argos"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/shuttle/argos

/obj/machinery/computer/shuttle/specops
	name = "transport specops shuttle console"
	desc = "A console that controls the transport Specops shuttle."
	icon_screen = "teleport"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/specops
	shuttleId = "specops"
	possible_destinations = "specops_home;specops_trurl;specops_custom"
	req_access = list(ACCESS_CENT_GENERAL)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/circuitboard/computer/specops
	name = "Transport Specops"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/shuttle/specops
