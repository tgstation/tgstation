/obj/machinery/button/door_control
	name = "remote door-control"
	desc = "It controls doors, remotely."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A remote control-switch for a door."
	power_channel = ENVIRON
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

/obj/machinery/button/door_control/New()
	if(normaldoorcontrol)
		minion_types = list(/obj/machinery/door/airlock)
	else
		minion_types = list(/obj/machinery/door/poddoor)
	..()
	return

/obj/machinery/button/door_control/attack_ai(mob/user as mob)
	if(wires & 2)
		return src.attack_hand(user)
	else
		user << "Error, no route to host."

/obj/machinery/button/door_control/attackby(obj/item/weapon/W, mob/user as mob)
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
	if(istype(W, /obj/item/weapon/card/emag))
		req_access = list()
		req_one_access = list()
		playsound(src.loc, "sparks", 100, 1)
	return src.attack_hand(user)

/obj/machinery/button/door_control/attack_hand(mob/user as mob)
	src.add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		return

	if(!allowed(user) && (wires & 1))
		user << "\red Access Denied"
		flick("doorctrl-denied",src)
		return

	use_power(5)
	icon_state = "doorctrl1"
	add_fingerprint(user)

	if(normaldoorcontrol)
		for(var/obj/machinery/door/airlock/D in minions)
			if(specialfunctions & OPEN)
				spawn(0)
					if(D)
						if(D.density)	D.open()
						else			D.close()
					return
			if(specialfunctions & IDSCAN)
				D.aiDisabledIdScanner = !D.aiDisabledIdScanner
			if(specialfunctions & BOLTS)
				if(!D.isWireCut(4) && D.arePowerSystemsOn())
					D.locked = !D.locked
					D.update_icon()
			if(specialfunctions & SHOCK)
				D.secondsElectrified = D.secondsElectrified ? 0 : -1
			if(specialfunctions & SAFE)
				D.safe = !D.safe
	else
		var/openclose
		for(var/obj/machinery/door/poddoor/M in minions)
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

/obj/machinery/button/door_control/power_change()
	..()
	if(stat & NOPOWER)
		icon_state = "doorctrl-p"
	else
		icon_state = "doorctrl0"