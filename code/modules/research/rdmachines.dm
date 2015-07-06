//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

//All devices that link into the R&D console fall into thise type for easy identification and some shared procs.


/obj/machinery/r_n_d
	name = "R&D Device"
	icon = 'icons/obj/machines/research.dmi'
	density = 1
	anchored = 1
	use_power = 1
	var/busy = 0
	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/obj/machinery/computer/rdconsole/linked_console
	var/datum/wires/rnd/wires = null

/obj/machinery/r_n_d/New()
	..()
	wires = new(src)


/obj/machinery/r_n_d/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if (electrocute_mob(user, get_area(src), src, 0.7))
		return 1
	else
		return 0

/obj/machinery/r_n_d/proc/adjust_hacked(var/hack)
	hacked = hack

/obj/machinery/r_n_d/attack_hand(mob/user as mob)
	if(..(user, 0))
		return
	interact(user)
	return


/obj/machinery/r_n_d/interact(mob/user)
	if(!is_operational())
		return

	if(shocked && !(stat & NOPOWER))
		shock(user,50)

	if(panel_open)
		var/dat = wires.GetInteractWindow()
		var/datum/browser/popup = new(user, "R&D machine", name, 400, 500)
		popup.set_content(dat)
		popup.open()



/obj/machinery/r_n_d/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	/*
	if(href_list["pulse"])
		var/temp_wire = href_list["wire"]
		if (!istype(usr.get_active_hand(), /obj/item/device/multitool))
			usr << "You need a multitool!"
		else
			if(src.wires[temp_wire])
				usr << "You can't pulse a cut wire."
			else
				if(src.hack_wire == href_list["wire"])
					src.hacked = !src.hacked
					spawn(100) src.hacked = !src.hacked
				if(src.disable_wire == href_list["wire"])
					src.disabled = !src.disabled
					src.shock(usr,50)
					spawn(100) src.disabled = !src.disabled
				if(src.shock_wire == href_list["wire"])
					src.shocked = !src.shocked
					src.shock(usr,50)
					spawn(100) src.shocked = !src.shocked
	if(href_list["cut"])
		if (!istype(usr.get_active_hand(), /obj/item/weapon/wirecutters))
			usr << "You need wirecutters!"
		else
			var/temp_wire = href_list["wire"]
			wires[temp_wire] = !wires[temp_wire]
			if(src.hack_wire == temp_wire)
				src.hacked = !src.hacked
			if(src.disable_wire == temp_wire)
				src.disabled = !src.disabled
				src.shock(usr,50)
			if(src.shock_wire == temp_wire)
				src.shocked = !src.shocked
				src.shock(usr,50)
	*/
	src.updateUsrDialog()
