/// List of language prototypes to reference, assoc [type] = prototype
GLOBAL_LIST_INIT_TYPED(language_datum_instances, /datum/language, init_language_prototypes())
/// List if all language typepaths learnable, IE, those with keys
GLOBAL_LIST_INIT(all_languages, init_all_languages())
/// /List of language prototypes to reference, assoc "name" = typepath
GLOBAL_LIST_INIT(language_types_by_name, init_language_types_by_name())
/// 1000 element long list containing the 1000 most common words in the English language.
/// Indexed by word, value is the rank of the word in the list. So accessing it is fasta.
GLOBAL_LIST_INIT(most_common_words, init_common_words())

/proc/init_language_prototypes()
	var/list/lang_list = list()
	for(var/datum/language/lang_type as anything in typesof(/datum/language))
		if(!initial(lang_type.key))
			continue

		lang_list[lang_type] = new lang_type()
	return lang_list

/proc/init_all_languages()
	var/list/lang_list = list()
	for(var/datum/language/lang_type as anything in typesof(/datum/language))
		if(!initial(lang_type.key))
			continue
		lang_list += lang_type
	return lang_list

/proc/init_language_types_by_name()
	var/list/lang_list = list()
	for(var/datum/language/lang_type as anything in typesof(/datum/language))
		if(!initial(lang_type.key))
			continue
		lang_list[initial(lang_type.name)] = lang_type
	return lang_list

/proc/init_common_words()
	var/list/word_to_commonness_list = list()
	var/i = 1
	for(var/word in world.file2list("strings/1000_most_common.txt"))
		word_to_commonness_list[word] = i
		i += 1
	return word_to_commonness_list
