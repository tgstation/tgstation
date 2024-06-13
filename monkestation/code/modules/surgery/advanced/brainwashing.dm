/datum/surgery_step/brainwash/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	if(HAS_MIND_TRAIT(target, TRAIT_UNCONVERTABLE))
		to_chat(user, span_warning("[target] doesn't respond to the brainwashing, as if [target.p_their()] mind was completely hardened against any form of influence."))
		return FALSE
	return ..()
