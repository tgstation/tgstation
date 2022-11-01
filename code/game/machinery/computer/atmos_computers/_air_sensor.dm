/// Gas tank air sensor.
/// These always hook to monitors, be mindful of them
/obj/machinery/air_sensor
	name = "gas sensor"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor1"
	resistance_flags = FIRE_PROOF

	var/on = TRUE

	var/frequency = FREQ_ATMOS_STORAGE
	var/datum/radio_frequency/radio_connection

	/// The unique string that represents which atmos chamber to associate with.
	var/chamber_id

/obj/machinery/air_sensor/Initialize(mapload)
	id_tag = chamber_id + "_sensor"
	SSair.start_processing_machine(src)
	radio_connection = SSradio.add_object(src, frequency, RADIO_ATMOSIA)
	return ..()

/obj/machinery/air_sensor/Destroy()
	INVOKE_ASYNC(src, PROC_REF(broadcast_destruction), src.frequency)
	SSair.stop_processing_machine(src)
	SSradio.remove_object(src, frequency)
	return ..()

/obj/machinery/air_sensor/proc/broadcast_destruction(frequency)
	var/datum/signal/signal = new(list(
		"sigtype" = "destroyed",
		"tag" = id_tag,
		"timestamp" = world.time,
	))
	var/datum/radio_frequency/connection = SSradio.return_frequency(frequency)
	connection.post_signal(null, signal, filter = RADIO_ATMOSIA)

/obj/machinery/air_sensor/update_icon_state()
	icon_state = "gsensor[on]"
	return ..()

/obj/machinery/air_sensor/process_atmos()
	if(!on)
		return

	var/datum/gas_mixture/air_sample = return_air()
	var/datum/signal/signal = new(list(
		"sigtype" = "status",
		"tag" = id_tag,
		"timestamp" = world.time,
		"gasmix" = gas_mixture_parser(air_sample),
	))
	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)
