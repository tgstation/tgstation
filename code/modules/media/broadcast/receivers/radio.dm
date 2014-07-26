/obj/machinery/media/receiver/boombox
	name = "Boombox"
	desc = "Tune in and tune out."

	icon='icons/obj/radio.dmi'
	icon_state="radio"

	var/on=0
/obj/machinery/media/receiver/boombox/interact(var/mob/user)
	if(!on)
		return

	var/dat = "<html><head><title>[src]</title></head><body><TT>"
	dat += {"
				Power: <a href="?src=\ref[src];power=[!on]">[on ? "On" : "Off"]</a><BR>
				Frequency: <A href='byond://?src=\ref[src];set_freq=-1'>[format_frequency(media_frequency)]</a><BR>
				"}
	dat+={"</TT></body></html>"}
	user << browse(dat, "window=radio-recv")
	onclose(user, "radio-recv")
	return
/obj/machinery/media/receiver/boombox/Topic(href,href_list)
	..()
	if("power" in href_list)
		on = !on
		if(on)
			visible_message("\The [src] hisses to life!")
			connect_frequency()
		else
			visible_message("\The [src] falls quiet.")
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
