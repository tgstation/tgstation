//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33


/obj/machinery/power/rad_collector
	name = "Radiation Collector Array"
	desc = "A device which uses Hawking Radiation and plasma to produce power."
	icon = 'singularity.dmi'
	icon_state = "ca"
	anchored = 0
	density = 1
	directwired = 1
	req_access = list(ACCESS_ENGINE)
//	use_power = 0
	var/obj/item/weapon/tank/plasma/P = null
	var/last_power = 0
	var/active = 0
	var/locked = 0
	var/drainratio = 1

	process()
		if(P)
			if(P.air_contents.toxins <= 0)
				investigate_log("<font color='red'>out of fuel</font>.","singulo")
				P.air_contents.toxins = 0
				eject()
			else
				P.air_contents.toxins -= 0.001*drainratio
		return


	attack_hand(mob/user as mob)
		if(anchored)
			if(!src.locked)
				toggle_power()
				user.visible_message("[user.name] turns the [src.name] [active? "on":"off"].", \
				"You turn the [src.name] [active? "on":"off"].")
				investigate_log("turned [active?"<font color='green'>on</font>":"<font color='red'>off</font>"] by [user.key]. [P?"Fuel: [round(P.air_contents.toxins/0.29)]%":"<font color='red'>It is empty</font>"].","singulo")
				return
			else
				user << "\red The controls are locked!"
				return
	..()


	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/device/analyzer))
			user << "\blue The [W.name] detects that [last_power]W were recently produced."
			return 1
		else if(istype(W, /obj/item/weapon/tank/plasma))
			if(!src.anchored)
				user << "\red The [src] needs to be secured to the floor first."
				return 1
			if(src.P)
				user << "\red There's already a plasma tank loaded."
				return 1
			src.P = W
			W.loc = src
			if (user.client)
				user.client.screen -= W
			user.u_equip(W)
			updateicon()
		else if(istype(W, /obj/item/weapon/crowbar))
			if(P && !src.locked)
				eject()
				return 1
		else if(istype(W, /obj/item/weapon/wrench))
			if(P)
				user << "\blue Remove the plasma tank first."
				return 1
			playsound(src.loc, 'Ratchet.ogg', 75, 1)
			src.anchored = !src.anchored
			user.visible_message("[user.name] [anchored? "secures":"unsecures"] the [src.name].", \
				"You [anchored? "secure":"undo"] the external bolts.", \
				"You hear a ratchet")
			if(anchored)
				connect_to_network()
			else
				disconnect_from_network()
		else if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
			if (src.allowed(user))
				if(active)
					src.locked = !src.locked
					user << "The controls are now [src.locked ? "locked." : "unlocked."]"
				else
					src.locked = 0 //just in case it somehow gets locked
					user << "\red The controls can only be locked when the [src] is active"
			else
				user << "\red Access denied!"
				return 1
		else
			..()
			return 1


	ex_act(severity)
		switch(severity)
			if(2, 3)
				eject()
		return ..()


	proc/eject()
		locked = 0
		var/obj/item/weapon/tank/plasma/Z = src.P
		if (!Z)
			return
		Z.loc = get_turf(src)
		Z.layer = initial(Z.layer)
		src.P = null
		if(active)
			toggle_power()
		else
			updateicon()

	proc/receive_pulse(var/pulse_strength)
		if(P && active)
			var/power_produced = 0
			power_produced = P.air_contents.toxins*pulse_strength*20
			add_avail(power_produced)
			last_power = power_produced
			return
		return


	proc/updateicon()
		overlays = null
		if(P)
			overlays += image('singularity.dmi', "ptank")
		if(stat & (NOPOWER|BROKEN))
			return
		if(active)
			overlays += image('singularity.dmi', "on")


	proc/toggle_power()
		active = !active
		if(active)
			icon_state = "ca_on"
			flick("ca_active", src)
		else
			icon_state = "ca"
			flick("ca_deactive", src)
		updateicon()
		return

