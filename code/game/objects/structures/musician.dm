//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/datum/song
	var/name = "Untitled"
	var/list/lines = new()
	var/tempo = 5

	var/playing = 0			// if we're playing
	var/help = 0			// if help is open
	var/edit = 1			// if we're in editing mode
	var/repeat = 0			// number of times remaining to repeat
	var/max_repeats = 10	// maximum times we can repeat

	var/instrumentDir = "piano"		// the folder with the sounds
	var/instrumentExt = "ogg"		// the file extension
	var/obj/instrumentObj = null	// the associated obj playing the sound

/datum/song/New(dir, obj)
	instrumentDir = dir
	instrumentObj = obj

/datum/song/proc/playnote(var/note as text)
	//world << "Note: [note]"
	var/soundfile
	/*BYOND loads resource files at compile time if they are ''. This means you can't really manipulate them dynamically.
	Tried doing it dynamically at first but its more trouble than its worth. Would have saved many lines tho.*/
	switch(note)
		if("Cn1")	soundfile = "sound/[instrumentDir]/Cn1.[instrumentExt]"
		if("C#1")	soundfile = "sound/[instrumentDir]/C#1.[instrumentExt]"
		if("Db1")	soundfile = "sound/[instrumentDir]/Db1.[instrumentExt]"
		if("Dn1")	soundfile = "sound/[instrumentDir]/Dn1.[instrumentExt]"
		if("D#1")	soundfile = "sound/[instrumentDir]/D#1.[instrumentExt]"
		if("Eb1")	soundfile = "sound/[instrumentDir]/Eb1.[instrumentExt]"
		if("En1")	soundfile = "sound/[instrumentDir]/En1.[instrumentExt]"
		if("E#1")	soundfile = "sound/[instrumentDir]/E#1.[instrumentExt]"
		if("Fb1")	soundfile = "sound/[instrumentDir]/Fb1.[instrumentExt]"
		if("Fn1")	soundfile = "sound/[instrumentDir]/Fn1.[instrumentExt]"
		if("F#1")	soundfile = "sound/[instrumentDir]/F#1.[instrumentExt]"
		if("Gb1")	soundfile = "sound/[instrumentDir]/Gb1.[instrumentExt]"
		if("Gn1")	soundfile = "sound/[instrumentDir]/Gn1.[instrumentExt]"
		if("G#1")	soundfile = "sound/[instrumentDir]/G#1.[instrumentExt]"
		if("Ab1")	soundfile = "sound/[instrumentDir]/Ab1.[instrumentExt]"
		if("An1")	soundfile = "sound/[instrumentDir]/An1.[instrumentExt]"
		if("A#1")	soundfile = "sound/[instrumentDir]/A#1.[instrumentExt]"
		if("Bb1")	soundfile = "sound/[instrumentDir]/Bb1.[instrumentExt]"
		if("Bn1")	soundfile = "sound/[instrumentDir]/Bn1.[instrumentExt]"
		if("B#1")	soundfile = "sound/[instrumentDir]/B#1.[instrumentExt]"
		if("Cb2")	soundfile = "sound/[instrumentDir]/Cb2.[instrumentExt]"
		if("Cn2")	soundfile = "sound/[instrumentDir]/Cn2.[instrumentExt]"
		if("C#2")	soundfile = "sound/[instrumentDir]/C#2.[instrumentExt]"
		if("Db2")	soundfile = "sound/[instrumentDir]/Db2.[instrumentExt]"
		if("Dn2")	soundfile = "sound/[instrumentDir]/Dn2.[instrumentExt]"
		if("D#2")	soundfile = "sound/[instrumentDir]/D#2.[instrumentExt]"
		if("Eb2")	soundfile = "sound/[instrumentDir]/Eb2.[instrumentExt]"
		if("En2")	soundfile = "sound/[instrumentDir]/En2.[instrumentExt]"
		if("E#2")	soundfile = "sound/[instrumentDir]/E#2.[instrumentExt]"
		if("Fb2")	soundfile = "sound/[instrumentDir]/Fb2.[instrumentExt]"
		if("Fn2")	soundfile = "sound/[instrumentDir]/Fn2.[instrumentExt]"
		if("F#2")	soundfile = "sound/[instrumentDir]/F#2.[instrumentExt]"
		if("Gb2")	soundfile = "sound/[instrumentDir]/Gb2.[instrumentExt]"
		if("Gn2")	soundfile = "sound/[instrumentDir]/Gn2.[instrumentExt]"
		if("G#2")	soundfile = "sound/[instrumentDir]/G#2.[instrumentExt]"
		if("Ab2")	soundfile = "sound/[instrumentDir]/Ab2.[instrumentExt]"
		if("An2")	soundfile = "sound/[instrumentDir]/An2.[instrumentExt]"
		if("A#2")	soundfile = "sound/[instrumentDir]/A#2.[instrumentExt]"
		if("Bb2")	soundfile = "sound/[instrumentDir]/Bb2.[instrumentExt]"
		if("Bn2")	soundfile = "sound/[instrumentDir]/Bn2.[instrumentExt]"
		if("B#2")	soundfile = "sound/[instrumentDir]/B#2.[instrumentExt]"
		if("Cb3")	soundfile = "sound/[instrumentDir]/Cb3.[instrumentExt]"
		if("Cn3")	soundfile = "sound/[instrumentDir]/Cn3.[instrumentExt]"
		if("C#3")	soundfile = "sound/[instrumentDir]/C#3.[instrumentExt]"
		if("Db3")	soundfile = "sound/[instrumentDir]/Db3.[instrumentExt]"
		if("Dn3")	soundfile = "sound/[instrumentDir]/Dn3.[instrumentExt]"
		if("D#3")	soundfile = "sound/[instrumentDir]/D#3.[instrumentExt]"
		if("Eb3")	soundfile = "sound/[instrumentDir]/Eb3.[instrumentExt]"
		if("En3")	soundfile = "sound/[instrumentDir]/En3.[instrumentExt]"
		if("E#3")	soundfile = "sound/[instrumentDir]/E#3.[instrumentExt]"
		if("Fb3")	soundfile = "sound/[instrumentDir]/Fb3.[instrumentExt]"
		if("Fn3")	soundfile = "sound/[instrumentDir]/Fn3.[instrumentExt]"
		if("F#3")	soundfile = "sound/[instrumentDir]/F#3.[instrumentExt]"
		if("Gb3")	soundfile = "sound/[instrumentDir]/Gb3.[instrumentExt]"
		if("Gn3")	soundfile = "sound/[instrumentDir]/Gn3.[instrumentExt]"
		if("G#3")	soundfile = "sound/[instrumentDir]/G#3.[instrumentExt]"
		if("Ab3")	soundfile = "sound/[instrumentDir]/Ab3.[instrumentExt]"
		if("An3")	soundfile = "sound/[instrumentDir]/An3.[instrumentExt]"
		if("A#3")	soundfile = "sound/[instrumentDir]/A#3.[instrumentExt]"
		if("Bb3")	soundfile = "sound/[instrumentDir]/Bb3.[instrumentExt]"
		if("Bn3")	soundfile = "sound/[instrumentDir]/Bn3.[instrumentExt]"
		if("B#3")	soundfile = "sound/[instrumentDir]/B#3.[instrumentExt]"
		if("Cb4")	soundfile = "sound/[instrumentDir]/Cb4.[instrumentExt]"
		if("Cn4")	soundfile = "sound/[instrumentDir]/Cn4.[instrumentExt]"
		if("C#4")	soundfile = "sound/[instrumentDir]/C#4.[instrumentExt]"
		if("Db4")	soundfile = "sound/[instrumentDir]/Db4.[instrumentExt]"
		if("Dn4")	soundfile = "sound/[instrumentDir]/Dn4.[instrumentExt]"
		if("D#4")	soundfile = "sound/[instrumentDir]/D#4.[instrumentExt]"
		if("Eb4")	soundfile = "sound/[instrumentDir]/Eb4.[instrumentExt]"
		if("En4")	soundfile = "sound/[instrumentDir]/En4.[instrumentExt]"
		if("E#4")	soundfile = "sound/[instrumentDir]/E#4.[instrumentExt]"
		if("Fb4")	soundfile = "sound/[instrumentDir]/Fb4.[instrumentExt]"
		if("Fn4")	soundfile = "sound/[instrumentDir]/Fn4.[instrumentExt]"
		if("F#4")	soundfile = "sound/[instrumentDir]/F#4.[instrumentExt]"
		if("Gb4")	soundfile = "sound/[instrumentDir]/Gb4.[instrumentExt]"
		if("Gn4")	soundfile = "sound/[instrumentDir]/Gn4.[instrumentExt]"
		if("G#4")	soundfile = "sound/[instrumentDir]/G#4.[instrumentExt]"
		if("Ab4")	soundfile = "sound/[instrumentDir]/Ab4.[instrumentExt]"
		if("An4")	soundfile = "sound/[instrumentDir]/An4.[instrumentExt]"
		if("A#4")	soundfile = "sound/[instrumentDir]/A#4.[instrumentExt]"
		if("Bb4")	soundfile = "sound/[instrumentDir]/Bb4.[instrumentExt]"
		if("Bn4")	soundfile = "sound/[instrumentDir]/Bn4.[instrumentExt]"
		if("B#4")	soundfile = "sound/[instrumentDir]/B#4.[instrumentExt]"
		if("Cb5")	soundfile = "sound/[instrumentDir]/Cb5.[instrumentExt]"
		if("Cn5")	soundfile = "sound/[instrumentDir]/Cn5.[instrumentExt]"
		if("C#5")	soundfile = "sound/[instrumentDir]/C#5.[instrumentExt]"
		if("Db5")	soundfile = "sound/[instrumentDir]/Db5.[instrumentExt]"
		if("Dn5")	soundfile = "sound/[instrumentDir]/Dn5.[instrumentExt]"
		if("D#5")	soundfile = "sound/[instrumentDir]/D#5.[instrumentExt]"
		if("Eb5")	soundfile = "sound/[instrumentDir]/Eb5.[instrumentExt]"
		if("En5")	soundfile = "sound/[instrumentDir]/En5.[instrumentExt]"
		if("E#5")	soundfile = "sound/[instrumentDir]/E#5.[instrumentExt]"
		if("Fb5")	soundfile = "sound/[instrumentDir]/Fb5.[instrumentExt]"
		if("Fn5")	soundfile = "sound/[instrumentDir]/Fn5.[instrumentExt]"
		if("F#5")	soundfile = "sound/[instrumentDir]/F#5.[instrumentExt]"
		if("Gb5")	soundfile = "sound/[instrumentDir]/Gb5.[instrumentExt]"
		if("Gn5")	soundfile = "sound/[instrumentDir]/Gn5.[instrumentExt]"
		if("G#5")	soundfile = "sound/[instrumentDir]/G#5.[instrumentExt]"
		if("Ab5")	soundfile = "sound/[instrumentDir]/Ab5.[instrumentExt]"
		if("An5")	soundfile = "sound/[instrumentDir]/An5.[instrumentExt]"
		if("A#5")	soundfile = "sound/[instrumentDir]/A#5.[instrumentExt]"
		if("Bb5")	soundfile = "sound/[instrumentDir]/Bb5.[instrumentExt]"
		if("Bn5")	soundfile = "sound/[instrumentDir]/Bn5.[instrumentExt]"
		if("B#5")	soundfile = "sound/[instrumentDir]/B#5.[instrumentExt]"
		if("Cb6")	soundfile = "sound/[instrumentDir]/Cb6.[instrumentExt]"
		if("Cn6")	soundfile = "sound/[instrumentDir]/Cn6.[instrumentExt]"
		if("C#6")	soundfile = "sound/[instrumentDir]/C#6.[instrumentExt]"
		if("Db6")	soundfile = "sound/[instrumentDir]/Db6.[instrumentExt]"
		if("Dn6")	soundfile = "sound/[instrumentDir]/Dn6.[instrumentExt]"
		if("D#6")	soundfile = "sound/[instrumentDir]/D#6.[instrumentExt]"
		if("Eb6")	soundfile = "sound/[instrumentDir]/Eb6.[instrumentExt]"
		if("En6")	soundfile = "sound/[instrumentDir]/En6.[instrumentExt]"
		if("E#6")	soundfile = "sound/[instrumentDir]/E#6.[instrumentExt]"
		if("Fb6")	soundfile = "sound/[instrumentDir]/Fb6.[instrumentExt]"
		if("Fn6")	soundfile = "sound/[instrumentDir]/Fn6.[instrumentExt]"
		if("F#6")	soundfile = "sound/[instrumentDir]/F#6.[instrumentExt]"
		if("Gb6")	soundfile = "sound/[instrumentDir]/Gb6.[instrumentExt]"
		if("Gn6")	soundfile = "sound/[instrumentDir]/Gn6.[instrumentExt]"
		if("G#6")	soundfile = "sound/[instrumentDir]/G#6.[instrumentExt]"
		if("Ab6")	soundfile = "sound/[instrumentDir]/Ab6.[instrumentExt]"
		if("An6")	soundfile = "sound/[instrumentDir]/An6.[instrumentExt]"
		if("A#6")	soundfile = "sound/[instrumentDir]/A#6.[instrumentExt]"
		if("Bb6")	soundfile = "sound/[instrumentDir]/Bb6.[instrumentExt]"
		if("Bn6")	soundfile = "sound/[instrumentDir]/Bn6.[instrumentExt]"
		if("B#6")	soundfile = "sound/[instrumentDir]/B#6.[instrumentExt]"
		if("Cb7")	soundfile = "sound/[instrumentDir]/Cb7.[instrumentExt]"
		if("Cn7")	soundfile = "sound/[instrumentDir]/Cn7.[instrumentExt]"
		if("C#7")	soundfile = "sound/[instrumentDir]/C#7.[instrumentExt]"
		if("Db7")	soundfile = "sound/[instrumentDir]/Db7.[instrumentExt]"
		if("Dn7")	soundfile = "sound/[instrumentDir]/Dn7.[instrumentExt]"
		if("D#7")	soundfile = "sound/[instrumentDir]/D#7.[instrumentExt]"
		if("Eb7")	soundfile = "sound/[instrumentDir]/Eb7.[instrumentExt]"
		if("En7")	soundfile = "sound/[instrumentDir]/En7.[instrumentExt]"
		if("E#7")	soundfile = "sound/[instrumentDir]/E#7.[instrumentExt]"
		if("Fb7")	soundfile = "sound/[instrumentDir]/Fb7.[instrumentExt]"
		if("Fn7")	soundfile = "sound/[instrumentDir]/Fn7.[instrumentExt]"
		if("F#7")	soundfile = "sound/[instrumentDir]/F#7.[instrumentExt]"
		if("Gb7")	soundfile = "sound/[instrumentDir]/Gb7.[instrumentExt]"
		if("Gn7")	soundfile = "sound/[instrumentDir]/Gn7.[instrumentExt]"
		if("G#7")	soundfile = "sound/[instrumentDir]/G#7.[instrumentExt]"
		if("Ab7")	soundfile = "sound/[instrumentDir]/Ab7.[instrumentExt]"
		if("An7")	soundfile = "sound/[instrumentDir]/An7.[instrumentExt]"
		if("A#7")	soundfile = "sound/[instrumentDir]/A#7.[instrumentExt]"
		if("Bb7")	soundfile = "sound/[instrumentDir]/Bb7.[instrumentExt]"
		if("Bn7")	soundfile = "sound/[instrumentDir]/Bn7.[instrumentExt]"
		if("B#7")	soundfile = "sound/[instrumentDir]/B#7.[instrumentExt]"
		if("Cb8")	soundfile = "sound/[instrumentDir]/Cb8.[instrumentExt]"
		if("Cn8")	soundfile = "sound/[instrumentDir]/Cn8.[instrumentExt]"
		if("C#8")	soundfile = "sound/[instrumentDir]/C#8.[instrumentExt]"
		if("Db8")	soundfile = "sound/[instrumentDir]/Db8.[instrumentExt]"
		if("Dn8")	soundfile = "sound/[instrumentDir]/Dn8.[instrumentExt]"
		if("D#8")	soundfile = "sound/[instrumentDir]/D#8.[instrumentExt]"
		if("Eb8")	soundfile = "sound/[instrumentDir]/Eb8.[instrumentExt]"
		if("En8")	soundfile = "sound/[instrumentDir]/En8.[instrumentExt]"
		if("E#8")	soundfile = "sound/[instrumentDir]/E#8.[instrumentExt]"
		if("Fb8")	soundfile = "sound/[instrumentDir]/Fb8.[instrumentExt]"
		if("Fn8")	soundfile = "sound/[instrumentDir]/Fn8.[instrumentExt]"
		if("F#8")	soundfile = "sound/[instrumentDir]/F#8.[instrumentExt]"
		if("Gb8")	soundfile = "sound/[instrumentDir]/Gb8.[instrumentExt]"
		if("Gn8")	soundfile = "sound/[instrumentDir]/Gn8.[instrumentExt]"
		if("G#8")	soundfile = "sound/[instrumentDir]/G#8.[instrumentExt]"
		if("Ab8")	soundfile = "sound/[instrumentDir]/Ab8.[instrumentExt]"
		if("An8")	soundfile = "sound/[instrumentDir]/An8.[instrumentExt]"
		if("A#8")	soundfile = "sound/[instrumentDir]/A#8.[instrumentExt]"
		if("Bb8")	soundfile = "sound/[instrumentDir]/Bb8.[instrumentExt]"
		if("Bn8")	soundfile = "sound/[instrumentDir]/Bn8.[instrumentExt]"
		if("B#8")	soundfile = "sound/[instrumentDir]/B#8.[instrumentExt]"
		if("Cb9")	soundfile = "sound/[instrumentDir]/Cb9.[instrumentExt]"
		if("Cn9")	soundfile = "sound/[instrumentDir]/Cn9.[instrumentExt]"
		else		return

	hearers(15, get_turf(instrumentObj)) << sound(soundfile)

/datum/song/proc/updateDialog(mob/user as mob)
	instrumentObj.updateDialog()		// assumes it's an object in world, override if otherwise

/datum/song/proc/shouldStopPlaying()
	return !instrumentObj.anchored		// add special cases to stop in subclasses

/datum/song/proc/playsong(mob/user as mob)
	while(repeat >= 0)
		var/cur_oct[7]
		var/cur_acc[7]
		for(var/i = 1 to 7)
			cur_oct[i] = "3"
			cur_acc[i] = "n"

		for(var/line in lines)
			//world << line
			for(var/beat in text2list(lowertext(line), ","))
				//world << "beat: [beat]"
				var/list/notes = text2list(beat, "/")
				for(var/note in text2list(notes[1], "-"))
					//world << "note: [note]"
					if(!playing || shouldStopPlaying())//If the instrument is playing, or special case
						playing = 0
						return
					if(lentext(note) == 0)
						continue
					//world << "Parse: [copytext(note,1,2)]"
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
							cur_oct[cur_note] = ni
					playnote(uppertext(copytext(note,1,2)) + cur_acc[cur_note] + cur_oct[cur_note])
				if(notes.len >= 2 && text2num(notes[2]))
					sleep(tempo / text2num(notes[2]))
				else
					sleep(tempo)
		repeat--
		if(repeat >= 0) // don't show the last -1 repeat
			updateDialog(user)
	playing = 0
	repeat = 0
	updateDialog(user)

/datum/song/proc/interact(mob/user as mob)
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
		var/calctempo = round(600 / tempo)
		var/calcstep = tempo - 600 / (calctempo+1)
		var/calcstep_b = tempo - 600 / (calctempo+10)
		dat += "Tempo: <A href='?src=\ref[src];tempo=[calcstep_b]'>-</A><A href='?src=\ref[src];tempo=[calcstep]'>-</A> [calctempo] BPM <A href='?src=\ref[src];tempo=-[calcstep]'>+</A><A href='?src=\ref[src];tempo=-[calcstep_b]'>+</A><BR><BR>"
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


/datum/song/Topic(href, href_list)
	if(!in_range(instrumentObj, usr) || issilicon(usr) || !isliving(usr) || !usr.canmove || usr.restrained())
		usr << browse(null, "window=instrument")
		usr.unset_machine()
		return

	instrumentObj.add_fingerprint(usr)

	if(href_list["newsong"])
		lines = new()
		tempo = 5 // default 120 BPM
		name = ""

	else if(href_list["import"])
		var/t = ""
		do
			t = html_encode(input(usr, "Please paste the entire song, formatted:", text("[]", name), t)  as message)
			if(!in_range(instrumentObj, usr))
				return

			if(lentext(t) >= 3072)
				var/cont = input(usr, "Your message is too long! Would you like to continue editing it?", "", "yes") in list("yes", "no")
				if(cont == "no")
					break
		while(lentext(t) > 3072)

		//split into lines
		spawn()
			lines = text2list(t, "\n")
			if(copytext(lines[1],1,6) == "BPM: ")
				tempo = 600 / text2num(copytext(lines[1],6))
				lines.Cut(1,2)
			else
				tempo = 5 // default 120 BPM
			if(lines.len > 50)
				usr << "Too many lines!"
				lines.Cut(51)
			var/linenum = 1
			for(var/l in lines)
				if(lentext(l) > 50)
					usr << "Line [linenum] too long!"
					lines.Remove(l)
				else
					linenum++
			updateDialog(usr)		// make sure updates when complete

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
		tempo += text2num(href_list["tempo"])
		if(tempo < 1)
			tempo = 1
		if(tempo > 600)
			tempo = 600

	else if(href_list["play"])
		playing = 1
		spawn()
			playsong(usr)

	else if(href_list["newline"])
		var/newline = html_encode(input("Enter your line: ", instrumentObj.name) as text|null)
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
		var/content = html_encode(input("Enter your line: ", instrumentObj.name, lines[num]) as text|null)
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


// subclass for handheld instruments, like violin
/datum/song/handheld

	updateDialog(mob/user as mob)
		instrumentObj.interact(user)

	shouldStopPlaying()
		return !isliving(instrumentObj.loc)


//////////////////////////////////////////////////////////////////////////


/obj/structure/device/piano
	name = "space minimoog"
	icon = 'icons/obj/musician.dmi'
	icon_state = "minimoog"
	anchored = 1
	density = 1
	var/datum/song/song


/obj/structure/device/piano/New()
	song = new("piano", src)

	if(prob(50))
		name = "space minimoog"
		desc = "This is a minimoog, like a space piano, but more spacey!"
		icon_state = "minimoog"
	else
		name = "space piano"
		desc = "This is a space piano, like a regular piano, but always in tune! Even if the musician isn't."
		icon_state = "piano"

/obj/structure/device/piano/attack_hand(mob/user as mob)
	interact(user)

/obj/structure/device/piano/interact(mob/user as mob)
	if(!user || !anchored)
		return

	user.set_machine(src)
	song.interact(user)

/obj/structure/device/piano/attackby(obj/item/O as obj, mob/user as mob)
	if (istype(O, /obj/item/weapon/wrench))
		if (anchored)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			user << "\blue You begin to loosen \the [src]'s casters..."
			if (do_after(user, 40))
				user.visible_message( \
					"[user] loosens \the [src]'s casters.", \
					"\blue You have loosened \the [src]. Now it can be pulled somewhere else.", \
					"You hear ratchet.")
				src.anchored = 0
		else
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			user << "\blue You begin to tighten \the [src] to the floor..."
			if (do_after(user, 20))
				user.visible_message( \
					"[user] tightens \the [src]'s casters.", \
					"\blue You have tightened \the [src]'s casters. Now it can be played again.", \
					"You hear ratchet.")
				src.anchored = 1
	else
		..()
