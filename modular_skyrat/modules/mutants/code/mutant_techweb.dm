/obj/item/circuitboard/machine/rna_recombinator
	name = "RNA Recombinator (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/rnd/rna_recombinator
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 2)

/datum/techweb_node/mutanttech
	id = "mutanttech"
	display_name = "Advanced Nanotrasen Viral Bioweapons Technology"
	description = "Research devices from the Nanotrasen viral bioweapons division! Got a virus problem? This'll save your day."
	prereq_ids = list("adv_engi", "adv_biotech")
	design_ids = list("rna_vial", "rna_extractor", "rna_recombinator")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 4000)

/datum/design/rna_vial
	name = "Empty RNA vial"
	desc = "An empty RNA vial for storing genetic information."
	id = "rna_vial"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 3000, /datum/material/silver = 1000)
	build_path = /obj/item/rna_vial
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/rna_extractor
	name = "Empty RNA vial"
	desc = "An RNA extraction device, use this on any subect you'd like to extract RNA data from, needs RNA vials to work."
	id = "rna_extractor"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/gold = 3000, /datum/material/uranium = 1000, /datum/material/diamond = 1000)
	build_path = /obj/item/rna_extractor
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/board/rna_recombinator
	name = "Machine Design (RNA Recombinator)"
	desc = "The MRNA Recombinator is one of Nanotrasens most advanced technologies and allows the exact recombination of virus RNA."
	id = "rna_recombinator"
	build_path = /obj/item/circuitboard/machine/rna_recombinator
	category = list("Research Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_MEDICAL
