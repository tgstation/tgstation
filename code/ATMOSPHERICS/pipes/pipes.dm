/obj/machinery/atmospherics/pipe
	var/datum/gas_mixture/air_temporary //used when reconstructing a pipeline that broke
	var/volume = 0
	layer = 2.4 //under wires with their 2.44
	use_power = 0
	can_unwrench = 1
	var/alert_pressure = 80*ONE_ATMOSPHERE
		//minimum pressure before check_pressure(...) should be called

	//Buckling
	can_buckle = 1
	buckle_requires_restraints = 1
	buckle_lying = -1

/obj/machinery/atmospherics/proc/pipeline_expansion()
	return null

/obj/machinery/atmospherics/pipe/proc/check_pressure(pressure)
	//Return 1 if parent should continue checking other pipes
	//Return null if parent should stop checking other pipes. Recall: del(src) will by default return null
	return 1

/obj/machinery/atmospherics/pipe/proc/releaseAirToTurf()
	if(air_temporary)
		var/turf/T = loc
		T.assume_air(air_temporary)
		air_update_turf()

/obj/machinery/atmospherics/pipe/return_air()
	return parent.air

/obj/machinery/atmospherics/pipe/build_network()
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)

/obj/machinery/atmospherics/pipe/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/device/analyzer))
		atmosanalyzer_scan(parent.air, user)
		return

	if(istype(W,/obj/item/device/pipe_painter) || istype(W,/obj/item/weapon/pipe_dispenser))
		return

	return ..()

/obj/machinery/atmospherics/pipe/setPipenet(datum/pipeline/P)
	parent = P

/obj/machinery/atmospherics/pipe/Destroy()
	var/turf/T = loc
	for(var/obj/machinery/meter/meter in T)
		if(meter.target == src)
			var/obj/item/pipe_meter/PM = new (T)
			meter.transfer_fingerprints_to(PM)
			qdel(meter)
	..()

/obj/machinery/atmospherics/pipe/proc/update_node_icon()
	//Used for pipe painting. Overriden in the children.
	return
