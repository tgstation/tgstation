/obj/item/disk/surgery/brainwashing
	name = "Brainwashing Surgery Disk"
	desc = "The disk provides instructions on how to impress an order on a brain, making it the primary objective of the patient."
	surgeries = list(/datum/surgery/advanced/brainwashing)

/datum/surgery/advanced/brainwashing
	name = "Brainwashing"
	desc = "A surgical procedure which directly implants a directive into the patient's brain, making it their absolute priority. It can be cleared using a mindshield implant."
	steps = list(
	/datum/surgery_step/incise,
	/datum/surgery_step/retract_skin,
	/datum/surgery_step/saw,
	/datum/surgery_step/clamp_bleeders,
	/datum/surgery_step/brainwash,
	/datum/surgery_step/close)

	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_HEAD)

/datum/surgery/advanced/brainwashing/can_start(mob/user, mob/living/carbon/target)
	if(!..())
		return FALSE
	var/obj/item/organ/brain/target_brain = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!target_brain)
		return FALSE
	return TRUE

/datum/surgery_step/brainwash
	name = "brainwash"
	implements = list(
		TOOL_HEMOSTAT = 85,
		TOOL_WIRECUTTER = 50,
		/obj/item/stack/package_wrap = 35,
		/obj/item/stack/cable_coil = 15)
	time = 200
	var/objective

/datum/surgery_step/brainwash/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	objective = tgui_input_text(user, "Choose the objective to imprint on your victim's brain", "Brainwashing")
	if(!objective)
		return -1
	display_results(user, target, span_notice("You begin to brainwash [target]..."),
		span_notice("[user] begins to fix [target]'s brain."),
		span_notice("[user] begins to perform surgery on [target]'s brain."))
	display_pain(target, "Your head pounds with unimaginable pain!") // Same message as other brain surgeries

/datum/surgery_step/brainwash/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(!target.mind)
		to_chat(user, span_warning("[target] doesn't respond to the brainwashing, as if [target.p_they()] lacked a mind..."))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		to_chat(user, span_warning("You hear a faint buzzing from a device inside [target]'s brain, and the brainwashing is erased."))
		return FALSE
	display_results(user, target, span_notice("You succeed in brainwashing [target]."),
		span_notice("[user] successfully fixes [target]'s brain!"),
		span_notice("[user] completes the surgery on [target]'s brain."))
	to_chat(target, span_userdanger("A new compulsion fills your mind... you feel forced to obey it!"))
	brainwash(target, objective)
	message_admins("[ADMIN_LOOKUPFLW(user)] surgically brainwashed [ADMIN_LOOKUPFLW(target)] with the objective '[objective]'.")
	user.log_message("has brainwashed [key_name(target)] with the objective '[objective]' using brainwashing surgery.", LOG_ATTACK)
	target.log_message("has been brainwashed with the objective '[objective]' by [key_name(user)] using brainwashing surgery.", LOG_VICTIM, log_globally=FALSE)
	log_game("[key_name(user)] surgically brainwashed [key_name(target)] with the objective '[objective]'.")
	return ..()

/datum/surgery_step/brainwash/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.getorganslot(ORGAN_SLOT_BRAIN))
		display_results(user, target, span_warning("You screw up, bruising the brain tissue!"),
			span_warning("[user] screws up, causing brain damage!"),
			span_notice("[user] completes the surgery on [target]'s brain."))
		display_pain(target, "Your head throbs with horrible pain!")
		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 40)
	else
		user.visible_message(span_warning("[user] suddenly notices that the brain [user.p_they()] [user.p_were()] working on is not there anymore."), span_warning("You suddenly notice that the brain you were working on is not there anymore."))
	return FALSE
