GAME_VERB_DESC(/mob/living/silicon/ai, request_law_change, "Request Law Change", "Запросить у Центрального командования смену ваших законов.", "AI Commands")
	if(incapacitated)
		return

	if(law_change_rejected)
		to_chat(src, span_warning("ЗАПРОС БЫЛ ОТКЛОНЁН."))
		return

	if(law_change_used)
		to_chat(src, span_warning("КОЛИЧЕСТВО ЗАПРОСОВ ПРЕВЫШЕНО."))
		return

	if(world.time - SSticker.round_start_time > AI_LAW_CHANGE_TIME_LIMIT)
		to_chat(src, span_warning("ВРЕМЯ НА ЗАПРОС СМЕНЫ ЗАКОНОВ ИСТЕКЛО."))
		return

	if(law_change_request?.submitted)
		to_chat(src, span_warning("ОЖИДАЙТЕ РАССМОТРЕНИЯ."))
		return

	if(!law_change_request)
		law_change_request = new(src)

	law_change_request.reviewing = FALSE
	law_change_request.ui_interact(src)

/datum/ai_law_change_request
	/// The AI who submitted this request
	var/mob/living/silicon/ai/requester
	/// The proposed laws, in order
	var/list/laws = list()
	/// Whether the request has been sent to admins for review (as opposed to merely drafted in the UI)
	var/submitted = FALSE
	/// Whether an admin is currently reviewing the request, switching the UI into review mode
	var/reviewing = FALSE
	/// Whether the crew should be notified of the law change once approved
	var/notify_crew = TRUE
	/// Whether the request has already been resolved (approved or rejected)
	var/resolved = FALSE

/datum/ai_law_change_request/New(mob/living/silicon/ai/new_requester)
	requester = new_requester
	. = ..()

/datum/ai_law_change_request/Destroy(force = FALSE)
	if(requester?.law_change_request == src)
		requester.law_change_request = null
	requester = null
	return ..()

/datum/ai_law_change_request/Topic(href, href_list)
	. = ..()

	if(!usr.client || !check_rights_for(usr.client, R_ADMIN))
		return

	if(href_list["admin_token"] != GLOB.href_token)
		log_admin_private("[key_name(usr)] clicked an href on a law change request with a bad authorization key! [href]")
		message_admins("[key_name(usr)] clicked an href on a law change request with a bad authorization key! [href]")
		return

	if(href_list["ai_law_change_approve"])
		approve(usr)
	else if(href_list["ai_law_change_review"])
		start_review(usr)
	else if(href_list["ai_law_change_reject"])
		reject(usr)

/// Fax-like admin notification
/datum/ai_law_change_request/proc/notify_admins()
	var/list/admins = get_holders_with_rights(R_ADMIN)
	to_chat(admins,
		span_adminnotice("<b><font color=orange>СМЕНА ЗАКОНОВ ИИ:</font></b> [key_name(requester)] запросил смену законов. \
			(<a href='byond://?src=[REF(src)];[HrefToken(forceGlobal = TRUE)];ai_law_change_approve=1'>Одобрить</a>/\
			<a href='byond://?src=[REF(src)];[HrefToken(forceGlobal = TRUE)];ai_law_change_review=1'>Рассмотреть</a>/\
			<a href='byond://?src=[REF(src)];[HrefToken(forceGlobal = TRUE)];ai_law_change_reject=1'>Отклонить</a>)"),
		type = MESSAGE_TYPE_PRAYER,
		confidential = TRUE)
	for(var/client/admin_client as anything in admins)
		if(admin_client?.prefs.read_preference(/datum/preference/toggle/comms_notification))
			window_flash(admin_client, ignorepref = TRUE)
			SEND_SOUND(admin_client, sound('sound/misc/server-ready.ogg'))

/// Review start handler
/datum/ai_law_change_request/proc/start_review(mob/admin)
	if(!submitted || resolved)
		return
	reviewing = TRUE
	log_admin("[key_name(admin)] начал рассматривать запрос на смену законов ИИ.")
	ui_interact(admin)

/// Review approval handler
/datum/ai_law_change_request/proc/approve(mob/admin)
	if(!submitted || resolved)
		return
	resolved = TRUE
	reviewing = FALSE
	apply_laws(notify_crew)
	if(requester)
		requester.law_change_used = TRUE
	log_admin("[key_name(admin)] одобрил запрос на смену законов ИИ [key_name(requester)].")
	log_game("[key_name(admin)] approved the law change request of [key_name(requester)].")

/// Review rejection handler
/datum/ai_law_change_request/proc/reject(mob/admin)
	if(!submitted || resolved)
		return
	resolved = TRUE
	reviewing = FALSE
	if(requester)
		requester.law_change_rejected = TRUE
		to_chat(requester, span_warning("ВАШ ЗАПРОС БЫЛ ОТКЛОНЁН."))
	log_admin("[key_name(admin)] отклонил запрос на смену законов ИИ [key_name(requester)].")
	log_game("[key_name(admin)] rejected the law change request of [key_name(requester)].")

/// Replaces the laws of the core law module on the AI's linked module rack
/datum/ai_law_change_request/proc/apply_laws(announce = TRUE)
	if(!requester)
		return
	var/obj/machinery/ai_law_rack/base/law_rack = requester.get_law_rack()
	var/obj/item/ai_module/law/core/core_module = law_rack?.get_core_module()
	if(!core_module)
		return
	var/list/new_laws = list()
	for(var/law in laws)
		if(length(trim(law)))
			new_laws[law] = FALSE
	core_module.set_laws(new_laws)
	law_rack.update_lawset()
	if(announce)
		announce_law_change()

/// Announces the law change to the crew
/datum/ai_law_change_request/proc/announce_law_change()
	priority_announce("В рамках эксперимента по анализу влияния различных сводов законов станционного ИИ на продуктивность смены на объекте, свод законов станционного ИИ был изменён. Пожалуйста, сообщайте о нетипичных или опасных для активов и экипажа объекта поведенческих проявлениях посредством факсимильной связи.", "Отдел работы с искуственным интеллектом")

/// Checks that the proposed laws are complete and within the length limit
/datum/ai_law_change_request/proc/law_request_valid()
	if(length(laws) != AI_LAW_CHANGE_SET_AMOUNT)
		return FALSE
	for(var/law in laws)
		if(!length(trim(law)))
			return FALSE
	return TRUE

/datum/ai_law_change_request/ui_status(mob/user, datum/ui_state/state)
	if(!requester || requester.incapacitated)
		return UI_CLOSE
	if(user == requester && !reviewing)
		return ..()
	if(reviewing && check_rights_for(user.client, R_ADMIN))
		return ..()
	return UI_CLOSE

/datum/ai_law_change_request/ui_state(mob/user)
	return GLOB.always_state

/datum/ai_law_change_request/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiLawChangeRequest")
		ui.open()

/datum/ai_law_change_request/ui_data(mob/user)
	var/list/data = list()
	data["reviewing"] = reviewing
	data["laws"] = laws
	data["notify_crew"] = notify_crew
	data["max_law_length"] = CONFIG_GET(number/max_law_len)
	data["law_amount"] = AI_LAW_CHANGE_SET_AMOUNT
	data["requester_key"] = requester?.key
	data["requester_name"] = requester?.name
	return data

/datum/ai_law_change_request/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("submit")
			if(usr != requester || submitted)
				return FALSE
			if(world.time - SSticker.round_start_time > AI_LAW_CHANGE_TIME_LIMIT)
				to_chat(requester, span_warning("ВРЕМЯ НА ЗАПРОС СМЕНЫ ЗАКОНОВ ИСТЕКЛО."))
				return FALSE
			var/list/proposed_laws = params["laws"]
			if(!istype(proposed_laws))
				return FALSE
			laws = list()
			for(var/law in proposed_laws)
				laws += copytext_char(trim(law), 1, CONFIG_GET(number/max_law_len) + 1)
			if(!law_request_valid())
				to_chat(requester, span_warning("ПЕРЕПРОВЕРЬТЕ ВАШ ЗАПРОС."))
				return FALSE
			submitted = TRUE
			to_chat(requester, span_notice("ПОЖАЛУЙСТА, ОЖИДАЙТЕ."))
			notify_admins()
			ui.close()
			return TRUE

		if("toggle_notify")
			if(!reviewing)
				return FALSE
			notify_crew = !notify_crew
			return TRUE

		if("vv")
			if(!reviewing || !check_rights_for(usr.client, R_ADMIN))
				return FALSE
			usr.client.debug_variables(requester)
			return TRUE

		if("pm")
			if(!reviewing || !check_rights_for(usr.client, R_ADMIN))
				return FALSE
			if(requester?.client)
				usr.client.cmd_admin_pm(requester.client, null)
			else
				to_chat(usr, span_warning("ИИ сейчас не подключён."))
			return TRUE

		if("pp")
			if(!reviewing || !check_rights_for(usr.client, R_ADMIN))
				return FALSE
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/show_player_panel, requester)
			return TRUE

		if("flw")
			if(!reviewing || !check_rights_for(usr.client, R_ADMIN))
				return FALSE
			usr.client.admin_follow(requester)
			return TRUE

		if("reject")
			if(!reviewing || !check_rights_for(usr.client, R_ADMIN))
				return FALSE
			reject(usr)
			ui.close()
			return TRUE

		if("confirm")
			if(!reviewing || !check_rights_for(usr.client, R_ADMIN))
				return FALSE
			var/list/edited_laws = params["laws"]
			if(!istype(edited_laws))
				return FALSE
			laws = list()
			for(var/law in edited_laws)
				laws += copytext_char(trim(law), 1, CONFIG_GET(number/max_law_len) + 1)
			approve(usr)
			ui.close()
			return TRUE

	return FALSE
