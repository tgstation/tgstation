/datum/round_event_control/carp_migration
	name = "Carp Migration"
	typepath = /datum/round_event/carp_migration
	average_time = 30 //Moderate challenge that sometimes kills a person or two.
	max_occurrences = 6

/datum/round_event/carp_migration
	announceWhen	= 3
	startWhen = 50

/datum/round_event/carp_migration/setup()
	startWhen = rand(40, 60)

/datum/round_event/carp_migration/announce()
	priority_announce("Unknown biological entities have been detected near [station_name()], please stand-by.", "Lifesign Alert")


/datum/round_event/carp_migration/start()
	for(var/obj/effect/landmark/C in landmarks_list)
		if(C.name == "carpspawn")
			if(prob(95))
				new /mob/living/simple_animal/hostile/carp(C.loc)
			else
				new /mob/living/simple_animal/hostile/carp/megacarp(C.loc)


