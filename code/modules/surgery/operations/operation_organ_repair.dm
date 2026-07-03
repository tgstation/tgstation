/// Repairing specific organs
/datum/surgery_operation/organ/repair
	abstract_type = /datum/surgery_operation/organ/repair
	name = "Восстановление органа"
	desc = "Восстановление поврежденного органа пациента."
	required_organ_flag = ORGAN_TYPE_FLAGS & ~ORGAN_ROBOTIC
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE | OPERATION_NO_PATIENT_REQUIRED
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|SURGERY_BONE_SAWED
	/// What % damage do we heal the organ to on success
	/// Note that 0% damage = 100% health
	var/heal_to_percent = 0.6
	/// What % damage do we apply to the organ on failure
	var/failure_damage_percent = 0.2
	/// If TRUE, an organ can be repaired multiple times
	var/repeatable = FALSE

/datum/surgery_operation/organ/repair/New()
	. = ..()
	if(operation_flags & OPERATION_LOOPING)
		repeatable = TRUE // if it's looping it would necessitate being repeatable
	if(!repeatable)
		desc += " Эту процедуру можно провести только один раз для каждого органа."

/datum/surgery_operation/organ/repair/state_check(obj/item/organ/organ)
	if(organ.damage < (organ.maxHealth * heal_to_percent) || (!repeatable && HAS_TRAIT(organ, TRAIT_ORGAN_OPERATED_ON)))
		return FALSE // conditionally available so we don't spam the radial with useless options, alas
	return TRUE

/datum/surgery_operation/organ/repair/all_required_strings()
	. = ..()
	if(!repeatable)
		. += "орган должен быть умеренно поврежден"

/datum/surgery_operation/organ/repair/all_blocked_strings()
	. = ..()
	if(!repeatable)
		. += "орган не должен был подвергаться хирургическому восстановлению ранее"

/datum/surgery_operation/organ/repair/on_success(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	organ.set_organ_damage(organ.maxHealth * heal_to_percent)
	organ.organ_flags &= ~ORGAN_EMP
	ADD_TRAIT(organ, TRAIT_ORGAN_OPERATED_ON, TRAIT_GENERIC)

/datum/surgery_operation/organ/repair/on_failure(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	organ.apply_organ_damage(organ.maxHealth * failure_damage_percent)

/datum/surgery_operation/organ/repair/lobectomy
	name = "Удаление поврежденной доли легкого"
	rnd_name = "Лобэктомия (Восстановление лёгких)"
	desc = "Восстановление поврежденных лёгких пациента путем удаления наиболее поврежденной доли."
	implements = list(
		TOOL_SCALPEL = 1.05,
		/obj/item/melee/energy/sword = 1.5,
		/obj/item/knife = 2.25,
		/obj/item/shard = 2.85,
	)
	time = 4.2 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/organ1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	target_type = /obj/item/organ/lungs
	failure_damage_percent = 0.1

/datum/surgery_operation/organ/repair/lobectomy/on_preop(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы начинаете делать надрез в легких [organ.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает делать надрез у [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает делать надрез у [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Вы чувствуете колющую боль в груди!")

/datum/surgery_operation/organ/repair/lobectomy/on_success(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы успешно удаляете наиболее повреждённую долю легкого [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] успешно удаляет наиболее повреждённую долю легкого [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] успешно удаляет наиболее повреждённую долю легкого [organ.owner.declent_ru(GENITIVE)]."),
	)

/datum/surgery_operation/organ/repair/lobectomy/on_failure(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	organ.owner?.losebreath += 4
	display_results(
		surgeon,
		organ.owner,
		span_warning("Вы совершаете ошибку, не сумев удалить повреждённую долю легкого [organ.owner.declent_ru(GENITIVE)]!"),
		span_warning("[surgeon] совершает ошибку!"),
		span_warning("[surgeon] совершает ошибку!"),
	)
	display_pain(organ.owner, "Вы чувствуете резкий укол в груди; у вас перехватывает дыхание, и каждый вдох причиняет боль!")

/datum/surgery_operation/organ/repair/lobectomy/mechanic
	name = "Проведение техобслуживания"
	rnd_name = "Диагностика фильтрации воздуха (Восстановление лёгких)"
	implements = list(
		TOOL_WRENCH = 1.05,
		TOOL_SCALPEL = 1.05,
		/obj/item/melee/energy/sword = 1.5,
		/obj/item/knife = 2.25,
		/obj/item/shard = 2.85,
	)
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/machines/airlock/doorclick.ogg'
	required_organ_flag = ORGAN_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/organ/repair/hepatectomy
	name = "Удаление поврежденной части печени"
	rnd_name = "Гепатэктомия (Восстановление печени)"
	desc = "Восстановление поврежденной печени пациента путем удаления наиболее поврежденного сегмента."
	implements = list(
		TOOL_SCALPEL = 1.05,
		/obj/item/melee/energy/sword = 1.5,
		/obj/item/knife = 2.25,
		/obj/item/shard = 2.85,
	)
	time = 5.2 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/organ1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	target_type = /obj/item/organ/liver
	heal_to_percent = 0.1
	failure_damage_percent = 0.15

/datum/surgery_operation/organ/repair/hepatectomy/on_preop(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы начинаете вырезать поврежденный фрагмент печени [organ.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает делать надрез у [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает делать надрез у [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Ваш живот горит от ужасной колющей боли!")

/datum/surgery_operation/organ/repair/hepatectomy/on_success(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы успешно удаляете повреждённую часть печени [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] успешно удаляет повреждённую часть печени [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] успешно удаляет повреждённую часть печени [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Боль немного отступает!")

/datum/surgery_operation/organ/repair/hepatectomy/on_failure(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		organ.owner,
		span_warning("Вы отрезали не ту часть печени [organ.owner.declent_ru(GENITIVE)]!"),
		span_warning("[surgeon] отрезал не ту часть печени [organ.owner.declent_ru(GENITIVE)]!"),
		span_warning("[surgeon] отрезал не ту часть печени [organ.owner.declent_ru(GENITIVE)]!"),
	)
	display_pain(organ.owner, "Боль в животе усиливается!")

/datum/surgery_operation/organ/repair/hepatectomy/mechanic
	name = "Проведение техобслуживания"
	rnd_name = "Диагностика системы очистки от примесей (Восстановление печени)"
	implements = list(
		TOOL_WRENCH = 1.05,
		TOOL_SCALPEL = 1.05,
		/obj/item/melee/energy/sword = 1.5,
		/obj/item/knife = 2.25,
		/obj/item/shard = 2.85,
	)
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/machines/airlock/doorclick.ogg'
	required_organ_flag = ORGAN_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/organ/repair/coronary_bypass
	name = "Коронарное шунтирование"
	rnd_name = "Аортокоронарное шунтирование (Восстановление сердца)"
	desc = "Установка шунта на поврежденное сердце пациента для восстановления нормального кровотока."
	implements = list(
		TOOL_HEMOSTAT = 1.05,
		TOOL_WIRECUTTER = 2.85,
		/obj/item/stack/package_wrap = 6.67,
		/obj/item/stack/cable_coil = 2,
	)
	time = 9 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	success_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	target_type = /obj/item/organ/heart

/datum/surgery_operation/organ/repair/coronary_bypass/on_preop(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы начинаете устанавливать шунт на сердце [organ.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает устанавливать шунт на сердце [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает устанавливать шунт на сердце [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Боль в груди невыносима! Вы едва можете это терпеть!")

/datum/surgery_operation/organ/repair/coronary_bypass/on_success(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы успешно установили шунт на сердце [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] успешно установил шунт на сердце [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] успешно установил шунт на сердце [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Боль в груди пульсирует, но сердце чувствует себя лучше, чем когда-либо!")

/datum/surgery_operation/organ/repair/coronary_bypass/on_failure(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	organ.bodypart_owner?.adjustBleedStacks(30)
	var/blood_name = LOWER_TEXT(organ.owner?.get_bloodtype()?.get_blood_name()) || "крови"
	display_results(
		surgeon,
		organ.owner,
		span_warning("Вы ошибаетесь при креплении шунта, и он отрывается, повреждая часть сердца!"),
		span_warning("[surgeon] совершает ошибку, из-за чего поток [blood_name] обильно хлещет из груди [organ.owner.declent_ru(GENITIVE)]!"),
		span_warning("[surgeon] совершает ошибку, из-за чего поток [blood_name] обильно хлещет из груди [organ.owner.declent_ru(GENITIVE)]!"),
	)
	display_pain(organ.owner, "Грудь горит; кажется, вы сходите с ума от боли!")

/datum/surgery_operation/organ/repair/coronary_bypass/mechanic
	name = "Доступ к внутренностям сервомотора"
	rnd_name = "Диагностика сервомотора (Хирургия сердца)"
	implements = list(
		TOOL_CROWBAR = 1.05,
		TOOL_SCALPEL = 1.05,
		/obj/item/melee/energy/sword = 1.5,
		/obj/item/knife = 2.25,
		/obj/item/shard = 2.85,
	)
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/machines/airlock/doorclick.ogg'
	required_organ_flag = ORGAN_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/organ/repair/gastrectomy
	name = "Удаление поврежденной части желудка"
	rnd_name = "Гастрэктомия (Восстановление желудка)"
	desc = "Восстановление желудка пациента путем удаления поврежденного сегмента."
	implements = list(
		TOOL_SCALPEL = 1.05,
		/obj/item/melee/energy/sword = 1.5,
		/obj/item/knife = 2.25,
		/obj/item/shard = 2.85,
		/obj/item = 4,
	)
	time = 5.2 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/organ1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	target_type = /obj/item/organ/stomach
	heal_to_percent = 0.2
	failure_damage_percent = 0.15

/datum/surgery_operation/organ/repair/gastrectomy/get_any_tool()
	return "Любой острый предмет"

/datum/surgery_operation/organ/repair/gastrectomy/tool_check(obj/item/tool)
	// Require edged sharpness OR a tool behavior match
	return ((tool.get_sharpness() & SHARP_EDGED) || implements[tool.tool_behaviour])

/datum/surgery_operation/organ/repair/gastrectomy/on_preop(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы начинаете вырезать поврежденный фрагмент желудка [organ.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает делать надрез у [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает делать надрез у [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Вы чувствуете ужасную колющую боль в животе!")

/datum/surgery_operation/organ/repair/gastrectomy/on_success(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы успешно удаляете повреждённую часть желудка [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] успешно удаляет повреждённую часть желудка [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] успешно удаляет повреждённую часть желудка [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Боль в животе немного утихает!")

/datum/surgery_operation/organ/repair/gastrectomy/on_failure(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		organ.owner,
		span_warning("Вы отрезали не ту часть желудка [organ.owner.declent_ru(GENITIVE)]!"),
		span_warning("[surgeon] отрезал не ту часть желудка [organ.owner.declent_ru(GENITIVE)]!"),
		span_warning("[surgeon] отрезал не ту часть желудка [organ.owner.declent_ru(GENITIVE)]!"),
	)
	display_pain(organ.owner, "Боль в животе усиливается!")

/datum/surgery_operation/organ/repair/gastrectomy/mechanic
	name = "Проведение техобслуживания"
	rnd_name = "Диагностика системы переработки нутриентов (Хирургия желудка)"
	implements = list(
		TOOL_WRENCH = 1.05,
		TOOL_WRENCH = 1.05,
		TOOL_SCALPEL = 1.05,
		/obj/item/melee/energy/sword = 1.5,
		/obj/item/knife = 2.25,
		/obj/item/shard = 2.85,
		/obj/item = 4,
	)
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/machines/airlock/doorclick.ogg'
	required_organ_flag = ORGAN_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/organ/repair/ears
	name = "Операция на ушах"
	rnd_name = "Ототомия (Хирургия ушей)" // source: i made it up
	desc = "Восстановление поврежденных ушей пациента для возвращения слуха."
	operation_flags = parent_type::operation_flags & ~OPERATION_AFFECTS_MOOD
	implements = list(
		TOOL_HEMOSTAT = 1.05,
		TOOL_SCREWDRIVER = 2.25,
		/obj/item/pen = 4,
	)
	target_type = /obj/item/organ/ears
	time = 6.4 SECONDS
	heal_to_percent = 0
	repeatable = TRUE
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/organ/repair/ears/all_blocked_strings()
	return ..() + list("если в конечности есть кости, они должны быть целы")

/datum/surgery_operation/organ/repair/ears/state_check(obj/item/organ/ears/organ)
	// If bones are sawed, prevent the operation (unless we're operating on a limb with no bones)
	if(LIMB_HAS_ANY_SURGERY_STATE(organ.bodypart_owner, SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED) && LIMB_HAS_BONES(organ.bodypart_owner))
		return FALSE
	return TRUE // always available so you can intentionally fail it

/datum/surgery_operation/organ/repair/ears/on_preop(obj/item/organ/ears/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы начинаете лечить уши [organ.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает лечить уши [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает лечить уши [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Вы чувствуете головокружительную боль в голове!")

/datum/surgery_operation/organ/repair/ears/on_success(obj/item/organ/ears/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	var/deaf_change = 40 SECONDS - organ.temporary_deafness
	organ.adjust_temporary_deafness(deaf_change)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы успешно вылечили уши [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] успешно вылечил уши [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] успешно вылечил уши [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Голова идет кругом, но, кажется, слух начинает возвращаться!")

/datum/surgery_operation/organ/repair/ears/on_failure(obj/item/organ/ears/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/obj/item/organ/brain/brain = locate() in organ.bodypart_owner
	if(isnull(brain))
		display_results(
			surgeon,
			organ.owner,
			span_warning("Вы случайно тыкаете туда, где должен быть мозг [organ.owner.declent_ru(GENITIVE)]! Хорошо, что его там нет."),
			span_warning("[surgeon] случайно тыкает инструментом прямо в мозг [organ.owner.declent_ru(GENITIVE)]! Или сделал бы это, будь у пациента мозг."),
			span_warning("[surgeon] случайно попадает инструментом прямо в мозг [organ.owner.declent_ru(GENITIVE)]!"),
		)
		return

	display_results(
		surgeon,
		organ.owner,
		span_warning("Вы случайно тычите инструментом прямо в мозг [organ.owner.declent_ru(GENITIVE)]!"),
		span_warning("[surgeon] случайно тычет инструментом прямо в мозг [organ.owner.declent_ru(GENITIVE)]!"),
		span_warning("[surgeon] случайно тычет инструментом прямо в мозг [organ.owner.declent_ru(GENITIVE)]!"),
	)
	display_pain(organ.owner, "Вы чувствуете пронзающую боль, проходящую сквозь голову прямо в мозг!")
	organ.apply_organ_damage(70)

/datum/surgery_operation/organ/repair/eyes
	name = "Операция на глазах"
	rnd_name = "Витрэктомия (Хирургия глаз)"
	desc = "Восстановление поврежденных глаз пациента для возвращения зрения."
	operation_flags = parent_type::operation_flags & ~OPERATION_AFFECTS_MOOD
	implements = list(
		TOOL_HEMOSTAT = 1.05,
		TOOL_SCREWDRIVER = 2.25,
		/obj/item/pen = 4,
	)
	time = 6.4 SECONDS
	target_type = /obj/item/organ/eyes
	heal_to_percent = 0
	repeatable = TRUE
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/organ/repair/eyes/all_blocked_strings()
	return ..() + list("если в конечности есть кости, они должны быть целы")

/datum/surgery_operation/organ/repair/eyes/state_check(obj/item/organ/organ)
	// If bones are sawed, prevent the operation (unless we're operating on a limb with no bones)
	if(LIMB_HAS_ANY_SURGERY_STATE(organ.bodypart_owner, SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED) && LIMB_HAS_BONES(organ.bodypart_owner))
		return FALSE
	return TRUE // always available so you can intentionally fail it

/datum/surgery_operation/organ/repair/eyes/get_default_radial_image()
	return image(icon = 'icons/obj/medical/surgery_ui.dmi', icon_state = "surgery_eyes")

/datum/surgery_operation/organ/repair/eyes/on_preop(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы начинаете лечить глаза [organ.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает лечить глаза [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает лечить глаза [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Вы чувствуете колющую боль в глазах!")

/datum/surgery_operation/organ/repair/eyes/on_success(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	organ.owner?.remove_status_effect(/datum/status_effect/temporary_blindness)
	organ.owner?.set_eye_blur_if_lower(70 SECONDS) //this will fix itself slowly.
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы успешно вылечили глаза [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] успешно вылечил глаза [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] успешно вылечил глаза [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Зрение затуманено, но кажется, теперь вы видите немного лучше!")

/datum/surgery_operation/organ/repair/eyes/on_failure(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/obj/item/organ/brain/brain = locate() in organ.bodypart_owner
	if(isnull(brain))
		display_results(
			surgeon,
			organ.owner,
			span_warning("Вы случайно тыкаете туда, где должен быть мозг [organ.owner.declent_ru(GENITIVE)]! Хорошо, что его там нет."),
			span_warning("[surgeon] случайно тыкает инструментом прямо в мозг [organ.owner.declent_ru(GENITIVE)]! Или сделал бы это, будь у пациента мозг."),
			span_warning("[surgeon] случайно попадает инструментом прямо в мозг [organ.owner.declent_ru(GENITIVE)]!"),
		)
		return

	display_results(
		surgeon,
		organ.owner,
		span_warning("Вы случайно попадаете инструментом прямо в мозг [organ.owner.declent_ru(GENITIVE)]!"),
		span_warning("[surgeon] случайно попадает инструментом прямо в мозг [organ.owner.declent_ru(GENITIVE)]!"),
		span_warning("[surgeon] случайно попадает инструментом прямо в мозг [organ.owner.declent_ru(GENITIVE)]!"),
	)
	display_pain(organ.owner, "Вы чувствуете пронзающую боль, проходящую сквозь голову прямо в мозг!")
	organ.apply_organ_damage(70)

/datum/surgery_operation/organ/repair/brain
	name = "Операция на мозге"
	rnd_name = "Нейрохирургия (Хирургия мозга)"
	desc = "Восстановление поврежденных тканей мозга пациента для возвращения когнитивных функций."
	implements = list(
		TOOL_HEMOSTAT = 1.05,
		TOOL_SCREWDRIVER = 2.85,
		/obj/item/pen = 6.67,
	)
	time = 10 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	success_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	operation_flags = parent_type::operation_flags | OPERATION_LOOPING
	target_type = /obj/item/organ/brain
	heal_to_percent = 0.25
	failure_damage_percent = 0.3
	repeatable = TRUE
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/organ/repair/brain/state_check(obj/item/organ/brain/organ)
	return TRUE // always available so you can intentionally fail it

/datum/surgery_operation/organ/repair/brain/on_preop(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы начинаете лечить мозг [organ.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает лечить мозг [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает проводить операцию на мозге [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Ваша голова пульсирует от невообразимой боли!")

/datum/surgery_operation/organ/repair/brain/on_success(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	organ.apply_organ_damage(-organ.maxHealth * heal_to_percent) // no parent call, special healing for this one
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вам удалось прооперировать мозг [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] успешно оперирует мозг [organ.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] завершает операцию на мозге [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Боль в голове отступает, думать становится немного легче!")
	if (organ.owner)
		organ.owner.mind?.remove_antag_datum(/datum/antagonist/brainwashed)
	else if (organ.brainmob)
		organ.brainmob.mind?.remove_antag_datum(/datum/antagonist/brainwashed)
	organ.cure_all_traumas(TRAUMA_RESILIENCE_SURGERY)
	if(organ.damage > organ.maxHealth * 0.1)
		to_chat(surgeon, "Мозг [organ.owner.declent_ru(GENITIVE)] выглядит так, будто его можно вылечить еще немного.")

/datum/surgery_operation/organ/repair/brain/on_failure(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		organ.owner,
		span_warning("Вы совершаете ошибку, нанося еще больше повреждений!"),
		span_warning("[surgeon] совершает ошибку, вызывая повреждение мозга!"),
		span_notice("[surgeon] завершает операцию на мозге [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Ваша голова пульсирует от ужасной боли; даже думать больно!")
	organ.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)

/datum/surgery_operation/organ/repair/brain/mechanic
	name = "Проведение нейронной отладки"
	rnd_name = "Wetware OS диагностика (Хирургия мозга)"
	implements = list(
		TOOL_MULTITOOL = 1.15,
		TOOL_HEMOSTAT = 1.05,
		TOOL_SCREWDRIVER = 2.85,
		/obj/item/pen = 6.67,
	)
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'
	required_organ_flag = ORGAN_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC
