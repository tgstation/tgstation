/obj/item/disk/surgery/brainwashing
	name = "Brainwashing Surgery Disk"
	desc = "The disk provides instructions on how to impress an order on a brain, making it the primary objective of the patient."
	// surgeries = list(
	// 	/datum/surgery/advanced/brainwashing,
	// 	/datum/surgery/advanced/brainwashing/mechanic,
	// )

/obj/item/disk/surgery/sleeper_protocol
	name = "Suspicious Surgery Disk"
	desc = "The disk provides instructions on how to turn someone into a sleeper agent for the Syndicate."
	// surgeries = list(
	// 	/datum/surgery/advanced/brainwashing_sleeper,
	// 	/datum/surgery/advanced/brainwashing_sleeper/mechanic,
	// )

/datum/surgery_operation/limb/brainwash
	name = "brainwash"
	implements = list(
		TOOL_HEMOSTAT = 0.85,
		TOOL_WIRECUTTER = 0.50,
		/obj/item/stack/package_wrap = 0.35,
		/obj/item/stack/cable_coil = 0.15,
	)
	time = 20 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	success_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	operation_flags = OPERATION_MORBID

/datum/surgery_operation/limb/brainwash/state_check(obj/item/bodypart/limb)
	var/obj/item/organ/brain/target_brain = locate() in limb
	if(isnull(target_brain))
		return FALSE
	if(!brain_check(target_brain))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/brainwash/brain_check(obj/item/organ/brain/brain)
	return !IS_ROBOTIC_ORGAN(brain)

/datum/surgery_operation/limb/brainwash/pre_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/pre_owner = limb.owner
	operation_args["objective"] = tgui_input_text(surgeon, "Choose the objective to imprint on your patient's brain", "Brainwashing", max_length = MAX_MESSAGE_LEN)
	return !!operation_args["objective"]

/datum/surgery_operation/limb/brainwash/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to brainwash [limb.owner]..."),
		span_notice("[surgeon] begins to fix [limb.owner]'s brain."),
		span_notice("[surgeon] begins to perform surgery on [limb.owner]'s brain."),
	)
	display_pain(limb.owner, "Your head pounds with unimaginable pain!") // Same message as other brain surgeries

/datum/surgery_operation/limb/brainwash/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	if(!limb.owner.mind)
		to_chat(surgeon, span_warning("[limb.owner] doesn't respond to the brainwashing, as if [limb.owner.p_they()] lacked a mind..."))
		return ..()
	if(HAS_MIND_TRAIT(limb.owner, TRAIT_UNCONVERTABLE))
		to_chat(surgeon, span_warning("[limb.owner] seems resistant to the brainwashing..."))
		return ..()

	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully brainwash [limb.owner]!"),
		span_notice("[surgeon] successfully brainwashes [limb.owner]!"),
		span_notice("[surgeon] finishes performing surgery on [limb.owner]'s brain."),
	)
	on_brainwash(limb, surgeon, tool, operation_args)

/datum/surgery_operation/limb/brainwash/proc/on_brainwash(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/objective = operation_args["objective"] || "Oooo no objective set somehow report this to an admin"
	to_chat(limb.owner, span_notice("A new thought forms in your mind: '[objective]'"))
	brainwash(limb.owner, objective)
	message_admins("[ADMIN_LOOKUPFLW(surgeon)] surgically brainwashed [ADMIN_LOOKUPFLW(limb.owner)] with the objective '[objective]'.")
	surgeon.log_message("has brainwashed [key_name(limb.owner)] with the objective '[objective]' using brainwashing surgery.", LOG_ATTACK)
	limb.owner.log_message("has been brainwashed with the objective '[objective]' by [key_name(surgeon)] using brainwashing surgery.", LOG_VICTIM, log_globally=FALSE)
	surgeon.log_message("surgically brainwashed [key_name(limb.owner)] with the objective '[objective]'.", LOG_GAME)

/datum/surgery_operation/limb/brainwash/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args, total_penalty_modifier)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You screw up, bruising the brain's tissue!"),
		span_notice("[surgeon] screws up, causing brain damage!"),
		span_notice("[surgeon] completes the surgery on [limb.owner]'s brain."),
	)
	display_pain(limb.owner, "Your head throbs with horrible pain!")
	limb.owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 40)

/datum/surgery_operation/limb/brainwash/mechanic
	name = "reprogram"
	implements = list(
		TOOL_MULTITOOL = 0.85,
		TOOL_HEMOSTAT = 0.50,
		TOOL_WIRECUTTER = 0.50,
		/obj/item/stack/package_wrap = 0.35,
		/obj/item/stack/cable_coil = 0.15,
	)
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'

/datum/surgery_operation/limb/brainwash/mechanic/brain_check(obj/item/organ/brain/brain)
	return IS_ROBOTIC_ORGAN(brain)

/datum/surgery_operation/limb/brainwash/sleeper
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	success_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'

	var/list/possible_objectives = list(
		"You love the Syndicate.",
		"Do not trust Nanotrasen.",
		"The Captain is a lizardperson.",
		"Nanotrasen isn't real.",
		"They put something in the food to make you forget.",
		"You are the only real person on the station.",
		"Things would be a lot better on the station if more people were screaming, someone should do something about that.",
		"The people in charge around here have only ill intentions for the crew.",
		"Help the crew? What have they ever done for you anyways?",
		"Does your bag feel lighter? I bet those guys in Security stole something from it. Go get it back.",
		"Command is incompetent, someone with some REAL authority should take over around here.",
		"The cyborgs and the AI are stalking you. What are they planning?",
	)

/datum/surgery_operation/limb/brainwash/sleeper/pre_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	operation_args["objective"] = pick(possible_objectives)
	return TRUE

/datum/surgery_operation/limb/brainwash/sleeper/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to brainwash [limb.owner]..."),
		span_notice("[surgeon] begins to fix [limb.owner]'s brain."),
		span_notice("[surgeon] begins to perform surgery on [limb.owner]'s brain."),
	)
	display_pain(limb.owner, "Your head pounds with unimaginable pain!") // Same message as other brain surgeries

/datum/surgery_operation/limb/brainwash/sleeper/on_brainwash(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.owner.gain_trauma(new /datum/brain_trauma/mild/phobia/conspiracies(), TRAUMA_RESILIENCE_LOBOTOMY)

/datum/surgery_operation/limb/brainwash/sleeper/mechanic
	name = "reprogramming"
	implements = list(
		TOOL_MULTITOOL = 0.85,
		TOOL_HEMOSTAT = 0.50,
		TOOL_WIRECUTTER = 0.50,
		/obj/item/stack/package_wrap = 0.35,
		/obj/item/stack/cable_coil = 0.15,
	)
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'

/datum/surgery_operation/limb/brainwash/sleeper/mechanic/brain_check(obj/item/organ/brain/brain)
	return IS_ROBOTIC_ORGAN(brain)
