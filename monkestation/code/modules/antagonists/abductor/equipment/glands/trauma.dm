/obj/item/organ/internal/heart/gland/trauma/on_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	ADD_TRAIT(organ_owner, TRAIT_SPECIAL_TRAUMA_BOOST, ABDUCTOR_GLAND_TRAIT)

/obj/item/organ/internal/heart/gland/trauma/on_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	REMOVE_TRAIT(organ_owner, TRAIT_SPECIAL_TRAUMA_BOOST, ABDUCTOR_GLAND_TRAIT)

/obj/item/organ/internal/heart/gland/trauma/activate()
	owner.balloon_alert(owner, "you feel a sudden headache")
	// anesthetic will prevent deep-rooted traumas, allowing for a safe(r) lobotomy before removal
	var/resilience = (owner.stat == CONSCIOUS && prob(15)) ? TRAUMA_RESILIENCE_LOBOTOMY : (prob(40) ? TRAUMA_RESILIENCE_SURGERY : TRAUMA_RESILIENCE_BASIC)
	if(prob(33))
		owner.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, resilience)
	else
		if(prob(20))
			owner.gain_trauma_type(BRAIN_TRAUMA_SEVERE, resilience)
		else
			owner.gain_trauma_type(BRAIN_TRAUMA_MILD, resilience)
