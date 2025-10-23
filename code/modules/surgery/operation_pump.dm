/datum/surgery_operation/limb/stomach_pump
	name = "pump stomach"
	desc = "Manually pump a patient's stomach to induce vomiting and expel harmful chemicals."
	required_bodytype = BODYTYPE_ORGANIC
	implements = list(
		HAND_IMPLEMENT = 1,
	)
	time = 2 SECONDS

/datum/surgery_operation/limb/stomach_pump/state_check(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool)
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	if(limb.surgery_vessel_state < SURGERY_VESSELS_ORGANS_CUT)
		return FALSE
	if(HAS_TRAIT(limb.owner, TRAIT_HUSK))
		return FALSE
	var/obj/item/organ/stomach/stomach = locate() in limb
	if(isnull(stomach))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/stomach_pump/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to pump [limb.owner]'s stomach..."),
		span_notice("[surgeon] begins to pump [limb.owner]'s stomach."),
		span_notice("[surgeon] begins to press on [limb.owner]'s chest."),
	)
	display_pain(limb.owner, "You feel a horrible sloshing feeling in your gut! You're going to be sick!")

/datum/surgery_operation/limb/stomach_pump/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("[surgeon] forces [limb.owner] to vomit, cleansing their stomach of some chemicals!"),
		span_notice("[surgeon] forces [limb.owner] to vomit, cleansing their stomach of some chemicals!"),
		span_notice("[surgeon] forces [limb.owner] to vomit!"),
	)
	limb.owner.vomit((MOB_VOMIT_MESSAGE | MOB_VOMIT_STUN), lost_nutrition = 20, purge_ratio = 0.67)

/datum/surgery_operation/limb/stomach_pump/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_warning("You screw up, bruising [limb.owner]'s chest!"),
		span_warning("[surgeon] screws up, bruising [limb.owner]'s chest!"),
		span_warning("[surgeon] screws up!"),
	)
	limb.owner.adjustOrganLoss(ORGAN_SLOT_STOMACH, 5)
	limb.receive_damage(5)

/datum/surgery_operation/limb/stomach_pump/mechanic
	name = "purge nutrient processor"
	required_bodytype = BODYTYPE_ROBOTIC
