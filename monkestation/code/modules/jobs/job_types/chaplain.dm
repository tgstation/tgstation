/datum/job/chaplain/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	if(spawned.mind)
		ADD_TRAIT(spawned.mind, TRAIT_BLOODSUCKER_HUNTER, JOB_TRAIT)
