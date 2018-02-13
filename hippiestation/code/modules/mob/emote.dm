/datum/emote/flip/run_emote(mob/user, params)
	. = ..()

	if (.)
		if (istype(user, /mob/living/carbon))
			var/mob/living/carbon/C = user
			C.throw_hats(1 + rand(1, 3), GLOB.alldirs)

/datum/emote/spin/run_emote(mob/user)
	. = ..()

	if (.)
		if (istype(user, /mob/living/carbon))
			var/mob/living/carbon/C = user
			C.throw_hats(1 + rand(1, 3), GLOB.alldirs)