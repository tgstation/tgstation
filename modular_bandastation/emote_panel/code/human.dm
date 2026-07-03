/datum/sound_effect/male_sigh
	file_paths = list(
		'sound/mobs/humanoids/human/sigh/male_sigh1.ogg',
		'sound/mobs/humanoids/human/sigh/male_sigh2.ogg',
		'sound/mobs/humanoids/human/sigh/male_sigh3.ogg',
		'modular_bandastation/emote_panel/audio/human/male/sigh_male.ogg',
	)

/datum/sound_effect/female_sigh
	file_paths = list(
		'sound/mobs/humanoids/human/sigh/female_sigh1.ogg',
		'sound/mobs/humanoids/human/sigh/female_sigh2.ogg',
		'sound/mobs/humanoids/human/sigh/female_sigh3.ogg',
		'modular_bandastation/emote_panel/audio/human/female/sigh_female.ogg',
	)

/datum/species/human/get_cry_sound(mob/living/carbon/human/human)
	if(human.physique == FEMALE)
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

/datum/species/human/get_laugh_sound(mob/living/carbon/human/human)
	if(human.physique == FEMALE)
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

/// Returns the species' giggle sound.
/datum/emote/living/giggle/get_sound(mob/living/carbon/human/user)
	if(!istype(user))
		return
	return user.dna.species.get_giggle_sound(user)
/datum/species/proc/get_giggle_sound(mob/living/carbon/human/user)
	if(user.physique == FEMALE)
		return pick(
			'modular_bandastation/emote_panel/audio/human/female/giggle_female_1.ogg',
			'modular_bandastation/emote_panel/audio/human/female/giggle_female_2.ogg',
			'modular_bandastation/emote_panel/audio/human/female/giggle_female_3.ogg',
			'modular_bandastation/emote_panel/audio/human/female/giggle_female_4.ogg',
		)
	return pick(
		'modular_bandastation/emote_panel/audio/human/male/giggle_male_1.ogg',
		'modular_bandastation/emote_panel/audio/human/male/giggle_male_2.ogg',
	)
// MARK: Emotes
/datum/emote/living/sniffle
	key = "sniffle"
	key_third_person = "sniffles"
	name = "нюхать"
	message = "нюхает."
	message_mime = "бесшумно нюхает."
	message_param = "нюхает %t."

/datum/emote/living/sniffle/get_sound(mob/living/user)
	if(user.gender == FEMALE)
		return 'modular_bandastation/emote_panel/audio/human/female/sniff_female.ogg'
	else
		return 'modular_bandastation/emote_panel/audio/human/male/sniff_male.ogg'

/datum/emote/living/gasp/get_sound(mob/living/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/human_user = user
	if(human_user.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/gasp/gasp_female1.ogg',
			'sound/mobs/humanoids/human/gasp/gasp_female2.ogg',
			'sound/mobs/humanoids/human/gasp/gasp_female3.ogg',
			'modular_bandastation/emote_panel/audio/human/female/gasp_female_1.ogg',
			'modular_bandastation/emote_panel/audio/human/female/gasp_female_2.ogg',
			'modular_bandastation/emote_panel/audio/human/female/gasp_female_3.ogg',
			'modular_bandastation/emote_panel/audio/human/female/gasp_female_4.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/gasp/gasp_male1.ogg',
		'sound/mobs/humanoids/human/gasp/gasp_male2.ogg',
		'modular_bandastation/emote_panel/audio/human/male/gasp_male_1.ogg',
		'modular_bandastation/emote_panel/audio/human/male/gasp_male_2.ogg',
		'modular_bandastation/emote_panel/audio/human/male/gasp_male_3.ogg',
		'modular_bandastation/emote_panel/audio/human/male/gasp_male_4.ogg',
		'modular_bandastation/emote_panel/audio/human/male/gasp_male_5.ogg',
	)

/datum/emote/living/yawn/get_sound(mob/living/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/human_user = user
	if(human_user.physique == FEMALE)
		return pick(
			'modular_bandastation/emote_panel/audio/human/female/yawn_female_1.ogg',
			'modular_bandastation/emote_panel/audio/human/female/yawn_female_2.ogg',
			'modular_bandastation/emote_panel/audio/human/female/yawn_female_3.ogg',
		)
	return pick(
		'modular_bandastation/emote_panel/audio/human/male/yawn_male_1.ogg',
		'modular_bandastation/emote_panel/audio/human/male/yawn_male_2.ogg',
	)

/datum/emote/living/choke/get_sound(mob/living/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/human_user = user
	if(human_user.physique == FEMALE)
		return pick(
			'modular_bandastation/emote_panel/audio/human/female/choke_female_1.ogg',
			'modular_bandastation/emote_panel/audio/human/female/choke_female_2.ogg',
			'modular_bandastation/emote_panel/audio/human/female/choke_female_3.ogg',
		)
	return pick(
		'modular_bandastation/emote_panel/audio/human/male/choke_male_1.ogg',
		'modular_bandastation/emote_panel/audio/human/male/choke_male_2.ogg',
		'modular_bandastation/emote_panel/audio/human/male/choke_male_3.ogg',
	)

/datum/emote/living/carbon/whistle/get_sound(mob/living/user)
	return pick(
		'sound/mobs/humanoids/human/whistle/whistle1.ogg',
		'modular_bandastation/emote_panel/audio/whistle.ogg',
	)

/datum/emote/living/carbon/moan/get_sound(mob/living/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/human_user = user
	if(human_user.physique == FEMALE)
		return pick(
			'modular_bandastation/emote_panel/audio/human/female/moan_female_1.ogg',
			'modular_bandastation/emote_panel/audio/human/female/moan_female_2.ogg',
			'modular_bandastation/emote_panel/audio/human/female/moan_female_3.ogg',
		)
	return pick(
		'modular_bandastation/emote_panel/audio/human/male/moan_male_1.ogg',
		'modular_bandastation/emote_panel/audio/human/male/moan_male_2.ogg',
		'modular_bandastation/emote_panel/audio/human/male/moan_male_3.ogg',
	)

/datum/emote/living/dance
	cooldown = 5 SECONDS

/datum/emote/living/dance/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	user.spin(cooldown, pick(0.1 SECONDS, 0.2 SECONDS))
	user.do_jitter_animation(rand(8 SECONDS, 16 SECONDS), cooldown / 4)

/datum/emote/living/evil_laugh
	key = "laughevil"
	message = "злорадно смеётся."
	message_mime = "бесшумно злорадно смеётся!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/evil_laugh/can_run_emote(mob/living/user, status_check = TRUE, intentional, params)
	return ..() && user.can_speak(allow_mimes = TRUE)

/datum/emote/living/evil_laugh/get_sound(mob/living/carbon/human/user)
	if(!istype(user))
		return
	return user.dna.species.get_evil_laugh_sound(user)
