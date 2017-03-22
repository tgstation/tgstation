
#define PTL_HITSCAN_PASS 0
#define PTL_HITSCAN_PIERCE 1
#define PTL_HITSCAN_HIT 2

#define PTL_HITSCAN_RETURN_ERROR 0
#define PTL_HITSCAN_RETURN_HIT 1
#define PTL_HITSCAN_RETURN_ZEDGE 2

/obj/machinery/power/PTL/proc/hitscan_beamline(var/turf/starting, beam_dir)
	var/list/affected = list()
	var/hit = FALSE
	var/iterations_left = 500
	affected += "[NORTH]"
	affected += "[SOUTH]"
	affected += "[EAST]"
	affected += "[WEST]"
	affected["RESULT"] = PTL_HITSCAN_RETURN_ERROR
	affected["HIT_ATOM"] = null
	affected[beam_dir] += starting
	var/turf/scanning
	scanning = starting
	while(!hit)
		iterations_left--
		if(iterations_left <= 0)
			break
		for(var/atom/A in scanning)
			if(hitscan_check(A) == PTL_HITSCAN_PASS)
				continue
			else if(hitscan_check(A) == PTL_HITSCAN_PIERCE)
				affected[beam_dir] += A
				continue
			else if(hitscan_check(A) == PTL_HITSCAN_HIT)
				hit = TRUE
				hit_atom = A
				affected["HIT_ATOM"] = A
				affected["RESULT"] = PTL_HITSCAN_RETURN_HIT
				continue
		if(((scanning.x < 5) || (scanning.x > (world.maxx - 5))) || ((scanning.y < 5) || (scanning.y > (world.maxy - 5))))	//ZLEVEL EDGE CHECK
			hit = TRUE
			affected["RESULT"] = PTL_HITSCAN_RETURN_ZEDGE
			continue


		//Insert check for zlevel edges here
		//Insert check for reflectors here
		scanning = get_step(scanning, beam_dir)
		CHECK_TICK

/obj/machinery/power/PTL/proc/hitscan_check(var/atom/A)	//1 for passes, 0 for hit.
	if(isclosedturf(A))			//Mechanics still WIP
		return PTL_HITSCAN_HIT
	if(ismovableatom(A))
		return PTL_HITSCAN_PIERCE
	return PTL_HITSCAN_PASS
