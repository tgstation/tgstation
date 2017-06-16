/obj/item/device/assembly/control
	name = "blast door controller"
	desc = "A small electronic device able to control a blast door remotely."
	icon_state = "control"
	origin_tech = "magnets=1;programming=2"
	attachable = 1
	var/id = null
	var/can_change_id = 0
	var/cooldown = 0//Door cooldowns

/obj/item/device/assembly/control/examine(mob/user)
	..()
	if(id)
		to_chat(user, "<span class='notice'>Its channel ID is '[id]'.</span>")


/obj/item/device/assembly/control/activate()
	cooldown = 1
	var/openclose
	for(var/obj/machinery/door/poddoor/M in GLOB.machines)
		if(M.id == src.id)
			if(openclose == null)
				openclose = M.density
			spawn(0)
				if(M)
					if(openclose)
						M.open()
					else
						M.close()
				return
	sleep(10)
	cooldown = 0


/obj/item/device/assembly/control/airlock
	name = "airlock controller"
	desc = "A small electronic device able to control an airlock remotely."
	id = "badmin" // Set it to null for MEGAFUN.
	var/specialfunctions = OPEN
	/*
	Bitflag, 	1= open (OPEN)
				2= idscan (IDSCAN)
				4= bolts (BOLTS)
				8= shock (SHOCK)
				16= door safties (SAFE)
	*/

/obj/item/device/assembly/control/airlock/activate()
	cooldown = 1
	var/doors_need_closing = FALSE
	var/list/obj/machinery/door/airlock/open_or_close = list()
	for(var/obj/machinery/door/airlock/D in GLOB.airlocks)
		if(D.id_tag == src.id)
			if(specialfunctions & OPEN)
				open_or_close += D
				if(!D.density)
					doors_need_closing = TRUE
			if(specialfunctions & IDSCAN)
				D.aiDisabledIdScanner = !D.aiDisabledIdScanner
			if(specialfunctions & BOLTS)
				if(!D.wires.is_cut(WIRE_BOLTS) && D.hasPower())
					D.locked = !D.locked
					D.update_icon()
			if(specialfunctions & SHOCK)
				if(D.secondsElectrified)
					D.secondsElectrified = -1
					D.shockedby += "\[[time_stamp()]\][usr](ckey:[usr.ckey])"
					add_logs(usr, D, "electrified")
				else
					D.secondsElectrified = 0
			if(specialfunctions & SAFE)
				D.safe = !D.safe

	for(var/D in open_or_close)
		INVOKE_ASYNC(D, doors_need_closing ? /obj/machinery/door/airlock.proc/close : /obj/machinery/door/airlock.proc/open)

	sleep(10)
	cooldown = 0


/obj/item/device/assembly/control/massdriver
	name = "mass driver controller"
	desc = "A small electronic device able to control a mass driver."

/obj/item/device/assembly/control/massdriver/activate()
	cooldown = 1
	for(var/obj/machinery/door/poddoor/M in GLOB.machines)
		if (M.id == src.id)
			spawn( 0 )
				M.open()

	sleep(10)

	for(var/obj/machinery/mass_driver/M in GLOB.machines)
		if(M.id == src.id)
			M.drive()

	sleep(60)

	for(var/obj/machinery/door/poddoor/M in GLOB.machines)
		if (M.id == src.id)
			spawn( 0 )
				M.close()

	sleep(10)
	cooldown = 0


/obj/item/device/assembly/control/igniter
	name = "ignition controller"
	desc = "A remote controller for a mounted igniter."

/obj/item/device/assembly/control/igniter/activate()
	cooldown = 1
	for(var/obj/machinery/sparker/M in GLOB.machines)
		if (M.id == src.id)
			spawn( 0 )
				M.ignite()

	for(var/obj/machinery/igniter/M in GLOB.machines)
		if(M.id == src.id)
			M.use_power(50)
			M.on = !M.on
			M.icon_state = "igniter[M.on]"

	sleep(30)
	cooldown = 0


/obj/item/device/assembly/control/flasher
	name = "flasher controller"
	desc = "A remote controller for a mounted flasher."

/obj/item/device/assembly/control/flasher/activate()
	cooldown = 1
	for(var/obj/machinery/flasher/M in GLOB.machines)
		if(M.id == src.id)
			spawn(0)
				M.flash()

	sleep(50)
	cooldown = 0


/obj/item/device/assembly/control/crematorium
	name = "crematorium controller"
	desc = "An evil-looking remote controller for a crematorium."

/obj/item/device/assembly/control/crematorium/activate()
	cooldown = 1
	for (var/obj/structure/bodycontainer/crematorium/C in GLOB.crematoriums)
		if (C.id == id)
			C.cremate(usr)

	sleep(50)
	cooldown = 0
