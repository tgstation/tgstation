/obj/machinery/power/am_control_unit
	name = "antimatter control unit"
	desc = "This device injects antimatter into connected shielding units, the more antimatter injected the more power produced.  Wrench the device to set it up."
	icon = 'icons/obj/machines/antimatter.dmi'
	icon_state = "control"
	anchored = FALSE
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	active_power_usage = 1000

	var/list/obj/machinery/am_shielding/linked_shielding
	var/list/obj/machinery/am_shielding/linked_cores
	var/obj/item/am_containment/fueljar
	var/update_shield_icons = FALSE
	var/stability = 100
	var/exploding = FALSE

	var/icon_mod = "on" // on, critical, or fuck

	var/active = FALSE//On or not
	var/fuel_injection = 2//How much fuel to inject
	var/shield_icon_delay = FALSE//delays resetting for a short time
	var/reported_core_efficiency = 0

	var/power_cycle = 0
	var/power_cycle_delay = 4//How many ticks till produce_power is called
	var/stored_core_stability = 0
	var/stored_core_stability_delay = 0

	var/stored_power = 0//Power to deploy per tick


/obj/machinery/power/am_control_unit/Initialize()
	. = ..()
	linked_shielding = list()
	linked_cores = list()


/obj/machinery/power/am_control_unit/Destroy()//Perhaps damage and run stability checks rather than just del on the others
	for(var/obj/machinery/am_shielding/AMS in linked_shielding)
		AMS.control_unit = null
		qdel(AMS)
	QDEL_NULL(fueljar)
	return ..()


/obj/machinery/power/am_control_unit/process()
	if(exploding)
		explosion(get_turf(src),8,12,18,12)
		if(src)
			qdel(src)

	if(update_shield_icons && !shield_icon_delay)
		check_shield_icons()
		update_shield_icons = 0

	if(stat & (NOPOWER|BROKEN) || !active)//can update the icons even without power
		return

	if(!fueljar)//No fuel but we are on, shutdown
		toggle_power()
		playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 0)
		return

	add_avail(stored_power)

	power_cycle++
	if(power_cycle >= power_cycle_delay)
		produce_power()
		power_cycle = 0

	return


/obj/machinery/power/am_control_unit/proc/produce_power()
	playsound(src, 'sound/effects/bang.ogg', 25, 1)
	var/core_power = reported_core_efficiency//Effectively how much fuel we can safely deal with
	if(core_power <= 0)
		return FALSE//Something is wrong
	var/core_damage = 0
	var/fuel = fueljar.usefuel(fuel_injection)

	stored_power = (fuel/core_power)*fuel*20000 // Was 200000, was too much.
	//Now check if the cores could deal with it safely, this is done after so you can overload for more power if needed, still a bad idea
	if(fuel > (2*core_power))//More fuel has been put in than the current cores can deal with
		if(prob(50))
			core_damage = 1//Small chance of damage
		if((fuel-core_power) > 5)
			core_damage = 5//Now its really starting to overload the cores
		if((fuel-core_power) > 10)
			core_damage = 20//Welp now you did it, they wont stand much of this
		if(core_damage == 0)
			return
		for(var/obj/machinery/am_shielding/AMS in linked_cores)
			AMS.stability -= core_damage
			AMS.check_stability(1)
		playsound(src, 'sound/effects/bang.ogg', 50, 1)
	update_icon()
	return


/obj/machinery/power/am_control_unit/emp_act(severity)
	switch(severity)
		if(1)
			if(active)
				toggle_power()
			stability -= rand(15,30)
		if(2)
			if(active)
				toggle_power()
			stability -= rand(10,20)
	..()
	return FALSE


/obj/machinery/power/am_control_unit/blob_act(obj/structure/blob/B)
	stability -= 20
	if(prob(100-stability))//Might infect the rest of the machine! Watch out!
		for(var/obj/machinery/am_shielding/AMS in linked_cores)
			AMS.blob_act(B)
		for(var/obj/machinery/am_shielding/AMS in linked_shielding)
			AMS.blob_act(B)
		qdel(src)
		return
	check_stability()
	return


/obj/machinery/power/am_control_unit/ex_act(severity, target)
	stability -= (80 - (severity * 20))
	check_stability()
	return


/obj/machinery/power/am_control_unit/bullet_act(obj/item/projectile/Proj)
	. = ..()
	if(Proj.flag != "bullet")
		stability -= Proj.force
		check_stability()


/obj/machinery/power/am_control_unit/power_change()
	..()
	if(stat & NOPOWER)
		if(active)
			toggle_power(1)
		else
			use_power = NO_POWER_USE

	else if(!stat && anchored)
		use_power = IDLE_POWER_USE

	update_icon()


/obj/machinery/power/am_control_unit/update_icon()
	switch(stored_core_stability)
		if(0 to 24)
			icon_mod="fuck"
		if(25 to 49)
			icon_mod="critical"
		if(50 to INFINITY)
			icon_mod="on"
	if(active)
		icon_state = "control_[icon_mod]"
	else icon_state = "control"


/obj/machinery/power/am_control_unit/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/wrench))
		if(!anchored)
			playsound(src.loc, W.usesound, 75, 1)
			user.visible_message("[user.name] secures the [src.name] to the floor.", \
				"<span class='notice'>You secure the anchor bolts to the floor.</span>", \
				"<span class='italics'>You hear a ratchet.</span>")
			src.anchored = TRUE
			connect_to_network()
		else if(!linked_shielding.len > 0)
			playsound(src.loc, W.usesound, 75, 1)
			user.visible_message("[user.name] unsecures the [src.name].", \
				"<span class='notice'>You remove the anchor bolts.</span>", \
				"<span class='italics'>You hear a ratchet.</span>")
			src.anchored = FALSE
			disconnect_from_network()
		else
			to_chat(user, "<span class='warning'>Once bolted and linked to a shielding unit it the [src.name] is unable to be moved!</span>")

	else if(istype(W, /obj/item/am_containment))
		if(fueljar)
			to_chat(user, "<span class='warning'>There is already a [fueljar] inside!</span>")
			return

		if(!user.transferItemToLoc(W, src))
			return
		fueljar = W
		user.visible_message("[user.name] loads an [W.name] into the [src.name].", \
				"<span class='notice'>You load an [W.name].</span>", \
				"<span class='italics'>You hear a thunk.</span>")
	else
		return ..()


/obj/machinery/power/am_control_unit/take_damage(damage, damage_type = BRUTE, sound_effect = 1)
	switch(damage_type)
		if(BRUTE)
			if(sound_effect)
				if(damage)
					playsound(loc, 'sound/weapons/smash.ogg', 50, 1)
				else
					playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			if(sound_effect)
				playsound(src.loc, 'sound/items/welder.ogg', 100, 1)
		else
			return
	if(damage >= 20)
		stability -= damage/2
		check_stability()

/obj/machinery/power/am_control_unit/attack_hand(mob/user)
	if(anchored)
		interact(user)

/obj/machinery/power/am_control_unit/proc/add_shielding(obj/machinery/am_shielding/AMS, AMS_linking = 0)
	if(!istype(AMS))
		return FALSE
	if(!anchored)
		return FALSE
	if(!AMS_linking && !AMS.link_control(src))
		return FALSE
	linked_shielding.Add(AMS)
	update_shield_icons = TRUE
	return TRUE


/obj/machinery/power/am_control_unit/proc/remove_shielding(obj/machinery/am_shielding/AMS)
	if(!istype(AMS))
		return FALSE
	linked_shielding.Remove(AMS)
	update_shield_icons = 2
	if(active)
		toggle_power()
	return TRUE


/obj/machinery/power/am_control_unit/proc/check_stability()//TODO: make it break when low also might want to add a way to fix it like a part or such that can be replaced
	if(stability <= 0)
		qdel(src)
	return


/obj/machinery/power/am_control_unit/proc/toggle_power(powerfail = 0)
	active = !active
	if(active)
		use_power = ACTIVE_POWER_USE
		visible_message("The [src.name] starts up.")
	else
		use_power = !powerfail
		visible_message("The [src.name] shuts down.")
	update_icon()
	return


/obj/machinery/power/am_control_unit/proc/check_shield_icons()//Forces icon_update for all shields
	if(shield_icon_delay)
		return
	shield_icon_delay = TRUE
	if(update_shield_icons == 2)//2 means to clear everything and rebuild
		for(var/obj/machinery/am_shielding/AMS in linked_shielding)
			if(AMS.processing)
				AMS.shutdown_core()
			AMS.control_unit = null
			addtimer(CALLBACK(AMS, /obj/machinery/am_shielding.proc/controllerscan), 10)
		linked_shielding = list()
	else
		for(var/obj/machinery/am_shielding/AMS in linked_shielding)
			AMS.update_icon()
	addtimer(CALLBACK(src, .proc/reset_shield_icon_delay), 20)

/obj/machinery/power/am_control_unit/proc/reset_shield_icon_delay()
	shield_icon_delay = FALSE

/obj/machinery/power/am_control_unit/proc/check_core_stability()
	if(linked_cores.len <=0)
		return
	stored_core_stability = FALSE
	for(var/obj/machinery/am_shielding/AMS in linked_cores)
		stored_core_stability += AMS.stability
	stored_core_stability/=linked_cores.len
	update_icon()

/obj/machinery/power/am_control_unit/interact(mob/user)
	if((get_dist(src, user) > 1) || (stat & (BROKEN|NOPOWER)))
		if(!issilicon(user))
			user.unset_machine()
			return
	user.set_machine(src)
	ShowInterface(user)


/obj/machinery/power/am_control_unit/Topic(href, href_list)
	if(..())
		return TRUE

	if(href_list["close"])
		if(usr.machine == src)
			usr.unset_machine()
		return TRUE

	//Ignore input if we are broken or guy is not touching us, AI can control from a ways away
	if(stat & (BROKEN|NOPOWER))
		usr.unset_machine()
		usr << browse(null, "window=AMcontrol")
		return TRUE

	switch(href_list["task"])
		if("close")
			usr << browse(null, "window=AMcontrol")
			usr.unset_machine()
		if("togglestatus")
			toggle_power()
			message_admins("AME toggled [active?"on":"off"] by [usr.real_name] ([key_name_admin(usr)]) at ([COORD(loc)] - [ADMIN_JMP(loc)]",0,1)
		if("eject")
			if(fueljar)
				fueljar.forceMove(drop_location())
			fueljar = null
		if("set_strength")
			var/newval = input("Enter new injection strength") as num|null
			if(!newval)
				return
			fuel_injection = max(1, newval)
			message_admins("AME injection strength set to [fuel_injection] by [usr.real_name] ([key_name_admin(usr)]) at ([COORD(loc)] - [ADMIN_JMP(loc)])",FALSE,TRUE)
		if("refreshicons")
			check_core_stability()

	updateDialog()
	return

/obj/machinery/power/am_control_unit/proc/ShowInterface(mob/user)
	if(!user || !(in_range(src, user) || issilicon(user)))
		return
	var/datum/browser/popup = new(user, "amenew", "Antimatter Control Unit", 500, (issilicon(user) ? 465 : 390)) // Set up the popup browser window
	var/list/dat = list()
	dat += "<div class='line'>"
	dat += "<div class='statusLabel'>Status:</div>"
	if(active)
		dat += "<div class='statusValue average'>Injecting</div>"
	else
		dat += "<div class='statusValue good'>Standby</div>"
	dat += "    <a href='?src=[REF(src)];task=togglestatus;'>Toggle Status</a>"
	if(!fueljar)
		dat += "<div class='notice'>No fuel jar detected.</div>"
	else
		dat += "<div class='statusDisplay'>"
		dat += "<div class='line'>"
		dat += "<div class='statusLabel'>Fuel:</div> "
		dat += "<div class='statusValue'>[fueljar.fuel]/[fueljar.fuel_max]</div>  "
		dat += "<a href='?src=[REF(src)];task=eject;'>Eject</a></div>"
		dat += "<div class='line'>"
		dat += "<div class='statusLabel'>Injecting:</div> "
		dat += "<div class='statusValue'><a href='?src=[REF(src)];task=set_strength;'>[fuel_injection]</a></div></div><div class='clearBoth'></div></div>"
	dat += "<div class='statusDisplay'>"
	dat += "<div class='line'>"
	dat += "<div class='statusLabel'>Stability:</div>"
	dat += "<div class='statusValue'>[stability]%</div><div class='clearBoth'></div></div>"
	dat += "<div class='line'>"
	dat += "<div class='statusLabel'>Shielding Count:</div>"
	dat += "<div class='statusValue'>[linked_shielding.len]</div></div>"
	dat += "<div class='line'>"
	dat += "<div class='statusLabel'>Cores:</div>"
	dat += "<div class='statusValue'>[linked_cores.len]</div>"
	dat += "<div style='float: right'><a href='?src=[REF(src)];task=refreshicons;'>Refresh Parts</a></div></div>"
	dat += "<div class='line'>"
	dat += "<div class='statusLabel'>Current Efficiency:</div>"
	dat += "<div class='statusValue'>[reported_core_efficiency]</div></div>"
	dat += "<div class='line'>"
	dat += "<div class='statusLabel'>Average Efficiency:</div>"
	dat += "<div class='statusValue'>[stability]</div></div>"
	dat += "<div class='line'>"
	dat += "<div class='statusLabel'>Last Produced:</div>"
	dat += "<div class='statusValue'>[stored_power]</div></div><div class='clearBoth'></div></div>"

	popup.set_content(dat.Join())
	popup.open()