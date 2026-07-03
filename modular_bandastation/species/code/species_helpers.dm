/// Returns the species' evil laugh sound
/datum/species/proc/get_evil_laugh_sound(mob/living/carbon/human/user)
	return

/datum/species/human/get_evil_laugh_sound(mob/living/carbon/human/user)
	if(user.physique == FEMALE)
		return pick(HUMAN_EVIL_LAUGH_SOUNDS_FEMALE)
	return pick(HUMAN_EVIL_LAUGH_SOUNDS_MALE)

/datum/species/jelly/get_evil_laugh_sound(mob/living/carbon/human/user)
	if(user.physique == FEMALE)
		return pick(HUMAN_EVIL_LAUGH_SOUNDS_FEMALE)
	return pick(HUMAN_EVIL_LAUGH_SOUNDS_MALE)

/datum/species/pod/get_evil_laugh_sound(mob/living/carbon/human/user)
	if(user.physique == FEMALE)
		return pick(HUMAN_EVIL_LAUGH_SOUNDS_FEMALE)
	return pick(HUMAN_EVIL_LAUGH_SOUNDS_MALE)

/datum/species/skrell/get_evil_laugh_sound(mob/living/carbon/human/user)
	if(user.physique == FEMALE)
		return pick(HUMAN_EVIL_LAUGH_SOUNDS_FEMALE)
	return pick(HUMAN_EVIL_LAUGH_SOUNDS_MALE)

/datum/species/tajaran/get_evil_laugh_sound(mob/living/carbon/human/user)
	if(user.physique == FEMALE)
		return pick(HUMAN_EVIL_LAUGH_SOUNDS_FEMALE)
	return pick(HUMAN_EVIL_LAUGH_SOUNDS_MALE)

/datum/species/vulpkanin/get_evil_laugh_sound(mob/living/carbon/human/user)
	if(user.physique == FEMALE)
		return pick(HUMAN_EVIL_LAUGH_SOUNDS_FEMALE)
	return pick(HUMAN_EVIL_LAUGH_SOUNDS_MALE)

/datum/species/lizard/get_evil_laugh_sound(mob/living/carbon/human/user)
	return 'sound/mobs/humanoids/lizard/lizard_laugh1.ogg'

/datum/species/moth/get_evil_laugh_sound(mob/living/carbon/human/user)
	return 'sound/mobs/humanoids/moth/moth_laugh1.ogg'
