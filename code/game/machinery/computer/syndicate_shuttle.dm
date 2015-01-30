/obj/machinery/computer/shuttle/syndicate
	name = "syndicate shuttle terminal"
	icon_state = "syndishuttle"
	req_access = list(access_syndicate)

	shuttleId = "syndicate"
	possible_destinations = "syndicate_away;syndicate_z5;syndicate_z3;syndicate_z4;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s"

/obj/machinery/computer/shuttle/syndicate/recall
	name = "syndicate shuttle recall terminal"
	possible_destinations = "syndicate_away"
