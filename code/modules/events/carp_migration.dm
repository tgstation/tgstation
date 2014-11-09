/datum/event/carp_migration
	announceWhen	= 20
	endWhen = 450
	var/list/spawned_carp = list()

/datum/event/carp_migration/setup()
	announceWhen = rand(15, 30)
	endWhen = rand(600,1200)

/datum/event/carp_migration/announce()
	command_alert("Unknown biological entities have been detected near [station_name()], please stand-by.", "Lifesign Alert")

/datum/event/carp_migration/start()
	for(var/obj/effect/landmark/C in landmarks_list)
		if(C.name == "carpspawn")
			if(prob(90)) //Give it a sliver of randomness
				spawned_carp.Add(new /mob/living/simple_animal/hostile/carp(C.loc))

/datum/event/carp_migration/end()
	for(var/mob/living/simple_animal/hostile/carp/C in spawned_carp)
		if(!C.stat)
			var/turf/T = get_turf(C)
			if(istype(T, /turf/space))
				del(C)
