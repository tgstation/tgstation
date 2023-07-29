/datum/emote_panel
	var/list/blacklisted_emotes = list("me", "help")

/datum/emote_panel/ui_static_data(mob/user)
	var/list/data = list()

	var/list/emotes = list()
	var/list/keys = list()

	for(var/key in GLOB.emote_list)
		for(var/datum/emote/emote in GLOB.emote_list[key])
			if(emote.key in keys)
				continue
			if(emote.key in blacklisted_emotes)
				continue
			if(emote.can_run_emote(user, status_check = FALSE, intentional = TRUE))
				keys += emote.key
				emotes += list(list(
					"key" = emote.name,
					"emote_path" = emote.type,
					"hands" = emote.hands_use_check,
					"visible" = emote.emote_type & EMOTE_VISIBLE,
					"audible" = emote.emote_type & EMOTE_AUDIBLE,
					"sound" = !isnull(emote.sound),
				))

	data["emotes"] = emotes

	return data

/datum/emote_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("play_emote")
			var/emote_path = params["emote_path"]
			var/datum/emote/emote = new emote_path()
			var/emote_act = emote.key
			if(emote.message_param)
				var/emote_param = tgui_input_text(usr, "Дополните эмоцию", emote.message_param)
				if(!isnull(emote_param))
					emote_act = "[emote_act] [emote_param]"
			usr.emote(emote_act, intentional = TRUE)

/datum/emote_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EmotePanel")
		ui.open()

/datum/emote_panel/ui_state(mob/user)
	return GLOB.always_state

/mob/living/verb/emote_panel()
	set name = "Emote Panel"
	set category = "IC"

	var/static/datum/emote_panel/emote_panel = new
	emote_panel.ui_interact(src)
