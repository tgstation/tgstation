////////////////////////////////////////
//////////////MISC Boards///////////////
////////////////////////////////////////
/datum/design/board/electrolyzer
	name = "Electrolyzer Board"
	desc = "Used to build an electrolyzer, which atmospherics uses to process certain gas types."
	build_path = /obj/item/circuitboard/machine/electrolyzer
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ATMOS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/smes
	name = "SMES Board"
	desc = "Used to build a SMES (or \"superconducting magnetic energy storage\"), which stores power."
	build_path = /obj/item/circuitboard/machine/smes
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/power_connector
	name = "Power Connector Board"
	desc = "Used to build a portable SMES power connector. Portable SMES units can be placed within to store or supply power."
	build_path = /obj/item/circuitboard/machine/smes/connector
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/smesbank
	name = "Portable SMES Board"
	desc = "Used to build a portable SMES, which requires a connector to use. Used to store or supply power on the go."
	build_path = /obj/item/circuitboard/machine/smesbank
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/announcement_system
	name = "Automated Announcement System Board"
	desc = "Used to build an automated announcement system. Handles the various automated messages broadcast throughout the station, \
	such as those from arriving crew members."
	build_path = /obj/item/circuitboard/machine/announcement_system
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELECOMMS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/turbine_computer
	name = "Turbine Control Console Board"
	desc = "Used to build a turbine control console. Necessary for operation of a gas turbine."
	build_path = /obj/item/circuitboard/computer/turbine_computer
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ATMOS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/emitter
	name = "Emitter Board"
	desc = "Used to build an emitter, a device that fires high power energy beams."
	build_path = /obj/item/circuitboard/machine/emitter
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/mass_driver
	name = "Mass Driver Board"
	desc = "Used to build a mass driver, a device which launches projectiles at high velocities."
	build_path = /obj/item/circuitboard/machine/mass_driver
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/turbine_compressor
	name = "Turbine Compressor Board"
	desc = "Used to build a turbine compressor. One third of the necessary components for a gas turbine. \
		The compressor should face where the heat is being generated, acting as an intake."
	build_path = /obj/item/circuitboard/machine/turbine_compressor
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ATMOS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/turbine_rotor
	name = "Turbine Rotor Board"
	desc = "Used to build a turbine rotor. One third of the necessary components for a gas turbine. \
		The rotor should be positioned between the compressor and the stator to effectively transfer energy."
	build_path = /obj/item/circuitboard/machine/turbine_rotor
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ATMOS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/turbine_stator
	name = "Turbine Stator Board"
	desc = "Used to build a turbine stator. One third of the necessary components for a gas turbine. \
		The stator should be positioned after the rotor, acting as an outlet."
	build_path = /obj/item/circuitboard/machine/turbine_stator
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ATMOS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/thermomachine
	name = "Thermomachine Board"
	desc = "Used to build a thermomachine. Heats or cools connected gas pipe networks."
	build_path = /obj/item/circuitboard/machine/thermomachine
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ATMOS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/space_heater
	name = "Space Heater Board"
	desc = "Used to build a space heater. Heats or cools the area around it. Power via cell."
	build_path = /obj/item/circuitboard/machine/space_heater
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ATMOS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/teleport_station
	name = "Teleportation Station Board"
	desc = "Used to build a teleportation station. Requires a teleporter hub and teleporter control console. \
		Teleports individuals between connected hubs (or to teleporter beacons) via bluespace."
	build_type = IMPRINTER
	build_path = /obj/item/circuitboard/machine/teleporter_station
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELEPORT
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/teleport_hub
	name = "Teleportation Hub Board"
	desc = "Used to build a teleportation hub. Requires a teleporter station and teleporter control console. \
		Calibrates outgoing teleportation."
	build_type = IMPRINTER
	build_path = /obj/item/circuitboard/machine/teleporter_hub
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELEPORT
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/quantumpad
	name = "Quantum Pad Board"
	desc = "Used to build a quantum telepad, a quick method of point-to-point quantum teleportation."
	build_type = IMPRINTER
	build_path = /obj/item/circuitboard/machine/quantumpad
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELEPORT
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/botpad
	name = "Bot Launchpad Board"
	desc = "Used to build a bot launchpad, which sends station bots to designated locations."
	build_type = IMPRINTER
	build_path = /obj/item/circuitboard/machine/botpad
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/launchpad
	name = "Bluespace Launchpad Board"
	desc = "Used to build a bluespace Launchpad. Requires a bluespace launchpad control console. \
		Allows for bluespace teleportation to and from a given point."
	build_type = IMPRINTER
	build_path = /obj/item/circuitboard/machine/launchpad
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELEPORT
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/launchpad_console
	name = "Bluespace Launchpad Console Board"
	desc = "Used to build a bluespace launchpad Console. Required to operate a bluespace launchpad. \
		Allows for precise targeting of bluespace launchpads."
	build_type = IMPRINTER
	build_path = /obj/item/circuitboard/computer/launchpad_console
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELEPORT
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/modular_shield_gate
	name = "Modular Shield Gate Board"
	desc = "Used to build a modular shield gate. A component of modular shields. \
		The gate can be used to project the shield generated a set distance in a single direction, rather than in all directions. \
		Can only be operated via signaller or a control console."
	build_path = /obj/item/circuitboard/machine/modular_shield_generator/gate
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
		)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/modular_shield_generator
	name = "Modular Shield Generator Board"
	desc = "Used to build a modular shield generator. A component of modular shields. \
		The core of the shield network - components will not function without being connected to it. \
		Can be operated via signaller, its control panel, or a control console."
	build_path = /obj/item/circuitboard/machine/modular_shield_generator
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/modular_shield_node
	name = "Modular Shield Node Board"
	desc = "Used to build a modular shield node. A component of modular shields. \
		A purely structural components that can be used to add more components to a shield network."
	build_path = /obj/item/circuitboard/machine/modular_shield_node
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/modular_shield_cable
	name = "Modular Shield Cable Board"
	desc = "Used to build a modular shield cable. A component of modular shields. \
		A purely structural components used to connect different components of a shield network."
	build_path = /obj/item/circuitboard/machine/modular_shield_cable
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/modular_shield_relay
	name = "Modular Shield Relay Board"
	desc = "Used to build a modular shield relay. A component of modular shields. \
		Used to expand the radius that which a modular shield can reach - every relay allows the shield to cover a larger and larger area."
	build_path = /obj/item/circuitboard/machine/modular_shield_relay
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/modular_shield_charger
	name = "Modular Shield Charger Board"
	desc = "Used to build a modular shield charger. A component of modular shields. \
		Used to improve the speed that which the shield regenerates integrity - every charger improves the overall recharge rate of the shield."
	build_path = /obj/item/circuitboard/machine/modular_shield_charger
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/modular_shield_well
	name = "Modular Shield Well Board"
	desc = "Used to build a modular shield well. A component of modular shields. \
		Used to increase the overall integrity of the shield - every well adds more overall strength to the shield."
	build_path = /obj/item/circuitboard/machine/modular_shield_well
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/modular_shield_console
	name = "Modular Shield Console Board"
	desc = "Used to build a modular shield console. A component of modular shields. \
		Allows for the control and management of the shield network."
	build_path = /obj/item/circuitboard/computer/modular_shield_console
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/teleconsole
	name = "Teleporter Console Board"
	desc = "Used to build a teleporter control console. Requires a teleporter station and teleporter hub. \
		Allows for control over the teleporter."
	build_type = IMPRINTER
	build_path = /obj/item/circuitboard/computer/teleporter
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELEPORT
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/cryotube
	name = "Cryotube Board"
	desc = "Used to build a cryotube, a machine often used in conjunction with cryoxadone for advanced medical treatments."
	build_path = /obj/item/circuitboard/machine/cryo_tube
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_MEDICAL

/datum/design/board/chem_dispenser
	name = "Chem Dispenser Board"
	desc = "Used to build a chem dispenser."
	build_path = /obj/item/circuitboard/machine/chem_dispenser
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CHEMISTRY
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_MEDICAL

/datum/design/board/chem_master
	name = "Chem Master Board"
	desc = "Used to build a Chem Master 3000, for producing pills, patches, or other chemical products."
	build_path = /obj/item/circuitboard/machine/chem_master
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CHEMISTRY
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_MEDICAL

/datum/design/board/chem_heater
	name = "Chemical Heater Board"
	desc = "Used to build a chemical heater."
	build_path = /obj/item/circuitboard/machine/chem_heater
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CHEMISTRY
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_MEDICAL

/datum/design/board/chem_mass_spec
	name = "High-Performance Liquid Chromatography Machine Board"
	desc = "Used to build a high-performance liquid chromatography machine."
	build_path = /obj/item/circuitboard/machine/chem_mass_spec
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CHEMISTRY
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_MEDICAL

/datum/design/board/smoke_machine
	name = "Smoke Machine Board"
	desc = "Used to build a smoke machine."
	build_path = /obj/item/circuitboard/machine/smoke_machine
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CHEMISTRY
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/board/reagentgrinder
	name = "All-In-One Grinder Board"
	desc = "Used to build an All-In-One Grinder."
	build_path = /obj/item/circuitboard/machine/reagentgrinder
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CHEMISTRY
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/hypnochair
	name = "Enhanced Interrogation Chamber Board"
	desc = "Used to build an Enhanced Interrogation Chamber, an experimental device that induces a form of hypnosis on its occupants."
	build_path = /obj/item/circuitboard/machine/hypnochair
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_SECURITY
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/board/photobooth
	name = "Photobooth Board"
	desc = "Used to build a photobooth."
	build_path = /obj/item/circuitboard/machine/photobooth
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_SERVICE
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/security_photobooth
	name = "Security Photobooth Board"
	desc = "Used to build a security photobooth."
	build_path = /obj/item/circuitboard/machine/photobooth/security
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_SECURITY
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/board/biogenerator
	name = "Biogenerator Board"
	desc = "Used to build a biogenerator, which uses biological matter to generate useful materials and reagents."
	build_path = /obj/item/circuitboard/machine/biogenerator
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_BOTANY
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/hydroponics
	name = "Hydroponics Tray Board"
	desc = "Used to build a hydroponics tray."
	build_path = /obj/item/circuitboard/machine/hydroponics
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_BOTANY
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/destructive_analyzer
	name = "Destructive Analyzer Board"
	desc = "Used to build a destructive analyzer, allowing R&D to deconstruct objects to unlock new technology."
	build_path = /obj/item/circuitboard/machine/destructive_analyzer
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/experimentor
	name = "E.X.P.E.R.I-MENTOR Board"
	desc = "Used to build an E.X.P.E.R.I-MENTOR, an large machine used to identify strange relics and conduct arcane experiments."
	build_path = /obj/item/circuitboard/machine/experimentor
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/circuit_imprinter
	name = "Circuit Imprinter Board"
	desc = "Used to build a circuit imprinter."
	build_type = IMPRINTER
	build_path = /obj/item/circuitboard/machine/circuit_imprinter
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_FAB
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/circuit_imprinter/offstation
	name = "Ancient Circuit Imprinter Board"
	desc = "Used to build a circuit imprinter."
	build_type = AWAY_IMPRINTER
	build_path = /obj/item/circuitboard/machine/circuit_imprinter/offstation
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_FAB
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/rdservercontrol
	name = "R&D Server Control Console Board"
	desc = "Used to build an R&D server control console, to monitor the status of the station's R&D servers."
	build_path = /obj/item/circuitboard/computer/rdservercontrol
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/rdserver
	name = "R&D Server Board"
	desc = "Used to build an R&D Server. Note that additional R&D servers do not provide additional research progress."
	build_path = /obj/item/circuitboard/machine/rdserver
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/mechfab
	name = "Exosuit Fabricator Board"
	desc = "Used to build an exosuit fabricator."
	build_path = /obj/item/circuitboard/machine/mechfab
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ROBOTICS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/cyborgrecharger
	name = "Cyborg Recharger Board"
	desc = "Used to build a cyborg recharger. Can also be used to recharge MODs and even Ethereals."
	build_path = /obj/item/circuitboard/machine/cyborgrecharger
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ROBOTICS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/mech_recharger
	name = "Mechbay Recharger Board"
	desc = "Used to build a mech bay recharger."
	build_path = /obj/item/circuitboard/machine/mech_recharger
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ROBOTICS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/dnascanner
	name = "DNA Scanner Board"
	desc = "Used to build a DNA scanner, for genetic research. Requires a corresponding DNA scanner console."
	build_path = /obj/item/circuitboard/machine/dnascanner
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_GENETICS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/dnainfuser
	name = "DNA Infuser Board"
	desc = "Used to build a DNA infuser, for mixing animal DNA and human DNA to create hybrid organisms."
	build_path = /obj/item/circuitboard/machine/dna_infuser
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_GENETICS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/scan_console
	name = "DNA Console Board"
	desc = "Used to build a DNA console, for genetic research. Requires a corresponding DNA scanner."
	build_path = /obj/item/circuitboard/computer/scan_consolenew
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_GENETICS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/destructive_scanner
	name = "Destructive Scanner Board"
	desc = "Used to build an experimental destructive scanner, allowing R&D to deconstruct objects to further their experiments."
	build_path = /obj/item/circuitboard/machine/destructive_scanner
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/doppler_array
	name = "Tachyon-Doppler Research Array Board"
	desc = "Used to build a tachyon-doppler research array. Records the strength of explosions in the direction it is pointed. \
		Often installed in the ordnance testing lab, pointed down range at the test site."
	build_path = /obj/item/circuitboard/machine/doppler_array
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/anomaly_refinery
	name = "Anomaly Refinery Board"
	desc = "Used to build an anomaly refinery. Takes raw anomaly cores and transfer tank valves to produce refined anomaly cores."
	build_path = /obj/item/circuitboard/machine/anomaly_refinery
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/tank_compressor
	name = "Tank Compressor Board"
	desc = "Used to build a tank compressor. Compresses any input gas into a canister for scientific experiments."
	build_path = /obj/item/circuitboard/machine/tank_compressor
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/microwave
	name = "Microwave Board"
	desc = "Used to build a microwave."
	build_path = /obj/item/circuitboard/machine/microwave
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_KITCHEN
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/microwave_engineering
	name = "Wireless Microwave Board"
	desc = "Used to build a cell-powered microwave."
	build_path = /obj/item/circuitboard/machine/microwave/engineering
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_KITCHEN
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/gibber
	name = "Gibber Board"
	desc = "Used to build a gibber."
	build_path = /obj/item/circuitboard/machine/gibber
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_KITCHEN
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/smartfridge
	name = "Smartfridge Board"
	desc = "Used to build a smartfridge."
	build_path = /obj/item/circuitboard/machine/smartfridge
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_KITCHEN
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/dehydrator
	name = "Dehydrator Board"
	desc = "Used to build a dehydrator."
	build_path = /obj/item/circuitboard/machine/dehydrator
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_KITCHEN
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/vatgrower
	name = "Growing Vat Board"
	desc = "Used to build a growing vat. Allows for cytologists to grow new organisms."
	build_path = /obj/item/circuitboard/machine/vatgrower
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/monkey_recycler
	name = "Monkey Recycler Board"
	desc = "Used to build a monkey recycler. Allows for xenobiologists to recycle the \"leftovers\" of slime feeding into new monkeys."
	build_path = /obj/item/circuitboard/machine/monkey_recycler
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/seed_extractor
	name = "Seed Extractor Board"
	desc = "Used to build a seed extractor. Can be fed plants to extract their seeds to replant or store."
	build_path = /obj/item/circuitboard/machine/seed_extractor
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_BOTANY
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/processor
	name = "Food/Slime Processor Board"
	desc = "Used to build a processing unit. Screwdriver the circuit to switch between food (default) or slime processing."
	build_path = /obj/item/circuitboard/machine/processor
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_KITCHEN
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/soda_dispenser
	name = "Portable Soda Dispenser Board"
	desc = "Used to build a soda dispenser."
	build_path = /obj/item/circuitboard/machine/chem_dispenser/drinks
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_BAR
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/beer_dispenser
	name = "Portable Booze Dispenser Board"
	desc = "Used to build a booze dispenser."
	build_path = /obj/item/circuitboard/machine/chem_dispenser/drinks/beer
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_BAR
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/recycler
	name = "Recycler Board"
	desc = "Used to build a recycler. Tears apart almost all varieties of items, spitting out their base materials."
	build_path = /obj/item/circuitboard/machine/recycler
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/scanner_gate
	name = "Scanner Gate Board"
	desc = "Used to build a scanner gate. Analyzes any organism that passes underneath. Can be configured in a number of ways."
	build_path = /obj/item/circuitboard/machine/scanner_gate
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_SECURITY | DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_MEDICAL

/datum/design/board/holopad
	name = "Holopad Board"
	desc = "Used to build a holopad. Allows for remote calls to other holopads. Screwdriver the circuit to toggle security mode."
	build_path = /obj/item/circuitboard/machine/holopad
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/autolathe
	name = "Autolathe Board"
	desc = "Used to build an autolathe. Prints a wide variety of generically useful items."
	build_path = /obj/item/circuitboard/machine/autolathe
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_FAB
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/recharger
	name = "Weapon Recharger Board"
	desc = "Used to build a weapon recharger. Recharges the cell of anything placed within."
	materials = list(/datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/gold =SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/circuitboard/machine/recharger
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_SECURITY
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SECURITY

/datum/design/board/vendor
	name = "Vendor Board"
	desc = "Used to build a vending machine. Screwdriver the circuit to select the type of vending machine."
	build_path = /obj/item/circuitboard/machine/vendor
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_SERVICE
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/ore_redemption
	name = "Ore Redemption Machine Board"
	desc = "Used to build an ore redemption machine. Smelts raw ores into usable materials."
	build_path = /obj/item/circuitboard/machine/ore_redemption
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/mining_equipment_vendor
	name = "Mining Rewards Vendor Board"
	desc = "Used to build a mining rewards vendor. Offers a wide variety of equipment to shaft miners in exchange for their mining points."
	build_path = /obj/item/circuitboard/computer/order_console/mining
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/board/suit_storage_unit
	name = "Suit Storage Unit"
	desc = "Used to build a suit storage unit. In addition to storing and organizing EVA suits and related equipment, automatically recharges suit power cells."
	build_path = /obj/item/circuitboard/machine/suit_storage_unit
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ROBOTICS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/tesla_coil
	name = "Tesla Coil Board"
	desc = "Used to build a tesla coil. Collects energy from electrical discharges and stores it, releases it into connected cables over time."
	build_path = /obj/item/circuitboard/machine/tesla_coil
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/grounding_rod
	name = "Grounding Rod Board"
	desc = "Used to build a grounding rod. Safely directs electrical discharges into the ground."
	build_path = /obj/item/circuitboard/machine/grounding_rod
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/ntnet_relay
	name = "NTNet Relay Board"
	desc = "Used to build a wireless network relay. Extends the range of NTNet communications."
	build_path = /obj/item/circuitboard/machine/ntnet_relay
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELECOMMS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/crossing_signal
	name = "Crossing Signal Board"
	desc = "Used to build a tram crossing signal. Warns for approaching trams. Requires a guideway sensor."
	build_path = /obj/item/circuitboard/machine/crossing_signal
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELECOMMS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/guideway_sensor
	name = "Guideway Sensor Board"
	desc = "Used to build a tram proximity sensor. Detects oncoming trams and triggers appropriate signals."
	build_path = /obj/item/circuitboard/machine/guideway_sensor
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELECOMMS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/limbgrower
	name = "Limb Grower Board"
	desc = "Used to build a limb grower. Creates replacement organic limbs."
	build_path = /obj/item/circuitboard/machine/limbgrower
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/board/harvester
	name = "Organ Harvester Board"
	desc = "Used to build an organ harvester."
	build_path = /obj/item/circuitboard/machine/harvester
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/board/deepfryer
	name = "Deep Fryer Board"
	desc = "Used to build a deep fryer."
	build_path = /obj/item/circuitboard/machine/deep_fryer
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_KITCHEN
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/griddle
	name = "Griddle Board"
	desc = "Used to build a griddle."
	build_path = /obj/item/circuitboard/machine/griddle
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_KITCHEN
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/oven
	name = "Oven Board"
	desc = "Used to build an oven."
	build_path = /obj/item/circuitboard/machine/oven
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_KITCHEN
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/stove
	name = "Stove Board"
	desc = "Used to build a stove."
	build_path = /obj/item/circuitboard/machine/stove
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_KITCHEN
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/range
	name = "Range Board"
	desc = "Used to build a range, which is both an oven and a stove."
	build_path = /obj/item/circuitboard/machine/range
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_KITCHEN
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/cell_charger
	name = "Cell Charger Board"
	desc = "Used to build a cell charger."
	build_path = /obj/item/circuitboard/machine/cell_charger
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/dish_drive
	name = "Dish Drive Board"
	desc = "Used to build a dish drive. Collects nearby empty dishes."
	build_path = /obj/item/circuitboard/machine/dish_drive
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_KITCHEN
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/stacking_unit_console
	name = "Stacking Machine Console Board"
	desc = "Used to build a stacking machine console. Controls a stacking machine."
	build_path = /obj/item/circuitboard/machine/stacking_unit_console
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/stacking_machine
	name = "Stacking Machine Board"
	desc = "Used to build a stacking machine. Collects nearby materials and dispenses it in the ore silo."
	build_path = /obj/item/circuitboard/machine/stacking_machine
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/ore_silo
	name = "Ore Silo Board"
	desc = "Used to build an ore silo. Stores collected materials for use across the station."
	build_path = /obj/item/circuitboard/machine/ore_silo
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/fat_sucker
	name = "Lipid Extractor Board"
	desc = "Used to build a lipid extractor. Removes excess fat from individuals."
	build_path = /obj/item/circuitboard/machine/fat_sucker
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_SERVICE
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/stasis
	name = "Lifeform Stasis Unit Board"
	desc = "Used to build a stasis unit."
	build_path = /obj/item/circuitboard/machine/stasis
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/board/medical_kiosk
	name = "Medical Kiosk Board"
	desc = "Used to build a medical kiosk."
	build_path = /obj/item/circuitboard/machine/medical_kiosk
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/board/medipen_refiller
	name = "Medipen Refiller Board"
	desc = "Used to build a medipen refiller."
	build_path = /obj/item/circuitboard/machine/medipen_refiller
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/board/plumbing_receiver
	name = "Chemical Recipient Board"
	desc = "Used to build a chemical recipient. Connects to plumbing networks and uses bluespace to teleport chemicals long distances."
	build_path = /obj/item/circuitboard/machine/plumbing_receiver
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CHEMISTRY
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/sheetifier
	name = "Sheet-meister 2000 Board"
	desc = "Used to build a Sheet-meister 2000, which transforms certain objects into construction-viable sheets of material."
	build_path = /obj/item/circuitboard/machine/sheetifier
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_FAB
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_CARGO

/datum/design/board/restaurant_portal
	name = "Restaurant Portal Board"
	desc = "Used to build a restaurant portal, which transports tourists to and from the station."
	build_path = /obj/item/circuitboard/machine/restaurant_portal
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_KITCHEN
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/bountypad
	name = "Civilian Bounty Pad Board"
	desc = "Used to build a civilian bounty pad to send bounty components. Requires a civilian bounty pad console."
	build_path = /obj/item/circuitboard/machine/bountypad
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/board/skill_station
	name = "Skill Station Board"
	desc = "Used to build a skill station, for interfacing with skillchips."
	build_path = /obj/item/circuitboard/machine/skill_station
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_SERVICE
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/fax
	name = "Fax Machine Board"
	desc = "Used to build a a fax machine."
	build_path = /obj/item/circuitboard/machine/fax
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_SERVICE
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE | DEPARTMENT_BITFLAG_CARGO

//Hypertorus fusion reactor designs

/datum/design/board/HFR_core
	name = "HFR Core Board"
	desc = "Used to build the core of the hypertorus fusion reactor."
	build_path = /obj/item/circuitboard/machine/HFR_core
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ATMOS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/HFR_fuel_input
	name = "HFR Fuel Input Board"
	desc = "Used to build the fuel input of the hypertorus fusion reactor."
	build_path = /obj/item/circuitboard/machine/HFR_fuel_input
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ATMOS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/HFR_waste_output
	name = "HFR Waste Output Board"
	desc = "Used to build the waste output of the hypertorus fusion reactor."
	build_path = /obj/item/circuitboard/machine/HFR_waste_output
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ATMOS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/HFR_moderator_input
	name = "HFR Moderator Input Board"
	desc = "Used to build the moderator input of the hypertorus fusion reactor."
	build_path = /obj/item/circuitboard/machine/HFR_moderator_input
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ATMOS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/HFR_corner
	name = "HFR Corner Board"
	desc = "Used to build a corner of the hypertorus fusion reactor."
	build_path = /obj/item/circuitboard/machine/HFR_corner
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ATMOS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/HFR_interface
	name = "HFR Interface Board"
	desc = "Used to build the interface of the hypertorus fusion reactor."
	build_path = /obj/item/circuitboard/machine/HFR_interface
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ATMOS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/crystallizer
	name = "Crystallizer Board"
	desc = "Used to build a crystallizer, which atmospherics uses to condense gases into solid form."
	build_path = /obj/item/circuitboard/machine/crystallizer
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ATMOS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/exoscanner
	name = "Scanner Array Board"
	desc = "Used to build a scanner array. Exodrone operators use these to expand the range of their scanning capabilities."
	build_path = /obj/item/circuitboard/machine/exoscanner
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/board/exodrone_launcher
	name = "Exploration Drone Launcher Board"
	desc = "Used to build an exodrone launcher. Exodrone operators use these to deploy their exploration drones."
	build_path = /obj/item/circuitboard/machine/exodrone_launcher
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/board/component_printer
	name = "Component Printer Board"
	desc = "Used to build a component printer. Prints circuit components."
	build_path = /obj/item/circuitboard/machine/component_printer
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/module_printer
	name = "Module Duplicator Board"
	desc = "Used to build a module duplicator. Copies circuits."
	build_path = /obj/item/circuitboard/machine/module_duplicator
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/coffeemaker
	name = "Coffeemaker Board"
	desc = "Used to build a coffeemaker."
	build_path = /obj/item/circuitboard/machine/coffeemaker
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_SERVICE
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE | DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/navbeacon
	name = "Bot Navigational Beacon Board"
	desc = "Used to build a beacon that aids bot navigation."
	build_path = /obj/item/circuitboard/machine/navbeacon
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ROBOTICS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/fishing_portal_generator
	name = "Fishing Portal Generator Board"
	desc = "Used to build a fishing portal generator, allowing for remote fishing capabilities."
	build_path = /obj/item/circuitboard/machine/fishing_portal_generator
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_SERVICE
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE | DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/brm
	name = "Boulder Retrieval Matrix Board"
	desc = "Used to build a boulder retrieval matrix. Teleports newly harvested boulders from down below straight to the station for processing."
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/circuitboard/machine/brm
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELEPORT,
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/board/flatpacker
	name = "Flatpacker Machine Board"
	desc = "Used to build a flatpacker, allowing for significantly faster machine assembly and deployment."
	build_path = /obj/item/circuitboard/machine/flatpacker
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/scrubber
	name = "Portable Air Scrubber Board"
	desc = "Used to build a portable air scrubber."
	build_path = /obj/item/circuitboard/machine/scrubber
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ATMOS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/pump
	name = "Portable Air Pump Board"
	desc = "Used to build a portable air pump."
	build_path = /obj/item/circuitboard/machine/pump
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ATMOS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/pipe_scrubber
	name = "Portable Pipe Scrubber Board"
	desc = "Used to build a portable pipe scrubber."
	build_path = /obj/item/circuitboard/machine/pipe_scrubber
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ATMOS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/bookbinder
	name = "Book Binder"
	desc = "Used to build a book binder."
	build_path = /obj/item/circuitboard/machine/bookbinder
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_SERVICE
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/libraryscanner
	name = "Book Scanner"
	desc = "Used to build a book scanner."
	build_path = /obj/item/circuitboard/machine/libraryscanner
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_SERVICE
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/big_manipulator
	name = "Big Manipulator Board"
	desc = "Used to build a manipulator, capable of doing countless different interactions with various objects."
	build_path = /obj/item/circuitboard/machine/big_manipulator
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/manulathe
	name = "Manufacturing Lathe Board"
	desc = "Used to build a manufacturing lathe. Allows for automatic fabrication of certain recipes."
	build_path = /obj/item/circuitboard/machine/manulathe
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO

/datum/design/board/manucrafter
	name = "Manufacturing Assembling Machine Board"
	desc = "Used to build a manufacturing assembling machine. Allows for automatic assembly of certain recipes."
	build_path = /obj/item/circuitboard/machine/manucrafter
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO

/datum/design/board/manucrusher
	name = "Manufacturing Crusher Board"
	desc = "Used to build a manufacturing crusher. Automatically crushes anything that enters it, such as boulders."
	build_path = /obj/item/circuitboard/machine/manucrusher
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO

/datum/design/board/manurouter
	name = "Manufacturing Router Board"
	desc = "Used to build a manufacturing router, best used with conveyor systems to divide an input across multiple outputs."
	build_path = /obj/item/circuitboard/machine/manurouter
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO

/datum/design/board/manusorter
	name = "Manufacturing Sort-Router Board"
	desc = "Used to build a manufacturing sort-router, best used with conveyor systems to direct certain inputs to specific outputs."
	build_path = /obj/item/circuitboard/machine/manusorter
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO

/datum/design/board/manuunloader
	name = "Manufacturing Crate Unloader Board"
	desc = "Used to build a manufacturing crate unloader, which takes in crates or boxes, and automatically extracts its contents."
	build_path = /obj/item/circuitboard/machine/manuunloader
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO

/datum/design/board/manusmelter
	name = "Manufacturing Smelter Board"
	desc = "Used to build a manufacturing smelter, which incinerates any input materials to produce refined outputs."
	build_path = /obj/item/circuitboard/machine/manusmelter
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO

/datum/design/board/mailsorter
	name = "Mail Sorter Board"
	desc = "Used to build a mail sorter, which stores mail and automatically sorts it by department or recipient."
	build_path = /obj/item/circuitboard/machine/mailsorter
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/propulsion_engine
	name = "Propulsion Engine Board"
	desc = "Used to build a propulsion engine for a shuttle."
	build_path = /obj/item/circuitboard/machine/engine/propulsion
	build_type = IMPRINTER
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/photopcopier
	name = "Photocopier Board"
	desc = "Used to build a photocopier."
	build_path = /obj/item/circuitboard/machine/photocopier
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_SERVICE
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/atmosshieldgen
	name = "Atmospherics Shield Generator Board"
	desc = "Used to build an atmospherics shield generator, which uses power to stop air from passing through."
	build_path = /obj/item/circuitboard/machine/atmos_shield_gen
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ATMOS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/netpod
	name = "Netpod Board"
	desc = "Used to build a netpod, which Bitrunners enter to access their virtual domains."
	build_path = /obj/item/circuitboard/machine/netpod
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/byteforge
	name = "Byteforge Board"
	desc = "Used to build a Byteforge, which synthesizes resources and other rewards earned by Bitrunners."
	build_path = /obj/item/circuitboard/machine/byteforge
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/washing_machine
	name = "Washing Machine Board"
	desc = "Used to build a washing machine."
	build_path = /obj/item/circuitboard/machine/washing_machine
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_SERVICE
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE
