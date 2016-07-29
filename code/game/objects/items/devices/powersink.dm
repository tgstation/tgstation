<<<<<<< HEAD
// Powersink - used to drain station power

/obj/item/device/powersink
	desc = "A nulling power sink which drains energy from electrical systems."
	name = "power sink"
	icon_state = "powersink0"
	item_state = "electronic"
	w_class = 4
	flags = CONDUCT
	throwforce = 5
	throw_speed = 1
	throw_range = 2
	materials = list(MAT_METAL=750)
	origin_tech = "powerstorage=5;syndicate=5"
	var/drain_rate = 1600000	// amount of power to drain per tick
	var/power_drained = 0 		// has drained this much power
	var/max_power = 1e10		// maximum power that can be drained before exploding
	var/mode = 0		// 0 = off, 1=clamped (off), 2=operating
	var/admins_warned = 0 // stop spam, only warn the admins once that we are about to boom

	var/const/DISCONNECTED = 0
	var/const/CLAMPED_OFF = 1
	var/const/OPERATING = 2

	var/obj/structure/cable/attached		// the attached cable

/obj/item/device/powersink/update_icon()
	icon_state = "powersink[mode == OPERATING]"

/obj/item/device/powersink/proc/set_mode(value)
	if(value == mode)
		return
	switch(value)
		if(DISCONNECTED)
			attached = null
			if(mode == OPERATING)
				STOP_PROCESSING(SSobj, src)
			anchored = 0

		if(CLAMPED_OFF)
			if(!attached)
				return
			if(mode == OPERATING)
				STOP_PROCESSING(SSobj, src)
			anchored = 1

		if(OPERATING)
			if(!attached)
				return
			START_PROCESSING(SSobj, src)
			anchored = 1

	mode = value
	update_icon()
	SetLuminosity(0)

/obj/item/device/powersink/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		if(mode == DISCONNECTED)
			var/turf/T = loc
			if(isturf(T) && !T.intact)
				attached = locate() in T
				if(!attached)
					user << "<span class='warning'>This device must be placed over an exposed, powered cable node!</span>"
				else
					set_mode(CLAMPED_OFF)
					user.visible_message( \
						"[user] attaches \the [src] to the cable.", \
						"<span class='notice'>You attach \the [src] to the cable.</span>",
						"<span class='italics'>You hear some wires being connected to something.</span>")
			else
				user << "<span class='warning'>This device must be placed over an exposed, powered cable node!</span>"
		else
			set_mode(DISCONNECTED)
			user.visible_message( \
				"[user] detaches \the [src] from the cable.", \
				"<span class='notice'>You detach \the [src] from the cable.</span>",
				"<span class='italics'>You hear some wires being disconnected from something.</span>")
	else
		return ..()

/obj/item/device/powersink/attack_paw()
	return

/obj/item/device/powersink/attack_ai()
	return

/obj/item/device/powersink/attack_hand(mob/user)
	switch(mode)
		if(DISCONNECTED)
			..()

		if(CLAMPED_OFF)
			user.visible_message( \
				"[user] activates \the [src]!", \
				"<span class='notice'>You activate \the [src].</span>",
				"<span class='italics'>You hear a click.</span>")
			message_admins("Power sink activated by [key_name_admin(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
			log_game("Power sink activated by [key_name(user)] at ([x],[y],[z])")
			set_mode(OPERATING)

		if(OPERATING)
			user.visible_message( \
				"[user] deactivates \the [src]!", \
				"<span class='notice'>You deactivate \the [src].</span>",
				"<span class='italics'>You hear a click.</span>")
			set_mode(CLAMPED_OFF)

/obj/item/device/powersink/process()
	if(!attached)
		set_mode(DISCONNECTED)
		return

	var/datum/powernet/PN = attached.powernet
	if(PN)
		SetLuminosity(5)

		// found a powernet, so drain up to max power from it

		var/drained = min ( drain_rate, PN.avail )
		PN.load += drained
		power_drained += drained

		// if tried to drain more than available on powernet
		// now look for APCs and drain their cells
		if(drained < drain_rate)
			for(var/obj/machinery/power/terminal/T in PN.nodes)
				if(istype(T.master, /obj/machinery/power/apc))
					var/obj/machinery/power/apc/A = T.master
					if(A.operating && A.cell)
						A.cell.charge = max(0, A.cell.charge - 50)
						power_drained += 50
						if(A.charging == 2) // If the cell was full
							A.charging = 1 // It's no longer full

	if(power_drained > max_power * 0.98)
		if (!admins_warned)
			admins_warned = 1
			message_admins("Power sink at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>) is 95% full. Explosion imminent.")
		playsound(src, 'sound/effects/screech.ogg', 100, 1, 1)

	if(power_drained >= max_power)
		STOP_PROCESSING(SSobj, src)
		explosion(src.loc, 4,8,16,32)
		qdel(src)
=======
// Powersink - used to drain station power

/obj/item/device/powersink
	desc = "A nulling power sink which drains energy from electrical systems."
	name = "power sink"
	icon_state = "powersink0"
	item_state = "electronic"
	w_class = W_CLASS_LARGE
	flags = FPRINT
	siemens_coefficient = 1
	throwforce = 5
	throw_speed = 1
	throw_range = 2
	starting_materials = list(MAT_IRON = 750)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_STEEL
	origin_tech = "powerstorage=3;syndicate=5"
	var/drain_rate = 600000		// amount of power to drain per tick
	var/power_drained = 0 		// has drained this much power
	var/max_power = 1e8		// maximum power that can be drained before exploding
	var/mode = 0		// 0 = off, 1=clamped (off), 2=operating


	var/obj/structure/cable/attached		// the attached cable

	attackby(var/obj/item/I, var/mob/user)
		if(isscrewdriver(I))
			if(mode == 0)
				var/turf/T = loc
				if(isturf(T) && !T.intact)
					attached = locate() in T
					if(!attached)
						to_chat(user, "No exposed cable here to attach to.")
						return
					else
						attached.attached = src
						anchored = 1
						mode = 1
						to_chat(user, "You attach the device to the cable.")
						for(var/mob/M in viewers(user))
							if(M == user) continue
							to_chat(M, "[user] attaches the power sink to the cable.")
						return
				else
					to_chat(user, "Device must be placed over an exposed cable to attach to it.")
					return
			else
				if (mode == 2)
					processing_objects.Remove(src) // Now the power sink actually stops draining the station's power if you unhook it. --NeoFite
				anchored = 0
				mode = 0
				to_chat(user, "You detach the device from the cable.")
				attached.attached = null
				attached = null
				for(var/mob/M in viewers(user))
					if(M == user) continue
					to_chat(M, "[user] detaches the power sink from the cable.")
				set_light(0)
				icon_state = "powersink0"

				return
		else
			..()

	Destroy()
		set_light(0)
		processing_objects.Remove(src)
		attached.attached = null
		attached = null
		..()

	attack_paw()
		return

	attack_ai()
		return

	attack_hand(var/mob/user)
		switch(mode)
			if(0)
				..()

			if(1)
				to_chat(user, "You activate the device!")
				for(var/mob/M in viewers(user))
					if(M == user) continue
					to_chat(M, "[user] activates the power sink!")
				mode = 2
				icon_state = "powersink1"
				playsound(get_turf(src), 'sound/effects/phasein.ogg', 30, 1)
				processing_objects.Add(src)

			if(2)  //This switch option wasn't originally included. It exists now. --NeoFite
				to_chat(user, "You deactivate the device!")
				for(var/mob/M in viewers(user))
					if(M == user) continue
					to_chat(M, "[user] deactivates the power sink!")
				mode = 1
				set_light(0)
				icon_state = "powersink0"
				playsound(get_turf(src), 'sound/effects/teleport.ogg', 50, 1)
				processing_objects.Remove(src)

	process()
		if(attached)
			var/datum/powernet/PN = attached.get_powernet()
			if(PN)
				set_light(12)

				// found a powernet, so drain up to max power from it

				var/drained = min ( drain_rate, PN.avail )
				PN.load += drained
				power_drained += drained

				// if tried to drain more than available on powernet
				// now look for APCs and drain their cells
				if(drained < drain_rate)
					for(var/obj/machinery/power/terminal/T in PN.nodes)
						if(istype(T.master, /obj/machinery/power/apc))
							var/obj/machinery/power/apc/A = T.master
							if(A.operating && A.cell)
								A.cell.charge = max(0, A.cell.charge - 50)
								power_drained += 50
								if(A.charging == 2)
									A.charging = 1


			if(power_drained > max_power * 0.95)
				playsound(src, 'sound/effects/screech.ogg', 100, 1, 1)
			if(power_drained >= max_power)
				processing_objects.Remove(src)
				explosion(src.loc, 3,6,9,12)
				qdel(src)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
