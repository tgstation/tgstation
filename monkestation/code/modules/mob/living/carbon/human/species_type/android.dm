/datum/species/android/get_scream_sound(mob/living/carbon/human/human)
	return 'monkestation/sound/voice/screams/silicon/scream_silicon.ogg'

/datum/species/android/get_laugh_sound(mob/living/carbon/human/human)
	return pick(
		'monkestation/sound/voice/laugh/silicon/laugh_siliconE1M0.ogg',
		'monkestation/sound/voice/laugh/silicon/laugh_siliconE1M1.ogg',
		'monkestation/sound/voice/laugh/silicon/laugh_siliconM2.ogg',
	)
