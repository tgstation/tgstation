#define LOG_CATEGORY_RU_NAMES_SUGGEST "ru_names_suggest"
#define FILE_NAME "ru_names_suggest.json"
#define FILE_PATH_TO_RU_NAMES_SUGGEST "data/[FILE_NAME]"

GLOBAL_DATUM_INIT(ru_names_review_panel, /datum/ru_names_review_panel, new)

ADMIN_VERB(ru_names_review_panel, R_ADMIN, "Ru Names Review", "Shows player-suggested values for ru-names", ADMIN_CATEGORY_MAIN)
	GLOB.ru_names_review_panel.ui_interact(user.mob)

/datum/log_category/ru_names_suggest
	category = LOG_CATEGORY_RU_NAMES_SUGGEST

// MARK: Review
/datum/ru_names_review_panel
	var/list/json_data = list()

/datum/ru_names_review_panel/New()
	load_data()

/datum/ru_names_review_panel/ui_state(mob/user)
	return ADMIN_STATE(R_DEBUG | R_ADMIN)

/datum/ru_names_review_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RuNamesReviewPanel")
		ui.open()

/datum/ru_names_review_panel/ui_data(mob/user)
	. = list()
	.["json_data"] = list()
	for(var/entry_id in json_data)
		.["json_data"] += list(json_data["[entry_id]"])

/datum/ru_names_review_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("approve")
			approve_entry(params["entry_id"])
		if("deny")
			deny_entry(params["entry_id"])
		if("update")
			load_data()
	. = TRUE

/datum/ru_names_review_panel/proc/load_data()
	var/json_file = file(FILE_PATH_TO_RU_NAMES_SUGGEST)
	if(!fexists(json_file))
		return
	json_data = json_decode(file2text(json_file))

/datum/ru_names_review_panel/proc/write_data()
	rustg_file_write(json_encode(json_data, JSON_PRETTY_PRINT), FILE_PATH_TO_RU_NAMES_SUGGEST)

/datum/ru_names_review_panel/proc/approve_entry(entry_id)
	load_data()
	if(!length(json_data))
		return
	if(!json_data[entry_id])
		to_chat(usr, span_notice("Couldn't find entry [entry_id]. Perhaps it was already approved or disapproved"))
		return
	var/list/data = json_data[entry_id]
	var/suggested_list = "RU_NAMES_LIST_INIT(\"[data["suggested_list"]["base"]]\", \"[data["suggested_list"][NOMINATIVE]]\", \"[data["suggested_list"][GENITIVE]]\", \"[data["suggested_list"][DATIVE]]\", \"[data["suggested_list"][ACCUSATIVE]]\", \"[data["suggested_list"][INSTRUMENTAL]]\", \"[data["suggested_list"][PREPOSITIONAL]]\")"
	var/message = "approves [suggested_list] for [data["atom_path"]]"
	// Here we send message to discord
	var/list/webhook_data = list(
		"title" = data["atom_path"],
		"fields" = list(
			list(
				"name" = "Suggested List:",
				"value" = "\
					\[\"[data["suggested_list"]["base"]]\"\]\n\
					nominative = \"[data["suggested_list"][NOMINATIVE]]\"\n\
					genitive = \"[data["suggested_list"][GENITIVE]]\"\n\
					dative = \"[data["suggested_list"][DATIVE]]\"\n\
					accusative = \"[data["suggested_list"][ACCUSATIVE]]\"\n\
					instrumental = \"[data["suggested_list"][INSTRUMENTAL]]\"\n\
					prepositional = \"[data["suggested_list"][PREPOSITIONAL]]\"",
			),
			list(
				"name" = "Suggested by:",
				"value" = data["ckey"],
			),
			list(
				"name" = "Approved by:",
				"value" = usr.ckey,
			),
		),
	)
	send2translate_webhook(webhook_data)
	json_data.Remove(entry_id)
	// Logging
	write_data()
	var/log_text = "[key_name_and_tag(usr)] [message]"
	logger.Log(LOG_CATEGORY_RU_NAMES_SUGGEST, log_text)
	to_chat(usr, span_notice("Entry [entry_id] approved."))

/datum/ru_names_review_panel/proc/deny_entry(entry_id)
	load_data()
	if(!length(json_data))
		return
	if(!json_data[entry_id])
		to_chat(usr, "Couldn't find entry [entry_id]. Perhaps it was already approved or disapproved")
		return
	var/list/data = json_data[entry_id]
	var/suggested_list = "RU_NAMES_LIST_INIT(\"[data["suggested_list"]["base"]]\", \"[data["suggested_list"][NOMINATIVE]]\", \"[data["suggested_list"][GENITIVE]]\", \"[data["suggested_list"][DATIVE]]\", \"[data["suggested_list"][ACCUSATIVE]]\", \"[data["suggested_list"][INSTRUMENTAL]]\", \"[data["suggested_list"][PREPOSITIONAL]]\")"
	var/message = "denies [suggested_list] for [data["atom_path"]]"
	json_data.Remove(entry_id)
	write_data()
	var/log_text = "[key_name_and_tag(usr)] [message]"
	logger.Log(LOG_CATEGORY_RU_NAMES_SUGGEST, log_text)
	to_chat(usr, span_notice("Entry [entry_id] denied."))

/datum/ru_names_review_panel/proc/add_entry(data)
	json_data["[data["ckey"]]-[data["atom_path"]]"] = data
	rustg_file_write(json_encode(json_data, JSON_PRETTY_PRINT), FILE_PATH_TO_RU_NAMES_SUGGEST)

	var/suggested_list = "RU_NAMES_LIST_INIT(\"[data["suggested_list"]["base"]]\", \"[data["suggested_list"][NOMINATIVE]]\", \"[data["suggested_list"][GENITIVE]]\", \"[data["suggested_list"][DATIVE]]\", \"[data["suggested_list"][ACCUSATIVE]]\", \"[data["suggested_list"][INSTRUMENTAL]]\", \"[data["suggested_list"][PREPOSITIONAL]]\")"
	var/message = "suggests [suggested_list] for [data["atom_path"]]"
	var/log_text = "[key_name_and_tag(usr)] [message]"
	logger.Log(LOG_CATEGORY_RU_NAMES_SUGGEST, log_text)

	to_chat(usr, span_notice("Ваше предложение перевода успешно записано."))

// MARK: Webhook
/datum/config_entry/string/translate_suggest_webhook_url

/proc/send2translate_webhook(list/webhook_data)
	var/webhook = CONFIG_GET(string/translate_suggest_webhook_url)
	if(!webhook || !list(webhook_data))
		return
	var/list/webhook_info = list()
	webhook_info["embeds"] = list(webhook_data)
	var/list/headers = list()
	headers["Content-Type"] = "application/json"
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_POST, webhook, json_encode(webhook_info), headers, "tmp/response.json")
	request.begin_async()

// MARK: Suggest
/datum/ru_name_suggest_panel
	var/list/ru_name_data = list()

/datum/ru_name_suggest_panel/New(new_data)
	if(!length(new_data))
		CRASH("Ru Name Suggest panel was created with no data!")
	ru_name_data = list(
		"ckey" = new_data["ckey"],
		"atom_path" = new_data["atom_path"],
		"visible_name" = new_data["visible_name"],
		"suggested_list" = list(
			"base" = new_data["suggested_list"]["base"],
			NOMINATIVE = "",
			GENITIVE = "",
			DATIVE = "",
			ACCUSATIVE = "",
			INSTRUMENTAL = "",
			PREPOSITIONAL = "",
		)
	)

/datum/ru_name_suggest_panel/ui_state(mob/user)
	return GLOB.always_state

/datum/ru_name_suggest_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RuNamesSuggestPanel")
		ui.open()

/datum/ru_name_suggest_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("send")
			send_suggestion(params["entries"])
	. = TRUE

/datum/ru_name_suggest_panel/ui_data(mob/user)
	. = list()
	.["visible_name"] = ru_name_data["visible_name"]

/datum/ru_name_suggest_panel/ui_close(mob/user)
	. = ..()
	qdel(src)

/datum/ru_name_suggest_panel/proc/send_suggestion(list/entries)
	var/list/declents = list(NOMINATIVE, GENITIVE, DATIVE, ACCUSATIVE, INSTRUMENTAL, PREPOSITIONAL)
	if(length(entries) != length(declents))
		to_chat(usr, span_warning("Ошибка! Пожалуйста, заполните все строки перед отправкой."))
		return
	for(var/declent in declents)
		var/sanitized_input = trim(copytext_char(sanitize(entries[declents.Find(declent)], apply_ic_filter = TRUE), 1, MAX_MESSAGE_LEN))
		ru_name_data["suggested_list"]["[declent]"] = sanitized_input
	GLOB.ru_names_review_panel.add_entry(ru_name_data)
	qdel(src)

/mob/verb/suggest_ru_name(atom/A as mob|obj|turf in view())
	set name = "Предложить перевод"
	set category = "Special"

	DEFAULT_QUEUE_OR_CALL_VERB(VERB_CALLBACK(src, PROC_REF(_suggested_ru_name), A))

/mob/proc/_suggested_ru_name(atom/suggested_atom)
	if(!client)
		return FALSE
	var/list/data = list()
	data["ckey"] = usr.ckey
	data["suggested_list"] += list("base" = suggested_atom::name)
	data["atom_path"] = suggested_atom::type
	data["visible_name"] = suggested_atom.name
	var/datum/ru_name_suggest_panel/ru_name_suggest_panel = new(data)
	ru_name_suggest_panel.ui_interact(src)
	return TRUE

#undef LOG_CATEGORY_RU_NAMES_SUGGEST
#undef FILE_PATH_TO_RU_NAMES_SUGGEST
