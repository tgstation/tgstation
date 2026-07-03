/datum/surgery_operation/organ/fix_wings
	name = "Восстановление крыльев"
	rnd_name = "Птеропластика (Починка крыльев)"
	desc = "Восстановление повреждённых крыльев пациента, чтобы вернуть ему возможность летать."
	rnd_desc = "Хирургическая процедура восстановления повреждённых крыльев с использованием синтплоти."
	implements = list(
		TOOL_HEMOSTAT = 1.15,
		TOOL_SCREWDRIVER = 2.85,
		/obj/item/pen = 6.67,
	)
	operation_flags = OPERATION_LOCKED | OPERATION_NOTABLE
	time = 20 SECONDS
	target_type = /obj/item/organ/wings/moth
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED
	required_organ_flag = NONE

/datum/surgery_operation/organ/fix_wings/get_default_radial_image()
	return image(icon = 'icons/mob/human/species/moth/moth_wings.dmi', icon_state = "m_moth_wings_monarch_BEHIND")

/datum/surgery_operation/organ/fix_wings/all_required_strings()
	return ..() + list("крылья должны быть обожжены", "пациент должен получить >5u [/datum/reagent/medicine/c2/synthflesh::name]")

/datum/surgery_operation/organ/fix_wings/all_blocked_strings()
	return ..() + list("если в конечности есть кости, они должны быть целыми")

/datum/surgery_operation/organ/fix_wings/state_check(obj/item/organ/wings/moth/organ)
	if(!organ.burnt)
		return FALSE
	// If bones are sawed, prevent the operation (unless we're operating on a limb with no bones)
	if(LIMB_HAS_ANY_SURGERY_STATE(organ.bodypart_owner, SURGERY_BONE_DRILLED|SURGERY_BONE_SAWED) && LIMB_HAS_BONES(organ.bodypart_owner))
		return FALSE
	if(organ.owner.reagents?.get_reagent_amount(/datum/reagent/medicine/c2/synthflesh) < 5)
		return FALSE
	return TRUE

/datum/surgery_operation/organ/fix_wings/on_preop(obj/item/organ/wings/moth/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы начинаете чинить повреждённые крылья [organ.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает чинить повреждённые крылья [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает операцию на повреждённых крыльях [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Ваши крылья адски жгутся!")

/datum/surgery_operation/organ/fix_wings/on_success(obj/item/organ/wings/moth/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вам удаётся полностью восстановить крылья [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] успешно восстанавливает крылья [organ.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] завершает операцию на крыльях [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Вы снова чувствуете свои крылья!")
	// heal the wings in question
	organ.heal_wings(surgeon, ALL)

	// might as well heal their antennae too
	var/obj/item/organ/antennae/antennae = organ.owner.get_organ_slot(ORGAN_SLOT_EXTERNAL_ANTENNAE)
	antennae?.heal_antennae(surgeon, ALL)

	organ.owner.update_body_parts()
