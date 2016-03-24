//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/structure/computerframe
	density = 1
	anchored = 0
	name = "computer-frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "0"
	var/state = 0
	var/obj/item/weapon/circuitboard/circuit = null
//	weight = 1.0E8

/obj/item/weapon/circuitboard
	density = 0
	anchored = 0
	w_class = 2
	name = "circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
	item_state = "electronic"
	origin_tech = "programming=2"
	materials = list(MAT_GLASS=200)
	var/frequency = null
	var/build_path = null
	var/board_type = "computer"
	var/list/req_components = null
	var/powernet = null
	var/list/records = null
	var/frame_desc = null

/obj/item/weapon/circuitboard/turbine_computer
	name = "circuit board (Turbine Computer)"
	build_path = /obj/machinery/computer/turbine_computer
	origin_tech = "programming=4;engineering=4;powerstorage=4"
/obj/item/weapon/circuitboard/telesci_console
	name = "circuit board (Telescience Console)"
	build_path = /obj/machinery/computer/telescience
	origin_tech = "programming=3;bluespace=2"
/obj/item/weapon/circuitboard/message_monitor
	name = "circuit board (Message Monitor)"
	build_path = /obj/machinery/computer/message_monitor
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/security
	name = "circuit board (Security)"
	build_path = /obj/machinery/computer/security
/obj/item/weapon/circuitboard/aicore
	name = "circuit board (AI core)"
	origin_tech = "programming=4;biotech=2"
	board_type = "other"
/obj/item/weapon/circuitboard/aiupload
	name = "circuit board (AI Upload)"
	build_path = /obj/machinery/computer/upload/ai
	origin_tech = "programming=4"
/obj/item/weapon/circuitboard/borgupload
	name = "circuit board (Cyborg Upload)"
	build_path = /obj/machinery/computer/upload/borg
	origin_tech = "programming=4"
/obj/item/weapon/circuitboard/med_data
	name = "circuit board (Medical Records Console)"
	build_path = /obj/machinery/computer/med_data
/obj/item/weapon/circuitboard/pandemic
	name = "circuit board (PanD.E.M.I.C. 2200)"
	build_path = /obj/machinery/computer/pandemic
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/scan_consolenew
	name = "circuit board (DNA Machine)"
	build_path = /obj/machinery/computer/scan_consolenew
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/communications
	name = "circuit board (Communications)"
	build_path = /obj/machinery/computer/communications
	origin_tech = "programming=2;magnets=2"
	var/lastTimeUsed = 0

/obj/item/weapon/circuitboard/card
	name = "circuit board (ID Console)"
	build_path = /obj/machinery/computer/card
/obj/item/weapon/circuitboard/card/centcom
	name = "circuit board (Centcom ID Console)"
	build_path = /obj/machinery/computer/card/centcom
/obj/item/weapon/circuitboard/card/minor
	name = "circuit board (Department Management Console)"
	build_path = /obj/machinery/computer/card/minor
	var/target_dept = 1
//obj/item/weapon/circuitboard/shield
//	name = "Circuit board (Shield Control)"
//	build_path = /obj/machinery/computer/stationshield
/obj/item/weapon/circuitboard/teleporter
	name = "circuit board (Teleporter)"
	build_path = /obj/machinery/computer/teleporter
	origin_tech = "programming=2;bluespace=2"
/obj/item/weapon/circuitboard/secure_data
	name = "circuit board (Security Records Console)"
	build_path = /obj/machinery/computer/secure_data
/obj/item/weapon/circuitboard/stationalert
	name = "circuit board (Station Alerts)"
	build_path = /obj/machinery/computer/station_alert
/*/obj/item/weapon/circuitboard/atmospheresiphonswitch
	name = "circuit board (Atmosphere siphon control)"
	build_path = /obj/machinery/computer/atmosphere/siphonswitch*/
/obj/item/weapon/circuitboard/atmos_control
	name = "circuit board (Atmospheric Monitor)"
	build_path = /obj/machinery/computer/atmos_control
/obj/item/weapon/circuitboard/atmos_control/tank
	name = "circuit board (Tank Control)"
	build_path = /obj/machinery/computer/atmos_control/tank
	origin_tech = "programming=2;engineering=3;materials=2"
/obj/item/weapon/circuitboard/atmos_alert
	name = "circuit board (Atmospheric Alert)"
	build_path = /obj/machinery/computer/atmos_alert
/obj/item/weapon/circuitboard/pod
	name = "circuit board (Massdriver control)"
	build_path = /obj/machinery/computer/pod
/obj/item/weapon/circuitboard/robotics
	name = "circuit board (Robotics Control)"
	build_path = /obj/machinery/computer/robotics
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/cloning
	name = "circuit board (Cloning)"
	build_path = /obj/machinery/computer/cloning
	origin_tech = "programming=3;biotech=3"
/obj/item/weapon/circuitboard/arcade/battle
	name = "circuit board (Arcade Battle)"
	build_path = /obj/machinery/computer/arcade/battle
	origin_tech = "programming=1"
/obj/item/weapon/circuitboard/arcade/orion_trail
	name = "circuit board (Orion Trail)"
	build_path = /obj/machinery/computer/arcade/orion_trail
/obj/item/weapon/circuitboard/turbine_control
	name = "circuit board (Turbine control)"
	build_path = /obj/machinery/computer/turbine_computer
/obj/item/weapon/circuitboard/solar_control
	name = "circuit board (Solar Control)"  //name fixed 250810
	build_path = /obj/machinery/power/solar_control
	origin_tech = "programming=2;powerstorage=2"
/obj/item/weapon/circuitboard/powermonitor
	name = "circuit board (Power Monitor)"  //name fixed 250810
	build_path = /obj/machinery/computer/monitor
/obj/item/weapon/circuitboard/olddoor
	name = "circuit board (DoorMex)"
	build_path = /obj/machinery/computer/pod/old
/obj/item/weapon/circuitboard/syndicatedoor
	name = "circuit board (ProComp Executive)"
	build_path = /obj/machinery/computer/pod/old/syndicate
/obj/item/weapon/circuitboard/swfdoor
	name = "circuit board (Magix)"
	build_path = /obj/machinery/computer/pod/old/swf
/obj/item/weapon/circuitboard/prisoner
	name = "circuit board (Prisoner Management Console)"
	build_path = /obj/machinery/computer/prisoner
/obj/item/weapon/circuitboard/rdconsole
	name = "circuit board (RD Console)"
	build_path = /obj/machinery/computer/rdconsole/core
/obj/item/weapon/circuitboard/mecha_control
	name = "circuit board (Exosuit Control Console)"
	build_path = /obj/machinery/computer/mecha
/obj/item/weapon/circuitboard/rdservercontrol
	name = "circuit board (R&D Server Control)"
	build_path = /obj/machinery/computer/rdservercontrol
/obj/item/weapon/circuitboard/crew
	name = "circuit board (Crew Monitoring Console)"
	build_path = /obj/machinery/computer/crew
	origin_tech = "programming=3;biotech=2;magnets=2"
/obj/item/weapon/circuitboard/mech_bay_power_console
	name = "circuit board (Mech Bay Power Control Console)"
	build_path = /obj/machinery/computer/mech_bay_power_console
	origin_tech = "programming=2;powerstorage=3"
/obj/item/weapon/circuitboard/cargo
	name = "circuit board (Supply Console)"
	build_path = /obj/machinery/computer/cargo
	origin_tech = "programming=3"
	var/contraband = 0
/obj/item/weapon/circuitboard/cargo/request
	name = "circuit board (Supply Request Console)"
	build_path = /obj/machinery/computer/cargo/request
/obj/item/weapon/circuitboard/operating
	name = "circuit board (Operating Computer)"
	build_path = /obj/machinery/computer/operating
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/mining
	name = "circuit board (Outpost Status Display)"
	build_path = /obj/machinery/computer/security/mining
/obj/item/weapon/circuitboard/comm_monitor
	name = "circuit board (Telecommunications Monitor)"
	build_path = /obj/machinery/computer/telecomms/monitor
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/comm_server
	name = "circuit board (Telecommunications Server Monitor)"
	build_path = /obj/machinery/computer/telecomms/server
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/shuttle
	name = "circuit board (Shuttle)"
	build_path = /obj/machinery/computer/shuttle
	var/shuttleId
	var/possible_destinations = ""
/obj/item/weapon/circuitboard/labor_shuttle
	name = "circuit board (Labor Shuttle)"
	build_path = /obj/machinery/computer/shuttle/labor
/obj/item/weapon/circuitboard/labor_shuttle/one_way
	name = "circuit board (Prisoner Shuttle Console)"
	build_path = /obj/machinery/computer/shuttle/labor/one_way
/obj/item/weapon/circuitboard/ferry
	name = "circuit board (Transport Ferry)"
	build_path = /obj/machinery/computer/shuttle/ferry
/obj/item/weapon/circuitboard/ferry/request
	name = "circuit board (Transport Ferry Console)"
	build_path = /obj/machinery/computer/shuttle/ferry/request
/obj/item/weapon/circuitboard/mining_shuttle
	name = "circuit board (Mining Shuttle)"
	build_path = /obj/machinery/computer/shuttle/mining
/obj/item/weapon/circuitboard/white_ship
	name = "circuit board (White Ship)"
	build_path = /obj/machinery/computer/shuttle/white_ship
/obj/item/weapon/circuitboard/holodeck// Not going to let people get this, but it's just here for future
	name = "circuit board (Holodeck Control)"
	build_path = /obj/machinery/computer/holodeck
	origin_tech = "programming=4"
/obj/item/weapon/circuitboard/aifixer
	name = "circuit board (AI Integrity Restorer)"
	build_path = /obj/machinery/computer/aifixer
	origin_tech = "programming=3;biotech=2"
/*/obj/item/weapon/circuitboard/prison_shuttle
	name = "circuit board (Prison Shuttle)"
	build_path = /obj/machinery/computer/prison_shuttle*/
/obj/item/weapon/circuitboard/slot_machine
	name = "circuit board (Slot Machine)"
	build_path = /obj/machinery/computer/slot_machine
	origin_tech = "programming=1"
/obj/item/weapon/circuitboard/libraryconsole
	name = "circuit board (Library Visitor Console)"
	build_path = /obj/machinery/computer/libraryconsole
	origin_tech = "programming=1"

/obj/item/weapon/circuitboard/card/minor/attackby(obj/item/I, mob/user, params)
	if(istype(I,/obj/item/device/multitool))
		var/list/dept_list = list("general","security","medical","science","engineering")
		var/choice = input("Currently set to [dept_list[target_dept]] personnel database. Changing to:","Multitool-Circuitboard interface") as null|anything in dept_list
		if(choice)
			target_dept = dept_list.Find(choice)
	return

/obj/item/weapon/circuitboard/cargo/attackby(obj/item/I, mob/user, params)
	if(istype(I,/obj/item/device/multitool))
		contraband = !contraband
		user << "<span class='notice'>Receiver spectrum set to [contraband ? "Broad" : "Standard"].</span>"

/obj/item/weapon/circuitboard/rdconsole/attackby(obj/item/I, mob/user, params)
	if(istype(I,/obj/item/weapon/screwdriver))
		if(build_path == /obj/machinery/computer/rdconsole/core)
			name = "circuit board (RD Console - Robotics)"
			build_path = /obj/machinery/computer/rdconsole/robotics
			user << "<span class='notice'>Access protocols successfully updated.</span>"
		else
			name = "circuit board (RD Console)"
			build_path = /obj/machinery/computer/rdconsole/core
			user << "<span class='notice'>Defaulting access protocols.</span>"
	return

/obj/item/weapon/circuitboard/libraryconsole/attackby(obj/item/I, mob/user, params)
	if(istype(I,/obj/item/weapon/screwdriver))
		if(build_path == /obj/machinery/computer/libraryconsole/bookmanagement)
			name = "circuit board (Library Visitor Console)"
			build_path = /obj/machinery/computer/libraryconsole
			user << "<span class='notice'>Defaulting access protocols.</span>"
		else
			name = "circuit board (Book Inventory Management Console)"
			build_path = /obj/machinery/computer/libraryconsole/bookmanagement
			user << "<span class='notice'>Access protocols successfully updated.</span>"
	return

/obj/item/weapon/circuitboard/shuttle/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/multitool))
		var/chosen_id = round(input(usr, "Choose an ID number (-1 for reset):", "Input an Integer", null) as num|null)
		if(chosen_id >= 0)
			shuttleId = chosen_id
		else
			shuttleId = initial(shuttleId)
	return

/obj/structure/computerframe/attackby(obj/item/P, mob/user, params)
	add_fingerprint(user)
	switch(state)
		if(0)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				user << "<span class='notice'>You start wrenching the frame into place...</span>"
				if(do_after(user, 20/P.toolspeed, target = src))
					user << "<span class='notice'>You wrench the frame into place.</span>"
					anchored = 1
					state = 1
			if(istype(P, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = P
				if(!WT.remove_fuel(0, user))
					if(!WT.isOn())
						user << "<span class='warning'>The welding tool must be on to complete this task!</span>"
					return
				playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
				user << "<span class='notice'>You start deconstructing the frame...</span>"
				if(do_after(user, 20/P.toolspeed, target = src))
					if(!src || !WT.isOn()) return
					user << "<span class='notice'>You deconstruct the frame.</span>"
					var/obj/item/stack/sheet/metal/M = new (loc, 5)
					M.add_fingerprint(user)
					qdel(src)
		if(1)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				user << "<span class='notice'>You start to unfasten the frame...</span>"
				if(do_after(user, 20/P.toolspeed, target = src))
					user << "<span class='notice'>You unfasten the frame.</span>"
					anchored = 0
					state = 0
			if(istype(P, /obj/item/weapon/circuitboard) && !circuit)
				var/obj/item/weapon/circuitboard/B = P
				if(B.board_type == "computer")
					if(!user.drop_item())
						return
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					user << "<span class='notice'>You place the circuit board inside the frame.</span>"
					icon_state = "1"
					circuit = P
					circuit.add_fingerprint(user)
					P.loc = null
				else
					user << "<span class='warning'>This frame does not accept circuit boards of this type!</span>"
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "<span class='notice'>You screw the circuit board into place.</span>"
				state = 2
				icon_state = "2"
			if(istype(P, /obj/item/weapon/crowbar) && circuit)
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				user << "<span class='notice'>You remove the circuit board.</span>"
				state = 1
				icon_state = "0"
				circuit.loc = src.loc
				circuit.add_fingerprint(user)
				circuit = null
		if(2)
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "<span class='notice'>You unfasten the circuit board.</span>"
				state = 1
				icon_state = "1"
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if(C.get_amount() >= 5)
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					user << "<span class='notice'>You start adding cables to the frame...</span>"
					if(do_after(user, 20/P.toolspeed, target = src))
						if(C.get_amount() >= 5 && state == 2)
							C.use(5)
							user << "<span class='notice'>You add cables to the frame.</span>"
							state = 3
							icon_state = "3"
				else
					user << "<span class='warning'>You need five lengths of cable to wire the frame!</span>"
		if(3)
			if(istype(P, /obj/item/weapon/wirecutters))
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
				user << "<span class='notice'>You remove the cables.</span>"
				state = 2
				icon_state = "2"
				var/obj/item/stack/cable_coil/A = new (loc)
				A.amount = 5
				A.add_fingerprint(user)

			if(istype(P, /obj/item/stack/sheet/glass))
				var/obj/item/stack/sheet/glass/G = P
				if(G.get_amount() < 2)
					user << "<span class='warning'>You need two glass sheets to continue construction!</span>"
					return
				else
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					user << "<span class='notice'>You start to put in the glass panel...</span>"
					if(do_after(user, 20, target = src))
						if(G.get_amount() >= 2 && state == 3)
							G.use(2)
							user << "<span class='notice'>You put in the glass panel.</span>"
							state = 4
							src.icon_state = "4"
		if(4)
			if(istype(P, /obj/item/weapon/crowbar))
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				user << "<span class='notice'>You remove the glass panel.</span>"
				state = 3
				icon_state = "3"
				var/obj/item/stack/sheet/glass/G = new (loc, 2)
				G.add_fingerprint(user)
			if(istype(P, /obj/item/weapon/screwdriver))
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "<span class='notice'>You connect the monitor.</span>"
				var/obj/B = new src.circuit.build_path (src.loc, circuit)
				transfer_fingerprints_to(B)
				qdel(src)
