SUBSYSTEM_DEF(language)
	name = "Language"
	init_order = INIT_ORDER_LANGUAGE
	flags = SS_NO_FIRE

/datum/controller/subsystem/language/Initialize()
	for(var/datum/language/language as anything in subtypesof(/datum/language))
		if(!initial(language.key))
			continue

		GLOB.all_languages += language
		GLOB.language_types_by_name[initial(language.name)] = language

		var/datum/language/instance = new language
		GLOB.language_datum_instances[language] = instance

	return SS_INIT_SUCCESS
