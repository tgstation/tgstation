/obj/machinery/media/receiver/boombox
	name = "Boombox"
	desc = "Tune in and tune out."

	icon='icons/obj/radio.dmi'
	icon_state="radio"

	var/on=0

/obj/machinery/media/receiver/boombox/initialize()
	if(on)
		update_on()
	update_icon()

/obj/machinery/media/receiver/boombox/attack_hand(var/mob/user)
	if(stat & (NOPOWER|BROKEN))
		usr << "\red You don't see anything to mess with."
		return
	user.set_machine(src)
	interact(user)

/obj/machinery/media/receiver/boombox/interact(var/mob/user)
	var/dat = "<html><head><title>[src]</title></head><body><TT>"
	dat += {"
				Power: <a href="?src=\ref[src];power=1">[on ? "On" : "Off"]</a><BR>
				Frequency: <A href='byond://?src=\ref[src];set_freq=-1'>[format_frequency(media_frequency)]</a><BR>
				Volume: <A href='byond://?src=\ref[src];set_volume=-1'>[volume*100]%</a><BR>
				"}
	dat+={"</TT></body></html>"}
	user << browse(dat, "window=radio-recv")
	onclose(user, "radio-recv")
	return

/obj/machinery/media/receiver/boombox/proc/update_on()
	if(on)
		visible_message("\The [src] hisses to life!")
		playing=1
		connect_frequency()
	else
		visible_message("\The [src] falls quiet.")
		playing=0
		disconnect_frequency()

/obj/machinery/media/receiver/boombox/Topic(href,href_list)
	if(isobserver(usr) && !isAdminGhost(usr))
		usr << "\red You can't push buttons when your fingers go right through them, dummy."
		return
	..()
	if("power" in href_list)
		on = !on
		update_on()
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
	if("set_volume" in href_list)
		var/vol=volume
		if(href_list["set_volume"]!="-1")
			vol = text2num(href_list["set_volume"])/100
		else
			vol = input(usr, "Set a new volume (1-100%).", src, volume*100) as null|num
			if(vol==null)
				updateUsrDialog()
				return
			vol /= 100
		if(vol)
			volume = vol
			update_music()
		else
			usr << "\red Invalid volume."
	updateDialog()


/obj/machinery/media/receiver/boombox/wallmount
	name = "Sound System"
	desc = "This plays music for this room."

	icon='icons/obj/radio.dmi'
	icon_state="wallradio"
	anchored=1
	volume=0.25 // 25% of user's set volume.

/obj/machinery/media/receiver/boombox/wallmount/update_on()
	..()
	if(on)
		icon_state="wallradio-p"
	else
		icon_state="wallradio"

/obj/machinery/media/receiver/boombox/wallmount/shuttle
	on=1
	media_frequency=953
	volume=1

/obj/machinery/media/receiver/boombox/wallmount/muzak
	on=1
	media_frequency=1015