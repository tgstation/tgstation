/**
 * AI Status Display Picker TGUI
 * Allows AIs to select status display options with search functionality
 */

/datum/ai_status_display_picker
	/// The AI user who opened this interface
	var/mob/living/silicon/ai/ai_user
	/// The status display that was clicked
	var/obj/machinery/status_display/ai/target_display

/datum/ai_status_display_picker/New(mob/living/silicon/ai/user)
	ai_user = user

/datum/ai_status_display_picker/ui_status(mob/user, datum/ui_state/state)
	if(!ai_user || user != ai_user || ai_user.incapacitated)
		return UI_CLOSE
	return ..()

/datum/ai_status_display_picker/ui_state(mob/user)
	return GLOB.always_state

/datum/ai_status_display_picker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiStatusDisplayPicker")
		ui.open()

/datum/ai_status_display_picker/ui_close(mob/user)
	if(ai_user)
		ai_user.status_display_picker = null

// No assets needed for DMIcon system

/datum/ai_status_display_picker/ui_static_data(mob/user)
	// Always ensure initialization
	init_ai_status_display_options()

	var/list/data = list()
	var/list/options = list()

	for(var/option_name in GLOB.ai_status_display_emotes)
		var/icon_state = GLOB.ai_status_display_emotes[option_name]
		var/list/option_data = list(
			"name" = option_name,
			"icon_state" = icon_state,
			"is_original" = TRUE,
			"icon" = 'icons/obj/machines/status_display.dmi'
		)
		options += list(option_data)

	for(var/option_name in GLOB.ai_core_to_status_display_mapping)
		var/icon_state = GLOB.ai_core_to_status_display_mapping[option_name]
		var/list/option_data = list(
			"name" = option_name,
			"icon_state" = icon_state,
			"is_original" = FALSE,
			"icon" = 'icons/obj/machines/status_display.dmi'
		)
		options += list(option_data)

	data["options"] = options

	return data

/datum/ai_status_display_picker/ui_data(mob/user)
	var/list/data = list()

	// Find current display emotion from first available AI status display
	var/current_emotion = "None"
	var/current_icon_state
	var/obj/machinery/status_display/ai/first_display = locate() in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/status_display/ai)
	if(first_display?.emotion)
		current_emotion = first_display.emotion
		if(current_emotion in GLOB.ai_status_display_emotes)
			current_icon_state = GLOB.ai_status_display_emotes[current_emotion]
		else if(current_emotion in GLOB.ai_core_to_status_display_mapping)
			current_icon_state = GLOB.ai_core_to_status_display_mapping[current_emotion]
		else
			current_icon_state = "ai_download"
	else
		current_icon_state = "ai_download"

	data["current_emotion"] = current_emotion
	data["current_icon"] = list(
		"icon" = 'icons/obj/machines/status_display.dmi',
		"icon_state" = current_icon_state
	)

	return data

/datum/ai_status_display_picker/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!ai_user)
		return FALSE

	switch(action)
		if("select_option")
			var/selected_option = params["option"]
			if(!selected_option || !(selected_option in GLOB.ai_status_display_all_options))
				return FALSE

			// Check if this is an original AI emotion (has a corresponding emote)
			var/found_emote = FALSE
			for(var/_emote in typesof(/datum/emote/ai/emotion_display))
				var/datum/emote/ai/emotion_display/emote = _emote
				if(initial(emote.emotion) == selected_option)
					ai_user.emote(initial(emote.key))
					found_emote = TRUE
					break

			// If no emote found (i.e., it's a new AI core display option), directly apply it
			if(!found_emote)
				ai_user.apply_emote_display(selected_option)

			return TRUE

	return FALSE


