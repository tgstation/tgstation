//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/structure/computerframe
	density = 1
	anchored = 0
	name = "Computer Frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "0"
	var/state = 0
	var/obj/item/weapon/circuitboard/circuit = null
//	weight = 1.0E8

/obj/item/weapon/circuitboard
	density = 0
	anchored = 0
	w_class = 2.0
	name = "Circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
	item_state = "circuitboard"
	origin_tech = "programming=2"
	starting_materials = list(MAT_GLASS = 2000) // Recycle glass only
	w_type = RECYK_ELECTRONIC

	var/id_tag = null
	var/frequency = null
	var/build_path = null
	var/board_type = "computer"
	var/list/req_components = null
	var/powernet = null
	var/list/records = null
	var/frame_desc = null
	var/contain_parts = 1

/obj/item/weapon/circuitboard/message_monitor
	name = "Circuit board (Message Monitor)"
	build_path = "/obj/machinery/computer/message_monitor"
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/security
	name = "Circuit board (Security)"
	build_path = "/obj/machinery/computer/security"
/obj/item/weapon/circuitboard/security/engineering
	name = "Circuit board (Engineering)"
	build_path = "/obj/machinery/computer/security/engineering"
/obj/item/weapon/circuitboard/aicore
	name = "Circuit board (AI core)"
	origin_tech = "programming=4;biotech=2"
	board_type = "other"
/obj/item/weapon/circuitboard/aiupload
	name = "Circuit board (AI Upload)"
	build_path = "/obj/machinery/computer/aiupload"
	origin_tech = "programming=4"
/obj/item/weapon/circuitboard/borgupload
	name = "Circuit board (Cyborg Upload)"
	build_path = "/obj/machinery/computer/borgupload"
	origin_tech = "programming=4"
/obj/item/weapon/circuitboard/med_data
	name = "Circuit board (Medical Records)"
	build_path = "/obj/machinery/computer/med_data"
/obj/item/weapon/circuitboard/pandemic
	name = "Circuit board (PanD.E.M.I.C. 2200)"
	build_path = "/obj/machinery/computer/pandemic"
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/scan_consolenew
	name = "Circuit board (DNA Machine)"
	build_path = "/obj/machinery/computer/scan_consolenew"
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/communications
	name = "Circuit board (Communications)"
	build_path = "/obj/machinery/computer/communications"
	origin_tech = "programming=2;magnets=2"
/obj/item/weapon/circuitboard/card
	name = "Circuit board (ID Computer)"
	build_path = "/obj/machinery/computer/card"
/obj/item/weapon/circuitboard/card/centcom
	name = "Circuit board (CentCom ID Computer)"
	build_path = "/obj/machinery/computer/card/centcom"
//obj/item/weapon/circuitboard/shield
//	name = "Circuit board (Shield Control)"
//	build_path = "/obj/machinery/computer/stationshield"
/obj/item/weapon/circuitboard/teleporter
	name = "Circuit board (Teleporter)"
	build_path = "/obj/machinery/computer/teleporter"
	origin_tech = "programming=2;bluespace=2"
/obj/item/weapon/circuitboard/secure_data
	name = "Circuit board (Security Records)"
	build_path = "/obj/machinery/computer/secure_data"
/obj/item/weapon/circuitboard/stationalert
	name = "Circuit board (Station Alerts)"
	build_path = "/obj/machinery/computer/station_alert"
/obj/item/weapon/circuitboard/atmospheresiphonswitch
	name = "Circuit board (Atmosphere siphon control)"
	build_path = "/obj/machinery/computer/atmosphere/siphonswitch"
/obj/item/weapon/circuitboard/air_management
	name = "Circuit board (Atmospheric General Monitor)"
	build_path = "/obj/machinery/computer/general_air_control"
/obj/item/weapon/circuitboard/atmos_automation
	name = "Circuit board (Atmospherics Automation)"
	build_path = "/obj/machinery/computer/general_air_control/atmos_automation"
/obj/item/weapon/circuitboard/large_tank_control
	name = "Circuit board (Atmospheric Tank Control)"
	build_path = "/obj/machinery/computer/general_air_control/large_tank_control"
/obj/item/weapon/circuitboard/injector_control
	name = "Circuit board (Injector control)"
	build_path = "/obj/machinery/computer/general_air_control/fuel_injection"
/obj/item/weapon/circuitboard/atmos_alert
	name = "Circuit board (Atmospheric Alert)"
	build_path = "/obj/machinery/computer/atmos_alert"
/obj/item/weapon/circuitboard/pod
	name = "Circuit board (Massdriver control)"
	build_path = "/obj/machinery/computer/pod"
/obj/item/weapon/circuitboard/pod/deathsquad
	name = "Circuit board (Deathsquad Massdriver control)"
	build_path = "/obj/machinery/computer/pod/deathsquad"
/obj/item/weapon/circuitboard/robotics
	name = "Circuit board (Robotics Control)"
	build_path = "/obj/machinery/computer/robotics"
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/cloning
	name = "Circuit board (Cloning Console)"
	build_path = "/obj/machinery/computer/cloning"
	origin_tech = "programming=3;biotech=3"
/obj/item/weapon/circuitboard/arcade
	name = "Circuit board (Arcade)"
	build_path = "/obj/machinery/computer/arcade"
	origin_tech = "programming=1"
	var/list/game_data = list()
/obj/item/weapon/circuitboard/turbine_control
	name = "Circuit board (Turbine control)"
	build_path = "/obj/machinery/computer/turbine_computer"
/obj/item/weapon/circuitboard/solar_control
	name = "Circuit board (Solar Control)"  //name fixed 250810
	build_path = "/obj/machinery/power/solar/control"
	origin_tech = "programming=2;powerstorage=2"
/obj/item/weapon/circuitboard/powermonitor
	name = "Circuit board (Power Monitor)"  //name fixed 250810
	build_path = "/obj/machinery/power/monitor"
/obj/item/weapon/circuitboard/olddoor
	name = "Circuit board (DoorMex)"
	build_path = "/obj/machinery/computer/pod/old"
/obj/item/weapon/circuitboard/syndicatedoor
	name = "Circuit board (ProComp Executive)"
	build_path = "/obj/machinery/computer/pod/old/syndicate"
/obj/item/weapon/circuitboard/swfdoor
	name = "Circuit board (Magix)"
	build_path = "/obj/machinery/computer/pod/old/swf"
/obj/item/weapon/circuitboard/prisoner
	name = "Circuit board (Prisoner Management)"
	build_path = "/obj/machinery/computer/prisoner"

/obj/item/weapon/circuitboard/rdconsole
	name = "Circuit Board (R&D Console)"
	build_path = "/obj/machinery/computer/rdconsole/core"
/obj/item/weapon/circuitboard/rdconsole/mommi
	name = "Circuit Board (MoMMI R&D Console)"
	build_path = "/obj/machinery/computer/rdconsole/mommi"
/obj/item/weapon/circuitboard/rdconsole/robotics
	name = "Circuit Board (Robotics R&D Console)"
	build_path = "/obj/machinery/computer/rdconsole/robotics"
/obj/item/weapon/circuitboard/rdconsole/mechanic
	name = "Circuit Board (Mechanic R&D Console)"
	build_path = "/obj/machinery/computer/rdconsole/mechanic"
/obj/item/weapon/circuitboard/rdconsole/pod
	name = "Circuit Board (Pod Bay R&D Console)"
	build_path = "/obj/machinery/computer/rdconsole/pod"

/obj/item/weapon/circuitboard/mecha_control
	name = "Circuit Board (Exosuit Control Console)"
	build_path = "/obj/machinery/computer/mecha"
/obj/item/weapon/circuitboard/rdservercontrol
	name = "Circuit Board (R&D Server Control)"
	build_path = "/obj/machinery/computer/rdservercontrol"
/obj/item/weapon/circuitboard/crew
	name = "Circuit board (Crew monitoring computer)"
	build_path = "/obj/machinery/computer/crew"
	origin_tech = "programming=3;biotech=2;magnets=2"
/obj/item/weapon/circuitboard/mech_bay_power_console
	name = "Circuit board (Mech Bay Power Control Console)"
	build_path = "/obj/machinery/computer/mech_bay_power_console"
	origin_tech = "programming=2;powerstorage=3"
/obj/item/weapon/circuitboard/ordercomp
	name = "Circuit board (Supply ordering console)"
	build_path = "/obj/machinery/computer/ordercomp"
	origin_tech = "programming=2"
/obj/item/weapon/circuitboard/supplycomp
	name = "Circuit board (Supply shuttle console)"
	build_path = "/obj/machinery/computer/supplycomp"
	origin_tech = "programming=3"
	var/contraband_enabled = 0
/obj/item/weapon/circuitboard/operating
	name = "Circuit board (Operating Computer)"
	build_path = "/obj/machinery/computer/operating"
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/mining
	name = "Circuit board (Outpost Status Display)"
	build_path = "/obj/machinery/computer/security/mining"
	origin_tech = "programming=2"
/obj/item/weapon/circuitboard/comm_monitor
	name = "Circuit board (Telecommunications Monitor)"
	build_path = "/obj/machinery/computer/telecomms/monitor"
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/comm_server
	name = "Circuit board (Telecommunications Server Monitor)"
	build_path = "/obj/machinery/computer/telecomms/server"
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/comm_traffic
	name = "Circuitboard (Telecommunications Traffic Control)"
	build_path = "/obj/machinery/computer/telecomms/traffic"
	origin_tech = "programming=3"

/obj/item/weapon/circuitboard/curefab
	name = "Circuit board (Cure fab)"
	build_path = "/obj/machinery/computer/curer"
/obj/item/weapon/circuitboard/splicer
	name = "Circuit board (Disease Splicer)"
	build_path = "/obj/machinery/computer/diseasesplicer"
	origin_tech = "programming=3;biotech=4"

/obj/item/weapon/circuitboard/shuttle_control
	name = "Circuit board (Shuttle Control)"
	build_path = "/obj/machinery/computer/shuttle_control"
	origin_tech = "programming=3;engineering=2"

/obj/item/weapon/circuitboard/HolodeckControl // Not going to let people get this, but it's just here for future
	name = "Circuit board (Holodeck Control)"
	build_path = "/obj/machinery/computer/HolodeckControl"
	origin_tech = "programming=4"
/obj/item/weapon/circuitboard/aifixer
	name = "Circuit board (AI Integrity Restorer)"
	build_path = "/obj/machinery/computer/aifixer"
	origin_tech = "programming=3;biotech=2"
/obj/item/weapon/circuitboard/area_atmos
	name = "Circuit board (Area Air Control)"
	build_path = "/obj/machinery/computer/area_atmos"
	origin_tech = "programming=2"
/obj/item/weapon/circuitboard/prison_shuttle
	name = "Circuit board (Prison Shuttle)"
	build_path = "/obj/machinery/computer/prison_shuttle"
	origin_tech = "programming=2"
/obj/item/weapon/circuitboard/bhangmeter
	name = "Circuit board (Bhangmeter)"
	build_path = "/obj/machinery/computer/bhangmeter"
	origin_tech = "programming=2"
/obj/item/weapon/circuitboard/telesci_computer
	name = "Circuit board (Telepad Control Console)"
	build_path = "/obj/machinery/computer/telescience"
	origin_tech = "programming=3;bluespace=2"
/obj/item/weapon/circuitboard/forensic_computer
	name = "Circuit board (Forensics Console)"
	build_path = "/obj/machinery/computer/forensic_scanning"
	origin_tech = "programming=2"
/obj/item/weapon/circuitboard/pda_terminal
	name = "Circuit board (PDA Terminal)"
	build_path = "/obj/machinery/computer/pda_terminal"
	origin_tech = "programming=2"

/obj/item/weapon/circuitboard/smeltcomp
	name = "Circuit board (Ore Processing Console)"
	build_path = "/obj/machinery/computer/smelting"
	origin_tech = "programming=2;materials=2"

/obj/item/weapon/circuitboard/stacking_machine_console
	name = "Circuit board (Stacking Machine Console)"
	build_path = "/obj/machinery/computer/stacking_unit"
	origin_tech = "programming=2;materials=2"

/obj/item/weapon/circuitboard/attackby(obj/item/I as obj, mob/user as mob)
	if(issolder(I))
		var/obj/item/weapon/solder/S = I
		if(S.remove_fuel(2,user))
			solder_improve(user)
	else if(iswelder(I))
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.remove_fuel(1,user))
			var/obj/item/weapon/circuitboard/blank/B = new /obj/item/weapon/circuitboard/blank(src.loc)
			if(user.get_inactive_hand() == src)
				user.before_take_item(src)
				user.put_in_hands(B)
			qdel(src)
			return
	return

/obj/item/weapon/circuitboard/proc/solder_improve(mob/user as mob)
	to_chat(user, "<span class='warning'>You fiddle with a few random fuses but can't find a routing that doesn't short the board.</span>")
	return

/obj/item/weapon/circuitboard/supplycomp/solder_improve(mob/user as mob)
	to_chat(user, "<span class='notice'>You [contraband_enabled ? "" : "un"]connect the mysterious fuse.</span>")
	contraband_enabled = !contraband_enabled
	return

/obj/item/weapon/circuitboard/security/solder_improve(mob/user as mob)
	if(istype(src,/obj/item/weapon/circuitboard/security/advanced))
		return ..()
	if(istype(src,/obj/item/weapon/circuitboard/security/engineering))
		return ..()
	else
		to_chat(user, "<span class='notice'>You locate a short that makes the feed circuitry more elegant.</span>")
		var/obj/item/weapon/circuitboard/security/advanced/A = new /obj/item/weapon/circuitboard/security/advanced(src.loc)
		user.put_in_hands(A)
		qdel(src)
		return

/obj/structure/computerframe/attackby(obj/item/P as obj, mob/user as mob)
	switch(state)
		if(0)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
				if(do_after(user, src, 5) && state == 0)
					to_chat(user, "<span class='notice'>You wrench the frame into place.</span>")
					src.anchored = 1
					src.state = 1
				return 1
			if(istype(P, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = P
				if(!WT.remove_fuel(0, user))
					to_chat(user, "The welding tool must be on to complete this task.")
					return 1
				playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
				if(do_after(user, src, 10) && state == 0)
					if(!src || !WT.isOn()) return
					to_chat(user, "<span class='notice'>You deconstruct the frame.</span>")
					var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, src.loc)
					M.amount = 5
					state = -1
					qdel(src)
				return 1
		if(1)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
				if(do_after(user, src, 20) && state == 1)
					to_chat(user, "<span class='notice'>You unfasten the frame.</span>")
					src.anchored = 0
					src.state = 0
				return 1
			if(istype(P, /obj/item/weapon/circuitboard) && !circuit)
				var/obj/item/weapon/circuitboard/B = P
				if(B.board_type == "computer")
					playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
					to_chat(user, "<span class='notice'>You place the circuit board inside the frame.</span>")
					src.icon_state = "1"
					src.circuit = P
					user.drop_item(B, src)
				else
					to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
				return 1
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You screw the circuit board into place.</span>")
				src.state = 2
				src.icon_state = "2"
				return 1
			if(istype(P, /obj/item/weapon/crowbar) && circuit)
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
				src.state = 1
				src.icon_state = "0"
				circuit.loc = src.loc
				src.circuit = null
				return 1
		if(2)
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You unfasten the circuit board.</span>")
				src.state = 1
				src.icon_state = "1"
				return 1
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if (C.amount < 5)
					to_chat(user, "<span class='warning'>You need at least 5 lengths of cable coil for this!</span>")
					return 1

				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				if (do_after(user, src, 20) && state == 2 && C.amount >= 5)
					C.use(5)
					to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
					src.state = 3
					src.icon_state = "3"

				return 1
		if(3)
			if(istype(P, /obj/item/weapon/wirecutters))
				playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You remove the cables.</span>")
				src.state = 2
				src.icon_state = "2"
				getFromPool(/obj/item/stack/cable_coil, get_turf(src), 5)
				return 1

			if(istype(P, /obj/item/stack/sheet/glass/glass))
				var/obj/item/stack/sheet/glass/glass/G = P
				if (G.amount < 2)
					to_chat(user, "<span class='warning'>You need at least 2 sheets of glass for this!</span>")
					return 1

				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				if(do_after(user, src, 20) && state == 3 && G.amount >= 2)
					G.use(2)
					to_chat(user, "<span class='notice'>You put in the glass panel.</span>")
					src.state = 4
					src.icon_state = "4"

				return 1
		if(4)
			if(istype(P, /obj/item/weapon/crowbar))
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You remove the glass panel.</span>")
				src.state = 3
				src.icon_state = "3"
				new /obj/item/stack/sheet/glass/glass( src.loc, 2 )
				return 1
			if(istype(P, /obj/item/weapon/screwdriver))
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You connect the monitor.</span>")
				var/B = new src.circuit.build_path ( src.loc )
				if(circuit.powernet) B:powernet = circuit.powernet
				if(circuit.id_tag) B:id_tag = circuit.id_tag
				if(circuit.records) B:records = circuit.records
				if(circuit.frequency) B:frequency = circuit.frequency
				if(istype(circuit,/obj/item/weapon/circuitboard/supplycomp))
					var/obj/machinery/computer/supplycomp/SC = B
					var/obj/item/weapon/circuitboard/supplycomp/C = circuit
					SC.can_order_contraband = C.contraband_enabled
				else if(istype(circuit,/obj/item/weapon/circuitboard/arcade))
					var/obj/machinery/computer/arcade/arcade = B
					var/obj/item/weapon/circuitboard/arcade/C = circuit
					arcade.import_game_data(C)
				qdel(src)
				return 1
	return 0
