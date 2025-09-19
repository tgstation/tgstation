/datum/surgery/asthmatic_bypass
	name = "Asthmatic Bypass"
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB
	requires_bodypart_type = NONE
	organ_to_manipulate = ORGAN_SLOT_LUNGS
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/expand_windpipe,
		/datum/surgery_step/close,
	)

/datum/surgery/asthmatic_bypass/can_start(mob/user, mob/living/patient)
	. = ..()

	if (!.)
		return

	return (patient.has_quirk(/datum/quirk/item_quirk/asthma))

/datum/surgery_step/expand_windpipe
	name = "force open windpipe (retractor)"
	implements = list(
		TOOL_RETRACTOR = 80,
		TOOL_WIRECUTTER = 45,
	)
	time = 8 SECONDS
	repeatable = TRUE
	preop_sound = 'sound/items/handling/surgery/retractor1.ogg'
	success_sound = 'sound/items/handling/surgery/retractor2.ogg'

	/// The amount of inflammation a failure or success of this surgery will reduce.
	var/inflammation_reduction = 75

/datum/surgery_step/expand_windpipe/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You start to stretch [target]'s windpipe, trying your best to avoid nearby blood vessels..."),
		span_notice("[user] begins to stretch [target]'s windpipe, taking care to avoid any nearby blood vessels."),
		span_notice("[user] begins to stretch [target]'s windpipe."),
	)
	display_pain(target, "You feel an agonizing stretching sensation in your neck!")

/datum/surgery_step/expand_windpipe/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = TRUE)
	if (!reduce_inflammation(user, target, tool, surgery))
		return

	default_display_results = FALSE
	display_results(
		user,
		target,
		span_notice("You stretch [target]'s windpipe with [tool], managing to avoid the nearby blood vessels and arteries."),
		span_notice("[user] succeeds at stretching [target]'s windpipe with [tool], avoiding the nearby blood vessels and arteries."),
		span_notice("[user] finishes stretching [target]'s windpipe.")
	)

	return ..()

/datum/surgery_step/expand_windpipe/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, fail_prob)
	if (!reduce_inflammation(user, target, tool, surgery))
		return

	display_results(
		user,
		target,
		span_bolddanger("You stretch [target]'s windpipe with [tool], but accidentally clip a few arteries!"),
		span_bolddanger("[user] succeeds at stretching [target]'s windpipe with [tool], but accidentally clips a few arteries!"),
		span_bolddanger("[user] finishes stretching [target]'s windpipe, but screws up!")
	)

	target.losebreath++

	if (iscarbon(target))
		var/mob/living/carbon/carbon_patient = target
		var/wound_bonus = tool.wound_bonus
		var/obj/item/bodypart/head/patient_chest = carbon_patient.get_bodypart(BODY_ZONE_CHEST)
		if (patient_chest)
			if (prob(30))
				carbon_patient.cause_wound_of_type_and_severity(WOUND_SLASH, patient_chest, WOUND_SEVERITY_MODERATE, WOUND_SEVERITY_CRITICAL, WOUND_PICK_LOWEST_SEVERITY, tool)
			patient_chest.receive_damage(brute = 10, wound_bonus = wound_bonus, sharpness = SHARP_EDGED, damage_source = tool)

	return FALSE

/// Reduces the asthmatic's inflammation by [inflammation_reduction]. Called by both success and failure.
/datum/surgery_step/expand_windpipe/proc/reduce_inflammation(mob/user, mob/living/target, obj/item/tool, datum/surgery/surgery)
	var/datum/quirk/item_quirk/asthma/asthma_quirk = locate(/datum/quirk/item_quirk/asthma) in target.quirks
	if (isnull(asthma_quirk))
		qdel(surgery) // not really an error cause quirks can get removed during surgery?
		return FALSE

	asthma_quirk.adjust_inflammation(-inflammation_reduction)
	return TRUE
