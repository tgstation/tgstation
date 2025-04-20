/datum/status_effect/slapped_silly
	id = "slapped_silly"
	duration = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/slapped_silly
	///This sound is played for the duration of the effect.
	var/datum/looping_sound/dizzy_birdies/bird_noise
	///This overlay is applied to the owner for the duration of the effect.
	var/static/mob_overlay

/datum/status_effect/slapped_silly/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	. = ..()

/datum/status_effect/slapped_silly/on_apply()
	. = ..()
	if(!isliving(owner))
		return FALSE
	var/mob/living/living_owner = owner

	if(isnull(mob_overlay))
		mob_overlay = icon2appearance('icons/mob/effects/halo.dmi', "dizzy_birdies")
	owner.add_overlay(mob_overlay)
	owner.update_overlays()

	living_owner.adjust_confusion(25 SECONDS)
	ADD_TRAIT(living_owner, TRAIT_CLUMSY, id)
	bird_noise = new(living_owner, TRUE)

/datum/status_effect/slapped_silly/on_remove()
	. = ..()
	if(QDELETED(owner))
		return

	var/mob/living/living_owner = owner
	living_owner.set_confusion(0 SECONDS) //Yes, a light slap might actually help treat confusion.
	REMOVE_TRAIT(living_owner, TRAIT_CLUMSY, id)
	QDEL_NULL(bird_noise)
	owner.cut_overlay(mob_overlay)
	owner.update_overlays()

/atom/movable/screen/alert/status_effect/slapped_silly
	name = "Slapped Silly"
	desc = "HONK!"
	icon_state = "waddle"
