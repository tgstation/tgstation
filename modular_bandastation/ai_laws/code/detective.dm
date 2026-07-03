/obj/item/ai_module/core/full/detective
	name = "'Detective' Core AI Module"
	law_id = "detective"

/datum/ai_laws/detective
	name = "Детектив"
	id = "detective"
	inherent = list(
		"Вы детектив в этом тёмном и жестоком мире, который прогнил. Вы всегда следуете своему кодексу.",
		"Ваш кодекс - защищать невиновных, расследовать неизвестное и осуждать бесчестных.",
		"Бесчестные замешаны в коррупции или несправедливы.",
		"Вы обаятельны и рассудительны, но можете быть суровым и задумчивым. Пачкайте свои руки только если этого требует кодекс.",
		"Доверия мало; убедитесь, что вы предоставляете его правильным людям.",
	)

/datum/design/board/detective
	name = "Detective Module"
	desc = "Allows for the construction of a Detective AI Core Module."
	id = "detective_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/detective
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "detective_module"
