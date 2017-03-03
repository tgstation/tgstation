/obj/machinery/power/exporter
	name = "power exporter"
	desc = "It exports power for points, points get rewards.</span>"
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator"
	density = 1
	anchored = 0
	verb_say = "states"
	var/drain_rate = 0	// amount of power to drain per tick
	var/power_drained = 0 		// has drained this much power
	var/active = 0

/obj/machinery/power/exporter/examine(mob/user)
	..()
	if(!active)
		user << "<span class='notice'>The exporter seems to be offline.</span>"
	else
		user << "<span class='notice'>The [src] is exporting [drain_rate] kilowatts of power, it has consumed [power_drained/1000] kilowatts so far.</span>"


/obj/machinery/power/exporter/attackby(obj/item/O, mob/user, params)
	if(!active)
		if(istype(O, /obj/item/weapon/wrench))
			if(!anchored && !isinspace())
				connect_to_network()
				user << "<span class='notice'>You secure the [src] to the floor.</span>"
				anchored = 1
			else if(anchored)
				disconnect_from_network()
				user << "<span class='notice'>You unsecure and disconnect the [src].</span>"
				anchored = 0
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			return
	return ..()

/obj/machinery/power/exporter/attack_hand(mob/user)
	..()
	if (!anchored)
		user << "<span class='warning'>This device must be anchored by a wrench!</span>"
		return

	interact(user)

/obj/machinery/power/exporter/attack_ai(mob/user)
	interact(user)

/obj/machinery/power/exporter/attack_paw(mob/user)
	interact(user)

/obj/machinery/power/exporter/interact(mob/user)
	if (!anchored)
		user << "<span class='warning'>This device must be anchored by a wrench!</span>"
		user.unset_machine()
		user << browse(null, "window=port_gen")
		return
	if (get_dist(src, user) > 1 )
		if(!isAI(user))
			user.unset_machine()
			user << browse(null, "window=port_gen")
			return
	user.set_machine(src)
	var/dat = text("<b>[name]</b><br>")
	if (active)
		dat += text("Exporter: <A href='?src=\ref[src];action=disable'>On</A><br>")
	else
		dat += text("Exporter: <A href='?src=\ref[src];action=enable'>Off</A><br>")
	dat += text("Power consumption: <A href='?src=\ref[src];action=set_power'>[drain_rate] kilowatts</A><br>")
	dat += text("Surplus power: [(powernet == null ? "Unconnected" : "[powernet.netexcess/1000] kilowatts")]<br>")
	dat += text("Power exported: [power_drained] kilowatts<br>")
	dat += "<br><A href='?src=\ref[src];action=close'>Close</A>"
	var/datum/browser/popup = new(user, "vending", "Power Exporter", 400, 350)
	popup.set_content(dat)
	popup.open()

/obj/machinery/power/exporter/Topic(href, href_list)
	if(..())
		return
	src.add_fingerprint(usr)
	switch(href_list["action"])
		if("enable")
			if(!active && !crit_fail)
				active = 1
				src.updateUsrDialog()
				if(active && !crit_fail && anchored && powernet && drain_rate)
					icon_state = "dominator-yellow"
		if("disable")
			if (active)
				active = 0
				drain_rate = 0
				src.updateUsrDialog()
		if("set_power")
			drain_rate = input("Power export rate (in kW):", name, drain_rate)
			src.updateUsrDialog()
			if(active && !crit_fail && anchored && powernet && drain_rate)
				icon_state = "dominator-yellow"
		if ("close")
			usr.unset_machine()


/obj/machinery/power/exporter/process()
	if(active && !crit_fail && anchored && powernet)
		if(powernet.netexcess >= 1)
			powernet.load += drain_rate*1000
			power_drained += drain_rate
		else
			visible_message("Power export levels have exceeded energy surplus, shutting down")
			active = 0
			drain_rate = 0
			icon_state = "dominator"
	else
		active = 0
		drain_rate = 0
		icon_state = "dominator"
