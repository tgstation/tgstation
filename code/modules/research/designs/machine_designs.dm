////////////////////////////////////////
//////////////MISC Boards///////////////
////////////////////////////////////////

/datum/design/board/smes
	name = "Machine Design (SMES Board)"
	desc = "The circuit board for a SMES."
	id = "smes"
	req_tech = list("programming" = 4, "powerstorage" = 5, "engineering" = 4)
	build_path = /obj/item/circuitboard/machine/smes
	category = list ("Engineering Machinery")

/datum/design/board/announcement_system
	name = "Machine Design (Automated Announcement System Board)"
	desc = "The circuit board for an automated announcement system."
	id = "automated_announcement"
	req_tech = list("programming" = 3, "bluespace" = 3, "magnets" = 2)
	build_path = /obj/item/circuitboard/machine/announcement_system
	category = list("Subspace Telecomms")

/datum/design/board/turbine_computer
	name = "Computer Design (Power Turbine Console Board)"
	desc = "The circuit board for a power turbine console."
	id = "power_turbine_console"
	req_tech = list("programming" = 4, "powerstorage" = 5, "engineering" = 4)
	build_path = /obj/item/circuitboard/computer/turbine_computer
	category = list ("Engineering Machinery")

/datum/design/board/emitter
	name = "Machine Design (Emitter Board)"
	desc = "The circuit board for an emitter."
	id = "emitter"
	req_tech = list("programming" = 3, "powerstorage" = 5, "engineering" = 4)
	build_path = /obj/item/circuitboard/machine/emitter
	category = list ("Engineering Machinery")

/datum/design/board/power_compressor
	name = "Machine Design (Power Compressor Board)"
	desc = "The circuit board for a power compressor."
	id = "power_compressor"
	req_tech = list("programming" = 4, "powerstorage" = 5, "engineering" = 4)
	build_path = /obj/item/circuitboard/machine/power_compressor
	category = list ("Engineering Machinery")

/datum/design/board/power_turbine
	name = "Machine Design (Power Turbine Board)"
	desc = "The circuit board for a power turbine."
	id = "power_turbine"
	req_tech = list("programming" = 4, "powerstorage" = 4, "engineering" = 5)
	build_path = /obj/item/circuitboard/machine/power_turbine
	category = list ("Engineering Machinery")

/datum/design/board/thermomachine
	name = "Machine Design (Freezer/Heater Board)"
	desc = "The circuit board for a freezer/heater."
	id = "thermomachine"
	req_tech = list("programming" = 3, "plasmatech" = 3)
	build_path = /obj/item/circuitboard/machine/thermomachine
	category = list ("Engineering Machinery")

/datum/design/board/space_heater
	name = "Machine Design (Space Heater Board)"
	desc = "The circuit board for a space heater."
	id = "space_heater"
	req_tech = list("programming" = 2, "engineering" = 2, "plasmatech" = 2)
	build_path = /obj/item/circuitboard/machine/space_heater
	category = list ("Engineering Machinery")

/datum/design/board/teleport_station
	name = "Machine Design (Teleportation Station Board)"
	desc = "The circuit board for a teleportation station."
	id = "tele_station"
	req_tech = list("programming" = 5, "bluespace" = 4, "engineering" = 4, "plasmatech" = 4)
	build_path = /obj/item/circuitboard/machine/teleporter_station
	category = list ("Teleportation Machinery")

/datum/design/board/teleport_hub
	name = "Machine Design (Teleportation Hub Board)"
	desc = "The circuit board for a teleportation hub."
	id = "tele_hub"
	req_tech = list("programming" = 3, "bluespace" = 5, "materials" = 4, "engineering" = 5)
	build_path = /obj/item/circuitboard/machine/teleporter_hub
	category = list ("Teleportation Machinery")

/datum/design/board/quantumpad
	name = "Machine Design (Quantum Pad Board)"
	desc = "The circuit board for a quantum telepad."
	id = "quantumpad"
	req_tech = list("programming" = 4, "bluespace" = 4, "plasmatech" = 3, "engineering" = 4)
	build_path = /obj/item/circuitboard/machine/quantumpad
	category = list ("Teleportation Machinery")

/datum/design/board/launchpad
	name = "Machine Design (Bluespace Launchpad Board)"
	desc = "The circuit board for a bluespace Launchpad."
	id = "launchpad"
	req_tech = list("programming" = 3, "bluespace" = 3, "plasmatech" = 2, "engineering" = 3)
	build_path = /obj/item/circuitboard/machine/launchpad
	category = list ("Teleportation Machinery")

/datum/design/board/launchpad_console
	name = "Machine Design (Bluespace Launchpad Console Board)"
	desc = "The circuit board for a bluespace launchpad Console."
	id = "launchpad_console"
	req_tech = list("programming" = 4, "bluespace" = 3, "plasmatech" = 3)
	build_path = /obj/item/circuitboard/computer/launchpad_console
	category = list ("Teleportation Machinery")

/datum/design/board/teleconsole
	name = "Computer Design (Teleporter Console)"
	desc = "Allows for the construction of circuit boards used to build a teleporter control console."
	id = "teleconsole"
	req_tech = list("programming" = 3, "bluespace" = 3, "plasmatech" = 4)
	build_path = /obj/item/circuitboard/computer/teleporter
	category = list("Teleportation Machinery")

/datum/design/board/sleeper
	name = "Machine Design (Sleeper Board)"
	desc = "The circuit board for a sleeper."
	id = "sleeper"
	req_tech = list("programming" = 3, "biotech" = 2, "engineering" = 3)
	build_path = /obj/item/circuitboard/machine/sleeper
	category = list ("Medical Machinery")

/datum/design/board/cryotube
	name = "Machine Design (Cryotube Board)"
	desc = "The circuit board for a cryotube."
	id = "cryotube"
	req_tech = list("programming" = 5, "biotech" = 3, "engineering" = 4, "plasmatech" = 3)
	build_path = /obj/item/circuitboard/machine/cryo_tube
	category = list ("Medical Machinery")

/datum/design/board/chem_dispenser
	name = "Machine Design (Portable Chem Dispenser Board)"
	desc = "The circuit board for a portable chem dispenser."
	id = "chem_dispenser"
	req_tech = list("programming" = 5, "biotech" = 3, "materials" = 4, "plasmatech" = 4)
	build_path = /obj/item/circuitboard/machine/chem_dispenser
	category = list ("Medical Machinery")

/datum/design/board/chem_master
	name = "Machine Design (Chem Master Board)"
	desc = "The circuit board for a Chem Master 3000."
	id = "chem_master"
	req_tech = list("biotech" = 3, "materials" = 3, "programming" = 2)
	build_path = /obj/item/circuitboard/machine/chem_master
	category = list ("Medical Machinery")

/datum/design/board/chem_heater
	name = "Machine Design (Chemical Heater Board)"
	desc = "The circuit board for a chemical heater."
	id = "chem_heater"
	req_tech = list("engineering" = 2, "biotech" = 2, "programming" = 2)
	build_path = /obj/item/circuitboard/machine/chem_heater
	category = list ("Medical Machinery")

/datum/design/board/clonecontrol
	name = "Computer Design (Cloning Machine Console)"
	desc = "Allows for the construction of circuit boards used to build a new Cloning Machine console."
	id = "clonecontrol"
	req_tech = list("programming" = 4, "biotech" = 3)
	build_path = /obj/item/circuitboard/computer/cloning
	category = list("Medical Machinery")

/datum/design/board/clonepod
	name = "Machine Design (Clone Pod)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Pod."
	id = "clonepod"
	req_tech = list("programming" = 4, "biotech" = 3)
	build_path = /obj/item/circuitboard/machine/clonepod
	category = list("Medical Machinery")

/datum/design/board/clonescanner
	name = "Machine Design (Cloning Scanner)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Scanner."
	id = "clonescanner"
	req_tech = list("programming" = 4, "biotech" = 3)
	build_path = /obj/item/circuitboard/machine/clonescanner
	category = list("Medical Machinery")

/datum/design/board/biogenerator
	name = "Machine Design (Biogenerator Board)"
	desc = "The circuit board for a biogenerator."
	id = "biogenerator"
	req_tech = list("programming" = 2, "biotech" = 3, "materials" = 3)
	build_path = /obj/item/circuitboard/machine/biogenerator
	category = list ("Hydroponics Machinery")

/datum/design/board/hydroponics
	name = "Machine Design (Hydroponics Tray Board)"
	desc = "The circuit board for a hydroponics tray."
	id = "hydro_tray"
	req_tech = list("biotech" = 2)
	build_path = /obj/item/circuitboard/machine/hydroponics
	category = list ("Hydroponics Machinery")

/datum/design/board/destructive_analyzer
	name = "Machine Design (Destructive Analyzer Board)"
	desc = "The circuit board for a destructive analyzer."
	id = "destructive_analyzer"
	req_tech = list("programming" = 2, "magnets" = 2, "engineering" = 2)
	build_path = /obj/item/circuitboard/machine/destructive_analyzer
	category = list("Research Machinery")

/datum/design/board/experimentor
	name = "Machine Design (E.X.P.E.R.I-MENTOR Board)"
	desc = "The circuit board for an E.X.P.E.R.I-MENTOR."
	id = "experimentor"
	req_tech = list("programming" = 2, "magnets" = 2, "engineering" = 2, "bluespace" = 2)
	build_path = /obj/item/circuitboard/machine/experimentor
	category = list("Research Machinery")

/datum/design/board/protolathe
	name = "Machine Design (Protolathe Board)"
	desc = "The circuit board for a protolathe."
	id = "protolathe"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_path = /obj/item/circuitboard/machine/protolathe
	category = list("Research Machinery")

/datum/design/board/circuit_imprinter
	name = "Machine Design (Circuit Imprinter Board)"
	desc = "The circuit board for a circuit imprinter."
	id = "circuit_imprinter"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_path = /obj/item/circuitboard/machine/circuit_imprinter
	category = list("Research Machinery")

/datum/design/board/rdservercontrol
	name = "Computer Design (R&D Server Control Console Board)"
	desc = "The circuit board for an R&D Server Control Console."
	id = "rdservercontrol"
	req_tech = list("programming" = 3)
	build_path = /obj/item/circuitboard/computer/rdservercontrol
	category = list("Research Machinery")

/datum/design/board/rdserver
	name = "Machine Design (R&D Server Board)"
	desc = "The circuit board for an R&D Server."
	id = "rdserver"
	req_tech = list("programming" = 3)
	build_path = /obj/item/circuitboard/machine/rdserver
	category = list("Research Machinery")

/datum/design/board/mechfab
	name = "Machine Design (Exosuit Fabricator Board)"
	desc = "The circuit board for an Exosuit Fabricator."
	id = "mechfab"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_path = /obj/item/circuitboard/machine/mechfab
	category = list("Research Machinery")

/datum/design/board/cyborgrecharger
	name = "Machine Design (Cyborg Recharger Board)"
	desc = "The circuit board for a Cyborg Recharger."
	id = "cyborgrecharger"
	req_tech = list("powerstorage" = 3, "engineering" = 3)
	build_path = /obj/item/circuitboard/machine/cyborgrecharger
	category = list("Research Machinery")

/datum/design/board/mech_recharger
	name = "Machine Design (Mechbay Recharger Board)"
	desc = "The circuit board for a Mechbay Recharger."
	id = "mech_recharger"
	req_tech = list("programming" = 3, "powerstorage" = 4, "engineering" = 3)
	build_path = /obj/item/circuitboard/machine/mech_recharger
	category = list("Research Machinery")

/datum/design/board/microwave
	name = "Machine Design (Microwave Board)"
	desc = "The circuit board for a microwave."
	id = "microwave"
	req_tech = list("programming" = 2, "magnets" = 2)
	build_path = /obj/item/circuitboard/machine/microwave
	category = list ("Misc. Machinery")

/datum/design/board/gibber
	name = "Machine Design (Gibber Board)"
	desc = "The circuit board for a gibber."
	id = "gibber"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_path = /obj/item/circuitboard/machine/gibber
	category = list ("Misc. Machinery")

/datum/design/board/smartfridge
	name = "Machine Design (Smartfridge Board)"
	desc = "The circuit board for a smartfridge."
	id = "smartfridge"
	req_tech = list("programming" = 1)
	build_path = /obj/item/circuitboard/machine/smartfridge
	category = list ("Misc. Machinery")

/datum/design/board/monkey_recycler
	name = "Machine Design (Monkey Recycler Board)"
	desc = "The circuit board for a monkey recycler."
	id = "monkey_recycler"
	req_tech = list("programming" = 1)
	build_path = /obj/item/circuitboard/machine/monkey_recycler
	category = list ("Misc. Machinery")

/datum/design/board/seed_extractor
	name = "Machine Design (Seed Extractor Board)"
	desc = "The circuit board for a seed extractor."
	id = "seed_extractor"
	req_tech = list("programming" = 1)
	build_path = /obj/item/circuitboard/machine/seed_extractor
	category = list ("Misc. Machinery")

/datum/design/board/processor
	name = "Machine Design (Processor Board)"
	desc = "The circuit board for a processor."
	id = "processor"
	req_tech = list("programming" = 1)
	build_path = /obj/item/circuitboard/machine/processor
	category = list ("Misc. Machinery")

/datum/design/board/recycler
	name = "Machine Design (Recycler Board)"
	desc = "The circuit board for a recycler."
	id = "recycler"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_path = /obj/item/circuitboard/machine/recycler
	category = list ("Misc. Machinery")

/datum/design/board/holopad
	name = "Machine Design (AI Holopad Board)"
	desc = "The circuit board for a holopad."
	id = "holopad"
	req_tech = list("programming" = 1)
	build_path = /obj/item/circuitboard/machine/holopad
	category = list ("Misc. Machinery")

/datum/design/board/autolathe
	name = "Machine Design (Autolathe Board)"
	desc = "The circuit board for an autolathe."
	id = "autolathe"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_path = /obj/item/circuitboard/machine/autolathe
	category = list ("Misc. Machinery")

/datum/design/board/recharger
	name = "Machine Design (Weapon Recharger Board)"
	desc = "The circuit board for a Weapon Recharger."
	id = "recharger"
	req_tech = list("powerstorage" = 4, "engineering" = 3, "materials" = 4)
	materials = list(MAT_GLASS = 1000, MAT_GOLD = 100)
	build_path = /obj/item/circuitboard/machine/recharger
	category = list("Misc. Machinery")

/datum/design/board/vendor
	name = "Machine Design (Vendor Board)"
	desc = "The circuit board for a Vendor."
	id = "vendor"
	req_tech = list("programming" = 1)
	build_path = /obj/item/circuitboard/machine/vendor
	category = list ("Misc. Machinery")

/datum/design/board/ore_redemption
	name = "Machine Design (Ore Redemption Board)"
	desc = "The circuit board for an Ore Redemption machine."
	id = "ore_redemption"
	req_tech = list("programming" = 2, "engineering" = 2, "plasmatech" = 3)
	build_path = /obj/item/circuitboard/machine/ore_redemption
	category = list ("Misc. Machinery")

/datum/design/board/mining_equipment_vendor
	name = "Machine Design (Mining Rewards Vender Board)"
	desc = "The circuit board for a Mining Rewards Vender."
	id = "mining_equipment_vendor"
	req_tech = list("engineering" = 3)
	build_path = /obj/item/circuitboard/machine/mining_equipment_vendor
	category = list ("Misc. Machinery")

/datum/design/board/tesla_coil
	name = "Machine Design (Tesla Coil Board)"
	desc = "The circuit board for a tesla coil."
	id = "tesla_coil"
	req_tech = list("programming" = 3, "powerstorage" = 3, "magnets" = 3)
	build_path = /obj/item/circuitboard/machine/tesla_coil
	category = list ("Misc. Machinery")

/datum/design/board/grounding_rod
	name = "Machine Design (Grounding Rod Board)"
	desc = "The circuit board for a grounding rod."
	id = "grounding_rod"
	req_tech = list("programming" = 3, "powerstorage" = 3, "magnets" = 3, "plasmatech" = 2)
	build_path = /obj/item/circuitboard/machine/grounding_rod
	category = list ("Misc. Machinery")

/datum/design/board/plantgenes
	name = "Machine Design (Plant DNA Manipulator Board)"
	desc = "The circuit board for a plant DNA manipulator."
	id = "plantgenes"
	req_tech = list("programming" = 4, "biotech" = 3)
	build_path = /obj/item/circuitboard/machine/plantgenes
	category = list ("Misc. Machinery")

/datum/design/board/ntnet_relay
	name = "Machine Design (NTNet Relay Board)"
	desc = "The circuit board for a wireless network relay."
	id = "ntnet_relay"
	req_tech = list("programming" = 2, "engineering" = 2, "bluespace" = 2)
	build_path = /obj/item/circuitboard/machine/ntnet_relay
	category = list("Subspace Telecomms")

/datum/design/board/limbgrower
	name = "Machine Design (Limb Grower Board)"
	desc = "The circuit board for a limb grower."
	id = "limbgrower"
	req_tech = list("programming" = 3, "biotech" = 2)
	build_path = /obj/item/circuitboard/machine/limbgrower
	category = list("Medical Machinery")

/datum/design/board/deepfryer
	name = "Machine Design (Deep Fryer)"
	desc = "The circuit board for a Deep Fryer."
	id = "deepfryer"
	req_tech = list("programming" = 1)
	build_path = /obj/item/circuitboard/machine/deep_fryer
	category = list ("Misc. Machinery")
