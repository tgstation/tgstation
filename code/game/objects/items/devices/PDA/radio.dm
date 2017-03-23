/obj/item/radio/integrated
	name = "\improper PDA radio module"
	desc = "An electronic radio system of nanotrasen origin."
	icon = 'icons/obj/module.dmi'
	icon_state = "power_mod"
	var/obj/item/device/pda/hostpda = null

	var/on = 0 //Are we currently active??
	var/menu_message = ""

/obj/item/radio/integrated/New()
	..()
	if (istype(loc.loc, /obj/item/device/pda))
		hostpda = loc.loc

/obj/item/radio/integrated/Destroy()
	hostpda = null
	return ..()

/*
 *	Radio Cartridge, essentially a signaler.
 */


/obj/item/radio/integrated/signal
	var/frequency = 1457
	var/code = 30
	var/last_transmission
	var/datum/radio_frequency/radio_connection

/obj/item/radio/integrated/signal/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/item/radio/integrated/signal/Initialize()
	..()
	if (src.frequency < 1200 || src.frequency > 1600)
		src.frequency = sanitize_frequency(src.frequency)

	set_frequency(frequency)

/obj/item/radio/integrated/signal/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency)

/obj/item/radio/integrated/signal/proc/send_signal(message="ACTIVATE")

	if(last_transmission && world.time < (last_transmission + 5))
		return
	last_transmission = world.time

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(src)
	lastsignalers.Add("[time] <B>:</B> [usr.key] used [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(frequency)]/[code]")

	var/datum/signal/signal = new
	signal.source = src
	signal.encryption = code
	signal.data["message"] = message

	radio_connection.post_signal(src, signal)

	return