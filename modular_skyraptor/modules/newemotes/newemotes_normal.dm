/datum/emote/living/claponce
	key = "clap1"
	key_third_person = "claps once"
	message = "claps once."
	muzzle_ignore = TRUE
	hands_use_check = TRUE
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	audio_cooldown = 1 SECONDS
	vary = TRUE

/datum/emote/living/claponce/get_sound(mob/living/user)
	if(ishuman(user))
		if(!user.get_bodypart(BODY_ZONE_L_ARM) || !user.get_bodypart(BODY_ZONE_R_ARM))
			return
		else
			return pick('modular_skyraptor/modules/newemotes/sounds/claponce1.ogg',
							'modular_skyraptor/modules/newemotes/sounds/claponce2.ogg')
	else
		return pick('modular_skyraptor/modules/newemotes/sounds/claponce1.ogg',
							'modular_skyraptor/modules/newemotes/sounds/claponce2.ogg')

/datum/emote/living/cackle
	key = "cackle"
	key_third_person = "cackles"
	message = "cackles!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	audio_cooldown = 3 SECONDS
	vary = TRUE

/datum/emote/living/cackle/get_sound(mob/living/user)
	return pick('modular_skyraptor/modules/newemotes/sounds/voice/cackle_yeen.ogg')

/datum/emote/living/warble
	key = "warble"
	key_third_person = "warbles"
	message = "warbles!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	audio_cooldown = 1 SECONDS
	vary = TRUE

/datum/emote/living/warble/get_sound(mob/living/user)
	return pick('modular_skyraptor/modules/newemotes/sounds/voice/warble.ogg')

/datum/emote/living/wurble
	key = "wurble"
	key_third_person = "wurble"
	message = "lets out a wurble."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	audio_cooldown = 1 SECONDS
	vary = TRUE

/datum/emote/living/wurble/get_sound(mob/living/user)
	return pick('modular_skyraptor/modules/newemotes/sounds/voice/wurble.ogg')

/datum/emote/living/peep
	key = "peep"
	key_third_person = "peeps"
	message = "peeps!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	audio_cooldown = 1 SECONDS
	vary = TRUE

/datum/emote/living/peep/get_sound(mob/living/user)
	return pick('modular_skyraptor/modules/newemotes/sounds/voice/peep_once.ogg')

/datum/emote/living/peep2
	key = "peep2"
	key_third_person = "peep2s"
	message = "peeps twice!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	audio_cooldown = 1 SECONDS
	vary = TRUE

/datum/emote/living/peep2/get_sound(mob/living/user)
	return pick('modular_skyraptor/modules/newemotes/sounds/voice/peep.ogg')

/datum/emote/living/hoot
	key = "hoot"
	key_third_person = "hoots"
	message = "hoots!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	audio_cooldown = 1 SECONDS
	vary = TRUE

/datum/emote/living/hoot/get_sound(mob/living/user)
	return pick('modular_skyraptor/modules/newemotes/sounds/voice/hoot.ogg')

/datum/emote/living/trill
	key = "trill"
	key_third_person = "trills"
	message = "trills!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	audio_cooldown = 1 SECONDS
	vary = TRUE

/datum/emote/living/trill/get_sound(mob/living/user)
	return pick('modular_skyraptor/modules/newemotes/sounds/voice/trills.ogg')

/datum/emote/living/msqueak
	key = "msqueak"
	key_third_person = "msqueaks"
	message = "makes a tiny squeak!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	audio_cooldown = 1 SECONDS
	vary = TRUE

/datum/emote/living/msqueak/get_sound(mob/living/user)
	return pick('modular_skyraptor/modules/newemotes/sounds/voice/mothsqueak.ogg')

/datum/emote/living/chitter
	key = "chitter"
	key_third_person = "chitters"
	message = "chitters!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	audio_cooldown = 1 SECONDS
	vary = TRUE

/datum/emote/living/chitter/get_sound(mob/living/user)
	return pick('modular_skyraptor/modules/newemotes/sounds/voice/mothchitter.ogg')

/datum/emote/living/merp
	key = "merp"
	key_third_person = "merps"
	message = "merps!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	audio_cooldown = 1 SECONDS
	vary = TRUE

/datum/emote/living/merp/get_sound(mob/living/user)
	return pick('modular_skyraptor/modules/newemotes/sounds/voice/merp.ogg')

/datum/emote/living/weh
	key = "weh"
	key_third_person = "wehs"
	message = "wehs!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	audio_cooldown = 1 SECONDS
	vary = TRUE

/datum/emote/living/weh/get_sound(mob/living/user)
	return pick('modular_skyraptor/modules/newemotes/sounds/voice/weh.ogg')

/datum/emote/living/snap1 //i know it's just *snap on skyrat but it's inconsistent with *clap1 and it is AGONY
	key = "snap1"
	key_third_person = "snap1s"
	message = "snaps their fingers!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	audio_cooldown = 1 SECONDS
	vary = TRUE

/datum/emote/living/snap1/get_sound(mob/living/user)
	if(ishuman(user))
		if(!user.get_bodypart(BODY_ZONE_L_ARM) || !user.get_bodypart(BODY_ZONE_R_ARM))
			return
		else
			return pick('modular_skyraptor/modules/newemotes/sounds/snap1.ogg')
	else
		return pick('modular_skyraptor/modules/newemotes/sounds/snap1.ogg')

/datum/emote/living/snap2
	key = "snap2"
	key_third_person = "snap2s"
	message = "snaps their fingers twice!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	audio_cooldown = 1 SECONDS
	vary = TRUE

/datum/emote/living/snap2/get_sound(mob/living/user)
	if(ishuman(user))
		if(!user.get_bodypart(BODY_ZONE_L_ARM) || !user.get_bodypart(BODY_ZONE_R_ARM))
			return
		else
			return pick('modular_skyraptor/modules/newemotes/sounds/snap2.ogg')
	else
		return pick('modular_skyraptor/modules/newemotes/sounds/snap2.ogg')

/datum/emote/living/snap3
	key = "snap3"
	key_third_person = "snap3s"
	message = "snaps their fingers thrice!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	audio_cooldown = 1 SECONDS
	vary = TRUE

/datum/emote/living/snap3/get_sound(mob/living/user)
	if(ishuman(user))
		if(!user.get_bodypart(BODY_ZONE_L_ARM) || !user.get_bodypart(BODY_ZONE_R_ARM))
			return
		else
			return pick('modular_skyraptor/modules/newemotes/sounds/snap3.ogg')
	else
		return pick('modular_skyraptor/modules/newemotes/sounds/snap3.ogg')

/datum/emote/living/hiss
	key = "hiss"
	key_third_person = "hisses"
	message = "hisses."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	audio_cooldown = 1 SECONDS
	vary = TRUE

/datum/emote/living/hiss/get_sound(mob/living/user)
	return pick('modular_skyraptor/modules/newemotes/sounds/voice/hiss1.ogg',
					'modular_skyraptor/modules/newemotes/sounds/voice/hiss2.ogg')
