/datum/song/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "InstrumentEditor", parent.name)
		ui.open()

/datum/song/ui_host(mob/user)
	return parent

/datum/song/ui_data(mob/user)
	var/list/data = ..()
	data["using_instrument"] = using_instrument?.name || "No instrument loaded!"
	data["note_shift"] = note_shift
	data["octaves"] = round(note_shift / 12, 0.01)
	data["sustain_mode"] = sustain_mode
	switch(sustain_mode)
		if(SUSTAIN_LINEAR)
			data["sustain_mode_button"] = "Linear Sustain Duration"
			data["sustain_mode_text"] = "[sustain_linear_duration / 10] seconds"
		if(SUSTAIN_EXPONENTIAL)
			data["sustain_mode_button"] = "Exponential Falloff Factor"
			data["sustain_mode_text"] = "[sustain_exponential_dropoff]% per decisecond"
	data["instrument_ready"] = using_instrument?.ready()
	data["volume"] = volume
	data["volume_dropoff_threshold"] = sustain_dropoff_volume
	data["sustain_indefinitely"] = full_sustain_held_note
	data["playing"] = playing
	data["repeat"] = repeat
	data["bpm"] = round(600 / tempo)
	data["lines"] = list()
	var/linecount
	for(var/line in lines)
		linecount++
		data["lines"] += list(list(
			"line_count" = linecount,
			"line_text" = line,
		))
	return data

/datum/song/ui_static_data(mob/user)
	var/list/data = ..()
	data["can_switch_instrument"] = (length(allowed_instrument_ids) > 1)
	data["max_repeats"] = max_repeats
	data["max_line_chars"] = MUSIC_MAXLINECHARS
	data["max_lines"] = MUSIC_MAXLINES
	return data

/datum/song/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = ui.user
	if(!istype(user))
		return FALSE

	switch(action)
		//SETTINGS
		if("play_music")
			if(!playing)
				INVOKE_ASYNC(src, PROC_REF(start_playing), user)
			else
				stop_playing()
			return TRUE
		if("switch_instrument")
			if(!length(allowed_instrument_ids))
				return FALSE
			if(length(allowed_instrument_ids) == 1)
				set_instrument(allowed_instrument_ids[1])
				return TRUE
			var/list/categories = list()
			for(var/i in allowed_instrument_ids)
				var/datum/instrument/instrument_type = SSinstruments.get_instrument(i)
				if(instrument_type)
					LAZYSET(categories[instrument_type.category || "ERROR CATEGORY"], instrument_type.name, instrument_type.id)
			if(!categories)
				return FALSE
			var/category_selection = tgui_input_list(user, "Select Category", "Instrument Category", categories)
			if(isnull(category_selection))
				return FALSE
			var/list/instruments = categories[category_selection]
			var/instrument_selection = tgui_input_list(user, "Select Instrument", "Instrument Selection", instruments)
			instrument_selection = instruments[instrument_selection] //get id
			if(isnull(instrument_selection))
				return FALSE
			set_instrument(instrument_selection)
			return TRUE
		if("tempo")
			var/move_direction = params["tempo_change"]
			var/tempo_diff
			if(move_direction == "increase_speed")
				tempo_diff = world.tick_lag
			else
				tempo_diff = -world.tick_lag
			tempo = sanitize_tempo(tempo + tempo_diff)
			return TRUE

		//SONG MAKING
		if("import_song")
			var/song_text = ""
			do
				song_text = tgui_input_text(user, "Please paste the entire song, formatted:", name, max_length = (MUSIC_MAXLINES * MUSIC_MAXLINECHARS))
				if(!in_range(parent, user))
					return
				if(length_char(song_text) >= MUSIC_MAXLINES * MUSIC_MAXLINECHARS)
					var/should_continue = tgui_alert(user, "Your message is too long! Would you like to continue editing it?", "Warning", list("Yes", "No"))
					if(should_continue != "Yes")
						break
			while(length_char(song_text) > MUSIC_MAXLINES * MUSIC_MAXLINECHARS)
			ParseSong(user, song_text)
			return TRUE
		if("start_new_song")
			name = ""
			lines = new()
			tempo = sanitize_tempo(5) // default 120 BPM
			return TRUE
		if("add_new_line")
			var/newline = tgui_input_text(user, "Enter your line", parent.name)
			if(!newline || !in_range(parent, user))
				return
			if(lines.len > MUSIC_MAXLINES)
				return
			if(length(newline) > MUSIC_MAXLINECHARS)
				newline = copytext(newline, 1, MUSIC_MAXLINECHARS)
			lines.Add(newline)
		if("delete_line")
			var/line_to_delete = params["line_deleted"]
			if(line_to_delete > lines.len || line_to_delete < 1)
				return FALSE
			lines.Cut(line_to_delete, line_to_delete + 1)
			return TRUE
		if("modify_line")
			var/line_to_edit = params["line_editing"]
			if(line_to_edit > lines.len || line_to_edit < 1)
				return FALSE
			var/new_line_text = tgui_input_text(user, "Enter your line ", parent.name, lines[line_to_edit], MUSIC_MAXLINECHARS)
			if(isnull(new_line_text) || !in_range(parent, user))
				return FALSE
			lines[line_to_edit] = new_line_text
			return TRUE

		//MODE STUFF
		if("set_sustain_mode")
			var/choice = tgui_input_list(user, "Choose a sustain mode", "Sustain Mode", SSinstruments.note_sustain_modes)
			if(isnull(choice) || !(choice in SSinstruments.note_sustain_modes))
				return FALSE
			sustain_mode = choice
			return TRUE
		if("set_note_shift")
			var/amount = tgui_input_number(user, "Set note shift", "Note Shift", max_value = note_shift_max, min_value = note_shift_min)
			if(!isnum(amount))
				return FALSE
			note_shift = clamp(amount, note_shift_min, note_shift_max)
			return TRUE
		if("set_volume")
			var/amount = tgui_input_number(user, "Set volume", "Volume", default = 1, max_value = 75, min_value = 1)
			if(!isnum(amount))
				return FALSE
			set_volume(amount)
			return TRUE
		if("set_dropoff_volume")
			var/amount = tgui_input_number(user, "Set dropoff threshold", "Dropoff Volume", max_value = 100)
			if(!isnum(amount))
				return FALSE
			set_dropoff_volume(amount)
			return TRUE
		if("toggle_sustain_hold_indefinitely")
			full_sustain_held_note = !full_sustain_held_note
			return TRUE
		if("set_repeat")
			if(playing)
				return
			var/amount = tgui_input_number(user, "How many times will the song repeat", "Repeat Song", max_value = max_repeats)
			if(!isnum(amount))
				return FALSE
			set_repeats(amount)
			return TRUE
		if("edit_sustain_mode")
			switch(sustain_mode)
				if(SUSTAIN_LINEAR)
					var/amount = tgui_input_number(user, "Set linear sustain duration in seconds", "Linear Sustain Duration", 0.1, INSTRUMENT_MAX_TOTAL_SUSTAIN, 0.1, round_value = FALSE)
					if(isnull(amount))
						return FALSE
					set_linear_falloff_duration(amount)
				if(SUSTAIN_EXPONENTIAL)
					var/amount = tgui_input_number(user, "Set exponential sustain factor", "Exponential sustain factor", INSTRUMENT_EXP_FALLOFF_MIN, INSTRUMENT_EXP_FALLOFF_MAX,  INSTRUMENT_EXP_FALLOFF_MIN, round_value = FALSE)
					if(isnull(amount))
						return FALSE
					set_exponential_drop_rate(amount)

/**
 * Parses a song the user has input into lines and stores them.
 */
/datum/song/proc/ParseSong(mob/user, new_song)
	set waitfor = FALSE
	//split into lines
	lines = islist(new_song) ? new_song : splittext(new_song, "\n")
	if(lines.len)
		var/bpm_string = "BPM: "
		if(findtext(lines[1], bpm_string, 1, length(bpm_string) + 1))
			var/divisor = text2num(copytext(lines[1], length(bpm_string) + 1)) || 120 // default
			tempo = sanitize_tempo(BPM_TO_TEMPO_SETTING(divisor))
			lines.Cut(1, 2)
		else
			tempo = sanitize_tempo(5) // default 120 BPM
		if(lines.len > MUSIC_MAXLINES)
			if(user)
				to_chat(user, "Too many lines!")
			lines.Cut(MUSIC_MAXLINES + 1)
		var/linenum = 1
		for(var/l in lines)
			if(length_char(l) > MUSIC_MAXLINECHARS)
				if(user)
					to_chat(user, "Line [linenum] too long!")
				lines.Remove(l)
			else
				linenum++
