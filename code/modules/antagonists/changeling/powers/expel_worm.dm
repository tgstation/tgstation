/datum/action/changeling_expel_worm
	name = "Expel Worm"
	desc = "Forcefully expel the blood worm in your body."

	background_icon_state = "bg_changeling"
	overlay_icon_state = "bg_changeling_border"
	button_icon = 'icons/mob/actions/actions_changeling.dmi'
	button_icon_state = "expel_worm"

/datum/action/changeling_expel_worm/IsAvailable(feedback)
	if (!IS_CHANGELING(owner))
		return FALSE
	if (!istype(owner, /mob/living/blood_worm_host))
		return FALSE
	if (!HAS_TRAIT(owner.loc, TRAIT_BLOOD_WORM_HOST))
		return FALSE
	if (!locate(/mob/living/basic/blood_worm) in owner.loc)
		return FALSE
	return TRUE

/datum/action/changeling_expel_worm/Trigger(mob/clicker, trigger_flags)
	var/mob/living/basic/blood_worm/invader = locate() in owner.loc
	to_chat(owner, span_danger("You expel \the [invader] from your body!"))
	to_chat(invader, span_userdanger("You are forcefully expelled by the body of \the [owner.loc]!"))
	invader.leave_host() // hasta la vista, worm
	return TRUE
