/obj/machinery/media/transmitter/broadcast
	name = "FM Transmitter"
	desc = "A huge hulk of steel containing high-powered phase-modulating radio transmitting equipment."

	var/on=0
	var/obj/machinery/media/source=null

/obj/machinery/media/transmitter/broadcast/proc/hook_media_source()
	if(!source) return
	// Hook into output
	if(!source.hookMediaOutput(src,exclusive=1))
		return
	source.update_music() // Request music update

/obj/machinery/media/transmitter/broadcast/proc/unhook_media_source()
	if(!source) return
	// Hook into output
	if(!source.unhookMediaOutput(src))
		return
	broadcast() // Bzzt

/obj/machinery/media/transmitter/broadcast/Topic(href,href_list)
	..()
	if("power" in href_list)
		on = !on
		if(on)
			visible_message("\The [src] hums as it begins pumping energy into the air!")
			connect_frequency()
			hook_media_source()
		else
			visible_message("\The [src] falls quiet and makes a soft ticking noise as it cools down.")
			unhook_media_source()
			disconnect_frequency()
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




/obj/machinery/media/transmitter/broadcast/linkWith(var/mob/user, var/obj/O, var/list/context)
	if(istype(O,/obj/machinery/media) && !is_type_in_list(O,list(/obj/machinery/media/transmitter)))
		if(source)
			unhook_media_source()
		source=O
		hook_media_source()

/obj/machinery/media/transmitter/broadcast/unlinkFrom(var/mob/user, var/obj/O)
	if(source==O)
		unhook_media_source()
		source=null
	return 0

/obj/machinery/media/transmitter/broadcast/canLink(var/obj/O, var/list/context)
	return istype(O,/obj/machinery/media) && !is_type_in_list(O,list(/obj/machinery/media/transmitter))

/obj/machinery/media/transmitter/broadcast/isLinkedWith(var/obj/O)
	return O==source