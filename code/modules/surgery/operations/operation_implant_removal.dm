/datum/surgery_operation/basic/implant_removal
	name = "Извлечение импланта"
	desc = "Попытка найти и извлечь имплант из пациента. \
		Любой найденный имплант будет уничтожен, если рядом или в руках нет кейса для имплантов."
	operation_flags = OPERATION_NOTABLE
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_CROWBAR = 1.5,
		/obj/item/kitchen/fork = 2.85,
	)
	time = 6.4 SECONDS
	success_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/basic/implant_removal/get_default_radial_image()
	return image('icons/obj/medical/syringe.dmi', "implantcase-b")

/datum/surgery_operation/basic/implant_removal/any_optional_strings()
	return ..() + list("наличие кейса для имплантов у пациента или в руках позволит сохранить извлеченный имплант")

/datum/surgery_operation/basic/implant_removal/on_preop(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("Вы ищете импланты в [patient.declent_ru(PREPOSITIONAL)]..."),
		span_notice("[surgeon] ищет импланты в [patient.declent_ru(PREPOSITIONAL)]."),
		span_notice("[surgeon] ищет что-то в [patient.declent_ru(PREPOSITIONAL)]."),
	)
	if(LAZYLEN(patient.implants))
		display_pain(patient, "Вы чувствуете серьезную боль, когда [surgeon] копается внутри вас!")

/datum/surgery_operation/basic/implant_removal/on_success(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/obj/item/implant/implant = LAZYACCESS(patient.implants, 1)
	if(isnull(implant))
		display_results(
			surgeon,
			patient,
			span_warning("Вы не находите имплантов для извлечения в [patient.declent_ru(PREPOSITIONAL)]."),
			span_warning("[surgeon] не находит имплантов для извлечения в [patient.declent_ru(PREPOSITIONAL)]."),
			span_warning("[surgeon] не находит ничего, что можно было бы извлечь из [patient.declent_ru(GENITIVE)]."),
		)
		return

	display_results(
		surgeon,
		patient,
		span_notice("Вы успешно извлекаете [declent_ru(implant, ACCUSATIVE)] из [patient.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] успешно извлекает [declent_ru(implant, ACCUSATIVE)] из [patient.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] успешно извлекает что-то из [patient.declent_ru(GENITIVE)]!"),
	)
	display_pain(patient, "Вы чувствуете, как ваш [declent_ru(implant.name, ACCUSATIVE)] вытаскивают из вас!")
	implant.removed(patient)

	if(QDELETED(implant))
		return

	var/obj/item/implantcase/case = get_case(surgeon, patient)
	if(isnull(case))
		return

	case.imp = implant
	implant.forceMove(case)
	case.update_appearance()
	display_results(
		surgeon,
		patient,
		span_notice("Вы помещаете [declent_ru(implant, ACCUSATIVE)] в [case]."),
		span_notice("[surgeon] помещает [declent_ru(implant, ACCUSATIVE)] в [case]."),
		span_notice("[surgeon] помещает что-то в [declent_ru(implant, ACCUSATIVE)]."),
	)

/datum/surgery_operation/basic/implant_removal/proc/get_case(mob/living/surgeon, mob/living/target)
	var/list/locations = list(
		surgeon.is_holding_item_of_type(/obj/item/implantcase),
		locate(/obj/item/implantcase) in surgeon.loc,
		locate(/obj/item/implantcase) in target.loc,
	)

	for(var/obj/item/implantcase/case in locations)
		if(!case.imp)
			return case

	return null
