/datum/quirk/mute
	name = "Mute"
	desc = "Due to some accident, medical condition, or simply by choice, you are completely unable to speak."
	value = -2 //HALP MAINTS
	gain_text = "<span class='danger'>You find yourself unable to speak!</span>"
	lose_text = "<span class='notice'>You feel a growing strength in your vocal chords.</span>"
	medical_record_text = "Functionally mute, patient is unable to use their voice in any capacity."

/datum/quirk/mute/add()
	var/mob/living/carbon/human/H = quirk_holder
	H.gain_trauma(new /datum/brain_trauma/severe/mute, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/mute/remove()
	var/mob/living/carbon/human/H = quirk_holder
	H?.cure_trauma_type(/datum/brain_trauma/severe/mute, TRAUMA_RESILIENCE_ABSOLUTE)
