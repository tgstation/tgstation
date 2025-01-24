// Various beeps

/datum/emote/beep
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/twobeep.ogg'
	mob_type_allowed_typecache = list(/mob/living) //Beep already exists on brains and silicons

/datum/emote/silicon/beep2
	key = "beep2"
	message = "beeps sharply."
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/machines/beep/twobeep_high.ogg'
