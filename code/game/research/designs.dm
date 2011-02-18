/***************************************************************
**						Design Datums						  **
**	All the data for building stuff and tracking reliability. **
***************************************************************/
/*
For the materials datum, it assumes you need reagents unless specified otherwise. To designate a material that isn't a reagent,
you use one of the material IDs below. These are NOT ids in the usual sense (they aren't defined in the object or part of a datum),
they are simply references used as part of a "has materials?" type proc. They all start with a $ to denote that they aren't reagents.
The currently supporting non-reagent materials:
- $metal (/obj/item/stack/metal). One sheet = 3750 units.
- $glass (/obj/item/stack/metal). One sheet = 3750 units.
(Insert new ones here)

Don't add new keyword/IDs if they are made from an existing one (such as rods which are made from metal). Only add raw materials.

*/
#define	IMPRINTER	1	//For circuits. Uses glass/chemicals.
#define PROTOLATHE	2	//New stuff. Uses glass/metal/chemicals
#define	AUTOLATHE	4	//Uses glass/metal only.
#define CRAFTLATHE	8	//Uses fuck if I know. For use eventually.
//Note: More then one of these can be added to a design but imprinter and lathe designs are incompatable.

datum
	design						//Datum for object designs, used in construction
		var
			name = "Name"					//Name of the created object.
			desc = "Desc"					//Description of the created object.
			id = "id"						//ID of the created object for easy refernece. Alphanumeric, lower-case, no symbols
			list/req_tech = list()			//IDs of that techs the object originated from and the minimum level requirements.
			reliability_mod = 0				//Reliability modifier of the device at it's starting point.
			reliability_base = 100			//Base reliability of a device before modifiers.
			reliability = 100				//Reliability of the device.
			build_type = null				//Flag as to what kind machine the design is built in. See defines.
			list/materials = list()			//List of materials. Format: "id" = amount.
			build_path = ""					//The file path of the object that gets created

		proc
			//A proc to calculate the reliability of a design based on tech levels and innate modifiers.
			//Input: A list of /datum/tech; Output: The new reliabilty.
			CalcReliability(var/list/temp_techs)
				var/new_reliability = reliability_mod + reliability_base
				for(var/datum/tech/T in temp_techs)
					if(T.id in req_tech)
						new_reliability += (T.level - req_tech[T]) * 5
				new_reliability = between(reliability_base, new_reliability, 100)
				return new_reliability


///////////////////Computer Boards///////////////////////////////////

		seccamera
			name = "Circuit Design (Security)"
			desc = "Allows for the construction of circuit boards used to build security camera computers."
			id = "seccamera"
			req_tech = list("programming" = 2)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/circuitboard/security"

		aicore
			name = "Circuit Design (AI Core)"
			desc = "Allows for the construction of circuit boards used to build new AI cores."
			id = "aicore"
			req_tech = list("programming" = 4, "biotech" = 3)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/circuitboard/aicore"

		aiupload
			name = "Circuit Design (AI Upload)"
			desc = "Allows for the construction of circuit boards used to build an AI Upload Console."
			id = "aiupload"
			req_tech = list("programming" = 4)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/circuitboard/aiupload"

		med_data
			name = "Circuit Design (Medical Records)"
			desc = "Allows for the construction of circuit boards used to build a medical records console."
			id = "med_data"
			req_tech = list("programming" = 2)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/circuitboard/med_data"

		pandemic
			name = "Circuit Design (PanD.E.M.I.C. 2200)"
			desc = "Allows for the construction of circuit boards used to build a PanD.E.M.I.C. 2200 console."
			id = "pandemic"
			req_tech = list("programming" = 2, "biotech" = 2)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/circuitboard/pandemic"

		scan_console
			name = "Circuit Design (DNA Machine)"
			desc = "Allows for the construction of circuit boards used to build a new DNA scanning console."
			id = "scan_console"
			req_tech = list("programming" = 2, "biotech" = 3)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/machinery/scan_consolenew"

		comconsole
			name = "Circuit Design (Communications)"
			desc = "Allows for the construction of circuit boards used to build a communications console."
			id = "comconsole"
			req_tech = list("programming" = 2, "magnets" = 2)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/circuitboard/communications"

		idcardconsole
			name = "Circuit Design (ID Computer)"
			desc = "Allows for the construction of circuit boards used to build an ID computer."
			id = "idcardconsole"
			req_tech = list("programming" = 2)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/circuitboard/card"

		teleconsole
			name = "Circuit Design (Teleporter Console)"
			desc = "Allows for the construction of circuit boards used to build a teleporter control console."
			id = "teleconsole"
			req_tech = list("programming" = 3, "bluespace" = 2)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/circuitboard/teleporter"

		secdata
			name = "Circuit Design (Security Records Console)"
			desc = "Allows for the construction of circuit boards used to build a security records console."
			id = "secdata"
			req_tech = list("programming" = 2)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/circuitboard/secure_data"

		atmosalerts
			name = "Circuit Design (Atmosphere Alerts Console)"
			desc = "Allows for the construction of circuit boards used to build an atmosphere alert console.."
			id = "atmosalerts"
			req_tech = list("programming" = 2)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/circuitboard/atmosphere/alerts"

		air_management
			name = "Circuit Design (Atmospheric Monitor)"
			desc = "Allows for the construction of circuit boards used to build an Atmospheric Monitor."
			id = "air_management"
			req_tech = list("programming" = 2)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/circuitboard/general_air_control"

		general_alert
			name = "Circuit Design (General Alert Console)"
			desc = "Allows for the construction of circuit boards used to build a General Alert console."
			id = "general_alert"
			req_tech = list("programming" = 2)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/circuitboard/general_alert"

		robocontrol
			name = "Circuit Design (Robotics Control Console)"
			desc = "Allows for the construction of circuit boards used to build a Robotics Control console."
			id = "robocontrol"
			req_tech = list("programming" = 4)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/circuitboard/robotics"

		clonecontrol
			name = "Circuit Design (Cloning Machine Console)"
			desc = "Allows for the construction of circuit boards used to build a new Cloning Machine console."
			id = "clonecontrol"
			req_tech = list("programming" = 3, "biotech" = 3)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/circuitboard/cloning"

		arcademachine
			name = "Circuit Design (Arcade Machine)"
			desc = "Allows for the construction of circuit boards used to build a new arcade machine."
			id = "arcademachine"
			req_tech = list("programming" = 1)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/circuitboard/arcade"

		powermonitor
			name = "Circuit Design (Power Monitor)"
			desc = "Allows for the construction of circuit boards used to build a new power monitor"
			id = "powermonitor"
			req_tech = list("programming" = 2)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/machinery/power/monitor"

		prisonmanage
			name = "Circuit Design (Prisoner Management Console)"
			desc = "Allows for the construction of circuit boards used to build a prisoner management console."
			id = "prisonmanage"
			req_tech = list("programming" = 2)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/circuitboard/prisoner"

///////////////////////////////////
//////////AI Module Disks//////////
///////////////////////////////////
		safeguard_module
			name = "Module Design (Safeguard)"
			desc = "Allows for the construction of a Safeguard AI Module."
			id = "safeguard_module"
			req_tech = list("programming" = 3)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/aiModule/safeguard"

		onehuman_module
			name = "Module Design (OneHuman)"
			desc = "Allows for the construction of a OneHuman AI Module."
			id = "onehuman_module"
			req_tech = list("programming" = 3, "syndicate" = 2)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/aiModule/oneHuman"

		protectstation_module
			name = "Module Design (ProtectStation)"
			desc = "Allows for the construction of a ProtectStation AI Module."
			id = "protectstation_module"
			req_tech = list("programming" = 3)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/aiModule/protectStation"

		notele_module
			name = "Module Design (TeleporterOffline Module)"
			desc = "Allows for the construction of a TeleporterOffline AI Module."
			id = "notele_module"
			req_tech = list("programming" = 3)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/aiModule/teleporterOffline"

		quarantine_module
			name = "Module Design (Quarantine)"
			desc = "Allows for the construction of a Quarantine AI Module."
			id = "quarantine_module"
			req_tech = list("programming" = 3, "biotech" = 2)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/aiModule/quarantine"

		oxygen_module
			name = "Module Design (OxygenIsToxicToHumans)"
			desc = "Allows for the construction of a Safeguard AI Module."
			id = "oxygen_module"
			req_tech = list("programming" = 3, "biotech" = 2)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/aiModule/oxygen"

		freeform_module
			name = "Module Design (Freeform)"
			desc = "Allows for the construction of a Freeform AI Module."
			id = "freeform_module"
			req_tech = list("programming" = 4)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/aiModule/freeform"

		reset_module
			name = "Module Design (Reset)"
			desc = "Allows for the construction of a Reset AI Module."
			id = "reset_module"
			req_tech = list("programming" = 3)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/aiModule/reset"

		purge_module
			name = "Module Design (Purge)"
			desc = "Allows for the construction of a Purge AI Module."
			id = "purge_module"
			req_tech = list("programming" = 4)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/aiModule/purge"

		freeformcore_module
			name = "Core Module Design (Freeform)"
			desc = "Allows for the construction of a Freeform AI Core Module."
			id = "freeformcore_module"
			req_tech = list("programming" = 4)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/aiModule/freeformcore"

		asimov
			name = "Core Module Design (Asimov)"
			desc = "Allows for the construction of a Asimov AI Core Module."
			id = "asimov_module"
			req_tech = list("programming" = 3)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/aiModule/asimov"

		paladin_module
			name = "Core Module Design (P.A.L.A.D.I.N.)"
			desc = "Allows for the construction of a P.A.L.A.D.I.N. AI Core Module."
			id = "paladin_module"
			req_tech = list("programming" = 4)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/aiModule/paladin"

		tyrant_module
			name = "Core Module Design (T.Y.R.A.N.T.)"
			desc = "Allows for the construction of a T.Y.R.A.N.T. AI Module."
			id = "tyrant_module"
			req_tech = list("programming" = 4, "syndicate" = 2)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/weapon/aiModule/tyrant"

///////////////////////////////////
//////////Mecha Module Disks///////
///////////////////////////////////

		ripley_main
			name = "Circuit Design (APLU \"Ripley\" Central Control module)"
			desc = "Allows for the construction of a \"Ripley\" Central Control module."
			id = "ripley_main"
			req_tech = list("programming" = 3, "robotics" = 5)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/mecha_parts/circuitboard/ripley/main"

		ripley_peri
			name = "Circuit Design (APLU \"Ripley\" Peripherals Control module)"
			desc = "Allows for the construction of a  \"Ripley\" Peripheral Control module."
			id = "ripley_peri"
			req_tech = list("programming" = 3, "robotics" = 5)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/mecha_parts/circuitboard/ripley/peripherals"

		gygax_main
			name = "Circuit Design (\"Gygax\" Central Control module)"
			desc = "Allows for the construction of a \"Gygax\" Central Control module."
			id = "gygax_main"
			req_tech = list("programming" = 4, "robotics" = 5)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/mecha_parts/circuitboard/gygax/main"

		gygax_peri
			name = "Circuit Design (\"Gygax\" Peripherals Control module)"
			desc = "Allows for the construction of a \"Gygax\" Peripheral Control module."
			id = "gygax_peri"
			req_tech = list("programming" = 4, "robotics" = 5)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/mecha_parts/circuitboard/gygax/peripherals"

		gygax_targ
			name = "Circuit Design (\"Gygax\" Weapons & Targeting Control module)"
			desc = "Allows for the construction of a \"Gygax\" Weapons & Targeting Control module."
			id = "gygax_targ"
			req_tech = list("programming" = 4, "robotics" = 5)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/mecha_parts/circuitboard/gygax/targeting"

		honker_main
			name = "Circuit Design (\"H.O.N.K\" Central Control module)"
			desc = "Allows for the construction of a \"H.O.N.K\" Central Control module."
			id = "honker_main"
			req_tech = list("programming" = 2, "robotics" = 3)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/mecha_parts/circuitboard/honker/main"

		honker_peri
			name = "Circuit Design (\"H.O.N.K\" Peripherals Control module)"
			desc = "Allows for the construction of a \"H.O.N.K\" Peripheral Control module."
			id = "honker_peri"
			req_tech = list("programming" = 2, "robotics" = 3)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/mecha_parts/circuitboard/honker/peripherals"

		honker_targ
			name = "Circuit Design (\"H.O.N.K\" Weapons & Targeting Control module)"
			desc = "Allows for the construction of a \"H.O.N.K\" Weapons & Targeting Control module."
			id = "honker_targ"
			req_tech = list("programming" = 2, "robotics" = 3)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/item/mecha_parts/circuitboard/honker/targeting"

////////////////////////////////////////
//////////Disk Construction Disks///////
////////////////////////////////////////
		design_disk
			name = "Design Storage Disk"
			desc = "Produce additional disks for storing device designs."
			id = "design_disk"
			req_tech = list("programming" = 1)
			build_type = PROTOLATHE | AUTOLATHE
			materials = list("$metal" = 30, "$glass" = 10)
			build_path = "/obj/item/weapon/disk/design_disk"

		tech_disk
			name = "Technology Data Storage Disk"
			desc = "Produce additional disks for storing technology data."
			id = "tech_disk"
			req_tech = list("programming" = 1)
			build_type = PROTOLATHE | AUTOLATHE
			materials = list("$metal" = 30, "$glass" = 10)
			build_path = "/obj/item/weapon/disk/tech_disk"

////////////////////////////////////////
/////////////Stock Parts////////////////
////////////////////////////////////////

		basic_capacitor
			name = "Basic Capacitor"
			desc = "A stock part used in the construction of various devices."
			id = "basic_capacitor"
			req_tech = list("powerstorage" = 1)
			build_type = PROTOLATHE | AUTOLATHE
			materials = list("$metal" = 50, "$glass" = 50)
			build_path = "/obj/item/weapon/stock_parts/capacitor"

		basic_sensor
			name = "Basic Sensor Module"
			desc = "A stock part used in the construction of various devices."
			id = "basic_sensor"
			req_tech = list("magnets" = 1)
			build_type = PROTOLATHE | AUTOLATHE
			materials = list("$metal" = 50, "$glass" = 20)
			build_path = "/obj/item/weapon/stock_parts/scanning_module"

		micro_mani
			name = "Micro Manipulator"
			desc = "A stock part used in the construction of various devices."
			id = "micro_mani"
			req_tech = list("robotics" = 1)
			build_type = PROTOLATHE | AUTOLATHE
			materials = list("$metal" = 30)
			build_path = "/obj/item/weapon/stock_parts/micro_manipulator"

		basic_micro_laser
			name = "Basic Micro-Laser"
			desc = "A stock part used in the construction of various devices."
			id = "basic_micro_laser"
			req_tech = list("magnets" = 1)
			build_type = PROTOLATHE | AUTOLATHE
			materials = list("$metal" = 10, "$glass" = 20)
			build_path = "/obj/item/weapon/stock_parts/micro_laser"

		basic_matter_bin
			name = "Basic Matter Bin"
			desc = "A stock part used in the construction of various devices."
			id = "basic_matter_bin"
			req_tech = list("materials" = 1)
			build_type = PROTOLATHE | AUTOLATHE
			materials = list("$metal" = 80)
			build_path = "/obj/item/weapon/stock_parts/matter_bin"

		adv_capacitor
			name = "Advanced Capacitor"
			desc = "A stock part used in the construction of various devices."
			id = "adv_capacitor"
			req_tech = list("powerstorage" = 3)
			build_type = PROTOLATHE
			materials = list("$metal" = 50, "$glass" = 50)
			build_path = "/obj/item/weapon/stock_parts/adv_capacitor"

		adv_sensor
			name = "Advanced Sensor Module"
			desc = "A stock part used in the construction of various devices."
			id = "adv_sensor"
			req_tech = list("magnets" = 3)
			build_type = PROTOLATHE
			materials = list("$metal" = 50, "$glass" = 20)
			build_path = "/obj/item/weapon/stock_parts/adv_scanning_module"

		nano_mani
			name = "Nano Manipulator"
			desc = "A stock part used in the construction of various devices."
			id = "nano_mani"
			req_tech = list("robotics" = 3)
			build_type = PROTOLATHE
			materials = list("$metal" = 30)
			build_path = "/obj/item/weapon/stock_parts/nano_manipulator"

		high_micro_laser
			name = "High-Power Micro-Laser"
			desc = "A stock part used in the construction of various devices."
			id = "high_micro_laser"
			req_tech = list("magnets" = 3)
			build_type = PROTOLATHE
			materials = list("$metal" = 10, "$glass" = 20)
			build_path = "/obj/item/weapon/stock_parts/high_micro_laser"

		adv_matter_bin
			name = "Advanced Matter Bin"
			desc = "A stock part used in the construction of various devices."
			id = "basic_matter_bin"
			req_tech = list("materials" = 3)
			build_type = PROTOLATHE
			materials = list("$metal" = 80)
			build_path = "/obj/item/weapon/stock_parts/adv_matter_bin"

////////////////////////////////////////
//////////////////Power/////////////////
////////////////////////////////////////

		basic_cell
			name = "Basic Power Cell"
			desc = "A basic power cell that holds 1000 units of energy"
			id = "basic_cell"
			req_tech = list("powerstorage" = 1)
			build_type = PROTOLATHE | AUTOLATHE
			materials = list("$metal" = 700, "$glass" = 50)
			build_path = "/obj/item/weapon/cell"

		high_cell
			name = "High-Capacity Power Cell"
			desc = "A power cell that holds 10000 units of energy"
			id = "high_cell"
			req_tech = list("powerstorage" = 2)
			build_type = PROTOLATHE | AUTOLATHE
			materials = list("$metal" = 700, "$glass" = 60)
			build_path = "/obj/item/weapon/cell/high"

		super_cell
			name = "Super-Capacity Power Cell"
			desc = "A power cell that holds 20000 units of energy"
			id = "super_cell"
			req_tech = list("powerstorage" = 3, "materials" = 2)
			reliability_base = 75
			build_type = PROTOLATHE
			materials = list("$metal" = 700, "$glass" = 70)
			build_path = "/obj/item/weapon/cell/super"

////////////////////////////////////////
/////////Machine Frame Boards///////////
////////////////////////////////////////

		destructive_analyzer
			name = "Destructive Analyzer Board"
			desc = "The circuit board for a destructive analyzer."
			id = "destructive_analyzer"
			req_tech = list("materials" = 2, "magnets" = 2)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/machinery/r_n_d/destructive_analyzer"

		protolathe
			name = "Protolathe Board"
			desc = "The circuit board for a protolathe."
			id = "protolathe"
			req_tech = list("materials" = 3)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/machinery/r_n_d/protolathe"

		circuit_imprinter
			name = "Circuit Imprinter Board"
			desc = "The circuit board for a circuit imprinter."
			id = "circuit_imprinter"
			req_tech = list("materials" = 2)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/machinery/r_n_d/circuit_imprinter"

		protolathe
			name = "Protolathe Board"
			desc = "The circuit board for a autolathe."
			id = "autolathe"
			req_tech = list("materials" = 2)
			build_type = IMPRINTER
			materials = list("$glass" = 2000, "acid" = 20)
			build_path = "/obj/machinery/autolathe"

/////////////////////////////////////////
//////////////////Test///////////////////
/////////////////////////////////////////

	/*	test
			name = "Test Design"
			desc = "A design to test the new protolathe."
			id = "protolathe_test"
			build_type = PROTOLATHE
			req_tech = list("materials" = 1)
			materials = list("$gold" = 3000, "iron" = 15, "copper" = 10, "$silver" = 2500)
			build_path = "/obj/item/weapon/banhammer" */

////////////////////////////////////////
//Disks for transporting design datums//
////////////////////////////////////////

/obj/item/weapon/disk/design_disk
	name = "Component Design Disk"
	desc = "A disk for storing device design data for construction in lathes."
	icon = 'cloning.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = 1.0
	m_amt = 30
	g_amt = 10
	var/datum/design/blueprint
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)