#define OPERATION_OBJECTIVE "objective"

/datum/surgery_operation/organ/brainwash
	name = "Промывание мозгов"
	desc = "Внедрение директивы в мозг пациента, сделав её его абсолютным приоритетом."
	rnd_name = "Нейронное промывание мозгов (Промывание мозгов)"
	rnd_desc = "Хирургическая процедура, которая непосредственно внедряет директиву в мозг пациента, \
		что делает её абсолютным приоритетом. Это можно устранить с помощью импланта «Защита Разума»."
	implements = list(
		TOOL_HEMOSTAT = 1.15,
		TOOL_WIRECUTTER = 2,
		/obj/item/stack/package_wrap = 2.85,
		/obj/item/stack/cable_coil = 6.67,
	)
	time = 20 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	success_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	operation_flags = OPERATION_MORBID | OPERATION_NOTABLE | OPERATION_LOCKED
	target_type = /obj/item/organ/brain
	required_organ_flag = ORGAN_TYPE_FLAGS & ~ORGAN_ROBOTIC
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|SURGERY_BONE_SAWED

/datum/surgery_operation/organ/brainwash/get_default_radial_image()
	return image(/atom/movable/screen/alert/hypnosis::overlay_icon, /atom/movable/screen/alert/hypnosis::overlay_state)

/datum/surgery_operation/organ/brainwash/pre_preop(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	operation_args[OPERATION_OBJECTIVE] = tgui_input_text(surgeon, "Выберите цель, которая будет запечатлена в мозгу вашего пациента", "Промывание мозгов", max_length = MAX_MESSAGE_LEN)
	return !!operation_args[OPERATION_OBJECTIVE]

/datum/surgery_operation/organ/brainwash/on_preop(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы начинаете промывание мозгов у [organ.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает лечить мозг [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] приступает к выполнению операции на мозге [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Твоя голова раскалывается от невообразимой боли!") // Same message as other brain surgeries

/datum/surgery_operation/organ/brainwash/on_success(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	if(!organ.owner.mind)
		to_chat(surgeon, span_warning("[organ.owner.declent_ru(NOMINATIVE)] не реагирует на промывание мозгов, как будто [ru_p_they()] нет разума..."))
		return ..()
	if(HAS_MIND_TRAIT(organ.owner, TRAIT_UNCONVERTABLE))
		to_chat(surgeon, span_warning("[organ.owner.declent_ru(GENITIVE)], похоже, не поддается промыванию мозгов..."))
		return ..()

	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы успешно промыли мозги [organ.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] успешно промыл мозги [organ.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] заканчивает выполнение операции на мозге [organ.owner.declent_ru(GENITIVE)]."),
	)
	on_brainwash(organ.owner, surgeon, tool, operation_args)

/datum/surgery_operation/organ/brainwash/proc/on_brainwash(mob/living/carbon/brainwashed, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/objective = operation_args[OPERATION_OBJECTIVE] || "Oooo no objective set somehow report this to an admin"
	to_chat(brainwashed, span_notice("Новая мысль формируется в вашем разуме: «[objective]»"))
	brainwash(brainwashed, objective)
	message_admins("[ADMIN_LOOKUPFLW(surgeon)] surgically brainwashed [ADMIN_LOOKUPFLW(brainwashed)] with the objective '[objective]'.")
	surgeon.log_message("has brainwashed [key_name(brainwashed)] with the objective '[objective]' using brainwashing surgery.", LOG_ATTACK)
	brainwashed.log_message("has been brainwashed with the objective '[objective]' by [key_name(surgeon)] using brainwashing surgery.", LOG_VICTIM, log_globally=FALSE)
	surgeon.log_message("surgically brainwashed [key_name(brainwashed)] with the objective '[objective]'.", LOG_GAME)

/datum/surgery_operation/organ/brainwash/on_failure(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы облажались, повредив мозговую ткань!"),
		span_notice("[surgeon] облажался, что привело к повреждению мозга!"),
		span_notice("[surgeon] заканчивает операцию на мозге [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Your head throbs with horrible pain!")
	organ.apply_organ_damage(40)

/datum/surgery_operation/organ/brainwash/mechanic
	name = "Перепрограммирование"
	rnd_name = "Нейронное перепрограммирование (Промывание мозгов)"
	rnd_desc = "Установка вредоносного ПО, которое непосредственно внедряет директиву в операционную систему робота-пациента, \
		делая это своим абсолютным приоритетом. Это можно устранить с помощью импланта «Защита Разума»."
	implements = list(
		TOOL_MULTITOOL = 1.15,
		TOOL_HEMOSTAT = 2,
		TOOL_WIRECUTTER = 2,
		/obj/item/stack/package_wrap = 2.85,
		/obj/item/stack/cable_coil = 6.67,
	)
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'
	required_organ_flag = ORGAN_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/organ/brainwash/sleeper
	name = "Установить директивы спящего агента"
	rnd_name = "Имплантация спящего агента (Промывание мозгов)"
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	success_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'

	var/list/possible_objectives = list(
		"Вы любите Синдикат.",
		"Не доверяйте Нанотрейзен.",
		"Капитан - унатх.",
		"Нанотрейзен не настоящий.",
		"Они подкладывают что-то в еду, чтобы вы забыли.",
		"Только вы настоящая личность на этой станции.",
		"На станции было бы намного лучше, если бы больше людей кричали. Кто-то должен что-то с этим сделать.",
		"У здешних глав только дурные намерения по отношению к команде.",
		"Помогаете экипажу? Что они вообще когда-нибудь делали для вас?",
		"Твоя сумка стала легче на ощупь? Держу пари, те парни из службы безопасности что-то из нее украли. Пойди и верни это.",
		"Командование некомпетентно, кто-то, обладающий РЕАЛЬНОЙ властью, должен взять это на себя.",
		"Киборги и ИИ преследуют вас. Что они планируют?",
	)

/datum/surgery_operation/organ/brainwash/sleeper/pre_preop(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	operation_args[OPERATION_OBJECTIVE] = pick(possible_objectives)
	return TRUE

/datum/surgery_operation/organ/brainwash/sleeper/on_preop(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы начинаете промывание мозгов у [organ.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает лечить мозг [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] приступает к выполнению операции на мозге [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Your head pounds with unimaginable pain!") // Same message as other brain surgeries

/datum/surgery_operation/organ/brainwash/sleeper/on_brainwash(mob/living/carbon/brainwashed, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	brainwashed.gain_trauma(new /datum/brain_trauma/mild/phobia/conspiracies(), TRAUMA_RESILIENCE_LOBOTOMY)

/datum/surgery_operation/organ/brainwash/sleeper/mechanic
	name = "Установить программу спящего агента"
	rnd_name = "Программирование спящего агента (Промывание мозгов)"
	implements = list(
		TOOL_MULTITOOL = 1.15,
		TOOL_HEMOSTAT = 2,
		TOOL_WIRECUTTER = 2,
		/obj/item/stack/package_wrap = 2.85,
		/obj/item/stack/cable_coil = 6.67,
	)
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'
	required_organ_flag = ORGAN_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

#undef OPERATION_OBJECTIVE
