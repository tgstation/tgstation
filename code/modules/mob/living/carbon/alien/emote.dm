/datum/emote/living/alien
	mob_type_allowed_typecache = list(/mob/living/carbon/alien)

/datum/emote/living/alien/gnarl
	key = "gnarl"
	key_third_person = "gnarls"
	message = "gnarls and shows its teeth..."

/datum/emote/living/alien/hiss
	key = "hiss"
	key_third_person = "hisses"
	message_alien = "hisses."
	message_larva = "hisses softly."

/datum/emote/living/alien/hiss/run_emote(mob/user, params)
	. = ..()
	if(. && isalienadult(user))
		playsound(user.loc, "hiss", 40, 1, 1)

/datum/emote/living/alien/roar
	key = "roar"
	key_third_person = "roars"
	message_alien = "roars"
	message_larva = "sofly roars"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/alien/roar/run_emote(mob/user, params)
	. = ..()
	if(. && isalienadult(user))
		playsound(user.loc, 'sound/voice/hiss5.ogg', 40, 1, 1)