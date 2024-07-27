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
		"podcargohold",
		"podextraseats",
		"podpinlock",
//t1 parts here
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
