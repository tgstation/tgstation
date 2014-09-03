/obj/item/device/radio/intercom
	name = "station intercom"
	desc = "Talk through this."
	icon_state = "intercom"
	anchored = 1
	w_class = 4.0
	canhear_range = 2
	var/installed=1
	var/number = 0
	var/anyai = 1
	var/circuitry_installed=1
	var/mob/living/silicon/ai/ai = list()
	var/last_tick //used to delay the powercheck

/obj/item/device/radio/intercom/New(turf/loc, var/ndir, var/building=0)
	..()
	processing_objects += src

	// offset 24 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (building)

		pixel_x = (ndir & 3)? 0 : (ndir == 4 ? 24 : -24)
		pixel_y = (ndir & 3)? (ndir ==1 ? 24 : -24) : 0

		dir=SOUTH

	if (building!=0)
		b_stat=1
		on = 0
		circuitry_installed=0
		installed=0
		b_stat=1
	src.update_icon()

/obj/item/device/radio/intercom/Destroy()
	processing_objects -= src
	..()

/obj/item/device/radio/intercom/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	src.add_fingerprint(user)
	spawn (0)
		attack_self(user)

/obj/item/device/radio/intercom/attack_paw(mob/user as mob)
	return src.attack_hand(user)


/obj/item/device/radio/intercom/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	spawn (0)
		attack_self(user)

/obj/item/device/radio/intercom/receive_range(freq, level)
	if (!on || b_stat)
		return -1
	if (isWireCut(WIRE_RECEIVE))
		return -1
	if(!(0 in level))
		var/turf/position = get_turf(src)
		if(isnull(position) || !(position.z in level))
			return -1
	if (!src.listening)
		return -1
	if(freq == SYND_FREQ)
		if(!(src.syndie))
			return -1//Prevents broadcast of messages over devices lacking the encryption

	return canhear_range


/obj/item/device/radio/intercom/hear_talk(mob/M as mob, msg)
	if(!src.anyai && !(M in src.ai))
		return
	..()

/obj/item/device/radio/intercom/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(!installed)
		if(istype(W,/obj/item/weapon/cable_coil))
			if(!circuitry_installed)
				user << "\red You need to install intercom electronics first!"
				return 1
			playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
			if(do_after(user, 10))
				installed=1
				b_stat=0
				user << "\blue You wire \the [src]!"
			return 1
		if(istype(W,/obj/item/weapon/intercom_electronics))
			for(var/obj/item/weapon/intercom_electronics/board in src)
				user << "\red There's already an intercom electronics board inside!"
				return 1
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
			if(do_after(user, 10))
				user.drop_item()
				W.loc=src
				user << "\blue You insert \the [W] into \the [src]!"
			return 1
		if(istype(W,/obj/item/weapon/screwdriver))
			for(var/obj/item/weapon/intercom_electronics/board in src)
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				if(do_after(user, 10))
					del(board)
					circuitry_installed=1
					update_icon()
					user << "\blue You secure the electronics!"
				return 1
		if(istype(W,/obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT=W
			if(circuitry_installed)
				return ..()
			playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
			if(!WT.remove_fuel(3, user))
				user << "\red You're out of welding fuel."
				return 1
			if(do_after(user, 10))
				user << "\blue You cut the intercom frame from the wall!"
				new /obj/item/intercom_frame(src.loc)
				return 1
	else
		if(istype(W,/obj/item/weapon/crowbar))
			if(!b_stat || wires > 0)
				return ..()
			user << "You begin removing the electronics..."
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
			if(do_after(user, 10))
				new /obj/item/weapon/intercom_electronics(src.loc)
				user << "\blue The circuitboard pops out!"
				installed=0
				circuitry_installed=0
				b_stat=1
			return 1

	..()

/obj/item/device/radio/intercom/update_icon()
	if(!circuitry_installed)
		icon_state="intercom-frame"
		return
	icon_state = "intercom[!on?"-p":""][b_stat ? "-open":""]"

/obj/item/device/radio/intercom/process()
	if(((world.timeofday - last_tick) > 30) || ((world.timeofday - last_tick) < 0))
		last_tick = world.timeofday

		on = areaMaster.powered(EQUIP) // set "on" to the power status
		update_icon()

/obj/item/weapon/intercom_electronics
	name = "intercom electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	desc = "Looks like a circuit. Probably is."
	w_class = 2.0
	m_amt = 50
	g_amt = 50
	w_type = RECYK_ELECTRONIC