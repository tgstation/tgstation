/datum/emote/slime
	mob_type_allowed_typecache = /mob/living/simple_animal/slime
	mob_type_blacklist_typecache = list()

/datum/emote/slime/bounce
	key = "bounce"
	key_third_person = "bounces"
	message = "bounces in place."

/datum/emote/slime/jiggle
	key = "jiggle"
	key_third_person = "jiggles"
	message = "jiggles!"

/datum/emote/slime/light
	key = "light"
	key_third_person = "lights"
	message = "lights up for a bit, then stops."

/datum/emote/slime/vibrate
	key = "vibrate"
	key_third_person = "vibrates"
	message = "vibrates!"

/datum/emote/slime/mood
	var/mood

/datum/emote/slime/mood/run_emote(mob/user, params)
	. = ..()
	var/mob/living/simple_animal/slime/S = user
	S.mood = mood
	S.regenerate_icons()

/datum/emote/slime/mood/noface
	key = "noface"
	mood = null

/datum/emote/slime/mood/smile
	key = "smile"
	key_third_person = "smiles"
	mood = "mischevous"

/datum/emote/slime/mood/kiss
	key = ":3"
	mood = ":33"

/datum/emote/slime/mood/pout
	key = "pout"
	key_third_person = "pouts"
	mood = "pout"

/datum/emote/slime/mood/frown
	key = "frown"
	key_third_person = "frowns"
	mood = "sad"

/datum/emote/slime/mood/scowl
	key = "scowl"
	key_third_person = "scowls"
	mood = "angry"