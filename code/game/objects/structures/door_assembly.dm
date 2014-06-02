obj/structure/door_assembly
	icon = 'icons/obj/doors/door_assembly.dmi'

	name = "Airlock Assembly"
	icon_state = "door_as_0"
	anchored = 0
	density = 1
	var/state = 0
	var/base_icon_state = ""
	var/base_name = "Airlock"
	var/obj/item/weapon/circuitboard/airlock/electronics = null
	var/airlock_type = "" //the type path of the airlock once completed
	var/glass_type = "/glass"
	var/glass = 0 // 0 = glass can be installed. -1 = glass can't be installed. 1 = glass is already installed. Text = mineral plating is installed instead.
	var/created_name = null

	New()
		update_state()

	door_assembly_com
		base_icon_state = "com"
		base_name = "Command Airlock"
		glass_type = "/glass_command"
		airlock_type = "/command"

	door_assembly_sec
		base_icon_state = "sec"
		base_name = "Security Airlock"
		glass_type = "/glass_security"
		airlock_type = "/security"

	door_assembly_eng
		base_icon_state = "eng"
		base_name = "Engineering Airlock"
		glass_type = "/glass_engineering"
		airlock_type = "/engineering"

	door_assembly_min
		base_icon_state = "min"
		base_name = "Mining Airlock"
		glass_type = "/glass_mining"
		airlock_type = "/mining"

	door_assembly_atmo
		base_icon_state = "atmo"
		base_name = "Atmospherics Airlock"
		glass_type = "/glass_atmos"
		airlock_type = "/atmos"

	door_assembly_research
		base_icon_state = "res"
		base_name = "Research Airlock"
		glass_type = "/glass_research"
		airlock_type = "/research"

	door_assembly_science
		base_icon_state = "sci"
		base_name = "Science Airlock"
		glass_type = "/glass_science"
		airlock_type = "/science"

	door_assembly_med
		base_icon_state = "med"
		base_name = "Medical Airlock"
		glass_type = "/glass_medical"
		airlock_type = "/medical"

	door_assembly_mai
		base_icon_state = "mai"
		base_name = "Maintenance Airlock"
		airlock_type = "/maintenance"
		glass = -1

	door_assembly_ext
		base_icon_state = "ext"
		base_name = "External Airlock"
		airlock_type = "/external"
		glass = -1

	door_assembly_fre
		base_icon_state = "fre"
		base_name = "Freezer Airlock"
		airlock_type = "/freezer"
		glass = -1

	door_assembly_hatch
		base_icon_state = "hatch"
		base_name = "Airtight Hatch"
		airlock_type = "/hatch"
		glass = -1

	door_assembly_mhatch
		base_icon_state = "mhatch"
		base_name = "Maintenance Hatch"
		airlock_type = "/maintenance_hatch"
		glass = -1

	door_assembly_highsecurity // Borrowing this until WJohnston makes sprites for the assembly
		base_icon_state = "highsec"
		base_name = "High Security Airlock"
		airlock_type = "/highsecurity"
		glass = -1

	multi_tile
		icon = 'icons/obj/doors/door_assembly2x1.dmi'
		dir = EAST
		var/width = 1

/*Temporary until we get sprites.
		glass_type = "/multi_tile/glass"
		airlock_type = "/multi_tile/maint"
		glass = 1*/
		base_icon_state = "g" //Remember to delete this line when reverting "glass" var to 1.
		airlock_type = "/multi_tile/glass"
		glass = -1 //To prevent bugs in deconstruction process.

		New()
			if(dir in list(EAST, WEST))
				bound_width = width * world.icon_size
				bound_height = world.icon_size
			else
				bound_width = world.icon_size
				bound_height = width * world.icon_size
			update_state()

		Move()
			. = ..()
			if(dir in list(EAST, WEST))
				bound_width = width * world.icon_size
				bound_height = world.icon_size
			else
				bound_width = world.icon_size
				bound_height = width * world.icon_size



/obj/structure/door_assembly/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/pen))
		var/t = copytext(stripped_input(user, "Enter the name for the door.", src.name, src.created_name),1,MAX_NAME_LEN)
		if(!t)	return
		if(!in_range(src, usr) && src.loc != usr)	return
		created_name = t
		return

	if(istype(W, /obj/item/weapon/weldingtool) && ( (istext(glass)) || (glass == 1) || (!anchored) ))
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.remove_fuel(0, user))
			playsound(get_turf(src), 'sound/items/Welder2.ogg', 50, 1)
			if(istext(glass))
				user.visible_message("[user] welds the [glass] plating off the airlock assembly.", "You start to weld the [glass] plating off the airlock assembly.")
				if(do_after(user, 40))
					if(!src || !WT.isOn()) return
					user << "\blue You welded the [glass] plating off!"
					var/M = text2path("/obj/item/stack/sheet/mineral/[glass]")
					new M(src.loc, 2)
					glass = 0
			else if(glass == 1)
				user.visible_message("[user] welds the glass panel out of the airlock assembly.", "You start to weld the glass panel out of the airlock assembly.")
				if(do_after(user, 40))
					if(!src || !WT.isOn()) return
					user << "\blue You welded the glass panel out!"
					new /obj/item/stack/sheet/rglass(src.loc)
					glass = 0
			else if(!anchored)
				user.visible_message("[user] dissassembles the airlock assembly.", "You start to dissassemble the airlock assembly.")
				if(do_after(user, 40))
					if(!src || !WT.isOn()) return
					user << "\blue You dissasembled the airlock assembly!"
					new /obj/item/stack/sheet/metal(src.loc, 4)
					del (src)
		else
			user << "\blue You need more welding fuel."
			return

	else if(istype(W, /obj/item/weapon/wrench) && state == 0)
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
		if(anchored)
			user.visible_message("[user] unsecures the airlock assembly from the floor.", "You start to unsecure the airlock assembly from the floor.")
		else
			user.visible_message("[user] secures the airlock assembly to the floor.", "You start to secure the airlock assembly to the floor.")

		if(do_after(user, 40))
			if(!src) return
			user << "\blue You [anchored? "un" : ""]secured the airlock assembly!"
			anchored = !anchored

	else if(istype(W, /obj/item/weapon/cable_coil) && state == 0 && anchored )
		var/obj/item/weapon/cable_coil/coil = W
		user.visible_message("[user] wires the airlock assembly.", "You start to wire the airlock assembly.")
		if(do_after(user, 40))
			if(!src) return
			coil.use(1)
			src.state = 1
			user << "\blue You wire the Airlock!"

	else if(istype(W, /obj/item/weapon/wirecutters) && state == 1 )
		playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 100, 1)
		user.visible_message("[user] cuts the wires from the airlock assembly.", "You start to cut the wires from airlock assembly.")

		if(do_after(user, 40))
			if(!src) return
			user << "\blue You cut the airlock wires.!"
			new/obj/item/weapon/cable_coil(src.loc, 1)
			src.state = 0

	else if(istype(W, /obj/item/weapon/circuitboard/airlock) && state == 1 && W:icon_state != "door_electronics_smoked")
		playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 100, 1)
		user.visible_message("[user] installs the electronics into the airlock assembly.", "You start to install electronics into the airlock assembly.")
		user.drop_item()
		W.loc = src

		if(do_after(user, 40))
			if(!src) return
			user << "\blue You installed the airlock electronics!"
			src.state = 2
			src.name = "Near finished Airlock Assembly"
			src.electronics = W
		else
			W.loc = src.loc

	else if(istype(W, /obj/item/weapon/crowbar) && state == 2 )
		playsound(get_turf(src), 'sound/items/Crowbar.ogg', 100, 1)
		user.visible_message("[user] removes the electronics from the airlock assembly.", "You start to install electronics into the airlock assembly.")

		if(do_after(user, 40))
			if(!src) return
			user << "\blue You removed the airlock electronics!"
			src.state = 1
			src.name = "Wired Airlock Assembly"
			var/obj/item/weapon/circuitboard/airlock/ae
			if (!electronics)
				ae = new/obj/item/weapon/circuitboard/airlock( src.loc )
			else
				ae = electronics
				electronics = null
				ae.loc = src.loc

	else if(istype(W, /obj/item/stack/sheet) && !glass)
		var/obj/item/stack/sheet/S = W
		if (S)
			if (S.amount>=1)
				if(istype(S, /obj/item/stack/sheet/rglass))
					playsound(get_turf(src), 'sound/items/Crowbar.ogg', 100, 1)
					user.visible_message("[user] adds [S.name] to the airlock assembly.", "You start to install [S.name] into the airlock assembly.")
					if(do_after(user, 40))
						user << "\blue You installed reinforced glass windows into the airlock assembly!"
						S.use(1)
						glass = 1
				else if(istype(S, /obj/item/stack/sheet/mineral) && S.sheettype)
					var/M = S.sheettype
					if(S.amount>=2)
						playsound(get_turf(src), 'sound/items/Crowbar.ogg', 100, 1)
						user.visible_message("[user] adds [S.name] to the airlock assembly.", "You start to install [S.name] into the airlock assembly.")
						if(do_after(user, 40))
							user << "\blue You installed [M] plating into the airlock assembly!"
							S.use(2)
							glass = "[M]"

	else if(istype(W, /obj/item/weapon/screwdriver) && state == 2 )
		playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 100, 1)
		user << "\blue Now finishing the airlock."

		if(do_after(user, 40))
			if(!src) return
			user << "\blue You finish the airlock!"
			var/path
			if(istext(glass))
				path = text2path("/obj/machinery/door/airlock/[glass]")
			else if (glass == 1)
				path = text2path("/obj/machinery/door/airlock[glass_type]")
			else
				path = text2path("/obj/machinery/door/airlock[airlock_type]")
			var/obj/machinery/door/airlock/door = new path(src.loc)
			door.assembly_type = type
			door.electronics = src.electronics
			door.fingerprints += src.fingerprints
			door.fingerprintshidden += src.fingerprintshidden
			door.fingerprintslast = user.ckey
			if(src.electronics.one_access)
				door.req_access = null
				door.req_one_access = src.electronics.conf_access
			else
				door.req_access = src.electronics.conf_access
			if(created_name)
				door.name = created_name
			else
				door.name = "[istext(glass) ? "[glass] airlock" : base_name]"
			src.electronics.loc = door
			del(src)
	else
		..()
	update_state()

/obj/structure/door_assembly/proc/update_state()
	icon_state = "door_as_[glass == 1 ? "g" : ""][istext(glass) ? glass : base_icon_state][state]"
	name = ""
	switch (state)
		if(0)
			if (anchored)
				name = "Secured "
		if(1)
			name = "Wired "
		if(2)
			name = "Near Finished "
	name += "[glass == 1 ? "Window " : ""][istext(glass) ? "[glass] Airlock" : base_name] Assembly"