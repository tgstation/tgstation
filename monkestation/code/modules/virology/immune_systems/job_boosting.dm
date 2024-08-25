/datum/job
	/// If set, players spawning with this job will start with a boosted immune system.
	var/boost_immune_system

/datum/job/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	if(!isnull(boost_immune_system))
		if(QDELETED(spawned.immune_system))
			spawned.immune_system = new(spawned, boost_immune_system)
		else
			spawned.immune_system.change_boost(boost_immune_system)

/datum/job/chief_medical_officer
	boost_immune_system = 1.7

/datum/job/doctor
	boost_immune_system = 1.4

/datum/job/paramedic
	boost_immune_system = 1.4

/datum/job/virologist
	boost_immune_system = 1.8

/datum/job/janitor
	boost_immune_system = 2
