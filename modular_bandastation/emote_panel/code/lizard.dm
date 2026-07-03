/datum/species/lizard/get_cry_sound(mob/living/carbon/human/lizard)
	if(lizard.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cry/female_cry1.ogg',
			'sound/mobs/humanoids/human/cry/female_cry2.ogg',
			'modular_bandastation/emote_panel/audio/human/female/cry_female_1.ogg',
			'modular_bandastation/emote_panel/audio/human/female/cry_female_2.ogg',
			'modular_bandastation/emote_panel/audio/human/female/cry_female_3.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cry/male_cry1.ogg',
		'sound/mobs/humanoids/human/cry/male_cry2.ogg',
		'sound/mobs/humanoids/human/cry/male_cry3.ogg',
		'modular_bandastation/emote_panel/audio/human/male/cry_male_1.ogg',
		'modular_bandastation/emote_panel/audio/human/male/cry_male_2.ogg',
	)
