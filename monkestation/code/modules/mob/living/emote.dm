/datum/emote/living/click
	key = "click"
	key_third_person = "clicks their tongue"
	message = "clicks their tongue."
	message_ipc = "makes a click sound."
	message_insect = "clicks their mandibles."

/datum/emote/living/click/get_sound(mob/living/user)
	if(ismoth(user) || isflyperson(user) || istype(user, /mob/living/basic/mothroach))
		return 'monkestation/sound/creatures/rattle.ogg'
	else if(isipc(user))
		return 'sound/machines/click.ogg'
	else
		return FALSE

/datum/emote/living/zap
	key = "zap"
	key_third_person = "zaps"
	message = "zaps."
	message_param = "zaps %t."

/datum/emote/living/zap/can_run_emote(mob/user, status_check = TRUE , intentional)
	. = ..()
	if(isethereal(user))
		return TRUE
	else
		return FALSE

/datum/emote/living/zap/get_sound(mob/living/user)
	if(isethereal(user))
		return 'sound/machines/defib_zap.ogg'

/datum/emote/living/hum
	key = "hum"
	key_third_person = "hums"
	message = "hums."
	message_robot = "lets out a droning hum."
	message_AI = "lets out a droning hum."
	message_ipc = "lets out a droning hum."
	message_mime = "silently hums."

/datum/emote/living/hiss
	key = "hiss"
	key_third_person = "hisses"
	message = "lets out a hiss."
	message_robot = "plays a hissing noise."
	message_AI = "plays a hissing noise."
	message_ipc = "plays a hissing noise."
	message_mime = "acts out a hiss."
	message_param = "hisses at %t."

/datum/emote/living/hiss/get_sound(mob/living/user)
	if(islizard(user) || isipc(user) || isAI(user) || iscyborg(user))
		return pick('sound/voice/hiss1.ogg', 'sound/voice/hiss2.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss4.ogg', 'sound/voice/hiss5.ogg', 'sound/voice/hiss6.ogg')

/datum/emote/living/thumbs_up
	key = "thumbsup"
	key_third_person = "thumbsup"
	message = "flashes a thumbs up."
	message_robot = "makes a crude thumbs up with their 'hands'."
	message_AI = "flashes a quick hologram of a thumbs up."
	message_ipc = "flashes a thumbs up icon."
	message_animal_or_basic = "attempts a thumbs up."
	message_param = "flashes a thumbs up at %t."
	hands_use_check = TRUE

/datum/emote/living/thumbs_down
	key = "thumbsdown"
	key_third_person = "thumbsdown"
	message = "flashes a thumbs down."
	message_robot = "makes a crude thumbs down with their 'hands'."
	message_AI = "flashes a quick hologram of a thumbs down."
	message_ipc = "flashes a thumbs down icon."
	message_animal_or_basic = "attempts a thumbs down."
	message_param = "flashes a thumbs down at %t."
	hands_use_check = TRUE

/datum/emote/living/whistle
	key="whistle"
	key_third_person="whistle"
	message = "whistles a few notes."
	message_robot = "whistles a few synthesized notes."
	message_AI = "whistles a synthesized song."
	message_ipc = "whistles a few synthesized notes."
	message_param = "whistles at %t."
