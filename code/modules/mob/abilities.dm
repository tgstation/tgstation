/*
Creature-level abilities.
*/

/var/global/list/ability_verbs = list(	)

/*

 Example ability:

/client/proc/test_ability()

	set category = "Ability"
	set name = "Test ability"
	set desc = "An ability for testing."

	// Check if the client has a mob and if the mob is valid and alive.
	if(!mob || !istype(mob,/mob/living) || mob.stat)
		src << "\red You must be corporeal and alive to do that."
		return 0

	//Handcuff check.
	if(mob.restrained())
		src << "\red You cannot do this while restrained."
		return 0

	if(istype(mob,/mob/living/carbon))
		var/mob/living/carbon/M = mob
		if(M.handcuffed)
			src << "\red You cannot do this while cuffed."
			return 0

	src << "\blue You perform an ability."

*/