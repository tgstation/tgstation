/datum/emote/living/carbon/human/scream
	only_forced_audio = FALSE

/datum/emote/living/carbon/human/scream/get_sound(mob/living/carbon/human/user)
	if(!istype(user) || !user.can_speak())
		return

	return user.dna.species.get_scream_sound(user)
