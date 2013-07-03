// the SMES
// stores power

#define SMESMAXCHARGELEVEL 200000
#define SMESMAXOUTPUT 200000

/obj/machinery/power/smes
	name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit."
	icon_state = "smes"
	density = 1
	anchored = 1
	use_power = 0
	var/output = 50000
	var/lastout = 0
	var/loaddemand = 0
	var/capacity = 5e6
	var/charge = 1e6
	var/charging = 0
	var/chargemode = 0
	var/chargecount = 0
	var/chargelevel = 50000
	var/online = 1
	var/n_tag = null
	var/obj/machinery/power/terminal/terminal = null
	var/datum/effect/effect/system/spark_spread/spark_system // the spark system, used for generating... sparks?
	var/state = 3


/obj/machinery/power/smes/New()
	..()
	// Sets up a spark system
	spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	spawn(5)
		dir_loop:
			for(var/d in cardinal)
				var/turf/T = get_step(src, d)
				for(var/obj/machinery/power/terminal/term in T)
					if(term && term.dir == turn(d, 180))
						terminal = term
						break dir_loop
		if(!terminal)
			stat |= BROKEN
			return
		terminal.master = src
		updateicon()
	return


/obj/machinery/power/smes/proc/updateicon()
	overlays.Cut()
	if(stat & BROKEN)	return

	overlays += image('icons/obj/power.dmi', "smes-op[online]")

	if(charging)
		overlays += image('icons/obj/power.dmi', "smes-oc1")
	else
		if(chargemode)
			overlays += image('icons/obj/power.dmi', "smes-oc0")

	var/clevel = chargedisplay()
	if(clevel>0)
		overlays += image('icons/obj/power.dmi', "smes-og[clevel]")
	return


/obj/machinery/power/smes/proc/chargedisplay()
	return round(5.5*charge/capacity)

#define SMESRATE 0.05			// rate of internal charge to external power


/obj/machinery/power/smes/process()

	if(stat & BROKEN)	return

	//store machine state to see if we need to update the icon overlays
	var/last_disp = chargedisplay()
	var/last_chrg = charging
	var/last_onln = online

	if(terminal)
		var/excess = terminal.surplus()

		if(charging)
			if(excess >= 0)		// if there's power available, try to charge

				var/load = min((capacity-charge)/SMESRATE, chargelevel)		// charge at set rate, limited to spare capacity

				charge += load * SMESRATE	// increase the charge

				add_load(load)		// add the load to the terminal side network

			else					// if not enough capcity
				charging = 0		// stop charging
				chargecount  = 0

		else
			if(chargemode)
				if(chargecount > rand(3,6))
					charging = 1
					chargecount = 0

				if(excess > chargelevel)
					chargecount++
				else
					chargecount = 0
			else
				chargecount = 0

	if(online)		// if outputting
		lastout = min( charge/SMESRATE, output)		//limit output to that stored

		charge -= lastout*SMESRATE		// reduce the storage (may be recovered in /restore() if excessive)

		add_avail(lastout)				// add output to powernet (smes side)

		if(charge < 0.0001)
			online = 0					// stop output if charge falls to zero

	// only update icon if state changed
	if(last_disp != chargedisplay() || last_chrg != charging || last_onln != online)
		updateicon()

	updateDialog()
	return

// called after all power processes are finished
// restores charge level to smes if there was excess this ptick


/obj/machinery/power/smes/proc/restore()
	if(stat & BROKEN)
		return

	if(!online)
		loaddemand = 0
		return

	var/excess = powernet.netexcess		// this was how much wasn't used on the network last ptick, minus any removed by other SMESes

	excess = min(lastout, excess)				// clamp it to how much was actually output by this SMES last ptick

	excess = min((capacity-charge)/SMESRATE, excess)	// for safety, also limit recharge by space capacity of SMES (shouldn't happen)

	// now recharge this amount

	var/clev = chargedisplay()

	charge += excess * SMESRATE
	powernet.netexcess -= excess		// remove the excess from the powernet, so later SMESes don't try to use it

	loaddemand = lastout-excess

	if(clev != chargedisplay() )
		updateicon()
	return


/obj/machinery/power/smes/add_load(var/amount)
	if(terminal && terminal.powernet)
		terminal.powernet.newload += amount


/obj/machinery/power/smes/attack_ai(mob/user)
	add_fingerprint(user)
	if(stat & BROKEN) return
	interact(user)


/obj/machinery/power/smes/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & BROKEN) return

	if(ishuman(user))
		if(istype(user:gloves, /obj/item/clothing/gloves/space_ninja)&&user:gloves:candrain&&!user:gloves:draining)
			call(/obj/item/clothing/gloves/space_ninja/proc/drain)("SMES",src,user:wear_suit)
			return
	interact(user)

// ADDED SECURING CODE

/obj/machinery/power/smes/attackby(obj/item/W, mob/user)

	var/mob/living/carbon/human/U = user

	if(istype(W, /obj/item/weapon/wrench))
		if(online)
			user << "Turn off the [src] first."
			return
		switch(state)
			if(0)
				state = 1
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				user.visible_message("[user.name] secures [src] to the floor.", \
					"You secure the external reinforcing bolts to the floor.", \
					"You hear a ratchet")
				src.anchored = 1
			if(1)
				state = 0
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				user.visible_message("[user.name] unsecures [src] reinforcing bolts from the floor.", \
					"You undo the external reinforcing bolts.", \
					"You hear a ratchet")
				src.anchored = 0
			if(2)
				user << "\red [src] needs to be unwelded from the floor."
			if(3)
				user << "\red [src] needs to have its power cords disconnected."
		return

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(online)
			user << "Turn off the [src] first."
			return
		switch(state)
			if(0)
				user << "\red [src] needs to be wrenched to the floor."
			if(1)
				if (WT.remove_fuel(0,user))
					playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
					user.visible_message("[user.name] starts to weld [src] to the floor.", \
						"You start to weld the [src] to the floor.", \
						"You hear welding")
					if (do_after(user,20))
						if(!src || !WT.isOn()) return
						state = 2
						user << "You weld the [src] to the floor."
						connect_to_network()
						src.directwired = 1
				else
					user << "\red You need more welding fuel to complete this task."
			if(2)
				if (WT.remove_fuel(0,user))
					playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
					user.visible_message("[user.name] starts to cut [src] free from the floor.", \
						"You start to cut the [src] free from the floor.", \
						"You hear welding")
					if (do_after(user,20))
						if(!src || !WT.isOn()) return
						state = 1
						user << "You cut the [src] free from the floor."
						disconnect_from_network()
						src.directwired = 0
				else
					user << "\red You need more welding fuel to complete this task."
			if(3)
				user << "\red [src] needs to have its power cords disconnected."
		return

	if(istype(W, /obj/item/weapon/wirecutters))

		/*
			Will shock anyone who is not wearing yellow gloves with the current along the wires
			The unit will remain on, and then has the potential to shock when reconnected

			Over 50000W, without protective gloves, will result in body gibbing
		*/

		//Process live disconnection (can be very nasty)
		if(online)
			var/damagemin = charging * 50
			var/damage = max(damagemin, (loaddemand/10))
			var/siemens_coeff = 1

			//Has gloves?
			if(U.gloves)
				var/obj/item/clothing/gloves/G = U.gloves
				siemens_coeff = G.siemens_coefficient

			if(siemens_coeff > 0)
				U.electrocute_act(damage, src,siemens_coeff,1)//The last argument is a safety for the human proc that checks for gloves.
				if(damage>5000)
					//If the voltage is so high, gib the person
					spawn(1)
					playsound(U.loc, 'sound/effects/splat.ogg', 50, 1)
					U.gib()

			src.spark_system.start() // creates some sparks because they look cool
			chargelevel = chargelevel - damage

			//Circuit breaker fires
			if(state == 3)
				charging = 0		// stop charging
				chargecount  = 0
				chargemode = !chargemode
				online = !online	//disconnect
				updateicon()

		switch(state)
			if(2)
				state = 3
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
				user.visible_message("[user.name] connects [src] power cords.", \
					"You connect [src] power cords.", \
					"You hear wirecutters")
			if(3)
				state = 2
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
				user.visible_message("[user.name] disconnects [src] power cords.", \
					"You disconnect [src] power cords.", \
					"You hear wirecutters")
		return

// END OF SECURING CODE

/obj/machinery/power/smes/interact(mob/user)
	if(get_dist(src, user) > 1 && !istype(user, /mob/living/silicon/ai))
		user.unset_machine()
		user << browse(null, "window=smes")
		return

	user.set_machine(src)

	var/t = "<TT><B>SMES Power Storage Unit</B> [n_tag? "([n_tag])" : null]<HR><PRE>"

	t += "Stored capacity : [round(100.0*charge/capacity, 0.1)]%<BR><BR>"

	t += "Input: [charging ? "Charging" : "Not Charging"]    [chargemode ? "<B>Auto</B> <A href = '?src=\ref[src];cmode=1'>Off</A>" : "<A href = '?src=\ref[src];cmode=1'>Auto</A> <B>Off</B> "]<BR>"


	t += "Input level:  <A href = '?src=\ref[src];input=-4'>M</A> <A href = '?src=\ref[src];input=-3'>-</A> <A href = '?src=\ref[src];input=-2'>-</A> <A href = '?src=\ref[src];input=-1'>-</A> [add_lspace(chargelevel,5)] <A href = '?src=\ref[src];input=1'>+</A> <A href = '?src=\ref[src];input=2'>+</A> <A href = '?src=\ref[src];input=3'>+</A> <A href = '?src=\ref[src];input=4'>M</A><BR>"

	t += "<BR><BR>"

	t += "Output: [online ? "<B>Online</B> <A href = '?src=\ref[src];online=1'>Offline</A>" : "<A href = '?src=\ref[src];online=1'>Online</A> <B>Offline</B> "]<BR>"

	t += "Output level: <A href = '?src=\ref[src];output=-4'>M</A> <A href = '?src=\ref[src];output=-3'>-</A> <A href = '?src=\ref[src];output=-2'>-</A> <A href = '?src=\ref[src];output=-1'>-</A> [add_lspace(output,5)] <A href = '?src=\ref[src];output=1'>+</A> <A href = '?src=\ref[src];output=2'>+</A> <A href = '?src=\ref[src];output=3'>+</A> <A href = '?src=\ref[src];output=4'>M</A><BR>"

	t += "Output load: [round(loaddemand)] W<BR>"

	t += "<BR></PRE><HR><A href='?src=\ref[src];close=1'>Close</A>"

	t += "</TT>"
	user << browse(t, "window=smes;size=460x300")
	onclose(user, "smes")
	return


/obj/machinery/power/smes/Topic(href, href_list)
	..()

	if (usr.stat || usr.restrained() )
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		if(!istype(usr, /mob/living/silicon/ai))
			usr << "\red You don't have the dexterity to do this!"
			return

//world << "[href] ; [href_list[href]]"

	if (( usr.machine==src && ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))


		if( href_list["close"] )
			usr << browse(null, "window=smes")
			usr.unset_machine()
			return

		else if( href_list["cmode"] )
			if(state==3)
				chargemode = !chargemode
				if(!chargemode)
					charging = 0
				updateicon()
			else
				usr << "The [src] must have its power cables connected before operating."
			return

		else if( href_list["online"] )
			if(state==3)
				online = !online
				updateicon()
			else
				usr << "The [src] must have its power cables connected before operating."
			return
		else if( href_list["input"] )

			var/i = text2num(href_list["input"])

			var/d = 0
			switch(i)
				if(-4)
					chargelevel = 0
				if(4)
					chargelevel = SMESMAXCHARGELEVEL		//30000

				if(1)
					d = 100
				if(-1)
					d = -100
				if(2)
					d = 1000
				if(-2)
					d = -1000
				if(3)
					d = 10000
				if(-3)
					d = -10000

			chargelevel += d
			chargelevel = max(0, min(SMESMAXCHARGELEVEL, chargelevel))	// clamp to range

		else if( href_list["output"] )

			var/i = text2num(href_list["output"])

			var/d = 0
			switch(i)
				if(-4)
					output = 0
				if(4)
					output = SMESMAXOUTPUT		//30000

				if(1)
					d = 100
				if(-1)
					d = -100
				if(2)
					d = 1000
				if(-2)
					d = -1000
				if(3)
					d = 10000
				if(-3)
					d = -10000

			output += d
			output = max(0, min(SMESMAXOUTPUT, output))	// clamp to range

		investigate_log("input/output; [chargelevel>output?"<font color='green'>":"<font color='red'>"][chargelevel]/[output]</font> | Output-mode: [online?"<font color='green'>on</font>":"<font color='red'>off</font>"] | Input-mode: [chargemode?"<font color='green'>auto</font>":"<font color='red'>off</font>"] by [usr.key]","singulo")
		src.updateUsrDialog()

	else
		usr << browse(null, "window=smes")
		usr.unset_machine()
	return


/obj/machinery/power/smes/proc/ion_act()
	if(src.z == 1)
		if(prob(1)) //explosion
			world << "\red SMES explosion in [src.loc.loc]"
			for(var/mob/M in viewers(src))
				M.show_message("\red [src] is making strange noises!", 3, "\red You hear sizzling electronics.", 2)
			sleep(10*pick(4,5,6,7,10,14))
			var/datum/effect/effect/system/harmless_smoke_spread/smoke = new /datum/effect/effect/system/harmless_smoke_spread()
			smoke.set_up(3, 0, src.loc)
			smoke.attach(src)
			smoke.start()
			explosion(src.loc, -1, 0, 1, 3, 0)
			del(src)
			return
		if(prob(15)) //Power drain
			world << "\red SMES power drain in [src.loc.loc]"
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			if(prob(50))
				emp_act(1)
			else
				emp_act(2)
		if(prob(5)) //smoke only
			world << "\red SMES smoke in [src.loc.loc]"
			var/datum/effect/effect/system/harmless_smoke_spread/smoke = new /datum/effect/effect/system/harmless_smoke_spread()
			smoke.set_up(3, 0, src.loc)
			smoke.attach(src)
			smoke.start()


/obj/machinery/power/smes/emp_act(severity)
	online = 0
	charging = 0
	output = 0
	charge -= 1e6/severity
	if (charge < 0)
		charge = 0
	spawn(100)
		output = initial(output)
		charging = initial(charging)
		online = initial(online)
	..()



/obj/machinery/power/smes/magical
	name = "magical power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. Magically produces power."
	process()
		capacity = INFINITY
		charge = INFINITY
		..()



/proc/rate_control(var/S, var/V, var/C, var/Min=1, var/Max=5, var/Limit=null)
	var/href = "<A href='?src=\ref[S];rate control=1;[V]"
	var/rate = "[href]=-[Max]'>-</A>[href]=-[Min]'>-</A> [(C?C : 0)] [href]=[Min]'>+</A>[href]=[Max]'>+</A>"
	if(Limit) return "[href]=-[Limit]'>-</A>"+rate+"[href]=[Limit]'>+</A>"
	return rate


#undef SMESRATE
