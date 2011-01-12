obj/door_assembly
	icon = 'door_assembly.dmi'

	name = "Airlock Assembly"
	icon_state = "door_as0"
	anchored = 0
	density = 1
	var/doortype = 0
	var/state = 0
	var/glass = 0
	var/obj/item/weapon/airlock_electronics/electronics = null

	door_assembly_0
		name = "Airlock Assembly"
		icon_state = "door_as1"
		anchored = 1
		density = 1
		doortype = 0
		state = 1
		glass = 0

	door_assembly_com
		name = "Command Airlock Assembly"
		icon_state = "door_as1_com"
		anchored = 1
		density = 1
		doortype = 1
		state = 1
		glass = 0

	door_assembly_sec
		name = "Security Airlock Assembly"
		icon_state = "door_as1_sec"
		anchored = 1
		density = 1
		doortype = 2
		state = 1
		glass = 0

	door_assembly_eng
		name = "Engineering Airlock Assembly"
		icon_state = "door_as1_eng"
		anchored = 1
		density = 1
		doortype = 3
		state = 1
		glass = 0

	door_assembly_med
		name = "Medical Airlock Assembly"
		icon_state = "door_as1_med"
		anchored = 1
		density = 1
		doortype = 4
		state = 1
		glass = 0

	door_assembly_mai
		name = "Maintenance Airlock Assembly"
		icon_state = "door_as1_mai"
		anchored = 1
		density = 1
		doortype = 5
		state = 1
		glass = 0

	door_assembly_ext
		name = "External Airlock Assembly"
		icon_state = "door_as1_ext"
		anchored = 1
		density = 1
		doortype = 6
		state = 1
		glass = 0

	door_assembly_g
		name = "Glass Airlock Assembly"
		icon_state = "door_as1_g"
		anchored = 1
		density = 1
		doortype = 7
		state = 1
		glass = 1

/obj/door_assembly/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/weldingtool) && W:welding && !anchored )
		if (W:get_fuel() < 1)
			user << "\blue You need more welding fuel to dissassemble the airlock assembly."
			return
		W:use_fuel(1)
		user.visible_message("[user] dissassembles the airlock assembly.", "You start to dissassemble the airlock assembly.")
		playsound(src.loc, 'Welder2.ogg', 50, 1)
		var/turf/T = get_turf(user)
		sleep(40)
		if(get_turf(user) == T)
			user << "\blue You dissasembled the airlock assembly!"
			new /obj/item/stack/sheet/metal(get_turf(src), 4)
			if(src.glass==1)
				new /obj/item/stack/sheet/rglass(get_turf(src))
			del(src)
	else if(istype(W, /obj/item/weapon/wrench) && !anchored )
		playsound(src.loc, 'Ratchet.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user.visible_message("[user] secures the airlock assembly to the floor.", "You start to secure the airlock assembly to the floor.")
		sleep(40)
		if(get_turf(user) == T)
			user << "\blue You secured the airlock assembly!"
			src.name = "Secured Airlock Assembly"
			src.anchored = 1
	else if(istype(W, /obj/item/weapon/wrench) && anchored )
		playsound(src.loc, 'Ratchet.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user.visible_message("[user] unsecures the airlock assembly from the floor.", "You start to unsecure the airlock assembly from the floor.")
		sleep(40)
		if(get_turf(user) == T)
			user << "\blue You unsecured the airlock assembly!"
			src.name = "Airlock Assembly"
			src.anchored = 0
	else if(istype(W, /obj/item/weapon/cable_coil) && state == 0 && anchored )
		var/obj/item/weapon/cable_coil/coil = W
		var/turf/T = get_turf(user)
		user.visible_message("[user] wires the airlock assembly.", "You start to wire the airlock assembly.")
		sleep(40)
		if(get_turf(user) == T)
			coil.use(1)
			src.state = 1
			switch(src.doortype)
				if(0) src.icon_state = "door_as1"
				if(1) src.icon_state = "door_as1_com"
				if(2) src.icon_state = "door_as1_sec"
				if(3) src.icon_state = "door_as1_eng"
				if(4) src.icon_state = "door_as1_med"
				if(5) src.icon_state = "door_as1_mai"
				if(6) src.icon_state = "door_as1_ext"
				if(7) src.icon_state = "door_as1_g"
			user << "\blue You wire the Airlock!"
			src.name = "Wired Airlock Assembly"
	else if(istype(W, /obj/item/weapon/wirecutters) && state == 1 )
		playsound(src.loc, 'Wirecutter.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user.visible_message("[user] cuts the wires from the airlock assembly.", "You start to cut the wires from airlock assembly.")
		sleep(40)
		if(get_turf(user) == T)
			user << "\blue You cut the airlock wires.!"
			new/obj/item/weapon/cable_coil(T, 1)
			src.state = 0
			switch(doortype)
				if(0) src.icon_state = "door_as0"
				if(1) src.icon_state = "door_as0_com"
				if(2) src.icon_state = "door_as0_sec"
				if(3) src.icon_state = "door_as0_eng"
				if(4) src.icon_state = "door_as0_med"
				if(5) src.icon_state = "door_as0_mai"
				if(6) src.icon_state = "door_as0_ext"
				if(7) src.icon_state = "door_as0_g"
			src.name = "Secured Airlock Assembly"
	else if(istype(W, /obj/item/weapon/airlock_electronics) && state == 1 )
		playsound(src.loc, 'Screwdriver.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user.visible_message("[user] installs the electronics into the airlock assembly.", "You start to install electronics into the airlock assembly.")
		user.drop_item()
		W.loc = src
		sleep(40)
		if(get_turf(user) == T)
			user << "\blue You installed the airlock electronics!"
			src.state = 2
			switch(src.doortype)
				if(0) src.icon_state = "door_as2"
				if(1) src.icon_state = "door_as2_com"
				if(2) src.icon_state = "door_as2_sec"
				if(3) src.icon_state = "door_as2_eng"
				if(4) src.icon_state = "door_as2_med"
				if(5) src.icon_state = "door_as2_mai"
				if(6) src.icon_state = "door_as2_ext"
				if(7) src.icon_state = "door_as2_g"
			src.name = "Near finished Airlock Assembly"
			src.electronics = W
		else
			W.loc = src.loc

			//del(W)
	else if(istype(W, /obj/item/weapon/crowbar) && state == 2 )
		playsound(src.loc, 'Crowbar.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user.visible_message("[user] removes the electronics from the airlock assembly.", "You start to install electronics into the airlock assembly.")
		sleep(40)
		if(get_turf(user) == T)
			user << "\blue You removed the airlock electronics!"
			src.state = 1
			switch(src.doortype)
				if(0) src.icon_state = "door_as1"
				if(1) src.icon_state = "door_as1_com"
				if(2) src.icon_state = "door_as1_sec"
				if(3) src.icon_state = "door_as1_eng"
				if(4) src.icon_state = "door_as1_med"
				if(5) src.icon_state = "door_as1_mai"
				if(6) src.icon_state = "door_as1_ext"
				if(7) src.icon_state = "door_as1_g"
			src.name = "Wired Airlock Assembly"
			var/obj/item/weapon/airlock_electronics/ae
			if (!electronics)
				ae = new/obj/item/weapon/airlock_electronics( src.loc )
			else
				ae = electronics
				electronics = null
				ae.loc = src.loc
	else if(istype(W, /obj/item/stack/sheet/rglass) && glass == 0)
		playsound(src.loc, 'Crowbar.ogg', 100, 1)
		user.visible_message("[user] adds reinforced glass windows to the airlock assembly.", "You start to install reinforced glass windows into the airlock assembly.")
		var/obj/item/stack/sheet/rglass/G = W
		if(do_after(user, 40) && G.amount>=1)
			user << "\blue You installed glass windows the airlock assembly!"
			G.use(1)
			src.glass = 1
			src.doortype = 7
			src.name = "Near finished Window Airlock Assembly"
			switch(src.state)
				if(0) src.icon_state = "door_as0_g"
				if(1) src.icon_state = "door_as1_g"
				if(2) src.icon_state = "door_as2_g"
				if(3) src.icon_state = "door_as3_g"
	else if(istype(W, /obj/item/weapon/screwdriver) && state == 2 )
		playsound(src.loc, 'Screwdriver.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user << "\blue Now finishing the airlock."
		sleep(40)
		if(get_turf(user) == T)
			user << "\blue You finish the airlock!"
			var/obj/machinery/door/airlock/door
			if (!src.glass)
				switch(src.doortype)
					if(0) door = new/obj/machinery/door/airlock( src.loc )
					if(1) door = new/obj/machinery/door/airlock/command( src.loc )
					if(2) door = new/obj/machinery/door/airlock/security( src.loc )
					if(3) door = new/obj/machinery/door/airlock/engineering( src.loc )
					if(4) door = new/obj/machinery/door/airlock/medical( src.loc )
					if(5) door = new/obj/machinery/door/airlock/maintenance( src.loc )
					if(6) door = new/obj/machinery/door/airlock/external( src.loc )
			else
				door = new/obj/machinery/door/airlock/glass( src.loc )
			//door.req_access = src.req_access
			door.electronics = src.electronics
			door.req_access = src.electronics.conf_access
			src.electronics.loc = door
			del(src)
	else
		..()