#define OPERATION_OBJECTIVE "objective"

/datum/surgery_operation/organ/brainwash
	name = "brainwash"
	desc = "Implant a directive into the patient's brain, making it their absolute priority."
	rnd_name = "Neural Brainwashing (Brainwash)"
	rnd_desc = "A surgical procedure which directly implants a directive into the patient's brain, \
		making it their absolute priority. It can be cleared using a mindshield implant."
	implements = list(
		TOOL_HEMOSTAT = 1.15,
		TOOL_WIRECUTTER = 2,
		/obj/item/stack/package_wrap = 2.85,
		/obj/item/stack/cable_coil = 6.67,
	)
	time = 20 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	success_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	operation_flags = OPERATION_MORBID | OPERATION_NOTABLE | OPERATION_LOCKED
	target_type = /obj/item/organ/brain
	required_organ_flag = ORGAN_TYPE_FLAGS & ~ORGAN_ROBOTIC
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|SURGERY_BONE_SAWED

/datum/surgery_operation/organ/brainwash/get_default_radial_image()
	return image(/atom/movable/screen/alert/hypnosis::overlay_icon, /atom/movable/screen/alert/hypnosis::overlay_state)

/datum/surgery_operation/organ/brainwash/pre_preop(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	operation_args[OPERATION_OBJECTIVE] = tgui_input_text(surgeon, "Choose the objective to imprint on your patient's brain", "Brainwashing", max_length = MAX_MESSAGE_LEN)
	return !!operation_args[OPERATION_OBJECTIVE]

/datum/surgery_operation/organ/brainwash/on_preop(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("You begin to brainwash [organ.owner]..."),
		span_notice("[surgeon] begins to fix [organ.owner]'s brain."),
		span_notice("[surgeon] begins to perform surgery on [organ.owner]'s brain."),
	)
	display_pain(organ.owner, "Your head pounds with unimaginable pain!") // Same message as other brain surgeries

/datum/surgery_operation/organ/brainwash/on_success(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	if(!organ.owner.mind)
		to_chat(surgeon, span_warning("[organ.owner] doesn't respond to the brainwashing, as if [organ.owner.p_they()] lacked a mind..."))
		return ..()
	if(HAS_MIND_TRAIT(organ.owner, TRAIT_UNCONVERTABLE))
		to_chat(surgeon, span_warning("[organ.owner] seems resistant to the brainwashing..."))
		return ..()

	display_results(
		surgeon,
		organ.owner,
		span_notice("You successfully brainwash [organ.owner]!"),
		span_notice("[surgeon] successfully brainwashes [organ.owner]!"),
		span_notice("[surgeon] finishes performing surgery on [organ.owner]'s brain."),
	)
	on_brainwash(organ.owner, surgeon, tool, operation_args)

/datum/surgery_operation/organ/brainwash/proc/on_brainwash(mob/living/carbon/brainwashed, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/objective = operation_args[OPERATION_OBJECTIVE] || "Oooo no objective set somehow report this to an admin"
	to_chat(brainwashed, span_notice("A new thought forms in your mind: '[objective]'"))
	brainwash(brainwashed, objective)
	message_admins("[ADMIN_LOOKUPFLW(surgeon)] surgically brainwashed [ADMIN_LOOKUPFLW(brainwashed)] with the objective '[objective]'.")
	surgeon.log_message("has brainwashed [key_name(brainwashed)] with the objective '[objective]' using brainwashing surgery.", LOG_ATTACK)
	brainwashed.log_message("has been brainwashed with the objective '[objective]' by [key_name(surgeon)] using brainwashing surgery.", LOG_VICTIM, log_globally=FALSE)
	surgeon.log_message("surgically brainwashed [key_name(brainwashed)] with the objective '[objective]'.", LOG_GAME)

/datum/surgery_operation/organ/brainwash/on_failure(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("You screw up, bruising the brain's tissue!"),
		span_notice("[surgeon] screws up, causing brain damage!"),
		span_notice("[surgeon] completes the surgery on [organ.owner]'s brain."),
	)
	display_pain(organ.owner, "Your head throbs with horrible pain!")
	organ.owner.adjust_organ_loss(ORGAN_SLOT_BRAIN, 40)

/datum/surgery_operation/organ/brainwash/mechanic
	name = "reprogram"
	rnd_name = "Neural Reprogramming (Brainwash)"
	rnd_desc = "Install malware which directly implants a directive into the robotic patient's operating system, \
		making it their absolute priority. It can be cleared using a mindshield implant."
	implements = list(
		TOOL_MULTITOOL = 1.15,
		TOOL_HEMOSTAT = 2,
		TOOL_WIRECUTTER = 2,
		/obj/item/stack/package_wrap = 2.85,
		/obj/item/stack/cable_coil = 6.67,
	)
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'
	required_organ_flag = ORGAN_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/organ/brainwash/sleeper
	name = "install sleeper agent directive"
	rnd_name = "Sleeper Agent Implantation (Brainwash)"
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

/datum/surgery_operation/organ/brainwash/sleeper/pre_preop(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	operation_args[OPERATION_OBJECTIVE] = pick(possible_objectives)
	return TRUE

/datum/surgery_operation/organ/brainwash/sleeper/on_preop(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("You begin to brainwash [organ.owner]..."),
		span_notice("[surgeon] begins to fix [organ.owner]'s brain."),
		span_notice("[surgeon] begins to perform surgery on [organ.owner]'s brain."),
	)
	display_pain(organ.owner, "Your head pounds with unimaginable pain!") // Same message as other brain surgeries

/datum/surgery_operation/organ/brainwash/sleeper/on_brainwash(mob/living/carbon/brainwashed, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	brainwashed.gain_trauma(new /datum/brain_trauma/mild/phobia/conspiracies(), TRAUMA_RESILIENCE_LOBOTOMY)

/datum/surgery_operation/organ/brainwash/sleeper/mechanic
	name = "install sleeper agent programming"
	rnd_name = "Sleeper Agent Programming (Brainwash)"
	implements = list(
		TOOL_MULTITOOL = 1.15,
		TOOL_HEMOSTAT = 2,
		TOOL_WIRECUTTER = 2,
		/obj/item/stack/package_wrap = 2.85,
		/obj/item/stack/cable_coil = 6.67,
	)
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'
	required_organ_flag = ORGAN_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

#undef OPERATION_OBJECTIVE
