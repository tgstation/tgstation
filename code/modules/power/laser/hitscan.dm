
#define PTL_HITSCAN_PASS 0
#define PTL_HITSCAN_PIERCE 1
#define PTL_HITSCAN_HIT 2
#define PTL_HITSCAN_TURN 3

#define PTL_FULLPIERCE_NONE 0
#define PTL_FULLPIERCE_NORMAL 1
#define PTL_FULLPIERCE_NOHIT 2

#define PTL_HITSCAN_RETURN_ERROR 0
#define PTL_HITSCAN_RETURN_HIT 1
#define PTL_HITSCAN_RETURN_ZEDGE 2

/obj/machinery/power/PTL/proc/hitscan_beamline(var/turf/starting, beam_dir, generate_effects = TRUE, effect_type = null, effect_duration = null, full_pierce = FALSE)
	var/list/affected = list()
	var/hit = FALSE
	var/iterations_left = 1000
	affected["[NORTH]"] = list()
	affected["[SOUTH]"] = list()
	affected["[EAST]"] = list()
	affected["[WEST]"] = list()
	affected["RESULT"] = PTL_HITSCAN_RETURN_ERROR
	affected["HIT_ATOM"] = null
	affected["BEAM_EFFECT_LIST"] = list()
	affected["[beam_dir]"] += starting
	var/turf/scanning
	scanning = starting
	while(!hit)
		iterations_left--
		var/reflector_hit = FALSE
		if(iterations_left <= 0)
			break
		for(var/atom/A in scanning)
			if(!full_pierce)
				var/V = hitscan_check(A)
				if(V == PTL_HITSCAN_PASS)
					continue
				else if(V == PTL_HITSCAN_PIERCE)
					affected["[beam_dir]"] += A
					continue
				else if(V == PTL_HITSCAN_HIT)
					hit = TRUE
					affected["HIT_ATOM"] = A
					affected["RESULT"] = PTL_HITSCAN_RETURN_HIT
					continue
				else if(V == PTL_HITSCAN_TURN)
					reflector_hit = TRUE
			else if(full_pierce = PTL_FULLPIERCE_NORMAL)	//Full pierce - Add everything but space to affected
				if(!isspaceturf(A))
					affected["[beam_dir]"] += A
		if(((scanning.x < 5) || (scanning.x > (world.maxx - 5))) || ((scanning.y < 5) || (scanning.y > (world.maxy - 5))))	//ZLEVEL EDGE CHECK
			hit = TRUE
			affected["RESULT"] = PTL_HITSCAN_RETURN_ZEDGE
			continue
		if(reflector_hit)
			var/obj/structure/reflector/found_R = null
			for(var/obj/structure/reflector/R in scanning)
				found_R = R
				break
			beam_dir = hitscan_reflect(found_R, beam_dir)
		scanning = get_step(scanning, beam_dir)
		if(!isnull(effect_type))
			affected["BEAM_EFFECT_LIST"] += hitscan_effect(scanning, effect_type, beam_dir, effect_duration)
		CHECK_TICK
	return affected

/obj/machinery/power/PTL/proc/hitscan_check(var/atom/A)	//1 for passes, 0 for hit.
	if(isclosedturf(A))			//Mechanics still WIP
		return PTL_HITSCAN_HIT
	else if(ismovableatom(A))
		if(istype(A, /obj/structure/reflector))
			var/obj/structure/reflector/R = A
			if(R.can_reflect_PTL)
				return PTL_HITSCAN_TURN
		return PTL_HITSCAN_PIERCE
	else
		return PTL_HITSCAN_PASS

/obj/machinery/power/PTL/proc/hitscan_reflect(obj/structure/reflector/R, beam_dir)
	return R.get_reflection(R.dir, beam_dir)

/obj/machinery/power/PTL/proc/hitscan_effect(location, type, effect_dir, effect_duration)
	var/obj/effect/overlay/temp/PTL/E = new type(location, effect_duration)
	if(!istype(E))
		return null
	E.dir = effect_dir
	return E
