
///////////////////////////////////
/////Non-Board Computer Stuff//////
///////////////////////////////////

/datum/design/intellicard
	name = "Intellicard AI Transportation System"
	desc = "Allows for the construction of an intellicard."
	id = "intellicard"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/gold =SMALL_MATERIAL_AMOUNT * 2)
	build_path = /obj/item/aicard
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_MISC
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/paicard
	name = "Personal Artificial Intelligence Card"
	desc = "Allows for the construction of a pAI Card."
	id = "paicard"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/glass =SMALL_MATERIAL_AMOUNT*5, /datum/material/iron =SMALL_MATERIAL_AMOUNT*5)
	build_path = /obj/item/pai_card
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_MISC
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_SERVICE

/datum/design/ai_cam_upgrade
	name = "AI Surveillance Software Update"
	desc = "A software package that will allow an artificial intelligence to 'hear' from its cameras via lip reading."
	id = "ai_cam_upgrade"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron =SHEET_MATERIAL_AMOUNT * 2.5, /datum/material/glass =SHEET_MATERIAL_AMOUNT * 2.5, /datum/material/gold = SHEET_MATERIAL_AMOUNT * 7.5, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 7.5, /datum/material/diamond = SHEET_MATERIAL_AMOUNT * 10, /datum/material/plasma = SHEET_MATERIAL_AMOUNT * 5)
	build_path = /obj/item/aiupgrade/surveillance_upgrade
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_UPGRADES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/ai_power_transfer
	name = "AI Power Transfer Update"
	desc = "An upgrade package that lets an AI charge an APC from a distance"
	id = "ai_power_upgrade"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron =SHEET_MATERIAL_AMOUNT * 2.5, /datum/material/glass =SHEET_MATERIAL_AMOUNT * 2.5)
	build_path = /obj/item/aiupgrade/power_transfer
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_UPGRADES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

////////////////////////////////////////
//////////Disk Construction Disks///////
////////////////////////////////////////
/datum/design/tech_disk
	name = "Technology Data Storage Disk"
	desc = "Produce additional disks for storing technology data."
	id = "tech_disk"
	build_type = PROTOLATHE | AWAY_LATHE | AUTOLATHE
	materials = list(/datum/material/iron =SMALL_MATERIAL_AMOUNT * 3, /datum/material/glass =SMALL_MATERIAL_AMOUNT)
	build_path = /obj/item/disk/tech_disk
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SCIENCE
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE
