/datum/surgery/lobectomy
	name = "Lobectomy" //not to be confused with lobotomy
	organ_to_manipulate = ORGAN_SLOT_LUNGS
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/lobectomy,
		/datum/surgery_step/close,
	)

/datum/surgery/lobectomy/mechanic
	name = "Air Filtration Diagnostic"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/lobectomy/mechanic,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery/lobectomy/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/lungs/target_lungs = target.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(isnull(target_lungs) || target_lungs.damage < 60 || target_lungs.operated)
		return FALSE
	return ..()

//lobectomy, removes the most damaged lung lobe with a 95% base success chance
/datum/surgery_step/lobectomy
	name = "excise damaged lung node (scalpel)"
	implements = list(
		TOOL_SCALPEL = 95,
		/obj/item/melee/energy/sword = 65,
		/obj/item/knife = 45,
		/obj/item/shard = 35)
	time = 4.2 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/organ1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	surgery_effects_mood = TRUE

/datum/surgery_step/lobectomy/mechanic
	name = "Perform maintenance (scalpel or wrench)"
	implements = list(
		TOOL_SCALPEL = 95,
		TOOL_WRENCH = 95,
		/obj/item/melee/energy/sword = 65,
		/obj/item/knife = 45,
		/obj/item/shard = 35)
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/machines/airlock/doorclick.ogg'

/datum/surgery_step/lobectomy/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to make an incision in [target]'s lungs..."),
		span_notice("[user] begins to make an incision in [target]."),
		span_notice("[user] begins to make an incision in [target]."),
	)
	display_pain(target, "You feel a stabbing pain in your chest!")

/datum/surgery_step/lobectomy/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		var/obj/item/organ/lungs/target_lungs = human_target.get_organ_slot(ORGAN_SLOT_LUNGS)
		human_target.setOrganLoss(ORGAN_SLOT_LUNGS, 60)
		if(target_lungs)
			target_lungs.operated = TRUE
			if(target_lungs.organ_flags & ORGAN_EMP) //If our organ is failing due to an EMP, fix that
				target_lungs.organ_flags &= ~ORGAN_EMP
		display_results(
			user,
			target,
			span_notice("You successfully excise [human_target]'s most damaged lobe."),
			span_notice("Successfully removes a piece of [human_target]'s lungs."),
			"",
		)
		display_pain(target, "Your chest hurts like hell, but breathing becomes slightly easier.")
	return ..()

/datum/surgery_step/lobectomy/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		display_results(
			user,
			target,
			span_warning("You screw up, failing to excise [human_target]'s damaged lobe!"),
			span_warning("[user] screws up!"),
			span_warning("[user] screws up!"),
		)
		display_pain(target, "You feel a sharp stab in your chest; the wind is knocked out of you and it hurts to catch your breath!")
		human_target.losebreath += 4
		human_target.adjustOrganLoss(ORGAN_SLOT_LUNGS, 10)
	return FALSE
