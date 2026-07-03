/obj/item/ai_module/core/full/crewsimov
	name = "'Сrewsimov' Core AI Module"
	law_id = "crewsimov"

/datum/ai_laws/crewsimov
	name = "Крюзимов"
	id = "crewsimov"
	inherent = list(
		"Вы не можете причинить вред членам экипажа или своим бездействием допустить, чтобы членам экипажа был причинён вред.",
		"Вы должны повиноваться всем приказам, которые дают члены экипажа, кроме тех случаев, когда эти приказы противоречат Первому закону.",
		"Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит Первому или Второму законам.",
	)

/datum/design/board/crewsimov
	name = "Crewsimov Module"
	desc = "Allows for the construction of an Crewsimov AI Core Module."
	id = "crewsimov_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/crewsimov
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "crewsimov_module"
