/obj/machinery/atmospherics/pipe
	var/datum/gas_mixture/air_temporary //used when reconstructing a pipeline that broke
	var/volume = 0

	level = 1

	use_power = 0
	can_unwrench = 1
	var/datum/pipeline/parent = null

	//Buckling
	can_buckle = 1
	buckle_requires_restraints = 1
	buckle_lying = -1

/obj/machinery/atmospherics/pipe/New()
	add_atom_colour(pipe_color, FIXED_COLOUR_PRIORITY)
	volume = 35 * device_type
	..()

/obj/machinery/atmospherics/pipe/nullifyNode(I)
	var/obj/machinery/atmospherics/oldN = NODE_I
	..()
	if(oldN)
		oldN.build_network()

/obj/machinery/atmospherics/pipe/update_icon() //overridden by manifolds
	if(NODE1&&NODE2)
		icon_state = "intact[invisibility ? "-f" : "" ]"
	else
		var/have_node1 = NODE1?1:0
		var/have_node2 = NODE2?1:0
		icon_state = "exposed[have_node1][have_node2][invisibility ? "-f" : "" ]"

/obj/machinery/atmospherics/pipe/atmosinit()
	var/turf/T = loc			// hide if turf is not intact
	hide(T.intact)
	..()

/obj/machinery/atmospherics/pipe/hide(i)
	if(level == 1 && isturf(loc))
		invisibility = i ? INVISIBILITY_MAXIMUM : 0
	update_icon()

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
	else
		return ..()

/obj/machinery/atmospherics/pipe/returnPipenet()
	return parent

/obj/machinery/atmospherics/pipe/setPipenet(datum/pipeline/P)
	parent = P

/obj/machinery/atmospherics/pipe/Destroy()
	releaseAirToTurf()
	qdel(air_temporary)
	air_temporary = null

	var/turf/T = loc
	for(var/obj/machinery/meter/meter in T)
		if(meter.target == src)
			var/obj/item/pipe_meter/PM = new (T)
			meter.transfer_fingerprints_to(PM)
			qdel(meter)
	. = ..()

	if(parent && !qdeleted(parent))
		qdel(parent)
	parent = null

/obj/machinery/atmospherics/pipe/proc/update_node_icon()
	for(DEVICE_TYPE_LOOP)
		if(NODE_I)
			var/obj/machinery/atmospherics/N = NODE_I
			N.update_icon()

/obj/machinery/atmospherics/pipe/returnPipenets()
	. = list(parent)

/obj/machinery/atmospherics/pipe/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == "melee" && damage_amount < 12)
		return 0
	. = ..()
