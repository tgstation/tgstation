/mob/living/simple_animal/mouse
	var/obj/structure/cable/FUCKING_KILL_THIS_CABLE = null
	var/chew_wires_untill = 0
	var/wire_view_range = 7
	var/chance_to_die_from_shock = 100
	var/wires_to_chew = 3

/mob/living/simple_animal/mouse/proc/check_wire_los(obj/structure/cable/C)
	if(!C)
		return 0
	if(!C.loc)
		return 0
	if(get_dist(loc,C) > wire_view_range)
		return 0
	if(C.z != z)
		return 0
	var/turf/current = get_turf(src)
	var/turf/targetturf = get_turf(C.loc)
	if(!istype(current) || !istype(targetturf))
		return 0
	var/timeout = wire_view_range
	while(timeout >= 0 && current != targetturf)
		timeout--
		var/turf/next = get_step_towards(current,targetturf)
		if(!next)
			return 0
		if(next.density)
			return 0
		for(var/obj/O in next)
			if(O.density)
				return 0
		current = next
	if(current == targetturf)
		return 1
	return 0

/mob/living/simple_animal/mouse/handle_automated_action()
	if(chew_wires_untill >= world.time || FUCKING_KILL_THIS_CABLE)
		seek_wire_to_chew()
	else if(chew_wires_untill > 0)
		chew_wires_untill = 0

/mob/living/simple_animal/mouse/proc/seek_wire_to_chew()
	if(!FUCKING_KILL_THIS_CABLE && wires_to_chew != 0)
		var/list/cables = list()
		var/list/supermatters = list()
		for(var/obj/machinery/power/supermatter_shard/shard in world)
			var/area/shardA = get_area(shard)
			if(shard)
				supermatters += shardA.type
		for(var/obj/structure/cable/C in range(wire_view_range,src))
			var/area/A = get_area(C)
			if(A.type in supermatters)
				continue
			if(!istype(C.loc,/turf/open/floor/plating))
				continue
			if(!check_wire_los(C))
				continue
			cables += C
		if(cables.len)
			FUCKING_KILL_THIS_CABLE = pick(cables)
	if(FUCKING_KILL_THIS_CABLE)
		if(!check_wire_los(FUCKING_KILL_THIS_CABLE))
			FUCKING_KILL_THIS_CABLE = null
		else
			if(get_dist(src,FUCKING_KILL_THIS_CABLE) > 0)
				step_towards(src,FUCKING_KILL_THIS_CABLE)
			else
				chew_wire()

/mob/living/simple_animal/mouse/proc/chew_wire()
	var/turf/open/floor/F = get_turf(src)
	if(istype(F) && !F.intact)
		var/obj/structure/cable/C = locate() in F
		if(C)
			var/shocked = C.avail()
			var/die = 0
			if(shocked)
				playsound(src, 'sound/effects/sparks2.ogg', 100, 1)
				if(prob(chance_to_die_from_shock))
					die = 1
			C.deconstruct()
			FUCKING_KILL_THIS_CABLE = null
			visible_message("<span class='warning'>[src] chews through the [C].[die ? " It's toast!" : ""]</span>")
			if(die)
				death(toast=1)
			if(wires_to_chew > 0)
				wires_to_chew--
				if(wires_to_chew == 0)
					wires_to_chew = initial(wires_to_chew)
					chew_wires_untill = initial(chew_wires_untill)
			return 1
	return 0

/mob/living/simple_animal/mouse/proc/wire_chewing_frenzie(duration = 600)
	chew_wires_untill = world.time+duration