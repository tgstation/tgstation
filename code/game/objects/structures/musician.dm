//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/datum/song
	var/name = "Untitled"

	var/sourcestring = ""
	var/compiledstring = ""
	var/compilesuccess = 0

	//For those other infidels who uses this datum
	//VIOLINSSS
	var/list/lines

	var/tempo = 5

	var/global/gid = 1
	var/id = 0
	New()
		id = gid
		gid++;

//Same text2list, but 20000 cap instead of 1000
/proc/dd_text2list_highcap(text, separator, var/list/withinList)
	var/textlength = length(text)
	var/separatorlength = length(separator)
	if(withinList && !withinList.len) withinList = null
	var/list/textList = new()
	var/searchPosition = 1
	var/findPosition = 1
	var/loops = 0
	while(1)
		if(loops >= 20000)
			break
		loops++

		findPosition = findtext(text, separator, searchPosition, 0)
		var/buggyText = copytext(text, searchPosition, findPosition)
		if(!withinList || (buggyText in withinList)) textList += "[buggyText]"
		if(!findPosition) return textList
		searchPosition = findPosition + separatorlength
		if(searchPosition > textlength)
			textList += ""
			return textList
	return

/obj/structure/device/piano
	name = "space minimoog"
	icon = 'icons/obj/musician.dmi'
	icon_state = "minimoog"
	anchored = 1
	density = 1

	var/datum/song/currentsong = new()
	var/list/internalsongs = new()

	var/playing = 0
	var/repeat = 1

	var/showcontrol = 1
	var/showeditor = 0
	var/showhelp = 0

	var/status = "Ok"

	var/global/list/soundlist = new()

	New()
		if(prob(50))
			name = "space minimoog"
			desc = "This is a minimoog, like a space piano, but more spacey!"
			icon_state = "minimoog"
		else
			name = "space piano"
			desc = "This is a space piano, like a regular piano, but always in tune! Even if the musician isn't."
			icon_state = "piano"

		//This shit is not used anywhere, but is needed to cache the sounds
		soundlist["Cn1"] = 'sound/piano/Cn1.ogg'
		soundlist["C#1"] = 'sound/piano/C#1.ogg'
		//soundlist["Db1"] = 'sound/piano/Db1.ogg'
		soundlist["Dn1"] = 'sound/piano/Dn1.ogg'
		soundlist["D#1"] = 'sound/piano/D#1.ogg'
		//soundlist["Eb1"] = 'sound/piano/Eb1.ogg'
		soundlist["En1"] = 'sound/piano/En1.ogg'
		soundlist["E#1"] = 'sound/piano/E#1.ogg'
		//soundlist["Fb1"] = 'sound/piano/Fb1.ogg'
		soundlist["Fn1"] = 'sound/piano/Fn1.ogg'
		soundlist["F#1"] = 'sound/piano/F#1.ogg'
		//soundlist["Gb1"] = 'sound/piano/Gb1.ogg'
		soundlist["Gn1"] = 'sound/piano/Gn1.ogg'
		soundlist["G#1"] = 'sound/piano/G#1.ogg'
		//soundlist["Ab1"] = 'sound/piano/Ab1.ogg'
		soundlist["An1"] = 'sound/piano/An1.ogg'
		soundlist["A#1"] = 'sound/piano/A#1.ogg'
		//soundlist["Bb1"] = 'sound/piano/Bb1.ogg'
		soundlist["Bn1"] = 'sound/piano/Bn1.ogg'
		soundlist["B#1"] = 'sound/piano/B#1.ogg'
		soundlist["Cb2"] = 'sound/piano/Cb2.ogg'
		soundlist["Cn2"] = 'sound/piano/Cn2.ogg'
		soundlist["C#2"] = 'sound/piano/C#2.ogg'
		//soundlist["Db2"] = 'sound/piano/Db2.ogg'
		soundlist["Dn2"] = 'sound/piano/Dn2.ogg'
		soundlist["D#2"] = 'sound/piano/D#2.ogg'
		//soundlist["Eb2"] = 'sound/piano/Eb2.ogg'
		soundlist["En2"] = 'sound/piano/En2.ogg'
		soundlist["E#2"] = 'sound/piano/E#2.ogg'
		//soundlist["Fb2"] = 'sound/piano/Fb2.ogg'
		soundlist["Fn2"] = 'sound/piano/Fn2.ogg'
		soundlist["F#2"] = 'sound/piano/F#2.ogg'
		//soundlist["Gb2"] = 'sound/piano/Gb2.ogg'
		soundlist["Gn2"] = 'sound/piano/Gn2.ogg'
		soundlist["G#2"] = 'sound/piano/G#2.ogg'
		//soundlist["Ab2"] = 'sound/piano/Ab2.ogg'
		soundlist["An2"] = 'sound/piano/An2.ogg'
		soundlist["A#2"] = 'sound/piano/A#2.ogg'
		//soundlist["Bb2"] = 'sound/piano/Bb2.ogg'
		soundlist["Bn2"] = 'sound/piano/Bn2.ogg'
		soundlist["B#2"] = 'sound/piano/B#2.ogg'
		soundlist["Cb3"] = 'sound/piano/Cb3.ogg'
		soundlist["Cn3"] = 'sound/piano/Cn3.ogg'
		soundlist["C#3"] = 'sound/piano/C#3.ogg'
		//soundlist["Db3"] = 'sound/piano/Db3.ogg'
		soundlist["Dn3"] = 'sound/piano/Dn3.ogg'
		soundlist["D#3"] = 'sound/piano/D#3.ogg'
		//soundlist["Eb3"] = 'sound/piano/Eb3.ogg'
		soundlist["En3"] = 'sound/piano/En3.ogg'
		soundlist["E#3"] = 'sound/piano/E#3.ogg'
		//soundlist["Fb3"] = 'sound/piano/Fb3.ogg'
		soundlist["Fn3"] = 'sound/piano/Fn3.ogg'
		soundlist["F#3"] = 'sound/piano/F#3.ogg'
		//soundlist["Gb3"] = 'sound/piano/Gb3.ogg'
		soundlist["Gn3"] = 'sound/piano/Gn3.ogg'
		soundlist["G#3"] = 'sound/piano/G#3.ogg'
		//soundlist["Ab3"] = 'sound/piano/Ab3.ogg'
		soundlist["An3"] = 'sound/piano/An3.ogg'
		soundlist["A#3"] = 'sound/piano/A#3.ogg'
		//soundlist["Bb3"] = 'sound/piano/Bb3.ogg'
		soundlist["Bn3"] = 'sound/piano/Bn3.ogg'
		soundlist["B#3"] = 'sound/piano/B#3.ogg'
		soundlist["Cb4"] = 'sound/piano/Cb4.ogg'
		soundlist["Cn4"] = 'sound/piano/Cn4.ogg'
		soundlist["C#4"] = 'sound/piano/C#4.ogg'
		//soundlist["Db4"] = 'sound/piano/Db4.ogg'
		soundlist["Dn4"] = 'sound/piano/Dn4.ogg'
		soundlist["D#4"] = 'sound/piano/D#4.ogg'
		//soundlist["Eb4"] = 'sound/piano/Eb4.ogg'
		soundlist["En4"] = 'sound/piano/En4.ogg'
		soundlist["E#4"] = 'sound/piano/E#4.ogg'
		//soundlist["Fb4"] = 'sound/piano/Fb4.ogg'
		soundlist["Fn4"] = 'sound/piano/Fn4.ogg'
		soundlist["F#4"] = 'sound/piano/F#4.ogg'
		//soundlist["Gb4"] = 'sound/piano/Gb4.ogg'
		soundlist["Gn4"] = 'sound/piano/Gn4.ogg'
		soundlist["G#4"] = 'sound/piano/G#4.ogg'
		//soundlist["Ab4"] = 'sound/piano/Ab4.ogg'
		soundlist["An4"] = 'sound/piano/An4.ogg'
		soundlist["A#4"] = 'sound/piano/A#4.ogg'
		//soundlist["Bb4"] = 'sound/piano/Bb4.ogg'
		soundlist["Bn4"] = 'sound/piano/Bn4.ogg'
		soundlist["B#4"] = 'sound/piano/B#4.ogg'
		soundlist["Cb5"] = 'sound/piano/Cb5.ogg'
		soundlist["Cn5"] = 'sound/piano/Cn5.ogg'
		soundlist["C#5"] = 'sound/piano/C#5.ogg'
		//soundlist["Db5"] = 'sound/piano/Db5.ogg'
		soundlist["Dn5"] = 'sound/piano/Dn5.ogg'
		soundlist["D#5"] = 'sound/piano/D#5.ogg'
		//soundlist["Eb5"] = 'sound/piano/Eb5.ogg'
		soundlist["En5"] = 'sound/piano/En5.ogg'
		soundlist["E#5"] = 'sound/piano/E#5.ogg'
		//soundlist["Fb5"] = 'sound/piano/Fb5.ogg'
		soundlist["Fn5"] = 'sound/piano/Fn5.ogg'
		soundlist["F#5"] = 'sound/piano/F#5.ogg'
		//soundlist["Gb5"] = 'sound/piano/Gb5.ogg'
		soundlist["Gn5"] = 'sound/piano/Gn5.ogg'
		soundlist["G#5"] = 'sound/piano/G#5.ogg'
		//soundlist["Ab5"] = 'sound/piano/Ab5.ogg'
		soundlist["An5"] = 'sound/piano/An5.ogg'
		soundlist["A#5"] = 'sound/piano/A#5.ogg'
		//soundlist["Bb5"] = 'sound/piano/Bb5.ogg'
		soundlist["Bn5"] = 'sound/piano/Bn5.ogg'
		soundlist["B#5"] = 'sound/piano/B#5.ogg'
		soundlist["Cb6"] = 'sound/piano/Cb6.ogg'
		soundlist["Cn6"] = 'sound/piano/Cn6.ogg'
		soundlist["C#6"] = 'sound/piano/C#6.ogg'
		//soundlist["Db6"] = 'sound/piano/Db6.ogg'
		soundlist["Dn6"] = 'sound/piano/Dn6.ogg'
		soundlist["D#6"] = 'sound/piano/D#6.ogg'
		//soundlist["Eb6"] = 'sound/piano/Eb6.ogg'
		soundlist["En6"] = 'sound/piano/En6.ogg'
		soundlist["E#6"] = 'sound/piano/E#6.ogg'
		//soundlist["Fb6"] = 'sound/piano/Fb6.ogg'
		soundlist["Fn6"] = 'sound/piano/Fn6.ogg'
		soundlist["F#6"] = 'sound/piano/F#6.ogg'
		//soundlist["Gb6"] = 'sound/piano/Gb6.ogg'
		soundlist["Gn6"] = 'sound/piano/Gn6.ogg'
		soundlist["G#6"] = 'sound/piano/G#6.ogg'
		//soundlist["Ab6"] = 'sound/piano/Ab6.ogg'
		soundlist["An6"] = 'sound/piano/An6.ogg'
		soundlist["A#6"] = 'sound/piano/A#6.ogg'
		//soundlist["Bb6"] = 'sound/piano/Bb6.ogg'
		soundlist["Bn6"] = 'sound/piano/Bn6.ogg'
		soundlist["B#6"] = 'sound/piano/B#6.ogg'
		soundlist["Cb7"] = 'sound/piano/Cb7.ogg'
		soundlist["Cn7"] = 'sound/piano/Cn7.ogg'
		soundlist["C#7"] = 'sound/piano/C#7.ogg'
		//soundlist["Db7"] = 'sound/piano/Db7.ogg'
		soundlist["Dn7"] = 'sound/piano/Dn7.ogg'
		soundlist["D#7"] = 'sound/piano/D#7.ogg'
		//soundlist["Eb7"] = 'sound/piano/Eb7.ogg'
		soundlist["En7"] = 'sound/piano/En7.ogg'
		soundlist["E#7"] = 'sound/piano/E#7.ogg'
		//soundlist["Fb7"] = 'sound/piano/Fb7.ogg'
		soundlist["Fn7"] = 'sound/piano/Fn7.ogg'
		soundlist["F#7"] = 'sound/piano/F#7.ogg'
		//soundlist["Gb7"] = 'sound/piano/Gb7.ogg'
		soundlist["Gn7"] = 'sound/piano/Gn7.ogg'
		soundlist["G#7"] = 'sound/piano/G#7.ogg'
		//soundlist["Ab7"] = 'sound/piano/Ab7.ogg'
		soundlist["An7"] = 'sound/piano/An7.ogg'
		soundlist["A#7"] = 'sound/piano/A#7.ogg'
		//soundlist["Bb7"] = 'sound/piano/Bb7.ogg'
		soundlist["Bn7"] = 'sound/piano/Bn7.ogg'
		soundlist["B#7"] = 'sound/piano/B#7.ogg'
		soundlist["Cb8"] = 'sound/piano/Cb8.ogg'
		soundlist["Cn8"] = 'sound/piano/Cn8.ogg'
		soundlist["C#8"] = 'sound/piano/C#8.ogg'
		//soundlist["Db8"] = 'sound/piano/Db8.ogg'
		soundlist["Dn8"] = 'sound/piano/Dn8.ogg'
		soundlist["D#8"] = 'sound/piano/D#8.ogg'
		//soundlist["Eb8"] = 'sound/piano/Eb8.ogg'
		soundlist["En8"] = 'sound/piano/En8.ogg'
		soundlist["E#8"] = 'sound/piano/E#8.ogg'
		//soundlist["Fb8"] = 'sound/piano/Fb8.ogg'
		soundlist["Fn8"] = 'sound/piano/Fn8.ogg'
		soundlist["F#8"] = 'sound/piano/F#8.ogg'
		//soundlist["Gb8"] = 'sound/piano/Gb8.ogg'
		soundlist["Gn8"] = 'sound/piano/Gn8.ogg'
		soundlist["G#8"] = 'sound/piano/G#8.ogg'
		//soundlist["Ab8"] = 'sound/piano/Ab8.ogg'
		soundlist["An8"] = 'sound/piano/An8.ogg'
		soundlist["A#8"] = 'sound/piano/A#8.ogg'
		//soundlist["Bb8"] = 'sound/piano/Bb8.ogg'
		soundlist["Bn8"] = 'sound/piano/Bn8.ogg'
		soundlist["B#8"] = 'sound/piano/B#8.ogg'
		soundlist["Cb9"] = 'sound/piano/Cb9.ogg'
		soundlist["Cn9"] = 'sound/piano/Cn9.ogg'

	proc/statusmsg( var/txt as text )
		status = txt
		updateUsrDialog()

	proc/playsong()
		if(currentsong.compilesuccess == 0)
			playing = 0
			statusmsg("Playback Error: Compile it first!")
			return

		var/list/tokens = dd_text2list_highcap(currentsong.compiledstring, "¤")

		//Remove last token
		tokens.Cut(tokens.len-1)

		var/repetitions = 0
		while(repetitions < repeat)
			repetitions++

			for(var/token in tokens)
				if(playing == 0)
					updateUsrDialog()
					return

				var/type = copytext(token, 1, 2)
				switch(type)
					if("x")
						var/soundfile = copytext(token, 2)
						soundfile = "sound/piano/[soundfile].ogg"

						hearers(15, src) << sound(soundfile)
					if("y")
						sleep(text2num(copytext(token, 2)))

		playing = 0
		updateUsrDialog()


	proc/compilesong()
		var/compilestring = ""

		var/strippedsourcestring = dd_replacetext(currentsong.sourcestring, "\n", "")


		for(var/part in dd_text2list(strippedsourcestring, ","))
			var/list/x = dd_text2list(part, "/")
			var/xlen = x.len
			var/list/tones = dd_text2list(x[1], "-")

			var/tempodiv = 1
			if(xlen==2)
				tempodiv = text2num(x[2])
				if(tempodiv == 0)
					statusmsg( "Compile Error: Can't divide by 0!\nAt Part:'[part]' Tone:" )
					return
			else if(xlen>2)
				statusmsg( "Compile Error: Tempo Syntax Error!\nAt Part:'[part]' Tone:" )
				return

			for(var/tone in tones)
				var/len = lentext(tone)

				if(len==0)
					break
				else if(len>3)
					statusmsg( "Compile Error: Tone Syntax Error!\nAt Part:'[part]' Tone:'[tone]'" )
					return

				var/note = copytext(tone, 1, 2)
				var/accidental = "n"
				var/octave = "3"

				var/notenum = text2ascii(note)
				if(notenum < 65 || notenum > 71)
					statusmsg( "Compile Error: Invalid Note Letter (A-G)\nAt Part:'[part]' Tone:'[tone]'" )
					return

				if(len>=2)
					var/x2 = copytext(tone, 2, 3)
					var/x2num = text2num(x2)
					if(x2 == "b" || x2 == "n" || x2 == "#")
						accidental = x2
					else if(x2num >= 1 && x2num <= 9)
						octave = x2
						if(len==3)
							statusmsg( "Compile Error: Tone Syntax Error! (incorrect order)\nAt Part:'[part]' Tone:'[tone]'" )
							return
					else
						statusmsg( "Compile Error: Invalid Letter At Char (2)\nAt Part:'[part]' Tone:'[tone]'" )
						return

					if(len==3)
						var/x3 = copytext(tone, 3, 4)
						var/x3num = text2num(x3)
						if(x3num >= 1 && x3num <= 9)
							octave = x3
						else
							statusmsg( "Compile Error: Invalid Octave! (1-9)\nAt Part:'[part]' Tone:'[tone]'" )
							return

				//Optimize part

				// Replace a flat with a sharp from the note one step darker
				// If we're on the darkest note, we can't replace it by some darker (note != "C")
				// C D E F G A B
				if(accidental == "b" && note != "C")
					accidental = "#"
					if(note == "A")
						note = "G"
					else
						note = ascii2text(text2ascii(note)-1) // Decrement by one

				var/finaltone = note + accidental + octave
				//Check if invalid note
				if((octave == "9" && (finaltone != "Cb9" && finaltone != "Cn9")) || finaltone == "Cb1")
					statusmsg( "Compile Error: Invalid Tone! (Check bottom of help for more info)\nAt Part:'[part]' Tone:'[tone]'" )
					return

				// TODO: OPTIMIZE SHARPS AND FLATS
				//x indicates its a tone to be played
				compilestring += "x" + finaltone + "¤"

			//y indicates its a sleep
			compilestring += "y[round((currentsong.tempo / tempodiv)*100)/100]¤"

		currentsong.compiledstring = compilestring
		currentsong.compilesuccess = 1

		statusmsg("Compiled successfully!")

/obj/structure/device/piano/attack_hand(var/mob/user as mob)
	if(!anchored)
		return

	usr.machine = src

	/*
	BPM TO TEMPO
	ds = 10/(BPM/60)

	TEMPO TO BPM
	BPM = (10/ds)*60
	*/

	var/calctempo = round((10/currentsong.tempo)*60)
	var/dat = {"
	<html>
		<head>
			<title>Piano</title>
			<style type="text/css">
				div.content
				{
					background-color:#AAAAAA;
					width:100%;
					padding:10;
					margin:5;
				}
				table.noborders {
					border-width: 0px;
					border-spacing: 0px;
					border-style: none;
					border-collapse: collapse;
				}
				table.noborders th {
					border-width: 0px;
					padding: 0px;
					border-style: inset;
				}
				table.noborders td {
					border-width: 0px;
					padding: 0px;
					border-style: inset;
				}
			</style>
		</head>
		<body>
			<center><h1>[src.name == "space piano" ? "Space Piano" : "Space Minimoog"]</h1></center>
			<table class="noborders" width="100%"><tr>
				<td>
					<div bgcolor="#AAAAAA" class="content" style="height:100%;">"}
	if(showcontrol)
		dat += {"		<a href='?src=\ref[src];controltoggle=1'>Hide Controlpanel</a><br>"}
	else
		dat += {"		<a href='?src=\ref[src];controltoggle=1'>Show Controlpanel</a><br>"}

	if(showcontrol)
		dat += {"

						<a href='?src=\ref[src];toggleplay=1'>[playing ? "Stop Playing" : "Play [currentsong.name]"]</a><br>
						<br>
						<a href='?src=\ref[src];newsong=1'>New Song</a><br>
						<a href='?src=\ref[src];name=1'>Rename Song</a><br>
						<a href='?src=\ref[src];savesong=1'>Save [currentsong.name]</a><br>
						<br>
						<a href='?src=\ref[src];repeat=1'>Repeat: [repeat]</a><br>
						<div style="width:auto; height:auto; background-color:#888888;" bgcolor="#888888">
							<pre>Status:<br>[status]</pre>
						</div>"}

	dat+={"
					</div>
				</td>
				<td width="150px">
					<div bgcolor="#AAAAAA" class="content" style="width:150px; height:100%; margin-left:0;">
						"}
	if(showcontrol)
		for(var/datum/song/isong in internalsongs)
			dat += "<a href='?src=\ref[src];setsong=[isong.id]'>[isong.name]</a><br>"
	dat += {"
					</div>
				</td>
			</tr></table>
			<div bgcolor="#AAAAAA" class="content" style="margin-top:0;">"}

	if(showeditor)
		dat += {"<a href='?src=\ref[src];editortoggle=1'>Hide Editor</a><br>"}
	else
		dat += {"<a href='?src=\ref[src];editortoggle=1'>Show Editor</a><br>"}

	if(showeditor)
		dat += {"
				Tempo:
				<a href='?src=\ref[src];tempo=-3'>-</a><a href='?src=\ref[src];tempo=-2'>-</a><a href='?src=\ref[src];tempo=-1'>-</a>
				[calctempo] BPM
				<a href='?src=\ref[src];tempo=1'>+</a><a href='?src=\ref[src];tempo=2'>+</a><a href='?src=\ref[src];tempo=3'>+</a><br>
				<a href='?src=\ref[src];compile=1'>Compile</a>
				<a href='?src=\ref[src];edit=1'>Edit</a>
				<div bgcolor="#888888" style="padding-left:5px; margin-top:5px; background-color:#888888"><pre>[currentsong.sourcestring]</pre></div>"}
	dat+={"
			</div>
			<div bgcolor="#AAAAAA" class="content">"}

	if(showhelp)
		dat += {"<a href='?src=\ref[src];helptoggle=1'>Hide Help</a><br>"}
	else
		dat += {"<a href='?src=\ref[src];helptoggle=1'>Show Help</a><br>"}

	if(showhelp)
		dat += {"
				Songs are a series of chords, separated by commas (,), each with notes seperated by hyphens (-).<br>
				Every note in a chord will play together, with chord timed by the tempo.<br>
				<br>
				Notes are played by the names of the note, and optionally, the accidental, and/or the octave number.<br>
				By default, every note is natural and in octave 3. Defining otherwise is remembered for each note.<br>
				Octave can be a number between 1 and 9<br>
				Example: <i>C,D,E,F,G,A,B</i> will play a C major scale.<br>
				After a note has an accidental placed, it will be remembered: <i>C#,C4,Cb,C3</i> is <i>C#3,Cn4,Cb3,Cn3</i><br>
				Chords can be played simply by seperating each note with a hyphon: <i>A-C#,Cn-E,E-G#-Gn-B</i><br>
				A pause may be denoted by an empty chord: <i>C,E,,C,G</i><br>
				To make a chord be a different time, end it with /x, where the chord length will be length<br>
				defined by 'tempo / x': <i>C,G/2,E/4</i><br>
				Combined, an example is: <i>E-Eb4/4,/2,G#/8,B/8,E3-E4/4</i><br>
				<br>
				A song may only contain up to 4000 letters.<br>
				If you're playing a small piece over and over, remember to put a pause at the end for it to sound properly.<br<
				<br>
				Note: Due to limitations in the engine, some tones doesn't exist. These are:<br>
				Cb1<br>
				All tones in the ninth octave <b>except Cb9 and Cn9</b>
				"}
	dat+={"
			</div>
		</body>
	</html>"}
	user << browse(dat, "window=piano;size=700x500")
	onclose(user, "piano")

/obj/structure/device/piano/Topic(href, href_list)

	if(!in_range(src, usr) || issilicon(usr) || !anchored || !usr.canmove || usr.restrained())
		usr << browse(null, "window=piano;size=700x300")
		onclose(usr, "piano")
		return

	if(href_list["toggleplay"])
		if(playing)
			playing = 0
		else
			playing = 1
			spawn() playsong()

		updateUsrDialog()

	else if(href_list["controltoggle"])
		showcontrol = 1-showcontrol
		updateUsrDialog()

	else if(href_list["editortoggle"])
		showeditor = 1-showeditor
		updateUsrDialog()

	else if(href_list["helptoggle"])
		showhelp = 1-showhelp
		updateUsrDialog()

	else if(href_list["name"])
		var/input = html_encode(input(usr, "", "Rename", currentsong.name) as text|null)
		currentsong.name = copytext(input,1,30)
		updateUsrDialog()

	else if(href_list["savesong"])

		//Check if the song already exists in the internal
		var/foundsong = 0
		for(var/datum/song/isong in internalsongs)
			if(isong.id == currentsong.id)
				foundsong = 1
				isong.compiledstring = currentsong.compiledstring
				isong.sourcestring = currentsong.sourcestring
				isong.name = currentsong.name
				break

		//If not, add it as new
		if(!foundsong)
			internalsongs += currentsong

		updateUsrDialog()

	if(playing)
		if(href_list["newsong"]||href_list["setsong"]||href_list["tempo"]||href_list["compile"]||href_list["edit"]||href_list["repeat"])
			statusmsg("Playback Error: Stop the song first!")
	else
		if(href_list["newsong"])
			var/answer = alert(usr, "This will overwrite any current song you're editing!", "Are you sure?", "Yes", "No")
			if(answer == "No")
				return

			currentsong = new()
			updateUsrDialog()

		else if(href_list["setsong"])

			var/matchid = text2num(href_list["setsong"])
			for(var/datum/song/isong in internalsongs)
				if(isong.id == matchid)
					currentsong = isong
					break

			updateUsrDialog()

		else if(href_list["tempo"])
			var/tempoinc = text2num(href_list["tempo"])

			currentsong.tempo += tempoinc*-1
			if(currentsong.tempo<1)
				currentsong.tempo = 1
			currentsong.compilesuccess = 0

			updateUsrDialog()

		else if(href_list["compile"])

			compilesong()

			updateUsrDialog()

		else if(href_list["edit"])

			var/input = html_encode(input(usr, "", "Edit", currentsong.sourcestring) as message|null)

			input = dd_replacetext(input, " ", "")
			input = dd_replacetext(input, "\t", "")

			if(lentext(input)>4000)
				statusmsg("Editor Error: Song too long, end was cutoff (max 4000)")
				input = copytext(input, 1, 4001)

			currentsong.sourcestring = input
			currentsong.compilesuccess = 0

			updateUsrDialog()

		else if(href_list["repeat"])

			var/input = round(input(usr, "", "Repeat", "How many times do you want to repeat? (max 10)") as num|null)
			if(input < 1)
				input = 1
			else if(input > 10)
				input = 10

			repeat = input

	add_fingerprint(usr)
	updateUsrDialog()
	return

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
