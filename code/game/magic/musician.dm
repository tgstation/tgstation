datum/song
	var
		name = "Untitled"
		var/list/lines = list()


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

	proc/playnote(var/note as text)
		var/soundfile
		switch(note)
			if("A")
				soundfile = 'pianoA.ogg'
			if("B")
				soundfile = 'pianoB.ogg'
			if("C")
				soundfile = 'pianoC.ogg'
			if("D")
				soundfile = 'pianoD.ogg'
			if("E")
				soundfile = 'pianoE.ogg'
			if("F")
				soundfile = 'pianoF.ogg'
			if("G")
				soundfile = 'pianoG.ogg'
			else
				return

		for(var/mob/M in range(15, src))
			M << sound(soundfile)

	proc/playsong()
		for(var/line in song.lines)
			var/i
			for(i = 1; i <= lentext(line); i++)
				var/currentnote = copytext(line, i, i+1)
				if(currentnote == "*")
					sleep(src.tempo)
				else
					playnote(currentnote)
			if(!src.playing)
				return
		src.playing = 0

	attack_hand(var/mob/user as mob)
		usr.machine = src
		//var/dat = "<HEAD><TITLE>Piano</TITLE></HEAD><BODY>\n <META HTTP-EQUIV='Refresh' CONTENT='10'>"
		var/dat
		var/calctempo = (10/tempo)*60
		dat += "Tempo : [calctempo] BPM  (<A href='?src=\ref[src];lowertempo=1'>-</A>/<A href='?src=\ref[src];raisetempo=1'>+</A>)"
		dat += "<A href='?src=\ref[src];newsong=1'>(Start a New Song)</A><BR>"
		if(src.song)
			var/linecount = 0
			for(var/line in song.lines)
				linecount += 1
				dat += "Bar [linecount]: [line]<BR>"//<A href='?src=\ref[src];deletebar=[linecount]'>(Delete bar)</A><BR>" // TODO: Replace delimeters with spaces, clean up display
			dat += "<A href='?src=\ref[src];newbar=1'>(Write a new bar)</A><BR>"
			if(src.song.lines.len > 0 && !(src.playing))
				dat += "<A href='?src=\ref[src];play=1'>(Play song)</A><BR>"
			if(src.playing)
				dat += "<A href='?src=\ref[src];stop=1'>(Stop playing)</A><BR>"
		dat += "<I><BR><BR><BR>Bars are a series of notes separated by asterisks (*)<BR><BR>Example: A*B*C*D*E*F*G will play a scale<BR>Chords can be played simply by listing more than one note before a pause : AB*CD*EF*GA<BR><BR>Bars may be up to 30 characters (including pauses)<BR>A song may only contain up to 10 bars<BR></I>"
		user << browse(dat, "window=piano")
		onclose(user, "piano")

	Topic(href, href_list)
		if(href_list["lowertempo"])
			tempo += 1
			if(tempo < 1)
				tempo = 1
		if(href_list["raisetempo"])
			tempo -= 1
			if(tempo < 1)
				tempo = 1
		if(href_list["play"])
			if(src.song)
				src.playing = 1
				spawn() playsong()
		if(href_list["newsong"])
			src.song = new /datum/song
		if(href_list["newbar"])
			var/newbar = input("Enter your bar: ") as text|null
			if(!newbar)
				return
			if(src.song.lines.len >= 10)
				return
			if(lentext(newbar) > 30)
				newbar = copytext(newbar, 1, 30)
			src.song.lines.Add(newbar)
		if(href_list["deletebar"])
			var/num = href_list["deletebar"]
			num -= 1
			var/line = src.song.lines[num]
			usr << "Line found is [line]"
			src.song.lines.Remove(line)
		if(href_list["stop"])
			src.playing = 0
		src.add_fingerprint(usr)
		src.updateUsrDialog()
		return



/*		src.playing = 1
		var/datum/song/S = new /datum/song
		S.lines.Add("A;B;C;D;E;F;G;A;A;B;B;A;G;A;F;F;A;*;*;*;*;B;C;C;F;G")
		S.lines.Add("A;B;C;D;E;F;G;A;A;B;B;A;G;A;F;F;A;*;*;*;*;B;C;C;F;G")
		src.song = S*/