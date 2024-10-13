#define LOG_CATEGORY_RU_NAMES_SUGGEST "ru_names_suggest"

/datum/log_category/ru_names_suggest
	category = LOG_CATEGORY_RU_NAMES_SUGGEST

/mob/verb/suggest_ru_name(atom/A as mob|obj|turf in view())
	set name = "Предложить перевод"

	DEFAULT_QUEUE_OR_CALL_VERB(VERB_CALLBACK(src, PROC_REF(_suggested_ru_name), A))

/mob/proc/_suggested_ru_name(atom/suggested_atom)
	if(!client)
		return FALSE
	var/atom_name = suggested_atom.name
	var/atom/atom_type = suggested_atom.type

	var/static/list/declents = list(NOMINATIVE, GENITIVE, DATIVE, ACCUSATIVE, INSTRUMENTAL, PREPOSITIONAL)
	var/list/ru_name_suggest = list()
	for(var/declent in declents)
		ru_name_suggest[declent] = tgui_input_text(src, "Введите [declent] падеж", "Предложение перевода для [atom_name]", atom_name)
		if(!ru_name_suggest[declent])
			to_chat(src, span_notice("Вы отменили предложение перевода."))
			return TRUE
	var/message = "suggests RU_NAMES_INIT_LIST(\"[atom_type::name]\", \"[ru_name_suggest[NOMINATIVE]]\", \"[ru_name_suggest[GENITIVE]]\", \"[ru_name_suggest[DATIVE]]\", \"[ru_name_suggest[ACCUSATIVE]]\", \"[ru_name_suggest[INSTRUMENTAL]]\", \"[ru_name_suggest[PREPOSITIONAL]]\") for [atom_type::type]"
	var/log_text = "[key_name_and_tag(src)] [message]"
	logger.Log(LOG_CATEGORY_RU_NAMES_SUGGEST, log_text)
	to_chat(src, span_notice("Ваше предложение перевода успешно записано."))
	return TRUE

#undef LOG_CATEGORY_RU_NAMES_SUGGEST
