#define CLOSING			1
#define OPENING			2
#define CYCLE			3
#define CYCLE_EXTERIOR	4
#define CYCLE_INTERIOR	5

/obj/machinery/doorButtons
	power_channel = ENVIRON
	anchored = 1
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/idSelf

/obj/machinery/doorButtons/attackby(obj/O, mob/user)
	attack_hand(user)

/obj/machinery/doorButtons/proc/findObjsByTag()
	return

/obj/machinery/doorButtons/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/doorButtons/LateInitialize()
	findObjsByTag()

/obj/machinery/doorButtons/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		req_access = list()
		req_one_access = list()
		playsound(src.loc, "sparks", 100, 1)
		to_chat(user, "<span class='warning'>You short out the access controller.</span>")

/obj/machinery/doorButtons/proc/removeMe()


/obj/machinery/doorButtons/access_button
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_button_standby"
	name = "access button"
	var/idDoor
	var/obj/machinery/door/airlock/door
	var/obj/machinery/doorButtons/airlock_controller/controller
	var/busy

/obj/machinery/doorButtons/access_button/findObjsByTag()
	for(var/obj/machinery/doorButtons/airlock_controller/A in GLOB.machines)
		if(A.idSelf == idSelf)
			controller = A
			break
	for(var/obj/machinery/door/airlock/I in GLOB.machines)
		if(I.id_tag == idDoor)
			door = I
			break

/obj/machinery/doorButtons/access_button/attack_hand(mob/user)
	if(..())
		return
	if(busy)
		return
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	if(controller && !controller.busy && door)
		if(controller.stat & NOPOWER)
			return
		busy = 1
		update_icon()
		if(door.density)
			if(!controller.exteriorAirlock || !controller.interiorAirlock)
				controller.onlyOpen(door)
			else
				if(controller.exteriorAirlock.density && controller.interiorAirlock.density)
					controller.onlyOpen(door)
				else
					controller.cycleClose(door)
		else
			controller.onlyClose(door)
		sleep(20)
		busy = 0
		update_icon()

/obj/machinery/doorButtons/access_button/update_icon()
	if(stat & NOPOWER)
		icon_state = "access_button_off"
	else
		if(busy)
			icon_state = "access_button_cycle"
		else
			icon_state = "access_button_standby"

/obj/machinery/doorButtons/access_button/power_change()
	..()
	update_icon()

/obj/machinery/doorButtons/access_button/removeMe(obj/O)
	if(O == door)
		door = null



/obj/machinery/doorButtons/airlock_controller
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_control_standby"
	name = "access console"
	var/obj/machinery/door/airlock/interiorAirlock
	var/obj/machinery/door/airlock/exteriorAirlock
	var/idInterior
	var/idExterior
	var/busy
	var/lostPower

/obj/machinery/doorButtons/airlock_controller/removeMe(obj/O)
	if(O == interiorAirlock)
		interiorAirlock = null
	else if(O == exteriorAirlock)
		exteriorAirlock = null

/obj/machinery/doorButtons/airlock_controller/Destroy()
	for(var/obj/machinery/doorButtons/access_button/A in GLOB.machines)
		if(A.controller == src)
			A.controller = null
	return ..()

/obj/machinery/doorButtons/airlock_controller/Topic(href, href_list)
	if(..())
		return
	if(busy)
		return
	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return
	switch(href_list["command"])
		if("close_exterior")
			onlyClose(exteriorAirlock)
		if("close_interior")
			onlyClose(interiorAirlock)
		if("cycle_exterior")
			cycleClose(exteriorAirlock)
		if("cycle_interior")
			cycleClose(interiorAirlock)
		if("open_exterior")
			onlyOpen(exteriorAirlock)
		if("open_interior")
			onlyOpen(interiorAirlock)

/obj/machinery/doorButtons/airlock_controller/proc/onlyOpen(obj/machinery/door/airlock/A)
	if(A)
		busy = CLOSING
		update_icon()
		openDoor(A)

/obj/machinery/doorButtons/airlock_controller/proc/onlyClose(obj/machinery/door/airlock/A)
	if(A)
		busy = CLOSING
		closeDoor(A)

/obj/machinery/doorButtons/airlock_controller/proc/closeDoor(obj/machinery/door/airlock/A)
	set waitfor = FALSE
	if(A.density)
		goIdle()
		return 0
	update_icon()
	A.unbolt()
	. = 1
	if(A && A.close())
		if(stat & NOPOWER || lostPower || !A || QDELETED(A))
			goIdle(1)
			return
		A.bolt()
		if(busy == CLOSING)
			goIdle(1)
	else
		goIdle(1)

/obj/machinery/doorButtons/airlock_controller/proc/cycleClose(obj/machinery/door/airlock/A)
	if(!A || !exteriorAirlock || !interiorAirlock)
		return
	if(exteriorAirlock.density == interiorAirlock.density || !A.density)
		return
	busy = CYCLE
	update_icon()
	if(A == interiorAirlock)
		if(closeDoor(exteriorAirlock))
			busy = CYCLE_INTERIOR
	else
		if(closeDoor(interiorAirlock))
			busy = CYCLE_EXTERIOR

/obj/machinery/doorButtons/airlock_controller/proc/cycleOpen(obj/machinery/door/airlock/A)
	if(!A)
		goIdle(1)
	if(A == exteriorAirlock)
		if(interiorAirlock)
			if(!interiorAirlock.density || !interiorAirlock.locked)
				return
	else
		if(exteriorAirlock)
			if(!exteriorAirlock.density || !exteriorAirlock.locked)
				return
	if(busy != OPENING)
		busy = OPENING
		openDoor(A)

/obj/machinery/doorButtons/airlock_controller/proc/openDoor(obj/machinery/door/airlock/A)
	if(exteriorAirlock && interiorAirlock && (!exteriorAirlock.density || !interiorAirlock.density))
		goIdle(1)
		return
	A.unbolt()
	spawn()
		if(A && A.open())
			if(stat | (NOPOWER) && !lostPower && A && !QDELETED(A))
				A.bolt()
		goIdle(1)

/obj/machinery/doorButtons/airlock_controller/proc/goIdle(update)
	lostPower = 0
	busy = 0
	if(update)
		update_icon()
	updateUsrDialog()

/obj/machinery/doorButtons/airlock_controller/process()
	if(stat & NOPOWER)
		return
	if(busy == CYCLE_EXTERIOR)
		cycleOpen(exteriorAirlock)
	else if(busy == CYCLE_INTERIOR)
		cycleOpen(interiorAirlock)

/obj/machinery/doorButtons/airlock_controller/power_change()
	..()
	if(stat & NOPOWER)
		lostPower = 1
	else
		if(!busy)
			lostPower = 0
	update_icon()

/obj/machinery/doorButtons/airlock_controller/findObjsByTag()
	for(var/obj/machinery/door/airlock/A in GLOB.machines)
		if(A.id_tag == idInterior)
			interiorAirlock = A
		else if(A.id_tag == idExterior)
			exteriorAirlock = A

/obj/machinery/doorButtons/airlock_controller/update_icon()
	if(stat & NOPOWER)
		icon_state = "access_control_off"
		return
	if(busy || lostPower)
		icon_state = "access_control_process"
	else
		icon_state = "access_control_standby"

/obj/machinery/doorButtons/airlock_controller/attack_hand(mob/user)
	if(..())
		return
	var/datum/browser/popup = new(user, "computer", name)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.set_content(returnText())
	popup.open()

/obj/machinery/doorButtons/airlock_controller/proc/returnText()
	var/output
	if(!exteriorAirlock && !interiorAirlock)
		return "ERROR ERROR ERROR ERROR"
	if(lostPower)
		output = "Initializing..."
	else
		if(!exteriorAirlock || !interiorAirlock)
			if(!exteriorAirlock)
				if(interiorAirlock.density)
					output = "<A href='?src=\ref[src];command=open_interior'>Open Interior Airlock</A><BR>"
				else
					output = "<A href='?src=\ref[src];command=close_interior'>Close Interior Airlock</A><BR>"
			else
				if(exteriorAirlock.density)
					output = "<A href='?src=\ref[src];command=open_exterior'>Open Exterior Airlock</A><BR>"
				else
					output = "<A href='?src=\ref[src];command=close_exterior'>Close Exterior Airlock</A><BR>"
		else
			if(exteriorAirlock.density)
				if(interiorAirlock.density)
					output = {"<A href='?src=\ref[src];command=open_exterior'>Open Exterior Airlock</A><BR>
					<A href='?src=\ref[src];command=open_interior'>Open Interior Airlock</A><BR>"}
				else
					output = {"<A href='?src=\ref[src];command=cycle_exterior'>Cycle to Exterior Airlock</A><BR>
					<A href='?src=\ref[src];command=close_interior'>Close Interior Airlock</A><BR>"}
			else
				if(interiorAirlock.density)
					output = {"<A href='?src=\ref[src];command=close_exterior'>Close Exterior Airlock</A><BR>
					<A href='?src=\ref[src];command=cycle_interior'>Cycle to Interior Airlock</A><BR>"}
				else
					output = {"<A href='?src=\ref[src];command=close_exterior'>Close Exterior Airlock</A><BR>
					<A href='?src=\ref[src];command=close_interior'>Close Interior Airlock</A><BR>"}


	output = {"<B>Access Control Console</B><HR>
				[output]<HR>"}
	if(exteriorAirlock)
		output += "<B>Exterior Door: </B> [exteriorAirlock.density ? "closed" : "open"]<BR>"
	if(interiorAirlock)
		output += "<B>Interior Door: </B> [interiorAirlock.density ? "closed" : "open"]<BR>"

	return output

#undef CLOSING
#undef OPENING
#undef CYCLE
#undef CYCLE_EXTERIOR
#undef CYCLE_INTERIOR