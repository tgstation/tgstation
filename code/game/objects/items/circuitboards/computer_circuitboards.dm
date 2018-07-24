/obj/item/circuitboard/computer/turbine_computer
	name = "Turbine Computer (Computer Board)"
	build_path = /obj/machinery/computer/turbine_computer

/obj/item/circuitboard/computer/launchpad_console
	name = "Launchpad Control Console (Computer Board)"
	build_path = /obj/machinery/computer/launchpad

/obj/item/circuitboard/computer/message_monitor
	name = "Message Monitor (Computer Board)"
	build_path = /obj/machinery/computer/message_monitor

/obj/item/circuitboard/computer/security
	name = "Security Cameras (Computer Board)"
	build_path = /obj/machinery/computer/security

/obj/item/circuitboard/computer/xenobiology
	name = "circuit board (Xenobiology Console)"
	build_path = /obj/machinery/computer/camera_advanced/xenobio

/obj/item/circuitboard/computer/base_construction
	name = "circuit board (Aux Mining Base Construction Console)"
	build_path = /obj/machinery/computer/camera_advanced/base_construction

/obj/item/circuitboard/computer/aiupload
	name = "AI Upload (Computer Board)"
	build_path = /obj/machinery/computer/upload/ai

/obj/item/circuitboard/computer/borgupload
	name = "Cyborg Upload (Computer Board)"
	build_path = /obj/machinery/computer/upload/borg

/obj/item/circuitboard/computer/med_data
	name = "Medical Records Console (Computer Board)"
	build_path = /obj/machinery/computer/med_data

/obj/item/circuitboard/computer/pandemic
	name = "PanD.E.M.I.C. 2200 (Computer Board)"
	build_path = /obj/machinery/computer/pandemic

/obj/item/circuitboard/computer/scan_consolenew
	name = "DNA Machine (Computer Board)"
	build_path = /obj/machinery/computer/scan_consolenew

/obj/item/circuitboard/computer/communications
	name = "Communications (Computer Board)"
	build_path = /obj/machinery/computer/communications
	var/lastTimeUsed = 0

/obj/item/circuitboard/computer/card
	name = "ID Console (Computer Board)"
	build_path = /obj/machinery/computer/card

/obj/item/circuitboard/computer/card/centcom
	name = "CentCom ID Console (Computer Board)"
	build_path = /obj/machinery/computer/card/centcom

/obj/item/circuitboard/computer/card/minor
	name = "Department Management Console (Computer Board)"
	build_path = /obj/machinery/computer/card/minor
	var/target_dept = 1
	var/list/dept_list = list("General","Security","Medical","Science","Engineering")

/obj/item/circuitboard/computer/card/minor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver))
		target_dept = (target_dept == dept_list.len) ? 1 : (target_dept + 1)
		to_chat(user, "<span class='notice'>You set the board to \"[dept_list[target_dept]]\".</span>")
	else
		return ..()

/obj/item/circuitboard/computer/card/minor/examine(user)
	..()
	to_chat(user, "Currently set to \"[dept_list[target_dept]]\".")

//obj/item/circuitboard/computer/shield
//	name = "Shield Control (Computer Board)"
//	build_path = /obj/machinery/computer/stationshield
/obj/item/circuitboard/computer/teleporter
	name = "Teleporter (Computer Board)"
	build_path = /obj/machinery/computer/teleporter

/obj/item/circuitboard/computer/secure_data
	name = "Security Records Console (Computer Board)"
	build_path = /obj/machinery/computer/secure_data

/obj/item/circuitboard/computer/stationalert
	name = "Station Alerts (Computer Board)"
	build_path = /obj/machinery/computer/station_alert

/obj/item/circuitboard/computer/atmos_control
	name = "Atmospheric Monitor (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control

/obj/item/circuitboard/computer/atmos_control/tank
	name = "Tank Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank

/obj/item/circuitboard/computer/atmos_alert
	name = "Atmospheric Alert (Computer Board)"
	build_path = /obj/machinery/computer/atmos_alert

/obj/item/circuitboard/computer/pod
	name = "Massdriver control (Computer Board)"
	build_path = /obj/machinery/computer/pod

/obj/item/circuitboard/computer/robotics
	name = "Robotics Control (Computer Board)"
	build_path = /obj/machinery/computer/robotics

/obj/item/circuitboard/computer/cloning
	name = "Cloning (Computer Board)"
	build_path = /obj/machinery/computer/cloning

/obj/item/circuitboard/computer/prototype_cloning
	name = "Prototype Cloning (Computer Board)"
	build_path = /obj/machinery/computer/prototype_cloning

/obj/item/circuitboard/computer/arcade/battle
	name = "Arcade Battle (Computer Board)"
	build_path = /obj/machinery/computer/arcade/battle

/obj/item/circuitboard/computer/arcade/orion_trail
	name = "Orion Trail (Computer Board)"
	build_path = /obj/machinery/computer/arcade/orion_trail

/obj/item/circuitboard/computer/turbine_control
	name = "Turbine control (Computer Board)"
	build_path = /obj/machinery/computer/turbine_computer

/obj/item/circuitboard/computer/solar_control
	name = "Solar Control (Computer Board)"  //name fixed 250810
	build_path = /obj/machinery/power/solar_control

/obj/item/circuitboard/computer/powermonitor
	name = "Power Monitor (Computer Board)"  //name fixed 250810
	build_path = /obj/machinery/computer/monitor

/obj/item/circuitboard/computer/powermonitor/secret
	name = "Outdated Power Monitor (Computer Board)" //Variant used on ruins to prevent them from showing up on PDA's.
	build_path = /obj/machinery/computer/monitor/secret

/obj/item/circuitboard/computer/olddoor
	name = "DoorMex (Computer Board)"
	build_path = /obj/machinery/computer/pod/old

/obj/item/circuitboard/computer/syndicatedoor
	name = "ProComp Executive (Computer Board)"
	build_path = /obj/machinery/computer/pod/old/syndicate

/obj/item/circuitboard/computer/swfdoor
	name = "Magix (Computer Board)"
	build_path = /obj/machinery/computer/pod/old/swf

/obj/item/circuitboard/computer/prisoner
	name = "Prisoner Management Console (Computer Board)"
	build_path = /obj/machinery/computer/prisoner
/obj/item/circuitboard/computer/gulag_teleporter_console
	name = "Labor Camp teleporter console (Computer Board)"
	build_path = /obj/machinery/computer/gulag_teleporter_computer

/obj/item/circuitboard/computer/rdconsole/production
	name = "R&D Console Production Only (Computer Board)"
	build_path = /obj/machinery/computer/rdconsole/production

/obj/item/circuitboard/computer/rdconsole
	name = "R&D Console (Computer Board)"
	build_path = /obj/machinery/computer/rdconsole/core

/obj/item/circuitboard/computer/rdconsole/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver))
		if(build_path == /obj/machinery/computer/rdconsole/core)
			name = "R&D Console - Robotics (Computer Board)"
			build_path = /obj/machinery/computer/rdconsole/robotics
			to_chat(user, "<span class='notice'>Access protocols successfully updated.</span>")
		else
			name = "R&D Console (Computer Board)"
			build_path = /obj/machinery/computer/rdconsole/core
			to_chat(user, "<span class='notice'>Defaulting access protocols.</span>")
	else
		return ..()

/obj/item/circuitboard/computer/mecha_control
	name = "Exosuit Control Console (Computer Board)"
	build_path = /obj/machinery/computer/mecha

/obj/item/circuitboard/computer/rdservercontrol
	name = "R&D Server Control (Computer Board)"
	build_path = /obj/machinery/computer/rdservercontrol

/obj/item/circuitboard/computer/crew
	name = "Crew Monitoring Console (Computer Board)"
	build_path = /obj/machinery/computer/crew

/obj/item/circuitboard/computer/mech_bay_power_console
	name = "Mech Bay Power Control Console (Computer Board)"
	build_path = /obj/machinery/computer/mech_bay_power_console

/obj/item/circuitboard/computer/cargo
	name = "Supply Console (Computer Board)"
	build_path = /obj/machinery/computer/cargo
	var/contraband = FALSE

/obj/item/circuitboard/computer/cargo/multitool_act(mob/living/user)
	if(!(obj_flags & EMAGGED))
		contraband = !contraband
		to_chat(user, "<span class='notice'>Receiver spectrum set to [contraband ? "Broad" : "Standard"].</span>")
	else
		to_chat(user, "<span class='notice'>The spectrum chip is unresponsive.</span>")

/obj/item/circuitboard/computer/cargo/emag_act(mob/living/user)
	if(!(obj_flags & EMAGGED))
		contraband = TRUE
		obj_flags |= EMAGGED
		to_chat(user, "<span class='notice'>You adjust [src]'s routing and receiver spectrum, unlocking special supplies and contraband.</span>")

/obj/item/circuitboard/computer/cargo/express
	name = "Express Supply Console (Computer Board)"
	build_path = /obj/machinery/computer/cargo/express

/obj/item/circuitboard/computer/cargo/express/multitool_act(mob/living/user)
	if (!(obj_flags & EMAGGED))
		to_chat(user, "<span class='notice'>Routing protocols are already set to: \"factory defaults\".</span>")
	else
		to_chat(user, "<span class='notice'>You reset the routing protocols to: \"factory defaults\".</span>")
		obj_flags &= ~EMAGGED

/obj/item/circuitboard/computer/cargo/express/emag_act(mob/living/user)
		to_chat(user, "<span class='notice'>You change the routing protocols, allowing the Drop Pod to land anywhere on the station.</span>")
		obj_flags |= EMAGGED

/obj/item/circuitboard/computer/cargo/request
	name = "Supply Request Console (Computer Board)"
	build_path = /obj/machinery/computer/cargo/request

/obj/item/circuitboard/computer/bounty
	name = "Nanotrasen Bounty Console (Computer Board)"
	build_path = /obj/machinery/computer/bounty

/obj/item/circuitboard/computer/operating
	name = "Operating Computer (Computer Board)"
	build_path = /obj/machinery/computer/operating

/obj/item/circuitboard/computer/mining
	name = "Outpost Status Display (Computer Board)"
	build_path = /obj/machinery/computer/security/mining

/obj/item/circuitboard/computer/research
	name = "Research Monitor (Computer Board)"
	build_path = /obj/machinery/computer/security/research

/obj/item/circuitboard/computer/comm_monitor
	name = "Telecommunications Monitor (Computer Board)"
	build_path = /obj/machinery/computer/telecomms/monitor

/obj/item/circuitboard/computer/comm_server
	name = "Telecommunications Server Monitor (Computer Board)"
	build_path = /obj/machinery/computer/telecomms/server

/obj/item/circuitboard/computer/labor_shuttle
	name = "Labor Shuttle (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/labor

/obj/item/circuitboard/computer/labor_shuttle/one_way
	name = "Prisoner Shuttle Console (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/labor/one_way

/obj/item/circuitboard/computer/ferry
	name = "Transport Ferry (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/ferry

/obj/item/circuitboard/computer/ferry/request
	name = "Transport Ferry Console (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/ferry/request

/obj/item/circuitboard/computer/mining_shuttle
	name = "Mining Shuttle (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/mining

/obj/item/circuitboard/computer/white_ship
	name = "White Ship (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/white_ship

/obj/item/circuitboard/computer/auxillary_base
	name = "Auxillary Base Management Console (Computer Board)"
	build_path = /obj/machinery/computer/auxillary_base

/obj/item/circuitboard/computer/holodeck// Not going to let people get this, but it's just here for future
	name = "Holodeck Control (Computer Board)"
	build_path = /obj/machinery/computer/holodeck

/obj/item/circuitboard/computer/aifixer
	name = "AI Integrity Restorer (Computer Board)"
	build_path = /obj/machinery/computer/aifixer

/obj/item/circuitboard/computer/slot_machine
	name = "Slot Machine (Computer Board)"
	build_path = /obj/machinery/computer/slot_machine

/obj/item/circuitboard/computer/libraryconsole
	name = "Library Visitor Console (Computer Board)"
	build_path = /obj/machinery/computer/libraryconsole

/obj/item/circuitboard/computer/libraryconsole/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver))
		if(build_path == /obj/machinery/computer/libraryconsole/bookmanagement)
			name = "Library Visitor Console (Computer Board)"
			build_path = /obj/machinery/computer/libraryconsole
			to_chat(user, "<span class='notice'>Defaulting access protocols.</span>")
		else
			name = "Book Inventory Management Console (Computer Board)"
			build_path = /obj/machinery/computer/libraryconsole/bookmanagement
			to_chat(user, "<span class='notice'>Access protocols successfully updated.</span>")
	else
		return ..()

/obj/item/circuitboard/computer/apc_control
	name = "\improper Power Flow Control Console (Computer Board)"
	build_path = /obj/machinery/computer/apc_control

/obj/item/circuitboard/computer/monastery_shuttle
	name = "Monastery Shuttle (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/monastery_shuttle

/obj/item/circuitboard/computer/syndicate_shuttle
	name = "Syndicate Shuttle (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/syndicate
	var/challenge = FALSE
	var/moved = FALSE

/obj/item/circuitboard/computer/syndicate_shuttle/Initialize()
	. = ..()
	GLOB.syndicate_shuttle_boards += src

/obj/item/circuitboard/computer/syndicate_shuttle/Destroy()
	GLOB.syndicate_shuttle_boards -= src
	return ..()

/obj/item/circuitboard/computer/bsa_control
	name = "Bluespace Artillery Controls (Computer Board)"
	build_path = /obj/machinery/computer/bsa_control

/obj/item/circuitboard/computer/sat_control
	name = "Satellite Network Control (Computer Board)"
	build_path = /obj/machinery/computer/sat_control
