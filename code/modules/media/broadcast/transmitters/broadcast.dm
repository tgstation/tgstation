/obj/machinery/media/transmitter/broadcast
	name = "Radio Transmitter"
	desc = "A huge hulk of steel containing high-powered phase-modulating radio transmitting equipment."

	icon = 'icons/obj/machines/broadcast.dmi'
	icon_state = "broadcaster"
	light_color = LIGHT_COLOR_BLUE
	use_power = 0 // We use power_connection for this.
	density = 1
	anchored = 1 // May need map updates idfk
	idle_power_usage = 50
	active_power_usage = 1000

	var/on=0
	var/integrity=100
	var/list/obj/machinery/media/sources=list()
	var/heating_power=40000
	var/list/autolink = null

	var/datum/wires/transmitter/wires = null
	var/datum/power_connection/consumer/cable/power_connection = null

	var/const/RADS_PER_TICK=150
	var/const/MAX_TEMP=70 // Celsius
	machine_flags = MULTITOOL_MENU | SCREWTOGGLE | WRENCHMOVE | FIXED2WORK

/obj/machinery/media/transmitter/broadcast/New()
	..()
	wires = new(src)
	power_connection=new(src,LIGHT)
	power_connection.idle_usage=idle_power_usage
	power_connection.active_usage=active_power_usage

/obj/machinery/media/transmitter/broadcast/Destroy()
	if(wires)
		qdel(wires)
		wires = null
	if(power_connection)
		qdel(power_connection)
		power_connection = null
	..()

/obj/machinery/media/transmitter/broadcast/proc/cable_power_change(var/list/args)
	if(power_connection.powered())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

	update_icon()

/obj/machinery/media/transmitter/broadcast/initialize()
	//testing("[type]/initialize() called!")
	if(autolink && autolink.len)
		for(var/obj/machinery/media/source in orange(20, src))
			if(source.id_tag in autolink)
				sources.Add(source)
				testing("Autolinked [source] -> [src]")
		hook_media_sources()
	if(on)
		update_on()
	power_connection.power_changed.Add(src,"cable_power_change")
	power_connection.connect()
	update_icon()

/obj/machinery/media/transmitter/broadcast/wrenchAnchor(mob/user)
	if(..())
		if(anchored) // We are now anchored
			power_connection.connect() // Connect to the powernet
		else // We are now NOT anchored
			power_connection.disconnect() // Ditch powernet.
			on=0
			update_on()
		return 1
	return

/obj/machinery/media/transmitter/broadcast/proc/hook_media_sources()
	if(!sources.len)
		return

	for(var/obj/machinery/media/source in sources)
		// Hook into output
		source.hookMediaOutput(src,exclusive=1) // Don't hook into the room media sources.
		source.update_music() // Request music update

/obj/machinery/media/transmitter/broadcast/proc/unhook_media_sources()
	if(!sources.len)
		return

	for(var/obj/machinery/media/source in sources)
		source.unhookMediaOutput(src)

	broadcast() // Bzzt

/obj/machinery/media/transmitter/broadcast/attackby(var/obj/item/W, mob/user)
	. = ..()
	if(panel_open && iswiretool(W))
		attack_hand(user)
	if(issolder(W))
		if(integrity>=100)
			to_chat(user, "<span class='warning'>[src] doesn't need to be repaired!</span>")
			return
		var/obj/item/weapon/solder/S = W
		if(!S.remove_fuel(4,user))
			return
		playsound(loc, 'sound/items/Welder.ogg', 100, 1)
		if(do_after(user, src,40))
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)
			integrity = 100
			to_chat(user, "<span class='notice'>You repair the blown fuses on [src].</span>")

/obj/machinery/media/transmitter/broadcast/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	attack_hand(user)

/obj/machinery/media/transmitter/broadcast/attack_hand(var/mob/user as mob)
	if(panel_open)
		wires.Interact(user)
	. = ..()
	if(.)
		return .

/obj/machinery/media/transmitter/broadcast/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	// You need a multitool to use this, or be silicon
	if(!issilicon(user))
		// istype returns false if the value is null
		if(!istype(user.get_active_hand(), /obj/item/device/multitool))
			return

	if(stat & (BROKEN|NOPOWER))
		return

	var/screen = {"
	<h2>Settings</h2>
	<ul>
		<li><b>Power:</b> <a href="?src=\ref[src];power=1">[on?"On":"Off"]</a></li>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(media_frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[initial(media_frequency)]">Reset</a>)</li>
	</ul>
	<h2>Media Sources</h2>"}
	if(!sources.len)
		screen += "<em>No media sources have been selected.</em>"
	else
		screen += "<ol>"
		for(var/i=1;i<=sources.len;i++)
			var/obj/machinery/media/source=sources[i]
			screen += "<li>\ref[source] [source.name] ([source.id_tag])  <a href='?src=\ref[src];unlink=[i]'>\[X\]</a></li>"
		screen += "</ol>"
	return screen


/obj/machinery/media/transmitter/broadcast/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	cable_power_change()
	..(severity)

/obj/machinery/media/transmitter/broadcast/update_icon()
	overlays = 0
	if(stat & (NOPOWER|BROKEN) || wires.IsIndexCut(TRANS_POWER))
		return
	if(on)
		overlays += image(icon = icon, icon_state = "broadcaster on")
		set_light(3) // OH FUUUUCK
		use_power = 2
	else
		set_light(1) // Only the tile we're on.
		use_power = 1
	if(sources.len)
		overlays += image(icon = icon, icon_state = "broadcaster linked")

/obj/machinery/media/transmitter/broadcast/proc/update_on()
	if(on)
		visible_message("\The [src] hums as it begins pumping energy into the air!")
		connect_frequency()
		hook_media_sources()
	else
		visible_message("\The [src] falls quiet and makes a soft ticking noise as it cools down.")
		unhook_media_sources()
		disconnect_frequency()
	update_icon()

/obj/machinery/media/transmitter/broadcast/Topic(href,href_list)
	if(..(href, href_list))
		return

	if("power" in href_list)
		if(!power_connection.powernet)
			power_connection.connect()
		if(!power_connection.powered())
			to_chat(usr, "<span class='warning'>This machine needs to be hooked up to a powered cable.</span>")
			return
		on = !on
		update_on()
		return
	if("set_freq" in href_list)
		var/newfreq=media_frequency
		if(href_list["set_freq"]!="-1")
			newfreq = text2num(href_list["set_freq"])
		else
			newfreq = input(usr, "Set a new frequency (MHz, 90.0, 200.0).", src, media_frequency) as null|num
		if(newfreq)
			if(findtext(num2text(newfreq), "."))
				newfreq *= 10 // shift the decimal one place
			if(newfreq > 900 && newfreq < 2000) // Between (90.0 and 100.0)
				disconnect_frequency()
				media_frequency = newfreq
				connect_frequency()
			else
				to_chat(usr, "<span class='warning'>Invalid FM frequency. (90.0, 200.0)</span>")

/obj/machinery/media/transmitter/broadcast/proc/count_rad_wires()
	return !wires.IsIndexCut(TRANS_RAD_ONE) + !wires.IsIndexCut(TRANS_RAD_TWO)

/obj/machinery/media/transmitter/broadcast/process()
	if(stat & (NOPOWER|BROKEN) || wires.IsIndexCut(TRANS_POWER))
		return
	if(on && anchored)
		if(integrity<=0 || count_rad_wires()==0) //Shut down if too damaged OR if no rad wires
			on=0
			update_on()

		// Radiation
		for(var/mob/living/carbon/M in view(src,3))
			var/rads = RADS_PER_TICK * sqrt( 1 / (get_dist(M, src) + 1) )
			if(istype(M,/mob/living/carbon/human))
				M.apply_effect((rads*count_rad_wires()),IRRADIATE)
			else
				M.radiation += rads

		// Heat output
		var/turf/simulated/L = loc
		if(istype(L) && heating_power)
			var/datum/gas_mixture/env = L.return_air()
			if(env.temperature != MAX_TEMP + T0C)

				var/transfer_moles = 0.25 * env.total_moles()

				var/datum/gas_mixture/removed = env.remove(transfer_moles)

//				to_chat(world, "got [transfer_moles] moles at [removed.temperature]")

				if(removed)

					var/heat_capacity = removed.heat_capacity()
//					to_chat(world, "heating ([heat_capacity])")
					if(heat_capacity) // Added check to avoid divide by zero (oshi-) runtime errors -- TLE
						if(removed.temperature < MAX_TEMP + T0C)
							removed.temperature = min(removed.temperature + heating_power/heat_capacity, 1000) // Added min() check to try and avoid wacky superheating issues in low gas scenarios -- TLE
						else
							removed.temperature = max(removed.temperature - heating_power/heat_capacity, TCMB)

//					to_chat(world, "now at [removed.temperature]")

				env.merge(removed)

//				to_chat(world, "turf now at [env.temperature]")

		// Checks heat from the environment and applies any integrity damage
		var/datum/gas_mixture/environment = loc.return_air()
		switch(environment.temperature)
			if(T0C to (T20C + 20))
				integrity = Clamp(integrity, 0, 100)
			if((T20C + 20) to INFINITY)
				integrity = max(0, integrity - 1)

/obj/machinery/media/transmitter/broadcast/linkWith(var/mob/user, var/obj/O, var/list/context)
	if(istype(O,/obj/machinery/media) && !is_type_in_list(O,list(/obj/machinery/media/transmitter,/obj/machinery/media/receiver)))
		if(sources.len)
			unhook_media_sources()
		sources.Add(O)
		hook_media_sources()
		update_icon()
		return 1
	return 0

/obj/machinery/media/transmitter/broadcast/unlinkFrom(var/mob/user, var/obj/O)
	if(O in sources)
		unhook_media_sources()
		sources.Remove(O)
		if(sources.len)
			hook_media_sources()
		update_icon()
	return 0

/obj/machinery/media/transmitter/broadcast/canLink(var/obj/O, var/list/context)
	return istype(O,/obj/machinery/media) && !is_type_in_list(O,list(/obj/machinery/media/transmitter,/obj/machinery/media/receiver))

/obj/machinery/media/transmitter/broadcast/isLinkedWith(var/obj/O)
	return O in sources

/obj/machinery/media/transmitter/broadcast/dj
	id_tag = "dj"
	media_frequency=1015
	autolink = list("DJ Satellite")
	on=1

// Centcomm Shuttle Radio
/obj/machinery/media/transmitter/broadcast/shuttle
	id_tag = "shuttle"
	media_frequency=953
	autolink = list("Shuttle")
	on=1
