/datum/artifact_fault/monkey_mode
	name = "Simian Spawner Fault"
	trigger_chance = 3
	visible_message = "summons a mass of simians!"

/datum/artifact_fault/monkey_mode/on_trigger(datum/component/artifact/component)
	var/monkey = rand(1,4)
	var/center_turf = get_turf(component.parent)
	var/list/turf/valid_turfs = list()
	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")
	for(var/turf/boi in range(rand(3,6),center_turf))
		if(boi.density)
			continue
		valid_turfs += boi
	for(var/i in 1 to monkey)
		var/turf/spawnon = pick(valid_turfs)
		valid_turfs -= spawnon
		var/pain = roll(1,100)
		var/mob/living/M //For monkey
		switch(pain)
			if(1 to 75)
				M = new /mob/living/carbon/human/species/monkey/angry(spawnon)
			if(75 to 95)
				M = new /mob/living/basic/gorilla(spawnon)
			if(95 to 100)
				M = new /mob/living/basic/gorilla/lesser(spawnon)//OH GOD ITS TINY
		if(M) //Just in case.
			M.forceMove(spawnon)

