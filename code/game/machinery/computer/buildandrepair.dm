/obj/structure/frame/computer
	name = "computer frame"
	icon_state = "0"
	state = 0

/obj/structure/frame/computer/attackby(obj/item/P, mob/user, params)
	add_fingerprint(user)
	switch(state)
		if(0)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(src.loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You start wrenching the frame into place...</span>")
				if(do_after(user, 20*P.toolspeed, target = src))
					to_chat(user, "<span class='notice'>You wrench the frame into place.</span>")
					anchored = TRUE
					state = 1
				return
			if(istype(P, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = P
				if(!WT.remove_fuel(0, user))
					if(!WT.isOn())
						to_chat(user, "<span class='warning'>The welding tool must be on to complete this task!</span>")
					return
				playsound(src.loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You start deconstructing the frame...</span>")
				if(do_after(user, 20*P.toolspeed, target = src))
					if(!src || !WT.isOn()) return
					to_chat(user, "<span class='notice'>You deconstruct the frame.</span>")
					var/obj/item/stack/sheet/metal/M = new (loc, 5)
					M.add_fingerprint(user)
					qdel(src)
				return
		if(1)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(src.loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You start to unfasten the frame...</span>")
				if(do_after(user, 20*P.toolspeed, target = src))
					to_chat(user, "<span class='notice'>You unfasten the frame.</span>")
					anchored = FALSE
					state = 0
				return
			if(istype(P, /obj/item/weapon/circuitboard/computer) && !circuit)
				if(!user.drop_item())
					return
				playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You place the circuit board inside the frame.</span>")
				icon_state = "1"
				circuit = P
				circuit.add_fingerprint(user)
				P.loc = null
				return

			else if(istype(P, /obj/item/weapon/circuitboard) && !circuit)
				to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
				return
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(src.loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You screw the circuit board into place.</span>")
				state = 2
				icon_state = "2"
				return
			if(istype(P, /obj/item/weapon/crowbar) && circuit)
				playsound(src.loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
				state = 1
				icon_state = "0"
				circuit.loc = src.loc
				circuit.add_fingerprint(user)
				circuit = null
				return
		if(2)
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(src.loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You unfasten the circuit board.</span>")
				state = 1
				icon_state = "1"
				return
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if(C.get_amount() >= 5)
					playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
					to_chat(user, "<span class='notice'>You start adding cables to the frame...</span>")
					if(do_after(user, 20*P.toolspeed, target = src))
						if(C.get_amount() >= 5 && state == 2)
							C.use(5)
							to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
							state = 3
							icon_state = "3"
				else
					to_chat(user, "<span class='warning'>You need five lengths of cable to wire the frame!</span>")
				return
		if(3)
			if(istype(P, /obj/item/weapon/wirecutters))
				playsound(src.loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the cables.</span>")
				state = 2
				icon_state = "2"
				var/obj/item/stack/cable_coil/A = new (loc)
				A.amount = 5
				A.add_fingerprint(user)
				return

			if(istype(P, /obj/item/stack/sheet/glass))
				var/obj/item/stack/sheet/glass/G = P
				if(G.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need two glass sheets to continue construction!</span>")
					return
				else
					playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
					to_chat(user, "<span class='notice'>You start to put in the glass panel...</span>")
					if(do_after(user, 20, target = src))
						if(G.get_amount() >= 2 && state == 3)
							G.use(2)
							to_chat(user, "<span class='notice'>You put in the glass panel.</span>")
							state = 4
							src.icon_state = "4"
				return
		if(4)
			if(istype(P, /obj/item/weapon/crowbar))
				playsound(src.loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the glass panel.</span>")
				state = 3
				icon_state = "3"
				var/obj/item/stack/sheet/glass/G = new (loc, 2)
				G.add_fingerprint(user)
				return
			if(istype(P, /obj/item/weapon/screwdriver))
				playsound(src.loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You connect the monitor.</span>")
				var/obj/B = new src.circuit.build_path (src.loc, circuit)
				transfer_fingerprints_to(B)
				qdel(src)
				return
	if(user.a_intent == INTENT_HARM)
		return ..()


/obj/structure/frame/computer/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(state == 4)
			new /obj/item/weapon/shard(loc)
			new /obj/item/weapon/shard(loc)
		if(state >= 3)
			new /obj/item/stack/cable_coil(loc , 5)
	..()


/obj/item/weapon/circuitboard
	name = "circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
	item_state = "electronic"
	origin_tech = "programming=2"
	materials = list(MAT_GLASS=1000)
	w_class = WEIGHT_CLASS_SMALL
	var/build_path = null

/obj/item/weapon/circuitboard/computer/turbine_computer
	name = "Turbine Computer (Computer Board)"
	build_path = /obj/machinery/computer/turbine_computer
	origin_tech = "programming=4;engineering=4;powerstorage=4"
/obj/item/weapon/circuitboard/computer/launchpad_console
	name = "Launchpad Control Console (Computer Board)"
	build_path = /obj/machinery/computer/launchpad
	origin_tech = "programming=3;bluespace=3;plasmatech=2"
/obj/item/weapon/circuitboard/computer/message_monitor
	name = "Message Monitor (Computer Board)"
	build_path = /obj/machinery/computer/message_monitor
	origin_tech = "programming=2"
/obj/item/weapon/circuitboard/computer/security
	name = "Security Cameras (Computer Board)"
	build_path = /obj/machinery/computer/security
	origin_tech = "programming=2;combat=2"
/obj/item/weapon/circuitboard/computer/xenobiology
	name = "circuit board (Xenobiology Console)"
	build_path = /obj/machinery/computer/camera_advanced/xenobio
	origin_tech = "programming=3;biotech=3"
/obj/item/weapon/circuitboard/computer/base_construction
	name = "circuit board (Aux Mining Base Construction Console)"
	build_path = /obj/machinery/computer/camera_advanced/base_construction
	origin_tech = "programming=3;engineering=3"
/obj/item/weapon/circuitboard/computer/aiupload
	name = "AI Upload (Computer Board)"
	build_path = /obj/machinery/computer/upload/ai
	origin_tech = "programming=4;engineering=4"
/obj/item/weapon/circuitboard/computer/borgupload
	name = "Cyborg Upload (Computer Board)"
	build_path = /obj/machinery/computer/upload/borg
	origin_tech = "programming=4;engineering=4"
/obj/item/weapon/circuitboard/computer/med_data
	name = "Medical Records Console (Computer Board)"
	build_path = /obj/machinery/computer/med_data
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/computer/pandemic
	name = "PanD.E.M.I.C. 2200 (Computer Board)"
	build_path = /obj/machinery/computer/pandemic
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/computer/scan_consolenew
	name = "DNA Machine (Computer Board)"
	build_path = /obj/machinery/computer/scan_consolenew
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/computer/communications
	name = "Communications (Computer Board)"
	build_path = /obj/machinery/computer/communications
	origin_tech = "programming=3;magnets=3"
	var/lastTimeUsed = 0

/obj/item/weapon/circuitboard/computer/card
	name = "ID Console (Computer Board)"
	build_path = /obj/machinery/computer/card
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/computer/card/centcom
	name = "Centcom ID Console (Computer Board)"
	build_path = /obj/machinery/computer/card/centcom

/obj/item/weapon/circuitboard/computer/card/minor
	name = "Department Management Console (Computer Board)"
	build_path = /obj/machinery/computer/card/minor
	var/target_dept = 1
	var/list/dept_list = list("General","Security","Medical","Science","Engineering")

/obj/item/weapon/circuitboard/computer/card/minor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		target_dept = (target_dept == dept_list.len) ? 1 : (target_dept + 1)
		to_chat(user, "<span class='notice'>You set the board to \"[dept_list[target_dept]]\".</span>")
	else
		return ..()

/obj/item/weapon/circuitboard/computer/card/minor/examine(user)
	..()
	to_chat(user, "Currently set to \"[dept_list[target_dept]]\".")

//obj/item/weapon/circuitboard/computer/shield
//	name = "Shield Control (Computer Board)"
//	build_path = /obj/machinery/computer/stationshield
/obj/item/weapon/circuitboard/computer/teleporter
	name = "Teleporter (Computer Board)"
	build_path = /obj/machinery/computer/teleporter
	origin_tech = "programming=3;bluespace=3;plasmatech=3"
/obj/item/weapon/circuitboard/computer/secure_data
	name = "Security Records Console (Computer Board)"
	build_path = /obj/machinery/computer/secure_data
	origin_tech = "programming=2;combat=2"
/obj/item/weapon/circuitboard/computer/stationalert
	name = "Station Alerts (Computer Board)"
	build_path = /obj/machinery/computer/station_alert
/*/obj/item/weapon/circuitboard/computer/atmospheresiphonswitch
	name = "Atmosphere siphon control (Computer Board)"
	build_path = /obj/machinery/computer/atmosphere/siphonswitch*/
/obj/item/weapon/circuitboard/computer/atmos_control
	name = "Atmospheric Monitor (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control
/obj/item/weapon/circuitboard/computer/atmos_control/tank
	name = "Tank Control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank
	origin_tech = "programming=2;engineering=3;materials=2"
/obj/item/weapon/circuitboard/computer/atmos_alert
	name = "Atmospheric Alert (Computer Board)"
	build_path = /obj/machinery/computer/atmos_alert
/obj/item/weapon/circuitboard/computer/pod
	name = "Massdriver control (Computer Board)"
	build_path = /obj/machinery/computer/pod
/obj/item/weapon/circuitboard/computer/robotics
	name = "Robotics Control (Computer Board)"
	build_path = /obj/machinery/computer/robotics
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/computer/cloning
	name = "Cloning (Computer Board)"
	build_path = /obj/machinery/computer/cloning
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/computer/arcade/battle
	name = "Arcade Battle (Computer Board)"
	build_path = /obj/machinery/computer/arcade/battle
	origin_tech = "programming=1"
/obj/item/weapon/circuitboard/computer/arcade/orion_trail
	name = "Orion Trail (Computer Board)"
	build_path = /obj/machinery/computer/arcade/orion_trail
	origin_tech = "programming=1"
/obj/item/weapon/circuitboard/computer/turbine_control
	name = "Turbine control (Computer Board)"
	build_path = /obj/machinery/computer/turbine_computer
/obj/item/weapon/circuitboard/computer/solar_control
	name = "Solar Control (Computer Board)"  //name fixed 250810
	build_path = /obj/machinery/power/solar_control
	origin_tech = "programming=2;powerstorage=2"
/obj/item/weapon/circuitboard/computer/powermonitor
	name = "Power Monitor (Computer Board)"  //name fixed 250810
	build_path = /obj/machinery/computer/monitor
	origin_tech = "programming=2;powerstorage=2"
/obj/item/weapon/circuitboard/computer/olddoor
	name = "DoorMex (Computer Board)"
	build_path = /obj/machinery/computer/pod/old
/obj/item/weapon/circuitboard/computer/syndicatedoor
	name = "ProComp Executive (Computer Board)"
	build_path = /obj/machinery/computer/pod/old/syndicate
/obj/item/weapon/circuitboard/computer/swfdoor
	name = "Magix (Computer Board)"
	build_path = /obj/machinery/computer/pod/old/swf
/obj/item/weapon/circuitboard/computer/prisoner
	name = "Prisoner Management Console (Computer Board)"
	build_path = /obj/machinery/computer/prisoner
/obj/item/weapon/circuitboard/computer/gulag_teleporter_console
	name = "Labor Camp teleporter console (Computer Board)"
	build_path = /obj/machinery/computer/gulag_teleporter_computer

/obj/item/weapon/circuitboard/computer/rdconsole
	name = "R&D Console (Computer Board)"
	build_path = /obj/machinery/computer/rdconsole/core

/obj/item/weapon/circuitboard/computer/rdconsole/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
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

/obj/item/weapon/circuitboard/computer/mecha_control
	name = "Exosuit Control Console (Computer Board)"
	build_path = /obj/machinery/computer/mecha
/obj/item/weapon/circuitboard/computer/rdservercontrol
	name = "R&D Server Control (Computer Board)"
	build_path = /obj/machinery/computer/rdservercontrol
/obj/item/weapon/circuitboard/computer/crew
	name = "Crew Monitoring Console (Computer Board)"
	build_path = /obj/machinery/computer/crew
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/computer/mech_bay_power_console
	name = "Mech Bay Power Control Console (Computer Board)"
	build_path = /obj/machinery/computer/mech_bay_power_console
	origin_tech = "programming=3;powerstorage=3"

/obj/item/weapon/circuitboard/computer/cargo
	name = "Supply Console (Computer Board)"
	build_path = /obj/machinery/computer/cargo
	origin_tech = "programming=3"
	var/contraband = FALSE
	var/emagged = FALSE

/obj/item/weapon/circuitboard/computer/cargo/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/multitool))
		if(!emagged)
			contraband = !contraband
			to_chat(user, "<span class='notice'>Receiver spectrum set to [contraband ? "Broad" : "Standard"].</span>")
		else
			to_chat(user, "<span class='notice'>The spectrum chip is unresponsive.</span>")
	else if(istype(I, /obj/item/weapon/card/emag))
		if(!emagged)
			contraband = TRUE
			emagged = TRUE
			to_chat(user, "<span class='notice'>You adjust [src]'s routing and receiver spectrum, unlocking special supplies and contraband.</span>")
	else
		return ..()


/obj/item/weapon/circuitboard/computer/cargo/request
	name = "Supply Request Console (Computer Board)"
	build_path = /obj/machinery/computer/cargo/request
/obj/item/weapon/circuitboard/computer/stockexchange
	name = "circuit board (Stock Exchange Console)"
	build_path = /obj/machinery/computer/stockexchange
	origin_tech = "programming=3"

/obj/item/weapon/circuitboard/computer/operating
	name = "Operating Computer (Computer Board)"
	build_path = /obj/machinery/computer/operating
	origin_tech = "programming=2;biotech=3"
/obj/item/weapon/circuitboard/computer/mining
	name = "Outpost Status Display (Computer Board)"
	build_path = /obj/machinery/computer/security/mining
/obj/item/weapon/circuitboard/computer/comm_monitor
	name = "Telecommunications Monitor (Computer Board)"
	build_path = /obj/machinery/computer/telecomms/monitor
	origin_tech = "programming=3;magnets=3;bluespace=2"
/obj/item/weapon/circuitboard/computer/comm_server
	name = "Telecommunications Server Monitor (Computer Board)"
	build_path = /obj/machinery/computer/telecomms/server
	origin_tech = "programming=3;magnets=3;bluespace=2"

/obj/item/weapon/circuitboard/computer/shuttle
	name = "Shuttle (Computer Board)"
	build_path = /obj/machinery/computer/shuttle
	var/shuttleId
	var/possible_destinations = ""

/obj/item/weapon/circuitboard/computer/shuttle/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/multitool))
		var/chosen_id = round(input(usr, "Choose an ID number (-1 for reset):", "Input an Integer", null) as num|null)
		if(chosen_id >= 0)
			shuttleId = chosen_id
		else
			shuttleId = initial(shuttleId)
	else
		return ..()

/obj/item/weapon/circuitboard/computer/labor_shuttle
	name = "Labor Shuttle (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/labor
/obj/item/weapon/circuitboard/computer/labor_shuttle/one_way
	name = "Prisoner Shuttle Console (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/labor/one_way
/obj/item/weapon/circuitboard/computer/ferry
	name = "Transport Ferry (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/ferry
/obj/item/weapon/circuitboard/computer/ferry/request
	name = "Transport Ferry Console (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/ferry/request
/obj/item/weapon/circuitboard/computer/mining_shuttle
	name = "Mining Shuttle (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/mining
/obj/item/weapon/circuitboard/computer/white_ship
	name = "White Ship (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/white_ship
/obj/item/weapon/circuitboard/computer/auxillary_base
	name = "Auxillary Base Management Console (Computer Board)"
	build_path = /obj/machinery/computer/auxillary_base
/obj/item/weapon/circuitboard/computer/holodeck// Not going to let people get this, but it's just here for future
	name = "Holodeck Control (Computer Board)"
	build_path = /obj/machinery/computer/holodeck
	origin_tech = "programming=4"
/obj/item/weapon/circuitboard/computer/aifixer
	name = "AI Integrity Restorer (Computer Board)"
	build_path = /obj/machinery/computer/aifixer
	origin_tech = "programming=2;biotech=2"
/*/obj/item/weapon/circuitboard/computer/prison_shuttle
	name = "Prison Shuttle (Computer Board)"
	build_path = /obj/machinery/computer/prison_shuttle*/
/obj/item/weapon/circuitboard/computer/slot_machine
	name = "Slot Machine (Computer Board)"
	build_path = /obj/machinery/computer/slot_machine
	origin_tech = "programming=1"

/obj/item/weapon/circuitboard/computer/libraryconsole
	name = "Library Visitor Console (Computer Board)"
	build_path = /obj/machinery/computer/libraryconsole
	origin_tech = "programming=1"

/obj/item/weapon/circuitboard/computer/libraryconsole/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
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

/obj/item/weapon/circuitboard/computer/apc_control
	name = "\improper Power Flow Control Console (Computer Board)"
	build_path = /obj/machinery/computer/apc_control
	origin_tech = "programming=3;engineering=3;powerstorage=2"
