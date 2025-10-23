/datum/surgery_operation/organ/fix_wings
	name = "repair wings"
	desc = "Repair a patient's damaged wings to restore flight capability."
	implements = list(
		TOOL_HEMOSTAT = 0.85,
		TOOL_SCREWDRIVER = 0.35,
		/obj/item/pen = 0.15
	)
	operation_flags = OPERATION_REQUIRES_TECH
	time = 20 SECONDS
	target_type = /obj/item/organ/wings/moth

/datum/surgery_operation/organ/fix_wings/get_default_radial_image(obj/item/organ/wings/moth/organ, mob/living/surgeon, obj/item/tool)
	return image(icon = 'icons/mob/human/species/moth/moth_wings.dmi', icon_state = "m_moth_wings_monarch_BEHIND")

/datum/surgery_operation/organ/fix_wings/organ_check(obj/item/organ/wings/moth/organ)
	if(!organ.burnt)
		return FALSE
	if(organ.bodypart_owner.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	if(organ.bodypart_owner.surgery_vessel_state < SURGERY_VESSELS_CLAMPED)
		return FALSE
	if(organ.bodypart_owner.surgery_bone_state == SURGERY_BONE_INTACT)
		return FALSE
	if(organ.owner.reagents?.get_reagent_amount(/datum/reagent/medicine/c2/synthflesh) < 1)
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
