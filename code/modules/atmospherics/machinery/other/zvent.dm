
/*
	Remie note:
	I added proper multiZ, but this thing is ancient
	I "updated" it, and it DOES work, but it's
	not in RPDs, pipe dispensers etc and some of its
	content (on/off, volume_rate) aren't implemented.

	Use this for ruins and stuff I guess, or fix it up proper.
*/


/obj/machinery/zvent
	name = "interfloor air transfer system"

	icon = 'icons/obj/atmospherics/components/unary_devices.dmi'
	icon_state = "vent_map"
	density = 0
	anchored=1

	var/on = 0
	var/volume_rate = 800

/obj/machinery/zvent/New()
	..()
	SSair.atmos_machinery += src

/obj/machinery/zvent/Destroy()
	SSair.atmos_machinery -= src
	return ..()

/obj/machinery/zvent/process_atmos()

	//all this object does, is make its turf share air with the ones above and below it, if they have a vent too.
	if(isturf(loc)) //if we're not on a valid turf, forget it
		var/turf/T = loc
		for (var/ddir in list(DOWN,UP))  //change this list if a fancier system of z-levels gets implemented //meow
			var/turf/open/zturf_conn = get_step(loc, ddir)
			if (istype(zturf_conn))
				if(!AreZsConnected(zturf_conn.z, T.z))
					continue

				var/obj/machinery/zvent/zvent_conn= locate(/obj/machinery/zvent) in zturf_conn
				if (istype(zvent_conn))
					//both floors have simulated turfs, share()
					var/turf/open/myturf = loc
					var/datum/gas_mixture/conn_air = zturf_conn.air //TODO: pop culture reference
					var/datum/gas_mixture/my_air = myturf.air
					if (istype(conn_air) && istype(my_air))
						my_air.share(conn_air)
						air_update_turf()
