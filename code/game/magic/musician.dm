/datum/song
	var
		name = "Untitled"
		list/lines = new()
		tempo = 5

/obj/structure/device/piano
	name = "space minimoog"
	icon = 'musician.dmi'
	icon_state = "minimoog"
	anchored = 1
	density = 1
	var
		datum/song/song
		playing = 0
		help = 0
		edit = 1

	proc
		playnote(var/note as text)
			//world << "Note: [note]"
			var/soundfile
			/*BYOND loads resource files at compile time if they are ''. This means you can't really manipulate them dynamically.
			Tried doing it dynamically at first but its more trouble than its worth. Would have saved many lines tho.*/
			switch(note)
				if("Cn1")
					soundfile = 'Cn1.ogg'
				if("C#1")
					soundfile = 'C#1.ogg'
				if("Db1")
					soundfile = 'Db1.ogg'
				if("Dn1")
					soundfile = 'Dn1.ogg'
				if("D#1")
					soundfile = 'D#1.ogg'
				if("Eb1")
					soundfile = 'Eb1.ogg'
				if("En1")
					soundfile = 'En1.ogg'
				if("E#1")
					soundfile = 'E#1.ogg'
				if("Fb1")
					soundfile = 'Fb1.ogg'
				if("Fn1")
					soundfile = 'Fn1.ogg'
				if("F#1")
					soundfile = 'F#1.ogg'
				if("Gb1")
					soundfile = 'Gb1.ogg'
				if("Gn1")
					soundfile = 'Gn1.ogg'
				if("G#1")
					soundfile = 'G#1.ogg'
				if("Ab1")
					soundfile = 'Ab1.ogg'
				if("An1")
					soundfile = 'An1.ogg'
				if("A#1")
					soundfile = 'A#1.ogg'
				if("Bb1")
					soundfile = 'Bb1.ogg'
				if("Bn1")
					soundfile = 'Bn1.ogg'
				if("B#1")
					soundfile = 'B#1.ogg'
				if("Cb2")
					soundfile = 'Cb2.ogg'
				if("Cn2")
					soundfile = 'Cn2.ogg'
				if("C#2")
					soundfile = 'C#2.ogg'
				if("Db2")
					soundfile = 'Db2.ogg'
				if("Dn2")
					soundfile = 'Dn2.ogg'
				if("D#2")
					soundfile = 'D#2.ogg'
				if("Eb2")
					soundfile = 'Eb2.ogg'
				if("En2")
					soundfile = 'En2.ogg'
				if("E#2")
					soundfile = 'E#2.ogg'
				if("Fb2")
					soundfile = 'Fb2.ogg'
				if("Fn2")
					soundfile = 'Fn2.ogg'
				if("F#2")
					soundfile = 'F#2.ogg'
				if("Gb2")
					soundfile = 'Gb2.ogg'
				if("Gn2")
					soundfile = 'Gn2.ogg'
				if("G#2")
					soundfile = 'G#2.ogg'
				if("Ab2")
					soundfile = 'Ab2.ogg'
				if("An2")
					soundfile = 'An2.ogg'
				if("A#2")
					soundfile = 'A#2.ogg'
				if("Bb2")
					soundfile = 'Bb2.ogg'
				if("Bn2")
					soundfile = 'Bn2.ogg'
				if("B#2")
					soundfile = 'B#2.ogg'
				if("Cb3")
					soundfile = 'Cb3.ogg'
				if("Cn3")
					soundfile = 'Cn3.ogg'
				if("C#3")
					soundfile = 'C#3.ogg'
				if("Db3")
					soundfile = 'Db3.ogg'
				if("Dn3")
					soundfile = 'Dn3.ogg'
				if("D#3")
					soundfile = 'D#3.ogg'
				if("Eb3")
					soundfile = 'Eb3.ogg'
				if("En3")
					soundfile = 'En3.ogg'
				if("E#3")
					soundfile = 'E#3.ogg'
				if("Fb3")
					soundfile = 'Fb3.ogg'
				if("Fn3")
					soundfile = 'Fn3.ogg'
				if("F#3")
					soundfile = 'F#3.ogg'
				if("Gb3")
					soundfile = 'Gb3.ogg'
				if("Gn3")
					soundfile = 'Gn3.ogg'
				if("G#3")
					soundfile = 'G#3.ogg'
				if("Ab3")
					soundfile = 'Ab3.ogg'
				if("An3")
					soundfile = 'An3.ogg'
				if("A#3")
					soundfile = 'A#3.ogg'
				if("Bb3")
					soundfile = 'Bb3.ogg'
				if("Bn3")
					soundfile = 'Bn3.ogg'
				if("B#3")
					soundfile = 'B#3.ogg'
				if("Cb4")
					soundfile = 'Cb4.ogg'
				if("Cn4")
					soundfile = 'Cn4.ogg'
				if("C#4")
					soundfile = 'C#4.ogg'
				if("Db4")
					soundfile = 'Db4.ogg'
				if("Dn4")
					soundfile = 'Dn4.ogg'
				if("D#4")
					soundfile = 'D#4.ogg'
				if("Eb4")
					soundfile = 'Eb4.ogg'
				if("En4")
					soundfile = 'En4.ogg'
				if("E#4")
					soundfile = 'E#4.ogg'
				if("Fb4")
					soundfile = 'Fb4.ogg'
				if("Fn4")
					soundfile = 'Fn4.ogg'
				if("F#4")
					soundfile = 'F#4.ogg'
				if("Gb4")
					soundfile = 'Gb4.ogg'
				if("Gn4")
					soundfile = 'Gn4.ogg'
				if("G#4")
					soundfile = 'G#4.ogg'
				if("Ab4")
					soundfile = 'Ab4.ogg'
				if("An4")
					soundfile = 'An4.ogg'
				if("A#4")
					soundfile = 'A#4.ogg'
				if("Bb4")
					soundfile = 'Bb4.ogg'
				if("Bn4")
					soundfile = 'Bn4.ogg'
				if("B#4")
					soundfile = 'B#4.ogg'
				if("Cb5")
					soundfile = 'Cb5.ogg'
				if("Cn5")
					soundfile = 'Cn5.ogg'
				if("C#5")
					soundfile = 'C#5.ogg'
				if("Db5")
					soundfile = 'Db5.ogg'
				if("Dn5")
					soundfile = 'Dn5.ogg'
				if("D#5")
					soundfile = 'D#5.ogg'
				if("Eb5")
					soundfile = 'Eb5.ogg'
				if("En5")
					soundfile = 'En5.ogg'
				if("E#5")
					soundfile = 'E#5.ogg'
				if("Fb5")
					soundfile = 'Fb5.ogg'
				if("Fn5")
					soundfile = 'Fn5.ogg'
				if("F#5")
					soundfile = 'F#5.ogg'
				if("Gb5")
					soundfile = 'Gb5.ogg'
				if("Gn5")
					soundfile = 'Gn5.ogg'
				if("G#5")
					soundfile = 'G#5.ogg'
				if("Ab5")
					soundfile = 'Ab5.ogg'
				if("An5")
					soundfile = 'An5.ogg'
				if("A#5")
					soundfile = 'A#5.ogg'
				if("Bb5")
					soundfile = 'Bb5.ogg'
				if("Bn5")
					soundfile = 'Bn5.ogg'
				if("B#5")
					soundfile = 'B#5.ogg'
				if("Cb6")
					soundfile = 'Cb6.ogg'
				if("Cn6")
					soundfile = 'Cn6.ogg'
				if("C#6")
					soundfile = 'C#6.ogg'
				if("Db6")
					soundfile = 'Db6.ogg'
				if("Dn6")
					soundfile = 'Dn6.ogg'
				if("D#6")
					soundfile = 'D#6.ogg'
				if("Eb6")
					soundfile = 'Eb6.ogg'
				if("En6")
					soundfile = 'En6.ogg'
				if("E#6")
					soundfile = 'E#6.ogg'
				if("Fb6")
					soundfile = 'Fb6.ogg'
				if("Fn6")
					soundfile = 'Fn6.ogg'
				if("F#6")
					soundfile = 'F#6.ogg'
				if("Gb6")
					soundfile = 'Gb6.ogg'
				if("Gn6")
					soundfile = 'Gn6.ogg'
				if("G#6")
					soundfile = 'G#6.ogg'
				if("Ab6")
					soundfile = 'Ab6.ogg'
				if("An6")
					soundfile = 'An6.ogg'
				if("A#6")
					soundfile = 'A#6.ogg'
				if("Bb6")
					soundfile = 'Bb6.ogg'
				if("Bn6")
					soundfile = 'Bn6.ogg'
				if("B#6")
					soundfile = 'B#6.ogg'
				if("Cb7")
					soundfile = 'Cb7.ogg'
				if("Cn7")
					soundfile = 'Cn7.ogg'
				if("C#7")
					soundfile = 'C#7.ogg'
				if("Db7")
					soundfile = 'Db7.ogg'
				if("Dn7")
					soundfile = 'Dn7.ogg'
				if("D#7")
					soundfile = 'D#7.ogg'
				if("Eb7")
					soundfile = 'Eb7.ogg'
				if("En7")
					soundfile = 'En7.ogg'
				if("E#7")
					soundfile = 'E#7.ogg'
				if("Fb7")
					soundfile = 'Fb7.ogg'
				if("Fn7")
					soundfile = 'Fn7.ogg'
				if("F#7")
					soundfile = 'F#7.ogg'
				if("Gb7")
					soundfile = 'Gb7.ogg'
				if("Gn7")
					soundfile = 'Gn7.ogg'
				if("G#7")
					soundfile = 'G#7.ogg'
				if("Ab7")
					soundfile = 'Ab7.ogg'
				if("An7")
					soundfile = 'An7.ogg'
				if("A#7")
					soundfile = 'A#7.ogg'
				if("Bb7")
					soundfile = 'Bb7.ogg'
				if("Bn7")
					soundfile = 'Bn7.ogg'
				if("B#7")
					soundfile = 'B#7.ogg'
				if("Cb8")
					soundfile = 'Cb8.ogg'
				if("Cn8")
					soundfile = 'Cn8.ogg'
				if("C#8")
					soundfile = 'C#8.ogg'
				if("Db8")
					soundfile = 'Db8.ogg'
				if("Dn8")
					soundfile = 'Dn8.ogg'
				if("D#8")
					soundfile = 'D#8.ogg'
				if("Eb8")
					soundfile = 'Eb8.ogg'
				if("En8")
					soundfile = 'En8.ogg'
				if("E#8")
					soundfile = 'E#8.ogg'
				if("Fb8")
					soundfile = 'Fb8.ogg'
				if("Fn8")
					soundfile = 'Fn8.ogg'
				if("F#8")
					soundfile = 'F#8.ogg'
				if("Gb8")
					soundfile = 'Gb8.ogg'
				if("Gn8")
					soundfile = 'Gn8.ogg'
				if("G#8")
					soundfile = 'G#8.ogg'
				if("Ab8")
					soundfile = 'Ab8.ogg'
				if("An8")
					soundfile = 'An8.ogg'
				if("A#8")
					soundfile = 'A#8.ogg'
				if("Bb8")
					soundfile = 'Bb8.ogg'
				if("Bn8")
					soundfile = 'Bn8.ogg'
				if("B#8")
					soundfile = 'B#8.ogg'
				if("Cb9")
					soundfile = 'Cb9.ogg'
				if("Cn9")
					soundfile = 'Cn9.ogg'
				else
					return

			for(var/mob/M in hearers(15, src))
				M << sound(soundfile)

		playsong()
			var/cur_oct[7]
			var/cur_acc[7]
			for(var/i = 1 to 7)
				cur_oct[i] = "3"
				cur_acc[i] = "n"

			for(var/line in song.lines)
				//world << line
				for(var/beat in dd_text2list(lowertext(line), ","))
					//world << "beat: [beat]"
					var/list/notes = dd_text2list(beat, "/")
					for(var/note in dd_text2list(notes[1], "-"))
						//world << "note: [note]"
						if(!playing || !anchored)//If the piano is playing, or is loose
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
						sleep(song.tempo / text2num(notes[2]))
					else
						sleep(song.tempo)
			playing = 0
			updateUsrDialog()

	attack_hand(var/mob/user as mob)
		if(!anchored)
			return

		usr.machine = src
		var/dat = "<HEAD><TITLE>Piano</TITLE></HEAD><BODY>"

		if(song)
			if(song.lines.len > 0 && !(playing))
				dat += "<A href='?src=\ref[src];play=1'>Play Song</A><BR><BR>"
			if(playing)
				dat += "<A href='?src=\ref[src];stop=1'>Stop Playing</A><BR><BR>"

		if(!edit)
			dat += "<A href='?src=\ref[src];edit=2'>Show Editor</A><BR><BR>"
		else
			dat += "<A href='?src=\ref[src];edit=1'>Hide Editor</A><BR>"
			dat += "<A href='?src=\ref[src];newsong=1'>Start a New Song</A><BR>"
			dat += "<A href='?src=\ref[src];import=1'>Import a Song</A><BR><BR>"
			if(song)
				var/calctempo = (10/song.tempo)*60
				dat += "Tempo : <A href='?src=\ref[src];tempo=10'>-</A><A href='?src=\ref[src];tempo=1'>-</A> [calctempo] BPM <A href='?src=\ref[src];tempo=-1'>+</A><A href='?src=\ref[src];tempo=-10'>+</A><BR><BR>"
				var/linecount = 0
				for(var/line in song.lines)
					linecount += 1
					dat += "Line [linecount]: [line] <A href='?src=\ref[src];deleteline=[linecount]'>Delete Line</A> <A href='?src=\ref[src];modifyline=[linecount]'>Modify Line</A><BR>"
				dat += "<A href='?src=\ref[src];newline=1'>Add Line</A><BR><BR>"
			if(help)
				dat += "<A href='?src=\ref[src];help=1'>Hide Help</A><BR>"
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
						Combined, an example is: <i>E-E4/4,/2,G#/8,B/8,E3-E4/4</i>
						<br>
						Lines may be up to 50 characters.<br>
						A song may only contain up to 50 lines.<br>
						"}
			else
				dat += "<A href='?src=\ref[src];help=2'>Show Help</A><BR>"
		dat += "</BODY></HTML>"
		user << browse(dat, "window=piano;size=700x300")
		onclose(user, "piano")

	Topic(href, href_list)
		if(in_range(src, usr) && !issilicon(usr) && anchored)
			if(href_list["tempo"])
				song.tempo += text2num(href_list["tempo"])
				if(song.tempo < 1)
					song.tempo = 1
			if(href_list["play"])
				if(song)
					playing = 1
					spawn() playsong()
			if(href_list["newsong"])
				song = new()
			if(href_list["newline"])
				var/newline = input("Enter your line: ", "Piano") as text|null
				if(!newline)
					return
				if(song.lines.len > 50)
					return
				if(lentext(newline) > 50)
					newline = copytext(newline, 1, 50)
				song.lines.Add(newline)
			if(href_list["deleteline"])
				var/num = text2num(href_list["deleteline"])
				song.lines.Cut(num, num+1)
			if(href_list["modifyline"])
				var/num = text2num(href_list["modifyline"])
				var/content = input("Enter your line: ", "Piano", song.lines[num]) as text|null
				if(!content)
					return
				if(lentext(content) > 50)
					content = copytext(content, 1, 50)
				song.lines[num] = content
			if(href_list["stop"])
				playing = 0
			if(href_list["help"])
				help = text2num(href_list["help"]) - 1
			if(href_list["edit"])
				edit = text2num(href_list["edit"]) - 1
			if(href_list["import"])
				var/t = ""
				do
					t = input(usr, "Please paste the entire song, formatted:", text("[]", src.name), t)  as message
					if (!in_range(src, usr))
						return

					if(lentext(t) >= 3072)
						var/cont = input(usr, "Your message is too long! Would you like to continue editing it?", "", "yes") in list("yes", "no")
						if(cont == "no")
							break
				while(lentext(t) > 3072)

				//split into lines
				spawn()
					var/list/lines = dd_text2list(t, "\n")
					var/tempo = 5
					if(copytext(lines[1],1,6) == "BPM: ")
						tempo = 600 / text2num(copytext(lines[1],6))
						lines.Cut(1,2)
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
					song = new()
					song.lines = lines
					song.tempo = tempo
					updateUsrDialog()
		add_fingerprint(usr)
		updateUsrDialog()
		return

	attackby(obj/item/O as obj, mob/user as mob)
		if (istype(O, /obj/item/weapon/wrench))
			if (anchored)
				playsound(src.loc, 'Ratchet.ogg', 50, 1)
				user << "\blue You begin to loosen \the [src]'s casters..."
				if (do_after(user, 40))
					user.visible_message( \
						"[user] loosens \the [src]'s casters.", \
						"\blue You have loosened \the [src]. Now it can be pulled somewhere else.", \
						"You hear ratchet.")
					src.anchored = 0
			else
				playsound(src.loc, 'Ratchet.ogg', 50, 1)
				user << "\blue You begin to tighten \the [src] to the floor..."
				if (do_after(user, 20))
					user.visible_message( \
						"[user] tightens \the [src]'s casters.", \
						"\blue You have tightened \the [src]'s casters. Now it can be played again.", \
						"You hear ratchet.")
					src.anchored = 1
		else
			..()
