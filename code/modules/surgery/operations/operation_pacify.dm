/datum/surgery_operation/organ/pacify
	name = "pacification"
	desc = "Remove aggressive tendencies from a patient's brain."
	rnd_desc = "A surgical procedure which permanently inhibits the aggression center of the brain, making the patient unwilling to cause direct harm."
	operation_flags = OPERATION_MORBID | OPERATION_LOCKED
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_SCREWDRIVER = 2.85,
		/obj/item/pen = 6.67,
	)
	time = 4 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	success_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	required_organ_flag = ~ORGAN_ROBOTIC
	target_type = /obj/item/organ/brain

/datum/surgery_operation/organ/pacify/get_default_radial_image()
	return image(/atom/movable/screen/alert/status_effect/high)

/datum/surgery_operation/organ/pacify/state_check(obj/item/organ/brain/organ)
	return LIMB_HAS_SURGERY_STATE(organ.bodypart_owner, SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED|SURGERY_BONE_SAWED)

/datum/surgery_operation/organ/pacify/on_preop(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("You begin to pacify [organ.owner]..."),
		span_notice("[surgeon] begins to fix [organ.owner]'s brain."),
		span_notice("[surgeon] begins to perform surgery on [organ.owner]'s brain."),
	)
	display_pain(organ.owner, "Your head pounds with unimaginable pain!")

/datum/surgery_operation/organ/pacify/on_success(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("You succeed in pacifying [organ.owner]."),
		span_notice("[surgeon] successfully fixes [organ.owner]!"),
		span_notice("[surgeon] completes the surgery on [organ.owner]'s brain."),
	)
	display_pain(organ.owner, "Your head pounds... the concept of violence flashes in your head, and nearly makes you hurl!")
	organ.gain_trauma(/datum/brain_trauma/severe/pacifism, TRAUMA_RESILIENCE_LOBOTOMY)

/datum/surgery_operation/organ/pacify/on_failure(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("You screw up, rewiring [organ.owner]'s brain the wrong way around..."),
		span_warning("[surgeon] screws up, causing brain damage!"),
		span_notice("[surgeon] completes the surgery on [organ.owner]'s brain."),
	)
	display_pain(organ.owner, "Your head pounds, and it feels like it's getting worse!")
	organ.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)

/datum/surgery_operation/organ/pacify/mechanic
	name = "delete aggression programming"
	rnd_name = "Aggression Suppression Programming"
	rnd_desc = "Install malware which permanently inhibits the aggression programming of the patient's neural network, making the patient unwilling to cause direct harm."
	implements = list(
		TOOL_MULTITOOL = 1,
		TOOL_HEMOSTAT = 2.85,
		TOOL_SCREWDRIVER = 2.85,
		/obj/item/pen = 6.67,
	)
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'
	failure_sound = null
	required_organ_flag = ORGAN_ROBOTIC
