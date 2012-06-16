//renwicks: fictional unit to describe shield strength
//a small meteor hit will deduct 1 renwick of strength from that shield tile
//light explosion range will do 1 renwick's damage
//medium explosion range will do 2 renwick's damage
//heavy explosion range will do 3 renwick's damage
//explosion damage is cumulative. if a tile is in range of light, medium and heavy damage, it will take a hit from all three

/obj/machinery/shield_gen
	name = "shield generator"
	desc = "Machine that generates an impenetrable field of energy when activated."
	icon = 'shielding.dmi'
	icon_state = "generator0"
	var/active = 0
	var/field_radius = 3
	var/list/field
	density = 1
	anchored = 1
	var/locked = 0
	var/average_field_strength = 0
	var/strengthen_rate = 0.2
	var/max_strengthen_rate = 0.2
	var/powered = 0
	var/check_powered = 1
	var/obj/machinery/shield_capacitor/owned_capacitor
	var/max_field_strength = 10
	var/time_since_fail = 100
	var/energy_conversion_rate = 0.01	//how many renwicks per watt?
	var/flicker_shield_glitch = 1		//shield is slightly faulty, and flickers
	//
	use_power = 1			//0 use nothing
							//1 use idle power
							//2 use active power
	idle_power_usage = 20
	active_power_usage = 100

/obj/machinery/shield_gen/New()
	..()
	field = new/list()
	for(var/obj/machinery/shield_capacitor/possible_cap in range(1))
		if(get_dir(possible_cap, src) == possible_cap.dir)
			owned_capacitor = possible_cap
			break
	/*spawn(10)
		check_powered()*/

//copied from a copypaste. DRY, right?
/obj/machinery/shield_gen/proc/check_powered()
	/*
	check_powered = 1
	if(!anchored)
		powered = 0
		return 0
	var/turf/T = src.loc
	var/obj/structure/cable/C = T.get_cable_node()
	var/net
	if (C)
		net = C.netnum		// find the powernet of the connected cable

	if(!net)
		powered = 0
		return 0
	var/datum/powernet/PN = powernets[net]			// find the powernet. Magic code, voodoo code.

	if(!PN)
		powered = 0
		return 0
	var/surplus = max(PN.avail-PN.load, 0)
	var/shieldload = min(rand(50,200), surplus)
	if(shieldload==0 && !storedpower)		// no cable or no power, and no power stored
		powered = 0
		return 0
	else
		powered = 1
		if(PN)
			storedpower += shieldload
			PN.newload += shieldload //uses powernet power.
			*/

/obj/machinery/shield_gen/process()

	if(!owned_capacitor)
		for(var/obj/machinery/shield_capacitor/possible_cap in range(1))
			if(get_dir(possible_cap, src) == possible_cap.dir)
				owned_capacitor = possible_cap
				break

	if(active && field.len)
		var/stored_renwicks = 0
		var/target_field_strength = min(average_field_strength + strengthen_rate, max_field_strength)
		if(owned_capacitor)
			var/assumed_charge = min(owned_capacitor.stored_charge, (target_field_strength / energy_conversion_rate) * field.len)
			stored_renwicks = assumed_charge * energy_conversion_rate
			owned_capacitor.stored_charge -= assumed_charge

		time_since_fail++

		average_field_strength = 0
		target_field_strength = stored_renwicks / field.len

		if(!flicker_shield_glitch)
			for(var/obj/effect/energy_field/E in field)
				//check to see if the shield is strengthening or failing
				if(E.strength > target_field_strength)
					E.strength = target_field_strength
				else if(E.strength + strengthen_rate > target_field_strength)
					E.strength = target_field_strength
				else
					E.strength += strengthen_rate

				if(stored_renwicks - E.strength < 0)
					E.strength = stored_renwicks
				stored_renwicks -= E.strength

				average_field_strength += E.strength
				//check if the current shield tile has enough energy to maintain itself
				if(E.strength >= 1)
					E.density = 1
					E.invisibility = 0
				else
					E.density = 0
					E.invisibility = 2
		else
			//the flicker shield glitch is an intersting quirk in 'older' and/or faulty shielding models
			//basically, it strengthens the shields continuously until it can no longer sustain them... then it drops out for a few seconds and starts again
			//this makes the shield 'flicker' every now and then until it stabilises
			//when this glitch is fixed, shields will only be charged as much as is sustainable
			for(var/obj/effect/energy_field/E in field)
				//check to see if the shield is strengthening or failing
				if(E.strength < target_field_strength)
					E.strength += strengthen_rate

				retry:
				if(stored_renwicks - E.strength < 0)
					if(owned_capacitor.stored_charge > 0)
						var/emergency_renwicks = min(E.strength, owned_capacitor.stored_charge * energy_conversion_rate)
						owned_capacitor.stored_charge -= emergency_renwicks / energy_conversion_rate
						stored_renwicks += emergency_renwicks
						goto retry
					else
						E.strength = stored_renwicks
				stored_renwicks -= E.strength

				average_field_strength += E.strength
				//check if the current shield tile has enough energy to maintain itself
				if(E.strength >= 1)
					E.density = 1
					E.invisibility = 0
				else
					E.density = 0
					E.invisibility = 2

		//add any leftover charge back to the capacitor
		if(owned_capacitor && stored_renwicks >= 0)
			owned_capacitor.stored_charge += stored_renwicks / energy_conversion_rate

		average_field_strength /= field.len
		if(average_field_strength < 0)
			time_since_fail = 0
	else
		average_field_strength = 0
	//
	updateDialog()

/obj/machinery/shield_gen/attack_hand(mob/user as mob)

	interact(user)
	src.add_fingerprint(user)

/obj/machinery/shield_gen/attackby(obj/item/W, mob/user)

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

/obj/machinery/shield_gen/power_change()
	if(stat & BROKEN)
		icon_state = "broke"
	else
		if( powered() )
			if (src.active)
				icon_state = "generator1"
			else
				icon_state = "generator0"
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				src.icon_state = "generator0"
				stat |= NOPOWER
			if (src.active)
				toggle()

/obj/machinery/shield_gen/proc/toggle()
	active = !active
	power_change()
	if(active)
		var/list/covered_turfs = get_shielded_turfs()
		if(get_turf(src) in covered_turfs)
			covered_turfs.Remove(get_turf(src))
		for(var/turf/O in covered_turfs)
			var/obj/effect/energy_field/E = new(O)
			field.Add(E)
		del covered_turfs

		for(var/mob/M in view(5,src))
			M << "\icon[src] You hear heavy droning start up."
	else
		for(var/obj/effect/energy_field/D in field)
			field.Remove(D)
			del D

		for(var/mob/M in view(5,src))
			M << "\icon[src] You hear heavy droning fade out."

/obj/machinery/shield_gen/Topic(href, href_list[])
	..()
	if( href_list["close"] )
		usr << browse(null, "window=shield_generator")
		usr.machine = null
		return
	else if( href_list["toggle"] )
		toggle()
	else if( href_list["change_radius"] )
		field_radius += text2num(href_list["change_radius"])
		if(field_radius > 200)
			field_radius = 200
		else if(field_radius < 0)
			field_radius = 0
	else if( href_list["strengthen_rate"] )
		strengthen_rate += text2num(href_list["strengthen_rate"])
		if(strengthen_rate > 0.2)
			strengthen_rate = 0.2
		else if(strengthen_rate < 0)
			strengthen_rate = 0
	else if( href_list["max_field_strength"] )
		max_field_strength += text2num(href_list["max_field_strength"])
		if(max_field_strength > 1000)
			max_field_strength = 1000
		else if(max_field_strength < 0)
			max_field_strength = 0
	//
	updateDialog()

/obj/machinery/shield_gen/proc/interact(mob/user)
	if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
		if (!istype(user, /mob/living/silicon))
			user.machine = null
			user << browse(null, "window=shield_generator")
			return
	var/t = "<B>Shield Generator Control Console</B><BR>"
	t += "[owned_capacitor ? "<font color=green>Charge capacitor connected.</font>" : "<font color=red>Unable to locate charge capacitor!</font>"]<br>"
	t += "This generator is: [active ? "<font color=green>Online</font>" : "<font color=red>Offline</font>" ] <a href='?src=\ref[src];toggle=1'>[active ? "\[Deactivate\]" : "\[Activate\]"]</a><br>"
	t += "[time_since_fail > 2 ? "<font color=green>Field is stable.</font>" : "<font color=red>Warning, field is unstable!</font>"]<br>"
	t += "Coverage radius (generator will need a restart to take effect): <a href='?src=\ref[src];change_radius=-5'>--</a> <a href='?src=\ref[src];change_radius=-1'>-</a> [field_radius * 2]m <a href='?src=\ref[src];change_radius=1'>+</a> <a href='?src=\ref[src];change_radius=5'>++</a><br>"
	t += "Overall field strength: [average_field_strength] Renwicks ([100 * average_field_strength / max_field_strength]%)<br>"
	t += "Charge consumption: [( (min(average_field_strength + strengthen_rate, max_field_strength)) / energy_conversion_rate) * field.len] Watts/sec<br>"
	t += "Field charge rate (approx): <a href='?src=\ref[src];strengthen_rate=-0.1'>--</a> <a href='?src=\ref[src];strengthen_rate=-0.01'>-</a>[strengthen_rate] Renwicks/sec <a href='?src=\ref[src];strengthen_rate=0.01'>+</a> <a href='?src=\ref[src];strengthen_rate=0.1'>++</a><br>"
	t += "Maximum field strength (avg across field): <a href='?src=\ref[src];max_field_strength=-100'>\[min\]</a> <a href='?src=\ref[src];max_field_strength=-10'>--</a> <a href='?src=\ref[src];max_field_strength=-1'>-</a>[max_field_strength] Renwicks <a href='?src=\ref[src];max_field_strength=1'>+</a> <a href='?src=\ref[src];max_field_strength=10'>++</a> <a href='?src=\ref[src];max_field_strength=100'>\[max\]</a><br>"
	t += "<hr>"
	t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
	user << browse(t, "window=shield_generator;size=500x800")
	user.machine = src

/obj/machinery/shield_gen/proc/get_shielded_turfs()
	return list()

/obj/machinery/shield_gen/ex_act(var/severity)

	if(active)
		toggle()
	return ..()
