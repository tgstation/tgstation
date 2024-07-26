/obj/machinery/computer/shuttle/goldeneye_cruiser
	name = "goldeneye cruiser helm"
	desc = "The terminal used to control the goldeneye cruiser."
	shuttleId = "goldeneye_cruiser"
	possible_destinations = "goldeneye_cruiser_custom;goldeneye_cruiser_dock;syndicate_away;syndicate_z5;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s;syndicate_cruiser_dock;whiteship_away;whiteship_home;whiteship_z4;whiteship_lavaland;ferry_away"
	circuit = /obj/item/circuitboard/computer/syndicate_shuttle
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	light_color = COLOR_SOFT_RED
	req_access = list(ACCESS_SYNDICATE)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/machinery/computer/shuttle/goldeneye_cruiser/launch_check(mob/user)
	return TRUE

/obj/machinery/computer/shuttle/goldeneye_cruiser/allowed(mob/to_check)
	if(issilicon(to_check) && !(ROLE_SYNDICATE in to_check.faction))
		return FALSE
	return ..()

/obj/machinery/computer/shuttle/goldeneye_cruiser/recall
	name = "goldeneye shuttle recall terminal"
	desc = "Use this if your friends left you behind."
	possible_destinations = "goldeneye_cruiser_dock"

/obj/machinery/computer/camera_advanced/shuttle_docker/goldeneye_cruiser
	name = "goldeneye cruiser navigation computer"
	desc = "Used to designate a precise transit location for the goldeneye cruiser."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	shuttlePortId = "goldeneye_cruiser_dock"
	shuttleId = "goldeneye_cruiser"
	jump_to_ports = list("syndicate_n" = 1, "whiteship_away" = 1, "whiteship_home" = 1, "whiteship_z4" = 1)
	view_range = 14
	whitelist_turfs = list(/turf/open/space, /turf/open/floor/plating, /turf/open/lava, /turf/closed/mineral, /turf/open/misc/ice/icemoon, /turf/open/misc/ice, /turf/open/misc/asteroid/snow/icemoon, /turf/closed/mineral/random/snow)
	see_hidden = TRUE
	x_offset = -10
	y_offset = 5

/datum/map_template/shuttle/goldeneye_cruiser
	name = "goldeneye cruiser"
	prefix = "_maps/shuttles/nova/"
	port_id = "goldeneye"
	suffix = "cruiser"
	who_can_purchase = null
