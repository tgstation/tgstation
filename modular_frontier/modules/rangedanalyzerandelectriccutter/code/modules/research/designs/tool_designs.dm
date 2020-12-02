/datum/design/powercutter
	name = "Power Cutter"
	desc = "A smaller, more compact Jaws of Life with an interchangeable pry jaws and cutting head. Sadly, it's smaller form factor relegates it to not forcing open airlocks - but makes it suitable for science personnel."
	id = "powercutter"
	build_path = /obj/item/crowbar/electric
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/titanium = 500)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/rangedanalyzer
	name = "Ranged Analyzer"
	id = "rangedanalyzer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 200)
	build_path = /obj/item/analyzer/ranged
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING
