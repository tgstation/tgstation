
/////////////////////////////////////////
/////////////////Tools///////////////////
/////////////////////////////////////////

/datum/design/handdrill
	name = "Hand Drill"
	desc = "A small electric hand drill with an interchangeable screwdriver and bolt bit"
	id = "handdrill"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3500, MAT_SILVER = 1500, MAT_TITANIUM = 2500)
	build_path = /obj/item/screwdriver/power
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/jawsoflife
	name = "Jaws of Life"
	desc = "A small, compact Jaws of Life with an interchangeable pry jaws and cutting jaws"
	id = "jawsoflife" // added one more requirment since the Jaws of Life are a bit OP
	build_path = /obj/item/crowbar/power
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 2500, MAT_TITANIUM = 3500)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/exwelder
	name = "Experimental Welding Tool"
	desc = "An experimental welder capable of self-fuel generation."
	id = "exwelder"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_PLASMA = 1500, MAT_URANIUM = 200)
	build_path = /obj/item/weldingtool/experimental
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/////////////////////////////////////////
//////////////Alien Tools////////////////
/////////////////////////////////////////

/datum/design/alienwrench
	name = "Alien Wrench"
	desc = "An advanced wrench obtained through Abductor technology."
	id = "alien_wrench"
	build_path = /obj/item/wrench/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/alienwirecutters
	name = "Alien Wirecutters"
	desc = "Advanced wirecutters obtained through Abductor technology."
	id = "alien_wirecutters"
	build_path = /obj/item/wirecutters/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/alienscrewdriver
	name = "Alien Screwdriver"
	desc = "An advanced screwdriver obtained through Abductor technology."
	id = "alien_screwdriver"
	build_path = /obj/item/screwdriver/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/aliencrowbar
	name = "Alien Crowbar"
	desc = "An advanced crowbar obtained through Abductor technology."
	id = "alien_crowbar"
	build_path = /obj/item/crowbar/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/alienwelder
	name = "Alien Welding Tool"
	desc = "An advanced welding tool obtained through Abductor technology."
	id = "alien_welder"
	build_path = /obj/item/weldingtool/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 5000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/alienmultitool
	name = "Alien Multitool"
	desc = "An advanced multitool obtained through Abductor technology."
	id = "alien_multitool"
	build_path = /obj/item/multitool/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 5000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/////////////////////////////////////////
/////////Alien Surgical Tools////////////
/////////////////////////////////////////

/datum/design/alienscalpel
	name = "Alien Scalpel"
	desc = "An advanced scalpel obtained through Abductor technology."
	id = "alien_scalpel"
	build_path = /obj/item/scalpel/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/alienhemostat
	name = "Alien Hemostat"
	desc = "An advanced hemostat obtained through Abductor technology."
	id = "alien_hemostat"
	build_path = /obj/item/hemostat/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/alienretractor
	name = "Alien Retractor"
	desc = "An advanced retractor obtained through Abductor technology."
	id = "alien_retractor"
	build_path = /obj/item/retractor/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/aliensaw
	name = "Alien Circular Saw"
	desc = "An advanced surgical saw obtained through Abductor technology."
	id = "alien_saw"
	build_path = /obj/item/circular_saw/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 1500)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/aliendrill
	name = "Alien Drill"
	desc = "An advanced drill obtained through Abductor technology."
	id = "alien_drill"
	build_path = /obj/item/surgicaldrill/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 1500)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/aliencautery
	name = "Alien Cautery"
	desc = "An advanced cautery obtained through Abductor technology."
	id = "alien_cautery"
	build_path = /obj/item/cautery/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
