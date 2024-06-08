/datum/surgery/gastrectomy
	name = "Gastrectomy"
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB | SURGERY_REQUIRES_REAL_LIMB
	organ_to_manipulate = ORGAN_SLOT_STOMACH
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/gastrectomy,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/close,
	)

/datum/surgery/gastrectomy/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/internal/stomach/target_stomach = target.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(isnull(target_stomach) || target_stomach.damage < 50 || target_stomach.operated)
		return FALSE
	return ..()

////Gastrectomy, because we truly needed a way to repair stomachs.
//95% chance of success to be consistent with most organ-repairing surgeries.
/datum/surgery_step/gastrectomy
	name = "remove lower duodenum (scalpel)"
	implements = list(
		TOOL_SCALPEL = 95,
		/obj/item/melee/energy/sword = 65,
		/obj/item/knife = 45,
		/obj/item/shard = 35)
	time = 52
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/organ1.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'

/datum/surgery_step/gastrectomy/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to cut out a damaged piece of [target]'s stomach..."),
		span_notice("[user] begins to make an incision in [target]."),
		span_notice("[user] begins to make an incision in [target]."),
	)
	display_pain(target, "You feel a horrible stab in your gut!", mood_event_type = /datum/mood_event/surgery)

/datum/surgery_step/gastrectomy/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/mob/living/carbon/human/target_human = target
	var/obj/item/organ/internal/stomach/target_stomach = target.get_organ_slot(ORGAN_SLOT_STOMACH)
	target_human.setOrganLoss(ORGAN_SLOT_STOMACH, 20) // Stomachs have a threshold for being able to even digest food, so I might tweak this number
	if(target_stomach)
		target_stomach.operated = TRUE
	display_results(
		user,
		target,
		span_notice("You successfully remove the damaged part of [target]'s stomach."),
		span_notice("[user] successfully removes the damaged part of [target]'s stomach."),
		span_notice("[user] successfully removes the damaged part of [target]'s stomach."),
	)
	display_pain(target, "The pain in your gut ebbs and fades somewhat.", mood_event_type = /datum/mood_event/surgery/success)
	return ..()

/datum/surgery_step/gastrectomy/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery)
	var/mob/living/carbon/human/target_human = target
	target_human.adjustOrganLoss(ORGAN_SLOT_STOMACH, 15)
	display_results(
		user,
		target,
		span_warning("You cut the wrong part of [target]'s stomach!"),
		span_warning("[user] cuts the wrong part of [target]'s stomach!"),
		span_warning("[user] cuts the wrong part of [target]'s stomach!"),
	)
	display_pain(target, "Your stomach throbs with pain; it's not getting any better!", mood_event_type = /datum/mood_event/surgery/failure)
