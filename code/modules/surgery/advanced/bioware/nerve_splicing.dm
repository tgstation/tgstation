/datum/surgery/advanced/bioware/nerve_splicing
	name = "Nerve Splicing"
	desc = "A surgical procedure which splices the patient's nerves, making them more resistant to stuns."
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/incise,
		/datum/surgery_step/apply_bioware/splice_nerves,
		/datum/surgery_step/close,
	)

	status_effect_gained = /datum/status_effect/bioware/nerves/spliced

/datum/surgery/advanced/bioware/nerve_splicing/mechanic
	name = "System Automatic Reset Subroutine"
	desc = "A robotic upgrade which upgrades a robotic patient's automatic systems, making them more resistant to stuns."
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/apply_bioware/splice_nerves,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery_step/apply_bioware/splice_nerves
	name = "splice nerves (hand)"
	time = 15.5 SECONDS

/datum/surgery_step/apply_bioware/splice_nerves/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You start splicing together [target]'s nerves."),
		span_notice("[user] starts splicing together [target]'s nerves."),
		span_notice("[user] starts manipulating [target]'s nervous system."),
	)
	display_pain(target, "Your entire body goes numb!")

/datum/surgery_step/apply_bioware/splice_nerves/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	. = ..()
	if(!.)
		return

	display_results(
		user,
		target,
		span_notice("You successfully splice [target]'s nervous system!"),
		span_notice("[user] successfully splices [target]'s nervous system!"),
		span_notice("[user] finishes manipulating [target]'s nervous system."),
	)
	display_pain(target, "You regain feeling in your body; It feels like everything's happening around you in slow motion!")
