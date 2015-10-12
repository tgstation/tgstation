/datum/design/destructive_analyzer
	name = "Circuit Design(Destructive Analyzer)"
	desc = "The circuit board for a destructive analyzer."
	id = "destructive_analyzer"
	req_tech = list("programming" = 2, "magnets" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/destructive_analyzer

/datum/design/protolathe
	name = "Circuit Design(Protolathe)"
	desc = "The circuit board for a protolathe."
	id = "protolathe"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/protolathe

/datum/design/circuit_imprinter
	name = "Circuit Design(Circuit Imprinter)"
	desc = "The circuit board for a circuit imprinter."
	id = "circuit_imprinter"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/circuit_imprinter

/datum/design/autolathe
	name = "Circuit Design(Autolathe)"
	desc = "The circuit board for a autolathe."
	id = "autolathe"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/autolathe

/datum/design/rdserver
	name = "Circuit Design(R&D Server)"
	desc = "The circuit board for an R&D Server"
	id = "rdserver"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/rdserver

/datum/design/mechfab
	name = "Circuit Design(Exosuit Fabricator)"
	desc = "The circuit board for an Exosuit Fabricator"
	id = "mechfab"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/mechfab

/datum/design/monkey_recycler
	name = "Circuit Design (Monkey Recycler)"
	desc = "Allows for the construction of circuit boards used to build a Monkey Recycler."
	id = "monkey"
	req_tech = list("programming" = 3,"engineering" = 2,"biotech" = 3,"powerstorage" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/monkey_recycler

/datum/design/mechapowerport
	name = "Circuit Design (Mech Bay Power Port)"
	desc = "Allows for the construction of circuit boards used to build a mech bay power connector port."
	id = "mechapowerport"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/mech_bay_power_port

/datum/design/mechapowerfloor
	name = "Circuit Design (Recharge Station)"
	desc = "Allows for the construction of circuit boards used to build a mech bay recharge station."
	id = "mechapowerfloor"
	req_tech = list("materials" = 2, "powerstorage" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/mech_bay_recharge_station

/datum/design/anom
	name = "Circuit Design (Fourier Transform Spectroscope)"
	desc = "Allows for the construction of circuit boards used in Xenoarcheology."
	id = "fourier"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/anom

/datum/design/anom/accelerator
	name = "Circuit Design (Accelerator Spectrometer)"
	id = "accelerator"
	build_path = /obj/item/weapon/circuitboard/anom/accelerator

/datum/design/anom/accelerator
	name = "Circuit Design (Gas Chromatography Spectrometer)"
	id = "gaschromatography"
	build_path = /obj/item/weapon/circuitboard/anom/gas

/datum/design/anom/accelerator
	name = "Circuit Design (Hyperspectral Imager)"
	id = "hyperspectral"
	build_path = /obj/item/weapon/circuitboard/anom/hyper

/datum/design/anom/accelerator
	name = "Circuit Design (Ion Mobility Spectrometer)"
	id = "ionmobility"
	build_path = /obj/item/weapon/circuitboard/anom/ion

/datum/design/anom/accelerator
	name = "Circuit Design (Isotope Ratio Spectrometer)"
	id = "isotoperatio"
	build_path = /obj/item/weapon/circuitboard/anom/iso
