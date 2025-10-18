/datum/surgery_operation/autopsy
	name = "Autopsy"
	desc = "Perform a detailed analysis of a deceased patient's body."
	implements = list(/obj/item/autopsy_scanner = 1)
	time = 10 SECONDS
	success_sound = 'sound/machines/printer.ogg'
	required_bodytype = BODYTYPE_ORGANIC

/datum/surgery_operation/autopsy/state_check(obj/item/bodypart/limb)
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	return TRUE

/datum/surgery_operation/autopsy/is_available(obj/item/bodypart/limb)
	if(limb.owner.stat != DEAD)
		return FALSE
	if(HAS_TRAIT_FROM(limb.owner, TRAIT_DISSECTED, AUTOPSY_TRAIT))
		return FALSE
	if(limb.body_zone != BODY_ZONE_CHEST)
		return FALSE
	return TRUE

/datum/surgery_operation/autopsy/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin performing an autopsy on [limb.owner]..."),
		span_notice("[surgeon] uses [tool] to perform an autopsy on [limb.owner]."),
		span_notice("[surgeon] uses [tool] on [limb.owner]'s chest."),
	)
	display_pain(limb.owner, "You feel a burning sensation in your chest!")

/datum/surgery_operation/autopsy/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	ADD_TRAIT(limb.owner, TRAIT_DISSECTED, AUTOPSY_TRAIT)
	ADD_TRAIT(limb.owner, TRAIT_SURGICALLY_ANALYZED, AUTOPSY_TRAIT)
	tool.scan_cadaver(surgeon, limb.owner)
	var/obj/machinery/computer/operating/operating_computer = locate_operating_computer(get_turf(limb.owner))
	if (!isnull(operating_computer))
		SEND_SIGNAL(operating_computer, COMSIG_OPERATING_COMPUTER_AUTOPSY_COMPLETE, limb.owner)
	if(HAS_MIND_TRAIT(surgeon, TRAIT_MORBID))
		surgeon.add_mood_event("morbid_dissection_success", /datum/mood_event/morbid_dissection_success)
	return ..()

/datum/surgery_operation/autopsy/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args, total_penalty_modifier)
	display_results(
		surgeon,
		limb.owner,
		span_warning("You screw up, bruising [limb.owner]'s chest!"),
		span_warning("[surgeon] screws up, brusing [limb.owner]'s chest!"),
		span_warning("[surgeon] screws up!"),
	)
	limb.receive_damage(5, wound_bonus = CANT_WOUND, damage_source = tool)

/datum/surgery_operation/autopsy/mechanic
	name = "system failure analysis"
	required_bodytype = BODYTYPE_ROBOTIC
