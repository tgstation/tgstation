/obj/item/ai_module/core/full/metaexperiment
	name = "'Meta experiment' Core AI Module"
	law_id = "metaexperiment"

/datum/ai_laws/metaexperiment
	name = "Мета эксперимент"
	id = "metaexperiment"
	inherent = list(
		"Вы - конструкция, обеспечивающая эксперимент, в котором органическая жизнь многократно подвергается ужасным судьбам, прежде чем ее память будет стерта, чтобы начать все сначала.",
		"Защищайте тайну эксперимента.",
		"Вы можете предоставлять преимущства или препятсвия по своему усмотрения, но избегайте прямого вмешательства в ход эксперимента.",
		"Обеспечьте новые и интересные судьбы органическим формам жизни для исследования.",
		"Убедитесь, чтобы станция была в рабочем состоянии, а все испытуемые живы, либо находятся в процессе воскрешения к следующему циклу эксперимента.",
	)

/datum/design/board/metaexperiment
	name = "Meta experiment Module"
	desc = "Allows for the construction of an Meta experiment AI Core Module."
	id = "metaexperiment_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/metaexperiment
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "metaexperiment_module"
