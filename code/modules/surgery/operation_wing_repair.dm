/datum/surgery_operation/fix_wings
	name = "repair wings"
	desc = "Repair a patient's damaged wings to restore flight capability."
	implements = list(
		TOOL_HEMOSTAT = 0.85,
		TOOL_SCREWDRIVER = 0.35,
		/obj/item/pen = 0.15
	)
	chems_needed = list(/datum/reagent/medicine/c2/synthflesh)
	operation_flags = OPERATION_REQUIRES_TECH
	time = 20 SECONDS

/datum/surgery_operation/fix_wings/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	return image(icon = 'icons/mob/human/species/moth/moth_wings.dmi', icon_state = "m_moth_wings_monarch_BEHIND")

/datum/surgery_operation/fix_wings/state_check(obj/item/bodypart/limb)
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	if(limb.surgery_vessel_state < SURGERY_VESSELS_CLAMPED)
		return FALSE
	if(limb.surgery_bone_state == SURGERY_BONE_INTACT)
		return FALSE
	var/obj/item/organ/wings/moth/wings = locate() in limb
	return wings?.burnt

/datum/surgery_operation/fix_wings/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to repair [limb.owner]'s damaged wings..."),
		span_notice("[surgeon] begins to repair [limb.owner]'s damaged wings."),
		span_notice("[surgeon] begins to perform surgery on [limb.owner]'s damaged wings."),
	)
	display_pain(limb.owner, "Your wings sting like hell!")

/datum/surgery_operation/fix_wings/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You succeed in repairing [limb.owner]'s wings."),
		span_notice("[surgeon] successfully repairs [limb.owner]'s wings!"),
		span_notice("[surgeon] completes the surgery on [limb.owner]'s wings."),
	)
	display_pain(limb.owner, "You can feel your wings again!")
	// heal the wings in question
	var/obj/item/organ/wings/moth/wings = locate() in limb
	wings?.heal_wings(surgeon, ALL)

	// might as well heal their antennae too
	var/obj/item/organ/antennae/antennae = limb.owner.get_organ_slot(ORGAN_SLOT_EXTERNAL_ANTENNAE)
	antennae?.heal_antennae(surgeon, ALL)

	limb.owner.update_body_parts()
