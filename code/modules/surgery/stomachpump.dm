/datum/surgery/stomach_pump
	name = "Stomach Pump"
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/incise,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/stomach_pump,
		/datum/surgery_step/close,
	)

/datum/surgery/stomach_pump/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/internal/stomach/target_stomach = target.getorganslot(ORGAN_SLOT_STOMACH)
	if(HAS_TRAIT(target, TRAIT_HUSK))
		return FALSE
	if(!target_stomach)
		return FALSE
	return ..()

//Working the stomach by hand in such a way that you induce vomiting.
/datum/surgery_step/stomach_pump
	name = "pump stomach (hand)"
	accept_hand = TRUE
	repeatable = TRUE
	time = 20
	success_sound = 'sound/surgery/organ2.ogg'

/datum/surgery_step/stomach_pump/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin pumping [target]'s stomach..."),
		span_notice("[user] begins to pump [target]'s stomach."),
		span_notice("[user] begins to press on [target]'s chest."),
	)
	display_pain(target, "You feel a horrible sloshing feeling in your gut! You're going to be sick!")

/datum/surgery_step/stomach_pump/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(ishuman(target))
		var/mob/living/carbon/human/target_human = target
		display_results(
			user,
			target,
			span_notice("[user] forces [target_human] to vomit, cleansing their stomach of some chemicals!"),
			span_notice("[user] forces [target_human] to vomit, cleansing their stomach of some chemicals!"),
			span_notice("[user] forces [target_human] to vomit!"),
		)
		target_human.vomit(20, FALSE, TRUE, 1, TRUE, FALSE, purge_ratio = 0.67) //higher purge ratio than regular vomiting
	return ..()

/datum/surgery_step/stomach_pump/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(ishuman(target))
		var/mob/living/carbon/human/target_human = target
		display_results(
			user,
			target,
			span_warning("You screw up, brusing [target_human]'s chest!"),
			span_warning("[user] screws up, brusing [target_human]'s chest!"),
			span_warning("[user] screws up!"),
		)
		target_human.adjustOrganLoss(ORGAN_SLOT_STOMACH, 5)
		target_human.adjustBruteLoss(5)
