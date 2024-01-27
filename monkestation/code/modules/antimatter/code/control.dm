#define SHIELD_UPDATE_NONE 0 //Dont update our icon
#define SHIELD_UPDATE_NORMAL 1 //Update the icons of just ourselfes and our neighbors
#define SHIELD_UPDATE_FULL 2 //Update the icons of every piece of the antimatter reactor
#define CORE_POWER_OUTPUT 25000 //How much do we generate per a single unit of fuel used?

/obj/machinery/power/am_control_unit
	name = "antimatter control unit"
	desc = "This device injects antimatter into connected shielding units, the more antimatter injected the more power produced.  Wrench the device to set it up."
	icon = 'monkestation/code/modules/antimatter/icons/antimatter.dmi'
	icon_state = "control"
	anchored = FALSE
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	active_power_usage = 1000

	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT | INTERACT_ATOM_REQUIRES_ANCHORED

	var/list/obj/machinery/am_shielding/linked_shielding
	var/list/obj/machinery/am_shielding/linked_cores
	var/obj/item/antimatter_jar/fuel_jar
	var/update_shield_icons = SHIELD_UPDATE_NONE
	var/stability = 100
	var/exploding = FALSE

	///Are we currently turned on or off?
	var/active = FALSE
	///How much fuel should we inject?
	var/fuel_injection = 2
	///Lets not spam resets when we dont need to
	var/shield_icon_delay = FALSE
	var/reported_core_efficiency = 0

	var/power_cycle = 0
	///How many ticks till produce_power is called
	var/power_cycle_delay = 4
	var/stored_core_stability = 100
	var/stored_core_stability_delay = FALSE
	///Power to deploy per tick
	var/stored_power = 0

	///Our internal radio
	var/obj/item/radio/radio

/obj/machinery/power/am_control_unit/Initialize()
	. = ..()
	linked_shielding = list()
	linked_cores = list()

	radio = new(src)
	radio.set_listening(FALSE)

/obj/machinery/power/am_control_unit/Destroy() //Perhaps damage and run stability checks rather than just del on the others
	for(var/obj/machinery/am_shielding/Shielding in linked_shielding)
		Shielding.control_unit = null
		qdel(Shielding)
	QDEL_NULL(fuel_jar)
	QDEL_NULL(radio)
	return ..()


/obj/machinery/power/am_control_unit/process()
	if(exploding)
		explosion(get_turf(src), 8, 12, 18, 12)
		if(src)
			qdel(src)

	if(update_shield_icons && !shield_icon_delay)
		check_shield_icons()
		update_shield_icons = SHIELD_UPDATE_NONE

	if(machine_stat & (NOPOWER|BROKEN) || !active) //can update the icons even without power
		return

	if(!fuel_jar) //No fuel but we are on, shutdown
		toggle_power()
		playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 0)
		return

	add_avail(stored_power)

	power_cycle++
	if(power_cycle >= power_cycle_delay)
		produce_power()
		check_core_stability()
		power_cycle = 0

	return


/obj/machinery/power/am_control_unit/proc/produce_power()
	playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)
	var/core_power = reported_core_efficiency //Effectively how much fuel we can safely deal with
	if(core_power <= 0)
		return FALSE //Something is wrong
	var/core_damage = 0
	var/fuel = fuel_jar.usefuel(fuel_injection)

	stored_power = (fuel/core_power) * fuel * CORE_POWER_OUTPUT
	//Now check if the cores could deal with it safely, this is done after so you can overload for more power if needed, still a bad idea
	if(fuel > (2 * core_power)) //More fuel has been put in than the current cores can deal with
		if(prob(20))
			visible_message(span_warning("Some small cracks form on [src]!"))
		if(prob(50))
			core_damage = 1 //Small chance of damage
		if(((fuel - core_power) > 5 && (fuel - core_power) < 10))
			core_damage = 5 //Now its really starting to overload the cores
			if(prob(20))
				radio.talk_into(src, "Warning: Core overload detected, please contact AME technicians", null)
		if((fuel - core_power) > 10)
			core_damage = 20 //Welp now you did it, they wont stand much of this
			radio.talk_into(src, "+WARNING: MAJOR DAMAGE SUSTAINED TO THE AME UNIT+", null)
		if(core_damage == 0)
			return
		for(var/obj/machinery/am_shielding/Shielding in linked_cores)
			Shielding.stability -= core_damage
			Shielding.check_stability(1)
		playsound(src.loc, 'sound/effects/bang.ogg', 50, 1)
	return TRUE


/obj/machinery/power/am_control_unit/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	switch(severity)
		if(1)
			if(active)
				toggle_power()
			stability -= rand(15,30)
		if(2)
			if(active)
				toggle_power()
			stability -= rand(10,20)

/obj/machinery/power/am_control_unit/blob_act()
	stability -= 20
	if(prob(100-stability)) //Might infect the rest of the machine
		for(var/obj/machinery/am_shielding/Shielding in linked_shielding)
			Shielding.blob_act()
		qdel(src)
		return
	check_stability()
	return


/obj/machinery/power/am_control_unit/ex_act(severity, target)
	stability -= (80 - (severity * 20))
	check_stability()
	return


/obj/machinery/power/am_control_unit/bullet_act(obj/projectile/P)
	. = ..()
	if(P.armor_flag != BULLET)
		stability -= P.force
		check_stability()


/obj/machinery/power/am_control_unit/power_change()
	..()
	if(machine_stat & NOPOWER)
		if(active)
			toggle_power(1)
		else
			use_power = NO_POWER_USE

	else if(!machine_stat && anchored)
		use_power = IDLE_POWER_USE

	return


/obj/machinery/power/am_control_unit/update_icon()
	if(active)
		icon_state = "control_on"
	else icon_state = "control"
	return ..()
	//No other icons for it atm


/obj/machinery/power/am_control_unit/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WRENCH)
		if(!anchored)
			W.play_tool_sound(src, 75)
			user.visible_message("[user.name] secures the [src.name] to the floor.", \
				span_notice("You secure the anchor bolts to the floor."), \
				"<span class='italics'>You hear a ratchet.</span>")
			src.anchored = TRUE
			connect_to_network()
		else if(!linked_shielding.len > 0)
			W.play_tool_sound(src, 75)
			user.visible_message("[user.name] unsecures the [src.name].", \
				span_notice("You remove the anchor bolts."), \
				"<span class='italics'>You hear a ratchet.</span>")
			src.anchored = FALSE
			disconnect_from_network()
		else
			to_chat(user, span_warning("Once bolted and linked to a shielding unit it the [src.name] is unable to be moved!"))

	else if(istype(W, /obj/item/antimatter_jar))
		if(fuel_jar)
			to_chat(user, span_warning("There is already a [fuel_jar] inside!"))
			return

		if(!user.transferItemToLoc(W, src))
			return
		fuel_jar = W
		user.visible_message("[user.name] loads an [W.name] into the [src.name].", \
				span_notice("You load an [W.name]."), \
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

/obj/machinery/power/am_control_unit/proc/add_shielding(obj/machinery/am_shielding/AMS, AMS_linking = 0)
	if(!istype(AMS))
		return FALSE

	if(!anchored)
		return FALSE

	if(!AMS_linking && !AMS.link_control(src))
		return FALSE

	linked_shielding.Add(AMS)
	update_shield_icons = SHIELD_UPDATE_NORMAL
	return TRUE


/obj/machinery/power/am_control_unit/proc/remove_shielding(obj/machinery/am_shielding/AMS)
	if(!istype(AMS))
		return FALSE
	linked_shielding.Remove(AMS)
	update_shield_icons = SHIELD_UPDATE_FULL
	if(active)
		toggle_power()
	return TRUE


/obj/machinery/power/am_control_unit/proc/check_stability() //TODO: make it break when low also might want to add a way to fix it like a part or such that can be replaced
	if(stability <= 0)
		qdel(src)
	return


/obj/machinery/power/am_control_unit/proc/toggle_power(powerfail = 0)
	active = !active
	if(active)
		use_power = ACTIVE_POWER_USE
		visible_message("The [src.name] starts up.")
		update_shield_icons = SHIELD_UPDATE_NORMAL
	else
		use_power = !powerfail
		visible_message("The [src.name] shuts down.")
		update_shield_icons = SHIELD_UPDATE_NORMAL
	update_icon()
	return


/obj/machinery/power/am_control_unit/proc/check_shield_icons() //Forces icon_update for all shields
	if(shield_icon_delay)
		return
	shield_icon_delay = TRUE
	if(update_shield_icons == SHIELD_UPDATE_FULL) //Clear everything and rebuild
		for(var/obj/machinery/am_shielding/AMS in linked_shielding)
			if(AMS.processing)
				AMS.shutdown_core()
			AMS.control_unit = null
			addtimer(CALLBACK(AMS, TYPE_PROC_REF(/obj/machinery/am_shielding, controllerscan)), 10)
		linked_shielding = list()
	else
		for(var/obj/machinery/am_shielding/AMS in linked_shielding)
			AMS.update_icon()
	addtimer(CALLBACK(src, PROC_REF(reset_shield_icon_delay)), 20)

/obj/machinery/power/am_control_unit/proc/reset_shield_icon_delay()
	shield_icon_delay = FALSE

/obj/machinery/power/am_control_unit/proc/check_core_stability()
	if(stored_core_stability_delay || linked_cores.len <= 0)
		return

	stored_core_stability_delay = TRUE
	stored_core_stability = 0
	for(var/obj/machinery/am_shielding/Shielding in linked_cores)
		stored_core_stability += Shielding.stability

	stored_core_stability /= linked_cores.len
	addtimer(CALLBACK(src, PROC_REF(reset_stored_core_stability_delay)), 40)

/obj/machinery/power/am_control_unit/proc/reset_stored_core_stability_delay()
	stored_core_stability_delay = FALSE

/obj/machinery/power/am_control_unit/ui_interact(mob/user)
	. = ..()
	if((get_dist(src, user) > 1) || (machine_stat & (BROKEN|NOPOWER)))
		if(!isAI(user))
			user.unset_machine()
			user << browse(null, "window=AMcontrol")
			return

	var/dat = ""
	dat += "AntiMatter Control Panel<BR>"
	dat += "<A href='?src=[REF(src)];close=1'>Close</A><BR>"
	dat += "<A href='?src=[REF(src)];refresh=1'>Refresh</A><BR>"
	dat += "Status: [(active?"Injecting":"Standby")] <BR>"
	dat += "<A href='?src=[REF(src)];togglestatus=1'>Toggle Status</A><BR>"

	dat += "Stability: [stability]%<BR>"
	dat += "Reactor parts: [linked_shielding.len]<BR>" //TODO: perhaps add some sort of stability check
	dat += "Cores: [linked_cores.len]<BR><BR>"
	dat += "-Current Efficiency: [reported_core_efficiency]<BR>"
	dat += "-Average Stability: [stored_core_stability] <A href='?src=[REF(src)];refreshstability=1'>(update)</A><BR>"
	dat += "Last Produced: [display_power(stored_power)]<BR>"

	dat += "Fuel: "
	if(!fuel_jar)
		dat += "<BR>No fuel receptacle detected."
	else
		dat += "<A href='?src=[REF(src)];ejectjar=1'>Eject</A><BR>"
		dat += "- [fuel_jar.fuel]/[fuel_jar.fuel_max] Units<BR>"

		dat += "- Injecting: [fuel_injection] units<BR>"
		dat += "- <A href='?src=[REF(src)];strengthdown=1'>--</A>|<A href='?src=[REF(src)];strengthup=1'>++</A><BR><BR>"


	user << browse(dat, "window=AMcontrol;size=420x500")
	onclose(user, "AMcontrol")
	return


/obj/machinery/power/am_control_unit/Topic(href, href_list)
	if(..())
		return

	if(href_list["close"])
		usr << browse(null, "window=AMcontrol")
		usr.unset_machine()
		return

	if(href_list["togglestatus"])
		toggle_power()

	if(href_list["ejectjar"])
		if(fuel_jar)
			fuel_jar.forceMove(drop_location())
			fuel_jar = null
			//fuel_jar.control_unit = null currently it does not care where it is
			//update_icon() when we have the icon for it

	if(href_list["strengthup"])
		fuel_injection++

	if(href_list["strengthdown"])
		fuel_injection--
		if(fuel_injection < 0)
			fuel_injection = 0

	if(href_list["refreshstability"])
		check_core_stability()

	updateDialog()
	return

#undef SHIELD_UPDATE_NONE
#undef SHIELD_UPDATE_NORMAL
#undef SHIELD_UPDATE_FULL
#undef CORE_POWER_OUTPUT
