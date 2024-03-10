/datum/heretic_knowledge/limited_amount/starting/base_ash/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	RegisterSignal(user, COMSIG_CARBON_GAIN_WOUND, PROC_REF(on_wound_gain))

/datum/heretic_knowledge/limited_amount/starting/base_ash/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	UnregisterSignal(user, COMSIG_CARBON_GAIN_WOUND)

/datum/heretic_knowledge/limited_amount/starting/base_ash/proc/on_wound_gain(mob/living/carbon/source, datum/wound/burn/flesh/flesh_wound, obj/item/bodypart/bodypart)
	SIGNAL_HANDLER
	if(!istype(flesh_wound))
		return
	// Ensure ash heretics never succumb to infections from burn wounds.
	// The wound itself still remains an issue, it just won't get infected.
	flesh_wound.infestation_rate = 0
	flesh_wound.infestation = 0
	flesh_wound.sanitization = INFINITY
	flesh_wound.strikes_to_lose_limb = INFINITY
