/datum/symptom/piss
	name = "Eternal Pisser"
	desc = "The virus causes the host to frequently piss themselves."
	stealth = 2
	resistance = -1
	stage_speed = -2
	transmittable = -1
	level = 6
	passive_message = span_notice("You feel tingling in your bladder.")


/datum/symptom/piss/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob

	if(prob(10 * A.stage))
		var/obj/item/organ/internal/bladder/bladder = A.affected_mob.get_organ_slot
		if(bladder)
			bladder.stored_piss += 15
			bladder.urinate()
