

/datum/song
	var/name = "Untitled"
	var/list/lines = new()
	var/tempo = 5			// delay between notes

	var/playing = 0			// if we're playing
	var/help = 0			// if help is open
	var/edit = 1			// if we're in editing mode
	var/repeat = 0			// number of times remaining to repeat
	var/max_repeats = 10	// maximum times we can repeat

	var/instrumentDir = "piano"		// the folder with the sounds
	var/instrumentExt = "ogg"		// the file extension
	var/obj/instrumentObj = null	// the associated obj playing the sound

	var/global/soundfiles = list(
		"sound/guitar/Ab3.ogg" = 'sound/guitar/Ab3.ogg',
		"sound/guitar/Ab4.ogg" = 'sound/guitar/Ab4.ogg',
		"sound/guitar/Ab5.ogg" = 'sound/guitar/Ab5.ogg',
		"sound/guitar/Ab6.ogg" = 'sound/guitar/Ab6.ogg',
		"sound/guitar/An3.ogg" = 'sound/guitar/An3.ogg',
		"sound/guitar/An4.ogg" = 'sound/guitar/An4.ogg',
		"sound/guitar/An5.ogg" = 'sound/guitar/An5.ogg',
		"sound/guitar/An6.ogg" = 'sound/guitar/An6.ogg',
		"sound/guitar/Bb3.ogg" = 'sound/guitar/Bb3.ogg',
		"sound/guitar/Bb4.ogg" = 'sound/guitar/Bb4.ogg',
		"sound/guitar/Bb5.ogg" = 'sound/guitar/Bb5.ogg',
		"sound/guitar/Bb6.ogg" = 'sound/guitar/Bb6.ogg',
		"sound/guitar/Bn3.ogg" = 'sound/guitar/Bn3.ogg',
		"sound/guitar/Bn4.ogg" = 'sound/guitar/Bn4.ogg',
		"sound/guitar/Bn5.ogg" = 'sound/guitar/Bn5.ogg',
		"sound/guitar/Bn6.ogg" = 'sound/guitar/Bn6.ogg',
//		"sound/guitar/Cb4.ogg" = 'sound/guitar/Cb4.ogg',
//		"sound/guitar/Cb5.ogg" = 'sound/guitar/Cb5.ogg',
//		"sound/guitar/Cb6.ogg" = 'sound/guitar/Cb6.ogg',
//		"sound/guitar/Cb7.ogg" = 'sound/guitar/Cb7.ogg',
		"sound/guitar/Cn4.ogg" = 'sound/guitar/Cn4.ogg',
		"sound/guitar/Cn5.ogg" = 'sound/guitar/Cn5.ogg',
		"sound/guitar/Cn6.ogg" = 'sound/guitar/Cn6.ogg',
		"sound/guitar/Db4.ogg" = 'sound/guitar/Db4.ogg',
		"sound/guitar/Db5.ogg" = 'sound/guitar/Db5.ogg',
		"sound/guitar/Db6.ogg" = 'sound/guitar/Db6.ogg',
		"sound/guitar/Dn4.ogg" = 'sound/guitar/Dn4.ogg',
		"sound/guitar/Dn5.ogg" = 'sound/guitar/Dn5.ogg',
		"sound/guitar/Dn6.ogg" = 'sound/guitar/Dn6.ogg',
		"sound/guitar/Eb4.ogg" = 'sound/guitar/Eb4.ogg',
		"sound/guitar/Eb5.ogg" = 'sound/guitar/Eb5.ogg',
		"sound/guitar/Eb6.ogg" = 'sound/guitar/Eb6.ogg',
		"sound/guitar/En3.ogg" = 'sound/guitar/En3.ogg',
		"sound/guitar/En4.ogg" = 'sound/guitar/En4.ogg',
		"sound/guitar/En5.ogg" = 'sound/guitar/En5.ogg',
		"sound/guitar/En6.ogg" = 'sound/guitar/En6.ogg',
//		"sound/guitar/Fb3.ogg" = 'sound/guitar/Fb3.ogg',
	//	"sound/guitar/Fb4.ogg" = 'sound/guitar/Fb4.ogg',
	//	"sound/guitar/Fb5.ogg" = 'sound/guitar/Fb5.ogg',
	//	"sound/guitar/Fb6.ogg" = 'sound/guitar/Fb6.ogg',
		"sound/guitar/Fn3.ogg" = 'sound/guitar/Fn3.ogg',
		"sound/guitar/Fn4.ogg" = 'sound/guitar/Fn4.ogg',
		"sound/guitar/Fn5.ogg" = 'sound/guitar/Fn5.ogg',
		"sound/guitar/Fn6.ogg" = 'sound/guitar/Fn6.ogg',
		"sound/guitar/Gb3.ogg" = 'sound/guitar/Gb3.ogg',
		"sound/guitar/Gb4.ogg" = 'sound/guitar/Gb4.ogg',
		"sound/guitar/Gb5.ogg" = 'sound/guitar/Gb5.ogg',
		"sound/guitar/Gb6.ogg" = 'sound/guitar/Gb6.ogg',
		"sound/guitar/Gn3.ogg" = 'sound/guitar/Gn3.ogg',
		"sound/guitar/Gn4.ogg" = 'sound/guitar/Gn4.ogg',
		"sound/guitar/Gn5.ogg" = 'sound/guitar/Gn5.ogg',
		"sound/guitar/Gn6.ogg" = 'sound/guitar/Gn6.ogg',
		"sound/piano/Ab1.ogg" = 'sound/piano/Ab1.ogg',
		"sound/piano/Ab2.ogg" = 'sound/piano/Ab2.ogg',
		"sound/piano/Ab3.ogg" = 'sound/piano/Ab3.ogg',
		"sound/piano/Ab4.ogg" = 'sound/piano/Ab4.ogg',
		"sound/piano/Ab5.ogg" = 'sound/piano/Ab5.ogg',
		"sound/piano/Ab6.ogg" = 'sound/piano/Ab6.ogg',
		"sound/piano/Ab7.ogg" = 'sound/piano/Ab7.ogg',
		"sound/piano/Ab8.ogg" = 'sound/piano/Ab8.ogg',
		"sound/piano/An1.ogg" = 'sound/piano/An1.ogg',
		"sound/piano/An2.ogg" = 'sound/piano/An2.ogg',
		"sound/piano/An3.ogg" = 'sound/piano/An3.ogg',
		"sound/piano/An4.ogg" = 'sound/piano/An4.ogg',
		"sound/piano/An5.ogg" = 'sound/piano/An5.ogg',
		"sound/piano/An6.ogg" = 'sound/piano/An6.ogg',
		"sound/piano/An7.ogg" = 'sound/piano/An7.ogg',
		"sound/piano/An8.ogg" = 'sound/piano/An8.ogg',
		"sound/piano/Bb1.ogg" = 'sound/piano/Bb1.ogg',
		"sound/piano/Bb2.ogg" = 'sound/piano/Bb2.ogg',
		"sound/piano/Bb3.ogg" = 'sound/piano/Bb3.ogg',
		"sound/piano/Bb4.ogg" = 'sound/piano/Bb4.ogg',
		"sound/piano/Bb5.ogg" = 'sound/piano/Bb5.ogg',
		"sound/piano/Bb6.ogg" = 'sound/piano/Bb6.ogg',
		"sound/piano/Bb7.ogg" = 'sound/piano/Bb7.ogg',
		"sound/piano/Bb8.ogg" = 'sound/piano/Bb8.ogg',
		"sound/piano/Bn1.ogg" = 'sound/piano/Bn1.ogg',
		"sound/piano/Bn2.ogg" = 'sound/piano/Bn2.ogg',
		"sound/piano/Bn3.ogg" = 'sound/piano/Bn3.ogg',
		"sound/piano/Bn4.ogg" = 'sound/piano/Bn4.ogg',
		"sound/piano/Bn5.ogg" = 'sound/piano/Bn5.ogg',
		"sound/piano/Bn6.ogg" = 'sound/piano/Bn6.ogg',
		"sound/piano/Bn7.ogg" = 'sound/piano/Bn7.ogg',
		"sound/piano/Bn8.ogg" = 'sound/piano/Bn8.ogg',
		"sound/piano/Cn1.ogg" = 'sound/piano/Cn1.ogg',
		"sound/piano/Cn2.ogg" = 'sound/piano/Cn2.ogg',
		"sound/piano/Cn3.ogg" = 'sound/piano/Cn3.ogg',
		"sound/piano/Cn4.ogg" = 'sound/piano/Cn4.ogg',
		"sound/piano/Cn5.ogg" = 'sound/piano/Cn5.ogg',
		"sound/piano/Cn6.ogg" = 'sound/piano/Cn6.ogg',
		"sound/piano/Cn7.ogg" = 'sound/piano/Cn7.ogg',
		"sound/piano/Cn8.ogg" = 'sound/piano/Cn8.ogg',
		"sound/piano/Cn9.ogg" = 'sound/piano/Cn9.ogg',
		"sound/piano/Db1.ogg" = 'sound/piano/Db1.ogg',
		"sound/piano/Db2.ogg" = 'sound/piano/Db2.ogg',
		"sound/piano/Db3.ogg" = 'sound/piano/Db3.ogg',
		"sound/piano/Db4.ogg" = 'sound/piano/Db4.ogg',
		"sound/piano/Db5.ogg" = 'sound/piano/Db5.ogg',
		"sound/piano/Db6.ogg" = 'sound/piano/Db6.ogg',
		"sound/piano/Db7.ogg" = 'sound/piano/Db7.ogg',
		"sound/piano/Db8.ogg" = 'sound/piano/Db8.ogg',
		"sound/piano/Dn1.ogg" = 'sound/piano/Dn1.ogg',
		"sound/piano/Dn2.ogg" = 'sound/piano/Dn2.ogg',
		"sound/piano/Dn3.ogg" = 'sound/piano/Dn3.ogg',
		"sound/piano/Dn4.ogg" = 'sound/piano/Dn4.ogg',
		"sound/piano/Dn5.ogg" = 'sound/piano/Dn5.ogg',
		"sound/piano/Dn6.ogg" = 'sound/piano/Dn6.ogg',
		"sound/piano/Dn7.ogg" = 'sound/piano/Dn7.ogg',
		"sound/piano/Dn8.ogg" = 'sound/piano/Dn8.ogg',
		"sound/piano/Eb1.ogg" = 'sound/piano/Eb1.ogg',
		"sound/piano/Eb2.ogg" = 'sound/piano/Eb2.ogg',
		"sound/piano/Eb3.ogg" = 'sound/piano/Eb3.ogg',
		"sound/piano/Eb4.ogg" = 'sound/piano/Eb4.ogg',
		"sound/piano/Eb5.ogg" = 'sound/piano/Eb5.ogg',
		"sound/piano/Eb6.ogg" = 'sound/piano/Eb6.ogg',
		"sound/piano/Eb7.ogg" = 'sound/piano/Eb7.ogg',
		"sound/piano/Eb8.ogg" = 'sound/piano/Eb8.ogg',
		"sound/piano/En1.ogg" = 'sound/piano/En1.ogg',
		"sound/piano/En2.ogg" = 'sound/piano/En2.ogg',
		"sound/piano/En3.ogg" = 'sound/piano/En3.ogg',
		"sound/piano/En4.ogg" = 'sound/piano/En4.ogg',
		"sound/piano/En5.ogg" = 'sound/piano/En5.ogg',
		"sound/piano/En6.ogg" = 'sound/piano/En6.ogg',
		"sound/piano/En7.ogg" = 'sound/piano/En7.ogg',
		"sound/piano/En8.ogg" = 'sound/piano/En8.ogg',
		"sound/piano/Fn1.ogg" = 'sound/piano/Fn1.ogg',
		"sound/piano/Fn2.ogg" = 'sound/piano/Fn2.ogg',
		"sound/piano/Fn3.ogg" = 'sound/piano/Fn3.ogg',
		"sound/piano/Fn4.ogg" = 'sound/piano/Fn4.ogg',
		"sound/piano/Fn5.ogg" = 'sound/piano/Fn5.ogg',
		"sound/piano/Fn6.ogg" = 'sound/piano/Fn6.ogg',
		"sound/piano/Fn7.ogg" = 'sound/piano/Fn7.ogg',
		"sound/piano/Fn8.ogg" = 'sound/piano/Fn8.ogg',
		"sound/piano/Gb1.ogg" = 'sound/piano/Gb1.ogg',
		"sound/piano/Gb2.ogg" = 'sound/piano/Gb2.ogg',
		"sound/piano/Gb3.ogg" = 'sound/piano/Gb3.ogg',
		"sound/piano/Gb4.ogg" = 'sound/piano/Gb4.ogg',
		"sound/piano/Gb5.ogg" = 'sound/piano/Gb5.ogg',
		"sound/piano/Gb6.ogg" = 'sound/piano/Gb6.ogg',
		"sound/piano/Gb7.ogg" = 'sound/piano/Gb7.ogg',
		"sound/piano/Gb8.ogg" = 'sound/piano/Gb8.ogg',
		"sound/piano/Gn1.ogg" = 'sound/piano/Gn1.ogg',
		"sound/piano/Gn2.ogg" = 'sound/piano/Gn2.ogg',
		"sound/piano/Gn3.ogg" = 'sound/piano/Gn3.ogg',
		"sound/piano/Gn4.ogg" = 'sound/piano/Gn4.ogg',
		"sound/piano/Gn5.ogg" = 'sound/piano/Gn5.ogg',
		"sound/piano/Gn6.ogg" = 'sound/piano/Gn6.ogg',
		"sound/piano/Gn7.ogg" = 'sound/piano/Gn7.ogg',
		"sound/piano/Gn8.ogg" = 'sound/piano/Gn8.ogg',
		"sound/violin/Ab3.ogg" = 'sound/violin/Ab3.ogg',
		"sound/violin/Ab4.ogg" = 'sound/violin/Ab4.ogg',
		"sound/violin/Ab5.ogg" = 'sound/violin/Ab5.ogg',
		"sound/violin/Ab6.ogg" = 'sound/violin/Ab6.ogg',
		"sound/violin/An3.ogg" = 'sound/violin/An3.ogg',
		"sound/violin/An4.ogg" = 'sound/violin/An4.ogg',
		"sound/violin/An5.ogg" = 'sound/violin/An5.ogg',
		"sound/violin/An6.ogg" = 'sound/violin/An6.ogg',
		"sound/violin/Bb3.ogg" = 'sound/violin/Bb3.ogg',
		"sound/violin/Bb4.ogg" = 'sound/violin/Bb4.ogg',
		"sound/violin/Bb5.ogg" = 'sound/violin/Bb5.ogg',
		"sound/violin/Bb6.ogg" = 'sound/violin/Bb6.ogg',
		"sound/violin/Bn3.ogg" = 'sound/violin/Bn3.ogg',
		"sound/violin/Bn4.ogg" = 'sound/violin/Bn4.ogg',
		"sound/violin/Bn5.ogg" = 'sound/violin/Bn5.ogg',
		"sound/violin/Bn6.ogg" = 'sound/violin/Bn6.ogg',
		"sound/violin/Cn4.ogg" = 'sound/violin/Cn4.ogg',
		"sound/violin/Cn5.ogg" = 'sound/violin/Cn5.ogg',
		"sound/violin/Cn6.ogg" = 'sound/violin/Cn6.ogg',
		"sound/violin/Cn7.ogg" = 'sound/violin/Cn7.ogg',
		"sound/violin/Db4.ogg" = 'sound/violin/Db4.ogg',
		"sound/violin/Db5.ogg" = 'sound/violin/Db5.ogg',
		"sound/violin/Db6.ogg" = 'sound/violin/Db6.ogg',
		"sound/violin/Db7.ogg" = 'sound/violin/Db7.ogg',
		"sound/violin/Dn4.ogg" = 'sound/violin/Dn4.ogg',
		"sound/violin/Dn5.ogg" = 'sound/violin/Dn5.ogg',
		"sound/violin/Dn6.ogg" = 'sound/violin/Dn6.ogg',
		"sound/violin/Dn7.ogg" = 'sound/violin/Dn7.ogg',
		"sound/violin/Eb4.ogg" = 'sound/violin/Eb4.ogg',
		"sound/violin/Eb5.ogg" = 'sound/violin/Eb5.ogg',
		"sound/violin/Eb6.ogg" = 'sound/violin/Eb6.ogg',
		"sound/violin/En4.ogg" = 'sound/violin/En4.ogg',
		"sound/violin/En5.ogg" = 'sound/violin/En5.ogg',
		"sound/violin/En6.ogg" = 'sound/violin/En6.ogg',
		"sound/violin/Fn4.ogg" = 'sound/violin/Fn4.ogg',
		"sound/violin/Fn5.ogg" = 'sound/violin/Fn5.ogg',
		"sound/violin/Fn6.ogg" = 'sound/violin/Fn6.ogg',
		"sound/violin/Gb4.ogg" = 'sound/violin/Gb4.ogg',
		"sound/violin/Gb5.ogg" = 'sound/violin/Gb5.ogg',
		"sound/violin/Gb6.ogg" = 'sound/violin/Gb6.ogg',
		"sound/violin/Gn3.ogg" = 'sound/violin/Gn3.ogg',
		"sound/violin/Gn4.ogg" = 'sound/violin/Gn4.ogg',
		"sound/violin/Gn5.ogg" = 'sound/violin/Gn5.ogg',
		"sound/violin/Gn6.ogg" = 'sound/violin/Gn6.ogg'
		)

/datum/song/New(dir, obj)
	tempo = sanitize_tempo(tempo)
	instrumentDir = dir
	instrumentObj = obj

/datum/song/Destroy()
	instrumentObj = null
	return ..()

// note is a number from 1-7 for A-G
// acc is either "b", "n", or "#"
// oct is 1-8 (or 9 for C)
/datum/song/proc/playnote(note, acc as text, oct)
	// handle accidental -> B<>C of E<>F
	if(acc == "b" && (note == 3 || note == 6)) // C or F
		if(note == 3)
			oct--
		note--
		acc = "n"
	else if(acc == "#" && (note == 2 || note == 5)) // B or E
		if(note == 2)
			oct++
		note++
		acc = "n"
	else if(acc == "#" && (note == 7)) //G#
		note = 1
		acc = "b"
	else if(acc == "#") // mass convert all sharps to flats, octave jump already handled
		acc = "b"
		note++

	// check octave, C is allowed to go to 9
	if(oct < 1 || (note == 3 ? oct > 9 : oct > 8))
		return

	// now generate name
	var/soundfile = soundfiles["sound/[instrumentDir]/[ascii2text(note+64)][acc][oct].[instrumentExt]"]
	// make sure the note exists
	if(!soundfile)
		return
	// and play
	var/turf/source = get_turf(instrumentObj)
	for(var/mob/M in get_hearers_in_view(15, source))
		if(!M.client || !(M.client.prefs.toggles & SOUND_INSTRUMENTS))
			continue
		M.playsound_local(source, soundfile, 100, falloff = 5)

/datum/song/proc/updateDialog(mob/user)
	instrumentObj.updateDialog()		// assumes it's an object in world, override if otherwise

/datum/song/proc/shouldStopPlaying(mob/user)
	if(instrumentObj)
		if(!user.canUseTopic(instrumentObj))
			return 1
		return !instrumentObj.anchored		// add special cases to stop in subclasses
	else
		return 1

/datum/song/proc/playsong(mob/user)
	while(repeat >= 0)
		var/cur_oct[7]
		var/cur_acc[7]
		for(var/i = 1 to 7)
			cur_oct[i] = 3
			cur_acc[i] = "n"

		for(var/line in lines)
			//to_chat(world, line)
			for(var/beat in splittext(lowertext(line), ","))
				//to_chat(world, "beat: [beat]")
				var/list/notes = splittext(beat, "/")
				for(var/note in splittext(notes[1], "-"))
					//to_chat(world, "note: [note]")
					if(!playing || shouldStopPlaying(user))//If the instrument is playing, or special case
						playing = 0
						return
					if(lentext(note) == 0)
						continue
					//to_chat(world, "Parse: [copytext(note,1,2)]")
					var/cur_note = text2ascii(note) - 96
					if(cur_note < 1 || cur_note > 7)
						continue
					for(var/i=2 to lentext(note))
						var/ni = copytext(note,i,i+1)
						if(!text2num(ni))
							if(ni == "#" || ni == "b" || ni == "n")
								cur_acc[cur_note] = ni
							else if(ni == "s")
								cur_acc[cur_note] = "#" // so shift is never required
						else
							cur_oct[cur_note] = text2num(ni)
					if(user.dizziness > 0 && prob(user.dizziness / 2))
						cur_note = Clamp(cur_note + rand(round(-user.dizziness / 10), round(user.dizziness / 10)), 1, 7)
					if(user.dizziness > 0 && prob(user.dizziness / 5))
						if(prob(30))
							cur_acc[cur_note] = "#"
						else if(prob(42))
							cur_acc[cur_note] = "b"
						else if(prob(75))
							cur_acc[cur_note] = "n"
					playnote(cur_note, cur_acc[cur_note], cur_oct[cur_note])
				if(notes.len >= 2 && text2num(notes[2]))
					sleep(sanitize_tempo(tempo / text2num(notes[2])))
				else
					sleep(tempo)
		repeat--
	playing = 0
	repeat = 0
	updateDialog(user)

/datum/song/proc/interact(mob/user)
	var/dat = ""

	if(lines.len > 0)
		dat += "<H3>Playback</H3>"
		if(!playing)
			dat += "<A href='?src=\ref[src];play=1'>Play</A> <SPAN CLASS='linkOn'>Stop</SPAN><BR><BR>"
			dat += "Repeat Song: "
			dat += repeat > 0 ? "<A href='?src=\ref[src];repeat=-10'>-</A><A href='?src=\ref[src];repeat=-1'>-</A>" : "<SPAN CLASS='linkOff'>-</SPAN><SPAN CLASS='linkOff'>-</SPAN>"
			dat += " [repeat] times "
			dat += repeat < max_repeats ? "<A href='?src=\ref[src];repeat=1'>+</A><A href='?src=\ref[src];repeat=10'>+</A>" : "<SPAN CLASS='linkOff'>+</SPAN><SPAN CLASS='linkOff'>+</SPAN>"
			dat += "<BR>"
		else
			dat += "<SPAN CLASS='linkOn'>Play</SPAN> <A href='?src=\ref[src];stop=1'>Stop</A><BR>"
			dat += "Repeats left: <B>[repeat]</B><BR>"
	if(!edit)
		dat += "<BR><B><A href='?src=\ref[src];edit=2'>Show Editor</A></B><BR>"
	else
		dat += "<H3>Editing</H3>"
		dat += "<B><A href='?src=\ref[src];edit=1'>Hide Editor</A></B>"
		dat += " <A href='?src=\ref[src];newsong=1'>Start a New Song</A>"
		dat += " <A href='?src=\ref[src];import=1'>Import a Song</A><BR><BR>"
		var/bpm = round(600 / tempo)
		dat += "Tempo: <A href='?src=\ref[src];tempo=[world.tick_lag]'>-</A> [bpm] BPM <A href='?src=\ref[src];tempo=-[world.tick_lag]'>+</A><BR><BR>"
		var/linecount = 0
		for(var/line in lines)
			linecount += 1
			dat += "Line [linecount]: <A href='?src=\ref[src];modifyline=[linecount]'>Edit</A> <A href='?src=\ref[src];deleteline=[linecount]'>X</A> [line]<BR>"
		dat += "<A href='?src=\ref[src];newline=1'>Add Line</A><BR><BR>"
		if(help)
			dat += "<B><A href='?src=\ref[src];help=1'>Hide Help</A></B><BR>"
			dat += {"
					Lines are a series of chords, separated by commas (,), each with notes seperated by hyphens (-).<br>
					Every note in a chord will play together, with chord timed by the tempo.<br>
					<br>
					Notes are played by the names of the note, and optionally, the accidental, and/or the octave number.<br>
					By default, every note is natural and in octave 3. Defining otherwise is remembered for each note.<br>
					Example: <i>C,D,E,F,G,A,B</i> will play a C major scale.<br>
					After a note has an accidental placed, it will be remembered: <i>C,C4,C,C3</i> is C3,C4,C4,C3</i><br>
					Chords can be played simply by seperating each note with a hyphon: <i>A-C#,Cn-E,E-G#,Gn-B</i><br>
					A pause may be denoted by an empty chord: <i>C,E,,C,G</i><br>
					To make a chord be a different time, end it with /x, where the chord length will be length<br>
					defined by tempo / x: <i>C,G/2,E/4</i><br>
					Combined, an example is: <i>E-E4/4,F#/2,G#/8,B/8,E3-E4/4</i>
					<br>
					Lines may be up to 50 characters.<br>
					A song may only contain up to 50 lines.<br>
					"}
		else
			dat += "<B><A href='?src=\ref[src];help=2'>Show Help</A></B><BR>"

	var/datum/browser/popup = new(user, "instrument", instrumentObj.name, 700, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(instrumentObj.icon, instrumentObj.icon_state))
	popup.open()

/datum/song/proc/ParseSong(text)
	set waitfor = FALSE
	//split into lines
	lines = splittext(text, "\n")
	if(lines.len)
		if(copytext(lines[1],1,6) == "BPM: ")
			tempo = sanitize_tempo(600 / text2num(copytext(lines[1],6)))
			lines.Cut(1,2)
		else
			tempo = sanitize_tempo(5) // default 120 BPM
		if(lines.len > 50)
			to_chat(usr, "Too many lines!")
			lines.Cut(51)
		var/linenum = 1
		for(var/l in lines)
			if(lentext(l) > 50)
				to_chat(usr, "Line [linenum] too long!")
				lines.Remove(l)
			else
				linenum++
		updateDialog(usr)		// make sure updates when complete

/datum/song/Topic(href, href_list)
	if(!usr.canUseTopic(instrumentObj))
		usr << browse(null, "window=instrument")
		usr.unset_machine()
		return

	instrumentObj.add_fingerprint(usr)

	if(href_list["newsong"])
		lines = new()
		tempo = sanitize_tempo(5) // default 120 BPM
		name = ""

	else if(href_list["import"])
		var/t = ""
		do
			t = rhtml_encode(input(usr, "Please paste the entire song, formatted:", text("[]", name), t)  as message)
			if(!in_range(instrumentObj, usr))
				return

			if(lentext(t) >= 3072)
				var/cont = input(usr, "Your message is too long! Would you like to continue editing it?", "", "yes") in list("yes", "no")
				if(cont == "no")
					break
		while(lentext(t) > 3072)
		ParseSong(t)

	else if(href_list["help"])
		help = text2num(href_list["help"]) - 1

	else if(href_list["edit"])
		edit = text2num(href_list["edit"]) - 1

	if(href_list["repeat"]) //Changing this from a toggle to a number of repeats to avoid infinite loops.
		if(playing)
			return //So that people cant keep adding to repeat. If the do it intentionally, it could result in the server crashing.
		repeat += round(text2num(href_list["repeat"]))
		if(repeat < 0)
			repeat = 0
		if(repeat > max_repeats)
			repeat = max_repeats

	else if(href_list["tempo"])
		tempo = sanitize_tempo(tempo + text2num(href_list["tempo"]))

	else if(href_list["play"])
		playing = 1
		spawn()
			playsong(usr)

	else if(href_list["newline"])
		var/newline = rhtml_encode(input("Enter your line: ", instrumentObj.name) as text|null)
		if(!newline || !in_range(instrumentObj, usr))
			return
		if(lines.len > 50)
			return
		if(lentext(newline) > 50)
			newline = copytext(newline, 1, 50)
		lines.Add(newline)

	else if(href_list["deleteline"])
		var/num = round(text2num(href_list["deleteline"]))
		if(num > lines.len || num < 1)
			return
		lines.Cut(num, num+1)

	else if(href_list["modifyline"])
		var/num = round(text2num(href_list["modifyline"]),1)
		var/content = rhtml_encode(input("Enter your line: ", instrumentObj.name, lines[num]) as text|null)
		if(!content || !in_range(instrumentObj, usr))
			return
		if(lentext(content) > 50)
			content = copytext(content, 1, 50)
		if(num > lines.len || num < 1)
			return
		lines[num] = content

	else if(href_list["stop"])
		playing = 0

	updateDialog(usr)
	return

/datum/song/proc/sanitize_tempo(new_tempo)
	new_tempo = abs(new_tempo)
	return max(round(new_tempo, world.tick_lag), world.tick_lag)

// subclass for handheld instruments, like violin
/datum/song/handheld

/datum/song/handheld/updateDialog(mob/user)
	instrumentObj.interact(user)

/datum/song/handheld/shouldStopPlaying()
	if(instrumentObj)
		return !isliving(instrumentObj.loc)
	else
		return 1


//////////////////////////////////////////////////////////////////////////


/obj/structure/piano
	name = "space minimoog"
	icon = 'icons/obj/musician.dmi'
	icon_state = "minimoog"
	anchored = 1
	density = 1
	var/datum/song/song


/obj/structure/piano/New()
	..()
	song = new("piano", src)

	if(prob(50))
		name = "space minimoog"
		desc = "This is a minimoog, like a space piano, but more spacey!"
		icon_state = "minimoog"
	else
		name = "space piano"
		desc = "This is a space piano, like a regular piano, but always in tune! Even if the musician isn't."
		icon_state = "piano"

/obj/structure/piano/Destroy()
	qdel(song)
	song = null
	return ..()

/obj/structure/piano/Initialize(mapload)
	..()
	if(mapload)
		song.tempo = song.sanitize_tempo(song.tempo) // tick_lag isn't set when the map is loaded

/obj/structure/piano/attack_hand(mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 1
	interact(user)

/obj/structure/piano/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/structure/piano/interact(mob/user)
	if(!user || !anchored)
		return

	user.set_machine(src)
	song.interact(user)

/obj/structure/piano/attackby(obj/item/O, mob/user, params)
	if (istype(O, /obj/item/weapon/wrench))
		if (!anchored && !isinspace())
			playsound(src.loc, O.usesound, 50, 1)
			to_chat(user, "<span class='notice'> You begin to tighten \the [src] to the floor...</span>")
			if (do_after(user, 20*O.toolspeed, target = src))
				user.visible_message( \
					"[user] tightens \the [src]'s casters.", \
					"<span class='notice'>You tighten \the [src]'s casters. Now it can be played again.</span>", \
					"<span class='italics'>You hear ratchet.</span>")
				anchored = 1
		else if(anchored)
			playsound(src.loc, O.usesound, 50, 1)
			to_chat(user, "<span class='notice'> You begin to loosen \the [src]'s casters...</span>")
			if (do_after(user, 40*O.toolspeed, target = src))
				user.visible_message( \
					"[user] loosens \the [src]'s casters.", \
					"<span class='notice'>You loosen \the [src]. Now it can be pulled somewhere else.</span>", \
					"<span class='italics'>You hear ratchet.</span>")
				anchored = 0
	else
		return ..()
