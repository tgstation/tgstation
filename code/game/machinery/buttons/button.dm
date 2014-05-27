///////////////////////////
///////// Buttons /////////
///////////////////////////


/obj/machinery/button
	name = "button"
	icon = 'icons/obj/objects.dmi'
	desc = "If you want a default subtype, make one"
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4
	var/active = 0
	var/list/minions = list()
	//Associated machines to be manipulated
	var/list/minion_types = list()
	//Valid types of machines to be added to minions[]

/obj/machinery/button/driver
	name = "mass driver button"
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mass driver."
	minion_types = list(/obj/machinery/door/poddoor,/obj/machinery/mass_driver)

/obj/machinery/button/driver/Trigger()
	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/door/poddoor/M in minions)
		spawn( 0 )
			M.open()
			return

	sleep(20)

	for(var/obj/machinery/mass_driver/M in minions)
		M.drive()

	sleep(50)

	for(var/obj/machinery/door/poddoor/M in minions)
		spawn( 0 )
			M.close()
			return

	icon_state = "launcherbtt"
	active = 0
	return



/obj/machinery/button/ignition_switch
	name = "ignition switch"
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mounted igniter."
	minion_types = list(/obj/machinery/sparker,/obj/machinery/igniter)

/obj/machinery/button/ignition_switch/Trigger()
	active = 1
	icon_state = "launcheract"

	for(var/L in minions)
		if(istype(L, /obj/machinery/sparker))
			var/obj/machinery/sparker/S = L
			S.ignite()
		else if(istype(L, /obj/machinery/igniter))
			var/obj/machinery/igniter/I = L
			use_power(50)
			I.on = !I.on
			I.icon_state = text("igniter[]", I.on)

	sleep(50)

	icon_state = "launcherbtt"
	active = 0
	return

/obj/machinery/button/flasher_button
	name = "flasher button"
	desc = "A remote control switch for a mounted flasher."
	icon_state = "launcherbtt"
	minion_types = list(/obj/machinery/flasher)

/obj/machinery/button/flasher_button/Trigger()
	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/flasher/M in minions)
		spawn()
			M.flash()

	sleep(50)

	icon_state = "launcherbtt"
	active = 0
	return


/obj/machinery/button/crema_switch
	desc = "Burn baby burn!"
	name = "crematorium igniter"
	icon_state = "crema_switch"
	icon = 'icons/obj/power.dmi'
	req_access = list(access_crematorium)
	minion_types = list(/obj/structure/crematorium)

/obj/machinery/button/crema_switch/pre_process()//TODO: Murder this the moment the crematorium is turned into a machine
	for(var/obj/structure/crematorium/C in orange(3,src))
		minions |= C
	return

/obj/machinery/button/crema_switch/attack_hand(mob/user as mob)
	src.add_fingerprint(usr)
	if(active)
		return
	active = 1

	for (var/obj/structure/crematorium/C in minions)
		if (!C.cremating)
			C.cremate(user)

	active = 0
	return

/obj/machinery/button/pre_process()
	return//Doesn't need to do anything, but at the same time doesn't need to look for other buttons

/obj/machinery/button/process()
	return//May be used later, but for now should stay so other machines can 'find' them

/obj/machinery/button/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/button/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/button/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	return attack_hand(user)

/obj/machinery/button/attack_hand(mob/user as mob)
	src.add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return
	add_fingerprint(user)

	use_power(5)
	Trigger()
	return

/obj/machinery/button/proc/Trigger()
	return