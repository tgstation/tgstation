/datum/surgery/asthmatic_bypass
	name = "Asthmatic Bypass"
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB
	requires_bodypart_type = NONE
	organ_to_manipulate = ORGAN_SLOT_LUNGS
	possible_locs = list(BODY_ZONE_HEAD)
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

	var/mob/living/carbon/human/human_patient = patient
	return (human_patient.has_quirk(/datum/quirk/item_quirk/asthma))

/datum/surgery_step/expand_windpipe
	name = "force open windpipe (retractor)"
	implements = list(
		TOOL_RETRACTOR = 80,
		TOOL_WIRECUTTER = 45
		)
	time = 8 SECONDS
	repeatable = TRUE
	preop_sound = 'sound/surgery/retractor1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'

	var/inflammation_reduction = 75

/datum/surgery_step/expand_windpipe/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You start to stretch [target]'s windpipe, trying your best to avoid nearby blood vessels..."),
		span_notice("[user] begins to stretch [target]'s windpipe, taking care to avoid any nearby blood vessels."),
		span_notice("[user] begins to stretch [target]'s windpipe."),
	)
	display_pain(target, "You feel a strange stretching sensation in your neck!")

/datum/surgery_step/expand_windpipe/finish

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

	var/mob/living/carbon/human/human_patient = target
	human_patient.losebreath += 2

	display_results(
		user,
		target,
		span_bolddanger("You stretch [target]'s windpipe with [tool], but acidentally clip a few arteries, causing blood to pour out!"),
		span_bolddanger("[user] succeeds at stretching [target]'s windpipe with [tool], but acidentally clips a few arteries, causing blood to pour out!"),
		span_bolddanger("[user] finishes stretching [target]'s windpipe, but screws up!")
	)
	var/wound_bonus = tool.wound_bonus
	var/obj/item/bodypart/head/patient_head = human_patient.get_bodypart(HEAD)
	if (prob(30))
		if (patient_head)
			wound_bonus += patient_head.get_wound_threshold_of_wound_type(WOUND_SLASH, WOUND_SEVERITY_MODERATE, 0, tool)
	patient_head.receive_damage(10, BRUTE, wound_bonus = wound_bonus, damage_source = tool)

	return FALSE

/datum/surgery_step/expand_windpipe/proc/reduce_inflammation(mob/user, mob/living/target, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/human_patient = target
	var/datum/quirk/item_quirk/asthma/asthma_quirk = locate(/datum/quirk/item_quirk/asthma) in human_patient.quirks
	if (isnull(asthma_quirk))
		qdel(surgery) // not really an error cause quirks can get removed during surgery?
		return FALSE

	asthma_quirk.adjust_inflammation(-inflammation_reduction)
	return TRUE
