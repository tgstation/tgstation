/datum/techweb_node/spacepod_base
	id = TECHWEB_NODE_SPACEPOD
	display_name = "Space Travel Basics"
	description = "Robustly engineered tech needed for your space travel pod."
	prereq_ids = list(TECHWEB_NODE_MINING)
	design_ids = list(
		"pod_board",
		"podrunner",
		"podthruster1",
		"podengine1",
		"podengine2",
		"podsensors",
		"podcomms",
		"podcargohold",
		"podextraseats",
		"podpinlock",
		"poddrill",
		"podfoamtool",
		"podorehold",
		"podwildlifegun",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/spacepod_tier2
	id = TECHWEB_NODE_SPACEPOD_T2
	display_name = "Improved Pod Parts"
	description = "Better parts for your space pods, to pimp your ride."
	prereq_ids = list(TECHWEB_NODE_SPACEPOD, TECHWEB_NODE_PARTS_UPG)
	design_ids = list(
		"podsensorsmesons",
		"podengine3",
		"podthruster2",
		"podimpactdrill",
		"podplasmacutter",
		"podlgtplating",
		"podefficiency",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/spacepod_t3
	id = TECHWEB_NODE_SPACEPOD_T3
	display_name = "Advanced Pod Parts"
	description = "Even better space pod parts, for the true speedsters."
	prereq_ids = list(TECHWEB_NODE_SPACEPOD_T2, TECHWEB_NODE_PARTS_ADV, TECHWEB_NODE_NIGHT_VISION)
	design_ids = list(
		"podsensorsnightvision",
		"podengine4",
		"podthruster3",
		"improvedimpactdrill",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
