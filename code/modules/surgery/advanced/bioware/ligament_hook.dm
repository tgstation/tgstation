/datum/surgery/advanced/bioware/ligament_hook
	name = "Ligament Hook"
	desc = "A surgical procedure which reshapes the connections between torso and limbs, making it so limbs can be attached manually if severed. \
		However this weakens the connection, making them easier to detach as well."
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/incise,
		/datum/surgery_step/apply_bioware/reshape_ligaments,
		/datum/surgery_step/close,
	)

	status_effect_gained = /datum/status_effect/bioware/ligaments/hooked

/datum/surgery_step/apply_bioware/reshape_ligaments
	name = "reshape ligaments (hand)"

/datum/surgery_step/apply_bioware/reshape_ligaments/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You start reshaping [target]'s ligaments into a hook-like shape."),
		span_notice("[user] starts reshaping [target]'s ligaments into a hook-like shape."),
		span_notice("[user] starts manipulating [target]'s ligaments."),
	)
	display_pain(target, "Your limbs burn with severe pain!")

/datum/surgery_step/apply_bioware/reshape_ligaments/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	. = ..()
	if(!.)
		return

	display_results(
		user,
		target,
		span_notice("You reshape [target]'s ligaments into a connective hook!"),
		span_notice("[user] reshapes [target]'s ligaments into a connective hook!"),
		span_notice("[user] finishes manipulating [target]'s ligaments."),
	)
	display_pain(target, "Your limbs feel... strangely loose.")
