
/obj/machinery/power/rad_collector
	name = "Radiation Collector Array"
	desc = "A device which uses Hawking Radiation and plasma to produce power."
	icon = 'singularity.dmi'
	icon_state = "collector"
	anchored = 1
	density = 1
	directwired = 1
	var
		obj/item/weapon/tank/plasma/P = null
		last_power = 0

	process()
		if(P)
			if(P.air_contents.toxins <= 0)
				P.air_contents.toxins = 0
				eject()
			else
				P.air_contents.toxins -= 0.001
		return


	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/device/analyzer))
			user << "\blue The [W.name] detects that [last_power]W were recently produced."
			return 1
		if(istype(W, /obj/item/weapon/tank/plasma))
			if(!src.anchored)
				user << "The [src] needs to be secured to the floor first."
				return 1
			if(src.P)
				user << "\red There appears to already be a plasma tank loaded!"
				return 1
			icon_state = "collector +p"
			src.P = W
			W.loc = src
			if (user.client)
				user.client.screen -= W
			user.u_equip(W)
		else if(istype(W, /obj/item/weapon/crowbar))
			if(P)
				eject()
				return 1
		else if(istype(W, /obj/item/weapon/wrench))
			if(P)
				user << "\red Remove the plasma tank first."
				return 1
			playsound(src.loc, 'Ratchet.ogg', 75, 1)
			src.anchored = !src.anchored
			user.visible_message("[user.name] [anchored? "secures":"unsecures"] the [src.name].", \
				"You [anchored? "secure":"undo"] the external bolts.", \
				"You hear ratchet")
		else
			..()
			return 1


	ex_act(severity)
		switch(severity)
			if(2, 3)
				eject()
		return ..()


	proc
		eject()
			var/obj/item/weapon/tank/plasma/Z = src.P
			if (!Z)
				return
			Z.loc = get_turf(src)
			Z.layer = initial(Z.layer)
			src.P = null
			icon_state = "collector"

		receive_pulse(var/pulse_strength)
			if(P)
				var/power_produced = 0
				power_produced = P.air_contents.toxins*pulse_strength*20
				add_avail(power_produced)
				last_power = power_produced
				return
			return