/datum/species/tajaran/get_scream_sound(mob/living/carbon/human/tajaran)
	if(tajaran.physique == FEMALE)
		return 'modular_bandastation/emote_panel/audio/tajaran/tajaran_scream.ogg'
	return 'modular_bandastation/emote_panel/audio/tajaran/tajaran_scream.ogg'

/datum/species/tajaran/get_sigh_sound(mob/living/carbon/human/tajaran)
	if(tajaran.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/sigh/female_sigh1.ogg',
			'sound/mobs/humanoids/human/sigh/female_sigh2.ogg',
			'sound/mobs/humanoids/human/sigh/female_sigh3.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/sigh/male_sigh1.ogg',
		'sound/mobs/humanoids/human/sigh/male_sigh2.ogg',
		'sound/mobs/humanoids/human/sigh/male_sigh3.ogg',
	)

/datum/species/tajaran/get_cough_sound(mob/living/carbon/human/tajaran)
	if(tajaran.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cough/female_cough1.ogg',
			'sound/mobs/humanoids/human/cough/female_cough2.ogg',
			'sound/mobs/humanoids/human/cough/female_cough3.ogg',
			'sound/mobs/humanoids/human/cough/female_cough4.ogg',
			'sound/mobs/humanoids/human/cough/female_cough5.ogg',
			'sound/mobs/humanoids/human/cough/female_cough6.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cough/male_cough1.ogg',
		'sound/mobs/humanoids/human/cough/male_cough2.ogg',
		'sound/mobs/humanoids/human/cough/male_cough3.ogg',
		'sound/mobs/humanoids/human/cough/male_cough4.ogg',
		'sound/mobs/humanoids/human/cough/male_cough5.ogg',
		'sound/mobs/humanoids/human/cough/male_cough6.ogg',
	)

/datum/species/tajaran/get_cry_sound(mob/living/carbon/human/tajaran)
	if(tajaran.physique == FEMALE)
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

/datum/species/tajaran/get_sneeze_sound(mob/living/carbon/human/tajaran)
	if(tajaran.physique == FEMALE)
		return pick(
			'modular_bandastation/emote_panel/audio/tajaran/tajaran_sneeze_female1.ogg',
			'modular_bandastation/emote_panel/audio/tajaran/tajaran_sneeze_female2.ogg',
		)
	return 'modular_bandastation/emote_panel/audio/tajaran/tajaran_sneeze_male.ogg'

/datum/species/tajaran/get_laugh_sound(mob/living/carbon/human/tajaran)
	if(!ishuman(tajaran))
		return
	if(tajaran.physique == FEMALE)
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

// MARK: Emotes
/datum/emote/living/carbon/human/tajaran
	species_type_whitelist_typecache = list(/datum/species/tajaran)

/datum/emote/living/carbon/human/tajaran/emote_meow
	name = "Мяукнуть"
	key = "meow_t"
	key_third_person = "meows"
	message = "мяукает."
	message_mime = "бесшумно мяукает."
	message_param = "мяукает на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	vary = TRUE
	cooldown = 4 SECONDS
	sound = 'modular_bandastation/emote_panel/audio/tajaran/tajaran_meow.ogg'

/datum/emote/living/carbon/human/tajaran/emote_mow
	name = "Мяукнуть раздражённо"
	key = "mow"
	key_third_person = "mows"
	message = "раздражённо мяукает."
	message_mime = "бесшумно раздражённо мяукает."
	message_param = "раздражённо мяукает на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	vary = TRUE
	cooldown = 4 SECONDS
	sound = 'modular_bandastation/emote_panel/audio/tajaran/tajaran_annoyed_meow.ogg'

/datum/emote/living/carbon/human/tajaran/emote_purr
	name = "Мурчать"
	key = "purr_t"
	key_third_person = "purrs"
	message = "мурчит."
	message_mime = "бесшумно мурчит."
	message_param = "мурчит на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	cooldown = 4 SECONDS
	sound = 'modular_bandastation/emote_panel/audio/tajaran/tajaran_purr.ogg'

/datum/emote/living/carbon/human/tajaran/emote_pur
	name = "Мурчать кратко"
	key = "pur"
	key_third_person = "purs"
	message = "кратко мурчит."
	message_mime = "бесшумно кратко мурчит."
	message_param = "кратко мурчит на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	cooldown = 4 SECONDS
	sound = 'modular_bandastation/emote_panel/audio/tajaran/tajaran_purr_short.ogg'

/datum/emote/living/carbon/human/tajaran/emote_purrr
	name = "Мурчать дольше"
	key = "purrr"
	key_third_person = "purrrs"
	message = "длительно мурчит."
	message_mime = "бесшумно длительно мурчит."
	message_param = "длительно мурчит на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	cooldown = 4 SECONDS
	sound = 'modular_bandastation/emote_panel/audio/tajaran/tajaran_purr_long.ogg'

/datum/emote/living/carbon/human/tajaran/emote_hiss_t
	name = "Шипеть"
	key = "hiss_t"
	key_third_person = "hisses"
	message = "шипит."
	message_mime = "бесшумно шипит."
	message_param = "шипит на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	cooldown = 4 SECONDS
	sound = 'modular_bandastation/emote_panel/audio/tajaran/tajaran_hiss.ogg'
