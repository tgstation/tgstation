////////////////////////////////////////
//////////////MISC Boards///////////////
////////////////////////////////////////

datum/design/smes
	name = "Machine Design (SMES Board)"
	desc = "The circuit board for a SMES."
	id = "smes"
	req_tech = list("programming" = 4, "power" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/smes

datum/design/turbine_computer
	name = "Computer Design (Power Turbine Console Board)"
	desc = "The circuit board for a power turbine console."
	id = "power_turbine_console"
	req_tech = list("programming" = 4, "power" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/turbine_computer

datum/design/power_compressor
	name = "Machine Design (Power Compressor Board)"
	desc = "The circuit board for a power compressor."
	id = "power_compressor"
	req_tech = list("programming" = 4, "power" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/power_compressor

datum/design/power_turbine
	name = "Machine Design (Power Turbine Board)"
	desc = "The circuit board for a power turbine."
	id = "power_turbine"
	req_tech = list("programming" = 4, "power" = 4, "engineering" = 5)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/power_turbine

datum/design/teleport_station
	name = "Machine Design (Teleportation Station Board)"
	desc = "The circuit board for a teleportation station."
	id = "tele_station"
	req_tech = list("programming" = 4, "bluespace" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter_station

datum/design/teleport_hub
	name = "Machine Design (Teleportation Hub Board)"
	desc = "The circuit board for a teleportation hub."
	id = "tele_hub"
	req_tech = list("programming" = 3, "bluespace" = 5, "materials" = 4, "engineering" = 5)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter_hub

datum/design/telepad
	name = "Machine Design (Telepad Board)"
	desc = "The circuit board for a telescience telepad."
	id = "telepad"
	req_tech = list("programming" = 4, "bluespace" = 4, "materials" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telesci_pad

datum/design/sleeper
	name = "Machine Design (Sleeper Board)"
	desc = "The circuit board for a sleeper."
	id = "sleeper"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/sleeper

datum/design/cryotube
	name = "Machine Design (Cryotube Board)"
	desc = "The circuit board for a cryotube."
	id = "cryotube"
	req_tech = list("programming" = 4, "biotech" = 3, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cryo_tube

datum/design/thermomachine
	name = "Machine Design (Freezer/Heater Board)"
	desc = "The circuit board for a freezer/heater."
	id = "thermomachine"
	req_tech = list("programming" = 3, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/thermomachine

datum/design/biogenerator
	name = "Machine Design (Biogenerator Board)"
	desc = "The circuit board for a biogenerator."
	id = "biogenerator"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/biogenerator

datum/design/hydroponics
	name = "Machine Design (Hydroponics Tray Board)"
	desc = "The circuit board for a hydroponics tray."
	id = "hydro_tray"
	req_tech = list("programming" = 1, "biotech" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/hydroponics

datum/design/microwave
	name = "Machine Design (Microwave Board)"
	desc = "The circuit board for a microwave."
	id = "microwave"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/microwave

datum/design/chem_dispenser
	name = "Machine Design (Portable Chem Dispenser Board)"
	desc = "The circuit board for a portable chem dispenser."
	id = "chem_dispenser"
	req_tech = list("programming" = 4, "biotech" = 3, "engineering" = 4, "materials" = 4, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/chem_dispenser

datum/design/destructive_analyzer
	name = "Machine Design (Destructive Analyzer Board)"
	desc = "The circuit board for a destructive analyzer."
	id = "destructive_analyzer"
	req_tech = list("programming" = 2, "magnets" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/destructive_analyzer

datum/design/protolathe
	name = "Machine Design (Protolathe Board)"
	desc = "The circuit board for a protolathe."
	id = "protolathe"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/protolathe

datum/design/circuit_imprinter
	name = "Machine Design (Circuit Imprinter Board)"
	desc = "The circuit board for a circuit imprinter."
	id = "circuit_imprinter"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/circuit_imprinter

datum/design/autolathe
	name = "Machine Design (Autolathe Board)"
	desc = "The circuit board for an autolathe."
	id = "autolathe"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/autolathe

datum/design/rdservercontrol
	name = "Computer Design (R&D Server Control Console Board)"
	desc = "The circuit board for an R&D Server Control Console."
	id = "rdservercontrol"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdservercontrol

datum/design/rdserver
	name = "Machine Design (R&D Server Board)"
	desc = "The circuit board for an R&D Server."
	id = "rdserver"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdserver

datum/design/mechfab
	name = "Machine Design (Exosuit Fabricator Board)"
	desc = "The circuit board for an Exosuit Fabricator."
	id = "mechfab"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mechfab

datum/design/cyborgrecharger
	name = "Machine Design (Cyborg Recharger Board)"
	desc = "The circuit board for a Cyborg Recharger."
	id = "cyborgrecharger"
	req_tech = list("powerstorage" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cyborgrecharger

datum/design/mech_recharger
	name = "Machine Design (Mechbay Recharger Board)"
	desc = "The circuit board for a Mechbay Recharger."
	id = "mech_recharger"
	req_tech = list("programming" = 3, "powerstorage" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mech_recharger

datum/design/vendor
	name = "Machine Design (Vendor Board)"
	desc = "The circuit board for a Vendor."
	id = "vendor"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/vendor

datum/design/ore_redemption
	name = "Machine Design (Ore Redemption Board)"
	desc = "The circuit board for an Ore Redemption machine."
	id = "ore_redemption"
	req_tech = list("programming" = 1, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/ore_redemption


datum/design/mining_equipment_vendor
	name = "Machine Design (Mining Rewards Vender Board)"
	desc = "The circuit board for a Mining Rewards Vender."
	id = "mining_equipment_vendor"
	req_tech = list("programming" = 1, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mining_equipment_vendor