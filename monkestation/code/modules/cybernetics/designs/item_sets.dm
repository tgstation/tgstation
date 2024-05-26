/datum/design/itemset_botany
	name = "Botany Arm Implant"
	desc =  "A rather simple arm implant containing tools used in gardening and botanical research."
	id = "ci-set-botany"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 3 SECONDS
	materials = list(/datum/material/iron = 2500, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/silver =HALF_SHEET_MATERIAL_AMOUNT * 1.5)
	build_path = /obj/item/organ/internal/cyberimp/arm/item_set/botany
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_TOOLS
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/itemset_connector
	name = "Universal Connection Implant"
	desc =  "Special inhand implant that allows you to connect your brain directly into the protocl sphere of implants, which allows for you to hack them and make the compatible."
	id = "ci-set-connector"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 3 SECONDS
	materials = list(/datum/material/iron = 2500, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/silver =HALF_SHEET_MATERIAL_AMOUNT * 1.5)
	build_path = /obj/item/organ/internal/cyberimp/arm/item_set/connector
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_TOOLS
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/itemset_atmospherics
	name = "Atmospheric Arm Implant"
	desc =   "A set of atmospheric tools hidden behind a concealed panel on the user's arm."
	id = "ci-set-atmospherics"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 3 SECONDS
	materials = list(/datum/material/iron = 2500, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/silver =HALF_SHEET_MATERIAL_AMOUNT * 1.5)
	build_path = /obj/item/organ/internal/cyberimp/arm/item_set/atmospherics
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_TOOLS
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/itemset_chemical
	name = "Chemical Arm Implant"
	desc =   "A set of chemical tools hidden behind a concealed panel on the user's arm."
	id = "ci-set-chemical"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 3 SECONDS
	materials = list(/datum/material/iron = 2500, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/silver =HALF_SHEET_MATERIAL_AMOUNT * 1.5)
	build_path = /obj/item/organ/internal/cyberimp/arm/item_set/chemical
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_TOOLS
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/itemset_detective
	name = "Detective's Arm Implant"
	desc =   "A set of detective's tools hidden behind a concealed panel on the user's arm."
	id = "ci-set-detective"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 3 SECONDS
	materials = list(/datum/material/iron = 2500, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/silver =HALF_SHEET_MATERIAL_AMOUNT * 1.5)
	build_path = /obj/item/organ/internal/cyberimp/arm/item_set/detective
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_TOOLS
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/itemset_janitor
	name = "Janitorial Arm Implant"
	desc =   "A set of janitor's tools hidden behind a concealed panel on the user's arm."
	id = "ci-set-janitor"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 3 SECONDS
	materials = list(/datum/material/iron = 2500, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/silver =HALF_SHEET_MATERIAL_AMOUNT * 1.5)
	build_path = /obj/item/organ/internal/cyberimp/arm/item_set/janitor
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_TOOLS
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/itemset_cook
	name = "Cook's Arm Implant"
	desc =   "A set of cook's tools hidden behind a concealed panel on the user's arm."
	id = "ci-set-cook"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 3 SECONDS
	materials = list(/datum/material/iron = 2500, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/silver =HALF_SHEET_MATERIAL_AMOUNT * 1.5)
	build_path = /obj/item/organ/internal/cyberimp/arm/item_set/cook
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_TOOLS
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/itemset_mining
	name = "Drill Arm Implant"
	desc =  "Just a big drill, implanted into your hand."
	id = "ci-set-mining"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 3 SECONDS
	materials = list(/datum/material/iron = 2500, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/silver =HALF_SHEET_MATERIAL_AMOUNT * 1.5)
	build_path = /obj/item/organ/internal/cyberimp/arm/item_set/mining_drill
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_TOOLS
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/cyberlink_connector
	name = "Cyberlink Connector"
	desc =  "A cyberlink connector used to hack implants."
	id = "ci-cyberconnector"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 3 SECONDS
	materials = list(/datum/material/iron = 2500, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT * 1.5)
	build_path = /obj/item/cyberlink_connector
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_TOOLS
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL
