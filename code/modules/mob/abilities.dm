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
		to_chat(src, "<span class='warning'>You must be corporeal and alive to do that.</span>")
		return 0

	//Handcuff check.
	if(mob.restrained())
		to_chat(src, "<span class='warning'>You cannot do this while restrained.</span>")
		return 0

	if(istype(mob,/mob/living/carbon))
		var/mob/living/carbon/M = mob
		if(M.handcuffed)
			to_chat(src, "<span class='warning'>You cannot do this while cuffed.</span>")
			return 0

	to_chat(src, "<span class='notice'>You perform an ability.</span>")

*/