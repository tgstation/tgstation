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
		for (var/new_z in list(-1,1))  //change this list if a fancier system of z-levels gets implemented
			var/turf/open/zturf_conn = locate(x,y,z+new_z)
			if (istype(zturf_conn))
				var/obj/machinery/zvent/zvent_conn= locate(/obj/machinery/zvent) in zturf_conn
				if (istype(zvent_conn))
					//both floors have simulated turfs, share()
					var/turf/open/myturf = loc
					var/datum/gas_mixture/conn_air = zturf_conn.air //TODO: pop culture reference
					var/datum/gas_mixture/my_air = myturf.air
					if (istype(conn_air) && istype(my_air))
						my_air.share(conn_air)
						air_update_turf()
