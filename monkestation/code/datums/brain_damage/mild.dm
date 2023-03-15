/datum/brain_trauma/mild/kleptomania
	name = "Kleptomania"
	desc = "Patient has a fixation of small objects and may involuntarily pick them up."
	scan_desc = "kleptomania"
	gain_text = "<span class='warning'>You feel a strong urge to grab things.</span>"
	lose_text = "<span class='notice'>You no longer feel the urge to grab things.</span>"

/datum/brain_trauma/mild/kleptomania/on_gain()
	owner.apply_status_effect(STATUS_EFFECT_KLEPTOMANIA)
	..()

/datum/brain_trauma/mild/kleptomania/on_lose()
	owner.remove_status_effect(STATUS_EFFECT_KLEPTOMANIA)
	..()

