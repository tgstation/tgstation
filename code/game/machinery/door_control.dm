/obj/machinery/door_control
	name = "remote door-control"
	desc = "It controls doors, remotely."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A remote control-switch for a door."
	power_channel = ENVIRON
	var/id = null
	var/normaldoorcontrol = 0
	var/specialfunctions = 1
	/*
	Bitflag, 	1= open
				2= idscan,
				4= bolts
				8= shock
				16= door safties

	*/

	var/exposedwires = 0
	var/wires = 3
	/*
	Bitflag,	1=checkID
				2=Network Access
	*/

	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/door_control/attack_ai(mob/user)
	if(wires & 2)
		return src.attack_hand(user)
	else
		user << "Error, no route to host."

/obj/machinery/door_control/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/machinery/door_control/attackby(obj/item/weapon/W, mob/user, params)
	/* For later implementation
	if (istype(W, /obj/item/weapon/screwdriver))
	{
		if(wiresexposed)
			icon_state = "doorctrl0"
			wiresexposed = 0

		else
			icon_state = "doorctrl-open"
			wiresexposed = 1

		return
	}
	*/
	if(istype(W, /obj/item/device/detective_scanner))
		return
	return src.attack_hand(user)

/obj/machinery/door_control/emag_act(mob/user)
	req_access = list()
	req_one_access = list()
	playsound(src.loc, "sparks", 100, 1)

/obj/machinery/door_control/attack_hand(mob/user)
	src.add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		return

	if(!allowed(user) && (wires & 1))
		user << "<span class='danger'>Access Denied</span>"
		flick("doorctrl-denied",src)
		return

	use_power(5)
	icon_state = "doorctrl1"
	add_fingerprint(user)

	if(normaldoorcontrol)
		for(var/obj/machinery/door/airlock/D in world)
			if(D.id_tag == src.id)
				if(specialfunctions & OPEN)
					spawn(0)
						if(D)
							if(D.density)	D.open()
							else			D.close()
						return
				if(specialfunctions & IDSCAN)
					D.aiDisabledIdScanner = !D.aiDisabledIdScanner
				if(specialfunctions & BOLTS)
					if(!D.isWireCut(4) && D.hasPower())
						D.locked = !D.locked
						D.update_icon()
				if(specialfunctions & SHOCK)
					D.secondsElectrified = D.secondsElectrified ? 0 : -1
				if(specialfunctions & SAFE)
					D.safe = !D.safe
	else
		var/openclose
		for(var/obj/machinery/door/poddoor/M in world)
			if(M.id == src.id)
				if(openclose == null)
					openclose = M.density
				spawn(0)
					if(M)
						if(openclose)	M.open()
						else			M.close()
					return

	spawn(15)
		if(!(stat & NOPOWER))
			icon_state = "doorctrl0"

/obj/machinery/door_control/power_change()
	..()
	if(stat & NOPOWER)
		icon_state = "doorctrl-p"
	else
		icon_state = "doorctrl0"

/obj/machinery/driver_button/attack_ai(mob/user)
	return src.attack_hand(user)

/obj/machinery/driver_button/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/machinery/driver_button/attackby(obj/item/weapon/W, mob/user, params)

	if(istype(W, /obj/item/device/detective_scanner))
		return
	return src.attack_hand(user)

/obj/machinery/driver_button/attack_hand(mob/user)

	src.add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return
	add_fingerprint(user)

	use_power(5)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/door/poddoor/M in world)
		if (M.id == src.id)
			spawn( 0 )
				M.open()
				return

	sleep(20)

	for(var/obj/machinery/mass_driver/M in world)
		if(M.id == src.id)
			M.drive()

	sleep(50)

	for(var/obj/machinery/door/poddoor/M in world)
		if (M.id == src.id)
			spawn( 0 )
				M.close()
				return

	icon_state = "launcherbtt"
	active = 0

	return