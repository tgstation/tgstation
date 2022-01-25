/datum/surgery/gastrectomy
	name = "Gastrectomy"
	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_real_bodypart = TRUE
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/gastrectomy,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/close)
	organ_to_manipulate = ORGAN_SLOT_STOMACH

/datum/surgery/gastrectomy/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/stomach/target_stomach = target.getorganslot(ORGAN_SLOT_STOMACH)
	if(target_stomach?.damage > 50 && !(target_stomach.organ_flags & ORGAN_FAILING))
		return TRUE

////Gastrectomy, because we truly needed a way to repair stomachs.
//95% chance of success to be consistent with most organ-repairing surgeries.
/datum/surgery_step/gastrectomy
	name = "remove lower duodenum"
	implements = list(
		TOOL_SCALPEL = 95,
		/obj/item/melee/energy/sword = 65,
		/obj/item/knife = 45,
		/obj/item/shard = 35)
	time = 52

/datum/surgery_step/gastrectomy/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to cut out a damaged piece of [target]'s stomach..."),
		span_notice("[user] begins to make an incision in [target]."),
		span_notice("[user] begins to make an incision in [target]."),
		playsound(get_turf(target), 'sound/surgery/scalpel1.ogg', 75, TRUE, falloff_exponent = 12, falloff_distance = 1))
	display_pain(target, "You feel a horrible stab in your gut!")

/datum/surgery_step/gastrectomy/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/mob/living/carbon/human/target_human = target
	target_human.setOrganLoss(ORGAN_SLOT_STOMACH, 20) // Stomachs have a threshold for being able to even digest food, so I might tweak this number
	display_results(user, target, span_notice("You successfully remove the damaged part of [target]'s stomach."),
		span_notice("[user] successfully removes the damaged part of [target]'s stomach."),
		span_notice("[user] successfully removes the damaged part of [target]'s stomach."),
		playsound(get_turf(target), 'sound/surgery/organ1.ogg', 75, TRUE, falloff_exponent = 12, falloff_distance = 1))
	display_pain(target, "The pain in your gut ebbs and fades somewhat.")
	return ..()

/datum/surgery_step/gastrectomy/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery)
	var/mob/living/carbon/human/target_human = target
	target_human.adjustOrganLoss(ORGAN_SLOT_STOMACH, 15)
	display_results(user, target, span_warning("You cut the wrong part of [target]'s stomach!"),
		span_warning("[user] cuts the wrong part of [target]'s stomach!"),
		span_warning("[user] cuts the wrong part of [target]'s stomach!"),
		playsound(get_turf(target), 'sound/surgery/organ2.ogg', 75, TRUE, falloff_exponent = 12, falloff_distance = 1))
	display_pain(target, "Your stomach throbs with pain; it's not getting any better!")

