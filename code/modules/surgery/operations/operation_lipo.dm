/datum/surgery_operation/limb/lipoplasty
	name = "Липопластика"
	rnd_name = "Липопластика (Удаление жира)"
	desc = "Удаление лишнего жира из тела пациента."
	operation_flags = OPERATION_NOTABLE | OPERATION_AFFECTS_MOOD
	implements = list(
		TOOL_SAW = 1,
		TOOL_SCALPEL = 1.25,
		/obj/item/shovel/serrated = 1.33,
		/obj/item/melee/energy/sword = 1.33,
		/obj/item/hatchet = 3.33,
		/obj/item/knife = 3.33,
		/obj/item = 5,
	)
	time = 6.4 SECONDS
	required_bodytype = ~BODYTYPE_ROBOTIC
	preop_sound = list(
		/obj/item/circular_saw = 'sound/items/handling/surgery/saw.ogg',
		/obj/item = 'sound/items/handling/surgery/scalpel1.ogg',
	)
	success_sound = 'sound/items/handling/surgery/organ2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/limb/lipoplasty/get_any_tool()
	return "Любой острый предмет"

/datum/surgery_operation/limb/lipoplasty/get_default_radial_image()
	return image(/obj/item/food/meat/slab/human)

/datum/surgery_operation/limb/lipoplasty/all_required_strings()
	. = list()
	. += "Операция на груди"
	. += ..()
	. += "Пациент должен иметь лишний жир для удаления"

/datum/surgery_operation/limb/lipoplasty/tool_check(obj/item/tool)
	// Require edged sharpness OR a tool behavior match
	return ((tool.get_sharpness() & SHARP_EDGED) || implements[tool.tool_behaviour])

/datum/surgery_operation/limb/lipoplasty/state_check(obj/item/bodypart/limb)
	if(limb.body_zone != BODY_ZONE_CHEST)
		return FALSE
	if(HAS_TRAIT(limb.owner, TRAIT_NOHUNGER))
		return FALSE
	if(!HAS_TRAIT_FROM(limb.owner, TRAIT_FAT, OBESITY) || limb.owner.nutrition < NUTRITION_LEVEL_WELL_FED)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/lipoplasty/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете срезать лишний жир у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает срезать лишний жир у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает резать [limb.ru_plaintext_zone[ACCUSATIVE]] у [limb.owner.declent_ru(GENITIVE)] с помощью [tool.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы чувствуете колющую боль в [limb.ru_plaintext_zone[PREPOSITIONAL]]!")

/datum/surgery_operation/limb/lipoplasty/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы успешно удалили лишний жир из тела [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] успешно удаляет лишний жир из тела [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] заканчивает срезать лишний жир из [limb.ru_plaintext_zone[GENITIVE]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	var/removednutriment = limb.owner.nutrition
	limb.owner.overeatduration = 0 //patient is unfatted
	limb.owner.set_nutrition(NUTRITION_LEVEL_WELL_FED)
	removednutriment -= NUTRITION_LEVEL_WELL_FED //whatever was removed goes into the meat

	if(limb.owner.flags_1 & HOLOGRAM_1)
		return

	var/typeofmeat = null
	for(var/meat_path in limb.butcher_drops)
		if(ispath(meat_path, /obj/item/food/meat))
			typeofmeat = meat_path
			break

	if(!typeofmeat)
		return

	var/obj/item/food/meat/slab/newmeat = new typeofmeat(limb.owner.drop_location())
	newmeat.name = "жирное мясо"
	newmeat.desc = "Чрезвычайно жирная ткань, извлеченная из пациента."
	newmeat.subjectname = limb.owner.real_name
	newmeat.subjectjob = limb.owner.job
	newmeat.reagents.add_reagent(/datum/reagent/consumable/nutriment, (removednutriment / /datum/reagent/consumable/nutriment::nutriment_factor))

/datum/surgery_operation/limb/lipoplasty/mechanic
	name = "Задействовать выпускной клапан" //gross
	rnd_name = "Выброс питательных резервов (Удаление жира)"
	implements = list(
		TOOL_WRENCH = 1.05,
		TOOL_CROWBAR = 1.05,
		/obj/item/shovel/serrated = 1.33,
		/obj/item/melee/energy/sword = 1.33,
		TOOL_SAW = 1.67,
		/obj/item/hatchet = 3.33,
		/obj/item/knife = 3.33,
		TOOL_SCALPEL = 4,
		/obj/item = 5,
	)
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/items/handling/surgery/organ2.ogg'
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC
