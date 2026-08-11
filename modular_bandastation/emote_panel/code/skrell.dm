/obj/item/organ/tongue/skrell
	emote_sounds = list(
		/datum/emote/living/scream::key = list(
			FEMALE = list(
				'sound/mobs/humanoids/human/scream/femalescream_1.ogg',
				'sound/mobs/humanoids/human/scream/femalescream_2.ogg',
				'sound/mobs/humanoids/human/scream/femalescream_3.ogg',
				'sound/mobs/humanoids/human/scream/femalescream_4.ogg',
				'sound/mobs/humanoids/human/scream/femalescream_5.ogg',
			),
			MALE = list(
				'sound/mobs/humanoids/human/scream/malescream_1.ogg',
				'sound/mobs/humanoids/human/scream/malescream_2.ogg',
				'sound/mobs/humanoids/human/scream/malescream_3.ogg',
				'sound/mobs/humanoids/human/scream/malescream_4.ogg',
				'sound/mobs/humanoids/human/scream/malescream_5.ogg',
				'sound/mobs/humanoids/human/scream/malescream_6.ogg',
			),
		),
		/datum/emote/living/carbon/cry::key = list(
			FEMALE = list(
				'sound/mobs/humanoids/human/cry/female_cry1.ogg',
				'sound/mobs/humanoids/human/cry/female_cry2.ogg',
				'modular_bandastation/emote_panel/audio/human/female/cry_female_1.ogg',
				'modular_bandastation/emote_panel/audio/human/female/cry_female_2.ogg',
				'modular_bandastation/emote_panel/audio/human/female/cry_female_3.ogg',
			),
			MALE = list(
				'sound/mobs/humanoids/human/cry/male_cry1.ogg',
				'sound/mobs/humanoids/human/cry/male_cry2.ogg',
				'sound/mobs/humanoids/human/cry/male_cry3.ogg',
				'modular_bandastation/emote_panel/audio/human/male/cry_male_1.ogg',
				'modular_bandastation/emote_panel/audio/human/male/cry_male_2.ogg',
			),
		),
		/datum/emote/living/sigh::key = list(
			MALE = SFX_MALE_SIGH,
			FEMALE = SFX_FEMALE_SIGH,
		),
		/datum/emote/living/sniff::key = list(
			FEMALE = 'sound/mobs/humanoids/human/sniff/female_sniff.ogg',
			MALE = 'sound/mobs/humanoids/human/sniff/male_sniff.ogg',
		),
		/datum/emote/living/cough::key = list(
			FEMALE = list(
				'sound/mobs/humanoids/human/cough/female_cough1.ogg',
				'sound/mobs/humanoids/human/cough/female_cough2.ogg',
				'sound/mobs/humanoids/human/cough/female_cough3.ogg',
				'sound/mobs/humanoids/human/cough/female_cough4.ogg',
				'sound/mobs/humanoids/human/cough/female_cough5.ogg',
				'sound/mobs/humanoids/human/cough/female_cough6.ogg',
			),
			MALE = list(
				'sound/mobs/humanoids/human/cough/male_cough1.ogg',
				'sound/mobs/humanoids/human/cough/male_cough2.ogg',
				'sound/mobs/humanoids/human/cough/male_cough3.ogg',
				'sound/mobs/humanoids/human/cough/male_cough4.ogg',
				'sound/mobs/humanoids/human/cough/male_cough5.ogg',
				'sound/mobs/humanoids/human/cough/male_cough6.ogg',
			),
		),
		/datum/emote/living/laugh::key = list(
			FEMALE = list(
				'modular_bandastation/emote_panel/audio/skrell/laugh_female_1.ogg',
				'modular_bandastation/emote_panel/audio/skrell/laugh_female_2.ogg',
				'modular_bandastation/emote_panel/audio/skrell/laugh_female_3.ogg',
			),
			MALE = list(
				'modular_bandastation/emote_panel/audio/skrell/laugh_male_1.ogg',
				'modular_bandastation/emote_panel/audio/skrell/laugh_male_2.ogg',
				'modular_bandastation/emote_panel/audio/skrell/laugh_male_3.ogg',
			),
		),
		/datum/emote/living/giggle::key = list(
			FEMALE = 'modular_bandastation/emote_panel/audio/skrell/giggle_female_1.ogg',
			MALE = 'modular_bandastation/emote_panel/audio/skrell/giggle_male_1.ogg',
		),
		/datum/emote/living/sneeze::key = list(
			FEMALE = 'sound/mobs/humanoids/human/sneeze/female_sneeze1.ogg',
			MALE = 'sound/mobs/humanoids/human/sneeze/male_sneeze1.ogg',
		),
		/datum/emote/living/snore::key = list(
			FEMALE = SFX_SNORE_FEMALE,
			MALE = SFX_SNORE_MALE,
		),
		/datum/emote/living/carbon/hiss::key = 'sound/mobs/humanoids/human/hiss/human_hiss.ogg',
	)

// MARK: Emotes
/datum/emote/living/carbon/human/skrell
	species_type_whitelist_typecache = list(/datum/species/skrell)

/datum/emote/living/carbon/human/skrell/warble
	name = "Трелить"
	key = "warble"
	key_third_person = "warbles"
	message = "трелит."
	message_param = "трелит на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	vary = TRUE

/datum/emote/living/carbon/human/skrell/warble/get_sound(mob/living/user)
	return pick(
		'modular_bandastation/emote_panel/audio/skrell/warble_1.ogg',
		'modular_bandastation/emote_panel/audio/skrell/warble_2.ogg',
	)

/datum/emote/living/carbon/human/skrell/warble/melodic
	name = "Мелодично трелить"
	key = "melodicwarble"
	key_third_person = "melodicwarble"
	message = "мелодично трелит."
	message_param = "мелодично трелит на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	vary = TRUE

/datum/emote/living/carbon/human/skrell/warble/melodic/get_sound(mob/living/user)
	return pick(
		'modular_bandastation/emote_panel/audio/skrell/melodicwarble.ogg',
	)

/datum/emote/living/carbon/human/skrell/croak
	name = "Квакать"
	key = "croak"
	key_third_person = "croak"
	message = "квакает."
	message_param = "квакает на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	vary = TRUE

/datum/emote/living/carbon/human/skrell/croak/get_sound(mob/living/user)
	return pick(
		'modular_bandastation/emote_panel/audio/skrell/croak_1.ogg',
		'modular_bandastation/emote_panel/audio/skrell/croak_2.ogg',
		'modular_bandastation/emote_panel/audio/skrell/croak_3.ogg',
	)

/datum/emote/living/carbon/human/skrell/croak/anger
	name = "Гневно квакать"
	key = "croak_anger"
	key_third_person = "croak_anger"
	message = "гневно квакает!"
	message_param = "гневно квакает на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	vary = TRUE

/datum/emote/living/carbon/human/skrell/croak/anger/get_sound(mob/living/user)
	return pick(
		'modular_bandastation/emote_panel/audio/skrell/anger_1.ogg',
		'modular_bandastation/emote_panel/audio/skrell/anger_2.ogg',
	)
