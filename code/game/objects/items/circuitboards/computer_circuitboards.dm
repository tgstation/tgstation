/obj/item/circuitboard/computer/turbine_computer
	name = "Turbine Computer (Computer Board)"
	build_path = /obj/machinery/computer/turbine_computer
	origin_tech = "programming=4;engineering=4;powerstorage=4"

/obj/item/circuitboard/computer/launchpad_console
	name = "Launchpad Control Console (Computer Board)"
	build_path = /obj/machinery/computer/launchpad
	origin_tech = "programming=3;bluespace=3;plasmatech=2"

/obj/item/circuitboard/computer/message_monitor
	name = "Message Monitor (Computer Board)"
	build_path = /obj/machinery/computer/message_monitor
	origin_tech = "programming=2"

/obj/item/circuitboard/computer/security
	name = "Security Cameras (Computer Board)"
	build_path = /obj/machinery/computer/security
	origin_tech = "programming=2;combat=2"

/obj/item/circuitboard/computer/xenobiology
	name = "circuit board (Xenobiology Console)"
	build_path = /obj/machinery/computer/camera_advanced/xenobio
	origin_tech = "programming=3;biotech=3"

/obj/item/circuitboard/computer/base_construction
	name = "circuit board (Aux Mining Base Construction Console)"
	build_path = /obj/machinery/computer/camera_advanced/base_construction
	origin_tech = "programming=3;engineering=3"

/obj/item/circuitboard/computer/aiupload
	name = "AI Upload (Computer Board)"
	build_path = /obj/machinery/computer/upload/ai
	origin_tech = "programming=4;engineering=4"

/obj/item/circuitboard/computer/borgupload
	name = "Cyborg Upload (Computer Board)"
	build_path = /obj/machinery/computer/upload/borg
	origin_tech = "programming=4;engineering=4"

/obj/item/circuitboard/computer/med_data
	name = "Medical Records Console (Computer Board)"
	build_path = /obj/machinery/computer/med_data
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/computer/pandemic
	name = "PanD.E.M.I.C. 2200 (Computer Board)"
	build_path = /obj/machinery/computer/pandemic
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/computer/scan_consolenew
	name = "DNA Machine (Computer Board)"
	build_path = /obj/machinery/computer/scan_consolenew
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/computer/communications
	name = "Communications (Computer Board)"
	build_path = /obj/machinery/computer/communications
	origin_tech = "programming=3;magnets=3"
	var/lastTimeUsed = 0

/obj/item/circuitboard/computer/card
	name = "ID Console (Computer Board)"
	build_path = /obj/machinery/computer/card
	origin_tech = "programming=3"

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
	origin_tech = "programming=3;bluespace=3;plasmatech=3"

/obj/item/circuitboard/computer/secure_data
	name = "Security Records Console (Computer Board)"
	build_path = /obj/machinery/computer/secure_data
	origin_tech = "programming=2;combat=2"

/obj/item/circuitboard/computer/stationalert
	name = "Station Alerts (Computer Board)"
	build_path = /obj/machinery/computer/station_alert

/obj/item/circuitboard/computer/atmos_control
	name = "Atmospheric Monitor (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control

/obj/item/circuitboard/computer/atmos_control/tank
	name = "Tank Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank
	origin_tech = "programming=2;engineering=3;materials=2"

/obj/item/circuitboard/computer/atmos_alert
	name = "Atmospheric Alert (Computer Board)"
	build_path = /obj/machinery/computer/atmos_alert

/obj/item/circuitboard/computer/pod
	name = "Massdriver control (Computer Board)"
	build_path = /obj/machinery/computer/pod

/obj/item/circuitboard/computer/robotics
	name = "Robotics Control (Computer Board)"
	build_path = /obj/machinery/computer/robotics
	origin_tech = "programming=3"

/obj/item/circuitboard/computer/cloning
	name = "Cloning (Computer Board)"
	build_path = /obj/machinery/computer/cloning
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/computer/arcade/battle
	name = "Arcade Battle (Computer Board)"
	build_path = /obj/machinery/computer/arcade/battle
	origin_tech = "programming=1"

/obj/item/circuitboard/computer/arcade/orion_trail
	name = "Orion Trail (Computer Board)"
	build_path = /obj/machinery/computer/arcade/orion_trail
	origin_tech = "programming=1"

/obj/item/circuitboard/computer/turbine_control
	name = "Turbine control (Computer Board)"
	build_path = /obj/machinery/computer/turbine_computer

/obj/item/circuitboard/computer/solar_control
	name = "Solar Control (Computer Board)"  //name fixed 250810
	build_path = /obj/machinery/power/solar_control
	origin_tech = "programming=2;powerstorage=2"

/obj/item/circuitboard/computer/powermonitor
	name = "Power Monitor (Computer Board)"  //name fixed 250810
	build_path = /obj/machinery/computer/monitor
	origin_tech = "programming=2;powerstorage=2"

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
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/computer/mech_bay_power_console
	name = "Mech Bay Power Control Console (Computer Board)"
	build_path = /obj/machinery/computer/mech_bay_power_console
	origin_tech = "programming=3;powerstorage=3"

/obj/item/circuitboard/computer/cargo
	name = "Supply Console (Computer Board)"
	build_path = /obj/machinery/computer/cargo
	origin_tech = "programming=3"
	var/contraband = FALSE

/obj/item/circuitboard/computer/cargo/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/multitool))
		if(!emagged)
			contraband = !contraband
			to_chat(user, "<span class='notice'>Receiver spectrum set to [contraband ? "Broad" : "Standard"].</span>")
		else
			to_chat(user, "<span class='notice'>The spectrum chip is unresponsive.</span>")
	else if(istype(I, /obj/item/card/emag))
		if(!emagged)
			contraband = TRUE
			emagged = TRUE
			to_chat(user, "<span class='notice'>You adjust [src]'s routing and receiver spectrum, unlocking special supplies and contraband.</span>")
	else
		return ..()


/obj/item/circuitboard/computer/cargo/request
	name = "Supply Request Console (Computer Board)"
	build_path = /obj/machinery/computer/cargo/request

/obj/item/circuitboard/computer/stockexchange
	name = "circuit board (Stock Exchange Console)"
	build_path = /obj/machinery/computer/stockexchange
	origin_tech = "programming=3"

/obj/item/circuitboard/computer/operating
	name = "Operating Computer (Computer Board)"
	build_path = /obj/machinery/computer/operating
	origin_tech = "programming=2;biotech=3"

/obj/item/circuitboard/computer/mining
	name = "Outpost Status Display (Computer Board)"
	build_path = /obj/machinery/computer/security/mining

/obj/item/circuitboard/computer/comm_monitor
	name = "Telecommunications Monitor (Computer Board)"
	build_path = /obj/machinery/computer/telecomms/monitor
	origin_tech = "programming=3;magnets=3;bluespace=2"

/obj/item/circuitboard/computer/comm_server
	name = "Telecommunications Server Monitor (Computer Board)"
	build_path = /obj/machinery/computer/telecomms/server
	origin_tech = "programming=3;magnets=3;bluespace=2"

/obj/item/circuitboard/computer/shuttle
	name = "Shuttle (Computer Board)"
	build_path = /obj/machinery/computer/shuttle
	var/shuttleId
	var/possible_destinations = ""

/obj/item/circuitboard/computer/shuttle/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/multitool))
		var/chosen_id = round(input(usr, "Choose an ID number (-1 for reset):", "Input an Integer", null) as num|null)
		if(chosen_id >= 0)
			shuttleId = chosen_id
		else
			shuttleId = initial(shuttleId)
	else
		return ..()

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
	origin_tech = "programming=4"

/obj/item/circuitboard/computer/aifixer
	name = "AI Integrity Restorer (Computer Board)"
	build_path = /obj/machinery/computer/aifixer
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/computer/slot_machine
	name = "Slot Machine (Computer Board)"
	build_path = /obj/machinery/computer/slot_machine
	origin_tech = "programming=1"

/obj/item/circuitboard/computer/libraryconsole
	name = "Library Visitor Console (Computer Board)"
	build_path = /obj/machinery/computer/libraryconsole
	origin_tech = "programming=1"

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
	origin_tech = "programming=3;engineering=3;powerstorage=2"

/obj/item/circuitboard/computer/shuttle/monastery_shuttle
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
	origin_tech = "engineering=2;combat=2;bluespace=2"

/obj/item/circuitboard/computer/sat_control
	name = "Satellite Network Control (Computer Board)"
	build_path = /obj/machinery/computer/sat_control
	origin_tech = "engineering=3"