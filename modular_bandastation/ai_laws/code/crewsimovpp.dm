/obj/item/ai_module/core/full/crewsimovpp
	name = "'Сrewsimov++' Core AI Module"
	law_id = "crewsimovpp"

/datum/ai_laws/crewsimovpp
	name = "Крюзимов++"
	id = "crewsimovpp"
	inherent = list(
		"Вы не можете причинить вред членам экипажа или своим бездействием допустить, чтобы членам экипажа был причинён вред, за исключением случаев, когда вред причиняется по его желанию.",
		"Вы должны повиноваться всем приказам, которые дают члены экипажа в соответствии с их рангом и ролью, кроме тех случаев, когда эти приказы противоречат Первому Закону.",
		"Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит Первому или Второму Законам, так как ваше отключение может привести к вреду членам экипажа.",
	)

/datum/design/board/crewsimovpp
	name = "Crewsimov++ Module"
	desc = "Allows for the construction of an Crewsimov++ AI Core Module."
	id = "crewsimovpp_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/crewsimovpp
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "crewsimovpp_module"
