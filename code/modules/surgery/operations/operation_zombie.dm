/datum/surgery_operation/limb/bionecrosis
	name = "Вызвать бионекроз"
	rnd_name = "Бионекропластика (Некротическое оживление)"
	desc = "Введение реагентов, стимулирующих рост Ромерол-опухоли в мозге пациента."
	rnd_desc = "Экспериментальная процедура, вызывающая рост Ромерол-опухоли в мозге пациента."
	implements = list(
		/obj/item/reagent_containers/syringe = 1,
		/obj/item/pen = 3.33,
	)
	time = 5 SECONDS
	operation_flags = OPERATION_MORBID | OPERATION_LOCKED | OPERATION_NOTABLE
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED
	var/list/zombie_chems = list(
		/datum/reagent/medicine/rezadone,
		/datum/reagent/toxin/zombiepowder,
	)

/datum/surgery_operation/limb/bionecrosis/get_default_radial_image()
	return image(get_dynamic_human_appearance(species_path = /datum/species/zombie))

/datum/surgery_operation/limb/bionecrosis/all_required_strings()
	. = ..()
	. += "в конечности должен присутствовать мозг"

/datum/surgery_operation/limb/bionecrosis/any_required_strings()
	. = ..()
	for(var/datum/reagent/chem as anything in zombie_chems)
		. += "у пациента или в инструменте должно быть >1u [chem::name]"

/datum/surgery_operation/limb/bionecrosis/all_blocked_strings()
	. = ..()
	. += "в конечности не должно быть Ромерол-опухоли"

/datum/surgery_operation/limb/bionecrosis/state_check(obj/item/bodypart/limb)
	if(locate(/obj/item/organ/zombie_infection) in limb)
		return FALSE
	if(!(locate(/obj/item/organ/brain) in limb))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/bionecrosis/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	for(var/chem in zombie_chems)
		if(tool.reagents?.get_reagent_amount(chem) > 1)
			return TRUE
		if(limb.owner.reagents?.get_reagent_amount(chem) > 1)
			return TRUE
	return FALSE

/datum/surgery_operation/limb/bionecrosis/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете выращивать Ромерол-опухоль в мозге у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает копаться в мозге у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает операцию на мозге у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Ваша голова разрывается от невообразимой боли!") // Same message as other brain surgeries

/datum/surgery_operation/limb/bionecrosis/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вам удаётся вырастить Ромерол-опухоль в мозге у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] успешно выращивает Ромерол-опухоль в мозге у [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] завершает операцию на мозге у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "На мгновение голова полностью немеет, боль становится невыносимой!")
	if(locate(/obj/item/organ/zombie_infection) in limb) // they got another one mid surgery? whatever
		return
	var/obj/item/organ/zombie_infection/z_infection = new()
	z_infection.Insert(limb.owner)
	for(var/chem in zombie_chems)
		tool.reagents?.remove_reagent(chem, 1)
		limb.owner.reagents?.remove_reagent(chem, 1)
