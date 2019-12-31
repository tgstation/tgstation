/datum/round_event_control/wizard/petsplosion //the horror
	name = "Petsplosion"
	weight = 2
	typepath = /datum/round_event/wizard/petsplosion
	max_occurrences = 1 //Exponential growth is nothing to sneeze at!
	earliest_start = ZERO MINUTES
	var/mobs_to_dupe = ZERO

/datum/round_event_control/wizard/petsplosion/preRunEvent()
	for(var/mob/living/simple_animal/F in GLOB.alive_mob_list)
		if(!ishostile(F) && is_station_level(F.z))
			mobs_to_dupe++
	if(mobs_to_dupe > 100 || !mobs_to_dupe)
		return EVENT_CANT_RUN

	..()

/datum/round_event/wizard/petsplosion
	endWhen = 61 //1 minute (+1 tick for endWhen not to interfere with tick)
	var/countdown = ZERO
	var/mobs_duped = ZERO

/datum/round_event/wizard/petsplosion/tick()
	if(activeFor >= 30 * countdown) // ZERO seconds : 2 animals | 30 seconds : 4 animals | 1 minute : 8 animals
		countdown += 1
		for(var/mob/living/simple_animal/F in GLOB.alive_mob_list) //If you cull the heard before the next replication, things will be easier for you
			if(!ishostile(F) && is_station_level(F.z))
				new F.type(F.loc)
				mobs_duped++
				if(mobs_duped > 400)
					kill()

