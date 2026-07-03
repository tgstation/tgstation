#define CHOICE_CRITICAL_TYPE "Открытый перелом"
#define CHOICE_SEVERE_TYPE "Закрытый перелом"
#define CHOICE_MODERATE_TYPE "Вывих конечности"
#define ALL_BODYTYPES list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
#define ALL_LIMBS list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)

/datum/smite/broken_limb
	name = "Broken limb"
	var/targeted_limb
	var/blunt_type

/datum/smite/broken_limb/configure(client/user)
	var/blunt_choice = tgui_input_list(user,
		"Какой тип перелома необходим?",
		"Тип перелома?",
		list(CHOICE_CRITICAL_TYPE, CHOICE_SEVERE_TYPE, CHOICE_MODERATE_TYPE))
	if(!blunt_choice)
		return FALSE
	blunt_type = blunt_choice

	var/limb_selection_choice = tgui_input_list(user,
		"Какую конечность ломаем?",
		"Нужная конечность?",
		blunt_choice != CHOICE_MODERATE_TYPE ? ALL_BODYTYPES : ALL_LIMBS)
	if(!limb_selection_choice)
		return FALSE
	targeted_limb = limb_selection_choice
	return TRUE

/datum/smite/broken_limb/effect(client/user, mob/living/target)
	. = ..()

	if (!iscarbon(target))
		to_chat(user, span_warning("Этот смайт можно использовать только на карбонах."), confidential = TRUE)
		return
	var/mob/living/carbon/carbon_target = target

	var/obj/item/bodypart/bodypart = carbon_target.get_bodypart(targeted_limb)
	if(!IS_ORGANIC_LIMB(bodypart))
		to_chat(user, span_warning("У цели нет выбранной органической части тела или она не является органической."), confidential = TRUE)
		return FALSE

	var/severity = blunt_type == CHOICE_SEVERE_TYPE ? WOUND_SEVERITY_SEVERE : \
					blunt_type == CHOICE_MODERATE_TYPE ? WOUND_SEVERITY_MODERATE : WOUND_SEVERITY_CRITICAL
	carbon_target.cause_wound_of_type_and_severity(WOUND_BLUNT, bodypart, severity)

#undef CHOICE_CRITICAL_TYPE
#undef CHOICE_SEVERE_TYPE
#undef CHOICE_MODERATE_TYPE
#undef ALL_BODYTYPES
#undef ALL_LIMBS
