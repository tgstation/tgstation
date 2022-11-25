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
	radio_connection = SSradio.add_object(src, frequency, RADIO_ATMOSIA)
	var/list/static/loc_connections = list(
		COMSIG_TURF_EXPOSE = PROC_REF(on_gasmix_change),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	if(!SSair.initialized)
		RegisterSignal(SSair, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(air_setup))
	else if(!mapload) // how does this work with stuff loaded through like the whatisit startreck magic room thing
		scan_air()

	return ..()

/obj/machinery/air_sensor/Destroy()
	INVOKE_ASYNC(src, PROC_REF(broadcast_destruction), src.frequency)
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

/obj/machinery/air_sensor/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	scan_air()

/obj/machinery/air_sensor/proc/air_setup()
	SIGNAL_HANDLER
	scan_air()
	UnregisterSignal(SSair, COMSIG_SUBSYSTEM_POST_INITIALIZE)

/obj/machinery/air_sensor/proc/scan_air()
	var/datum/gas_mixture/our_gas = return_air()
	if(!our_gas)
		return
	on_gasmix_change(null, our_gas, our_gas.temperature)

/obj/machinery/air_sensor/proc/on_gasmix_change(datum/source, datum/gas_mixture/air, exposed_temperature)
	SIGNAL_HANDLER
	if(!on)
		return

	var/datum/signal/signal = new(list(
		"sigtype" = "status",
		"tag" = id_tag,
		"timestamp" = world.time,
		"gasmix" = gas_mixture_parser(air),
	))
	INVOKE_ASYNC(radio_connection, TYPE_PROC_REF(/datum/radio_frequency, post_signal), src, signal, RADIO_ATMOSIA)
