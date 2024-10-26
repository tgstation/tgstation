/atom
	// code\__DEFINES\bandastation\pronouns.dm for more info
	/// RU_NAMES_LIST_INIT("name", "именительный", "родительный", "дательный", "винительный", "творительный", "предложный")
	var/list/ru_names
	var/ru_name_base
	var/ru_name_nominative
	var/ru_name_genitive
	var/ru_name_dative
	var/ru_name_accusative
	var/ru_name_instrumental
	var/ru_name_prepositional

/datum/proc/ru_names_rename(list/new_list)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Unimplemented proc/ru_names_rename() was used")

/// Необходимо использовать ПЕРЕД изменением var/name, и использовать только этот прок для изменения в рантайме склонений
/atom/ru_names_rename(list/new_list)
	if(length(new_list) != RU_NAMES_LENGTH)
		CRASH("proc/ru_names_rename() received incorrect list!")
	RU_NAMES_LIST_INIT(new_list["base"], new_list[NOMINATIVE], new_list[GENITIVE], new_list[DATIVE], new_list[ACCUSATIVE], new_list[INSTRUMENTAL], new_list[PREPOSITIONAL])

/**
* Процедура выбора правильного падежа для любого предмета, если у него указан словарь «ru_names», примерно такой:
* RU_NAMES_LIST_INIT("jaws of life", "челюсти жизни", "челюстей жизни", "челюстям жизни", "челюсти жизни", "челюстями жизни", "челюстях жизни")
*/
/datum/proc/declent_ru(case_id, list/ru_names_override)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Unimplemented proc/declent_ru() was used")

/atom/declent_ru(case_id, list/ru_names_override)
	var/list/list_to_use = ru_names_override || ru_names
	if(length(list_to_use))
		if(list_to_use[case_id] && list_to_use["base"] == name)
			return list_to_use[case_id] || name
	return name

/// Used for getting initial values, such as for recipies where resulted atom is not yet created.
/proc/declent_ru_initial(atom/target, declent)
	if(!istype(target) && !ispath(target, /atom))
		CRASH("declent_ru_initial got target that is not an atom or atom's path!")
	if(target::ru_name_base != target::name)
		return target::name
	switch(declent)
		if(NOMINATIVE)
			return target::ru_name_nominative
		if(GENITIVE)
			return target::ru_name_genitive
		if(DATIVE)
			return target::ru_name_dative
		if(ACCUSATIVE)
			return target::ru_name_accusative
		if(INSTRUMENTAL)
			return target::ru_name_instrumental
		if(PREPOSITIONAL)
			return target::ru_name_prepositional
	return target::name
