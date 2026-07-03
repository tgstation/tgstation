/datum/surgery_operation/organ/pacify
	name = "pacification"
	rnd_name = "Паксопсия (Пацификация)"
	desc = "Удаление агрессивных наклонностей из мозга пациента."
	rnd_desc = "Хирургическая процедура, которая навсегда подавляет центр агрессии в мозгу, лишая пациента желания наносить прямой вред."
	operation_flags = OPERATION_MORBID | OPERATION_LOCKED | OPERATION_NOTABLE | OPERATION_NO_PATIENT_REQUIRED
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_SCREWDRIVER = 2.85,
		/obj/item/pen = 6.67,
	)
	time = 4 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	success_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	required_organ_flag = ORGAN_TYPE_FLAGS & ~ORGAN_ROBOTIC
	target_type = /obj/item/organ/brain
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/organ/pacify/get_default_radial_image()
	return image(/atom/movable/screen/alert/status_effect/high::overlay_icon, /atom/movable/screen/alert/status_effect/high::overlay_state)

/datum/surgery_operation/organ/pacify/on_preop(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы начинаете пацификацию [organ.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает оперировать мозг [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает проводить операцию на мозге [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Ваша голова разрывается от невообразимой боли!")

/datum/surgery_operation/organ/pacify/on_success(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вам удалось пацифицировать [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] успешно оперирует мозг [organ.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] завершает операцию на мозге [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Ваша голова пульсирует... мысль о насилии вспыхивает в вашем разуме, и вас едва не выворачивает наизнанку!")
	organ.gain_trauma(/datum/brain_trauma/severe/pacifism, TRAUMA_RESILIENCE_LOBOTOMY)

/datum/surgery_operation/organ/pacify/on_failure(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы совершаете ошибку, перепутав все связи в мозгу [organ.owner.declent_ru(GENITIVE)]..."),
		span_warning("[surgeon] совершает ошибку, вызывая повреждение мозга!"),
		span_notice("[surgeon] завершает операцию на мозге [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Ваша голова пульсирует, и кажется, становится только хуже!")
	organ.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)

/datum/surgery_operation/organ/pacify/mechanic
	name = "Удаление программы агрессии"
	rnd_name = "Программирование подавления агрессии (Пацификация)"
	rnd_desc = "Установка вредоносного ПО, которое навсегда подавляет программы агрессии в нейронной сети пациента, лишая его желания наносить прямой вред."
	implements = list(
		TOOL_MULTITOOL = 1,
		TOOL_HEMOSTAT = 2.85,
		TOOL_SCREWDRIVER = 2.85,
		/obj/item/pen = 6.67,
	)
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'
	failure_sound = null
	required_organ_flag = ORGAN_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC
