/datum/surgery/advanced/bioware/muscled_veins
	name = "Vein Muscle Membrane"
	desc = "A surgical procedure which adds a muscled membrane to blood vessels, allowing them to pump blood without a heart."
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/incise,
		/datum/surgery_step/apply_bioware/muscled_veins,
		/datum/surgery_step/close,
	)

	status_effect_gained = /datum/status_effect/bioware/heart/muscled_veins

/datum/surgery_step/apply_bioware/muscled_veins
	name = "shape vein muscles (hand)"

/datum/surgery_step/apply_bioware/muscled_veins/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You start wrapping muscles around [target]'s circulatory system."),
		span_notice("[user] starts wrapping muscles around [target]'s circulatory system."),
		span_notice("[user] starts manipulating [target]'s circulatory system."),
	)
	display_pain(target, "Your entire body burns in agony!")

/datum/surgery_step/apply_bioware/muscled_veins/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	. = ..()
	if(!.)
		return

	display_results(
		user,
		target,
		span_notice("You reshape [target]'s circulatory system, adding a muscled membrane!"),
		span_notice("[user] reshapes [target]'s circulatory system, adding a muscled membrane!"),
		span_notice("[user] finishes manipulating [target]'s circulatory system."),
	)
	display_pain(target, "You can feel your heartbeat's powerful pulses ripple through your body!")
