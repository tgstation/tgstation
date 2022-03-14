/datum/techweb_node/cloning	//hippie start, re-add cloning
	id = "cloning"
	display_name = "Cloning"
	description = "We have the technology to make him."
	prereq_ids = list("biotech")
	design_ids = list("clonecontrol", "clonepod", "clonescanner", "dnascanner", "dna_disk")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
