/**
 * ai control examine; which gives the pawn of the parent the noticable organs depending on AI status!
 *
 * Used for monkeys to have PRIMAL eyes
 */
/datum/element/ai_control_examine
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// These organ slots on the parent's pawn, if filled, will get a special ai-specific examine
	/// Apply the element to ORGAN_SLOT_BRAIN if you don't want it to be hideable behind clothing.
	var/list/noticable_organ_examines

/datum/element/ai_control_examine/Attach(datum/target, noticable_organ_examines = list(ORGAN_SLOT_BRAIN = span_deadsay("doesn't appear to be themself.")))
	. = ..()

	if(!istype(target, /datum/ai_controller))
		return ELEMENT_INCOMPATIBLE
	var/datum/ai_controller/target_controller = target
	src.noticable_organ_examines = noticable_organ_examines
	RegisterSignal(target_controller, COMSIG_AI_CONTROLLER_POSSESSED_PAWN, PROC_REF(on_ai_controller_possessed_pawn))
	RegisterSignal(target_controller, COMSIG_AI_CONTROLLER_UNPOSSESSED_PAWN, PROC_REF(on_ai_controller_unpossessed_pawn))

/datum/element/ai_control_examine/Detach(datum/ai_controller/target_controller)
	. = ..()
	UnregisterSignal(target_controller, list(COMSIG_AI_CONTROLLER_POSSESSED_PAWN, COMSIG_AI_CONTROLLER_UNPOSSESSED_PAWN))
	if(target_controller.pawn && ishuman(target_controller.pawn))
		UnregisterSignal(target_controller.pawn, COMSIG_ORGAN_IMPLANTED)

/// Signal when the ai controller possesses a pawn
/datum/element/ai_control_examine/proc/on_ai_controller_possessed_pawn(datum/ai_controller/source_controller)
	SIGNAL_HANDLER

	if(!ishuman(source_controller.pawn))
		return //not supported
	var/mob/living/carbon/human/human_pawn = source_controller.pawn
	//make current organs noticable
	for(var/organ_slot_key in noticable_organ_examines)
		var/obj/item/organ/found = human_pawn.get_organ_slot(organ_slot_key)
		if(!found)
			continue
		make_organ_noticable(organ_slot_key, found, human_pawn)
	//listen for future insertions (the element removes itself on removal, so we can ignore organ removal)
	RegisterSignal(human_pawn, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_organ_implanted))

/datum/element/ai_control_examine/proc/on_organ_implanted(obj/item/organ/possibly_noticable, mob/living/carbon/receiver)
	SIGNAL_HANDLER
	if(noticable_organ_examines[possibly_noticable.slot])
		make_organ_noticable(possibly_noticable.slot, possibly_noticable)

/datum/element/ai_control_examine/proc/make_organ_noticable(organ_slot, obj/item/organ/noticable_organ, mob/living/carbon/human/human_pawn)
	var/examine_text = noticable_organ_examines[organ_slot]
	var/body_zone = organ_slot != ORGAN_SLOT_BRAIN ? noticable_organ.zone : null
	noticable_organ.AddElement(/datum/element/noticable_organ/ai_control, examine_text, body_zone)

/// Signal when the ai controller stops possessing a pawn, either it's deleted or it got moved to another pawn for some reason
/datum/element/ai_control_examine/proc/on_ai_controller_unpossessed_pawn(datum/ai_controller/source_controller)
	SIGNAL_HANDLER
	if(!ishuman(source_controller.pawn))
		return

	var/mob/living/carbon/human/human_pawn = source_controller.pawn

	for(var/organ_slot_key in noticable_organ_examines)
		var/obj/item/organ/found = human_pawn.get_organ_slot(organ_slot_key)
		if(!found)
			continue
		make_organ_uninteresting(organ_slot_key, found, human_pawn)

	UnregisterSignal(human_pawn, COMSIG_ORGAN_IMPLANTED)

/datum/element/ai_control_examine/proc/make_organ_uninteresting(organ_slot, obj/item/organ/noticable_organ, mob/living/carbon/human/human_pawn)
	var/examine_text = noticable_organ_examines[organ_slot]
	var/body_zone = organ_slot != ORGAN_SLOT_BRAIN ? noticable_organ.zone : null
	noticable_organ.RemoveElement(/datum/element/noticable_organ/ai_control, examine_text, body_zone)
