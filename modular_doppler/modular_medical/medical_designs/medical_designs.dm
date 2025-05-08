/datum/design/cyberimp_botany
	name = "Hydroponics Toolset Implant"
	desc = "Everything a botanist needs in an arm implant, designed to be installed on a subject's arm."
	id = "ci-botany"
	build_type = MECHFAB | PROTOLATHE
	materials = list (
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT,
	)
	construction_time = 20 SECONDS
	build_path = /obj/item/organ/cyberimp/arm/botany
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_TOOLS,
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/cyberimp_janitor
	name = "Sanitation Toolset Implant"
	desc = "A set of janitor tools fitted into an arm implant, designed to be installed on subject's arm."
	id = "ci-janitor"
	build_type = PROTOLATHE | MECHFAB
	materials = list (
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)
	construction_time = 20 SECONDS
	build_path = /obj/item/organ/cyberimp/arm/janitor
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_TOOLS,
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/cyberimp_drill
	name = "Dalba Masterworks 'Burrower' Integrated Drill"
	desc = "Extending from a stabilization bracer built into the upper forearm, this implant allows for a steel mining drill to extend over the user's hand. Little by little, we advance a bit further with each turn. That's how a drill works!"
	id = "ci-drill"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list (
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)
	construction_time = 20 SECONDS
	build_path = /obj/item/organ/cyberimp/arm/mining_drill
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_TOOLS,
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_CARGO

/datum/design/cyberimp_diamond_drill
	name = "Dalba Masterworks 'Tunneler' Diamond Drill"
	desc = "Extending from a stabilization bracer built into the upper forearm, this implant allows for a masterwork diamond mining drill to extend over the user's hand. This drill will open a hole in the universe, and that hole will be a path for those behind us!"
	id = "ci-drill-diamond"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT*3,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/diamond = SHEET_MATERIAL_AMOUNT,
	)
	construction_time = 30 SECONDS
	build_path = /obj/item/organ/cyberimp/arm/mining_drill/diamond
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MINING
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_CARGO

/datum/techweb_node/mining_adv/New() //Here for the integrated drill augments.
	design_ids += "ci-drill-diamond"
	return ..()

/datum/design/cyberimp_claws
	name = "Razor Claws Implant"
	desc = "Long, sharp, double-edged razors installed within the fingers, functional for cutting. All kinds of cutting."
	id = "ci-razor"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list (
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)
	construction_time = 20 SECONDS
	build_path = /obj/item/organ/cyberimp/arm/razor_claws
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_TOOLS,
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SECURITY
