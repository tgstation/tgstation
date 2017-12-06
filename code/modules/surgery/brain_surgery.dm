/datum/surgery/brain_surgery
	name = "brain surgery"
	steps = list(
	/datum/surgery_step/incise,
	/datum/surgery_step/retract_skin,
	/datum/surgery_step/saw,
	/datum/surgery_step/clamp_bleeders,
	/datum/surgery_step/fix_brain,
	/datum/surgery_step/close)

	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list("head")
	requires_bodypart_type = 0

/datum/surgery_step/fix_brain
	name = "fix brain"
	implements = list(/obj/item/hemostat = 85, /obj/item/screwdriver = 35, /obj/item/pen = 15) //don't worry, pouring some alcohol on their open brain will get that chance to 100
	time = 120 //long and complicated

/datum/surgery/brain_surgery/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/brain/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!B)
		to_chat(user, "<span class='warning'>It's hard to do surgery on someone's brain when they don't have one.</span>")
		return FALSE
	return TRUE

/datum/surgery_step/fix_brain/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to fix [target]'s brain.", "<span class='notice'>You begin to fix [target]'s brain...</span>")

/datum/surgery_step/fix_brain/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] successfully fixes [target]'s brain!", "<span class='notice'>You succeed in fixing [target]'s brain.</span>")
	target.adjustBrainLoss(-60)
	target.cure_all_traumas()
	return TRUE

/datum/surgery_step/fix_brain/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.getorganslot(ORGAN_SLOT_BRAIN))
		user.visible_message("<span class='warning'>[user] screws up, causing more damage!</span>", "<span class='warning'>You screw up, causing more damage!</span>")
		target.adjustBrainLoss(80)
	else
		user.visible_message("<span class='warning'>[user] suddenly notices that the brain [user.p_they()] [user.p_were()] working on is not there anymore.", "<span class='warning'>You suddenly notice that the brain you were working on is not there anymore.</span>")
	return FALSE