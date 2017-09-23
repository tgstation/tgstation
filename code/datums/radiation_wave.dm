/datum/radiation_wave
	var/turf/master_turf //The center of the wave
	var/steps=0 //How far we've moved
	var/intensity //How strong it was originaly
	var/range_modifier //Higher than 1 makes it drop off faster, 0.5 makes it drop off half etc
	var/list/move_dir //The direction of movement
	var/list/__dirs //The directions to the side of the wave, stored for easy looping

/datum/radiation_wave/New(turf/place, dir, strength=0, range_mod)
	master_turf = place

	move_dir = dir
	__dirs+=turn(dir, 90)
	__dirs+=turn(dir, -90)

	intensity = strength

	range_modifier = range_mod

	START_PROCESSING(SSradiation, src)

/datum/radiation_wave/process()
	master_turf = get_step(master_turf, move_dir)
	steps++
	var/list/turfs = get_rad_turfs()
	check_obstructions(turfs)
	var/strength = InverseSquareLaw(intensity, (range_modifier*(steps-1))+1, 1) //The full rad amount always applies on the first step
	if(strength<0.1)
		STOP_PROCESSING(SSradiation, src)
		qdel(src)
	radiate(turfs, Floor(strength))

	return TRUE

/datum/radiation_wave/proc/get_rad_turfs()
	var/list/turfs = list()
	var/distance = steps

	if(move_dir == NORTH || move_dir == SOUTH)
		distance-- //otherwise corners overlap

	turfs += master_turf

	if(!distance)
		return turfs

	var/turf/place
	for(var/dir in __dirs) //There should be just 2 dirs in here, left and right of the direction of movement
		place = master_turf
		for(var/i in 1 to distance)
			place = get_step(place, dir)
			turfs += place

	return turfs

/datum/radiation_wave/proc/check_obstructions(list/turfs)
	for(var/i in 1 to turfs.len)
		var/turf/place = turfs[i]
		if(!place)
			continue
		var/datum/component/rad_insulation/insulation = place.GetComponent(/datum/component/rad_insulation)
		if(insulation)
			intensity *= insulation.amount

		var/list/things = place.GetAllContents()
		for(var/k in 1 to things.len)
			var/atom/thing = things[k]
			if(!thing)
				continue
			insulation = thing.GetComponent(/datum/component/rad_insulation)
			if(!insulation)
				continue
			intensity *= insulation.amount

/datum/radiation_wave/proc/radiate(list/turfs, strength)
	var/contamination_strength = strength-RAD_MINIMUM_CONTAMINATION

	for(var/i in 1 to turfs.len)
		var/turf/place = turfs[i]
		if(!place)
			continue

		var/list/things = place.GetAllContents()
		for(var/k in 1 to things.len)
			var/atom/thing = things[k]
			if(!thing)
				continue
			thing.rad_act(strength, TRUE)
			if(prob(Clamp(contamination_strength/500,0,1))) // Only stronk rads get to have little baby rads
				var/datum/component/rad_insulation/insulation = thing.GetComponent(/datum/component/rad_insulation)
				if(insulation)
					continue
				else
					thing.AddComponent(/datum/component/radioactive, log(contamination_strength)**5.5) //This should be balanced somewhere between 5 and 6
				// Unless you're the stronkest of the stronk, in which case you get grandkids (>300 strength) or great great grandkids (>762)