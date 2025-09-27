/datum/surgery/autopsy
	name = "Autopsy"
	surgery_flags = SURGERY_IGNORE_CLOTHES | SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB | SURGERY_MORBID_CURIOSITY
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/autopsy,
		/datum/surgery_step/close,
	)

/datum/surgery/autopsy/mechanic
	name = "System Failure Analysis"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/autopsy,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery/autopsy/can_start(mob/user, mob/living/patient)
	if(!..())
		return FALSE
	if(patient.stat != DEAD)
		return FALSE
	if(HAS_TRAIT_FROM(patient, TRAIT_DISSECTED, AUTOPSY_TRAIT))
		return FALSE
	return TRUE

/datum/surgery_step/autopsy
	name = "Perform Autopsy (autopsy scanner)"
	implements = list(/obj/item/autopsy_scanner = 100)
	time = 10 SECONDS
	success_sound = 'sound/machines/printer.ogg'

/datum/surgery_step/autopsy/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin performing an autopsy on [target]..."),
		span_notice("[user] uses [tool] to perform an autopsy on [target]."),
		span_notice("[user] uses [tool] on [target]'s chest."),
	)
	display_pain(target, "You feel a burning sensation in your chest!")

/datum/surgery_step/autopsy/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/autopsy_scanner/tool, datum/surgery/surgery, default_display_results = FALSE)
	ADD_TRAIT(target, TRAIT_DISSECTED, AUTOPSY_TRAIT)
	ADD_TRAIT(target, TRAIT_SURGICALLY_ANALYZED, AUTOPSY_TRAIT)
	tool.scan_cadaver(user, target)
	var/obj/machinery/computer/operating/operating_computer = surgery.locate_operating_computer(get_turf(target))
	if (!isnull(operating_computer))
		SEND_SIGNAL(operating_computer, COMSIG_OPERATING_COMPUTER_AUTOPSY_COMPLETE, target)
	if(HAS_MIND_TRAIT(user, TRAIT_MORBID))
		user.add_mood_event("morbid_dissection_success", /datum/mood_event/morbid_dissection_success)
	return ..()

/datum/surgery_step/autopsy/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_warning("You screw up, bruising [target]'s chest!"),
		span_warning("[user] screws up, brusing [target]'s chest!"),
		span_warning("[user] screws up!"),
	)
	target.adjustBruteLoss(5)
