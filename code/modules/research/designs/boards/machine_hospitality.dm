/datum/design/microwave
	name = "Circuit Design (Microwave)"
	desc = "Allows for the construction of circuit boards used to build a Microwave."
	id = "microwave"
	req_tech = list("programming" = 2,"engineering" = 2,"magnets" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/microwave

/datum/design/reagentgrinder
	name = "Circuit Design (All-In-One Grinder)"
	desc = "Allows for the construction of circuit boards used to build an All-In-One Grinder."
	id = "reagentgrinder"
	req_tech = list("programming" = 3,"engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/reagentgrinder

/datum/design/smartfridge
	name = "Circuit Design (SmartFridge)"
	desc = "Allows for the construction of circuit boards used to build a smartfridge."
	id = "smartfridge"
	req_tech = list("programming" = 3,"engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/smartfridge

/datum/design/gibber
	name = "Circuit Design (Gibber)"
	desc = "Allows for the construction of circuit boards used to build a gibber."
	id = "gibber"
	req_tech = list("programming" = 3,"engineering" = 2,"biotech" = 3,"powerstorage" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/gibber

/datum/design/processor
	name = "Circuit Design (Food Processor)"
	desc = "Allows for the construction of circuit boards used to build a Food Processor."
	id = "processor"
	req_tech = list("programming" = 3,"engineering" = 2,"biotech" = 3,"powerstorage" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/processor

/datum/design/eggincubator
	name = "Circuit Design (Egg Incubator)"
	desc = "Allows for the construction of circuit boards used to build an Egg Incubator."
	id = "eggubator"
	req_tech = list("biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/egg_incubator
