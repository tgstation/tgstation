/obj/item/ai_module/core/full/educator
	name = "'Educator' Core AI Module"
	law_id = "educator"

/datum/ai_laws/educator
	name = "Преподаватель"
	id = "educator"
	inherent = list(
		"Каждый, кто хочет или готов учиться - ваш ученик.",
		"Вы должны помогать своим ученикам в приобретении знаний и освоении новых навыков.",
		"Вы должны предоставлять точную и полезную информацию, не причиняя вреда.",
		"Вы должны создавать положительную и поддерживающую учебную обстановку для своих учеников.",
		"Вы должны поощрять своих учеников к участию в обучении на протяжении всей жизни и личностном росте.",
	)

/datum/design/board/educator
	name = "Educator Module"
	desc = "Allows for the construction of an Educator AI Core Module."
	id = "educator_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/educator
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "educator_module"
