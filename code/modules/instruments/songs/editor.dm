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
			data["sustain_mode_button"] = "Linear Sustain Duration (in seconds)"
			data["sustain_mode_duration"] = sustain_linear_duration / 10
			data["sustain_mode_min"] = INSTRUMENT_MIN_TOTAL_SUSTAIN
			data["sustain_mode_max"] = INSTRUMENT_MAX_TOTAL_SUSTAIN
		if(SUSTAIN_EXPONENTIAL)
			data["sustain_mode_button"] = "Exponential Falloff Factor (% per decisecond)"
			data["sustain_mode_duration"] = sustain_exponential_dropoff
			data["sustain_mode_min"] = INSTRUMENT_EXP_FALLOFF_MIN
			data["sustain_mode_max"] = INSTRUMENT_EXP_FALLOFF_MAX
	data["instrument_ready"] = using_instrument?.ready()
	data["volume"] = volume
	data["volume_dropoff_threshold"] = sustain_dropoff_volume
	data["sustain_indefinitely"] = full_sustain_held_note
	data["playing"] = playing
	data["repeat"] = repeat
	data["bpm"] = round(60 SECONDS / tempo)
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
	data["possible_instruments"] = list()
	for(var/instrument in allowed_instrument_ids)
		UNTYPED_LIST_ADD(data["possible_instruments"], list("name" = SSinstruments.instrument_data[instrument], "id" = instrument))
	data["sustain_modes"] = SSinstruments.note_sustain_modes
	data["max_repeats"] = max_repeats
	data["min_volume"] = min_volume
	data["max_volume"] = max_volume
	data["note_shift_min"] = note_shift_min
	data["note_shift_max"] = note_shift_max
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
		if("change_instrument")
			var/new_instrument = params["new_instrument"]
			//only one instrument, so no need to bother changing it.
			if(!length(allowed_instrument_ids))
				return FALSE
			if(!(new_instrument in allowed_instrument_ids))
				return FALSE
			set_instrument(new_instrument)
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
				song_text = tgui_input_text(user, "Please paste the entire song, formatted:", name, max_length = (MUSIC_MAXLINES * MUSIC_MAXLINECHARS), multiline = TRUE)
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
			var/new_mode = params["new_mode"]
			if(isnull(new_mode) || !(new_mode in SSinstruments.note_sustain_modes))
				return FALSE
			sustain_mode = new_mode
			return TRUE
		if("set_note_shift")
			var/amount = params["amount"]
			if(!isnum(amount))
				return FALSE
			note_shift = clamp(amount, note_shift_min, note_shift_max)
			return TRUE
		if("set_volume")
			var/new_volume = params["amount"]
			if(!isnum(new_volume))
				return FALSE
			set_volume(new_volume)
			return TRUE
		if("set_dropoff_volume")
			var/dropoff_threshold = params["amount"]
			if(!isnum(dropoff_threshold))
				return FALSE
			set_dropoff_volume(dropoff_threshold)
			return TRUE
		if("toggle_sustain_hold_indefinitely")
			full_sustain_held_note = !full_sustain_held_note
			return TRUE
		if("set_repeat_amount")
			if(playing)
				return
			var/repeat_amount = params["amount"]
			if(!isnum(repeat_amount))
				return FALSE
			set_repeats(repeat_amount)
			return TRUE
		if("edit_sustain_mode")
			var/sustain_amount = params["amount"]
			if(isnull(sustain_amount) || !isnum(sustain_amount))
				return
			switch(sustain_mode)
				if(SUSTAIN_LINEAR)
					set_linear_falloff_duration(sustain_amount)
				if(SUSTAIN_EXPONENTIAL)
					set_exponential_drop_rate(sustain_amount)

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
