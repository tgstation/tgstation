/datum/surgery/advanced/bioware/vein_threading
	name = "Vein Threading"
	desc = "A surgical procedure which severely reduces the amount of blood lost in case of injury."
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/incise,
		/datum/surgery_step/apply_bioware/thread_veins,
		/datum/surgery_step/close,
	)

	status_effect_gained = /datum/status_effect/bioware/heart/threaded_veins

/datum/surgery_step/apply_bioware/thread_veins
	name = "thread veins (hand)"

/datum/surgery_step/apply_bioware/thread_veins/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You start weaving [target]'s circulatory system."),
		span_notice("[user] starts weaving [target]'s circulatory system."),
		span_notice("[user] starts manipulating [target]'s circulatory system."),
	)
	display_pain(target, "Your entire body burns in agony!")

/datum/surgery_step/apply_bioware/thread_veins/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	. = ..()
	if(!.)
		return

	display_results(
		user,
		target,
		span_notice("You weave [target]'s circulatory system into a resistant mesh!"),
		span_notice("[user] weaves [target]'s circulatory system into a resistant mesh!"),
		span_notice("[user] finishes manipulating [target]'s circulatory system."),
	)
	display_pain(target, "You can feel your blood pumping through reinforced veins!")
