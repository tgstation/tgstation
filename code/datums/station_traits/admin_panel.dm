ADMIN_VERB(station_traits_panel, R_FUN, "Modify Station Traits", "Modify the station traits for the next round.", ADMIN_CATEGORY_EVENTS)
	var/static/datum/station_traits_panel/station_traits_panel = new
	station_traits_panel.ui_interact(user.mob)

/datum/station_traits_panel
	var/static/list/future_traits

/datum/station_traits_panel/ui_data(mob/user)
	var/list/data = list()

	data["too_late_to_revert"] = too_late_to_revert()

	var/list/current_station_traits = list()
	for (var/datum/station_trait/station_trait as anything in SSstation.station_traits)
		current_station_traits += list(list(
			"name" = station_trait.name,
			"can_revert" = station_trait.can_revert,
			"ref" = REF(station_trait),
		))

	data["current_traits"] = current_station_traits
	data["future_station_traits"] = future_traits

	return data

/datum/station_traits_panel/ui_static_data(mob/user)
	var/list/data = list()

	var/list/valid_station_traits = list()

	for (var/datum/station_trait/station_trait_path as anything in subtypesof(/datum/station_trait))
		valid_station_traits += list(list(
			"name" = initial(station_trait_path.name),
			"path" = station_trait_path,
		))

	data["valid_station_traits"] = valid_station_traits

	return data

/datum/station_traits_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	switch (action)
		if ("revert")
			var/ref = params["ref"]
			if (!ref)
				return TRUE

			var/datum/station_trait/station_trait = locate(ref)

			if (!istype(station_trait))
				return TRUE

			if (too_late_to_revert())
				to_chat(usr, span_warning("It's too late to revert station traits, the round has already started!"))
				return TRUE

			if (!station_trait.can_revert)
				stack_trace("[station_trait.type] can't be reverted, but was requested anyway.")
				return TRUE

			var/message = "[key_name(usr)] reverted the station trait [station_trait.name] ([station_trait.type])"
			log_admin(message)
			message_admins(message)

			station_trait.revert()

			return TRUE
		if ("setup_future_traits")
			if (too_late_for_future_traits())
				to_chat(usr, span_warning("It's too late to add future station traits, the round is already over!"))
				return TRUE

			var/list/new_future_traits = list()
			var/list/station_trait_names = list()

			for (var/station_trait_text in params["station_traits"])
				var/datum/station_trait/station_trait_path = text2path(station_trait_text)
				if (!ispath(station_trait_path, /datum/station_trait) || station_trait_path == /datum/station_trait)
					log_admin("[key_name(usr)] tried to set an invalid future station trait: [station_trait_text]")
					to_chat(usr, span_warning("Invalid future station trait: [station_trait_text]"))
					return TRUE

				station_trait_names += initial(station_trait_path.name)

				new_future_traits += list(list(
					"name" = initial(station_trait_path.name),
					"path" = station_trait_path,
				))

			var/message = "[key_name(usr)] has prepared the following station traits for next round: [station_trait_names.Join(", ") || "None"]"
			log_admin(message)
			message_admins(message)

			future_traits = new_future_traits
			rustg_file_write(json_encode(params["station_traits"]), FUTURE_STATION_TRAITS_FILE)

			return TRUE
		if ("clear_future_traits")
			if (!future_traits)
				to_chat(usr, span_warning("There are no future station traits."))
				return TRUE

			var/message = "[key_name(usr)] has cleared the station traits for next round."
			log_admin(message)
			message_admins(message)

			fdel(FUTURE_STATION_TRAITS_FILE)
			future_traits = null

			return TRUE

/datum/station_traits_panel/proc/too_late_for_future_traits()
	return SSticker.current_state >= GAME_STATE_FINISHED

/datum/station_traits_panel/proc/too_late_to_revert()
	return SSticker.current_state >= GAME_STATE_PLAYING

/datum/station_traits_panel/ui_status(mob/user, datum/ui_state/state)
	return check_rights_for(user.client, R_FUN) ? UI_INTERACTIVE : UI_CLOSE

/datum/station_traits_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StationTraitsPanel")
		ui.open()
