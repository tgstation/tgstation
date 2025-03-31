/datum/quirk/touchy
	name = "Touchy"
	desc = "You are very touchy and have to physically be able to touch something to examine it."
	icon = FA_ICON_HAND
	value = -2
	gain_text = span_danger("You feel like you can't examine things from a distance.")
	lose_text = span_notice("You feel like you can examine things from a distance.")
	medical_record_text = "Patient is unable to tell objects apart from a distance."
	hardcore_value = 4

/datum/quirk/touchy/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_CLICK_SHIFT, PROC_REF(examinate_check))

/datum/quirk/touchy/remove()
	UnregisterSignal(quirk_holder, COMSIG_CLICK_SHIFT)

///Checks if the mob is besides the  thing being examined, if they aren't then we cancel their examinate.
/datum/quirk/touchy/proc/examinate_check(mob/examiner, atom/examined)
	SIGNAL_HANDLER

	if(!examined.Adjacent(examiner))
		return COMSIG_MOB_CANCEL_CLICKON
