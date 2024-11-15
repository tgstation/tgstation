/datum/station_goal/extract_plasma
	name = "Plasma Extraction"
	requires_space = TRUE //there isn't support for planet-side plasma extraction yet.
	goal_type = MINING_GOAL

/datum/station_goal/extract_plasma/get_report()
	return list(
		"<blockquote>Our plasma reserves are running low, hitting our Research Division hard.",
		"We need you to send the plasma extraction machine down to the surface of the planet.",
		"",
		"Once the machine is in place, connect it to the fuming plasma geysers planet-side using rapid pipe dispensers, which you can find the location of these using a GPS.",
		"Once fully piped, you can begin extracting plasma from the planet's core.",
		"Get it filled as much as you can, once completed we'll be processing it and you'll be able to purchase plasma canisters from Cargo.</blockquote>",
	).Join("\n")
