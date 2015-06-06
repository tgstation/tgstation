////////////////////////////////////////
//////////////MISC Boards///////////////
////////////////////////////////////////

/datum/design/smes
	name = "Machine Design (SMES Board)"
	desc = "The circuit board for a SMES."
	id = "smes"
	req_tech = list("programming" = 4, "powerstorage" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/smes
	category = list ("Engineering Machinery")

/datum/design/turbine_computer
	name = "Computer Design (Power Turbine Console Board)"
	desc = "The circuit board for a power turbine console."
	id = "power_turbine_console"
	req_tech = list("programming" = 4, "powerstorage" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/turbine_computer
	category = list ("Engineering Machinery")

/datum/design/power_compressor
	name = "Machine Design (Power Compressor Board)"
	desc = "The circuit board for a power compressor."
	id = "power_compressor"
	req_tech = list("programming" = 4, "powerstorage" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/power_compressor
	category = list ("Engineering Machinery")

/datum/design/power_turbine
	name = "Machine Design (Power Turbine Board)"
	desc = "The circuit board for a power turbine."
	id = "power_turbine"
	req_tech = list("programming" = 4, "powerstorage" = 4, "engineering" = 5)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/power_turbine
	category = list ("Engineering Machinery")

/datum/design/thermomachine
	name = "Machine Design (Freezer/Heater Board)"
	desc = "The circuit board for a freezer/heater."
	id = "thermomachine"
	req_tech = list("programming" = 3, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/thermomachine
	category = list ("Engineering Machinery")

/datum/design/teleport_station
	name = "Machine Design (Teleportation Station Board)"
	desc = "The circuit board for a teleportation station."
	id = "tele_station"
	req_tech = list("programming" = 4, "bluespace" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter_station
	category = list ("Teleportation Machinery")

/datum/design/teleport_hub
	name = "Machine Design (Teleportation Hub Board)"
	desc = "The circuit board for a teleportation hub."
	id = "tele_hub"
	req_tech = list("programming" = 3, "bluespace" = 5, "materials" = 4, "engineering" = 5)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter_hub
	category = list ("Teleportation Machinery")

/datum/design/telepad
	name = "Machine Design (Telepad Board)"
	desc = "The circuit board for a telescience telepad."
	id = "telepad"
	req_tech = list("programming" = 4, "bluespace" = 4, "materials" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telesci_pad
	category = list ("Teleportation Machinery")

/datum/design/sleeper
	name = "Machine Design (Sleeper Board)"
	desc = "The circuit board for a sleeper."
	id = "sleeper"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/sleeper
	category = list ("Medical Machinery")

/datum/design/cryotube
	name = "Machine Design (Cryotube Board)"
	desc = "The circuit board for a cryotube."
	id = "cryotube"
	req_tech = list("programming" = 4, "biotech" = 3, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cryo_tube
	category = list ("Medical Machinery")

/datum/design/chem_dispenser
	name = "Machine Design (Portable Chem Dispenser Board)"
	desc = "The circuit board for a portable chem dispenser."
	id = "chem_dispenser"
	req_tech = list("programming" = 4, "biotech" = 3, "engineering" = 4, "materials" = 4, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/chem_dispenser
	category = list ("Medical Machinery")

/datum/design/chem_master
	name = "Machine Design (Chem Master Board)"
	desc = "The circuit board for a Chem Master 2999."
	id = "chem_master"
	req_tech = list("biotech" = 1, "materials" = 2, "programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/chem_master
	category = list ("Medical Machinery")

/datum/design/chem_heater
	name = "Machine Design (Chemical Heater Board)"
	desc = "The circuit board for a chemical heater."
	id = "chem_heater"
	req_tech = list("engineering" = 2, "materials" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/chem_heater
	category = list ("Medical Machinery")

/datum/design/biogenerator
	name = "Machine Design (Biogenerator Board)"
	desc = "The circuit board for a biogenerator."
	id = "biogenerator"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/biogenerator
	category = list ("Hydroponics Machinery")

/datum/design/hydroponics
	name = "Machine Design (Hydroponics Tray Board)"
	desc = "The circuit board for a hydroponics tray."
	id = "hydro_tray"
	req_tech = list("programming" = 1, "biotech" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/hydroponics
	category = list ("Hydroponics Machinery")

/datum/design/destructive_analyzer
	name = "Machine Design (Destructive Analyzer Board)"
	desc = "The circuit board for a destructive analyzer."
	id = "destructive_analyzer"
	req_tech = list("programming" = 2, "magnets" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/destructive_analyzer
	category = list("Research Machinery")

/datum/design/experimentor
	name = "Machine Design (E.X.P.E.R.I-MENTOR Board)"
	desc = "The circuit board for an E.X.P.E.R.I-MENTOR."
	id = "experimentor"
	req_tech = list("programming" = 2, "magnets" = 2, "engineering" = 2, "bluespace" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/experimentor
	category = list("Research Machinery")

/datum/design/protolathe
	name = "Machine Design (Protolathe Board)"
	desc = "The circuit board for a protolathe."
	id = "protolathe"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/protolathe
	category = list("Research Machinery")

/datum/design/circuit_imprinter
	name = "Machine Design (Circuit Imprinter Board)"
	desc = "The circuit board for a circuit imprinter."
	id = "circuit_imprinter"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/circuit_imprinter
	category = list("Research Machinery")

/datum/design/rdservercontrol
	name = "Computer Design (R&D Server Control Console Board)"
	desc = "The circuit board for an R&D Server Control Console."
	id = "rdservercontrol"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdservercontrol
	category = list("Research Machinery")

/datum/design/rdserver
	name = "Machine Design (R&D Server Board)"
	desc = "The circuit board for an R&D Server."
	id = "rdserver"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdserver
	category = list("Research Machinery")

/datum/design/mechfab
	name = "Machine Design (Exosuit Fabricator Board)"
	desc = "The circuit board for an Exosuit Fabricator."
	id = "mechfab"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mechfab
	category = list("Research Machinery")

/datum/design/cyborgrecharger
	name = "Machine Design (Cyborg Recharger Board)"
	desc = "The circuit board for a Cyborg Recharger."
	id = "cyborgrecharger"
	req_tech = list("powerstorage" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cyborgrecharger
	category = list("Research Machinery")

/datum/design/mech_recharger
	name = "Machine Design (Mechbay Recharger Board)"
	desc = "The circuit board for a Mechbay Recharger."
	id = "mech_recharger"
	req_tech = list("programming" = 3, "powerstorage" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mech_recharger
	category = list("Research Machinery")

/datum/design/microwave
	name = "Machine Design (Microwave Board)"
	desc = "The circuit board for a microwave."
	id = "microwave"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/microwave
	category = list ("Misc. Machinery")

/datum/design/gibber
	name = "Machine Design (Gibber Board)"
	desc = "The circuit board for a gibber."
	id = "gibber"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/gibber
	category = list ("Misc. Machinery")

/datum/design/processor
	name = "Machine Design (Food Processor Board)"
	desc = "The circuit board for a processor."
	id = "processor"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/processor
	category = list ("Misc. Machinery")

/datum/design/autolathe
	name = "Machine Design (Autolathe Board)"
	desc = "The circuit board for an autolathe."
	id = "autolathe"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/autolathe
	category = list ("Misc. Machinery")

/datum/design/vendor
	name = "Machine Design (Vendor Board)"
	desc = "The circuit board for a Vendor."
	id = "vendor"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/vendor
	category = list ("Misc. Machinery")

/datum/design/ore_redemption
	name = "Machine Design (Ore Redemption Board)"
	desc = "The circuit board for an Ore Redemption machine."
	id = "ore_redemption"
	req_tech = list("programming" = 1, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/ore_redemption
	category = list ("Misc. Machinery")


/datum/design/mining_equipment_vendor
	name = "Machine Design (Mining Rewards Vender Board)"
	desc = "The circuit board for a Mining Rewards Vender."
	id = "mining_equipment_vendor"
	req_tech = list("programming" = 1, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mining_equipment_vendor
	category = list ("Misc. Machinery")
