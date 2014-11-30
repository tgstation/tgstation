//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/***************************************************************
**						Design Datums						  **
**	All the data for building stuff and tracking reliability. **
***************************************************************/
/*
For the materials datum, it assumes you need reagents unless specified otherwise. To designate a material that isn't a reagent,
you use one of the material IDs below. These are NOT ids in the usual sense (they aren't defined in the object or part of a datum),
they are simply references used as part of a "has materials?" type proc. They all start with a $ to denote that they aren't reagents.
The currently supporting non-reagent materials:
- $iron (/obj/item/stack/metal). One sheet = 3750 units. NB: do not use $metal. It is outdated and will cause issues
- $glass (/obj/item/stack/glass). One sheet = 3750 units.
- $plasma (/obj/item/stack/plasma). One sheet = 3750 units.
- $silver (/obj/item/stack/silver). One sheet = 3750 units.
- $gold (/obj/item/stack/gold). One sheet = 3750 units.
- $uranium (/obj/item/stack/uranium). One sheet = 3750 units.
- $diamond (/obj/item/stack/diamond). One sheet = 3750 units.
- $clown (/obj/item/stack/clown). One sheet = 3750 units. ("Bananium")
(Insert new ones here)

Don't add new keyword/IDs if they are made from an existing one (such as rods which are made from metal). Only add raw materials.

Design Guidlines
- The reliability formula for all R&D built items is reliability_base (a fixed number) + total tech levels required to make it +
reliability_mod (starts at 0, gets improved through experimentation). Example: PACMAN generator. 79 base reliablity + 6 tech
(3 plasmatech, 3 powerstorage) + 0 (since it's completely new) = 85% reliability. Reliability is the chance it works CORRECTLY.
- When adding new designs, check rdreadme.dm to see what kind of things have already been made and where new stuff is needed.
- A single sheet of anything is 3750 units of material. Materials besides metal/glass require help from other jobs (mining for
other types of metals and chemistry for reagents).
- Add the AUTOLATHE tag to


*/
#define	IMPRINTER	1	//For circuits. Uses glass/chemicals.
#define PROTOLATHE	2	//New stuff. Uses glass/metal/chemicals
#define	AUTOLATHE	4	//Uses glass/metal only.
#define CRAFTLATHE	8	//Uses fuck if I know. For use eventually.
#define MECHFAB		16  //Remember, objects built under fabricators need DESIGNS
#define PODFAB		32  //Used by the spacepod part fabricator. Same idea as the mechfab
//Note: More then one of these can be added to a design but imprinter and lathe designs are incompatable.

/datum/design						//Datum for object designs, used in construction
	var/name = "Name"					//Name of the created object.
	var/desc = "Desc"					//Description of the created object.
	var/id = "id"						//ID of the created object for easy refernece. Alphanumeric, lower-case, no symbols
	var/list/req_tech = list()			//IDs of that techs the object originated from and the minimum level requirements.
	var/reliability_mod = 0				//Reliability modifier of the device at it's starting point.
	var/reliability_base = 100			//Base reliability of a device before modifiers.
	var/reliability = 100				//Reliability of the device.
	var/build_type = null				//Flag as to what kind machine the design is built in. See defines.
	var/list/materials = list()			//List of materials. Format: "id" = amount.
	var/build_path = null				//The file path of the object that gets created
	var/locked = 0						//If true it will spawn inside a lockbox with currently sec access
	var/category = null //Primarily used for Mech Fabricators, but can be used for anything

/datum/design/New()
	var/list/newmats=list()
	for(var/matID in materials)
		var/nmid=matID
		if(matID == "$iron")
			nmid="$iron"
		newmats[nmid]=materials[matID]
	materials=newmats

//A proc to calculate the reliability of a design based on tech levels and innate modifiers.
//Input: A list of /datum/tech; Output: The new reliabilty.
/datum/design/proc/CalcReliability(var/list/temp_techs)
	var/new_reliability = reliability_mod + reliability_base
	for(var/datum/tech/T in temp_techs)
		if(T.id in req_tech)
			new_reliability += T.level
	new_reliability = between(reliability_base, new_reliability, 100)
	reliability = new_reliability
	return

//give it an object or a type
//if it gets passed an object, it makes it into a type
//it then finds the design which has a buildpath of that type
//confirmed to work by Comic
/datum/proc/FindDesign(var/part as anything)
	if(!ispath(part))
		var/obj/thispart = part
		part = thispart.type
	for(var/thisdesign in typesof(/datum/design))
		var/datum/design/D = thisdesign
		if(initial(D.build_path) == part)
			return D
	return

//sum of the required tech of a design
/datum/design/proc/TechTotal()
	var/total = 0
	for(var/tech in src.req_tech)
		total += src.req_tech[tech]
	return total

//sum of the required materials of a design
//do not confuse this with Total_Materials. That gets the machine's materials, this gets design materials
/datum/design/proc/MatTotal()
	var/total = 0
	for(var/matID in src.materials)
		total += src.materials[matID]
	//log_admin("[total] for [part.name]")
	return total


///////////////////Computer Boards///////////////////////////////////

/datum/design/seccamera
	name = "Circuit Design (Security Cameras)"
	desc = "Allows for the construction of circuit boards used to build security camera computers."
	id = "seccamera"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/security

/datum/design/aicore
	name = "Circuit Design (AI Core)"
	desc = "Allows for the construction of circuit boards used to build new AI cores."
	id = "aicore"
	req_tech = list("programming" = 4, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/aicore

/datum/design/aiupload
	name = "Circuit Design (AI Upload)"
	desc = "Allows for the construction of circuit boards used to build an AI Upload Console."
	id = "aiupload"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/aiupload

/datum/design/borgupload
	name = "Circuit Design (Cyborg Upload)"
	desc = "Allows for the construction of circuit boards used to build a Cyborg Upload Console."
	id = "borgupload"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/borgupload

/datum/design/med_data
	name = "Circuit Design (Medical Records)"
	desc = "Allows for the construction of circuit boards used to build a medical records console."
	id = "med_data"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/med_data

/datum/design/operating
	name = "Circuit Design (Operating Computer)"
	desc = "Allows for the construction of circuit boards used to build an operating computer console."
	id = "operating"
	req_tech = list("programming" = 2, "biotech" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/operating

/datum/design/pandemic
	name = "Circuit Design (PanD.E.M.I.C. 2200)"
	desc = "Allows for the construction of circuit boards used to build a PanD.E.M.I.C. 2200 console."
	id = "pandemic"
	req_tech = list("programming" = 2, "biotech" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pandemic

/datum/design/cryo
	name = "Cicrcuit Design (Cryo)"
	desc = "Allows for the construction of circuit boards used to build a Cryo Cell."
	id = "cryo"
	req_tech = list("programming" = 4, "biotech" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cryo

/datum/design/chem_dispenser
	name = "Circuit Design (Chemistry Dispenser)"
	desc = "Allows for the construction of circuit boards used to build a Chemistry Dispenser"
	id = "chem_dispenser"
	req_tech = list("programming" = 3, "biotech" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/chem_dispenser

/datum/design/scan_console
	name = "Circuit Design (DNA Machine)"
	desc = "Allows for the construction of circuit boards used to build a new DNA scanning console."
	id = "scan_console"
	req_tech = list("programming" = 2, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/scan_consolenew

/datum/design/comconsole
	name = "Circuit Design (Communications)"
	desc = "Allows for the construction of circuit boards used to build a communications console."
	id = "comconsole"
	req_tech = list("programming" = 2, "magnets" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/communications

/datum/design/idcardconsole
	name = "Circuit Design (ID Computer)"
	desc = "Allows for the construction of circuit boards used to build an ID computer."
	id = "idcardconsole"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/card

/datum/design/crewconsole
	name = "Circuit Design (Crew monitoring computer)"
	desc = "Allows for the construction of circuit boards used to build a Crew monitoring computer."
	id = "crewconsole"
	req_tech = list("programming" = 3, "magnets" = 2, "biotech" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/crew

/datum/design/teleconsole
	name = "Circuit Design (Teleporter Console)"
	desc = "Allows for the construction of circuit boards used to build a teleporter control console."
	id = "teleconsole"
	req_tech = list("programming" = 3, "bluespace" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter

/datum/design/secdata
	name = "Circuit Design (Security Records Console)"
	desc = "Allows for the construction of circuit boards used to build a security records console."
	id = "secdata"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/secure_data

/datum/design/atmosalerts
	name = "Circuit Design (Atmosphere Alert)"
	desc = "Allows for the construction of circuit boards used to build an atmosphere alert console.."
	id = "atmosalerts"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/atmos_alert

/datum/design/air_management
	name = "Circuit Design (Atmospheric General Monitor)"
	desc = "Allows for the construction of circuit boards used to build an Atmospheric General Monitor."
	id = "air_management"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/air_management

/datum/design/atmos_automation
	name = "Circuit Design (Atmospherics Automation Console)"
	desc = "Allows for the construction of circuit boards used to build an Atmospherics Automation Console"
	id = "atmos_automation"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/atmos_automation

/datum/design/large_tank_control
	name = "Circuit Design (Atmospheric Tank Control)"
	desc = "Allows for the construction of circuit boards used to build an Atmospheric Tank Control."
	id = "large_tank_control"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/large_tank_control

/* Uncomment if someone makes these buildable
/datum/design/general_alert
	name = "Circuit Design (General Alert Console)"
	desc = "Allows for the construction of circuit boards used to build a General Alert console."
	id = "general_alert"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/general_alert
*/

/datum/design/robocontrol
	name = "Circuit Design (Robotics Control Console)"
	desc = "Allows for the construction of circuit boards used to build a Robotics Control console."
	id = "robocontrol"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/robotics

/datum/design/recharge_station
	name = "Circuit Design (Cyborg Recharging Station)"
	desc = "Allows for the construction of circuit boards used to build a Cyborg Recharging Station."
	id = "recharge_station"
	req_tech = list("programming" = 4, "powerstorage" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/recharge_station

/datum/design/smes
	name = "Circuit Design (SMES) "
	desc = "Allows for the construction of circuit boards used to build SMES Power Storage Units"
	id="smes"
	req_tech = list("powerstorage" = 4, "engineering" = 4, "programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/smes

/datum/design/defib_recharger
	name = "Circuit Design (Defib Recharger)"
	desc = "Allows for the construction of circuit boards used to build Defib Rechargers"
	id="defib_recharger"
	req_tech = list("powerstorage" = 2, "engineering" = 2, "programming" = 3, "biotech" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/defib_recharger

/datum/design/photocopier
	name = "Circuit Design (Photocopier)"
	desc = "Allows for the construction of circuit boards to build photocopiers"
	id = "photocopier"
	req_tech = list ("powerstorage" = 2, "engineering" = 2, "programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/photocopier

/datum/design/freezer
	name = "Circuit Design (Freezer)"
	desc = "Allows for the construction of circuit boards to build freezers."
	id = "freezer"
	req_tech = list("powerstorage" = 3, "engineering" = 4, "biotech" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/freezer

/datum/design/heater
	name = "Circuit Design (Heater)"
	desc = "Allows for the construction of circuit boards to build heaters."
	id ="heater"
	req_tech = list("powerstorage" = 3, "engineering" = 5, "biotech"= 4)
	build_type = IMPRINTER
	materials = list ("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/heater

/datum/design/chemmaster3000
	name = "Circuit Design (ChemMaster 3000)"
	desc = "Allows for the cosntruction of circuit boards used to build ChemMaster 3000s"
	id="chemmaster3000"
	req_tech = list ("engineering" = 3, "biotech" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/chemmaster3000

/datum/design/condimaster
	name = "Circuit Design (CondiMaster)"
	desc = "Allows for the cosntruction of circuit boards used to build CondiMasters"
	id="condimaster"
	req_tech = list ("engineering" = 3, "biotech" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/condimaster

/datum/design/snackbarmachine
	name = "Circuit Design (SnackBar Machine)"
	desc = "Allows for the cosntruction of circuit boards used to build SnackBar Machines"
	id="snackbarmachine"
	req_tech = list ("engineering" = 3, "biotech" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/snackbar_machine

/datum/design/clonecontrol
	name = "Circuit Design (Cloning Machine Console)"
	desc = "Allows for the construction of circuit boards used to build a new Cloning Machine console."
	id = "clonecontrol"
	req_tech = list("programming" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cloning

/datum/design/clonepod
	name = "Circuit Design (Clone Pod)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Pod."
	id = "clonepod"
	req_tech = list("programming" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/clonepod

/datum/design/clonescanner
	name = "Circuit Design (Cloning Scanner)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Scanner."
	id = "clonescanner"
	req_tech = list("programming" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/clonescanner

/datum/design/arcademachine
	name = "Circuit Design (Arcade Machine)"
	desc = "Allows for the construction of circuit boards used to build a new arcade machine."
	id = "arcademachine"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/arcade

/datum/design/powermonitor
	name = "Circuit Design (Power Monitor)"
	desc = "Allows for the construction of circuit boards used to build a new power monitor"
	id = "powermonitor"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/powermonitor

/datum/design/apc_board
	name = "Circuit Design (Power Control Module)"
	desc = "Allows for the construction of circuit boards used to build a new APC"
	id = "apc_board"
	req_tech = list("powerstorage"=2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/module/power_control

/datum/design/solarcontrol
	name = "Circuit Design (Solar Control)"
	desc = "Allows for the construction of circuit boards used to build a solar control console"
	id = "solarcontrol"
	req_tech = list("programming" = 2, "powerstorage" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/solar_control

/datum/design/prisonmanage
	name = "Circuit Design (Prisoner Management Console)"
	desc = "Allows for the construction of circuit boards used to build a prisoner management console."
	id = "prisonmanage"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/prisoner

/datum/design/mechacontrol
	name = "Circuit Design (Exosuit Control Console)"
	desc = "Allows for the construction of circuit boards used to build an exosuit control console."
	id = "mechacontrol"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha_control

/datum/design/mechapower
	name = "Circuit Design (Mech Bay Power Control Console)"
	desc = "Allows for the construction of circuit boards used to build a mech bay power control console."
	id = "mechapower"
	req_tech = list("programming" = 2, "powerstorage" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mech_bay_power_console

/datum/design/rdconsole
	name = "Circuit Design (Core R&D Console)"
	desc = "Allows for the construction of circuit boards used to build a new R&D console."
	id = "rdconsole_core"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdconsole

/datum/design/rdconsole/robotics
	name = "Circuit Design (Robotics R&D Console)"
	id = "rdconsole_robotics"
	build_path = /obj/item/weapon/circuitboard/rdconsole/robotics

/datum/design/rdconsole/robotics
	name = "Circuit Design (Mechanic R&D Console)"
	id = "rdconsole_mechanic"
	build_path = /obj/item/weapon/circuitboard/rdconsole/mechanic

/datum/design/rdconsole/mommi
	name = "Circuit Design (MoMMI R&D Console)"
	id = "rdconsole_mommi"
	build_path = /obj/item/weapon/circuitboard/rdconsole/mommi

/datum/design/ordercomp
	name = "Circuit Design (Supply ordering console)"
	desc = "Allows for the construction of circuit boards used to build a Supply ordering console."
	id = "ordercomp"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/ordercomp

/datum/design/supplycomp
	name = "Circuit Design (Supply shuttle console)"
	desc = "Allows for the construction of circuit boards used to build a Supply shuttle console."
	id = "supplycomp"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/supplycomp

/datum/design/mining
	name = "Circuit Design (Outpost Status Display)"
	desc = "Allows for the construction of circuit boards used to build an outpost status display console."
	id = "mining"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mining

/datum/design/comm_monitor
	name = "Circuit Design (Telecommunications Monitoring Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunications monitor."
	id = "comm_monitor"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/comm_monitor

/datum/design/comm_server
	name = "Circuit Design (Telecommunications Server Monitoring Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunication server browser and monitor."
	id = "comm_server"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/comm_server

/datum/design/traffic_control
	name = "Circuit Design (Telecommunications Traffic Control Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunications traffic control console."
	id = "traffic_control"
	req_tech = list("programming" = 5)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/comm_traffic

/datum/design/message_monitor
	name = "Circuit Design (Messaging Monitor Console)"
	desc = "Allows for the construction of circuit boards used to build a messaging monitor console."
	id = "message_monitor"
	req_tech = list("programming" = 5)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/message_monitor

/datum/design/aifixer
	name = "Circuit Design (AI Integrity Restorer)"
	desc = "Allows for the construction of circuit boards used to build an AI Integrity Restorer."
	id = "aifixer"
	req_tech = list("programming" = 3, "biotech" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/aifixer

/datum/design/pipedispenser
	name = "Circuit Design (Pipe Dispenser)"
	desc = "Allows for the construction of circuit boards used to build a Pipe Dispenser."
	id = "pipedispenser"
	req_tech = list("programming" = 3, "materials" = 3,"engineering" = 2, "powerstorage" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pipedispenser

/datum/design/pipedispenser/disposal
	name = "Circuit Design (Disposal Pipe Dispenser)"
	desc = "Allows for the construction of circuit boards used to build a Pipe Dispenser."
	id = "dpipedispenser"
	req_tech = list("programming" = 3, "materials" = 3,"engineering" = 2, "powerstorage" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pipedispenser/disposal

/datum/design/reverse_engine
	name = "Circuit Design (Reverse Engine)"
	desc = "Allows for the construction of circuit boards used to build a Reverse Engine."
	id = "reverse_engine"
	req_tech = list("materials" = 6, "programming" = 4, "engineering"= 3, "bluespace"= 3, "powerstorage" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/reverse_engine

/datum/design/blueprinter
	name = "Circuit Design (Blueprint Printer)"
	desc = "Allows for the construction of circuit boards used to build a Blueprint Printer."
	id = "blueprinter"
	req_tech = list("engineering" = 3, "programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/blueprinter

/datum/design/general_fab
	name = "Circuit Design (General Fabricator)"
	desc = "Allows for the construction of circuit boards used to build a General Fabricator."
	id = "gen_fab"
	req_tech = list("materials" = 3, "engineering" = 2, "programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/generalfab

/datum/design/flatpacker
	name = "Circuit Design (Flatpack Fabricator)"
	desc = "Allows for the construction of circuit boards used to build a Flatpack Fabricator."
	id = "flatpacker"
	req_tech = list("materials" = 5, "engineering" = 4, "powerstorage" = 3, "programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/flatpacker

///////////////////////////////////
//////////AI Module Disks//////////
///////////////////////////////////
/datum/design/safeguard_module
	name = "Module Design (Safeguard)"
	desc = "Allows for the construction of a Safeguard AI Module."
	id = "safeguard_module"
	req_tech = list("programming" = 3, "materials" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$gold" = 100)
	build_path = /obj/item/weapon/aiModule/targetted/safeguard

/datum/design/onehuman_module
	name = "Module Design (OneHuman)"
	desc = "Allows for the construction of a OneHuman AI Module."
	id = "onehuman_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/targetted/oneHuman

/datum/design/protectstation_module
	name = "Module Design (ProtectStation)"
	desc = "Allows for the construction of a ProtectStation AI Module."
	id = "protectstation_module"
	req_tech = list("programming" = 3, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$gold" = 100)
	build_path = /obj/item/weapon/aiModule/standard/protectStation

/datum/design/notele_module
	name = "Module Design (TeleporterOffline Module)"
	desc = "Allows for the construction of a TeleporterOffline AI Module."
	id = "notele_module"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$gold" = 100)
	build_path = /obj/item/weapon/aiModule/standard/teleporterOffline

/datum/design/quarantine_module
	name = "Module Design (Quarantine)"
	desc = "Allows for the construction of a Quarantine AI Module."
	id = "quarantine_module"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$gold" = 100)
	build_path = /obj/item/weapon/aiModule/standard/quarantine

/datum/design/oxygen_module
	name = "Module Design (OxygenIsToxicToHumans)"
	desc = "Allows for the construction of a Safeguard AI Module."
	id = "oxygen_module"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$gold" = 100)
	build_path = /obj/item/weapon/aiModule/standard/oxygen

/datum/design/freeform_module
	name = "Module Design (Freeform)"
	desc = "Allows for the construction of a Freeform AI Module."
	id = "freeform_module"
	req_tech = list("programming" = 4, "materials" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$gold" = 100)
	build_path = /obj/item/weapon/aiModule/freeform

/datum/design/reset_module
	name = "Module Design (Reset)"
	desc = "Allows for the construction of a Reset AI Module."
	id = "reset_module"
	req_tech = list("programming" = 3, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$gold" = 100)
	build_path = /obj/item/weapon/aiModule/reset

/datum/design/purge_module
	name = "Module Design (Purge)"
	desc = "Allows for the construction of a Purge AI Module."
	id = "purge_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/purge

/datum/design/freeformcore_module
	name = "Core Module Design (Freeform)"
	desc = "Allows for the construction of a Freeform AI Core Module."
	id = "freeformcore_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/freeform/core

/datum/design/asimov
	name = "Core Module Design (Asimov)"
	desc = "Allows for the construction of a Asimov AI Core Module."
	id = "asimov_module"
	req_tech = list("programming" = 3, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/core/asimov

/datum/design/paladin_module
	name = "Core Module Design (P.A.L.A.D.I.N.)"
	desc = "Allows for the construction of a P.A.L.A.D.I.N. AI Core Module."
	id = "paladin_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/core/paladin

/datum/design/tyrant_module
	name = "Core Module Design (T.Y.R.A.N.T.)"
	desc = "Allows for the construction of a T.Y.R.A.N.T. AI Module."
	id = "tyrant_module"
	req_tech = list("programming" = 4, "syndicate" = 2, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/core/tyrant

///////////////////////////////////
/////Subspace Telecomms////////////
///////////////////////////////////
/datum/design/subspace_receiver
	name = "Circuit Design (Subspace Receiver)"
	desc = "Allows for the construction of Subspace Receiver equipment."
	id = "s-receiver"
	req_tech = list("programming" = 4, "engineering" = 3, "bluespace" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/receiver

/datum/design/telecomms_bus
	name = "Circuit Design (Bus Mainframe)"
	desc = "Allows for the construction of Telecommunications Bus Mainframes."
	id = "s-bus"
	req_tech = list("programming" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/bus

/datum/design/telecomms_hub
	name = "Circuit Design (Hub Mainframe)"
	desc = "Allows for the construction of Telecommunications Hub Mainframes."
	id = "s-hub"
	req_tech = list("programming" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/hub

/datum/design/telecomms_relay
	name = "Circuit Design (Relay Mainframe)"
	desc = "Allows for the construction of Telecommunications Relay Mainframes."
	id = "s-relay"
	req_tech = list("programming" = 3, "engineering" = 4, "bluespace" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/relay

/datum/design/telecomms_processor
	name = "Circuit Design (Processor Unit)"
	desc = "Allows for the construction of Telecommunications Processor equipment."
	id = "s-processor"
	req_tech = list("programming" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/processor

/datum/design/telecomms_server
	name = "Circuit Design (Server Mainframe)"
	desc = "Allows for the construction of Telecommunications Servers."
	id = "s-server"
	req_tech = list("programming" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/server

/datum/design/subspace_broadcaster
	name = "Circuit Design (Subspace Broadcaster)"
	desc = "Allows for the construction of Subspace Broadcasting equipment."
	id = "s-broadcaster"
	req_tech = list("programming" = 4, "engineering" = 4, "bluespace" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/broadcaster

/datum/design/bioprinter
	name = "Circuit Design (Bioprinter)"
	desc = "Allows for the construction of Bioprinter equipment."
	id = "s-bioprinter"
	req_tech = list("programming" = 3, "engineering" = 2, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/bioprinter


///////////////////////////////////
/////Non-Board Computer Stuff//////
///////////////////////////////////

/datum/design/intellicard
	name = "Intellicard AI Transportation System"
	desc = "Allows for the construction of an intellicard."
	id = "intellicard"
	req_tech = list("programming" = 4, "materials" = 4)
	build_type = PROTOLATHE
	materials = list("$glass" = 1000, "$gold" = 200)
	build_path = /obj/item/device/aicard

/datum/design/paicard
	name = "Personal Artificial Intelligence Card"
	desc = "Allows for the construction of a pAI Card"
	id = "paicard"
	req_tech = list("programming" = 2)
	build_type = PROTOLATHE
	materials = list("$glass" = 500, "$iron" = 500)
	build_path = /obj/item/device/paicard

/datum/design/posibrain
	name = "Positronic Brain"
	desc = "Allows for the construction of a positronic brain"
	id = "posibrain"
	req_tech = list("engineering" = 4, "materials" = 6, "bluespace" = 2, "programming" = 4)

	build_type = PROTOLATHE
	materials = list("$iron" = 2000, "$glass" = 1000, "$silver" = 1000, "$gold" = 500, "$plasma" = 500, "$diamond" = 100)
	build_path = /obj/item/device/mmi/posibrain

/datum/design/np_dispenser
	name = "Nano Paper Dispenser"
	desc = "A machine to create Nano Paper"
	id = "np_dispenser"
	req_tech = list("programming" = 2, "materials" = 2)
	build_type = PROTOLATHE
	materials = list("$glass" = 500, "$iron" = 1000, "$gold" = 500)
	build_path = /obj/item/weapon/paper_bin/nano

///////////////////////////////////
//////////Mecha Module Disks///////
///////////////////////////////////

/datum/design/ripley_main
	name = "Circuit Design (APLU \"Ripley\" Central Control module)"
	desc = "Allows for the construction of a \"Ripley\" Central Control module."
	id = "ripley_main"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/ripley/main

/datum/design/ripley_peri
	name = "Circuit Design (APLU \"Ripley\" Peripherals Control module)"
	desc = "Allows for the construction of a  \"Ripley\" Peripheral Control module."
	id = "ripley_peri"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/ripley/peripherals

/datum/design/odysseus_main
	name = "Circuit Design (\"Odysseus\" Central Control module)"
	desc = "Allows for the construction of a \"Odysseus\" Central Control module."
	id = "odysseus_main"
	req_tech = list("programming" = 3,"biotech" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/odysseus/main

/datum/design/odysseus_peri
	name = "Circuit Design (\"Odysseus\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Odysseus\" Peripheral Control module."
	id = "odysseus_peri"
	req_tech = list("programming" = 3,"biotech" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/odysseus/peripherals

/datum/design/phazon_main
	name = "Circuit Design (\"Phazon\" Central Control module)"
	desc = "Allows for the construction of a \"Phazon\" Central Control module."
	id = "phazon_main"
	req_tech = list("materials" = 9,"bluespace" = 10)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/phazon/main

/datum/design/phazon_peri
	name = "Circuit Design (\"Phazon\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Phazon\" Peripheral Control module."
	id = "phazon_peri"
	req_tech = list("materials" = 9,"bluespace" = 10)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/phazon/peripherals

/datum/design/phazon_phase_array
	name = "Phazon Phase Array"
	desc = "Show physics who's boss."
	id = "phazon_phasearray"
	req_tech = list("bluespace" = 10, "programming" = 4)
	build_type = MECHFAB
	materials = list("$iron" = 5000, "$phazon" = 2000)
	category = "Exosuit_Equipment"
	build_path = /obj/item/mecha_parts/part/phazon_phase_array

/datum/design/gygax_main
	name = "Circuit Design (\"Gygax\" Central Control module)"
	desc = "Allows for the construction of a \"Gygax\" Central Control module."
	id = "gygax_main"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/gygax/main

/datum/design/gygax_peri
	name = "Circuit Design (\"Gygax\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Gygax\" Peripheral Control module."
	id = "gygax_peri"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/gygax/peripherals

/datum/design/gygax_targ
	name = "Circuit Design (\"Gygax\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"Gygax\" Weapons & Targeting Control module."
	id = "gygax_targ"
	req_tech = list("programming" = 4, "combat" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/gygax/targeting

/datum/design/durand_main
	name = "Circuit Design (\"Durand\" Central Control module)"
	desc = "Allows for the construction of a \"Durand\" Central Control module."
	id = "durand_main"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/durand/main

/datum/design/durand_peri
	name = "Circuit Design (\"Durand\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Durand\" Peripheral Control module."
	id = "durand_peri"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/durand/peripherals

/datum/design/durand_targ
	name = "Circuit Design (\"Durand\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"Durand\" Weapons & Targeting Control module."
	id = "durand_targ"
	req_tech = list("programming" = 4, "combat" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/durand/targeting

/datum/design/honker_main
	name = "Circuit Design (\"H.O.N.K\" Central Control module)"
	desc = "Allows for the construction of a \"H.O.N.K\" Central Control module."
	id = "honker_main"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/honker/main

/datum/design/honker_peri
	name = "Circuit Design (\"H.O.N.K\" Peripherals Control module)"
	desc = "Allows for the construction of a \"H.O.N.K\" Peripheral Control module."
	id = "honker_peri"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/honker/peripherals

/datum/design/honker_targ
	name = "Circuit Design (\"H.O.N.K\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"H.O.N.K\" Weapons & Targeting Control module."
	id = "honker_targ"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/honker/targeting

/datum/design/spacepod_main
	name = "Circuit Design (Space Pod Mainboard)"
	desc = "Allows for the construction of a Space Pod mainboard."
	id = "spacepod_main"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/pod

////////////////////////////////////////
/////////// Mecha Equpment /////////////
////////////////////////////////////////

/datum/design/mech_scattershot
	name = "Weapon Design (LBX AC 10 \"Scattershot\")"
	desc = "Allows for the construction of LBX AC 10."
	id = "mech_scattershot"
	build_type = MECHFAB
	req_tech = list("combat" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	category = "Exosuit_Equipment"
	locked = 1
	materials = list("$iron"=10000)

/datum/design/mech_lmg
	name = "Weapon Design (Ultra AC 2)"
	desc = "Allows for the construction of Ultra AC 2."
	id = "mech_lmg"
	build_type = MECHFAB
	req_tech = list("combat" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	category = "Exosuit_Equipment"
	locked = 1
	materials = list("$iron"=10000)

/datum/design/mech_taser
	name = "Weapon Design (PBT \"Pacifier\" Taser)"
	desc = "Allows for the construction of PBT \"Pacifier\" mounted taser."
	id = "mech_taser"
	build_type = MECHFAB
	req_tech = list("combat" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/taser
	category = "Exosuit_Equipment"
	locked = 1
	materials = list("$iron"=10000)

/datum/design/mech_honker
	name = "Weapon Design (HoNkER BlAsT 5000)"
	desc = "Allows for the construction of HoNkER BlAsT 5000."
	id = "mech_honker"
	build_type = MECHFAB
	req_tech = list("combat" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/honker
	category = "Exosuit_Equipment"
	materials = list("$iron"=20000,"$clown"=10000)

/datum/design/mech_mousetrap
	name = "Weapon Design (Mousetrap Mortar)"
	desc = "Allows for the construction of Mousetrap Mortar."
	id = "mech_mousetrap"
	build_type = MECHFAB
	req_tech = list("combat" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar
	category = "Exosuit_Equipment"
	materials = list("$iron"=20000,"$clown"=5000)

/datum/design/mech_banana
	name = "Weapon Design (Banana Mortar)"
	desc = "Allows for the construction of Banana Mortar."
	id = "mech_banana"
	build_type = MECHFAB
	req_tech = list("combat" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar
	category = "Exosuit_Equipment"
	materials = list("$iron"=20000,"$clown"=5000)

/datum/design/mech_bolas
	name = "Weapon Design (PCMK-6 Bolas Launcher)"
	desc = "Allows for the construction of PCMK-6 Bolas Launcher."
	id = "mech_bolas"
	build_type = MECHFAB
	req_tech = list("combat" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bolas
	category = "Exosuit_Equipment"
	locked = 1
	materials = list("$iron"=20000)

/datum/design/mech_laser
	name = "Weapon Design (CH-PS \"Immolator\" Laser)"
	desc = "Allows for the construction of CH-PS Laser."
	id = "mech_laser"
	build_type = MECHFAB
	req_tech = list("combat" = 3, "magnets" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	category = "Exosuit_Equipment"
	locked = 1
	materials = list("$iron"=10000)

/datum/design/mech_laser_heavy
	name = "Weapon Design (CH-LC \"Solaris\" Laser Cannon)"
	desc = "Allows for the construction of CH-LC Laser Cannon."
	id = "mech_laser_heavy"
	build_type = MECHFAB
	req_tech = list("combat" = 4, "magnets" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	category = "Exosuit_Equipment"
	locked = 1
	materials = list("$iron"=10000)

/datum/design/mech_grenade_launcher
	name = "Weapon Design (SGL-6 Grenade Launcher)"
	desc = "Allows for the construction of SGL-6 Grenade Launcher."
	id = "mech_grenade_launcher"
	build_type = MECHFAB
	req_tech = list("combat" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	category = "Exosuit_Equipment"
	locked = 1
	materials = list("$iron"=10000)

/datum/design/clusterbang_launcher
	name = "Module Design (SOP-6 Clusterbang Launcher)"
	desc = "A weapon that violates the Geneva Convention at 6 rounds per minute"
	id = "clusterbang_launcher"
	build_type = MECHFAB
	req_tech = list("combat"= 5, "materials" = 5, "syndicate" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang/limited
	category = "Exosuit_Equipment"
	locked = 1
	materials = list("$iron"=20000,"$gold"=6000,"$uranium"=6000)

/datum/design/mech_wormhole_gen
	name = "Module Design (Localized Wormhole Generator)"
	desc = "An exosuit module that allows generating of small quasi-stable wormholes."
	id = "mech_wormhole_gen"
	build_type = MECHFAB
	req_tech = list("bluespace" = 3, "magnets" = 2)
	build_path = /obj/item/mecha_parts/mecha_equipment/wormhole_generator
	category = "Exosuit_Equipment"
	materials = list("$iron"=10000)

/datum/design/mech_teleporter
	name = "Module Design (Teleporter Module)"
	desc = "An exosuit module that allows exosuits to teleport to any position in view."
	id = "mech_teleporter"
	build_type = MECHFAB
	req_tech = list("bluespace" = 10, "magnets" = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/teleporter
	category = "Exosuit_Equipment"
	materials = list("$iron"=10000)

/datum/design/mech_rcd
	name = "Module Design (RCD Module)"
	desc = "An exosuit-mounted Rapid Construction Device."
	id = "mech_rcd"
	build_type = MECHFAB
	req_tech = list("materials" = 4, "bluespace" = 3, "magnets" = 4, "powerstorage"=4, "engineering" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/rcd
	category = "Exosuit_Equipment"
	materials = list("$iron"=30000,"$plasma"=25000,"$silver"=20000,"$gold"=20000)

/datum/design/mech_gravcatapult
	name = "Module Design (Gravitational Catapult Module)"
	desc = "An exosuit mounted Gravitational Catapult."
	id = "mech_gravcatapult"
	build_type = MECHFAB
	req_tech = list("bluespace" = 2, "magnets" = 3, "engineering" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/gravcatapult
	category = "Exosuit_Equipment"
	materials = list("$iron"=10000)

/datum/design/mech_repair_droid
	name = "Module Design (Repair Droid Module)"
	desc = "Automated Repair Droid. BEEP BOOP"
	id = "mech_repair_droid"
	build_type = MECHFAB
	req_tech = list("magnets" = 3, "programming" = 3, "engineering" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/repair_droid
	category = "Exosuit_Equipment"
	materials = list("$iron"=10000,"$gold"=1000,"$silver"=2000,"$glass"=5000)

/* MISSING
/datum/design/mech_plasma_generator
	name = "Module Design (Plasma Converter Module)"
	desc = "Exosuit-mounted plasma converter."
	id = "mech_plasma_generator"
	build_type = MECHFAB
	req_tech = list("plasmatech" = 2, "powerstorage"= 2, "engineering" = 2)
	build_path = /obj/item/mecha_parts/mecha_equipment/plasma_generator
	category = "Exosuit_Equipment"
*/

/datum/design/mech_energy_relay
	name = "Module Design (Tesla Energy Relay)"
	desc = "Tesla Energy Relay"
	id = "mech_energy_relay"
	build_type = MECHFAB
	req_tech = list("magnets" = 4, "powerstorage" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	category = "Exosuit_Equipment"
	materials = list("$iron"=10000,"$gold"=2000,"$silver"=3000,"$glass"=2000)

/datum/design/mech_ccw_armor
	name = "Module Design(Reactive Armor Booster Module)"
	desc = "Exosuit-mounted armor booster."
	id = "mech_ccw_armor"
	build_type = MECHFAB
	req_tech = list("materials" = 5, "combat" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster
	category = "Exosuit_Equipment"
	materials = list("$iron"=20000,"$silver"=5000)

/datum/design/mech_proj_armor
	name = "Module Design(Reflective Armor Booster Module)"
	desc = "Exosuit-mounted armor booster."
	id = "mech_proj_armor"
	build_type = MECHFAB
	req_tech = list("materials" = 5, "combat" = 5, "engineering"=3)
	build_path = /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	category = "Exosuit_Equipment"
	materials = list("$iron"=20000,"$gold"=5000)

/datum/design/mech_syringe_gun
	name = "Module Design(Syringe Gun)"
	desc = "Exosuit-mounted syringe gun and chemical synthesizer."
	id = "mech_syringe_gun"
	build_type = MECHFAB
	req_tech = list("materials" = 3, "biotech"=4, "magnets"=4, "programming"=3)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/syringe_gun
	category = "Exosuit_Equipment"
	materials = list("$iron"=3000,"$glass"=2000)

/datum/design/mech_drill
	name = "Module Design (Mining Drill)"
	desc = "A mech-mountable mining drill."
	id = "mech_drill"
	build_type = MECHFAB
	req_tech = list("materials" = 1, "engineering" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/drill
	category = "Exosuit_Equipment"
	materials = list("$iron"=10000)

/datum/design/mech_diamond_drill
	name = "Module Design (Diamond Mining Drill)"
	desc = "An upgraded version of the standard drill."
	id = "mech_diamond_drill"
	build_type = MECHFAB
	req_tech = list("materials" = 4, "engineering" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill
	category = "Exosuit_Equipment"
	materials = list("$iron"=10000,"$diamond"=6500)

/datum/design/mech_hydro_clamp
	name = "Module Design (Hydraulic Clamp)"
	desc = "A hydraulic clamp for lifting heavy objects."
	id = "mech_hydro_clamp"
	build_type = MECHFAB
	req_tech = list("materials" = 1, "engineering" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp
	category = "Exosuit_Equipment"
	materials = list("$iron"=10000)

/datum/design/mech_cable
	name = "Module Design (Cable Layer)"
	desc = "An automatic cable layer for mechs."
	id = "mech_cable"
	build_type = MECHFAB
	req_tech = list("engineering" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/cable_layer
	category = "Exosuit_Equipment"
	materials = list("$iron"=10000)

/datum/design/mech_extinguisher
	name = "Module Design (Extinguisher)"
	desc = "An extinguisher for mechs."
	id = "mech_extinguisher"
	build_type = MECHFAB
	req_tech = list("engineering" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/extinguisher
	category = "Exosuit_Equipment"
	materials = list("$iron"=10000)

/datum/design/mech_generator_plasma
	name = "Module Design (Plasma Generator)"
	desc = "A power generator that runs on burning plasma."
	id = "mech_generator_plasma"
	build_type = MECHFAB
	req_tech = list("engineering" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/generator
	category = "Exosuit_Equipment"
	materials = list("$iron"=10000,"$silver"=500,"$glass"=1000)

/datum/design/mech_sleeper
	name = "Module Design (Mounted Sleeper)"
	desc = "A mech-mountable sleeper for treating the ill."
	id = "mech_sleeper"
	build_type = MECHFAB
	req_tech = list("biotech" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/sleeper
	category = "Exosuit_Equipment"
	materials = list("$iron"=5000,"$glass"=10000)

/datum/design/mech_generator_nuclear
	name = "Module Design (ExoNuclear Reactor)"
	desc = "Compact nuclear reactor module"
	id = "mech_generator_nuclear"
	build_type = MECHFAB
	req_tech = list("powerstorage"= 3, "engineering" = 3, "materials" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/generator/nuclear
	category = "Exosuit_Equipment"
	materials = list("$iron"=10000,"$silver"=500,"$glass"=1000)

/datum/design/firefighter_chassis
	name = "Structure (Firefighter chassis)"
	desc = "Used to build a Ripley Firefighter chassis."
	id = "firef_chassis"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/firefighter
	category = "Exosuit_Equipment"
	materials = list("$iron"=25000)


/datum/design/mech_jail_cell
	name = "Exosuit Module Design (Mounted Jail Cell)"
	desc = "Exosuit-controlled secure holding cell"
	id = "mech_jail_cell"
	build_type = MECHFAB
	req_tech = list("biotech" = 2, "combat" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/jail
	category = "Exosuit_Equipment"
	materials = list("$iron"=7500,"$glass"=10000)

/datum/design/mech_tracker
	name = "Exosuit Tracking Device"
	desc = "Exosuit tracker, for tracking exosuits."
	id = "mech_tracker"
	build_type = MECHFAB
	req_tech = list("engineering" = 1)
	build_path = /obj/item/mecha_parts/mecha_tracking
	category = "Misc"
	materials = list("$iron"=500)


////////////////////////////////////////
//////////Disk Construction Disks///////
////////////////////////////////////////
/datum/design/design_disk
	name = "Design Storage Disk"
	desc = "Produce additional disks for storing device designs."
	id = "design_disk"
	req_tech = list("programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$iron" = 30, "$glass" = 10)
	build_path = /obj/item/weapon/disk/design_disk

/datum/design/tech_disk
	name = "Technology Data Storage Disk"
	desc = "Produce additional disks for storing technology data."
	id = "tech_disk"
	req_tech = list("programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$iron" = 30, "$glass" = 10)
	build_path = /obj/item/weapon/disk/tech_disk

////////////////////////////////////////
/////////////Stock Parts////////////////
////////////////////////////////////////

/datum/design/basic_capacitor
	name = "Basic Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "basic_capacitor"
	req_tech = list("powerstorage" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$iron" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/stock_parts/capacitor

/datum/design/basic_sensor
	//name = "Basic Sensor Module"
	name = "Basic Scanning Module" // Fixes #311
	desc = "A stock part used in the construction of various devices."
	id = "basic_sensor"
	req_tech = list("magnets" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$iron" = 50, "$glass" = 20)
	build_path = /obj/item/weapon/stock_parts/scanning_module

/datum/design/micro_mani
	name = "Micro Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "micro_mani"
	req_tech = list("materials" = 1, "programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$iron" = 30)
	build_path = /obj/item/weapon/stock_parts/manipulator

/datum/design/basic_micro_laser
	name = "Basic Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "basic_micro_laser"
	req_tech = list("magnets" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$iron" = 10, "$glass" = 20)
	build_path = /obj/item/weapon/stock_parts/micro_laser

/datum/design/basic_matter_bin
	name = "Basic Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "basic_matter_bin"
	req_tech = list("materials" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$iron" = 80)
	build_path = /obj/item/weapon/stock_parts/matter_bin

/datum/design/adv_capacitor
	name = "Advanced Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "adv_capacitor"
	req_tech = list("powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/stock_parts/capacitor/adv

/datum/design/adv_sensor
	//name = "Advanced Sensor Module"
	name = "Advanced Scanning Module" // Fixes #311
	desc = "A stock part used in the construction of various devices."
	id = "adv_sensor"
	req_tech = list("magnets" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 50, "$glass" = 20)
	build_path = /obj/item/weapon/stock_parts/scanning_module/adv

/datum/design/nano_mani
	name = "Nano Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "nano_mani"
	req_tech = list("materials" = 3, "programming" = 2)
	build_type = PROTOLATHE
	materials = list("$iron" = 30)
	build_path = /obj/item/weapon/stock_parts/manipulator/nano

/datum/design/high_micro_laser
	name = "High-Power Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "high_micro_laser"
	req_tech = list("magnets" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 10, "$glass" = 20)
	build_path = /obj/item/weapon/stock_parts/micro_laser/high

/datum/design/adv_matter_bin
	name = "Advanced Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "adv_matter_bin"
	req_tech = list("materials" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 80)
	build_path = /obj/item/weapon/stock_parts/matter_bin/adv

/datum/design/super_capacitor
	name = "Super Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "super_capacitor"
	req_tech = list("powerstorage" = 5, "materials" = 4)
	build_type = PROTOLATHE
	reliability_base = 71
	materials = list("$iron" = 50, "$glass" = 50, "$gold" = 20)
	build_path = /obj/item/weapon/stock_parts/capacitor/super

/datum/design/phasic_sensor
	//name = "Phasic Sensor Module"
	name = "Phasic Scanning Module" // Fixes #311
	desc = "A stock part used in the construction of various devices."
	id = "phasic_sensor"
	req_tech = list("magnets" = 5, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 50, "$glass" = 20, "$silver" = 10)
	reliability_base = 72
	build_path = /obj/item/weapon/stock_parts/scanning_module/phasic

/datum/design/pico_mani
	name = "Pico Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "pico_mani"
	req_tech = list("materials" = 5, "programming" = 2)
	build_type = PROTOLATHE
	materials = list("$iron" = 30)
	reliability_base = 73
	build_path = /obj/item/weapon/stock_parts/manipulator/pico

/datum/design/ultra_micro_laser
	name = "Ultra-High-Power Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "ultra_micro_laser"
	req_tech = list("magnets" = 5, "materials" = 5)
	build_type = PROTOLATHE
	materials = list("$iron" = 10, "$glass" = 20, "$uranium" = 10)
	reliability_base = 70
	build_path = /obj/item/weapon/stock_parts/micro_laser/ultra

/datum/design/super_matter_bin
	name = "Super Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "super_matter_bin"
	req_tech = list("materials" = 5)
	build_type = PROTOLATHE
	materials = list("$iron" = 80)
	reliability_base = 75
	build_path = /obj/item/weapon/stock_parts/matter_bin/super



/datum/design/subspace_ansible
	name = "Subspace Ansible"
	desc = "A compact module capable of sensing extradimensional activity."
	id = "s-ansible"
	req_tech = list("programming" = 3, "magnets" = 4, "materials" = 4, "bluespace" = 2)
	build_type = PROTOLATHE
	materials = list("$iron" = 80, "$silver" = 20)
	build_path = /obj/item/weapon/stock_parts/subspace/ansible

/datum/design/hyperwave_filter
	name = "Hyperwave Filter"
	desc = "A tiny device capable of filtering and converting super-intense radiowaves."
	id = "s-filter"
	req_tech = list("programming" = 3, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 40, "$silver" = 10)
	build_path = /obj/item/weapon/stock_parts/subspace/filter

/datum/design/subspace_amplifier
	name = "Subspace Amplifier"
	desc = "A compact micro-machine capable of amplifying weak subspace transmissions."
	id = "s-amplifier"
	req_tech = list("programming" = 3, "magnets" = 4, "materials" = 4, "bluespace" = 2)
	build_type = PROTOLATHE
	materials = list("$iron" = 10, "$gold" = 30, "$uranium" = 15)
	build_path = /obj/item/weapon/stock_parts/subspace/amplifier

/datum/design/subspace_treatment
	name = "Subspace Treatment Disk"
	desc = "A compact micro-machine capable of stretching out hyper-compressed radio waves."
	id = "s-treatment"
	req_tech = list("programming" = 3, "magnets" = 2, "materials" = 4, "bluespace" = 2)
	build_type = PROTOLATHE
	materials = list("$iron" = 10, "$silver" = 20)
	build_path = /obj/item/weapon/stock_parts/subspace/treatment

/datum/design/subspace_analyzer
	name = "Subspace Analyzer"
	desc = "A sophisticated analyzer capable of analyzing cryptic subspace wavelengths."
	id = "s-analyzer"
	req_tech = list("programming" = 3, "magnets" = 4, "materials" = 4, "bluespace" = 2)
	build_type = PROTOLATHE
	materials = list("$iron" = 10, "$gold" = 15)
	build_path = /obj/item/weapon/stock_parts/subspace/analyzer

/datum/design/subspace_crystal
	name = "Ansible Crystal"
	desc = "A sophisticated analyzer capable of analyzing cryptic subspace wavelengths."
	id = "s-crystal"
	req_tech = list("magnets" = 4, "materials" = 4, "bluespace" = 2)
	build_type = PROTOLATHE
	materials = list("$glass" = 1000, "$silver" = 20, "$gold" = 20)
	build_path = /obj/item/weapon/stock_parts/subspace/crystal

/datum/design/subspace_transmitter
	name = "Subspace Transmitter"
	desc = "A large piece of equipment used to open a window into the subspace dimension."
	id = "s-transmitter"
	req_tech = list("magnets" = 5, "materials" = 5, "bluespace" = 3)
	build_type = PROTOLATHE
	materials = list("$glass" = 100, "$silver" = 10, "$uranium" = 15)
	build_path = /obj/item/weapon/stock_parts/subspace/transmitter

////////////////////////////////////////
//////////////////Power/////////////////
////////////////////////////////////////

/datum/design/basic_cell
	name = "Basic Power Cell"
	desc = "A basic power cell that holds 1000 units of energy"
	id = "basic_cell"
	req_tech = list("powerstorage" = 1)
	build_type = PROTOLATHE | AUTOLATHE | MECHFAB | PODFAB
	materials = list("$iron" = 700, "$glass" = 50)
	build_path = /obj/item/weapon/cell
	category = "Misc"

/datum/design/high_cell
	name = "High-Capacity Power Cell"
	desc = "A power cell that holds 10000 units of energy"
	id = "high_cell"
	req_tech = list("powerstorage" = 2)
	build_type = PROTOLATHE | AUTOLATHE | MECHFAB | PODFAB
	materials = list("$iron" = 700, "$glass" = 60)
	build_path = /obj/item/weapon/cell/high
	category = "Misc"

/datum/design/super_cell
	name = "Super-Capacity Power Cell"
	desc = "A power cell that holds 20000 units of energy"
	id = "super_cell"
	req_tech = list("powerstorage" = 3, "materials" = 2)
	reliability_base = 75
	build_type = PROTOLATHE | MECHFAB | PODFAB
	materials = list("$iron" = 700, "$glass" = 70)
	build_path = /obj/item/weapon/cell/super
	category = "Misc"

/datum/design/hyper_cell
	name = "Hyper-Capacity Power Cell"
	desc = "A power cell that holds 30000 units of energy"
	id = "hyper_cell"
	req_tech = list("powerstorage" = 5, "materials" = 4)
	reliability_base = 70
	build_type = PROTOLATHE | MECHFAB | PODFAB
	materials = list("$iron" = 400, "$gold" = 150, "$silver" = 150, "$glass" = 70)
	build_path = /obj/item/weapon/cell/hyper
	category = "Misc"

/datum/design/light_replacer
	name = "Light Replacer"
	desc = "A device to automatically replace lights. Refill with working lightbulbs."
	id = "light_replacer"
	req_tech = list("magnets" = 3, "materials" = 4)
	build_type = PROTOLATHE
	materials = list("$iron" = 1500, "$silver" = 150, "$glass" = 3000)
	build_path = /obj/item/device/lightreplacer

////////////////////////////////////////
//////////////MISC Boards///////////////
////////////////////////////////////////

/datum/design/destructive_analyzer
	name = "Destructive Analyzer Board"
	desc = "The circuit board for a destructive analyzer."
	id = "destructive_analyzer"
	req_tech = list("programming" = 2, "magnets" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/destructive_analyzer

/datum/design/protolathe
	name = "Protolathe Board"
	desc = "The circuit board for a protolathe."
	id = "protolathe"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/protolathe

/datum/design/circuit_imprinter
	name = "Circuit Imprinter Board"
	desc = "The circuit board for a circuit imprinter."
	id = "circuit_imprinter"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/circuit_imprinter

/datum/design/autolathe
	name = "Autolathe Board"
	desc = "The circuit board for a autolathe."
	id = "autolathe"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/autolathe

/datum/design/rdservercontrol
	name = "R&D Server Control Console Board"
	desc = "The circuit board for a R&D Server Control Console"
	id = "rdservercontrol"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdservercontrol

/datum/design/rdserver
	name = "R&D Server Board"
	desc = "The circuit board for an R&D Server"
	id = "rdserver"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdserver

/datum/design/mechfab
	name = "Fabricator Board"
	desc = "The circuit board for an Exosuit Fabricator"
	id = "mechfab"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mechfab

/datum/design/pdapainter
	name = "PDA Painter Board"
	desc = "The circuit board for a PDA Painter."
	id = "pdapainter"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pdapainter


/////////////////////////////////////////
////////////Power Stuff//////////////////
/////////////////////////////////////////

/datum/design/pacman
	name = "PACMAN-type Generator Board"
	desc = "The circuit board that for a PACMAN-type portable generator."
	id = "pacman"
	req_tech = list("programming" = 3, "plasmatech" = 3, "powerstorage" = 3, "engineering" = 3)
	build_type = IMPRINTER
	reliability_base = 79
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pacman

/datum/design/superpacman
	name = "SUPERPACMAN-type Generator Board"
	desc = "The circuit board that for a SUPERPACMAN-type portable generator."
	id = "superpacman"
	req_tech = list("programming" = 3, "powerstorage" = 4, "engineering" = 4)
	build_type = IMPRINTER
	reliability_base = 76
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pacman/super

/datum/design/mrspacman
	name = "MRSPACMAN-type Generator Board"
	desc = "The circuit board that for a MRSPACMAN-type portable generator."
	id = "mrspacman"
	req_tech = list("programming" = 3, "powerstorage" = 5, "engineering" = 5)
	build_type = IMPRINTER
	reliability_base = 74
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pacman/mrs


/////////////////////////////////////////
////////////Medical Tools////////////////
/////////////////////////////////////////

/datum/design/bruise_pack
	name = "Roll of gauze"
	desc = "Some sterile gauze to wrap around bloody stumps."
	id = "bruise_pack"
	req_tech = list("biotech" = 1)
	build_type = PROTOLATHE
	materials = list("$iron" = 400, "$glass" = 125)
	build_path = /obj/item/stack/medical/bruise_pack

/datum/design/ointment
	name = "Ointment"
	desc = "Used to treat those nasty burns."
	id = "ointment"
	req_tech = list("biotech" = 1)
	build_type = PROTOLATHE
	materials = list("$iron" = 400, "$glass" = 125)
	build_path = /obj/item/stack/medical/ointment

/datum/design/adv_bruise_pack
	name = "Advanced trauma kit"
	desc = "Used to treat those nasty burns."
	id = "adv_bruise_pack"
	req_tech = list("biotech" = 2)
	build_type = PROTOLATHE
	materials = list("$iron" = 600, "$glass" = 250)
	build_path = /obj/item/stack/medical/advanced/bruise_pack

/datum/design/adv_ointment
	name = "Advanced burn kit"
	desc = "Used to treat those nasty burns."
	id = "adv_ointment"
	req_tech = list("biotech" = 2)
	build_type = PROTOLATHE
	materials = list("$iron" = 600, "$glass" = 250)
	build_path = /obj/item/stack/medical/advanced/ointment

/datum/design/mass_spectrometer
	name = "Mass-Spectrometer"
	desc = "A device for analyzing chemicals in the blood."
	id = "mass_spectrometer"
	req_tech = list("biotech" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list("$iron" = 30, "$glass" = 20)
	reliability_base = 76
	build_path = /obj/item/device/mass_spectrometer

/datum/design/adv_mass_spectrometer
	name = "Advanced Mass-Spectrometer"
	desc = "A device for analyzing chemicals in the blood and their quantities."
	id = "adv_mass_spectrometer"
	req_tech = list("biotech" = 2, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list("$iron" = 30, "$glass" = 20)
	reliability_base = 74
	build_path = /obj/item/device/mass_spectrometer/adv

/datum/design/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	id = "mmi"
	req_tech = list("programming" = 2, "biotech" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list("$iron" = 1000, "$glass" = 500)
	reliability_base = 76
	build_path = /obj/item/device/mmi
	category = "Misc"

/datum/design/mmi_radio
	name = "Radio-enabled Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity. This one comes with a built-in radio."
	id = "mmi_radio"
	req_tech = list("programming" = 2, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list("$iron" = 1200, "$glass" = 500)
	reliability_base = 74
	build_path = /obj/item/device/mmi/radio_enabled
	category = "Misc"

/datum/design/synthetic_flash
	name = "Synthetic Flash"
	desc = "When a problem arises, SCIENCE is the solution."
	id = "sflash"
	req_tech = list("magnets" = 3, "combat" = 2)
	build_type = MECHFAB
	materials = list("$iron" = 750, "$glass" = 750)
	reliability_base = 76
	build_path = /obj/item/device/flash/synthetic
	category = "Misc"

/datum/design/nanopaste
	name = "Nanopaste"
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	id = "nanopaste"
	req_tech = list("materials" = 4, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 7000, "$glass" = 7000)
	build_path = /obj/item/stack/nanopaste

/datum/design/robotanalyzer
	name = "Cyborg Analyzer"
	desc = "A hand-held scanner able to diagnose robotic injuries."
	id = "robotanalyzer"
	req_tech = list("magnets" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 8000, "$glass" = 2000)
	build_path = /obj/item/device/robotanalyzer

/datum/design/defibrillator
	name = "Defibrillator"
	desc = "A handheld emergency defibrillator, used to bring people back from the brink of death or put them there."
	id = "defibrillator"
	req_tech = list("magnets" = 3, "materials" = 4, "biotech" = 4)
	build_type = PROTOLATHE
	materials = list("$iron" = 9000, "$silver" = 250, "$glass" = 10000)
	build_path = /obj/item/weapon/melee/defibrillator

/datum/design/healthanalyzer
	name = "Health Analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	id = "healthanalyzer"
	req_tech = list("magnets" = 2, "biotech" = 2)
	build_type = PROTOLATHE
	materials = list ("$iron" = 1000, "$glass" = 1000)
	build_path = /obj/item/device/healthanalyzer

/////////////////////////////////////////
/////////////////Weapons/////////////////
/////////////////////////////////////////

/datum/design/nuclear_gun
	name = "Advanced Energy Gun"
	desc = "An energy gun with an experimental miniaturized reactor."
	id = "nuclear_gun"
	req_tech = list("combat" = 3, "materials" = 5, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 5000, "$glass" = 1000, "$uranium" = 500)
	reliability_base = 76
	build_path = /obj/item/weapon/gun/energy/gun/nuclear
	locked = 1

/datum/design/stunrevolver
	name = "Stun Revolver"
	desc = "The prize of the Head of Security."
	id = "stunrevolver"
	req_tech = list("combat" = 3, "materials" = 3, "powerstorage" = 2)
	build_type = PROTOLATHE
	materials = list("$iron" = 4000)
	build_path = /obj/item/weapon/gun/energy/stunrevolver
	locked = 1

/datum/design/lasercannon
	name = "Laser Cannon"
	desc = "A heavy duty laser cannon."
	id = "lasercannon"
	req_tech = list("combat" = 4, "materials" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 10000, "$glass" = 1000, "$diamond" = 2000)
	build_path = /obj/item/weapon/gun/energy/lasercannon
	locked = 1

/datum/design/xcomsquaddiearmor
	name = "Squaddie Armor"
	desc = "A set of armor good against ballistics and laser weaponry.."
	id = "xcomsquaddiearmor"
	req_tech = list("materials" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 5000, "$glass" = 1000)
	build_path = /obj/item/clothing/suit/armor/xcomsquaddie

/datum/design/xcomoriginalarmor
	name = "Original Armor"
	desc = "A set of armor good against ballistics and laser weaponry.."
	id = "xcomoriginalarmor"
	req_tech = list("materials" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 5000, "$glass" = 1000)
	build_path = /obj/item/clothing/suit/armor/xcomarmor

/datum/design/xcomplasmapistol
	name = "Plasma Pistol"
	desc = "A plasma pistol."
	id = "xcomplasmapistol"
	req_tech = list("combat" = 4, "materials" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 10000, "$glass" = 1000, "$diamond" = 1000)
	build_path = /obj/item/weapon/gun/energy/plasma/pistol
	locked = 1

/datum/design/xcomplasmarifle
	name = "Plasma Rifle"
	desc = "A plasma rifle."
	id = "xcomplasmarifle"
	req_tech = list("combat" = 4, "materials" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 10000, "$glass" = 1000, "$diamond" = 3000)
	build_path = /obj/item/weapon/gun/energy/plasma/rifle
	locked = 1

/datum/design/xcomlightplasmarifle
	name = "Light Plasma Rifle"
	desc = "A plasma rifle."
	id = "xcomlightplasmarifle"
	req_tech = list("combat" = 4, "materials" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 10000, "$glass" = 1000, "$diamond" = 2000)
	build_path = /obj/item/weapon/gun/energy/plasma/light
	locked = 1

/datum/design/xcomlaserrifle
	name = "Laser Rifle"
	desc = "A laser rifle."
	id = "xcomlaserrifle"
	req_tech = list("combat" = 4, "materials" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 10000, "$glass" = 1000, "$diamond" = 2000)
	build_path = /obj/item/weapon/gun/energy/laser/rifle
	locked = 1

/datum/design/xcomlaserpistol
	name = "Laser Pistol"
	desc = "A laser pistol."
	id = "xcomlaserpistol"
	req_tech = list("combat" = 4, "materials" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 10000, "$glass" = 1000, "$diamond" = 1000)
	build_path = /obj/item/weapon/gun/energy/laser/pistol
	locked = 1

/datum/design/xcomar
	name = "Assault Rifle"
	desc = "An Assault Rifle."
	id = "xcomar"
	req_tech = list("combat" = 4, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 10000, "$glass" = 1000)
	build_path = /obj/item/weapon/gun/projectile/automatic/xcom
	locked = 1

/datum/design/decloner
	name = "Decloner"
	desc = "Your opponent will bubble into a messy pile of goop."
	id = "decloner"
	req_tech = list("combat" = 4, "materials" = 4, "biotech" = 5, "powerstorage" = 4, "syndicate" = 3) //More reasonable
	build_type = PROTOLATHE
	materials = list("$iron" = 5000, "$gold" = 5000,"$uranium" = 10000) //, "mutagen" = 40)
	build_path = /obj/item/weapon/gun/energy/decloner

/datum/design/chemsprayer
	name = "Chem Sprayer"
	desc = "An advanced chem spraying device."
	id = "chemsprayer"
	req_tech = list("combat" = 3, "materials" = 3, "engineering" = 3, "biotech" = 2, "syndicate" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 5000, "$glass" = 1000)
	reliability_base = 100
	build_path = /obj/item/weapon/reagent_containers/spray/chemsprayer

/datum/design/rapidsyringe
	name = "Rapid Syringe Gun"
	desc = "A gun that fires many syringes."
	id = "rapidsyringe"
	req_tech = list("combat" = 3, "materials" = 3, "engineering" = 3, "biotech" = 2)
	build_type = PROTOLATHE
	materials = list("$iron" = 5000, "$glass" = 1000)
	build_path = /obj/item/weapon/gun/syringe/rapidsyringe

/datum/design/largecrossbow
	name = "Energy Crossbow"
	desc = "A weapon favoured by syndicate infiltration teams."
	id = "largecrossbow"
	req_tech = list("combat" = 4, "materials" = 5, "engineering" = 3, "biotech" = 4, "syndicate" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 5000, "$glass" = 1000, "$uranium" = 1000, "$silver" = 1000)
	build_path = /obj/item/weapon/gun/energy/crossbow/largecrossbow
	locked = 1

/datum/design/temp_gun
	name = "Temperature Gun"
	desc = "A gun that changes the body temperature of its targets."
	id = "temp_gun"
	req_tech = list("combat" = 3, "materials" = 4, "powerstorage" = 3, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list("$iron" = 5000, "$glass" = 500, "$silver" = 3000)
	build_path = /obj/item/weapon/gun/energy/temperature

/datum/design/flora_gun
	name = "Floral Somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells. Harmless to other organic life."
	id = "flora_gun"
	req_tech = list("materials" = 2, "biotech" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 2000, "$glass" = 500, "$uranium" = 500)
	build_path = /obj/item/weapon/gun/energy/floragun

/datum/design/large_grenade
	name = "Large Grenade"
	desc = "A grenade that affects a larger area and use larger containers."
	id = "large_Grenade"
	req_tech = list("combat" = 3, "materials" = 2)
	build_type = PROTOLATHE
	materials = list("$iron" = 3000)
	reliability_base = 79
	build_path = /obj/item/weapon/grenade/chem_grenade/large

/datum/design/ex_grenade
	name = "EX Grenade"
	desc = "A large grenade that is designed to hold three containers."
	id = "ex_Grenade"
	req_tech = list("combat" = 4, "materials" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list("$iron" = 3000)
	reliability_base = 79
	build_path = /obj/item/weapon/grenade/chem_grenade/exgrenade

/datum/design/smg
	name = "Submachine Gun"
	desc = "A lightweight, fast firing gun."
	id = "smg"
	req_tech = list("combat" = 4, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 8000, "$silver" = 2000, "$diamond" = 1000)
	build_path = /obj/item/weapon/gun/projectile/automatic
	locked = 1

/datum/design/ammo_9mm
	name = "Ammunition Box (9mm)"
	desc = "A box of prototype 9mm ammunition."
	id = "ammo_9mm"
	req_tech = list("combat" = 4, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 3750, "$silver" = 100)
	build_path = /obj/item/ammo_storage/box/c9mm

/datum/design/stunshell
	name = "Stun Shell"
	desc = "A stunning shell for a shotgun."
	id = "stunshell"
	req_tech = list("combat" = 3, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 4000)
	build_path = /obj/item/ammo_casing/shotgun/stunshell

/datum/design/pneumatic
	name = "Pneumatic Cannon"
	desc = "A launcher powered by compressed air."
	id = "pneumatic"
	req_tech = list("materials" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 12000)
	build_path = /obj/item/weapon/storage/pneumatic

/////////////////////////////////////////
/////////////////Mining//////////////////
/////////////////////////////////////////

/datum/design/jackhammer
	name = "Sonic Jackhammer"
	desc = "Cracks rocks with sonic blasts, perfect for killing cave lizards."
	id = "jackhammer"
	req_tech = list("materials" = 3, "powerstorage" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list("$iron" = 2000, "$glass" = 500, "$silver" = 500)
	build_path = /obj/item/weapon/pickaxe/jackhammer

/datum/design/drill
	name = "Mining Drill"
	desc = "Yours is the drill that will pierce through the rock walls."
	id = "drill"
	req_tech = list("materials" = 2, "powerstorage" = 3, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list("$iron" = 6000, "$glass" = 1000) //expensive, but no need for miners.
	build_path = /obj/item/weapon/pickaxe/drill

/datum/design/plasmacutter
	name = "Plasma Cutter"
	desc = "You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	id = "plasmacutter"
	req_tech = list("materials" = 4, "plasmatech" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 1500, "$glass" = 500, "$gold" = 500, "$plasma" = 500)
	reliability_base = 79
	build_path = /obj/item/weapon/pickaxe/plasmacutter

/datum/design/pick_diamond
	name = "Diamond Pickaxe"
	desc = "A pickaxe with a diamond pick head, this is just like minecraft."
	id = "pick_diamond"
	req_tech = list("materials" = 6)
	build_type = PROTOLATHE
	materials = list("$diamond" = 3000)
	build_path = /obj/item/weapon/pickaxe/diamond

/datum/design/drill_diamond
	name = "Diamond Mining Drill"
	desc = "Yours is the drill that will pierce the heavens!"
	id = "drill_diamond"
	req_tech = list("materials" = 6, "powerstorage" = 4, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list("$iron" = 3000, "$glass" = 1000, "$diamond" = 3750) //Yes, a whole diamond is needed.
	reliability_base = 79
	build_path = /obj/item/weapon/pickaxe/diamonddrill

/datum/design/mesons
	name = "Optical Meson Scanners"
	desc = "Used for seeing walls, floors, and stuff through anything."
	id = "mesons"
	req_tech = list("magnets" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list("$iron" = 50, "$glass" = 50)
	build_path = /obj/item/clothing/glasses/meson

/////////////////////////////////////////
//////////////Blue Space/////////////////
/////////////////////////////////////////

/datum/design/beacon
	name = "Tracking Beacon"
	desc = "A blue space tracking beacon."
	id = "beacon"
	req_tech = list("bluespace" = 1)
	build_type = PROTOLATHE
	materials = list ("$iron" = 20, "$glass" = 10)
	build_path = /obj/item/device/radio/beacon

/datum/design/bag_holding
	name = "Bag of Holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	id = "bag_holding"
	req_tech = list("bluespace" = 4, "materials" = 6)
	build_type = PROTOLATHE
	materials = list("$gold" = 3000, "$diamond" = 1500, "$uranium" = 250)
	reliability_base = 80
	build_path = /obj/item/weapon/storage/backpack/holding

/datum/design/bluespace_crystal
	name = "Artificial Bluespace Crystal"
	desc = "A small blue crystal with mystical properties."
	id = "bluespace_crystal"
	req_tech = list("bluespace" = 4, "materials" = 6)
	build_type = PROTOLATHE
	materials = list("$diamond" = 1500, "$plasma" = 1500)
	reliability = 100
	build_path = /obj/item/bluespace_crystal/artificial

/datum/design/bluespacebeaker_small
	name = "Bluespace Beaker"
	desc = "A newly-developed high-capacity beaker, courtesy of bluespace research. Can hold up to 200 units."
	id = "bluespacebeaker_small"
	req_tech = list("bluespace" = 2, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$glass" = 6000, "$iron" = 6000)
	reliability = 100
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/bluespace

/datum/design/bluespacebeaker_large
	name = "Large Bluespace Beaker"
	desc = "A prototype ultra-capacity beaker, courtesy of bluespace research. Can hold up to 300 units."
	id = "bluespacebeaker_large"
	req_tech = list("bluespace" = 3, "materials" = 5)
	build_type = PROTOLATHE
	materials = list("$diamond" = 1500, "$iron" = 6000, "$glass" = 6000)
	reliability = 100
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/bluespacelarge

/datum/design/stasisbeaker_small
	name = "Stasis Beaker"
	desc = "A beaker powered by experimental bluespace technology. Chemicals are held in stasis and do not react inside of it. Can hold up to 50 units."
	id = "stasisbeaker_small"
	req_tech = list("bluespace" = 3, "materials" = 4)
	build_type = PROTOLATHE
	materials = list("$uranium" = 1500, "$iron" = 3750, "$glass" = 3750)
	reliability = 100
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/noreact

/datum/design/stasisbeaker_large
	name = "Large Stasis Beaker"
	desc = "A beaker powered by experimental bluespace technology. Chemicals are held in stasis and do not react inside of it. Can hold up to 100 units."
	id = "stasisbeaker_large"
	req_tech = list("bluespace" = 4, "materials" = 6)
	build_type = PROTOLATHE
	materials = list("$diamond" = 1500, "$iron" = 3750, "$glass" = 3750, "$uranium" = 1500)
	reliability = 100
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/noreactlarge

/datum/design/reactive_teleport_armor
	name = "Reactive Teleport Armor"
	desc = "Someone seperated our Research Director from his own head!"
	id = "reactive_teleport_armor"
	req_tech = list("bluespace" = 4, "materials" = 5)
	build_type = PROTOLATHE
	materials = list("$diamond" = 2000, "$iron" = 3000, "$uranium" = 3750)
	build_path = /obj/item/clothing/suit/armor/reactive

/datum/design/gps
	name = "Global Positioning System"
	desc = "Helping lost spacemen find their way through the planets since 2016."
	id = "gps"
	req_tech = list("bluespace" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list ("$iron" = 800, "$glass" = 200)
	build_path = /obj/item/device/gps/science

/datum/design/mat_synth
	name = "Material Synthasizer"
	desc = "A device capable of producing very little rare material with a whole lot of investment."
	id = "mat_synth"
	req_tech = list("engineering" = 4, "materials" = 5, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list ("$iron" = 3000, "$glass" = 1500, "$diamond" = 1000, "$uranium" = 3000)
	build_path = /obj/item/device/material_synth

/////////////////////////////////////////
/////////////////HUDs////////////////////
/////////////////////////////////////////

/datum/design/health_hud
	name = "Health Scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	id = "health_hud"
	req_tech = list("biotech" = 2, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 50, "$glass" = 50)
	build_path = /obj/item/clothing/glasses/hud/health

/*
/datum/design/security_hud
	name = "Security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status."
	id = "security_hud"
	req_tech = list("magnets" = 3, "combat" = 2)
	build_type = PROTOLATHE
	materials = list("$iron" = 50, "$glass" = 50)
	build_path = /obj/item/clothing/glasses/hud/security
	locked = 1
*/

/datum/design/sechud_sunglass
	name = "HUDSunglasses"
	desc = "Sunglasses with a heads-up display that scans the humans in view and provides accurate data about their ID status."
	id = "sechud_sunglass"
	req_tech = list("magnets" = 3, "combat" = 2)
	build_type = PROTOLATHE
	materials = list("$iron" = 50, "$glass" = 50)
	build_path = /obj/item/clothing/glasses/sunglasses/sechud
	locked = 1

/////////////////////////////////////////
/////////////////Engineering/////////////
/////////////////////////////////////////

/datum/design/superior_welding_goggles
	name = "Superior Welding Goggles"
	desc = "Welding goggles made from more expensive materials, strangely smells like potatoes. Allows for better vision than normal goggles.."
	id = "superior_welding_goggles"
	req_tech = list("materials" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list("$iron" = 500, "$glass" = 1500)
	build_path = /obj/item/clothing/glasses/welding/superior

/datum/design/night_vision_goggles
	name = "Night Vision Goggles"
	desc = "You can totally see in the dark now!."
	id = "night_vision_goggles"
	req_tech = list("materials" = 5, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list("$iron" = 700, "$glass" = 2000, "$gold" = 100)
	build_path = /obj/item/clothing/glasses/night


/////////////////////////////////////////
//////////////////Security///////////////
/////////////////////////////////////////

/datum/design/ablative_armor_vest
	name = "Ablative Armor Vest"
	desc = "A vest that excels in protecting the wearer against energy projectiles."
	id = "ablative vest"
	req_tech = list("combat" = 4, "materials" = 5)
	build_type = PROTOLATHE
	materials = list("$iron" = 1500, "$glass" = 2500, "$diamond" = 3750, "$silver" = 1000, "$uranium" = 500)
	build_path = /obj/item/clothing/suit/armor/laserproof
	locked = 1

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
			build_path = /obj/item/weapon/banhammer */

////////////////////////////////////////
//Disks for transporting design datums//
////////////////////////////////////////

/obj/item/weapon/disk/design_disk
	name = "Component Design Disk"
	desc = "A disk for storing device design data for construction in lathes."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = 1.0
	m_amt = 30
	g_amt = 10
	w_type = RECYK_ELECTRONIC
	var/datum/design/blueprint

/obj/item/weapon/disk/design_disk/New()
	src.pixel_x = rand(-5.0, 5)
	src.pixel_y = rand(-5.0, 5)


/////////////////////////////////////////
//////////////Borg Upgrades//////////////
/////////////////////////////////////////

/datum/design/borg_syndicate_module
	name = "Borg Illegal Weapons Upgrade"
	desc = "Allows for the construction of illegal upgrades for cyborgs"
	id = "borg_syndicate_module"
	build_type = MECHFAB
	req_tech = list("combat" = 4, "syndicate" = 3)
	build_path = /obj/item/borg/upgrade/syndicate
	category = "Cyborg Upgrade Modules"
	materials = list("$iron"=10000,"$glass"=15000,"$diamond" = 10000)

/datum/design/medical_module_surgery
	name = "medical module board"
	desc = "Used to give a medical cyborg surgery tools."
	id = "medical_module_surgery"
	req_tech = list("biotech" = 3, "engineering" = 3)
	build_type = MECHFAB
	materials = list("$iron" = 80000, "$glass" = 20000)
	build_path = /obj/item/borg/upgrade/medical/surgery
	category = "Robotic_Upgrade_Modules"

/datum/design/borg_reset_board
	name = "cyborg reset module"
	desc = "Used to reset cyborgs to their default module."
	id = "borg_reset_board"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/reset
	category = "Robotic_Upgrade_Modules"
	materials = list("$iron"=10000)

/datum/design/borg_rename_board
	name = "cyborg rename module"
	desc = "Used to rename cyborgs."
	id = "borg_rename_board"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/rename
	category = "Robotic_Upgrade_Modules"
	materials = list("$iron"=35000)

/datum/design/borg_restart_board
	name = "cyborg restart module"
	desc = "Used to restart cyborgs."
	id = "borg_restart_board"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/restart
	category = "Robotic_Upgrade_Modules"
	materials = list("$iron"=60000 , "$glass"=5000)

/datum/design/borg_vtec_board
	name = "cyborg VTEC module"
	desc = "Used to upgrade a borg's speed."
	id = "borg_vtec_board"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/vtec
	category = "Robotic_Upgrade_Modules"
	materials = list("$iron"=80000, "$glass"=6000, "$gold"= 5000)

/datum/design/borg_tasercooler_board
	name = "cyborg taser cooling module"
	desc = "Used to upgrade cyborg taser cooling."
	id = "borg_tasercooler_board"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/tasercooler
	category = "Robotic_Upgrade_Modules"
	materials = list("$iron"=80000 , "$glass"=6000 , "$gold"= 2000, "$diamond" = 500)

/datum/design/borg_jetpack_board
	name = "cyborg jetpack module"
	desc = "Used to give cyborgs a jetpack."
	id = "borg_jetpack_board"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/jetpack
	category = "Robotic_Upgrade_Modules"
	materials = list("$iron"=10000,"$plasma"=15000,"$uranium" = 20000)

/////////////////////////////////////////
///////////General Upgrades//////////////
/////////////////////////////////////////

/datum/design/janicart_upgrade
	name = "Janicart Upgrade Module"
	desc = "Used to allow the janicart to clean surfaces while moving."
	id = "janicart_upgrade"
	build_type = PROTOLATHE | MECHFAB
	build_path = /obj/item/mecha_parts/janicart_upgrade
	req_tech = list("engineering" = 1, "materials" = 1)
	materials = list("$iron"=10000)
	category = "Misc"

/////////////////////////////////////////
//////////Teleporter Machines////////////
/////////////////////////////////////////
/datum/design/telehub
	name = "Circuit Design (Teleporter Hub)"
	desc = "Allows for the construction of circuit boards used to build a Teleporter Hub"
	id = "telehub"
	req_tech = list("programming" = 4, "engineering"=3, "bluespace" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telehub

/datum/design/telestation
	name = "Circuit Design (Teleporter Station)"
	desc = "Allows for the construction of circuit boards used to build a Teleporter Station."
	id = "telestation"
	req_tech = list("programming" = 4, "engineering" = 3, "bluespace" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telestation

/////////////////////////////////////////
///////////////Hospitality///////////////
/////////////////////////////////////////

/datum/design/biogenerator
	name = "Circuit Design (Biogenerator)"
	desc = "Allows for the construction of circuit boards used to build a Biogenerator."
	id = "biogenerator"
	req_tech = list("programming" = 3,"engineering" = 2, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/biogenerator

/datum/design/seed_extractor
	name = "Circuit Design (Seed Extractor)"
	desc = "Allows for the construction of circuit boards used to build a Seed Extractor."
	id = "seed_extractor"
	req_tech = list("programming" = 3,"engineering" = 2, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/seed_extractor

/datum/design/microwave
	name = "Circuit Design (Microwave)"
	desc = "Allows for the construction of circuit boards used to build a Microwave."
	id = "microwave"
	req_tech = list("programming" = 3,"engineering" = 2,"magnets" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/microwave

/datum/design/reagentgrinder
	name = "Circuit Design (All-In-One Grinder)"
	desc = "Allows for the construction of circuit boards used to build an All-In-One Grinder."
	id = "reagentgrinder"
	req_tech = list("programming" = 3,"engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/reagentgrinder

/datum/design/smartfridge
	name = "Circuit Design (SmartFridge)"
	desc = "Allows for the construction of circuit boards used to build a smartfridge."
	id = "smartfridge"
	req_tech = list("programming" = 3,"engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/smartfridge

/datum/design/hydroponics
	name = "Circuit Design (Hydroponics Tray)"
	desc = "Allows for the construction of circuit boards used to build a Hydroponics Tray."
	id = "hydroponics"
	req_tech = list("programming" = 3,"engineering" = 2,"biotech" = 3,"powerstorage" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/hydroponics

/datum/design/gibber
	name = "Circuit Design (Gibber)"
	desc = "Allows for the construction of circuit boards used to build a gibber."
	id = "gibber"
	req_tech = list("programming" = 3,"engineering" = 2,"biotech" = 3,"powerstorage" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/gibber

/datum/design/processor
	name = "Circuit Design (Food Processor)"
	desc = "Allows for the construction of circuit boards used to build a Food Processor."
	id = "processor"
	req_tech = list("programming" = 3,"engineering" = 2,"biotech" = 3,"powerstorage" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/processor

/datum/design/air_alarm
	name = "Circuit Design (Air Alarm)"
	desc = "Allows for the construction of circuit boards used to build an Air Alarm."
	id = "air_alarm"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/air_alarm

/datum/design/fire_alarm
	name = "Circuit Design (Fire Alarm)"
	desc = "Allows for the construction of circuit boards used to build a Fire Alarm."
	id = "fire_alarm"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/fire_alarm

/datum/design/airlock
	name = "Circuit Design (Airlock)"
	desc = "Allows for the construction of circuit boards used to build an airlock."
	id = "airlock"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/airlock

/datum/design/conveyor
	name = "Circuit Design (Conveyor)"
	desc = "Allows for the construction of circuit boards used to build a conveyor belt."
	id = "conveyor"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/conveyor

/datum/design/bhangmeter
	name = "Circuit Design (Bhangmeter)"
	desc = "Allows for the construction of circuit boards used to build a bhangmeter."
	id = "bhangmeter"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/bhangmeter


//////////////////////////////////////////////////////////////////
// EMBEDDED CONTROLLER BOARDS
//////////////////////////////////////////////////////////////////
/datum/design/access_control
	name = "Circuit Design (Access Control)"
	desc = "Allows for the construction of ECB used to build an access control panel."
	id = "access_control"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/ecb/access_controller

/datum/design/airlock_control
	name = "Circuit Design (Airlock Control)"
	desc = "Allows for the construction of ECB used to build an airlock control panel."
	id = "airlock_control"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/ecb/airlock_controller

/datum/design/advanced_airlock_control
	name = "Circuit Design (Advanced)"
	desc = "Allows for the construction of ECB used to build an advanced control panel."
	id = "advanced_airlock_control"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/ecb/advanced_airlock_controller

/*
/datum/design/hydroseeds
	name = "Circuit Design (MegaSeed Servitor)"
	desc = "Allows for the construction of circuit boards used to build a MegaSeedServitor."
	id = "hydroseeds"
	req_tech = list("programming" = 3,"engineering" = 2,"biotech" = 3,"powerstorage" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/hydroseeds

/datum/design/hydronutrients
	name = "Circuit Design (Nutrimax)"
	desc = "Allows for the construction of circuit boards used to build a Nutrimax."
	id = "hydronutrients"
	req_tech = list("programming" = 3,"engineering" = 2,"biotech" = 3,"powerstorage" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/hydronutrients
	*/

//////////////////////////////////////////////////
/////////SPACEPOD PARTS///////////////////////////
//////////////////////////////////////////////////
/datum/design/podframe_fp
	name = "Fore port pod frame"
	desc = "Allows for the construction of spacepod frames. This is the fore port component."
	id = "podframefp"
	build_type = PODFAB
	req_tech = list("materials" = 3, "engineering" = 2)
	build_path = /obj/item/pod_parts/pod_frame/fore_port
	category = "Pod_Frame"
	materials = list("$iron"=15000,"$glass"=5000)

/datum/design/podframe_ap
	name = "Aft port pod frame"
	desc = "Allows for the construction of spacepod frames. This is the aft port component."
	id = "podframeap"
	build_type = PODFAB
	req_tech = list("materials" = 3, "engineering" = 2)
	build_path = /obj/item/pod_parts/pod_frame/aft_port
	category = "Pod_Frame"
	materials = list("$iron"=15000,"$glass"=5000)

/datum/design/podframe_fs
	name = "Fore starboard pod frame"
	desc = "Allows for the construction of spacepod frames. This is the fore starboard component."
	id = "podframefs"
	build_type = PODFAB
	req_tech = list("materials" = 3, "engineering" = 2)
	build_path = /obj/item/pod_parts/pod_frame/fore_starboard
	category = "Pod_Frame"
	materials = list("$iron"=15000,"$glass"=5000)

/datum/design/podframe_as
	name = "Aft starboard pod frame"
	desc = "Allows for the construction of spacepod frames. This is the aft starboard component."
	id = "podframeas"
	build_type = PODFAB
	req_tech = list("materials" = 3, "engineering" = 2)
	build_path = /obj/item/pod_parts/pod_frame/aft_starboard
	category = "Pod_Frame"
	materials = list("$iron"=15000,"$glass"=5000)

//////////////////////////
////////POD CORE////////
//////////////////////////

/datum/design/pod_core
	name = "Spacepod Core"
	desc = "Allows for the construction of a spacepod core system, made up of the engine and life support systems."
	id = "podcore"
	build_type = MECHFAB | PODFAB
	req_tech = list("materials" = 4, "engineering" = 3, "plasma" = 3, "bluespace" = 2)
	build_path = /obj/item/pod_parts/core
	category = "Pod_Parts"
	materials = list("$iron"=5000,"$uranium"=1000,"$plasma"=5000)

//////////////////////////////////////////
////////SPACEPOD ARMOR////////////////////
//////////////////////////////////////////

/datum/design/pod_armor_civ
	name = "Pod Armor (civilian)"
	desc = "Allows for the construction of spacepod armor. This is the civilian version."
	id = "podarmor_civ"
	build_type = PODFAB
	req_tech = list("materials" = 3, "plasma" = 3)
	build_path = /obj/item/pod_parts/armor
	category = "Pod_Armor"
	materials = list("$iron"=15000,"$glass"=5000,"$plasma"=10000)

//////////////////////////////////////////
//////SPACEPOD GUNS///////////////////////
//////////////////////////////////////////
/datum/design/pod_gun_taser
	name = "Spacepod Equipment (Taser)"
	desc = "Allows for the construction of a spacepod mounted taser."
	id = "podgun_taser"
	build_type = PODFAB
	req_tech = list("materials" = 2, "combat" = 2)
	build_path = /obj/item/device/spacepod_equipment/weaponry/taser
	category = "Pod_Weaponry"
	materials = list("$iron" = 15000)

/datum/design/pod_gun_btaser
	name = "Spacepod Equipment (Burst Taser)"
	desc = "Allows for the construction of a spacepod mounted taser. This is the burst-fire model."
	id = "podgun_btaser"
	build_type = PODFAB
	req_tech = list("materials" = 3, "combat" = 3)
	build_path = /obj/item/device/spacepod_equipment/weaponry/taser/burst
	category = "Pod_Weaponry"
	materials = list("$iron" = 15000)

/datum/design/pod_gun_laser
	name = "Spacepod Equipment (Laser)"
	desc = "Allows for the construction of a spacepod mounted laser."
	id = "podgun_laser"
	build_type = PODFAB
	req_tech = list("materials" = 3, "combat" = 3, "plasma" = 2)
	build_path = /obj/item/device/spacepod_equipment/weaponry/laser
	category = "Pod_Weaponry"
	materials = list("$iron" = 15000)
	locked = 1

//////////////////////////////////////////
//////VENDING MACHINES////////////////////
//////////////////////////////////////////
/datum/design/vendomat
	name = "Circuit Design (Vending Machine)"
	desc = "Allows for the construction of circuit boards used to build vending machines."
	id = "vendomat"
	req_tech = list("materials" = 1, "engineering" = 1, "powerstorage" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/vendomat