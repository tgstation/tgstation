#define SYNDICATE_CHALLENGE_TIMER 12000 //20 minutes

/obj/machinery/computer/shuttle/syndicate
	name = "syndicate shuttle terminal"
	circuit = /obj/item/circuitboard/computer/syndicate_shuttle
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	light_color = LIGHT_COLOR_RED
	req_access = list(ACCESS_SYNDICATE)
	shuttleId = "syndicate"
	possible_destinations = "syndicate_away;syndicate_z5;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s;syndicate_custom"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/machinery/computer/shuttle/syndicate/recall
	name = "syndicate shuttle recall terminal"
	possible_destinations = "syndicate_away"


/obj/machinery/computer/shuttle/syndicate/Topic(href, href_list)
	if(href_list["move"])
		var/obj/item/circuitboard/computer/syndicate_shuttle/board = circuit
		if(board.challenge && world.time < SYNDICATE_CHALLENGE_TIMER)
			to_chat(usr, "<span class='warning'>You've issued a combat challenge to the station! You've got to give them at least [round(((SYNDICATE_CHALLENGE_TIMER - world.time) / 10) / 60)] more minutes to allow them to prepare.</span>")
			return 0
		board.moved = TRUE
	..()

/obj/machinery/computer/shuttle/syndicate/drop_pod
	name = "syndicate assault pod control"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "dorm_available"
	light_color = LIGHT_COLOR_BLUE
	req_access = list(ACCESS_SYNDICATE)
	shuttleId = "steel_rain"
	possible_destinations = null
	clockwork = TRUE //it'd look weird

/obj/machinery/computer/shuttle/syndicate/drop_pod/Topic(href, href_list)
	if(href_list["move"])
		if(z != ZLEVEL_CENTCOM)
			to_chat(usr, "<span class='warning'>Pods are one way!</span>")
			return 0
	..()

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate
	name = "syndicate shuttle navigation computer"
	desc = "Used to designate a precise transit location for the syndicate shuttle."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	z_lock = ZLEVEL_STATION_PRIMARY
	shuttleId = "syndicate"
	shuttlePortId = "syndicate_custom"
	shuttlePortName = "custom location"
	jumpto_ports = list("syndicate_ne" = 1, "syndicate_nw" = 1, "syndicate_n" = 1, "syndicate_se" = 1, "syndicate_sw" = 1, "syndicate_s" = 1)
	view_range = 13
	x_offset = -4
	y_offset = -2

#undef SYNDICATE_CHALLENGE_TIMER