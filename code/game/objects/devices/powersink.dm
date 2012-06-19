// Powersink - used to drain station power

/obj/item/device/powersink
	desc = "A nulling power sink which drains energy from electrical systems."
	name = "power sink"
	icon_state = "powersink0"
	item_state = "electronic"
	w_class = 4.0
	flags = FPRINT | TABLEPASS | CONDUCT
	throwforce = 5
	throw_speed = 1
	throw_range = 2
	m_amt = 750
	w_amt = 750
	origin_tech = "powerstorage=3;syndicate=5"
	var/drain_rate = 600000		// amount of power to drain per tick
	var/power_drained = 0 		// has drained this much power
	var/max_power = 1e8		// maximum power that can be drained before exploding
	var/mode = 0		// 0 = off, 1=clamped (off), 2=operating


	var/obj/structure/cable/attached		// the attached cable

	attackby(var/obj/item/I, var/mob/user)
		if(istype(I, /obj/item/weapon/screwdriver))
			if(mode == 0)
				var/turf/T = loc
				if(isturf(T) && !T.intact)
					attached = locate() in T
					if(!attached)
						user << "No exposed cable here to attach to."
						return
					else
						anchored = 1
						mode = 1
						user << "You attach the device to the cable."
						for(var/mob/M in viewers(user))
							if(M == user) continue
							M << "[user] attaches the power sink to the cable."
						return
				else
					user << "Device must be placed over an exposed cable to attach to it."
					return
			else
				if (mode == 2)
					processing_objects.Remove(src) // Now the power sink actually stops draining the station's power if you unhook it. --NeoFite
				anchored = 0
				mode = 0
				user << "You detach	the device from the cable."
				for(var/mob/M in viewers(user))
					if(M == user) continue
					M << "[user] detaches the power sink from the cable."
				ul_SetLuminosity(0)
				icon_state = "powersink0"

				return
		else
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
				user << "You activate the device!"
				for(var/mob/M in viewers(user))
					if(M == user) continue
					M << "[user] activates the power sink!"
				mode = 2
				icon_state = "powersink1"
				processing_objects.Add(src)

			if(2)  //This switch option wasn't originally included. It exists now. --NeoFite
				user << "You deactivate the device!"
				for(var/mob/M in viewers(user))
					if(M == user) continue
					M << "[user] deactivates the power sink!"
				mode = 1
				ul_SetLuminosity(0)
				icon_state = "powersink0"
				processing_objects.Remove(src)

	process()
		if(attached)
			var/datum/powernet/PN = attached.get_powernet()
			if(PN)
				if(!luminosity)
					ul_SetLuminosity(12)


				// found a powernet, so drain up to max power from it

				var/drained = min ( drain_rate, PN.avail )
				PN.newload += drained
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


			if(power_drained > max_power * 0.95)
				playsound(src, 'screech.ogg', 100, 1, 1)
			if(power_drained >= max_power)
				processing_objects.Remove(src)
				explosion(src.loc, 3,6,9,12)
				del(src)
