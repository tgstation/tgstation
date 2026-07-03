/datum/surgery_operation/organ/stomach_pump
	name = "Промывание желудка"
	rnd_name = "Гастральный лаваж (Промывание)"
	desc = "Ручное промывание желудка пациента для вызова рвоты и выведения вредных химикатов."
	operation_flags = OPERATION_NOTABLE
	implements = list(
		IMPLEMENT_HAND = 1,
	)
	time = 2 SECONDS
	required_organ_flag = ORGAN_TYPE_FLAGS & ~ORGAN_ROBOTIC
	target_type = /obj/item/organ/stomach
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT

/datum/surgery_operation/organ/stomach_pump/get_default_radial_image()
	return image(/atom/movable/screen/alert/disgusted::overlay_icon, /atom/movable/screen/alert/disgusted::overlay_state)

/datum/surgery_operation/organ/stomach_pump/all_required_strings()
	return ..() + list("пациент не должен быть хаском")

/datum/surgery_operation/organ/stomach_pump/state_check(obj/item/organ/stomach/organ)
	return !HAS_TRAIT(organ.owner, TRAIT_HUSK)

/datum/surgery_operation/organ/stomach_pump/on_preop(obj/item/organ/stomach/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы начинаете промывать желудок [organ.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает промывать желудок [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает давить на живот [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Вы чувствуете ужасное хлюпанье внутри! Вас сейчас стошнит!")

/datum/surgery_operation/organ/stomach_pump/on_success(obj/item/organ/stomach/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("[surgeon] заставляет [organ.owner.declent_ru(GENITIVE)] вырвать, очищая желудок от части химикатов!"),
		span_notice("[surgeon] заставляет [organ.owner.declent_ru(GENITIVE)] вырвать, очищая желудок от части химикатов!"),
		span_notice("[surgeon] заставляет [organ.owner.declent_ru(GENITIVE)] вырвать!"),
	)
	organ.owner.vomit((MOB_VOMIT_MESSAGE | MOB_VOMIT_STUN), lost_nutrition = 20, purge_ratio = 0.67)

/datum/surgery_operation/organ/stomach_pump/on_failure(obj/item/organ/stomach/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_warning("Вы совершаете ошибку, оставляя синяк на груди [organ.owner.declent_ru(GENITIVE)]!"),
		span_warning("[surgeon] совершает ошибку, оставляя синяк на груди [organ.owner.declent_ru(GENITIVE)]!"),
		span_warning("[surgeon] совершает ошибку!"),
	)
	organ.apply_organ_damage(5)
	organ.bodypart_owner.receive_damage(5)

/datum/surgery_operation/organ/stomach_pump/mechanic
	name = "Очистка нутриент-процессора"
	rnd_name = "Очистка нутриент-процессора (Промывание)"
	required_organ_flag = ORGAN_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC
