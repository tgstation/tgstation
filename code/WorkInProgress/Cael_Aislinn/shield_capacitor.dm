
//---------- shield capacitor
//pulls energy out of a power net and charges an adjacent generator

/obj/machinery/shield_capacitor
	name = "shield capacitor"
	desc = "Machine that charges a shield generator."
	icon = 'shielding.dmi'
	icon_state = "capacitor"
	var/active = 1
	density = 1
	anchored = 1
	var/obj/machinery/shield_gen/target_generator
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

/obj/machinery/shield_capacitor/New()
	..()
	target_generator = locate() in get_step(src,dir)
	if(target_generator && !target_generator.owned_capacitor)
		target_generator.owned_capacitor = src
	/*spawn(10)
		check_powered()*/

/obj/machinery/shield_capacitor/verb/rotate()
	set name = "Rotate Clockwise"
	set category = "Object"
	set src in oview(1)

	if (src.anchored || usr:stat)
		usr << "It is fastened to the floor!"
		return 0
	src.dir = turn(src.dir, 270)
	for(var/obj/machinery/shield_gen/possible_gen in range(1))
		if(get_dir(src, possible_gen) == dir)
			possible_gen.owned_capacitor = src
			break
	return 1

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
	//
	updateDialog()

/obj/machinery/shield_capacitor/attackby(obj/item/W, mob/user)
	/*if(istype(W, /obj/item/weapon/wrench))
		if(active)
			user << "Turn off the field generator first."
			return

		else if(state == 0)
			state = 1
			playsound(src.loc, 'Ratchet.ogg', 75, 1)
			user << "You secure the external reinforcing bolts to the floor."
			src.anchored = 1
			return

		else if(state == 1)
			state = 0
			playsound(src.loc, 'Ratchet.ogg', 75, 1)
			user << "You undo the external reinforcing bolts."
			src.anchored = 0
			return*/

	if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (src.allowed(user))
			src.locked = !src.locked
			user << "Controls are now [src.locked ? "locked." : "unlocked."]"
		else
			user << "\red Access denied."

	else
		src.add_fingerprint(user)
		user << "\red You hit the [src.name] with your [W.name]!"
		for(var/mob/M in viewers(src))
			if(M == user)	continue
			M.show_message("\red The [src.name] has been hit with the [W.name] by [user.name]!")

/obj/machinery/shield_capacitor/attack_hand(mob/user as mob)
	interact(user)
	src.add_fingerprint(user)

/obj/machinery/shield_capacitor/Topic(href, href_list[])
	..()
	if( href_list["close"] )
		usr << browse(null, "window=shield_capacitor")
		usr.machine = null
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

/obj/machinery/shield_capacitor/proc/interact(mob/user)
	if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
		if (!istype(user, /mob/living/silicon))
			user.machine = null
			user << browse(null, "window=shield_capacitor")
			return
	var/t = "<B>Shield Capacitor Control Console</B><BR>"
	t += "[target_generator ? "<font color=green>Shield generator connected.</font>" : "<font color=red>Unable to locate shield generator!</font>"]<br>"
	t += "This capacitor is: [active ? "<font color=green>Online</font>" : "<font color=red>Offline</font>" ] <a href='?src=\ref[src];toggle=1'>[active ? "\[Deactivate\]" : "\[Activate\]"]</a><br>"
	t += "[time_since_fail > 2 ? "<font color=green>Charging stable.</font>" : "<font color=red>Warning, low charge!</font>"]<br>"
	t += "Capacitor charge: [stored_charge] Watts ([100 * stored_charge/max_charge]%)<br>"
	t += "Capacitor charge rate (approx): <a href='?src=\ref[src];charge_rate=[-max_charge_rate]'>\[min\]</a> <a href='?src=\ref[src];charge_rate=-1000'>\[--\]</a> <a href='?src=\ref[src];charge_rate=-100'>\[-\]</a>[charge_rate] Watts/sec <a href='?src=\ref[src];charge_rate=100'>\[+\]</a> <a href='?src=\ref[src];charge_rate=1000'>\[++\]</a> <a href='?src=\ref[src];charge_rate=[max_charge_rate]'>\[max\]</a><br>"
	t += "<hr>"
	t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
	user << browse(t, "window=shield_capacitor;size=500x800")
	user.machine = src
