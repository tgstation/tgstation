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
			if(emote.can_run_emote(user, status_check = FALSE, intentional = FALSE))
				keys += emote.key
				emotes += list(list(
					"key" = emote.key,
					"name" = emote.name,
					"hands" = emote.hands_use_check,
					"visible" = emote.emote_type & EMOTE_VISIBLE,
					"audible" = emote.emote_type & EMOTE_AUDIBLE,
					"sound" = !isnull(emote.get_sound(user)),
					"use_params" = emote.message_param,
				))

	data["emotes"] = emotes

	return data

/datum/emote_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("play_emote")
			var/emote_key = params["emote_key"]
			if(isnull(emote_key) || !GLOB.emote_list[emote_key])
				return
			var/use_params = params["use_params"]
			var/datum/emote/emote = GLOB.emote_list[emote_key][1]
			var/emote_param
			if(emote.message_param && use_params)
				emote_param = tgui_input_text(ui.user, "Add params to the emote...", emote.message_param, max_length = MAX_MESSAGE_LEN)
			ui.user.emote(emote_key, message = emote_param, intentional = TRUE)

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

	var/static/datum/emote_panel/emote_panel
	if(isnull(emote_panel))
		emote_panel = new
	emote_panel.ui_interact(src)
