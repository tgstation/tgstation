/obj/computerframe
	density = 1
	anchored = 0
	name = "Computer-frame"
	icon = 'computer_frame.dmi'
	icon_state = "0"
	var/state = 0
	var/obj/item/weapon/circuitboard/circuit = null
//	weight = 1.0E8

/obj/item/weapon/circuitboard
	density = 0
	anchored = 0
	w_class = 2.0
	name = "Circuit board"
	icon = 'module.dmi'
	icon_state = "id_mod"
	item_state = "electronic"
	var/id = null
	var/frequency = null
	var/computertype = null
	var/powernet = null
	var/list/records = null

/obj/item/weapon/circuitboard/security
	name = "Circuit board (Security)"
	computertype = "/obj/machinery/computer/security"
/obj/item/weapon/circuitboard/aicore
	name = "Circuit board (AI core)"
/obj/item/weapon/circuitboard/aiupload
	name = "Circuit board (AI Upload)"
	computertype = "/obj/machinery/computer/aiupload"
/obj/item/weapon/circuitboard/med_data
	name = "Circuit board (Medical Records)"
	computertype = "/obj/machinery/computer/med_data"
/obj/item/weapon/circuitboard/pandemic
	name = "Circuit board (PanD.E.M.I.C. 2200)"
	computertype = "/obj/machinery/computer/pandemic"
/obj/item/weapon/circuitboard/scan_consolenew
	name = "Circuit board (DNA Machine)"
	computertype = "/obj/machinery/scan_consolenew"
/obj/item/weapon/circuitboard/communications
	name = "Circuit board (Communications)"
	computertype = "/obj/machinery/computer/communications"
/obj/item/weapon/circuitboard/card
	name = "Circuit board (ID Computer)"
	computertype = "/obj/machinery/computer/card"
//obj/item/weapon/circuitboard/shield
//	name = "Circuit board (Shield Control)"
//	computertype = "/obj/machinery/computer/stationshield"
/obj/item/weapon/circuitboard/teleporter
	name = "Circuit board (Teleporter)"
	computertype = "/obj/machinery/computer/teleporter"
/obj/item/weapon/circuitboard/secure_data
	name = "Circuit board (Security Records)"
	computertype = "/obj/machinery/computer/secure_data"
/obj/item/weapon/circuitboard/stationalert
	name = "Circuit board (Station Alerts)"
	computertype = "/obj/machinery/computer/station_alert"
/obj/item/weapon/circuitboard/atmospheresiphonswitch
	name = "Circuit board (Atmosphere siphon control)"
	computertype = "/obj/machinery/computer/atmosphere/siphonswitch"
/obj/item/weapon/circuitboard/air_management
	name = "Circuit board (Atmospheric monitor)"
	computertype = "/obj/machinery/computer/general_air_control"
/obj/item/weapon/circuitboard/injector_control
	name = "Circuit board (Injector control)"
	computertype = "/obj/machinery/computer/general_air_control/fuel_injection"
/obj/item/weapon/circuitboard/atmos_alert
	name = "Circuit board (Atmospheric Alert)"
	computertype = "/obj/machinery/computer/atmos_alert"
/obj/item/weapon/circuitboard/pod
	name = "Circuit board (Massdriver control)"
	computertype = "/obj/machinery/computer/pod"
/obj/item/weapon/circuitboard/robotics
	name = "Circuit board (Robotics Control)"
	computertype = "/obj/machinery/computer/robotics"
/obj/item/weapon/circuitboard/cloning
	name = "Circuit board (Cloning)"
	computertype = "/obj/machinery/computer/cloning"
/obj/item/weapon/circuitboard/arcade
	name = "Circuit board (Arcade)"
	computertype = "/obj/machinery/computer/arcade"
/obj/item/weapon/circuitboard/turbine_control
	name = "Circuit board (Turbine control)"
	computertype = "/obj/machinery/computer/turbine_computer"
/obj/item/weapon/circuitboard/solar_control
	name = "Circuit board (Solar Control)"  //name fixed 250810
	computertype = "/obj/machinery/power/solar_control"
/obj/item/weapon/circuitboard/powermonitor
	name = "Circuit board (Power Monitor)"  //name fixed 250810
	computertype = "/obj/machinery/power/monitor"
/obj/item/weapon/circuitboard/olddoor
	name = "Circuit board (DoorMex)"
	computertype = "/obj/machinery/computer/pod/old"
/obj/item/weapon/circuitboard/syndicatedoor
	name = "Circuit board (ProComp Executive)"
	computertype = "/obj/machinery/computer/pod/old/syndicate"
/obj/item/weapon/circuitboard/swfdoor
	name = "Circuit board (Magix)"
	computertype = "/obj/machinery/computer/pod/old/swf"
/obj/item/weapon/circuitboard/prisoner
	name = "Circuit board (Prisoner Management)"
	computertype = "/obj/machinery/computer/prisoner"
/obj/item/weapon/circuitboard/rdconsole
	name = "Circuit Board (RD Console)"
	computertype = "/obj/machinery/computer/rdconsole"



/obj/computerframe/attackby(obj/item/P as obj, mob/user as mob)
	switch(state)
		if(0)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(src.loc, 'Ratchet.ogg', 50, 1)
				if(do_after(user, 20))
					user << "\blue You wrench the frame into place."
					src.anchored = 1
					src.state = 1
			if(istype(P, /obj/item/weapon/weldingtool))
				playsound(src.loc, 'Welder.ogg', 50, 1)
				if(do_after(user, 20))
					user << "\blue You deconstruct the frame."
					new /obj/item/stack/sheet/metal( src.loc, 5 )
					del(src)
		if(1)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(src.loc, 'Ratchet.ogg', 50, 1)
				if(do_after(user, 20))
					user << "\blue You unfasten the frame."
					src.anchored = 0
					src.state = 0
			if(istype(P, /obj/item/weapon/circuitboard) && !circuit)
				playsound(src.loc, 'Deconstruct.ogg', 50, 1)
				user << "\blue You place the circuit board inside the frame."
				src.icon_state = "1"
				src.circuit = P
				user.drop_item()
				P.loc = src
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(src.loc, 'Screwdriver.ogg', 50, 1)
				user << "\blue You screw the circuit board into place."
				src.state = 2
				src.icon_state = "2"
			if(istype(P, /obj/item/weapon/crowbar) && circuit)
				playsound(src.loc, 'Crowbar.ogg', 50, 1)
				user << "\blue You remove the circuit board."
				src.state = 1
				src.icon_state = "0"
				circuit.loc = src.loc
				src.circuit = null
		if(2)
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(src.loc, 'Screwdriver.ogg', 50, 1)
				user << "\blue You unfasten the circuit board."
				src.state = 1
				src.icon_state = "1"
			if(istype(P, /obj/item/weapon/cable_coil))
				if(P:amount >= 5)
					playsound(src.loc, 'Deconstruct.ogg', 50, 1)
					if(do_after(user, 20))
						P:amount -= 5
						if(!P:amount) del(P)
						user << "\blue You add cables to the frame."
						src.state = 3
						src.icon_state = "3"
		if(3)
			if(istype(P, /obj/item/weapon/wirecutters))
				playsound(src.loc, 'wirecutter.ogg', 50, 1)
				user << "\blue You remove the cables."
				src.state = 2
				src.icon_state = "2"
				var/obj/item/weapon/cable_coil/A = new /obj/item/weapon/cable_coil( src.loc )
				A.amount = 5

			if(istype(P, /obj/item/stack/sheet/glass))
				if(P:amount >= 2)
					playsound(src.loc, 'Deconstruct.ogg', 50, 1)
					if(do_after(user, 20))
						P:use(2)
						user << "\blue You put in the glass panel."
						src.state = 4
						src.icon_state = "4"
		if(4)
			if(istype(P, /obj/item/weapon/crowbar))
				playsound(src.loc, 'Crowbar.ogg', 50, 1)
				user << "\blue You remove the glass panel."
				src.state = 3
				src.icon_state = "3"
				new /obj/item/stack/sheet/glass( src.loc, 2 )
			if(istype(P, /obj/item/weapon/screwdriver))
				playsound(src.loc, 'Screwdriver.ogg', 50, 1)
				user << "\blue You connect the monitor."
				var/B = new src.circuit.computertype ( src.loc )
				if(circuit.powernet) B:powernet = circuit.powernet
				if(circuit.id) B:id = circuit.id
				if(circuit.records) B:records = circuit.records
				if(circuit.frequency) B:frequency = circuit.frequency
				del(src)
