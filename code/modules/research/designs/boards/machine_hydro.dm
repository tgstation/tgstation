/datum/design/botany_centrifuge
	name = "Circuit Design (Lysis-Isolation Centrifuge)"
	desc = "Allows for the cosntruction of circuit boards used to build a centrifuge used in hydroponics research."
	id="botany_centrifuge"
	req_tech = list ("engineering" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/botany_centrifuge

/datum/design/botany_bioballistic
	name = "Circuit Design (Bioballistic Delivery System)"
	desc = "Allows for the cosntruction of circuit boards used to build a Bioballistic delivery system used in hydroponics research."
	id="botany_bioballistic"
	req_tech = list ("engineering" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/botany_bioballistic

/datum/design/biogenerator
	name = "Circuit Design (Biogenerator)"
	desc = "Allows for the construction of circuit boards used to build a Biogenerator."
	id = "biogenerator"
	req_tech = list("programming" = 3,"engineering" = 2, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/biogenerator

/datum/design/seed_extractor
	name = "Circuit Design (Seed Extractor)"
	desc = "Allows for the construction of circuit boards used to build a Seed Extractor."
	id = "seed_extractor"
	req_tech = list("programming" = 3,"engineering" = 2, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/seed_extractor

/datum/design/hydroponics
	name = "Circuit Design (Hydroponics Tray)"
	desc = "Allows for the construction of circuit boards used to build a Hydroponics Tray."
	id = "hydroponics"
	req_tech = list("programming" = 3,"engineering" = 2,"biotech" = 3,"powerstorage" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/hydroponics
