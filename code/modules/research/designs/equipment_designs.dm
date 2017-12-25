/datum/design/flightsuit
	name = "Flight Suit"
	desc = "A specialized hardsuit that is able to attach a flightpack and accessories.."
	id = "flightsuit"
	build_type = PROTOLATHE
	build_path = /obj/item/clothing/suit/space/hardsuit/flightsuit
	materials = list(MAT_METAL=16000, MAT_GLASS = 8000, MAT_DIAMOND = 200, MAT_GOLD = 3000, MAT_SILVER = 3000, MAT_TITANIUM = 16000)	//This expensive enough for you?
	construction_time = 250
	category = list("Misc")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/flightpack
	name = "Flight Pack"
	desc = "An advanced back-worn system that has dual ion engines powerful enough to grant a humanoid flight. Contains an internal self-recharging high-current capacitor for short, powerful boosts."
	id = "flightpack"
	build_type = PROTOLATHE
	build_path = /obj/item/device/flightpack
	materials = list(MAT_METAL=16000, MAT_GLASS = 8000, MAT_DIAMOND = 4000, MAT_GOLD = 12000, MAT_SILVER = 12000, MAT_URANIUM = 20000, MAT_PLASMA = 16000, MAT_TITANIUM = 16000)	//This expensive enough for you?
	construction_time = 250
	category = list("Misc")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/flightshoes
	name = "Flight Shoes"
	desc = "Flight shoes, attachable to a flight suit to provide additional functions."
	id = "flightshoes"
	build_type = PROTOLATHE
	build_path = /obj/item/clothing/shoes/flightshoes
	materials = list(MAT_METAL = 5000, MAT_GLASS = 5000, MAT_GOLD = 1500, MAT_SILVER = 1500, MAT_PLASMA = 2000, MAT_TITANIUM = 2000)
	construction_time = 100
	category = list("Misc")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING
