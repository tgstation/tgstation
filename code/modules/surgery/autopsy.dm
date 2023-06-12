/datum/surgery/autopsy
	name = "Autopsy"
	surgery_flags = SURGERY_IGNORE_CLOTHES | SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/autopsy,
		/datum/surgery_step/close,
	)

/datum/surgery/autopsy/can_start(mob/user, mob/living/patient)
	. = ..()
	if(patient.stat != DEAD)
		return FALSE
	if(HAS_TRAIT(patient, TRAIT_DISSECTED))
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
		span_notice("You begins performing an autopsy on [target]..."),
		span_notice("[user] uses [tool] to perform an autopsy on [target]."),
		span_notice("[user] uses [tool] on [target]'s chest."),
	)
	display_pain(target, "You feel a burning sensation in your chest!")

/datum/surgery_step/autopsy/success(mob/user, mob/living/carbon/target, target_zone, obj/item/autopsy_scanner/tool, datum/surgery/surgery, default_display_results = FALSE)
	ADD_TRAIT(target, TRAIT_DISSECTED, REF(src))
	tool.scan_cadaver(user, target)
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
