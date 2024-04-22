/datum/surgery/robot_brain_surgery
	name = "Reset Posibrain Logic (Brain Surgery)"
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/pry_off_plating,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/fix_robot_brain,
		/datum/surgery_step/mechanic_close,
	)

	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_CHEST) // The brains are in the chest
	requires_bodypart_type = BODYTYPE_ROBOTIC
	desc = "A surgical procedure that restores the default behavior logic and personality matrix of an IPC posibrain."

/datum/surgery/robot_brain_surgery/can_start(mob/user, mob/living/carbon/target, obj/item/tool)
	var/obj/item/organ/internal/brain/synth/brain = target.get_organ_slot(ORGAN_SLOT_BRAIN)

	if (!..())
		return FALSE

	if(!istype(brain) && !isipc(target))
		return FALSE
	else
		return TRUE

/datum/surgery_step/fix_robot_brain
	name = "fix posibrain"
	implements = list(
		TOOL_MULTITOOL = 100,
		TOOL_HEMOSTAT = 35,
		/obj/item/pen = 15
	)
	repeatable = TRUE
	time = 12 SECONDS //long and complicated

/datum/surgery_step/fix_robot_brain/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to clear system corruption from [target]'s posibrain..."),
		"[user] begins to fix [target]'s posibrain.",
		"[user] begins to perform surgery on [target]'s posibrain.",
	)

/datum/surgery_step/fix_robot_brain/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user,
		target,
		span_notice("You succeed in clearing system corruption from [target]'s posibrain."),
		"[user] successfully fixes [target]'s posibrain!",
		"[user] completes the surgery on [target]'s posibrain.",
	)

	if(target.mind && target.mind.has_antag_datum(/datum/antagonist/brainwashed))
		target.mind.remove_antag_datum(/datum/antagonist/brainwashed)

	target.setOrganLoss(ORGAN_SLOT_BRAIN, target.get_organ_loss(ORGAN_SLOT_BRAIN) - 60)	//we set damage in this case in order to clear the "failing" flag
	target.cure_all_traumas(TRAUMA_RESILIENCE_LOBOTOMY) //Lobotomy tier fix cause you can't clone this!

	if(target.get_organ_loss(ORGAN_SLOT_BRAIN) > NONE)
		to_chat(user, "[target]'s posibrain still has some lasting system damage that can be cleared.")

	return ..()

/datum/surgery_step/fix_robot_brain/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.get_organ_slot(ORGAN_SLOT_BRAIN))
		display_results(
			user,
			target,
			span_warning("You screw up, fragmenting their data!"),
			span_warning("[user] screws up, causing damage to the circuits!"),
			"[user] completes the surgery on [target]'s posibrain.",
		)

		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60)
		target.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
	else
		user.visible_message(span_warning("[user] suddenly notices that the posibrain [user.p_they()] [user.p_were()] working on is not there anymore."), span_warning("You suddenly notice that the posibrain you were working on is not there anymore."))

	return FALSE
