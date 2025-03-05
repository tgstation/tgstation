/datum/surgery/advanced/bioware/cortex_imprint
	name = "Cortex Imprint"
	desc = "A surgical procedure which modifies the cerebral cortex into a redundant neural pattern, making the brain able to bypass impediments caused by minor brain traumas."
	possible_locs = list(BODY_ZONE_HEAD)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/incise,
		/datum/surgery_step/apply_bioware/imprint_cortex,
		/datum/surgery_step/close,
	)

	status_effect_gained = /datum/status_effect/bioware/cortex/imprinted

/datum/surgery/advanced/bioware/cortex_imprint/mechanic
	name = "Wetware OS Ver 2.0"
	desc = "A robotic upgrade which updates the patient's operating system to the 'latest version', whatever that means, making the brain able to bypass damage caused by minor brain traumas. \
		Shame about all the adware."
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/apply_bioware/imprint_cortex,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery/advanced/bioware/cortex_imprint/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/brain/target_brain = target.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(!target_brain)
		return FALSE
	return ..()

/datum/surgery_step/apply_bioware/imprint_cortex
	name = "imprint cortex (hand)"

/datum/surgery_step/apply_bioware/imprint_cortex/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You start carving [target]'s outer cerebral cortex into a self-imprinting pattern."),
		span_notice("[user] starts carving [target]'s outer cerebral cortex into a self-imprinting pattern."),
		span_notice("[user] begins to perform surgery on [target]'s brain."),
	)
	display_pain(target, "Your head throbs with gruesome pain, it's nearly too much to handle!")

/datum/surgery_step/apply_bioware/imprint_cortex/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	. = ..()
	if(!.)
		return

	display_results(
		user,
		target,
		span_notice("You reshape [target]'s outer cerebral cortex into a self-imprinting pattern!"),
		span_notice("[user] reshapes [target]'s outer cerebral cortex into a self-imprinting pattern!"),
		span_notice("[user] completes the surgery on [target]'s brain."),
	)
	display_pain(target, "Your brain feels stronger... more resillient!")

/datum/surgery_step/apply_bioware/imprint_cortex/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.get_organ_slot(ORGAN_SLOT_BRAIN))
		display_results(
			user,
			target,
			span_warning("You screw up, damaging the brain!"),
			span_warning("[user] screws up, damaging the brain!"),
			span_notice("[user] completes the surgery on [target]'s brain."),
		)
		display_pain(target, "Your brain throbs with intense pain; Thinking hurts!")
		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60)
		target.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
	else
		user.visible_message(span_warning("[user] suddenly notices that the brain [user.p_they()] [user.p_were()] working on is not there anymore."), span_warning("You suddenly notice that the brain you were working on is not there anymore."))
	return FALSE
