/datum/song
	var
		name = "Untitled"
		lines[] = list()

/obj/device/piano
	name = "space piano"
	icon = 'musician.dmi'
	icon_state = "piano"
	anchored = 1
	density = 1
	var
		datum/song/song
		playing = 0
		tempo = 5

	proc
		playnote(var/note as text)
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

			for(var/mob/M in range(15, src))
				M << sound(soundfile)

		playsong()
			for(var/line in song.lines)
				for(var/i = 1, i <= length(line), i+=4)//i starts as 1, or beggining of list. Goes up by 4, skipping every fourth character.
					if(!playing)//If the piano is playing and you don't want it playing, this will stop the proc.
						return
					var/currentnote = copytext(line, i, i+3)
					playnote(currentnote)
					sleep(tempo)
			playing = 0

	attack_hand(var/mob/user as mob)
		usr.machine = src
		var/dat = "<HEAD><TITLE>Piano</TITLE></HEAD><BODY>\n <META HTTP-EQUIV='Refresh' CONTENT='10'>"
		var/calctempo = (10/tempo)*60
		dat += "Tempo : [calctempo] BPM  (<A href='?src=\ref[src];choice=lowertempo'>-</A>/<A href='?src=\ref[src];choice=raisetempo'>+</A>)"
		dat += "<A href='?src=\ref[src];choice=newsong'>(Start a New Song)</A><br>"
		if(song)
			var/linecount = 0
			for(var/line in song.lines)
				linecount += 1
				dat += "Bar [linecount]: [line]<br>"//<A href='?src=\ref[src];deletebar=[linecount]'>(Delete bar)</A><br>" // TODO: Replace delimeters with spaces, clean up display
			dat += "<A href='?src=\ref[src];choice=newbar'>(Write a new bar)</A><br>"
			if(song.lines.len > 0 && !(playing))
				dat += "<A href='?src=\ref[src];choice=play'>(Play song)</A><br>"
			if(playing)
				dat += "<A href='?src=\ref[src];choice=stop'>(Stop playing)</A><br>"
		dat += {"
				<br><br>
				Bars are a series of notes separated by asterisks (*) or anything else you want to put there.<br>
				Just know that every fourth character will act as a stop, delaying the next note by tempo.<br>
				<br>
				Notes are played by the names of the note, the accidental, then the octave number.<br>
				Example: <i>An3*Bn3*Cn3*Dn3*En3*Fn3*Gn3</i> will play a scale.<br>
				Chords can be played simply by listing more than one note before a pause: <i>AB*CD*EF*GA</i><br>
				<br>
				Bars may be up to 30 characters (including pauses).<br>
				A song may only contain up to 10 bars.<br>
				"}
		user << browse(dat, "window=piano")
		onclose(user, "piano")

	Topic(href, href_list)
		//You need some safety checks here. Where is the person located, etc.
		switch(href_list["choice"])
			if("lowertempo")
				tempo += 1
				if(tempo < 1)
					tempo = 1
			if("raisetempo")
				tempo -= 1
				if(tempo < 1)
					tempo = 1
			if("play")
				if(song)
					playing = 1
					spawn() playsong()
			if("newsong")
				song = new /datum/song
			if("newbar")
				var/newbar = input("Enter your bar: ") as text|null
				if(!newbar)
					return
				if(song.lines.len >= 10)
					return
				if(lentext(newbar) > 30)
					newbar = copytext(newbar, 1, 30)
				song.lines.Add(newbar)
			if("deletebar")
				var/num = href_list["deletebar"]
				num -= 1
				var/line = song.lines[num]
				usr << "Line found is [line]"
				song.lines.Remove(line)
			if("stop")
				playing = 0
		add_fingerprint(usr)
		updateUsrDialog()
		return

/*        playing = 1
        var/datum/song/S = new /datum/song
        S.lines.Add("A;B;C;D;E;F;G;A;A;B;B;A;G;A;F;F;A;*;*;*;*;B;C;C;F;G")
        S.lines.Add("A;B;C;D;E;F;G;A;A;B;B;A;G;A;F;F;A;*;*;*;*;B;C;C;F;G")
        song = S*/