/datum/surgery_step/heal/proc/remove_husking(mob/living/carbon/target) //Surgery heal can repair husking, including changeling husking now that we have no cloning.
	if(HAS_TRAIT(target, TRAIT_HUSK) && target.getFireLoss() < THRESHOLD_UNHUSK)
		target.cure_husk()
		target.visible_message("<span class='nicegreen'>[target]'s tissues are surgically repaired, taking on a more healthy appearance.")