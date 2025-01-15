/*
* Designs
*/

/datum/design/health_hud_aviator
	name = "Medical HUD Aviators"
	desc = "A heads-up display that scans the humanoids in view and provides accurate data about their health status. This HUD has been fitted inside of a pair of sunglasses."
	id = "health_hud_aviator"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT * 4,
	)
	build_path = /obj/item/clothing/glasses/hud/ar/aviator/health
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_MEDICAL,
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/security_hud_aviator
	name = "Security HUD Aviators"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status. This HUD has been fitted inside of a pair of sunglasses."
	id = "security_hud_aviator"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT * 4,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT * 2,
	)
	build_path = /obj/item/clothing/glasses/hud/ar/aviator/security
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SECURITY,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/diagnostic_hud_aviator
	name = "Diagnostic HUD Aviators"
	desc = "A heads-up display used to analyze and determine faults within robotic machinery. This HUD has been fitted inside of a pair of sunglasses."
	id = "diagnostic_hud_aviator"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT * 4,
	)
	build_path = /obj/item/clothing/glasses/hud/ar/aviator/diagnostic
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SCIENCE,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/meson_hud_aviator
	name = "Meson HUD Aviators"
	desc = "A heads-up display used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting condition. This HUD has been fitted inside of a pair of sunglasses."
	id = "meson_hud_aviator"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT * 4,
	)
	build_path = /obj/item/clothing/glasses/hud/ar/aviator/meson
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_ENGINEERING,
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/science_hud_aviator
	name = "Science Aviators"
	desc = "A pair of tacky purple aviator sunglasses that allow the wearer to recognize various chemical compounds with only a glance."
	id = "science_hud_aviator"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT * 4,
	)
	build_path = /obj/item/clothing/glasses/hud/ar/aviator/science
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SCIENCE,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/health_hud_projector
	name = "Retinal Projector Medical HUD"
	desc = "A headset equipped with a scanning lens and mounted retinal projector. It doesn't provide any eye protection, but it's less obtrusive than goggles."
	id = "health_hud_projector"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT * 4,
	)
	build_path = /obj/item/clothing/glasses/hud/ar/projector/health
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_MEDICAL,
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/security_hud_projector
	name = "Retinal Projector Security HUD"
	desc = "A headset equipped with a scanning lens and mounted retinal projector. It doesn't provide any eye protection, but it's less obtrusive than goggles."
	id = "security_hud_projector"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT * 4,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT * 2,
	)
	build_path = /obj/item/clothing/glasses/hud/ar/projector/security
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SECURITY,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/diagnostic_hud_projector
	name = "Retinal Projector Diagnostic HUD"
	desc = "A headset equipped with a scanning lens and mounted retinal projector. It doesn't provide any eye protection, but it's less obtrusive than goggles."
	id = "diagnostic_hud_projector"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT * 4,
	)
	build_path = /obj/item/clothing/glasses/hud/ar/projector/diagnostic
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SCIENCE,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/meson_hud_projector
	name = "Retinal Projector Meson HUD"
	desc = "A headset equipped with a scanning lens and mounted retinal projector. It doesn't provide any eye protection, but it's less obtrusive than goggles."
	id = "meson_hud_projector"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT * 4,
	)
	build_path = /obj/item/clothing/glasses/hud/ar/projector/meson
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_ENGINEERING,
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/science_hud_projector
	name = "Science Retinal Projector"
	desc = "A headset equipped with a scanning lens and mounted retinal projector. It doesn't provide any eye protection, but it's less obtrusive than goggles."
	id = "science_hud_projector"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT * 4,
	)
	build_path = /obj/item/clothing/glasses/hud/ar/projector/science
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SCIENCE + RND_SUBCATEGORY_EQUIPMENT_MEDICAL,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_MEDICAL
