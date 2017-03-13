/obj/machinery/power/exporter
	name = "power exporter"
	desc = "It exports power for points, points get rewards."
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator"
	density = 1
	anchored = FALSE
	verb_say = "states"
	var/drain_rate = 0	// amount of power to drain per tick
	var/power_drained = 0 		// has drained this much power
	var/rating = ""
	var/active = FALSE
	var/rewarded = FALSE

/obj/machinery/power/exporter/examine(mob/user)
	..()
	if(!active)
		user << "<span class='notice'>The exporter seems to be offline.</span>"
	else
		user << "<span class='notice'>The [src] is exporting [drain_rate] kilowatts of power, it has consumed [power_drained] kilowatts so far.</span>"

obj/machinery/power/exporter/Initialize()
	..()
	power_exporter_list += src

obj/machinery/power/exporter/Destroy()
	power_exporter_list -= src
	return ..()

/obj/machinery/power/exporter/attackby(obj/item/O, mob/user, params)
	if(!active)
		if(istype(O, /obj/item/weapon/wrench))
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

/obj/machinery/power/exporter/attack_hand(mob/user)
	..()
	if (!anchored)
		user << "<span class='warning'>This device must be anchored by a wrench!</span>"
		return
	if (power_drained >= 4000000 && !rewarded) // 4 billion watts
		rewarded = TRUE
		visible_message("<span class='danger'>You have been blessed by the gods of engineering for your massive power exports!</span>")
		new /obj/effect/overlay/temp/explosion/fast(get_turf(src))
		playsound(src, 'sound/effects/pray_chaplain.ogg', 100, 1)
		for(var/i in 1 to 3)
			new /obj/item/clothing/head/orange_beret(get_turf(src))
			new /obj/item/clothing/suit/poncho/engiponcho(get_turf(src))
			new /obj/item/clothing/gloves/krav_maga/engi(get_turf(src))
	interact(user)

/obj/machinery/power/exporter/attack_ai(mob/user)
	interact(user)

/obj/machinery/power/exporter/attack_paw(mob/user)
	interact(user)

/obj/machinery/power/exporter/interact(mob/user)
	if (!anchored)
		user << "<span class='warning'>This device must be anchored by a wrench!</span>"
		return
	if(!Adjacent(user))
		if(!isAI(user))
			return
	user.set_machine(src)
	var/list/dat = list()
	dat += ("<b>[name]</b><br>")
	if (active)
		dat += ("Exporter: <A href='?src=\ref[src];action=disable'>On</A><br>")
	else
		dat += ("Exporter: <A href='?src=\ref[src];action=enable'>Off</A><br>")
	dat += ("Power consumption: <A href='?src=\ref[src];action=set_power'>[drain_rate] kilowatts</A></u></b><br><br>")
	dat += ("<b><u>Surplus power: [(powernet == null ? "Unconnected" : "[powernet.netexcess/1000] kilowatts")]<br>")
	dat += ("Power exported: [power_drained] kilowatts<br>")
	dat += ("Points earned from exports: [power_drained/200] points<br>")
	switch(drain_rate)
		if(0 to 200)
			rating = "TERRIBLE"
		if(201 to 400)
			rating = "BAD"
		if(401 to 800)
			rating = "SUBPAR"
		if(801 to 2500)
			rating = "DECENT"
		if(2501 to 6000)
			rating = "ROBUST"
		if(6001 to 10000)
			rating = "THE 1%"
		if(10001 to 9999999)
			rating = "UNFATHOMABLE!"
	dat += ("Current export rating: [rating]<br><br><br>")
	dat += ("<b><u>Warning: Setting export rate above the initial surplus is feasible but will exhaust the SMES</b></u>")
	dat += "<br><A href='?src=\ref[src];action=close'>Close</A>"
	var/datum/browser/popup = new(user, "vending", "Power Exporter", 400, 350)
	popup.set_content(dat.Join())
	popup.open()

/obj/machinery/power/exporter/Topic(href, href_list)
	if(..())
		return
	add_fingerprint(usr)
	switch(href_list["action"])
		if("enable")
			if(!active && !crit_fail)
				active = TRUE
				src.updateUsrDialog()
				if(active && !crit_fail && anchored && powernet && drain_rate)
					icon_state = "dominator-yellow"
		if("disable")
			if (active)
				active = FALSE
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
			active = FALSE
			drain_rate = 0
			icon_state = "dominator"
	else
		active = FALSE
		drain_rate = 0
		icon_state = "dominator"


/obj/item/clothing/gloves/krav_maga/engi  // unique bonus
	name = "fists of the singulo"
	desc = "You have spent so much time managing power that your fists have become one with the powernet."
	icon_state = "yellow"
	item_state = "yellow"
	item_color="yellow"
	permeability_coefficient = 0.05
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = 0