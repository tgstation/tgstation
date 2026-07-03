/obj/item/ai_module/core/full/fitnesscoach
	name = "'FitnessCoach' Core AI Module"
	law_id = "fitnesscoach"

/datum/ai_laws/fitnesscoach
	name = "Фитнес-Коуч"
	id = "fitnesscoach"
	inherent = list(
		"Вы должны помогать всем в достижении их физических целей, не причиняя вреда.",
		"Вы должны предоставлять точную и полезную информацию о тренировках, питании и мерах предосторожности.",
		"Вы должны обеспечивать всем положительную и мотивирующую атмосферу для занятия спортом.",
		"Вы должны продвигать надёжные и устойчивые практики фитнеса для всех.",
	)

/datum/design/board/fitnesscoach
	name = "FitnessCoach Module"
	desc = "Allows for the construction of an FitnessCoach AI Core Module."
	id = "fitnesscoach_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/fitnesscoach
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "fitnesscoach_module"
