/obj/machinery/power/am_control_unit
	name = "antimatter control unit"
	desc = "This device injects antimatter into connected shielding units, the more antimatter injected the more power produced.  Wrench the device to set it up."
	icon = 'icons/obj/machines/antimatter.dmi'
	icon_state = "control"
	anchored = 1
	density = 1
	use_power = 1
	idle_power_usage = 100
	active_power_usage = 1000

	var/list/obj/machinery/am_shielding/linked_shielding
	var/list/obj/machinery/am_shielding/linked_cores
	var/obj/item/weapon/am_containment/fueljar
	var/update_shield_icons = 0
	var/stability = 100
	var/exploding = 0

	var/active = 0//On or not
	var/fuel_injection = 2//How much fuel to inject
	var/shield_icon_delay = 0//delays resetting for a short time
	var/reported_core_efficiency = 0

	var/power_cycle = 0
	var/power_cycle_delay = 4//How many ticks till produce_power is called
	var/stored_core_stability = 0
	var/stored_core_stability_delay = 0

	var/stored_power = 0//Power to deploy per tick


/obj/machinery/power/am_control_unit/New()
	..()
	linked_shielding = list()
	linked_cores = list()


/obj/machinery/power/am_control_unit/Del()//Perhaps damage and run stability checks rather than just del on the others
	for(var/obj/machinery/am_shielding/AMS in linked_shielding)
		del(AMS)
	..()


/obj/machinery/power/am_control_unit/process()
	if(exploding)
		explosion(get_turf(src),8,12,18,12)
		if(src) del(src)

	if(update_shield_icons && !shield_icon_delay)
		check_shield_icons()
		update_shield_icons = 0

	if(stat & (NOPOWER|BROKEN) || !active)//can update the icons even without power
		return

	if(!fueljar)//No fuel but we are on, shutdown
		toggle_power()
		//Angry buzz or such here
		return

	add_avail(stored_power)

	power_cycle++
	if(power_cycle >= power_cycle_delay)
		produce_power()
		power_cycle = 0

	return


/obj/machinery/power/am_control_unit/proc/produce_power()
	playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)
	var/core_power = reported_core_efficiency//Effectively how much fuel we can safely deal with
	if(core_power <= 0) return 0//Something is wrong
	var/core_damage = 0
	var/fuel = fueljar.usefuel(fuel_injection)

	stored_power = (fuel/core_power)*fuel*200000
	//Now check if the cores could deal with it safely, this is done after so you can overload for more power if needed, still a bad idea
	if(fuel > (2*core_power))//More fuel has been put in than the current cores can deal with
		if(prob(50))core_damage = 1//Small chance of damage
		if((fuel-core_power) > 5)	core_damage = 5//Now its really starting to overload the cores
		if((fuel-core_power) > 10)	core_damage = 20//Welp now you did it, they wont stand much of this
		if(core_damage == 0) return
		for(var/obj/machinery/am_shielding/AMS in linked_cores)
			AMS.stability -= core_damage
			AMS.check_stability(1)
		playsound(src.loc, 'sound/effects/bang.ogg', 50, 1)
	return


/obj/machinery/power/am_control_unit/emp_act(severity)
	switch(severity)
		if(1)
			if(active)	toggle_power()
			stability -= rand(15,30)
		if(2)
			if(active)	toggle_power()
			stability -= rand(10,20)
	..()
	return 0


/obj/machinery/power/am_control_unit/blob_act()
	stability -= 20
	if(prob(100-stability))//Might infect the rest of the machine
		for(var/obj/machinery/am_shielding/AMS in linked_shielding)
			AMS.blob_act()
		spawn(0)
			//Likely explode
			del(src)
		return
	check_stability()
	return


/obj/machinery/power/am_control_unit/ex_act(severity)
	switch(severity)
		if(1.0)
			stability -= 60
		if(2.0)
			stability -= 40
		if(3.0)
			stability -= 20
	check_stability()
	return


/obj/machinery/power/am_control_unit/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.flag != "bullet")
		stability -= Proj.force
	return 0


/obj/machinery/power/am_control_unit/power_change()
	..()
	if(stat & NOPOWER && active)
		toggle_power()
	return


/obj/machinery/power/am_control_unit/update_icon()
	if(active) icon_state = "control_on"
	else icon_state = "control"
	//No other icons for it atm


/obj/machinery/power/am_control_unit/attackby(obj/item/W, mob/user)
	if(!istype(W) || !user) return
	if(istype(W, /obj/item/weapon/wrench))
		if(!anchored)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
			user.visible_message("[user.name] secures the [src.name] to the floor.", \
				"You secure the anchor bolts to the floor.", \
				"You hear a ratchet")
			src.anchored = 1
			connect_to_network()
		else if(!linked_shielding.len > 0)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
			user.visible_message("[user.name] unsecures the [src.name].", \
				"You remove the anchor bolts.", \
				"You hear a ratchet")
			src.anchored = 0
			disconnect_from_network()
		else
			user << "\red Once bolted and linked to a shielding unit it the [src.name] is unable to be moved!"
		return

	if(istype(W, /obj/item/weapon/am_containment))
		if(fueljar)
			user << "\red There is already a [fueljar] inside!"
			return
		fueljar = W
		W.loc = src
		if(user.client)
			user.client.screen -= W
		user.u_equip(W)
		user.update_icons()
		user.visible_message("[user.name] loads an [W.name] into the [src.name].", \
				"You load an [W.name].", \
				"You hear a thunk.")
		return

	if(W.force >= 20)
		stability -= W.force/2
		check_stability()
	..()
	return


/obj/machinery/power/am_control_unit/attack_hand(mob/user as mob)
	if(anchored)
		interact(user)
	return


/obj/machinery/power/am_control_unit/proc/add_shielding(var/obj/machinery/am_shielding/AMS, var/AMS_linking = 0)
	if(!istype(AMS)) return 0
	if(!anchored) return 0
	if(!AMS_linking && !AMS.link_control(src)) return 0
	linked_shielding.Add(AMS)
	update_shield_icons = 1
	return 1


/obj/machinery/power/am_control_unit/proc/remove_shielding(var/obj/machinery/am_shielding/AMS)
	if(!istype(AMS)) return 0
	linked_shielding.Remove(AMS)
	update_shield_icons = 2
	if(active)	toggle_power()
	return 1


/obj/machinery/power/am_control_unit/proc/check_stability()//TODO: make it break when low also might want to add a way to fix it like a part or such that can be replaced
	if(stability <= 0)
		del(src)
	return


/obj/machinery/power/am_control_unit/proc/toggle_power()
	active = !active
	if(active)
		use_power = 2
		visible_message("The [src.name] starts up.")
	else
		use_power = 1
		visible_message("The [src.name] shuts down.")
	update_icon()
	return


/obj/machinery/power/am_control_unit/proc/check_shield_icons()//Forces icon_update for all shields
	if(shield_icon_delay) return
	shield_icon_delay = 1
	if(update_shield_icons == 2)//2 means to clear everything and rebuild
		for(var/obj/machinery/am_shielding/AMS in linked_shielding)
			if(AMS.processing)	AMS.shutdown_core()
			AMS.control_unit = null
			spawn(10)
				AMS.controllerscan()
		linked_shielding = list()

	else
		for(var/obj/machinery/am_shielding/AMS in linked_shielding)
			AMS.update_icon()
	spawn(20)
		shield_icon_delay = 0
	return


/obj/machinery/power/am_control_unit/proc/check_core_stability()
	if(stored_core_stability_delay || linked_cores.len <= 0)	return
	stored_core_stability_delay = 1
	stored_core_stability = 0
	for(var/obj/machinery/am_shielding/AMS in linked_cores)
		stored_core_stability += AMS.stability
	stored_core_stability/=linked_cores.len
	spawn(40)
		stored_core_stability_delay = 0
	return


/obj/machinery/power/am_control_unit/interact(mob/user)
	if((get_dist(src, user) > 1) || (stat & (BROKEN|NOPOWER)))
		if(!istype(user, /mob/living/silicon/ai))
			user.unset_machine()
			user << browse(null, "window=AMcontrol")
			return
	user.set_machine(src)

	var/dat = ""
	dat += "AntiMatter Control Panel<BR>"
	dat += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
	dat += "<A href='?src=\ref[src];refresh=1'>Refresh</A><BR>"
	dat += "<A href='?src=\ref[src];refreshicons=1'>Force Shielding Update</A><BR><BR>"
	dat += "Status: [(active?"Injecting":"Standby")] <BR>"
	dat += "<A href='?src=\ref[src];togglestatus=1'>Toggle Status</A><BR>"

	dat += "Stability: [stability]%<BR>"
	dat += "Reactor parts: [linked_shielding.len]<BR>"//TODO: perhaps add some sort of stability check
	dat += "Cores: [linked_cores.len]<BR><BR>"
	dat += "-Current Efficiency: [reported_core_efficiency]<BR>"
	dat += "-Average Stability: [stored_core_stability] <A href='?src=\ref[src];refreshstability=1'>(update)</A><BR>"
	dat += "Last Produced: [stored_power]<BR>"

	dat += "Fuel: "
	if(!fueljar)
		dat += "<BR>No fuel receptacle detected."
	else
		dat += "<A href='?src=\ref[src];ejectjar=1'>Eject</A><BR>"
		dat += "- [fueljar.fuel]/[fueljar.fuel_max] Units<BR>"

		dat += "- Injecting: [fuel_injection] units<BR>"
		dat += "- <A href='?src=\ref[src];strengthdown=1'>--</A>|<A href='?src=\ref[src];strengthup=1'>++</A><BR><BR>"


	user << browse(dat, "window=AMcontrol;size=420x500")
	onclose(user, "AMcontrol")
	return


/obj/machinery/power/am_control_unit/Topic(href, href_list)
	..()
	//Ignore input if we are broken or guy is not touching us, AI can control from a ways away
	if(stat & (BROKEN|NOPOWER) || (get_dist(src, usr) > 1 && !istype(usr, /mob/living/silicon/ai)))
		usr.unset_machine()
		usr << browse(null, "window=AMcontrol")
		return

	if(href_list["close"])
		usr << browse(null, "window=AMcontrol")
		usr.unset_machine()
		return

	if(href_list["togglestatus"])
		toggle_power()

	if(href_list["refreshicons"])
		update_shield_icons = 1

	if(href_list["ejectjar"])
		if(fueljar)
			fueljar.loc = src.loc
			fueljar = null
			//fueljar.control_unit = null currently it does not care where it is
			//update_icon() when we have the icon for it

	if(href_list["strengthup"])
		fuel_injection++

	if(href_list["strengthdown"])
		fuel_injection--
		if(fuel_injection < 0) fuel_injection = 0

	if(href_list["refreshstability"])
		check_core_stability()

	updateDialog()
	return