
//---------- shield capacitor
//pulls energy out of a power net and charges an adjacent generator

/obj/machinery/shield_capacitor
	name = "shield capacitor"
	desc = "Machine that charges a shield generator."
	icon = 'code/WorkInProgress/Cael_Aislinn/ShieldGen/shielding.dmi'
	icon_state = "capacitor"
	var/active = 1
	density = 1
	anchored = 1
	var/stored_charge = 0
	var/time_since_fail = 100
	var/max_charge = 1000000
	var/max_charge_rate = 100000
	var/min_charge_rate = 0
	var/locked = 0
	//
	use_power = 1			//0 use nothing
							//1 use idle power
							//2 use active power
	idle_power_usage = 10
	active_power_usage = 100
	var/charge_rate = 100

	ghost_read=0
	ghost_write=0

/obj/machinery/shield_capacitor/New()
	spawn(10)
		for(var/obj/machinery/shield_gen/possible_gen in range(1, src))
			if(get_dir(src, possible_gen) == src.dir)
				possible_gen.owned_capacitor = src
				break
	..()

/obj/machinery/shield_capacitor/attackby(obj/item/W, mob/user)

	if(istype(W, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/C = W
		if(access_captain in C.access || access_security in C.access || access_engine in C.access)
			src.locked = !src.locked
			user << "Controls are now [src.locked ? "locked." : "unlocked."]"
			updateDialog()
		else
			user << "\red Access denied."
	else if(istype(W, /obj/item/weapon/card/emag))
		if(prob(75))
			src.locked = !src.locked
			user << "Controls are now [src.locked ? "locked." : "unlocked."]"
			updateDialog()
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()

	else if(istype(W, /obj/item/weapon/wrench))
		src.anchored = !src.anchored
		src.visible_message("\blue \icon[src] [src] has been [anchored ? "bolted to the floor" : "unbolted from the floor"] by [user].")

		spawn(0)
			for(var/obj/machinery/shield_gen/gen in range(1, src))
				if(get_dir(src, gen) == src.dir)
					if(!src.anchored && gen.owned_capacitor == src)
						gen.owned_capacitor = null
						break
					else if(src.anchored && !gen.owned_capacitor)
						gen.owned_capacitor = src
						break
					gen.updateDialog()
					updateDialog()
	else
		..()

/obj/machinery/shield_capacitor/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/shield_capacitor/attack_ai(user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/shield_capacitor/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	interact(user)

/obj/machinery/shield_capacitor/interact(mob/user)
	if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
		if (!istype(user, /mob/living/silicon))
			user.unset_machine()
			user << browse(null, "window=shield_capacitor")
			return
	var/t = "<B>Shield Capacitor Control Console</B><br><br>"
	if(locked)
		t += "<i>Swipe your ID card to begin.</i>"
	else
		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\ShieldGen\shield_capacitor.dm:94: t += "This capacitor is: [active ? "<font color=green>Online</font>" : "<font color=red>Offline</font>" ] <a href='?src=\ref[src];toggle=1'>[active ? "\[Deactivate\]" : "\[Activate\]"]</a><br>"
		t += {"This capacitor is: [active ? "<font color=green>Online</font>" : "<font color=red>Offline</font>" ] <a href='?src=\ref[src];toggle=1'>[active ? "\[Deactivate\]" : "\[Activate\]"]</a><br>
			[time_since_fail > 2 ? "<font color=green>Charging stable.</font>" : "<font color=red>Warning, low charge!</font>"]<br>
			Charge: [stored_charge] Watts ([100 * stored_charge/max_charge]%)<br>
			Charge rate:
		<a href='?src=\ref[src];charge_rate=[-max_charge_rate]'>\[min\]</a>
		<a href='?src=\ref[src];charge_rate=-1000'>\[--\]</a>
		<a href='?src=\ref[src];charge_rate=-100'>\[-\]</a>[charge_rate] Watts/sec
		<a href='?src=\ref[src];charge_rate=100'>\[+\]</a>
		<a href='?src=\ref[src];charge_rate=1000'>\[++\]</a>
		<a href='?src=\ref[src];charge_rate=[max_charge_rate]'>\[max\]</a><br>"}

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\ShieldGen\shield_capacitor.dm:104: t += "<hr>"
	t += {"<hr>
		<A href='?src=\ref[src]'>Refresh</A>
		<A href='?src=\ref[src];close=1'>Close</A><BR>"}
	// END AUTOFIX
	user << browse(t, "window=shield_capacitor;size=500x800")
	user.set_machine(src)

/obj/machinery/shield_capacitor/process()
	//
	if(active)
		use_power = 2
		if(stored_charge + charge_rate > max_charge)
			active_power_usage = max_charge - stored_charge
		else
			active_power_usage = charge_rate
		stored_charge += active_power_usage
	else
		use_power = 1

	time_since_fail++
	if(stored_charge < active_power_usage * 1.5)
		time_since_fail = 0

/obj/machinery/shield_capacitor/Topic(href, href_list[])
	..()
	if( href_list["close"] )
		usr << browse(null, "window=shield_capacitor")
		usr.unset_machine()
		return
	if( href_list["toggle"] )
		active = !active
		if(active)
			use_power = 2
		else
			use_power = 1
	if( href_list["charge_rate"] )
		charge_rate += text2num(href_list["charge_rate"])
		if(charge_rate > max_charge_rate)
			charge_rate = max_charge_rate
		else if(charge_rate < min_charge_rate)
			charge_rate = min_charge_rate
	//
	updateDialog()

/obj/machinery/shield_capacitor/power_change()
	if(stat & BROKEN)
		icon_state = "broke"
	else
		if( powered() )
			if (src.active)
				icon_state = "capacitor"
			else
				icon_state = "capacitor"
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				src.icon_state = "capacitor"
				stat |= NOPOWER

/obj/machinery/shield_capacitor/verb/rotate()
	set name = "Rotate capacitor clockwise"
	set category = "Object"
	set src in oview(1)

	if (src.anchored)
		usr << "It is fastened to the floor!"
		return
	src.dir = turn(src.dir, 270)
	return
