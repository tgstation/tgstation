/obj/item/device/transfer_valve
	icon = 'assemblies.dmi'
	name = "Tank transfer valve" // because that's what it is exadv1 and don't you dare change it
	icon_state = "valve_1"
	desc = "Regulates the transfer of air between two tanks"
	var/obj/item/weapon/tank/tank_one
	var/obj/item/weapon/tank/tank_two
	var/obj/item/device/attached_device
	var/mob/attacher = "Unknown"
	var/valve_open = 0
	var/toggle = 1


	attackby(obj/item/item, mob/user)
		if(istype(item, /obj/item/weapon/tank))
			if(tank_one && tank_two)
				user << "\red There are already two tanks attached, remove one first!"
				return

			if(!tank_one)
				tank_one = item
				user.drop_item()
				item.loc = src
				user << "\blue You attach the tank to the transfer valve"
			else if(!tank_two)
				tank_two = item
				user.drop_item()
				item.loc = src
				user << "\blue You attach the tank to the transfer valve!"

			update_icon()

		else if(istype(item, /obj/item/device/radio/signaler) || istype(item, /obj/item/device/timer) || istype(item, /obj/item/device/infra) || istype(item, /obj/item/device/prox_sensor))
			if(attached_device)
				user << "\red There is already an device attached to the valve, remove it first!"
				return

			attached_device = item
			user.drop_item()
			item.loc = src
			user << "\blue You attach the [item] to the valve controls!"
			item.master = src

			bombers += "[key_name(user)] attached a [item] to a transfer valve."
			message_admins("[key_name_admin(user)] attached a [item] to a transfer valve.")
			attacher = key_name(user)



		return


	attack_self(mob/user as mob)
		user.machine = src
		var/dat = {"<B> Valve properties: </B>
		<BR> <B> Attachment one:</B> [tank_one] [tank_one ? "<A href='?src=\ref[src];tankone=1'>Remove</A>" : ""]
		<BR> <B> Attachment two:</B> [tank_two] [tank_two ? "<A href='?src=\ref[src];tanktwo=1'>Remove</A>" : ""]
		<BR> <B> Valve attachment:</B> [attached_device ? "<A href='?src=\ref[src];device=1'>[attached_device]</A>" : "None"] [attached_device ? "<A href='?src=\ref[src];rem_device=1'>Remove</A>" : ""]
		<BR> <B> Valve status: </B> [ valve_open ? "<A href='?src=\ref[src];open=1'>Closed</A> <B>Open</B>" : "<B>Closed</B> <A href='?src=\ref[src];open=1'>Open</A>"]"}

		user << browse(dat, "window=trans_valve;size=600x300")
		onclose(user, "trans_valve")
		return


	Topic(href, href_list)
		..()
		if (usr.stat|| usr.restrained())
			return
		if (src.loc == usr)
			if(href_list["tankone"])
				tank_one.loc = get_turf(src)
				tank_one = null
				update_icon()
			if(href_list["tanktwo"])
				tank_two.loc = get_turf(src)
				tank_two = null
				update_icon()
			if(href_list["open"])
				toggle_valve()
			if(href_list["rem_device"])
				if(attached_device)
					attached_device.loc = get_turf(src)
					attached_device = null
				update_icon()
			if(href_list["device"])
				attached_device.attack_self(usr)

			src.attack_self(usr)

			src.add_fingerprint(usr)
			return

	receive_signal(signal)
		if(toggle)
			toggle = 0
			toggle_valve()
			spawn(50) // To stop a signal being spammed from a proxy sensor constantly going off or whatever
				toggle = 1

	process()

	proc
		update_icon()
			src.overlays = new/list()
			src.underlays = new/list()
			if(!tank_one && !tank_two && !attached_device)
				icon_state = "valve_1"
				return
			icon_state = "valve"
			var/tank_one_icon = ""
			var/tank_two_icon = ""
			if(tank_one)
				tank_one_icon = tank_one.icon_state
			if(tank_two)
				tank_two_icon = tank_two.icon_state
			if(tank_one)
				var/icon/I = new(src.icon, icon_state = "[tank_one_icon]")
				//var/obj/overlay/tank_one_overlay = new
				//tank_one_overlay.icon = src.icon
				//tank_one_overlay.icon_state = tank_one_icon
				src.underlays += I
			if(tank_two)
				var/icon/J = new(src.icon, icon_state = "[tank_two_icon]")
				//I.Flip(EAST) this breaks the perspective!
				J.Shift(WEST, 13)
				//var/obj/underlay/tank_two_overlay = new
				//tank_two_overlay.icon = I
				src.underlays += J
			if(attached_device)
				var/icon/K = new(src.icon, icon_state = "device")
				//var/obj/overlay/device_overlay = new
				//device_overlay.icon = src.icon
				//device_overlay.icon_state = device_icon
				src.overlays += K

		/*
		Exadv1: I know this isn't how it's going to work, but this was just to check
		it explodes properly when it gets a signal (and it does).
		*/

		toggle_valve()
			src.valve_open = !valve_open
			if(valve_open && (tank_one && tank_two))
				var/turf/bombturf = get_turf(src)
				var/bombarea = bombturf.loc.name

				bombers += "Bomb valve opened in [bombarea] with device attacher: [attacher]. Last touched by: [src.fingerprintslast]"
				message_admins("Bomb valve opened in [bombarea] with device attacher: [attacher]. Last touched by: [src.fingerprintslast]")

				var/datum/gas_mixture/temp
				temp = tank_one.air_contents.remove_ratio(1)

				tank_two.air_contents.volume = tank_two.air_contents.volume + tank_one.air_contents.volume
				tank_two.air_contents.merge(temp)
				spawn(20) // In case one tank bursts
					src.update_icon()


		// this doesn't do anything but the timer etc. expects it to be here
		// eventually maybe have it update icon to show state (timer, prox etc.) like old bombs
		c_state()
			return



/obj/falsewall/
	attack_hand(mob/user as mob)
		if(density)
			// Open wall
			icon_state = "fwall_open"
			flick("fwall_opening", src)
			sleep(15)
			src.density = 0
			src.sd_SetOpacity(0)
			var/turf/T = src.loc
			T.sd_LumUpdate()


		else
			icon_state = "wall"
			flick("fwall_closing", src)
			sleep(15)
			src.density = 1
			src.sd_SetOpacity(1)
			var/turf/T = src.loc
			T.sd_LumUpdate()
			src.relativewall()


	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/screwdriver))
			var/turf/T = get_turf(src)
			user.visible_message("[user] tightens some bolts on the wall.", "You tighten the bolts on the wall.")
			T.ReplaceWithWall()
			del(src)
			//

	/*

		var/turf/T = get_turf(user)
		user << "\blue Now adding plating..."
		sleep(40)
		if (get_turf(user) == T)
			user << "\blue You added the plating!"
			var/turf/Tsrc = get_turf(src)
			Tsrc.ReplaceWithWall()

	*/