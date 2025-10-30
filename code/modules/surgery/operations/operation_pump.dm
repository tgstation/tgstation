/datum/surgery_operation/organ/stomach_pump
	name = "pump stomach"
	rnd_name = "Gastric Lavage (Stomach Pump)"
	desc = "Manually pump a patient's stomach to induce vomiting and expel harmful chemicals."
	implements = list(
		IMPLEMENT_HAND = 1,
	)
	time = 2 SECONDS
	required_biotype = ORGAN_ORGANIC
	target_type = /obj/item/organ/stomach

/datum/surgery_operation/organ/stomach_pump/get_default_radial_image()
	return image(/atom/movable/screen/alert/disgusted)

/datum/surgery_operation/organ/stomach_pump/state_check(obj/item/organ/stomach/organ, mob/living/surgeon, obj/item/tool)
	if(!LIMB_HAS_SURGERY_STATE(organ.bodypart_owner, SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT))
		return FALSE
	if(HAS_TRAIT(organ.owner, TRAIT_HUSK))
		return FALSE
	return TRUE

/datum/surgery_operation/organ/stomach_pump/on_preop(obj/item/organ/stomach/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("You begin to pump [organ.owner]'s stomach..."),
		span_notice("[surgeon] begins to pump [organ.owner]'s stomach."),
		span_notice("[surgeon] begins to press on [organ.owner]'s chest."),
	)
	display_pain(organ.owner, "You feel a horrible sloshing feeling in your gut! You're going to be sick!")

/datum/surgery_operation/organ/stomach_pump/on_success(obj/item/organ/stomach/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("[surgeon] forces [organ.owner] to vomit, cleansing their stomach of some chemicals!"),
		span_notice("[surgeon] forces [organ.owner] to vomit, cleansing their stomach of some chemicals!"),
		span_notice("[surgeon] forces [organ.owner] to vomit!"),
	)
	organ.owner.vomit((MOB_VOMIT_MESSAGE | MOB_VOMIT_STUN), lost_nutrition = 20, purge_ratio = 0.67)

/datum/surgery_operation/organ/stomach_pump/on_failure(obj/item/organ/stomach/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_warning("You screw up, bruising [organ.owner]'s chest!"),
		span_warning("[surgeon] screws up, bruising [organ.owner]'s chest!"),
		span_warning("[surgeon] screws up!"),
	)
	organ.apply_organ_damage(5)
	organ.bodypart_owner.receive_damage(5)

/datum/surgery_operation/organ/stomach_pump/mechanic
	name = "purge nutrient processor"
	required_biotype = ORGAN_ROBOTIC
