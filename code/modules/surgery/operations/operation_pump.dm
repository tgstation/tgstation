/datum/surgery_operation/organ/stomach_pump
	name = "pump stomach"
	rnd_name = "Gastric Lavage (Stomach Pump)"
	desc = "Manually pump a patient's stomach to induce vomiting and expel harmful chemicals."
	operation_flags = OPERATION_NOTABLE
	implements = list(
		IMPLEMENT_HAND = 1,
	)
	time = 2 SECONDS
	required_organ_flag = ORGAN_TYPE_FLAGS & ~ORGAN_ROBOTIC
	target_type = /obj/item/organ/stomach
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT

/datum/surgery_operation/organ/stomach_pump/get_default_radial_image()
	return image(/atom/movable/screen/alert/disgusted::overlay_icon, /atom/movable/screen/alert/disgusted::overlay_state)

/datum/surgery_operation/organ/stomach_pump/all_required_strings()
	return ..() + list("the patient must not be husked")

/datum/surgery_operation/organ/stomach_pump/state_check(obj/item/organ/stomach/organ)
	return !HAS_TRAIT(organ.owner, TRAIT_HUSK)

/datum/surgery_operation/organ/stomach_pump/on_preop(obj/item/organ/stomach/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("You begin to pump [organ.owner]'s stomach..."),
		span_notice("[surgeon] begins to pump [organ.owner]'s stomach."),
		span_notice("[surgeon] begins to press on [organ.owner]'s abdomen."),
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
	rnd_name = "Nutrient Processor Purge (Stomach Pump)"
	required_organ_flag = ORGAN_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC
