/obj/machinery/media/transmitter/broadcast
	name = "Radio Transmitter"
	desc = "A huge hulk of steel containing high-powered phase-modulating radio transmitting equipment."

	icon = 'icons/obj/machines/broadcast.dmi'
	icon_state = "broadcaster"
	l_color="#4285F4"
	use_power = 1
	idle_power_usage = 50
	active_power_usage = 1000

	var/on=0
	var/integrity=100
	var/list/obj/machinery/media/sources=list()
	var/heating_power=40000
	var/list/autolink = null

	var/const/RADS_PER_TICK=150
	var/const/MAX_TEMP=70 // Celsius

/obj/machinery/media/transmitter/broadcast/initialize()
	testing("[type]/initialize() called!")
	if(autolink && autolink.len)
		for(var/obj/machinery/media/source in orange(20, src))
			if(source.id_tag in autolink)
				sources.Add(source)
				testing("Autolinked [source] -> [src]")
		hook_media_sources()
	if(on)
		update_on()
	update_icon()

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
	if(istype(W, /obj/item/device/multitool))
		update_multitool_menu(user)
		return 1

/obj/machinery/media/transmitter/broadcast/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	attack_hand(user)

/obj/machinery/media/transmitter/broadcast/attack_hand(var/mob/user as mob)
	update_multitool_menu(user)

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



/obj/machinery/light_switch/power_change()
	if(powered(LIGHT))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

	updateicon()

/obj/machinery/light_switch/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	power_change()
	..(severity)

/obj/machinery/media/transmitter/broadcast/update_icon()
	overlays = 0
	if(stat & (NOPOWER|BROKEN))
		return
	if(on)
		overlays+="broadcaster on"
		SetLuminosity(3) // OH FUUUUCK
		use_power = 2
	else
		SetLuminosity(1) // Only the tile we're on.
		use_power = 1
	if(sources.len)
		overlays+="broadcaster linked"

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
				usr << "\red Invalid FM frequency. (90.0, 200.0)"

/obj/machinery/media/transmitter/broadcast/process()
	if(stat & (NOPOWER|BROKEN))
		return
	if(on)
		if(integrity<=0)
			on=0
			update_on()

		// Radiation
		for(var/mob/living/carbon/M in view(src,3))
			var/rads = RADS_PER_TICK * sqrt( 1 / (get_dist(M, src) + 1) )
			if(istype(M,/mob/living/carbon/human))
				M.apply_effect((rads*3),IRRADIATE)
			else
				M.radiation += rads

		// Heat output
		var/turf/simulated/L = loc
		if(istype(L) && heating_power)
			var/datum/gas_mixture/env = L.return_air()
			if(env.temperature != MAX_TEMP + T0C)

				var/transfer_moles = 0.25 * env.total_moles()

				var/datum/gas_mixture/removed = env.remove(transfer_moles)

				//world << "got [transfer_moles] moles at [removed.temperature]"

				if(removed)

					var/heat_capacity = removed.heat_capacity()
					//world << "heating ([heat_capacity])"
					if(heat_capacity) // Added check to avoid divide by zero (oshi-) runtime errors -- TLE
						if(removed.temperature < MAX_TEMP + T0C)
							removed.temperature = min(removed.temperature + heating_power/heat_capacity, 1000) // Added min() check to try and avoid wacky superheating issues in low gas scenarios -- TLE
						else
							removed.temperature = max(removed.temperature - heating_power/heat_capacity, TCMB)

					//world << "now at [removed.temperature]"

				env.merge(removed)

				//world << "turf now at [env.temperature]"

		// Checks heat from the environment and applies any integrity damage
		var/datum/gas_mixture/environment = loc.return_air()
		switch(environment.temperature)
			if(T0C to (T20C + 20))
				integrity = between(0, integrity, 100)
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