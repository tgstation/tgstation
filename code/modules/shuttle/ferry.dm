/obj/machinery/computer/shuttle/ferry
	name = "transport ferry console"
	desc = "A console that controls the transport ferry."
	circuit = /obj/item/circuitboard/computer/ferry
	shuttleId = "ferry"
	possible_destinations = "ferry_home;ferry_away"
	req_access = list(ACCESS_CENT_GENERAL)
	var/allow_silicons = FALSE
	var/allow_emag = FALSE

/obj/machinery/computer/shuttle/ferry/emag_act(mob/user)
	if(!allow_emag)
		to_chat(user, span_warning("[src]'s security firewall is far too powerful for you to bypass."))
		return FALSE
	return ..()

/obj/machinery/computer/shuttle/ferry/attack_ai()
	return allow_silicons ? ..() : FALSE

/obj/machinery/computer/shuttle/ferry/attack_robot()
	return allow_silicons ? ..() : FALSE

/obj/machinery/computer/shuttle/ferry/request
	name = "ferry console"
	circuit = /obj/item/circuitboard/computer/ferry/request
	possible_destinations = "ferry_home;ferry_away"
	req_access = list(ACCESS_CENT_GENERAL)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
