/// Gas tank air sensor.
/// These always hook to monitors, be mindful of them
/obj/machinery/air_sensor
	name = "gas sensor"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor1"
	resistance_flags = FIRE_PROOF

	var/on = TRUE

	/// The unique string that represents which atmos chamber to associate with.
	var/chamber_id

/obj/machinery/air_sensor/Initialize(mapload)
	id_tag = chamber_id + "_sensor"
	return ..()

/obj/machinery/air_sensor/update_icon_state()
	icon_state = "gsensor[on]"
	return ..()
