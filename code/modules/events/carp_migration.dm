/datum/event/carp_migration
	announceWhen	= 50
	oneShot			= 1

/datum/event/carp_migration/setup()
	announceWhen = rand(40, 60)

/datum/event/carp_migration/announce()
	command_alert("Unknown biological entities have been detected near [station_name()], please stand-by.", "Lifesign Alert")


/datum/event/carp_migration/start()
	for(var/obj/effect/landmark/C in landmarks_list)
		if(C.name == "carpspawn")
			new /mob/living/simple_animal/hostile/carp(C.loc)