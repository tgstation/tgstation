/datum/surgery_operation/limb/bioware
	abstract_type = /datum/surgery_operation/limb/bioware
	implements = list(
		IMPLEMENT_HAND = 1,
	)
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE | OPERATION_MORBID | OPERATION_LOCKED
	required_bodytype = ~BODYTYPE_ROBOTIC
	time = 12.5 SECONDS
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED|SURGERY_ORGANS_CUT
	/// What status effect is gained when the surgery is successful?
	/// Used to check against other bioware types to prevent stacking.
	var/datum/status_effect/status_effect_gained = /datum/status_effect/bioware
	/// Zone to operate on for this bioware
	var/required_zone = BODY_ZONE_CHEST

/datum/surgery_operation/limb/bioware/get_default_radial_image()
	return image('icons/hud/implants.dmi', "lighting_bolt")

/datum/surgery_operation/limb/bioware/all_required_strings()
	return list("операция на [parse_zone(required_zone)] (цель [parse_zone(required_zone)])") + ..()

/datum/surgery_operation/limb/bioware/all_blocked_strings()
	var/list/incompatible_surgeries = list()
	for(var/datum/surgery_operation/limb/bioware/other_bioware as anything in subtypesof(/datum/surgery_operation/limb/bioware))
		if(other_bioware::status_effect_gained::id != status_effect_gained::id)
			continue
		if(other_bioware::required_bodytype != required_bodytype)
			continue
		incompatible_surgeries += (other_bioware.rnd_name || other_bioware.name)

	return ..() + list("пациент ранее не должен был проходить [english_list(incompatible_surgeries, and_text = " OR ")]")

/datum/surgery_operation/limb/bioware/state_check(obj/item/bodypart/limb)
	if(limb.body_zone != required_zone)
		return FALSE
	if(limb.owner.has_status_effect(status_effect_gained))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/bioware/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	limb.owner.apply_status_effect(status_effect_gained)
	if(limb.owner.ckey)
		SSblackbox.record_feedback("tally", "bioware", 1, status_effect_gained)

/datum/surgery_operation/limb/bioware/vein_threading
	name = "Венозная нить"
	rnd_name = "Симваскулодез (Венозная нить)" // "together vessel fusion"
	desc = "Сплетение вен пациента в усиленную сетку, для уменьшения кровопотери при травмах."
	status_effect_gained = /datum/status_effect/bioware/heart/threaded_veins

/datum/surgery_operation/limb/bioware/vein_threading/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете плести кровеносную систему у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает плести кровеносную систему у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает манипулировать кровеносной системой у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Всё ваше тело горит в агонии!")

/datum/surgery_operation/limb/bioware/vein_threading/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы сплетаете кровеносную систему у [limb.owner.declent_ru(GENITIVE)] в прочную сеть!"),
		span_notice("[surgeon] сплетает кровеносную систему у [limb.owner.declent_ru(GENITIVE)] в прочную сеть!"),
		span_notice("[surgeon] завершает манипуляцию кровеносной системой у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы можете почувствовать, как кровь движется по усиленным венам!")

/datum/surgery_operation/limb/bioware/vein_threading/mechanic
	rnd_name = "Оптимизация маршрутизации гидравлики (Венозная нить)"
	desc = "Оптимизирование работы гидравлической системы роботизированного пациента, для снижения потери жидкости из-за утечек."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/limb/bioware/muscled_veins
	name = "Мышечная мембрана вены"
	rnd_name = "Миоваскулопластика (Мышечная мембрана вены)" // "muscle vessel reshaping"
	desc = "Добавление мышечной оболочки к венам пациента, что позволит ему перекачивать кровь без участия сердца."
	status_effect_gained = /datum/status_effect/bioware/heart/muscled_veins

/datum/surgery_operation/limb/bioware/muscled_veins/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете обматывать мышцами кровеносные сосуды у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает обматывать мышцами кровеносные сосуды у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает манипулировать кровеносной системой у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Всё ваше тело горит в агонии!")

/datum/surgery_operation/limb/bioware/muscled_veins/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы изменяете форму кровеносных сосудов у [limb.owner.declent_ru(GENITIVE)], добавляя мышечную оболочку!"),
		span_notice("[surgeon] изменяет форму кровеносных сосудов  у [limb.owner.declent_ru(GENITIVE)], добавляя мышечную оболочку!"),
		span_notice("[surgeon] завершает манипуляцию кровеносной системой у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы можете чувствовать, как мощные удары вашего сердца разносятся по всему телу!")

/datum/surgery_operation/limb/bioware/muscled_veins/mechanic
	rnd_name = "Подпрограмма резервирования гидравлики (Мышечная мембрана вены)"
	desc = "Добавление избыточности в гидравлическую систему роботизированного пациента, что позволяет ему перекачивать жидкости без двигателя или насоса."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/limb/bioware/nerve_splicing
	name = "Сращивание нервов"
	rnd_name = "Симневродез (Сращивание нервов)" // "together nerve fusion"
	desc = "Соединение нервов пациента вместе, чтобы сделать их более устойчивыми к оглушению."
	time = 15.5 SECONDS
	status_effect_gained = /datum/status_effect/bioware/nerves/spliced

/datum/surgery_operation/limb/bioware/nerve_splicing/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете соединять нервы  у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает соединять нервы у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает манипулировать нервной системой у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Все ваше тело немеет!")

/datum/surgery_operation/limb/bioware/nerve_splicing/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы успешно сращиваете нервную систему у [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] успешно сращивает нервную систему у [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] завершает манипулирование нервной системойу [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы вновь обретаете чувствительность в своем теле; вам кажется, что всё происходит вокруг вас в замедлении!")

/datum/surgery_operation/limb/bioware/nerve_splicing/mechanic
	rnd_name = "Подпрограмма автоматического сброса системы (Сращивание нервов)"
	desc = "Модернизирование автоматических систем роботизированного пациента, чтобы он мог лучше противостоять оглушению."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/limb/bioware/nerve_grounding
	name = "Заземление нервов"
	rnd_name = "Ксантоневропластика (Заземление нервов)" // "yellow nerve reshaping". see: yellow gloves
	desc = "Перенаправление нервов пациента так, чтобы они действовали как заземляющие стержни, защищая их от поражения электрическим током."
	time = 15.5 SECONDS
	status_effect_gained = /datum/status_effect/bioware/nerves/grounded

/datum/surgery_operation/limb/bioware/nerve_grounding/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете перенаправлять нервы у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает перенаправлять нервы у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает манипулировать нервной системой у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Все ваше тело немеет!")

/datum/surgery_operation/limb/bioware/nerve_grounding/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы успешно перенаправляете нервную систему у [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] успешно перенаправляет нервы у [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] завершает манипулирование нервной системой у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы возвращаете своему телу ощущение свежести! Вы чувствуете прилив сил!")

/datum/surgery_operation/limb/bioware/nerve_grounding/mechanic
	rnd_name = "Система гашения ударов (Заземление нервов)"
	desc = "Установка заземляющих стержней в нервную систему роботизированного пациента, защищая её от поражения электрическим током."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/limb/bioware/ligament_hook
	name = "Изменение формы связок"
	rnd_name = "Артропластика (Крюк для связок)" // "joint reshaping"
	desc = "Изменение формы связок пациента, чтобы в случае отсоединения конечности её можно было прикрепить вручную, за счет облегчения отсоединения конечностей."
	status_effect_gained = /datum/status_effect/bioware/ligaments/hooked

/datum/surgery_operation/limb/bioware/ligament_hook/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете придавать связкам у [limb.owner.declent_ru(GENITIVE)] форму крючка."),
		span_notice("[surgeon] начинает перестраивать связки у [limb.owner.declent_ru(GENITIVE)], придавая им форму крючка."),
		span_notice("[surgeon] начинает манипулировать связками у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Ваши конечности горят от сильной боли!")

/datum/surgery_operation/limb/bioware/ligament_hook/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы придаете связкам у [limb.owner.declent_ru(GENITIVE)] форму крючка!"),
		span_notice("[surgeon] придает связкам у [limb.owner.declent_ru(GENITIVE)] форму крючка!"),
		span_notice("[surgeon] заканчивает манипулирование связками у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Ваши конечности кажутся... странно свободными.")

/datum/surgery_operation/limb/bioware/ligament_hook/mechanic
	rnd_name = "Защелкивающиеся точки крепления (Крюк для связок)"
	desc = "Преобразование суставов конечностей роботизированного пациента таким образом, чтобы обеспечить быструю фиксацию и возможность повторного прикрепления конечностей вручную в случае их отсоединения - \
		за счет того, что конечности легче отсоединить."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/limb/bioware/ligament_reinforcement
	name = "Укрепление связок"
	rnd_name = "Артрорафия (Укрепление связок)" // "joint strengthening" / "joint stitching"
	desc = "Укрепление связок пациента, чтобы затруднить расчленение за счет облегчения прерывания нервных связей."
	status_effect_gained = /datum/status_effect/bioware/ligaments/reinforced

/datum/surgery_operation/limb/bioware/ligament_reinforcement/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете укреплять связки у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает укреплять связки у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает манипулировать связками у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Ваши конечности горят от сильной боли!")

/datum/surgery_operation/limb/bioware/ligament_reinforcement/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы укрепляете связки у [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] укрепляет связки у [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] заканчивает манипулирование связками у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Ваши конечности чувствуют себя более защищенными, но также более хрупкими.")

/datum/surgery_operation/limb/bioware/ligament_reinforcement/mechanic
	rnd_name = "Укрепление опорной точки (Укрепление связок)"
	desc = "Укрепление суставов конечностей роботизированного пациента, чтобы предотвратить расчленение, за счет облегчения разрыва нервных связей."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/limb/bioware/cortex_folding
	name = "Складывание коры"
	rnd_name = "Энцефалофрактопластика (Складывание коры)" // it's a stretch - "brain fractal reshaping"
	desc = "Биологическая модернизация, которая преобразует кору головного мозга пациента во фрактальный узор, повышая плотность и гибкость нейронов."
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE | OPERATION_MORBID | OPERATION_LOCKED | OPERATION_NO_PATIENT_REQUIRED
	status_effect_gained = /datum/status_effect/bioware/cortex // Not actually applied, simply for compatibility checks
	required_zone = BODY_ZONE_HEAD

/datum/surgery_operation/limb/bioware/cortex_folding/state_check(obj/item/bodypart/limb)
	. = ..()
	if (!.)
		return
	var/obj/item/organ/brain/brain = locate() in limb
	if(isnull(brain))
		return FALSE
	return !HAS_TRAIT_FROM(brain, TRAIT_SPECIAL_TRAUMA_BOOST, BIOWARE_TRAIT)

/datum/surgery_operation/limb/bioware/cortex_folding/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	var/obj/item/organ/brain/brain = locate() in limb
	if(!isnull(brain))
		ADD_TRAIT(brain, TRAIT_SPECIAL_TRAUMA_BOOST, BIOWARE_TRAIT)

/datum/surgery_operation/limb/bioware/cortex_folding/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете складывать внешнюю кору головного мозга у [limb.owner.declent_ru(NOMINATIVE)] во фрактальный узор."),
		span_notice("[surgeon] начинает складывать внешнюю кору головного мозга у [limb.owner.declent_ru(NOMINATIVE)] во фрактальный узор."),
		span_notice("[surgeon] начинает проводить операцию на мозге у [limb.owner.declent_ru(NOMINATIVE)]."),
	)
	display_pain(limb.owner, "Ваша голова раскалывается от ужасной боли, с ней почти невозможно справиться!")

/datum/surgery_operation/limb/bioware/cortex_folding/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы складываете внешнюю кору головного мозга у [limb.owner.declent_ru(NOMINATIVE)] во фрактальный узор!"),
		span_notice("[surgeon] складывает внешнюю кору головного мозга у [limb.owner.declent_ru(NOMINATIVE)] во фрактальный узор!"),
		span_notice("[surgeon] завершает операцию на мозге у [limb.owner.declent_ru(NOMINATIVE)]."),
	)
	display_pain(limb.owner, "Ваш мозг становится сильнее... более гибким!")

/datum/surgery_operation/limb/bioware/cortex_folding/on_failure(obj/item/bodypart/limb, mob/living/surgeon, tool)
	var/obj/item/organ/brain/brain = locate() in limb
	if(isnull(brain))
		return ..()
	display_results(
		surgeon,
		limb.owner,
		span_warning("Вы ошибаетесь, повреждая мозг!"),
		span_warning("[surgeon] ошибается, нанеся повреждения мозгу!"),
		span_notice("[surgeon] завершает операцию на мозге у [limb.owner.declent_ru(NOMINATIVE)]."),
	)
	display_pain(limb.owner, "Ваша голова раскалывается от мучительной боли!")
	brain.apply_organ_damage(60)
	brain.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)

/datum/surgery_operation/limb/bioware/cortex_folding/mechanic
	rnd_name = "Лабиринтное программирование Wetware OS (Складывание коры)"
	desc = "Перепрограммирование нейронной сети роботизированного пациента на совершенно необычном языке программирования, предоставив пространство для нестандартных нейронных паттернов."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/limb/bioware/cortex_imprint
	name = "Отпечаток коры"
	rnd_name = "Энцефалопластика (Отпечаток коры)" // it's a stretch - "brain print reshaping"
	desc = "Биологическая модернизация, которая формирует самозапечатлевающийся узор на коре головного мозга пациента, увеличивая плотность и устойчивость нервных клеток."
	status_effect_gained = /datum/status_effect/bioware/cortex/imprinted
	required_zone = BODY_ZONE_HEAD

/datum/surgery_operation/limb/bioware/cortex_imprint/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете вырезать на внешней коре головного мозга у [limb.owner.declent_ru(GENITIVE)] самопечатающийся шаблон."),
		span_notice("[surgeon] начинает вырезать на внешней коре головного мозга у [limb.owner.declent_ru(GENITIVE)] самопечатающийся шаблон."),
		span_notice("[surgeon]  начинает проводить операцию на мозге у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Ваша голова раскалывается от ужасной боли, с ней почти невозможно справиться!")

/datum/surgery_operation/limb/bioware/cortex_imprint/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы преобразуете внешнюю кору головного мозга у [limb.owner.declent_ru(GENITIVE)] в самопечатающийся шаблон!"),
		span_notice("[surgeon] перестраивает внешнюю кору головного мозга у [limb.owner.declent_ru(GENITIVE)] в самопечатающийся шаблон!"),
		span_notice("[surgeon] завершает операцию на мозге у у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Ваш мозг становится сильнее... более устойчивым!")

/datum/surgery_operation/limb/bioware/cortex_imprint/on_failure(obj/item/bodypart/limb, mob/living/surgeon, tool)
	if(!limb.owner.get_organ_slot(ORGAN_SLOT_BRAIN))
		return ..()
	display_results(
		surgeon,
		limb.owner,
		span_warning("Вы ошибаетесь, повреждая мозг!"),
		span_warning("[surgeon] ошибается, нанеся повреждения мозгу!"),
		span_notice("[surgeon] завершает операцию на мозге у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Голова раскалывается от ужасной боли; от одной мысли об этом уже начинает болеть голова!")
	limb.owner.adjust_organ_loss(ORGAN_SLOT_BRAIN, 60)
	limb.owner.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)

/datum/surgery_operation/limb/bioware/cortex_imprint/mechanic
	rnd_name = "Wetware OS Версия 2.0 (Отпечаток коры)"
	desc = "Обновление операционной системы роботизированного пациента до «новой версии», повысив общую производительность и надежность. \
		Жаль, что все это рекламное ПО."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC
