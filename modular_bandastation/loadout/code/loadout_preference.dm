/datum/preference_middleware/loadout/on_new_character(mob/user)
	preferences.loadout_points = preferences.get_loadout_points()
	.=..()

// Handles selecting from the preferences UI
/datum/preference_middleware/loadout/select_item(datum/loadout_item/selected_item)
	var/donator_level = preferences.parent.get_donator_level()
	if(preferences.loadout_points >= selected_item.cost && donator_level >= selected_item.donator_level)
		return ..()
	else if(donator_level < selected_item.donator_level)
		to_chat(preferences.parent.mob, span_warning("У вас недостаточный уровень доната, чтобы взять [selected_item.name]!"))
	else
		to_chat(preferences.parent.mob, span_warning("У вас недостаточно свободных очков лодаута, чтобы взять [selected_item.name]!"))

// Removes donator_level items from the user if their donator_level is insufficient
/datum/preference/loadout/deserialize(input, datum/preferences/preferences)
	. = ..()
	// For loadout purposes, donator_level is updated in middleware on select
	INVOKE_ASYNC(src, TYPE_PROC_REF(/datum/preference/loadout, loadout_process), input, preferences, .)

/datum/preference/loadout/proc/loadout_process(input, datum/preferences/preferences, result)
	var/donator_level = preferences.parent.get_donator_level()
	var/total_cost = 0
	var/removed_items = list()
	var/left_points = preferences.get_loadout_points()

	// Подсчёт общей стоимости всех предметов в лодауте
	for(var/path in result)
		var/datum/loadout_item/item = GLOB.all_loadout_datums[path]
		total_cost += item.cost

	// Если общая стоимость превышает доступные очки, очищаем весь лодаут
	if (total_cost > left_points)
		result = list()  // Полностью очищаем список
		removed_items = result  // Добавляем все элементы в список удалённых предметов
		to_chat(preferences.parent.mob, span_warning("У вас недостаточно очков, для вашего набора. Он был отчищен."))
	else
		// Если всё в порядке, выполняем стандартные проверки
		left_points -= total_cost
		for(var/path in result)
			var/datum/loadout_item/item = GLOB.all_loadout_datums[path]
			if(donator_level < item.donator_level)
				//Убираем предметы, на которые не хватает донат-уровня
				result -= path
				removed_items += item.name

	preferences.loadout_points = left_points
	// Сообщение пользователю о том, какие предметы были удалены
	if(length(removed_items) && preferences.parent.mob)
		to_chat(preferences.parent.mob, span_warning("У вас недостаточный уровень доната, чтобы взять: [english_list(removed_items, and_text = " и ")]!"))
