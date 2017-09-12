/obj/machinery/power/omnibox
	name = "Omnibox"
	desc = "A cutting edge device capable of automatically converting vast amounts of energy into unfathomably complex machinery."
	icon = 'icons/obj/machines/omnibox.dmi'
	icon_state = "dominator"
	density = 1
	anchored = FALSE
	verb_say = "states"
	var/drain_rate = 0	// amount of power to drain per tick
	var/power_drained = 0 		// has drained this much power
	var/active = FALSE
	var/goal = 100
	var/optional_message
	var/list/possible_machines = list(
		/datum/omnibox/factory
	)

/obj/machinery/power/omnibox/examine(mob/user)
	..()
	if(!active)
		user << "<span class='notice'>The [src] seems to be inactive.</span>"
	else
		user << "<span class='notice'>The [src] is converting approximately [drain_rate] kilowatts of power every cycle (2 seconds). It has consumed [power_drained] kilowatts so far.</span>"

/obj/machinery/power/omnibox/attackby(obj/item/O, mob/user, params)
	if(!active)
		if(istype(O, /obj/item/wrench))
			if(!anchored && !isinspace())
				connect_to_network()
				user << "<span class='notice'>You secure the [src] to the floor.</span>"
				anchored = TRUE
			else if(anchored)
				disconnect_from_network()
				user << "<span class='notice'>You unsecure and disconnect the [src].</span>"
				anchored = FALSE
			playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
			return
	return ..()

/obj/machinery/power/omnibox/attack_hand(mob/user)
	..()
	if (!anchored)
		user << "<span class='warning'>This device must be anchored by a wrench!</span>"
		return
	interact(user)

/obj/machinery/power/omnibox/attack_ai(mob/user)
	interact(user)

/obj/machinery/power/omnibox/attack_paw(mob/user)
	interact(user)

/obj/machinery/power/omnibox/interact(mob/user)
	if (!anchored)
		to_chat(user,"<span class='warning'>This device must be anchored by a wrench!</span>")
		return
	if(!Adjacent(user) && (!isAI(user)))
		return
	user.set_machine(src)
	var/list/dat = list()
	dat += ("<b>[name]</b><br>")
	if (power_drained >= goal && goal)
		dat += "<B>The omnibox has reached maximum charge. Please select a desired development.</B><BR>"
		dat += "<HR>"
		for(var/m in possible_machines)
			var/datum/omnibox/O = m
			dat += "<a href='?src=\ref[src];action=[O.id]'></a> - [initial(O.desc)]<br>"
	else
		if (active)
			dat += ("Omni: <A href='?src=\ref[src];action=disable'>On</A><br>")
		else
			dat += ("Omni: <A href='?src=\ref[src];action=enable'>Off</A><br>")
		dat += ("Power export rate: <A href='?src=\ref[src];action=set_power'>[drain_rate] kilowatts</A><br><br>")
		dat += ("Surplus power: [(powernet == null ? "Unconnected" : "[powernet.netexcess/1000] kilowatts")]<br>")
		dat += ("Total Power converted: [power_drained] kilowatts<br><br>")
		if (goal)
			dat += ("<B>The [src] is [(100*(power_drained/goal))]% complete</B><br>")
		if (optional_message)
			dat += optional_message
		dat += ("<br><A href='?src=\ref[src];action=close'>Close</A>")
	var/datum/browser/popup = new(user, "vending", "Omnibox", 400, 350)
	popup.set_content(dat.Join())
	popup.open()

/obj/machinery/power/omnibox/Topic(href, href_list)
	if(..())
		return
	add_fingerprint(usr)
	switch(href_list["action"])
		if("enable")
			if(!active && !crit_fail)
				active = TRUE
				src.updateUsrDialog()
				if(active && !crit_fail && anchored)
					icon_state = "[src]1"
		if("disable")
			if (active)
				active = FALSE
				drain_rate = 0
				src.updateUsrDialog()
		if("set_power")
			drain_rate = input("Power export rate (in kW):", name, drain_rate)
			src.updateUsrDialog()
			if(active && !crit_fail && anchored)
				icon_state = "[src]1"
		if ("close")
			usr.unset_machine()
		if ("Vehicle Factory")
			var/datum/omnibox/factory/F
			for(var/obj/machinery/MA in F.types)
				MA = new(loc)
			qdel(src)


/obj/machinery/power/omnibox/process()
	if(active && !crit_fail && anchored && powernet && drain_rate && (power_drained < goal))
		if(powernet.netexcess >= 1)
			powernet.load += drain_rate*1000
			power_drained += drain_rate
		else
			visible_message("Power conversion levels have exceeded energy grid supply, shutting down")
			active = FALSE
			drain_rate = 0
			icon_state = "[src]0"
	else
		active = FALSE
		drain_rate = 0
		icon_state = "[src]0"

/datum/omnibox
	var/id = "Placeholder"
	var/desc = "This shouldn't exist"
	var/list/types = list()

/datum/omnibox/factory
	id = "Vehicle Factory"
	desc = "An advanced assembly line capable of turning raw energy into prototype vehicles"
	types = list(
		/obj/machinery/power/omnibox/factory,
		/obj/machinery/power/omnibox/omnicube
	)

/obj/machinery/power/omnibox/omnicube
	name = "Omnicube Generator"
	desc = "Generates volatile omnicubes from the power grid that are designed for use in the vehicle factory."
	icon_state = "Omnicube Generator0"
	goal = 0
	var/cube = 10000
	var/surplus = 0

/obj/machinery/power/omnibox/omnicube/Initialize()
	. = ..()
	optional_message = "<B>Based on current power levels, the [src] is expected to create [power_drained/10000] omnicube every two seconds.</B><br>"

/obj/machinery/power/omnibox/omnicube/process()
	if(active && !crit_fail && anchored && powernet)
		if(powernet.netexcess >= 1)
			powernet.load += drain_rate*1000
			power_drained += drain_rate
			surplus += drain_rate
			while(surplus >= cube)
				surplus -= 10000
				new /obj/item/omnicube(locate(min(x+1,world.maxx),y,z))
		else
			visible_message("Power conversion levels have exceeded energy grid supply, shutting down")
			active = FALSE
			drain_rate = 0
			icon_state = "[src]0"
	else
		active = FALSE
		drain_rate = 0
		icon_state = "[src]0"

/obj/machinery/power/omnibox/factory
	name = "Vehicle Factory"
	desc = "A quantum-calibrated factory that consumes omnicubes in order to generate unique prototype vehicles."
	icon_state = "Vehicle Factory"
	var/finished = 60
	var/progress = 0
	var/reset = 1800
	var/iterations = 0
	var/record = 0
	var/efficiency = 0.2
	var/ideal
	var/phase1
	var/phase2
	var/phase3


/obj/machinery/power/omnibox/factory/Initialize()
	. = ..()
	phase1 = rand(10)
	phase2 = rand(10,15)
	phase3 = rand(15,20)
	ideal = phase1
	desc += " The factory's instruments are currently harmonized to a [ideal] second wavelength."

/obj/machinery/power/omnibox/factory/interact(mob/user)
	if (!anchored)
		to_chat(user,"<span class='warning'>This device must be anchored by a wrench!</span>")
		return
	if(!Adjacent(user) && (!isAI(user)))
		return
	user.set_machine(src)
	var/list/dat = list()
	dat += ("<b>[name]</b><br>")
	if (active)
		dat += ("Factory: <A href='?src=\ref[src];action=disable'>On</A><br>")
	else
		dat += ("Factory: <A href='?src=\ref[src];action=enable'>Off</A><br>")
	dat += ("The current vehicle is [100*(progress/finished)]% complete. It will require [finished-progress] ideal cubes to finish the current vehicles.<br><br>")
	if(record)
		dat += ("<b>The last omnicube was processed with a deviation of [record] seconds relative to the ideal - as a result the omnicube contributed [efficiency*100]% of its full potential.</b><br>")
	else
		dat += ("<b>Current instruments are synchronized to an omnicube delay of [ideal] seconds.</b><br>")
	dat += ("<br><A href='?src=\ref[src];action=close'>Close</A>")
	var/datum/browser/popup = new(user, "vending", "Vehicle Factory", 400, 350)
	popup.set_content(dat.Join())
	popup.open()

/obj/machinery/power/omnibox/factory/process()
	if(active && !crit_fail && anchored)
		for(var/obj/item/omnicube/O in orange(1, src))
			qdel(O)
			record = 0.1 * ((ideal*10)-(world.time-O.lifespan))
			var/dev = abs(record)
			if(dev < 4)
				efficiency = (1-(0.25*round(dev)))
			else
				efficiency = 0.2
			progress += efficiency
			playsound(src, 'sound/machines/ding.ogg', 25, 0)
			if(progress >= finished)
				progress -= finished
				new /obj/vehicle/space/speedbike/atmos(locate(min(x+1,world.maxx),y,z))
				new /obj/vehicle/space/speedbike/repair(locate(x,min(y+1,world.maxy),z))
				iterations = 0
				ideal = phase1
				return
			if(round(progress/(finished/3)) > iterations)
				iterations++
				switch(iterations)
					if(0)
						ideal = phase1
					if(1)
						ideal = phase2
					if(2)
						ideal = phase3
				playsound(src, 'sound/machines/warning-buzzer.ogg', 50, 0)
				say("Prototype construction has entered Phase [iterations+1]. Instruments have been synchronized to a [ideal] second delay.")
	else
		active = FALSE
		icon_state = "[src]0"

obj/item/omnicube
	name = "Omnicube"
	desc = "A volatile energy container designed for use in the vehicle factory."
	icon = 'icons/obj/machines/omnibox.dmi'
	icon_state = "omnicube"
	var/lifespan = 0

obj/item/omnicube/Initialize()
	. = ..()
	lifespan = world.time