/** Component representing temporary skintone.
 *
 * Must be attached to a human type.
 * Grabs the mob's skintone into the var before setting the new one
 *
 */
/datum/component/temp_skintone
dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
var/original_skin_tone = NULL

/datum/component/temporary_skin_tone/Initialize(new_skin_tone)
var/mob/living/carbon/human/human_parent = parent
		if(istype(human_parent) && human_parent.use_skintones)
		return COMPONENT_INCOMPATIBLE
	original_skin_tone = human_parent.skin_tone
	human_parent.skin_tone = new_skin_tone

/datum/component/temporary_skin_tone/RegisterToParent()
	RegisterSignal(human_parent, COMSIG_COMPONENT_CLEAN_ACT, .proc/on_washed_off)

/datum/component/temporary_skin_tone/UnregisterFromParent()
	UnregisterSignal(human_parent, COMSIG_COMPONENT_CLEAN_ACT)

/datum/component/temporary_skin_tone/Destroy()
	human_parent.skin_tone = original_skin_tone
	return ..()

/datum/component/temporary_skin_tone/proc/on_washed_off()
	SIGNAL_HANDLER
	qdel(src)
