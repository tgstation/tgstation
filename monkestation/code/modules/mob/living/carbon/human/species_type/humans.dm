/datum/species/human/get_laugh_sound(mob/living/carbon/human/human)
	if(human.gender == MALE)
		return pick('sound/voice/human/manlaugh1.ogg', 'sound/voice/human/manlaugh2.ogg')
	else
		return 'sound/voice/human/womanlaugh.ogg'
