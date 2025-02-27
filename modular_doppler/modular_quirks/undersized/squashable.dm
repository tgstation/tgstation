/datum/component/squashable
	var/squash_sound_effect = 'sound/effects/wounds/crack1.ogg'

/datum/component/squashable/Squish(mob/living/target)
	. = ..()
	playsound(parent,squash_sound_effect, 90)
