/datum/surgery/eye_surgery
	name = "eye surgery"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/fix_eyes, /datum/surgery_step/close)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_PRECISE_EYES)
	requires_bodypart_type = 0

//fix eyes
/datum/surgery_step/fix_eyes
	name = "fix eyes"
	implements = list(/obj/item/hemostat = 100, TOOL_SCREWDRIVER = 45, /obj/item/pen = 25)
	time = 64

/datum/surgery/eye_surgery/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/eyes/E = target.getorganslot(ORGAN_SLOT_EYES)
	if(!E)
		to_chat(user, "It's hard to do surgery on someone's eyes when [target.p_they()] [target.p_do()]n't have any.")
		return FALSE
	return TRUE

/datum/surgery_step/fix_eyes/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to fix [target]'s eyes.", "<span class='notice'>You begin to fix [target]'s eyes...</span>")

/datum/surgery_step/fix_eyes/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] successfully fixes [target]'s eyes!", "<span class='notice'>You succeed in fixing [target]'s eyes.</span>")
	target.cure_blind(list(EYE_DAMAGE))
	target.set_blindness(0)
	target.cure_nearsighted(list(EYE_DAMAGE))
	target.blur_eyes(35)	//this will fix itself slowly.
	target.set_eye_damage(0)
	return TRUE

/datum/surgery_step/fix_eyes/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.getorgan(/obj/item/organ/brain))
		user.visible_message("<span class='warning'>[user] accidentally stabs [target] right in the brain!</span>", "<span class='warning'>You accidentally stab [target] right in the brain!</span>")
		target.adjustBrainLoss(70)
	else
		user.visible_message("<span class='warning'>[user] accidentally stabs [target] right in the brain! Or would have, if [target] had a brain.</span>", "<span class='warning'>You accidentally stab [target] right in the brain! Or would have, if [target] had a brain.</span>")
	return FALSE