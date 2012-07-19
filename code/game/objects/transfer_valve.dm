/obj/item/device/transfer_valve
	icon = 'assemblies.dmi'
	name = "tank transfer valve"
	icon_state = "valve_1"
	desc = "Regulates the transfer of air between two tanks"
	var/obj/item/weapon/tank/tank_one
	var/obj/item/weapon/tank/tank_two
	var/obj/item/device/attached_device
	var/mob/attacher = "Unknown"
	var/valve_open = 0
	var/toggle = 1

/obj/item/device/transfer_valve/proc/process_activation(var/obj/item/device/D)

/obj/item/device/transfer_valve/IsAssemblyHolder()
	return 1

/obj/item/device/transfer_valve/attackby(obj/item/item, mob/user)
	if(istype(item, /obj/item/weapon/tank))
		if(tank_one && tank_two)
			user << "<span class='warning'>There are already two tanks attached, remove one first.</span>"
			return

		if(!tank_one)
			tank_one = item
			user.drop_item()
			item.loc = src
			user << "<span class='notice'>You attach the tank to the transfer valve.</span>"
		else if(!tank_two)
			tank_two = item
			user.drop_item()
			item.loc = src
			user << "<span class='notice'>You attach the tank to the transfer valve.</span>"

		update_icon()
//TODO: Have this take an assemblyholder
	else if(isassembly(item))
		var/obj/item/device/assembly/A = item
		if(A.secured)
			user << "<span class='notice'>The device is secured.</span>"
			return
		if(attached_device)
			user << "<span class='warning'>There is already an device attached to the valve, remove it first.</span>"
			return
		user.remove_from_mob(item)
		attached_device = A
		A.loc = src
		user << "<span class='notice'>You attach the [item] to the valve controls and secure it.</span>"
		A.holder = src
		A.toggle_secure()

		bombers += "[key_name(user)] attached a [item] to a transfer valve."
		message_admins("[key_name_admin(user)] attached a [item] to a transfer valve.")
		log_game("[key_name_admin(user)] attached a [item] to a transfer valve.")
		attacher = key_name(user)
	return


/obj/item/device/transfer_valve/HasProximity(atom/movable/AM as mob|obj)
	if(!attached_device)	return
	attached_device.HasProximity(AM)
	return


/obj/item/device/transfer_valve/attack_self(mob/user as mob)
	user.machine = src
	var/dat = {"<B> Valve properties: </B>
	<BR> <B> Attachment one:</B> [tank_one] [tank_one ? "<A href='?src=\ref[src];tankone=1'>Remove</A>" : ""]
	<BR> <B> Attachment two:</B> [tank_two] [tank_two ? "<A href='?src=\ref[src];tanktwo=1'>Remove</A>" : ""]
	<BR> <B> Valve attachment:</B> [attached_device ? "<A href='?src=\ref[src];device=1'>[attached_device]</A>" : "None"] [attached_device ? "<A href='?src=\ref[src];rem_device=1'>Remove</A>" : ""]
	<BR> <B> Valve status: </B> [ valve_open ? "<A href='?src=\ref[src];open=1'>Closed</A> <B>Open</B>" : "<B>Closed</B> <A href='?src=\ref[src];open=1'>Open</A>"]"}

	user << browse(dat, "window=trans_valve;size=600x300")
	onclose(user, "trans_valve")
	return

/obj/item/device/transfer_valve/Topic(href, href_list)
	..()
	if ( usr.stat || usr.restrained() )
		return
	if (src.loc == usr)
		if(tank_one && href_list["tankone"])
			split_gases()
			valve_open = 0
			tank_one.loc = get_turf(src)
			tank_one = null
			update_icon()
		else if(tank_two && href_list["tanktwo"])
			split_gases()
			valve_open = 0
			tank_two.loc = get_turf(src)
			tank_two = null
			update_icon()
		else if(href_list["open"])
			toggle_valve()
		else if(attached_device)
			if(href_list["rem_device"])
				attached_device.loc = get_turf(src)
				attached_device:holder = null
				attached_device = null
				update_icon()
			if(href_list["device"])
				attached_device.attack_self(usr)

		src.attack_self(usr)
		src.add_fingerprint(usr)
		return
	return

/obj/item/device/transfer_valve/process_activation(var/obj/item/device/D)
	if(toggle)
		toggle = 0
		toggle_valve()
		spawn(50) // To stop a signal being spammed from a proxy sensor constantly going off or whatever
			toggle = 1

/obj/item/device/transfer_valve/update_icon()
	overlays = null
	underlays = null

	if(!tank_one && !tank_two && !attached_device)
		icon_state = "valve_1"
		return
	icon_state = "valve"

	if(tank_one)
		overlays += "[tank_one.icon_state]"
	if(tank_two)
		var/icon/J = new(icon, icon_state = "[tank_two.icon_state]")
		J.Shift(WEST, 13)
		underlays += J
	if(attached_device)
		overlays += "device"

/obj/item/device/transfer_valve/proc/merge_gases()
	tank_two.air_contents.volume += tank_one.air_contents.volume
	var/datum/gas_mixture/temp
	temp = tank_one.air_contents.remove_ratio(1)
	tank_two.air_contents.merge(temp)

/obj/item/device/transfer_valve/proc/split_gases()
	if (!valve_open || !tank_one || !tank_two)
		return
	var/ratio1 = tank_one.air_contents.volume/tank_two.air_contents.volume
	var/datum/gas_mixture/temp
	temp = tank_two.air_contents.remove_ratio(ratio1)
	tank_one.air_contents.merge(temp)
	tank_two.air_contents.volume -=  tank_one.air_contents.volume

	/*
	Exadv1: I know this isn't how it's going to work, but this was just to check
	it explodes properly when it gets a signal (and it does).
	*/

/obj/item/device/transfer_valve/proc/toggle_valve()
	if(valve_open==0 && (tank_one && tank_two))
		valve_open = 1
		var/turf/bombturf = get_turf(src)
		var/bombarea = bombturf.loc.name
		var/log_str = "Bomb valve opened in [bombarea] with device attacher: [attacher]. Last touched by: [src.fingerprintslast]"
		bombers += log_str
		message_admins(log_str)
		log_game(log_str)
		merge_gases()
		spawn(20) // In case one tank bursts
			for (var/i=0,i<5,i++)
				src.update_icon()
				sleep(10)
			src.update_icon()

	else if(valve_open==1 && (tank_one && tank_two))
		split_gases()
		valve_open = 0
		src.update_icon()

// this doesn't do anything but the timer etc. expects it to be here
// eventually maybe have it update icon to show state (timer, prox etc.) like old bombs
/obj/item/device/transfer_valve/proc/c_state()
	return