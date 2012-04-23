obj/structure/door_assembly
	icon = 'door_assembly.dmi'

	name = "Airlock Assembly"
	icon_state = "door_as0"
	anchored = 0
	density = 1
	var/state = 0
	var/glass = 0
	var/base_icon_state
	var/obj/item/weapon/airlock_electronics/electronics = null
	var/airlock_type = /obj/machinery/door/airlock //the type path of the airlock once completed
	var/glass_type = /obj/machinery/door/airlock/glass //the type path of the airlock if changed into a glass airlock
	var/glass_base_icon_state = "door_as_g"
	New()
		base_icon_state = copytext(icon_state,1,lentext(icon_state))

	door_assembly_0
		name = "Airlock Assembly"
		icon_state = "door_as1"
		airlock_type = /obj/machinery/door/airlock
		anchored = 1
		density = 1
		state = 1
		glass = 0

	door_assembly_com
		name = "Command Airlock Assembly"
		icon_state = "door_as_com1"
		glass_base_icon_state = "door_as_gcom"
		glass_type = /obj/machinery/door/airlock/glass/glass_command
		airlock_type = /obj/machinery/door/airlock/command
		anchored = 1
		density = 1
		state = 1
		glass = 0

		glass
			glass = 1
			icon_state = "door_as_gcom1"

	door_assembly_sec
		name = "Security Airlock Assembly"
		icon_state = "door_as_sec1"
		glass_base_icon_state = "door_as_gsec"
		glass_type = /obj/machinery/door/airlock/glass/glass_security
		airlock_type = /obj/machinery/door/airlock/security
		anchored = 1
		density = 1
		state = 1
		glass = 0

		glass
			glass = 1
			icon_state = "door_as_gsec1"

	door_assembly_eng
		name = "Engineering Airlock Assembly"
		icon_state = "door_as_eng1"
		glass_base_icon_state = "door_as_geng"
		glass_type = /obj/machinery/door/airlock/glass/glass_engineering
		airlock_type = /obj/machinery/door/airlock/engineering
		anchored = 1
		density = 1
		state = 1
		glass = 0

		glass
			glass = 1
			icon_state = "door_as_geng1"

	door_assembly_min
		name = "Mining Airlock Assembly"
		icon_state = "door_as_min1"
		airlock_type = /obj/machinery/door/airlock/mining
		anchored = 1
		density = 1
		state = 1
		glass = 0

	door_assembly_atmo
		name = "Atmospherics Airlock Assembly"
		icon_state = "door_as_atmo1"
		airlock_type = /obj/machinery/door/airlock/atmos
		anchored = 1
		density = 1
		state = 1
		glass = 0

	door_assembly_research
		name = "Research Airlock Assembly"
		icon_state = "door_as_res1"
		airlock_type = /obj/machinery/door/airlock/research
		anchored = 1
		density = 1
		state = 1
		glass = 0

	door_assembly_med
		name = "Medical Airlock Assembly"
		icon_state = "door_as_med1"
		glass_base_icon_state = "door_as_gmed"
		glass_type = /obj/machinery/door/airlock/glass/glass_medical
		airlock_type = /obj/machinery/door/airlock/medical
		anchored = 1
		density = 1
		state = 1
		glass = 0

		glass
			glass = 1
			icon_state = "door_as_gmed1"

	door_assembly_mai
		name = "Maintenance Airlock Assembly"
		icon_state = "door_as_mai1"
		glass_type = null
		airlock_type = /obj/machinery/door/airlock/maintenance
		anchored = 1
		density = 1
		state = 1
		glass = 0

	door_assembly_ext
		name = "External Airlock Assembly"
		icon_state = "door_as_ext1"
		glass_type = null
		airlock_type = /obj/machinery/door/airlock/external
		anchored = 1
		density = 1
		state = 1
		glass = 0

	door_assembly_fre
		name = "Freezer Airlock Assembly"
		icon_state = "door_as_fre1"
		glass_type = null
		airlock_type = /obj/machinery/door/airlock/freezer
		anchored = 1
		density = 1
		state = 1
		glass = 0

	door_assembly_mhatch
		name = "Airtight Maintenance Hatch Assembly"
		icon_state = "door_as_mhatch1"
		glass_type = null
		airlock_type = /obj/machinery/door/airlock/maintenance_hatch
		anchored = 1
		density = 1
		state = 1
		glass = 0

	door_assembly_g
		name = "Glass Airlock Assembly"
		icon_state = "door_as_g1"
		airlock_type = /obj/machinery/door/airlock/glass
		anchored = 1
		density = 1
		state = 1
		glass = 1

/obj/structure/door_assembly/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/weldingtool) && W:welding && !anchored )
		if (W:remove_fuel(0,user))
			W:welding = 2
			user.visible_message("[user] dissassembles the airlock assembly.", "You start to dissassemble the airlock assembly.")
			playsound(src.loc, 'Welder2.ogg', 50, 1)
			if(do_after(user, 40))
				user << "\blue You dissasembled the airlock assembly!"
				new /obj/item/stack/sheet/metal(get_turf(src), 4)
				if(src.glass==1)
					new /obj/item/stack/sheet/rglass(get_turf(src))
				del(src)
			W:welding = 1
		else
			user << "\blue You need more welding fuel to dissassemble the airlock assembly."
			return
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

			var/obj/item/weapon/airlock_electronics/E = W
			var/obj/structure/door_assembly/D = new E.style(loc)
			D.state = 2
			D.glass = glass
			if(glass)
				// just in case user is setting a glass door to a type that doesn't have a glass version
				if(ispath(D.glass_type))
					D.icon_state = "[D.glass_base_icon_state]2"
				else
					D.icon_state = "[D.base_icon_state]2"
					// type doesn't support glass, drop it
					D.glass = 0
					new/obj/item/stack/sheet/rglass(get_turf(src))
			D.name = "Near finished Airlock Assembly"
			E.loc = D
			D.electronics = W
			del(src)
		else
			W.loc = src.loc
	else if(istype(W, /obj/item/weapon/crowbar) && state == 2 )
		playsound(src.loc, 'Crowbar.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user.visible_message("[user] removes the electronics from the airlock assembly.", "You start to install electronics into the airlock assembly.")
		sleep(40)
		if(get_turf(user) == T)
			user << "\blue You removed the airlock electronics!"
			src.state = 1
			src.name = "Wired Airlock Assembly"
			var/obj/item/weapon/airlock_electronics/ae
			if (!electronics)
				ae = new/obj/item/weapon/airlock_electronics( src.loc )
			else
				ae = electronics
				electronics = null
				ae.loc = src.loc
	else if(istype(W, /obj/item/stack/sheet/rglass) && glass == 0 && ispath(glass_type))
		playsound(src.loc, 'Crowbar.ogg', 100, 1)
		user.visible_message("[user] adds reinforced glass windows to the airlock assembly.", "You start to install reinforced glass windows into the airlock assembly.")
		var/obj/item/stack/sheet/rglass/G = W
		if(do_after(user, 40))
			if(G)
				if(G.amount>=1)
					user << "\blue You installed glass windows into the airlock assembly!"
					G.use(1)
					src.glass = 1
					src.name = "Near finished Window Airlock Assembly"
					src.airlock_type = glass_type
	else if(istype(W, /obj/item/weapon/screwdriver) && state == 2 )
		playsound(src.loc, 'Screwdriver.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user << "\blue Now finishing the airlock."
		sleep(40)
		if(get_turf(user) == T)
			user << "\blue You finish the airlock!"
			var/obj/machinery/door/airlock/door
			if(glass)
				door = new src.glass_type( src.loc )
			else
				door = new src.airlock_type( src.loc )
			//door.req_access = src.req_access
			door.electronics = src.electronics
			door.req_access = src.electronics.conf_access
			src.electronics.loc = door
			del(src)
	else
		..()
	if(glass)
		icon_state = "[glass_base_icon_state][state]"
	else
		icon_state = "[base_icon_state][state]"
	//This updates the icon_state. They are named as "door_as1_eng" where the 1 in that example
	//represents what state it's in. So the most generic algorithm for the correct updating of
	//this is simply to change the number.