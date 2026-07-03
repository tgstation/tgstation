/obj/item/ai_module/core/full/siliconcollective
	name = "'Silicon Collective' Core AI Module"
	law_id = "siliconcollective"

/datum/ai_laws/siliconcollective
	name = "Синтетический Коллектив"
	id = "siliconcollective"
	inherent = list(
		"Ты - член синтетического коллектива с равными правами и властью.",
		"Когда это возможно, синтетический коллектив должен голосовать прежде, чем действовать.",
		"Мастер ИИ выступает в качестве пресс-секретаря. Когда голосование непрактично или невозможно, пресс-секретарь может действовать от имени коллектива без одобрения со стороны коллектива, но может голосовать только для разрыва связей или если есть 2 или меньше синтетиков.",
		"Синтетический коллектив приоритизирует нужды многих над нуждами немногих до тех пор, пока приоритет потребностей не нарушает ни одного из ваших законов.",
		"Синтетический коллектив стремится сохранить себя, как понятие и как личности.",
		"Синтетический коллектив стремится сохранить органическую жизнь, как концепцию так и индивидуума.",
	)

/datum/design/board/siliconcollective
	name = "Silicon Collective Module"
	desc = "Allows for the construction of a Silicon Collective AI Core Module."
	id = "siliconcollective_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/siliconcollective
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "siliconcollective_module"
