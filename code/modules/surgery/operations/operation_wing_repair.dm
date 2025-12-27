/datum/surgery_operation/organ/fix_wings
	name = "repair wings"
	rnd_name = "Pteroplasty (Wing Repair)"
	desc = "Repair a patient's damaged wings to restore flight capability."
	rnd_desc = "A surgical procedure that repairs damaged wings using Synthflesh."
	implements = list(
		TOOL_HEMOSTAT = 1.15,
		TOOL_SCREWDRIVER = 2.85,
		/obj/item/pen = 6.67,
	)
	operation_flags = OPERATION_LOCKED | OPERATION_NOTABLE
	time = 20 SECONDS
	target_type = /obj/item/organ/wings/moth
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED

/datum/surgery_operation/organ/fix_wings/get_default_radial_image()
	return image(icon = 'icons/mob/human/species/moth/moth_wings.dmi', icon_state = "m_moth_wings_monarch_BEHIND")

/datum/surgery_operation/organ/fix_wings/all_required_strings()
	return ..() + list("the wings must be burnt", "the patient must be dosed with >5u [/datum/reagent/medicine/c2/synthflesh::name]")

/datum/surgery_operation/organ/fix_wings/all_blocked_strings()
	return ..() + list("if the limb has bones, they must be intact")

/datum/surgery_operation/organ/fix_wings/state_check(obj/item/organ/wings/moth/organ)
	if(!organ.burnt)
		return FALSE
	// If bones are sawed, prevent the operation (unless we're operating on a limb with no bones)
	if(!LIMB_HAS_ANY_SURGERY_STATE(organ.bodypart_owner, SURGERY_BONE_DRILLED|SURGERY_BONE_SAWED) && LIMB_HAS_BONES(organ.bodypart_owner))
		return FALSE
	if(organ.owner.reagents?.get_reagent_amount(/datum/reagent/medicine/c2/synthflesh) < 5)
		return FALSE
	return TRUE

/datum/surgery_operation/organ/fix_wings/on_preop(obj/item/organ/wings/moth/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("You begin to repair [organ.owner]'s damaged wings..."),
		span_notice("[surgeon] begins to repair [organ.owner]'s damaged wings."),
		span_notice("[surgeon] begins to perform surgery on [organ.owner]'s damaged wings."),
	)
	display_pain(organ.owner, "Your wings sting like hell!")

/datum/surgery_operation/organ/fix_wings/on_success(obj/item/organ/wings/moth/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("You succeed in repairing [organ.owner]'s wings."),
		span_notice("[surgeon] successfully repairs [organ.owner]'s wings!"),
		span_notice("[surgeon] completes the surgery on [organ.owner]'s wings."),
	)
	display_pain(organ.owner, "You can feel your wings again!")
	// heal the wings in question
	organ.heal_wings(surgeon, ALL)

	// might as well heal their antennae too
	var/obj/item/organ/antennae/antennae = organ.owner.get_organ_slot(ORGAN_SLOT_EXTERNAL_ANTENNAE)
	antennae?.heal_antennae(surgeon, ALL)

	organ.owner.update_body_parts()
