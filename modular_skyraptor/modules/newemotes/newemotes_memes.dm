/datum/emote/living/snake_scream
	key = "agony"
	key_third_person = "agonizes"
	message = "seizes up and falls limp, their eyes dead and lifeless..."
	muzzle_ignore = FALSE
	hands_use_check = FALSE
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	audio_cooldown = 1 SECONDS
	vary = FALSE

/datum/emote/living/snake_scream/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(isliving(user))
		var/mob/living/liveuser = user
		liveuser.set_resting(TRUE, TRUE, FALSE)
		if(liveuser.death_message)
			message = liveuser.death_message
		else
			message = "seizes up and falls limp, their eyes dead and lifeless..."

/datum/emote/living/snake_scream/get_sound(mob/living/user)
	return pick('modular_skyraptor/modules/newemotes/sounds/snake_fucking_died.ogg')

/datum/emote/living/snake_scream/oldspess
	key = "oldscream"
	key_third_person = "oldscreams"
	message = "lets out an agonized scream!"

/datum/emote/living/snake_scream/oldspess/get_sound(mob/living/user)
	return pick('sound/voice/human/malescream_2.ogg')

/datum/emote/living/snake_scream/jc
	key = "jcagony"
	key_third_person = "jcagonizes"

/datum/emote/living/snake_scream/jc/get_sound(mob/living/user)
	return pick('modular_skyraptor/modules/newemotes/sounds/jc_fucking_died.ogg')

/datum/emote/living/snake_scream/teshi
	key = "teshagony"
	key_third_person = "teshagonizes"

/datum/emote/living/snake_scream/teshi/get_sound(mob/living/user)
	return pick('modular_skyraptor/modules/newemotes/sounds/teshi_fucking_died.ogg')

/datum/emote/living/snake_scream/lizzer
	key = "lizagony"
	key_third_person = "lizagonizes"

/datum/emote/living/snake_scream/lizzer/get_sound(mob/living/user)
	return pick('modular_skyraptor/modules/newemotes/sounds/lizzer_fucking_died.ogg')

/datum/emote/living/snake_scream/haki
	key = "voxagony"
	key_third_person = "voxagonizes"

/datum/emote/living/snake_scream/haki/get_sound(mob/living/user)
	return pick('modular_skyraptor/modules/newemotes/sounds/haki_fucking_died.ogg')

/datum/emote/living/snake_scream/moff
	key = "mothagony"
	key_third_person = "mothagonizes"

/datum/emote/living/snake_scream/moff/get_sound(mob/living/user)
	return pick('modular_skyraptor/modules/newemotes/sounds/moff_fucking_died.ogg')

/datum/emote/living/snake_scream/scug
	key = "sluggony"
	key_third_person = "sluggonizes"

/datum/emote/living/snake_scream/scug/get_sound(mob/living/user)
	return pick('modular_skyraptor/modules/newemotes/sounds/sluggony2.ogg')
