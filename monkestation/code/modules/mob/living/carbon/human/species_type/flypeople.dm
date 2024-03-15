/datum/species/fly
	payday_modifier = 1

/datum/species/fly/get_scream_sound(mob/living/carbon/human/human)
	if(human.gender == MALE)
		if(prob(1))
			return 'sound/voice/human/wilhelm_scream.ogg'
		return pick(
			'sound/voice/human/malescream_1.ogg',
			'sound/voice/human/malescream_2.ogg',
			'sound/voice/human/malescream_3.ogg',
			'sound/voice/human/malescream_4.ogg',
			'sound/voice/human/malescream_5.ogg',
			'sound/voice/human/malescream_6.ogg',
		)

	return pick(
		'sound/voice/human/femalescream_1.ogg',
		'sound/voice/human/femalescream_2.ogg',
		'sound/voice/human/femalescream_3.ogg',
		'sound/voice/human/femalescream_4.ogg',
		'sound/voice/human/femalescream_5.ogg',
	)
/datum/species/fly/get_laugh_sound(mob/living/carbon/human/human)
	if(human.gender == MALE)
		return pick('sound/voice/human/manlaugh1.ogg', 'sound/voice/human/manlaugh2.ogg')
	else
		return 'sound/voice/human/womanlaugh.ogg'

