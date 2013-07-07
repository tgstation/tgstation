var/networkNum = 0

/obj/machinery/door_control
	name = "remote door-control"
	desc = "It controls doors, remotely."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl-open"
	desc = "A remote control-switch for a door."
	power_channel = ENVIRON
	var/datum/effect/effect/system/spark_spread/spark_system // the spark system, used for generating... sparks?
	var/id = null
	var/normaldoorcontrol = 0
	var/specialfunctions = 1
	var/range = 8
	var/locked = 1
	/*
	Bitflag, 	1= open
				2= idscan,
				4= bolts
				8= shock
				16= door safties

	*/
	var/opened = 0 //0=closed, 1=opened
	var/wired = 1
	var/hasElectronics = 1
	var/tdir = null
	var/installed = /obj/item/weapon/module/switch_control
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

/obj/machinery/door_control/New(turf/loc, var/ndir, var/building=0)
	..()

	if (building)
		// offset 24 pixels in direction of dir
		// this allows the APC to be embedded in a wall, yet still inside an area
		dir = ndir
		src.tdir = dir		// to fix Vars bug
		dir = SOUTH

		pixel_x = (src.tdir & 3)? 0 : (src.tdir == 4 ? 24 : -24)
		pixel_y = (src.tdir & 3)? (src.tdir ==1 ? 24 : -24) : 0
		opened = 1
		wired = 0
		hasElectronics = 0
	else
		icon_state = "doorctrl0"

	// Sets up a spark system
	spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/machinery/door_control/attack_ai(mob/user as mob)
	if(wired & 2)
		return src.attack_hand(user)
	else
		user << "Error, no route to host."

/obj/machinery/door_control/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door_control/attack_hand(mob/user as mob)
	src.add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		return

	if(!allowed(user) && (wires & 1))
		user << "\red Access Denied"
		flick("doorctrl-denied",src)
		return
	/*
	else if(istype(I, /obj/item/weapon/card/id)||istype(I, /obj/item/device/pda))
		//Behavior lock/unlock mangement
		if(allowed(user))
			locked = !locked
			user << "<span class='notice'>Controls are now [locked ? "locked" : "unlocked"].</span>"
		else
			user << "<span class='notice'>Access denied.</span>"
		return
	*/

	else if(hasElectronics && wired && opened && allowed(user))
		var/dat = ""
		dat += "<h3>Device Status</h3>"
		dat += text("<table width='100%'>")
		dat += text("<tr><td width='25%'>")
		if(id)
			dat += text("<span class='good'>Formatted</span>")
		else
			dat += text("<span class='bad'>Unformatted</span>")
		dat += text("</td><td width='25%'><A href='?src=\ref[src];action=3='>Format Device</A></td>")
		dat += text("</tr></table>")
		dat += "<h3>Blast Door Connections</h3>"
		dat += "<table width='100%'>"
		var/list/L = list()
		if(!range)
			L = world
		else
			L = range(range, src)

		for(var/obj/machinery/door/poddoor/D in L)
			dat += text("<tr>")
			dat += text("<td width='50%'>[D.name]</td>")
			if(D.id == id)
				dat += text("<td width='25%'><span class='good'>Connected</span></td>")
				dat += text("<td width='25%'><A href='?src=\ref[src];item=\ref[D];action=0='>Unlink</A></td>")
			else if(D.id == 1)
				dat += text("<td width='25%'><span class='average'>Available</span></td>")
				dat += text("<td width='25%'><A href='?src=\ref[src];item=\ref[D];action=1'>Link</A></td>")
			else
				dat += text("<td width='25%'><span class='bad'>In Use</span></td>")
				dat += text("<td width='25%'><A href='?src=\ref[src];item=\ref[D];action=2'>Join</A></td>")
			dat += text("</tr>")

		var/datum/browser/popup = new(user, "door_setup", "Switch Configuration", 400, 440)
		popup.set_content(dat)
		//popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
		popup.open()
		return
	else if(!hasElectronics || !wired || opened)
		return
	else if(hasElectronics && wired && !opened)
		//usr << "Do thing!"
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
						if(!D.isWireCut(4) && D.arePowerSystemsOn())
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
		return
	return

/obj/machinery/door_control/attackby(obj/item/weapon/W, mob/user)
	if(..(user))
		return
	src.add_fingerprint(usr)

	var/mob/living/carbon/human/U = user
	if (istype(W, /obj/item/weapon/screwdriver))
		//close unit
		user.visible_message(\
			"[user] has [opened? "closed" : "opened"] the [src]",\
			"You [opened? "close" : "open"] the [src].")
		opened = !opened
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		power_change()
		return

	else if(istype(W, /obj/item/weapon/card/emag))
		req_access = list()
		req_one_access = list()
		playsound(src.loc, "sparks", 100, 1)
		return

	else if(istype(W, /obj/item/weapon/cable_coil))
		if(opened && !wired)
			//add wires
			var/obj/item/weapon/cable_coil/C = W
			if(C.amount < 1)
				user << "\red You need more wires."
				return
			C.use(1)
			wired = 1
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			user.visible_message(\
				"[user] has wired the [src]",\
				"You wire the [src].")
			power_change()
		return

	else if(istype(W, /obj/item/weapon/module/switch_control) ||\
			istype(W, /obj/item/weapon/module/switch_control/high))
		var/obj/item/weapon/module/switch_control/module = W
		if(opened && wired)
			//add module
			if(istype(W, /obj/item/weapon/module/switch_control/high))
				installed = /obj/item/weapon/module/switch_control/high
			else
				installed = /obj/item/weapon/module/switch_control
			range = module.range
			req_access = module.conf_access
			id = module.id
			module.Del()
			hasElectronics = 1
			playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
			user.visible_message(\
				"[user] has inserted a control module into [src]",\
				"You insert a control module into [src].")
			power_change()

			/*
			var/list/doors = list()
			for(var/obj/machinery/door/poddoor/D in range(8, src))
				//if(D.id == 1)	// check if door unassigned
				doors += D
			var/newid = input("Please select nearby door:", "Awaiting Input") in doors
			//var/newid = copytext(reject_bad_text(input(usr, "Link ID:", "Awaiting Input", "")),1,256)
			if(newid)
				id = newid
			*/

		return

	else if(istype(W, /obj/item/weapon/crowbar))
		if(opened && hasElectronics)
			var/siemens_coeff = 1
			if(!istype(user))
				return

			//Has gloves?
			if(U.gloves)
				var/obj/item/clothing/gloves/G = U.gloves
				siemens_coeff = G.siemens_coefficient

			if(!(stat & (NOPOWER|BROKEN)))
				src.spark_system.start() // creates some sparks because they look cool

			if((siemens_coeff > 0) && !(stat & (NOPOWER|BROKEN)))
				U.electrocute_act(10, src,1,1)//The last argument is a safety for the human proc that checks for gloves.
			else
				//remove wires
				hasElectronics = 0
				user.visible_message(\
					"[user] has removed a control module from the [src]",\
					"You have removed a control module from the [src].")
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				power_change()
				var/obj/item/weapon/module/switch_control/M = new installed( get_turf(src.loc), 1 )
				M.id = id
				M.conf_access = req_access
				id = null
		return


	else if(istype(W, /obj/item/weapon/wirecutters))
		if(opened && wired && !hasElectronics)
			var/siemens_coeff = 1
			if(!istype(user))
				return

			//Has gloves?
			if(U.gloves)
				var/obj/item/clothing/gloves/G = U.gloves
				siemens_coeff = G.siemens_coefficient

				if((siemens_coeff > 0) && !(stat & (NOPOWER|BROKEN)))
					U.electrocute_act(10, src,1,1)//The last argument is a safety for the human proc that checks for gloves.
					src.spark_system.start() // creates some sparks because they look cool
				else
					//remove wires
					wired = 0
					user.visible_message(\
						"[user] has unwired the [src]",\
						"You unwire the [src].")
					playsound(src.loc, 'sound/items/wirecutter.ogg', 50, 1)
					power_change()
					new /obj/item/weapon/cable_coil( get_turf(src.loc), 1 )
		return
/*
/obj/machinery/door_control/process()
	..()
	src.updateUsrDialog()
*/
/obj/machinery/door_control/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)

	switch(text2num(href_list["action"]))
		if(0)
			usr << "\icon[src] *Trying to remove door from network!"
			if (href_list["item"])
				var/obj/machinery/door/poddoor/O = locate(href_list["item"])
				O.id = 1
				usr << "\icon[src] *[O] removed from network!"
		if(1)
			usr << "\icon[src] *Trying to link door to network!"
			if (href_list["item"])
				var/obj/machinery/door/poddoor/O = locate(href_list["item"])
				O.id = id
				usr << "\icon[src] *[O] linked to [id] network!"
		if(2)
			usr << "\icon[src] *Trying to join door's network!"
			if (href_list["item"])
				var/obj/machinery/door/poddoor/O = locate(href_list["item"])
				id = O.id
				usr << "\icon[src] *[src] linked to [O] network!"
		if(3)
			usr << "\icon[src] *Device formatted to new network!"
			playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 1)
			networkNum = networkNum + 1
			id = "network[networkNum]"

	updateUsrDialog()
	add_fingerprint(usr)
	return

/obj/machinery/door_control/power_change()
	..()
	if(opened)
		if(hasElectronics)
			icon_state = "doorctrl-open-2"
			return
		else if(wired)
			icon_state = "doorctrl-open-1"
			return
		else if(!wired)
			icon_state = "doorctrl-open"
			return
	else
		if(stat & NOPOWER)
			icon_state = "doorctrl-dead"
			return
		else if(!wired)
			icon_state = "doorctrl-dead"
			return
		else if(!hasElectronics)
			icon_state = "doorctrl-err"
			return
		else if(wired && hasElectronics && !opened)
			icon_state = "doorctrl0"
			return
	return

/obj/machinery/driver_button/attack_ai(mob/user)
	return src.attack_hand(user)

/obj/machinery/driver_button/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/machinery/driver_button/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	return src.attack_hand(user)

/obj/machinery/driver_button/attack_hand(mob/user as mob)
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