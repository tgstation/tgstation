///////////////////Computer Boards///////////////////////////////////

/datum/design/board
	abstract_type = /datum/design/board
	build_type = IMPRINTER | AWAY_IMPRINTER
	materials = list(/datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT)

/datum/design/board/arcade_battle
	name = "Battle Arcade Machine Board"
	desc = "Used to build a battle arcade machine."
	build_path = /obj/item/circuitboard/computer/arcade/battle
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_ENTERTAINMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/orion_trail
	name = "Orion Trail Arcade Machine Board"
	desc = "Used to build an Orion Trail machine."
	build_path = /obj/item/circuitboard/computer/arcade/orion_trail
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_ENTERTAINMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/seccamera
	name = "Security Camera Board"
	desc = "Used to build a security camera console, to view the station's security camera network."
	build_path = /obj/item/circuitboard/computer/security
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_SECURITY
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/board/rdcamera
	name = "Research Monitor Board"
	desc = "Used to build a research camera console, to view the research department's camera networks."
	build_path = /obj/item/circuitboard/computer/research
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/xenobiocamera
	name = "Xenobiology Console Board"
	desc = "Used to build a xenobiology camera console, to manage xenobiology's slime research."
	build_path = /obj/item/circuitboard/computer/xenobiology
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/med_data
	name = "Medical Records Board"
	desc = "Used to build a medical records console, to view the crew's medical data."
	build_path = /obj/item/circuitboard/computer/med_data
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/board/operating
	name = "Operating Computer Board"
	desc = "Used to build an operating computer console, to perform advanced surgical procedures."
	build_path = /obj/item/circuitboard/computer/operating
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/pandemic
	name = "PanD.E.M.I.C. 2200 Board"
	desc = "Used to build a PanD.E.M.I.C. 2200 console, to view and engineer viruses."
	build_path = /obj/item/circuitboard/computer/pandemic
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/board/comconsole
	name = "Communications Board"
	desc = "Used to build a communications console, primarily for managing communication between Central Command and the station. Typically installed in the Bridge."
	build_path = /obj/item/circuitboard/computer/communications
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_COMMAND
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SECURITY //Honestly should have a bridge techfab for this sometime.

/datum/design/board/bankmachine
	name = "Bank Machine Board"
	desc = "Used to build a bank machine, allowing withdrawal and deposit of funds into the station's bank account. Typically installed in the Vault."
	build_path = /obj/item/circuitboard/computer/bankmachine
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_COMMAND
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SECURITY

/datum/design/board/crewconsole
	name = "Crew Monitoring Computer Board"
	desc = "Used to build a crew monitoring computer, to monitor the crew's vital signs."
	build_type = IMPRINTER
	build_path = /obj/item/circuitboard/computer/crew
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY | DEPARTMENT_BITFLAG_MEDICAL

/datum/design/board/secdata
	name = "Security Records Console Board"
	desc = "Used to build a security records console, to manage and view the station's security records."
	build_path = /obj/item/circuitboard/computer/secure_data
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_SECURITY
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/board/atmosalerts
	name = "Atmosphere Alert Board"
	desc = "Used to build an atmosphere alert console, reporting hazardous atmospheric conditions across the station."
	build_path = /obj/item/circuitboard/computer/atmos_alert
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/atmos_control
	name = "Atmospheric Monitor Board"
	desc = "Used to build an atmospheric monitor, giving more detailed information about the station's atmospheric conditions."
	build_path = /obj/item/circuitboard/computer/atmos_control
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/robocontrol
	name = "Robotics Control Console Board"
	desc = "Used to build a robotics control console, offering control over the station's bot assistants, and to a lesser extent, cyborg units."
	materials = list(/datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/gold =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/silver =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/bluespace =SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/circuitboard/computer/robotics
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_ROBOTICS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/slot_machine
	name = "Slot Machine Board"
	desc = "Used to build a new slot machine."
	build_path = /obj/item/circuitboard/computer/slot_machine
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_ENTERTAINMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE


/datum/design/board/powermonitor
	name = "Power Monitor Board"
	desc = "Used to build a power monitoring console. Provides real-time information pertaining to all APC and SMES units connected to the console. \
		Requires a physical cable connection, unlike most consoles."
	build_path = /obj/item/circuitboard/computer/powermonitor
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/solarcontrol
	name = "Solar Control Board"
	desc = "Used to build a solar control console. Tracks the status of all solar cells connected to the console. \
		Requires a physical cable connection, unlike most consoles."
	build_path = /obj/item/circuitboard/computer/solar_control
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/prisonmanage
	name = "Prisoner Management Console Board"
	desc = "Used to build a prisoner management console, allowing monitoring of all implanted convicts."
	build_path = /obj/item/circuitboard/computer/prisoner
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_SECURITY
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/board/mechacontrol
	name = "Exosuit Control Console Board"
	desc = "Used to build an exosuit control console, allowing monitoring over mechs with installed tracking beacons."
	build_path = /obj/item/circuitboard/computer/mecha_control
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_ROBOTICS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/mechapower
	name = "Mech Bay Power Control Console Board"
	desc = "Used to build a mech bay power control console. Built in tandem with a mech recharger to, well, recharge mechs."
	build_path = /obj/item/circuitboard/computer/mech_bay_power_console
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_ROBOTICS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/rdconsole
	name = "R&D Console Board"
	desc = "Used to build a new R&D console, to research new technology for the station. \
		Locked by default, requiring research access to unlock."
	build_path = /obj/item/circuitboard/computer/rdconsole
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/cargo
	name = "Supply Console Board"
	desc = "Used to build a Supply Console. Able to approve supply requests, directly purchase items, and send the supply shuttle back and forth between the station and Central Command."
	build_type = IMPRINTER
	build_path = /obj/item/circuitboard/computer/cargo
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/board/cargorequest
	name = "Supply Request Console Board"
	desc = "Used to build a Supply Request Console. A \"request only\" version of the supply console board, incapable of direct purchase or shuttle use."
	build_type = IMPRINTER
	build_path = /obj/item/circuitboard/computer/cargo/request
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/board/mining
	name = "Outpost Status Display Board"
	desc = "Used to build an outpost status display console, to view the mining outpost's camera network."
	build_path = /obj/item/circuitboard/computer/mining
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SECURITY

/datum/design/board/comm_monitor
	name = "Telecommunications Monitoring Console Board"
	desc = "Used to build a telecommunications monitor, reporting the status of a telecommunication network."
	build_path = /obj/item/circuitboard/computer/comm_monitor
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/comm_server
	name = "Telecommunications Server Monitoring Console Board"
	desc = "Used to build a telecommunication server monitor, which logs and stores all communications messages sent through a telecommunication network."
	build_path = /obj/item/circuitboard/computer/comm_server
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/message_monitor
	name = "Messaging Monitor Console Board"
	desc = "Used to build a messaging monitor console, which logs and stores all messages sent via PDA or request console."
	build_path = /obj/item/circuitboard/computer/message_monitor
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/aifixer
	name = "AI Integrity Restorer Board"
	desc = "Used to build an AI Integrity Restorer, to repair broken AI units."
	build_path = /obj/item/circuitboard/computer/aifixer
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_ROBOTICS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/libraryconsole
	name = "Library Console Board"
	desc = "Used to build a new library console, providing access to the station's library database."
	build_path = /obj/item/circuitboard/computer/libraryconsole
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_ENTERTAINMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/board/apc_control
	name = "APC Control Board"
	desc = "Used to build a new power flow control console, allowing remote access and control over all the station's APC units. \
		Requires Chief Engineer access to operate."
	build_path = /obj/item/circuitboard/computer/apc_control
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/advanced_camera
	name = "Advanced Camera Console Board"
	desc = "Used to build advanced camera consoles, providing enhanced surveillance capabilities."
	build_path = /obj/item/circuitboard/computer/advanced_camera
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_SECURITY
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/board/bountypad_control
	name = "Civilian Bounty Pad Control Board"
	desc = "Used to build a civilian bounty pad console, allowing the crew to manage and track their cargo bounties. Requires a civilian bounty pad."
	build_path = /obj/item/circuitboard/computer/bountypad
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/board/exoscanner_console
	name = "Scanner Array Control Console Board"
	desc = "Used to build a scanner array control console. Used by exodrone operators to manage their scanning arrays and discover new locations to explore."
	build_type = IMPRINTER
	build_path = /obj/item/circuitboard/computer/exoscanner_console
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/exodrone_console
	name = "Exploration Drone Control Console Board"
	desc = "Used to build a new exploration drone control console. Used by exodrone operators to control their exploration drones."
	build_type = IMPRINTER
	build_path = /obj/item/circuitboard/computer/exodrone_console
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/accounting_console
	name = "Account Lookup Console Board"
	desc = "Used to build an account lookup console, allowing for the quick auditing of the crew's financial records, as well as paycheck management."
	build_type = IMPRINTER
	build_path = /obj/item/circuitboard/computer/accounting
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_COMMAND
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY //Honestly should have a bridge techfab for this sometime.

/datum/design/board/shuttle
	abstract_type = /datum/design/board/shuttle
	build_type = IMPRINTER
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO

/datum/design/board/shuttle/flight_control
	name = "Shuttle Flight Control Board"
	desc = "Used to build a console that enables shuttle flight."
	build_path = /obj/item/circuitboard/computer/shuttle/flight_control

/datum/design/board/shuttle/shuttle_docker
	name = "Shuttle Navigation Computer Board"
	desc = "Used to build a console that enables the targeting of custom flight locations."
	build_path = /obj/item/circuitboard/computer/shuttle/docker

/datum/design/board/quantum_console
	name = "Quantum Console Board"
	desc = "Used to build a quantum console, used by Bitrunners to manage their quantum server."
	build_path = /obj/item/circuitboard/computer/quantum_console
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING
