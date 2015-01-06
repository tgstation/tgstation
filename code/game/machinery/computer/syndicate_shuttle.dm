/obj/machinery/computer/shuttle/syndicate
	name = "syndicate shuttle terminal"
	icon_state = "syndishuttle"
	req_access = list(access_syndicate)

	shuttleId = "syndicate"
	possible_destinations = "syndicate_away;syndicate_mining;syndicate_commsat;home_ne;home_nw;home_n;home_se;home_sw;home_s"

/obj/machinery/computer/shuttle/syndicate/recall
	name = "syndicate shuttle recall terminal"
	possible_destinations = "syndicate_away"
