
/datum/action/adjust_vision
	name = "Adjust Vision"
	desc = "See better in the dark. Or don't. Your advanced vision allows either."
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "adjust_vision"
	background_icon_state = "bg_default"

/datum/action/adjust_vision/Grant(mob/living/grant_to)
	. = ..()
	grant_to.see_in_dark = NIGHTVISION_FOV_RANGE
	grant_to.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/datum/action/adjust_vision.Remove(mob/living/remove_from)
	. = ..()
	grant_to.see_in_dark = initial(grant_to.see_in_dark)
	grant_to.lighting_alpha = initial(grant_to.lighting_alpha)

/datum/action/adjust_vision/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	var/mob/living/living_owner = owner
	living_owner.sight = initial(sight_flags)
	switch(living_owner.lighting_alpha)
		if (LIGHTING_PLANE_ALPHA_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		else
			lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			living_owner.sight &= ~SEE_BLACKNESS
