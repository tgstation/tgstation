/**
 * Returns the HTML for the status UI for this song datum.
 */
/datum/song/proc/instrument_status_ui()
	. = list()
	. += "<div class='statusDisplay'>"
	. += "<b><a href='?src=[REF(src)];switchinstrument=1'>Current instrument</a>:</b> "
	if(!using_instrument)
		. += "[span_danger("No instrument loaded!")]<br>"
	else
		. += "[using_instrument.name]<br>"
	. += "Playback Settings:<br>"
	if(can_noteshift)
		. += "<a href='?src=[REF(src)];setnoteshift=1'>Note Shift/Note Transpose</a>: [note_shift] keys / [round(note_shift / 12, 0.01)] octaves<br>"
	var/smt
	var/modetext = ""
	switch(sustain_mode)
		if(SUSTAIN_LINEAR)
			smt = "Linear"
			modetext = "<a href='?src=[REF(src)];setlinearfalloff=1'>Linear Sustain Duration</a>: [sustain_linear_duration / 10] seconds<br>"
		if(SUSTAIN_EXPONENTIAL)
			smt = "Exponential"
			modetext = "<a href='?src=[REF(src)];setexpfalloff=1'>Exponential Falloff Factor</a>: [sustain_exponential_dropoff]% per decisecond<br>"
	. += "<a href='?src=[REF(src)];setsustainmode=1'>Sustain Mode</a>: [smt]<br>"
	. += modetext
	. += using_instrument?.ready()? "Status: <span class='good'>Ready</span><br>" : "Status: <span class='bad'>!Instrument Definition Error!</span><br>"
	. += "Instrument Type: [legacy? "Legacy" : "Synthesized"]<br>"
	. += "<a href='?src=[REF(src)];setvolume=1'>Volume</a>: [volume]<br>"
	. += "<a href='?src=[REF(src)];setdropoffvolume=1'>Volume Dropoff Threshold</a>: [sustain_dropoff_volume]<br>"
	. += "<a href='?src=[REF(src)];togglesustainhold=1'>Sustain indefinitely last held note</a>: [full_sustain_held_note? "Enabled" : "Disabled"].<br>"
	. += "</div>"

/datum/song/ui_interact(mob/user)
	var/list/dat = list()

	dat += instrument_status_ui()

	if(lines.len > 0)
		dat += "<H3>Playback</H3>"
		if(!playing)
			dat += "<A href='?src=[REF(src)];play=1'>Play</A> <span class='linkOn'>Stop</span><BR><BR>"
			dat += "Repeat Song: "
			dat += repeat > 0 ? "<A href='?src=[REF(src)];repeat=-10'>-</A><A href='?src=[REF(src)];repeat=-1'>-</A>" : "<span class='linkOff'>-</SPAN><SPAN CLASS='linkOff'>-</span>"
			dat += " [repeat] times "
			dat += repeat < max_repeats ? "<A href='?src=[REF(src)];repeat=1'>+</A><A href='?src=[REF(src)];repeat=10'>+</A>" : "<span class='linkOff'>+</SPAN><SPAN CLASS='linkOff'>+</span>"
			dat += "<BR>"
		else
			dat += "<span class='linkOn'>Play</span> <A href='?src=[REF(src)];stop=1'>Stop</A><BR>"
			dat += "Repeats left: <B>[repeat]</B><BR>"
	if(!editing)
		dat += "<BR><B><A href='?src=[REF(src)];edit=2'>Show Editor</A></B><BR>"
	else
		dat += "<H3>Editing</H3>"
		dat += "<B><A href='?src=[REF(src)];edit=1'>Hide Editor</A></B>"
		dat += " <A href='?src=[REF(src)];newsong=1'>Start a New Song</A>"
		dat += " <A href='?src=[REF(src)];import=1'>Import a Song</A><BR><BR>"
		var/bpm = round(600 / tempo)
		dat += "Tempo: <A href='?src=[REF(src)];tempo=[world.tick_lag]'>-</A> [bpm] BPM <A href='?src=[REF(src)];tempo=-[world.tick_lag]'>+</A><BR><BR>"
		var/linecount = 0
		for(var/line in lines)
			linecount += 1
			dat += "Line [linecount]: <A href='?src=[REF(src)];modifyline=[linecount]'>Edit</A> <A href='?src=[REF(src)];deleteline=[linecount]'>X</A> [line]<BR>"
		dat += "<A href='?src=[REF(src)];newline=1'>Add Line</A><BR><BR>"
		if(help)
			dat += "<B><A href='?src=[REF(src)];help=1'>Hide Help</A></B><BR>"
			dat += {"
					Lines are a series of chords, separated by commas (,), each with notes separated by hyphens (-).<br>
					Every note in a chord will play together, with chord timed by the tempo.<br>
					<br>
					Notes are played by the names of the note, and optionally, the accidental, and/or the octave number.<br>
					By default, every note is natural and in octave 3. Defining otherwise is remembered for each note.<br>
					Example: <i>C,D,E,F,G,A,B</i> will play a C major scale.<br>
					After a note has an accidental placed, it will be remembered: <i>C,C4,C,C3</i> is <i>C3,C4,C4,C3</i><br>
					Chords can be played simply by seperating each note with a hyphon: <i>A-C#,Cn-E,E-G#,Gn-B</i><br>
					A pause may be denoted by an empty chord: <i>C,E,,C,G</i><br>
					To make a chord be a different time, end it with /x, where the chord length will be length<br>
					defined by tempo / x: <i>C,G/2,E/4</i><br>
					Combined, an example is: <i>E-E4/4,F#/2,G#/8,B/8,E3-E4/4</i>
					<br>
					Lines may be up to [MUSIC_MAXLINECHARS] characters.<br>
					A song may only contain up to [MUSIC_MAXLINES] lines.<br>
					"}
		else
			dat += "<B><A href='?src=[REF(src)];help=2'>Show Help</A></B><BR>"

	var/datum/browser/popup = new(user, "instrument", parent?.name || "instrument", 700, 500)
	popup.set_content(dat.Join(""))
	popup.open()

/**
 * Parses a song the user has input into lines and stores them.
 */
/datum/song/proc/ParseSong(new_song)
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
			to_chat(usr, "Too many lines!")
			lines.Cut(MUSIC_MAXLINES + 1)
		var/linenum = 1
		for(var/l in lines)
			if(length_char(l) > MUSIC_MAXLINECHARS)
				to_chat(usr, "Line [linenum] too long!")
				lines.Remove(l)
			else
				linenum++
		updateDialog(usr) // make sure updates when complete

/datum/song/Topic(href, href_list)
	if(!usr.canUseTopic(parent, TRUE, FALSE, FALSE, FALSE))
		usr << browse(null, "window=instrument")
		usr.unset_machine()
		return

	parent.add_fingerprint(usr)

	if(href_list["newsong"])
		lines = new()
		tempo = sanitize_tempo(5) // default 120 BPM
		name = ""

	else if(href_list["import"])
		var/t = ""
		do
			t = html_encode(input(usr, "Please paste the entire song, formatted:", text("[]", name), t)  as message)
			if(!in_range(parent, usr))
				return

			if(length_char(t) >= MUSIC_MAXLINES * MUSIC_MAXLINECHARS)
				var/cont = tgui_alert(usr, "Your message is too long! Would you like to continue editing it?", "Warning", list("Yes", "No"))
				if(cont != "Yes")
					break
		while(length_char(t) > MUSIC_MAXLINES * MUSIC_MAXLINECHARS)
		ParseSong(t)

	else if(href_list["help"])
		help = text2num(href_list["help"]) - 1

	else if(href_list["edit"])
		editing = text2num(href_list["edit"]) - 1

	if(href_list["repeat"]) //Changing this from a toggle to a number of repeats to avoid infinite loops.
		set_repeats(repeat + text2num(href_list["repeat"]))

	else if(href_list["tempo"])
		tempo = sanitize_tempo(tempo + text2num(href_list["tempo"]))

	else if(href_list["play"])
		INVOKE_ASYNC(src, .proc/start_playing, usr)

	else if(href_list["newline"])
		var/newline = tgui_input_text(usr, "Enter your line ", parent.name)
		if(!newline || !in_range(parent, usr))
			return
		if(lines.len > MUSIC_MAXLINES)
			return
		if(length(newline) > MUSIC_MAXLINECHARS)
			newline = copytext(newline, 1, MUSIC_MAXLINECHARS)
		lines.Add(newline)

	else if(href_list["deleteline"])
		var/num = round(text2num(href_list["deleteline"]))
		if(num > lines.len || num < 1)
			return
		lines.Cut(num, num+1)

	else if(href_list["modifyline"])
		var/num = round(text2num(href_list["modifyline"]),1)
		var/content = tgui_input_text(usr, "Enter your line ", parent.name, lines[num], MUSIC_MAXLINECHARS)
		if(!content || !in_range(parent, usr))
			return
		if(num > lines.len || num < 1)
			return
		lines[num] = content

	else if(href_list["stop"])
		stop_playing()

	else if(href_list["setlinearfalloff"])
		var/amount = tgui_input_number(usr, "Set linear sustain duration in seconds", "Linear Sustain Duration")
		if(!isnull(amount))
			set_linear_falloff_duration(amount)

	else if(href_list["setexpfalloff"])
		var/amount = tgui_input_number(usr, "Set exponential sustain factor", "Exponential sustain factor")
		if(!isnull(amount))
			set_exponential_drop_rate(amount)

	else if(href_list["setvolume"])
		var/amount = tgui_input_number(usr, "Set volume", "Volume")
		if(!isnull(amount))
			set_volume(amount)

	else if(href_list["setdropoffvolume"])
		var/amount = tgui_input_number(usr, "Set dropoff threshold", "Dropoff Threshold Volume")
		if(!isnull(amount))
			set_dropoff_volume(amount)

	else if(href_list["switchinstrument"])
		if(!length(allowed_instrument_ids))
			return
		else if(length(allowed_instrument_ids) == 1)
			set_instrument(allowed_instrument_ids[1])
			return
		var/list/categories = list()
		for(var/i in allowed_instrument_ids)
			var/datum/instrument/I = SSinstruments.get_instrument(i)
			if(I)
				LAZYSET(categories[I.category || "ERROR CATEGORY"], I.name, I.id)
		var/cat = tgui_input_list(usr, "Select Category", "Instrument Category", categories)
		if(isnull(cat))
			return
		var/list/instruments = categories[cat]
		var/choice = tgui_input_list(usr, "Select Instrument", "Instrument Selection", instruments)
		if(isnull(choice))
			return
		if(isnull(instruments[choice]))
			return
		choice = instruments[choice] //get id
		if(choice)
			set_instrument(choice)

	else if(href_list["setnoteshift"])
		var/amount = input(usr, "Set note shift", "Note Shift") as null|num
		if(!isnull(amount))
			note_shift = clamp(amount, note_shift_min, note_shift_max)

	else if(href_list["setsustainmode"])
		var/choice = tgui_input_list(usr, "Choose a sustain mode", "Sustain Mode", SSinstruments.note_sustain_modes)
		if(choice)
			sustain_mode = SSinstruments.note_sustain_modes[choice]

	else if(href_list["togglesustainhold"])
		full_sustain_held_note = !full_sustain_held_note

	updateDialog()
