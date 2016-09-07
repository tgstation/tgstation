/datum/round_event_control/dolphin_migration
	name = "Dolphin Migration"
	typepath = /datum/round_event/dolphin_migration
	weight = 8
	min_players = 2
	earliest_start = 6000
	max_occurrences = 6

/datum/round_event/dolphin_migration
	announceWhen	= 3
	startWhen = 50

/datum/round_event/dolphin_migration/setup()
	startWhen = rand(40, 60)

/datum/round_event/dolphin_migration/announce()
	priority_announce("Unknown biological entities have been detected near [station_name()], please stand-by.", "Lifesign Alert")


/datum/round_event/dolphin_migration/start()
	for(var/obj/effect/landmark/C in landmarks_list)
		if(C.name == "carpspawn")
			new /mob/living/simple_animal/hostile/retaliate/dolphin(C.loc)