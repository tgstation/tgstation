/datum/surgery_operation/basic/viral_bonding
	name = "Вирусное связывание"
	rnd_name = "Виропластика (Вирусное связывание)"
	desc = "Создание симбиотической связи между пациентом и вирусом, которым он заражён."
	rnd_desc = "Хирургическая процедура, насильно формирующая симбиотические отношения между вирусом и его носителем. \
		Пациент становится полностью невосприимчив к эффектам вируса, но продолжает носить и распространять его."
	implements = list(
		TOOL_CAUTERY = 1,
		TOOL_WELDER = 2,
		/obj/item = 3.33,
	)
	time = 10 SECONDS
	preop_sound = 'sound/items/handling/surgery/cautery1.ogg'
	success_sound = 'sound/items/handling/surgery/cautery2.ogg'
	operation_flags = OPERATION_MORBID | OPERATION_LOCKED | OPERATION_NOTABLE
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT
	var/list/required_chems = list(
		/datum/reagent/medicine/spaceacillin,
		/datum/reagent/consumable/virus_food,
		/datum/reagent/toxin/formaldehyde,
	)

/datum/surgery_operation/basic/viral_bonding/get_any_tool()
	return "Любой источник тепла"

/datum/surgery_operation/basic/viral_bonding/all_required_strings()
	. = ..()
	. += "у пациента должен быть вирус для формирования связи"
	for(var/datum/reagent/chem as anything in required_chems)
		. += "пациент должен получить >1u [chem::name]"

/datum/surgery_operation/basic/viral_bonding/get_default_radial_image()
	return image(/obj/item/clothing/mask/surgical)

/datum/surgery_operation/basic/viral_bonding/state_check(mob/living/patient)
	for(var/chem in required_chems)
		if(patient.reagents?.get_reagent_amount(chem) < 1)
			return FALSE
	for(var/datum/disease/infected_disease as anything in patient.diseases)
		if(infected_disease.severity != DISEASE_SEVERITY_UNCURABLE)
			return TRUE
	return FALSE

/datum/surgery_operation/basic/viral_bonding/tool_check(obj/item/tool)
	return tool.get_temperature() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST

/datum/surgery_operation/basic/viral_bonding/on_preop(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("Вы начинаете подогревать костный мозг [patient] с помощью [tool.declent_ru(ACCUSATIVE)]..."),
		span_notice("[surgeon] начинает подогревать костный мозг [patient] с помощью [tool.declent_ru(ACCUSATIVE)]..."),
		span_notice("[surgeon] начинает подогревать что‑то в груди [patient] с помощью [tool.declent_ru(ACCUSATIVE)]..."),
	)
	display_pain(patient, "Вы чувствуете, как жгучее тепло разливается по вашей груди!")

/datum/surgery_operation/basic/viral_bonding/on_success(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("Костный мозг [patient] начинает медленно пульсировать. Вирусное связывание завершено."),
		span_notice("Костный мозг [patient] начинает медленно пульсировать."),
		span_notice("[surgeon] завершает операцию."),
	)
	display_pain(patient, "Вы чувствуете слабую пульсацию в груди.")
	for(var/datum/disease/infected_disease as anything in patient.diseases)
		if(infected_disease.severity != DISEASE_SEVERITY_UNCURABLE) //no curing quirks, sweaty
			infected_disease.carrier = TRUE
	return TRUE
