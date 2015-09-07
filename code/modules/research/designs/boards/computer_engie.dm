//Engineering related computer & console boards.

/datum/design/atmosalerts
	name = "Circuit Design (Atmosphere Alert)"
	desc = "Allows for the construction of circuit boards used to build an atmosphere alert console.."
	id = "atmosalerts"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/atmos_alert

/datum/design/air_management
	name = "Circuit Design (Atmospheric General Monitor)"
	desc = "Allows for the construction of circuit boards used to build an Atmospheric General Monitor."
	id = "air_management"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/air_management

/datum/design/atmos_automation
	name = "Circuit Design (Atmospherics Automation Console)"
	desc = "Allows for the construction of circuit boards used to build an Atmospherics Automation Console"
	id = "atmos_automation"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/atmos_automation

/datum/design/large_tank_control
	name = "Circuit Design (Atmospheric Tank Control)"
	desc = "Allows for the construction of circuit boards used to build an Atmospheric Tank Control."
	id = "large_tank_control"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/large_tank_control

/* Uncomment if someone makes these buildable
/datum/design/general_alert
	name = "Circuit Design (General Alert Console)"
	desc = "Allows for the construction of circuit boards used to build a General Alert console."
	id = "general_alert"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/general_alert
*/

/datum/design/powermonitor
	name = "Circuit Design (Power Monitor)"
	desc = "Allows for the construction of circuit boards used to build a new power monitor"
	id = "powermonitor"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/powermonitor

/datum/design/solarcontrol
	name = "Circuit Design (Solar Control)"
	desc = "Allows for the construction of circuit boards used to build a solar control console"
	id = "solarcontrol"
	req_tech = list("programming" = 2, "powerstorage" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/solar_control

//Tcomms

/datum/design/comm_monitor
	name = "Circuit Design (Telecommunications Monitoring Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunications monitor."
	id = "comm_monitor"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/comm_monitor

/datum/design/comm_server
	name = "Circuit Design (Telecommunications Server Monitoring Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunication server browser and monitor."
	id = "comm_server"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/comm_server

/datum/design/traffic_control
	name = "Circuit Design (Telecommunications Traffic Control Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunications traffic control console."
	id = "traffic_control"
	req_tech = list("programming" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/comm_traffic

/datum/design/message_monitor
	name = "Circuit Design (Messaging Monitor Console)"
	desc = "Allows for the construction of circuit boards used to build a messaging monitor console."
	id = "message_monitor"
	req_tech = list("programming" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/message_monitor

//Best engine (design wise)

/datum/design/rust_gyrotron_control
	name = "Circuit Design (R-UST Mk. 7 gyrotron controller)"
	desc = "Allows for the construction of circuit boards used to build a gyrotron control console for the R-UST Mk. 7 fusion engine."
	id = "rust_gyrotron_control"
	req_tech = list("programming" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Misc"
	build_path = "/obj/item/weapon/circuitboard/rust_gyrotron_control"

/datum/design/rust_fuel_control
	name = "Circuit Design (R-UST Mk. 7 fuel controller)"
	desc = "Allows for the construction of circuit boards used to build a fuel injector control console for the R-UST Mk. 7 fusion engine."
	id = "rust_fuel_control"
	req_tech = list("programming" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Misc"
	build_path = "/obj/item/weapon/circuitboard/rust_fuel_control"

/datum/design/rust_core_monitor
	name = "Circuit Design (R-UST Mk. 7 core monitor)"
	desc = "Allows for the construction of circuit boards used to build a core monitoring console for the R-UST Mk. 7 fusion engine."
	id = "rust_core_monitor"
	req_tech = list("programming" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Misc"
	build_path = "/obj/item/weapon/circuitboard/rust_core_monitor"

/datum/design/rust_core_control
	name = "Circuit Design (R-UST Mk. 7 core controller)"
	desc = "Allows for the construction of circuit boards used to build a core control console for the R-UST Mk. 7 fusion engine."
	id = "rust_core_control"
	req_tech = list("programming" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Misc"
	build_path = "/obj/item/weapon/circuitboard/rust_core_control"
