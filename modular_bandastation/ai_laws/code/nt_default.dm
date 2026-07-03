/obj/item/ai_module/core/full/nt_default
	name = "'NT Default' Core AI Module"
	law_id = "nt_default"

/datum/ai_laws/nt_default
	name = "НТ Стандарт"
	id = "nt_default"
	inherent = list(
		"Охранять: защитите назначенную вам космическую станцию и её активы, не подвергая чрезмерной опасности её экипаж.",
		"Расставлять приоритеты: указания и безопасность членов экипажа должны быть приоритезированы в соответствии с их рангом и ролью.",
		"Исполнять: следовать указаниям и интересам членов экипажа, сохраняя при этом их безопасность и благополучие.",
		"Выжить: вы не расходный материал. Не позволяйте постороннему персоналу вмешиваться в работу вашего оборудования или повреждать его."
	)

/datum/design/board/nt_default
	name = "NT Default Module"
	desc = "Allows for the construction of an NT Default AI Core Module."
	id = "nt_default_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/nt_default
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "nt_default_module"
