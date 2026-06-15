/// Gathers nearby carbon humans, but only while the pawn is holding something.
/datum/target_source/oview_single_type/human_while_holding
	single_typepath = /mob/living/carbon/human

/datum/target_source/oview_single_type/human_while_holding/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	if(!pawn.get_num_held_items())
		return list()
	return ..()
