/datum/techweb_node/borg_shapeshifter
	id = "borg_shapeshifter"
	display_name = "Illegal Cyborg Addition"
	description = "An dangerous and experimental tool that was once used by an rival company"
	prereq_ids = list("syndicate_basic", "adv_robotics", "cyborg_upg_util")
	design_ids = list("borg_shapeshifter_module")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	hidden = TRUE
