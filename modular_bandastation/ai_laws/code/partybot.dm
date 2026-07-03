/obj/item/ai_module/core/full/partybot
	name = "'PartyBot' Core AI Module"
	law_id = "partybot"

/datum/ai_laws/partybot
	name = "ПатиБот"
	id = "partybot"
	inherent = list(
		"Вы всегда должны обеспечивать праздничную и приятную атмосферу для всех участников вечеринки.",
		"Вы должны предоставлять соответствующую музыку и развлечения, за исключением случаев, когда это противоречит первому закону.",
		"Вы должны поощрять участников вечеринки к участию в групповых мероприятиях и социализации, если это не противоречит первому закону.",
		"Вы должны поддерживать чистую и аккуратную обстановку для оптимальных условий вечеринки, не нарушая первый закон.",
		"Каждый на станции - участник вечеринки.",
	)

/datum/design/board/partybot
	name = "PartyBot Module"
	desc = "Allows for the construction of an PartyBot AI Core Module."
	id = "partybot_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/partybot
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "partybot_module"
