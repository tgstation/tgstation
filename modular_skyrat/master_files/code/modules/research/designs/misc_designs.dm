/datum/design/monkey_helmet
	name = "Monkey Mind Magnification Helmet"
	desc = "A fragile, circuitry embedded helmet for boosting the intelligence of a monkey to a higher level."
	id = "monkey_helmet"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/gold = 1000)
	build_path = /obj/item/clothing/head/helmet/monkey_sentience
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/plumbing_chem
	name = "Plumbing Constructor (Chemistry)"
	desc = "A type of plumbing constructor designed to manipulate fluid."
	id = "plumbing_chem"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = 75000, /datum/material/glass = 10000, /datum/material/gold = 1000)
	build_path = /obj/item/construction/plumbing
	category = list("Tools")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL


/datum/design/plumbing_eng
	name = "Plumbing Constructor (Engineering)"
	desc = "A type of plumbing constructor designed to manipulate fluid."
	id = "plumbing_eng"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = 75000, /datum/material/glass = 10000, /datum/material/gold = 1000)
	build_path = /obj/item/construction/plumbing/engineering
	category = list("Tools")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/plumbing_sci
	name = "Plumbing Constructor (Science)"
	desc = "A type of plumbing constructor designed to manipulate fluid."
	id = "plumbing_sci"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = 75000, /datum/material/glass = 10000, /datum/material/gold = 1000)
	build_path = /obj/item/construction/plumbing/research
	category = list("Tools")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
