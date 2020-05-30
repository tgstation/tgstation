/obj/effect/catroomba
	icon = 'icons/effects/catroomba.dmi'
	name = "cat roomba video"
	desc = "holy shit"
	var/datum/looping_sound/catroomba/sounds

/obj/effect/catroomba/Initialize()
	. = ..()
	sounds = new(list(src), FALSE)
	sounds.start()

/datum/looping_sound/catroomba
	mid_length = 114
	mid_sounds = list('sound/effects/catroomba.ogg')
	volume = 100
	vary = TRUE
