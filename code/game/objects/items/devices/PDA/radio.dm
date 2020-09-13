// Radio Cartridge, essentially a remote signaler with limited spectrum.
/obj/item/integrated_signaler
	name = "\improper PDA radio module"
	desc = "An electronic radio system of Nanotrasen origin."
	icon = 'icons/obj/module.dmi'
	icon_state = "power_mod"

/obj/item/integrated_signaler
	var/frequency = FREQ_SIGNALER
	var/code = DEFAULT_SIGNALER_CODE
	var/last_transmission
	var/datum/radio_frequency/radio_connection

/obj/item/integrated_signaler/Destroy()
	radio_connection = null
	return ..()

/obj/item/integrated_signaler/ComponentInitialize()
	. = ..()
	if (frequency < MIN_FREE_FREQ || frequency > MAX_FREE_FREQ)
		frequency = sanitize_frequency(frequency)
	AddComponent(/datum/component/radio_interface, frequency)

/obj/item/integrated_signaler/proc/set_frequency(new_frequency)
	SEND_SIGNAL(src, COMSIG_RADIO_NEW_FREQUENCY, new_frequency)

/obj/item/integrated_signaler/proc/send_activation()
	if(last_transmission && world.time < (last_transmission + 5))
		return
	last_transmission = world.time

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(src)
	GLOB.lastsignalers.Add("[time] <B>:</B> [usr.key] used [src] @ location [AREACOORD(T)] <B>:</B> [format_frequency(frequency)]/[code]")

	var/datum/signal/signal = new(list("code" = code))
	var/datum/component/radio_interface/radio_connection = GetComponent(/datum/component/radio_interface)
	radio_connection.brodcast(signal,  RADIO_SIGNALER)
