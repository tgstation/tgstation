GLOBAL_LIST_EMPTY(ru_names)

/atom
	// code\__DEFINES\bandastation\pronouns.dm for more info
	/// List consists of ("name", "именительный", "родительный", "дательный", "винительный", "творительный", "предложный", "gender")
	var/list/ru_names

/// Хелпер для создания склонений
/proc/ru_names_list(base, nominative, genitive, dative, accusative, instrumental, prepositional, gender)
	if(!base || !nominative || !genitive || !dative || !accusative || !instrumental || !prepositional)
		CRASH("ru_names_list() received incomplete declent list!")
	return list("base" = base, NOMINATIVE = nominative, GENITIVE = genitive, DATIVE = dative, ACCUSATIVE = accusative, INSTRUMENTAL = instrumental, PREPOSITIONAL = prepositional, "gender" = gender)

/proc/ru_names_toml(name, prefix, suffix, override_base)
	. = list()
	var/formatted_name = format_text(name)
	if(!length(GLOB.ru_names))
		var/toml_path = "[PATH_TO_TRANSLATE_DATA]/ru_names.toml"
		if(!fexists(file(toml_path)))
			GLOB.ru_names = list("ERROR" = "File not found!")
			return .
		GLOB.ru_names = rustg_read_toml_file("[PATH_TO_TRANSLATE_DATA]/ru_names.toml")
	if(GLOB.ru_names[formatted_name])
		var/base = override_base || "[prefix][name][suffix]"
		. = ru_names_list(
			base,
			"[prefix][GLOB.ru_names[formatted_name]["nominative"] || name][suffix]",
			"[prefix][GLOB.ru_names[formatted_name]["genitive"] || name][suffix]",
			"[prefix][GLOB.ru_names[formatted_name]["dative"] || name][suffix]",
			"[prefix][GLOB.ru_names[formatted_name]["accusative"] || name][suffix]",
			"[prefix][GLOB.ru_names[formatted_name]["instrumental"] || name][suffix]",
			"[prefix][GLOB.ru_names[formatted_name]["prepositional"] || name][suffix]",
			gender = "[GLOB.ru_names[formatted_name]["gender"] || null]",)

/atom/Initialize(mapload, ...)
	. = ..()
	article = null
	ru_names_rename(ru_names_toml(name))

/turf/Initialize(mapload)
	. = ..()
	article = null
	ru_names_rename(ru_names_toml(name))

/datum/proc/ru_names_rename(list/new_list)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Unimplemented proc/ru_names_rename() was used")

/// Необходимо использовать ПЕРЕД изменением var/name, и использовать только этот прок для изменения в рантайме склонений
/atom/ru_names_rename(list/new_list)
	if(!length(new_list))
		ru_names = null
		return
	ru_names = new_list
	if(new_list["gender"])
		gender = new_list["gender"]
	else
		gender = src::gender

/**
* Процедура выбора правильного падежа для любого предмета, если у него указан словарь «ru_names», примерно такой:
* RU_NAMES_LIST_INIT("jaws of life", "челюсти жизни", "челюстей жизни", "челюстям жизни", "челюсти жизни", "челюстями жизни", "челюстях жизни")
*/
/datum/proc/declent_ru(declent)
	CRASH("Unimplemented proc/declent_ru() was used")

/proc/get_declented_value(list/declented_list, declent, backup_value)
	if(declent == "gender")
		return declented_list[declent] || backup_value
	return declented_list[declent] || declented_list[NOMINATIVE] || backup_value

/atom/declent_ru(declent)
	. = name
	if(declent == "gender")
		. = gender
	if(!length(ru_names) || ru_names["base"] != name)
		return .
	return get_declented_value(ru_names, declent, .)

/// Used for getting initial values, such as for recipies where resulted atom is not yet created.
/proc/declent_ru_initial(target_name, declent, override_backup)
	. = override_backup || target_name
	if(declent == "gender")
		. = NEUTER
	var/list/declented_list = ru_names_toml(target_name)
	if(!length(declented_list))
		return .
	return get_declented_value(declented_list, declent, .)
