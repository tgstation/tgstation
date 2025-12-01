/datum/emote/living/alien
	mob_type_allowed_typecache = list(/mob/living/carbon/alien)

/datum/emote/living/alien/gnarl
	key = "gnarl"
	key_third_person = "gnarls"
	message = "gnarls and shows its teeth..."

/datum/emote/living/alien/roar
	key = "roar"
	key_third_person = "roars"
	message_alien = "roars."
	message_larva = "softly roars."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	vary = TRUE

/datum/emote/living/alien/roar/get_sound(mob/living/user)
	if(isalienadult(user))
		return 'sound/mobs/non-humanoids/hiss/hiss5.ogg'
