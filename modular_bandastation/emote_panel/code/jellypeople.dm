/datum/species/jelly/get_scream_sound(mob/living/carbon/human/jellypeople)
	if(jellypeople.physique == FEMALE)
		return 'modular_bandastation/emote_panel/audio/slime/jelly_scream.ogg'
	return 'modular_bandastation/emote_panel/audio/slime/jelly_scream.ogg'

/datum/species/jelly/get_cough_sound(mob/living/carbon/human/jellypeople)
	if(jellypeople.physique == FEMALE)
		return 'modular_bandastation/emote_panel/audio/slime/jelly_squish.ogg'
	return 'modular_bandastation/emote_panel/audio/slime/jelly_squish.ogg'

/datum/species/jelly/get_cry_sound(mob/living/carbon/human/jellypeople)
	if(jellypeople.physique == FEMALE)
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

/datum/species/jelly/get_laugh_sound(mob/living/carbon/human/jellypeople)
	if(jellypeople.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/laugh/womanlaugh.ogg',
			'modular_bandastation/emote_panel/audio/human/female/laugh_female_1.ogg',
			'modular_bandastation/emote_panel/audio/human/female/laugh_female_2.ogg',
			'modular_bandastation/emote_panel/audio/human/female/laugh_female_3.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/laugh/manlaugh1.ogg',
		'sound/mobs/humanoids/human/laugh/manlaugh2.ogg',
		'modular_bandastation/emote_panel/audio/human/male/laugh_male_1.ogg',
		'modular_bandastation/emote_panel/audio/human/male/laugh_male_2.ogg',
	)

/datum/species/jelly/get_sneeze_sound(mob/living/carbon/human/jellypeople)
	if(jellypeople.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sneeze/female_sneeze1.ogg'
	return 'sound/mobs/humanoids/human/sneeze/male_sneeze1.ogg'

/datum/species/jelly/get_sniff_sound(mob/living/carbon/human/jellypeople)
	if(jellypeople.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sniff/female_sniff.ogg'
	return 'sound/mobs/humanoids/human/sniff/male_sniff.ogg'

/datum/species/jelly/get_sigh_sound(mob/living/carbon/human/jellypeople)
	if(jellypeople.physique == FEMALE)
		return SFX_FEMALE_SIGH
	return SFX_MALE_SIGH

/datum/species/jelly/get_snore_sound(mob/living/carbon/human/jellypeople)
	if(jellypeople.physique == FEMALE)
		return SFX_SNORE_FEMALE
	return SFX_SNORE_MALE

/datum/species/jelly/get_hiss_sound(mob/living/carbon/human/jellypeople)
	return 'sound/mobs/humanoids/human/hiss/human_hiss.ogg'
