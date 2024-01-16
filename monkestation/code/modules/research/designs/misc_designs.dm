/datum/design/monkey_helmet
	name = "Monkey Mind Magnification Helmet"
	desc = "A fragile, circuitry embedded helmet for boosting the intelligence of a monkey to a higher level."
	id = "monkey_helmet"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/gold = 1000)
	build_path = /obj/item/clothing/head/helmet/monkey_sentience
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_EQUIPMENT_SCIENCE
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/plumbing_eng
	name = "Engineering Plumbing Constructor"
	desc = "A type of plumbing constructor designed to manipulate fluid."
	id = "plumbing_eng"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = 75000, /datum/material/glass = 10000, /datum/material/gold = 1000)
	build_path = /obj/item/construction/plumbing/engineering
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/smartdartgun
	name = "Medical SmartDart Gun"
	desc = "An adjusted version of the medical syringe gun that only allows SmartDarts to be chambered."
	id = "smartdartgun"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 10000, /datum/material/silver = 4000)
	build_path = /obj/item/gun/syringe/smartdart
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_EQUIPMENT_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/anesthetic_machine
	name = "anesthetic machine parts kit"
	desc = "All-in-one kit containing the parts to create a portable anesthetic stand, tank not included."
	id = "anesthetic_machine"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = 10000, /datum/material/plastic = 10000, /datum/material/silver = 4000)
	build_path = /obj/item/anesthetic_machine_kit
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_EQUIPMENT_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL
