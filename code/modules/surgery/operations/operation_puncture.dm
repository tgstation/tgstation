/datum/surgery_operation/limb/repair_puncture
	name = "Соединение сосудов"
	desc = "Соединение разорванных кровеносных сосудов пациента для подготовки к их прижиганию."
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_SCALPEL = 1.15,
		TOOL_WIRECUTTER = 2.5,
	)
	time = 3 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_PRIORITY_NEXT_STEP | OPERATION_NO_PATIENT_REQUIRED
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT

/datum/surgery_operation/limb/repair_puncture/get_time_modifiers(obj/item/bodypart/limb, mob/living/surgeon, tool)
	. = ..()
	for(var/datum/wound/pierce/bleed/pierce_wound in limb.wounds)
		if(HAS_TRAIT(pierce_wound, TRAIT_WOUND_SCANNED))
			. *= 0.5

/datum/surgery_operation/limb/repair_puncture/get_default_radial_image()
	return image(/obj/item/hemostat)

/datum/surgery_operation/limb/repair_puncture/all_required_strings()
	return list("конечность должна иметь необработанную колотую рану") + ..()

/datum/surgery_operation/limb/repair_puncture/state_check(obj/item/bodypart/limb)
	var/datum/wound/pierce/bleed/pierce_wound = locate() in limb.wounds
	if(isnull(pierce_wound) || pierce_wound.blood_flow <= 0 || pierce_wound.mend_state)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/repair_puncture/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете соединять разорванные кровеносные сосуды в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает соединять разорванные кровеносные сосуды в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)] с помощью [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("[surgeon] начинает соединять разорванные кровеносные сосуды в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы чувствуете ужасную колющую боль в вашей [limb.ru_plaintext_zone[PREPOSITIONAL]]!")

/datum/surgery_operation/limb/repair_puncture/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/wound/pierce/bleed/pierce_wound = locate() in limb.wounds
	pierce_wound?.adjust_blood_flow(-0.25)
	limb.receive_damage(3, wound_bonus = CANT_WOUND, sharpness = tool.get_sharpness(), damage_source = tool)

	if(QDELETED(pierce_wound))
		display_results(
			surgeon,
			limb.owner,
			span_notice("Вы успешно соединили последние разорванные кровеносные сосуды в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
			span_notice("[surgeon] успешно соединяет последние разорванные кровеносные сосуды в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)] с помощью [tool.declent_ru(ACCUSATIVE)]!"),
			span_notice("[surgeon] успешно соединяет последние разорванные кровеносные сосуды в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]!"),
		)
		return

	pierce_wound?.mend_state = TRUE
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы успешно соединили часть кровеносных сосудов в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] успешно соединяет часть кровеносных сосудов в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)] с помощью [tool.declent_ru(ACCUSATIVE)]!"),
		span_notice("[surgeon] успешно соединяет часть кровеносных сосудов в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]!"),
	)

/datum/surgery_operation/limb/repair_puncture/on_failure(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы случайно разрываете кровеносные сосуды в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] разрывает кровеносные сосуды в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)] с помощью [declent_ru(tool, ACCUSATIVE)]!"),
		span_notice("[surgeon] разрывает кровеносные сосуды в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	limb.receive_damage(rand(4, 8), wound_bonus = 10, sharpness = SHARP_EDGED, damage_source = tool)

/datum/surgery_operation/limb/seal_veins
	name = "Прижигание сосудов"
	// rnd_name = "Anastomosis (Seal Blood Vessels)" // doctor says this is the term to use but it fits awkwardly
	desc = "Прижигание ранее соединенных кровеносных сосудов пациента."
	implements = list(
		TOOL_CAUTERY = 1,
		/obj/item/gun/energy/laser = 1.12,
		TOOL_WELDER = 1.5,
		/obj/item = 3.33,
	)
	time = 3.2 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_PRIORITY_NEXT_STEP | OPERATION_NO_PATIENT_REQUIRED
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT

/datum/surgery_operation/limb/seal_veins/get_time_modifiers(obj/item/bodypart/limb, mob/living/surgeon, tool)
	. = ..()
	for(var/datum/wound/pierce/bleed/pierce_wound in limb.wounds)
		if(HAS_TRAIT(pierce_wound, TRAIT_WOUND_SCANNED))
			. *= 0.5

/datum/surgery_operation/limb/seal_veins/get_default_radial_image()
	return image(/obj/item/cautery)

/datum/surgery_operation/limb/seal_veins/get_any_tool()
	return "Любой источник тепла"

/datum/surgery_operation/limb/seal_veins/all_required_strings()
	return list("конечность должна иметь подготовленную колотую рану") + ..()

/datum/surgery_operation/limb/seal_veins/tool_check(obj/item/tool)
	if(istype(tool, /obj/item/gun/energy/laser))
		var/obj/item/gun/energy/laser/lasergun = tool
		return lasergun.cell?.charge > 0

	return tool.get_temperature() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST

/datum/surgery_operation/limb/seal_veins/state_check(obj/item/bodypart/limb)
	var/datum/wound/pierce/bleed/pierce_wound = locate() in limb.wounds
	if(isnull(pierce_wound) || pierce_wound.blood_flow <= 0 || !pierce_wound.mend_state)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/seal_veins/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете прижигать соединенные кровеносные сосуды в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает прижигать соединенные кровеносные сосуды в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)] с помощью [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("[surgeon] начинает прижигать соединенные кровеносные сосуды в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы чувствуете жжение в вашей [limb.ru_plaintext_zone[PREPOSITIONAL]]!")

/datum/surgery_operation/limb/seal_veins/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/wound/pierce/bleed/pierce_wound = locate() in limb.wounds
	pierce_wound?.adjust_blood_flow(-0.5)

	if(QDELETED(pierce_wound))
		display_results(
			surgeon,
			limb.owner,
			span_notice("Вы успешно прижгли последние разорванные кровеносные сосуды в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
			span_notice("[surgeon] успешно прижигает последние разорванные кровеносные сосуды в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)] с помощью [tool.declent_ru(ACCUSATIVE)]!"),
			span_notice("[surgeon] успешно прижигает последние разорванные кровеносные сосуды в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]!"),
		)
		return

	pierce_wound?.mend_state = FALSE
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы успешно прижгли часть кровеносных сосудов в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] успешно прижигает часть кровеносных сосудов в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)] с помощью [tool.declent_ru(ACCUSATIVE)]!"),
		span_notice("[surgeon] успешно прижигает часть кровеносных сосудов в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]!"),
	)
