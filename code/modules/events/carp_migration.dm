/datum/round_event_control/carp_migration
	name = "Carp Migration"
	typepath = /datum/round_event/carp_migration
	weight = 15
	earliest_start = 6000
	max_occurrences = 6

/datum/round_event/carp_migration
	announceWhen	= 50

/datum/round_event/carp_migration/setup()
	announceWhen = rand(40, 60)

/datum/round_event/carp_migration/announce()
	command_alert("Unknown biological entities have been detected near [station_name()], please stand-by.", "Lifesign Alert")


/datum/round_event/carp_migration/start()
	for(var/obj/effect/landmark/C in landmarks_list)
		if(C.name == "carpspawn")
			new /mob/living/simple_animal/hostile/carp(C.loc)