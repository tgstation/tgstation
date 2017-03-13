#define TAPE_RECORDER_NAME "universal recorder"

/obj/item/device/taperecorder
	name = TAPE_RECORDER_NAME
	desc = "A device that can record to cassette tapes, and play them. It automatically translates the content in playback."
	icon_state = "taperecorder_empty"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = HEAR
	slot_flags = SLOT_BELT
	languages_spoken = ALL //this is a translator, after all.
	languages_understood = ALL //this is a translator, after all.
	materials = list(MAT_METAL=60, MAT_GLASS=30)
	force = 2
	throwforce = 0
	var/recording = FALSE
	var/playing = FALSE
	var/playsleepseconds = 0
	// var/loop = FALSE // Disabled until AI can spot tape recorders over radio
	var/obj/item/device/tape/mytape
	var/open_panel = FALSE
	var/canprint = TRUE
	var/canRecordComms = FALSE // Record what comes out of the radio
	var/announce = TRUE // Announce if the tape is playing or not playing
	var/playPosition = 1
	var/myVoice = "" // Define in New()
	var/recorderTalkSpan = "abductor"
	var/browserWindowName = "universalrecorder"

/obj/item/device/taperecorder/New()
	myVoice = name
	mytape = new /obj/item/device/tape/random(src)
	// mytape = new("{John}Hi{Bob}Hello{wait=2}{John}How are you?{Bob}<b>I am fine</b>{wait=5}{John}Yep") // DELETEME
	update_icon()
	..()

/*
/obj/item/device/taperecorder/proc/New(txt, color="white")
	myVoice = name
	mytape = new(txt,color)
	update_icon()
	..()
*/

// DELETEME
/obj/item/device/taperecorder/verb/setDialogue(txt as text)
	if (mytape)
		mytape.setDialogue(txt)

/obj/item/device/taperecorder/examine(mob/user)
	..()
	to_chat(user, "The wire panel is [open_panel ? "opened" : "closed"].")


/obj/item/device/taperecorder/attackby(obj/item/I, mob/user, params)
	if(!mytape && istype(I, /obj/item/device/tape))
		if(!user.transferItemToLoc(I,src))
			return
		mytape = I
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		update_icon()


/obj/item/device/taperecorder/proc/eject(mob/user)
	if(mytape)
		to_chat(user, "<span class='notice'>You remove [mytape] from [src].</span>")
		stop()
		user.put_in_hands(mytape)
		mytape = null
		update_icon()

/obj/item/device/taperecorder/fire_act(exposed_temperature, exposed_volume)
	mytape.ruin() //Fires destroy the tape
	..()

/obj/item/device/taperecorder/attack_hand(mob/user)
	if(loc == user)
		if(mytape)
			if(!user.is_holding(src))
				..()
				return
			eject(user)
			return
	..()

/obj/item/device/taperecorder/proc/can_use(mob/user)
	if(user && ismob(user))
		if(!user.incapacitated())
			return 1
	return 0


/obj/item/device/taperecorder/verb/ejectverb()
	set name = "Eject Tape"
	set category = "Object"

	if(!can_use(usr))
		return
	if(!mytape)
		return

	eject(usr)


/obj/item/device/taperecorder/update_icon()
	if(!mytape)
		icon_state = "taperecorder_empty"
	else if(recording)
		icon_state = "taperecorder_recording"
	else if(playing)
		icon_state = "taperecorder_playing"
	else
		icon_state = "taperecorder_idle"


/obj/item/device/taperecorder/GetVoice()
	return myVoice


/obj/item/device/taperecorder/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans)
	if(mytape && recording)
		if ((canRecordComms && radio_freq) || !radio_freq)
			mytape.addInfo(message, speaker, message_langs, raw_message, radio_freq, spans)


/obj/item/device/taperecorder/proc/toggleRecordComms()
	set name = "Toggle radio record"
	set category = "Object"
	if (canRecordComms)
		usr << "<span class='notice'>The [name] is set to <B>not record</B> the radio.</span>"
		canRecordComms = FALSE
	else
		usr << "<span class='notice'>The [name] is set to <B>record</B> the radio.</span>"
		canRecordComms = TRUE

/*
/obj/item/device/taperecorder/verb/toggleLoop()
	set name = "Toggle loop"
	set category = "Object"
	if (loop)
		usr << "<span class='notice'>The [name] is set to <B>not loop</B> any longer.</span>"
		loop = FALSE
	else
		usr << "<span class='notice'>The [name] is set to <B>loop</B>.</span>"
		loop = TRUE
*/

/obj/item/device/taperecorder/proc/toggleAnnounce()
	set name = "Toggle announcements"
	set category = "Object"
	if (announce)
		usr << "<span class='notice'>The [name] is set to <B>not announce</B> the tape playing.</span>"
		announce = FALSE
	else
		usr << "<span class='notice'>The [name] is set to <B>announce</B> the tape playing.</span>"
		announce = TRUE

/obj/item/device/taperecorder/verb/record()
	set name = "Start Recording"
	set category = "Object"

	if(!can_use(usr) || !mytape || mytape.ruined || recording || playing || mytape.premade)
		return

	if(mytape.used_capacity < mytape.max_capacity)
		to_chat(usr, "<span class='notice'>Recording started.</span>")
		recording = TRUE
		playPosition = 1
		refreshBrowseMenu()
		update_icon()
		var/used = mytape.used_capacity	//to stop runtimes when you eject the tape // I have no idea what this comment means - Davidj361
		var/max = mytape.max_capacity
		for(used, used < max)
			if(!recording)
				break
			mytape.used_capacity++
			used++
			if (mytape && mytape.storedinfo && mytape.storedinfo.len != 0)
				playPosition = mytape.storedinfo.len // Make browser menu show it's recording
			refreshBrowseMenu()
			sleep(10)
		recording = FALSE
		update_icon()
	else
		to_chat(usr, "<span class='notice'>The tape is full.</span>")


/obj/item/device/taperecorder/verb/stop()
	set name = "Stop/Rewind"
	set category = "Object"

	if(!can_use(usr))
		return

	playPosition = 1
	if(recording)
		recording = FALSE
		to_chat(usr, "<span class='notice'>Recording stopped.</span>")
		mytape.addInfoAnnounce(src, "*an audible cut in the recording is heard*")
		return
	else if(playing)
		playing = FALSE
		// T.visible_message("<font color=Maroon><B>Tape Recorder</B>: Playback stopped.</font>") // OLD
		to_chat(usr, "<span class='notice'>Playback stopped.</span>")
	update_icon()


/obj/item/device/taperecorder/verb/play()
	set name = "Play/Pause Tape"
	set category = "Object"

	if(!can_use(usr) || !mytape || mytape.ruined || recording)
		return
	if(playing)
		announce("Playing paused.")
		playing = FALSE
		return

	playing = TRUE
	update_icon()
	if (announce)
		announce("Playing started.")
	var/used = mytape.used_capacity	//to stop runtimes when you eject the tape
	var/max = mytape.max_capacity
	while (used < max)
		if(!mytape || !playing)
			break
		else if (mytape.storedinfo.len < playPosition)
			if (announce)
				announce("Playing ended.")
			playPosition = 1 // automatically rewind the tape
			break
		recorderSay(playPosition)
		if(mytape.storedinfo.len < playPosition + 1)
			playsleepseconds = 1
			sleep(10)
			//if (loop)
				//playPosition = 0 // since playPosition++ at end
		else
			playsleepseconds = mytape.timestampInSeconds[playPosition + 1] - mytape.timestampInSeconds[playPosition]
		if(playsleepseconds > 14)
			sleep(10)
			announce("Skipping [playsleepseconds] seconds of silence")
			playsleepseconds = 1
		playPosition++
		refreshBrowseMenu()
		sleep(10 * playsleepseconds)

	playing = FALSE
	update_icon()

// Taken from browser.dm
// For some fucking reason all the shit for browser.dm is commented out, so I'll just copy paste this
/obj/item/device/taperecorder/proc/browse_rsc_icon(icon, icon_state, dir = -1)
	var/icon/I
	if (dir >= 0)
		I = new /icon(icon, icon_state, dir)
	else
		I = new /icon(icon, icon_state)
		setDir("default")

	var/filename = "[ckey("[icon]_[icon_state]_[dir]")].png"
	src << browse_rsc(I, filename)
	return filename

// Make a menu for the player to seek through the tape and do other actions
/obj/item/device/taperecorder/attack_self(mob/user)
	user.set_machine(src)
	var/form_id = "seek"
	var/dat = get_javascript_header(form_id)
	var/timeStamp = "00:00"
	var/length = "00:00"
	var/progress = 0
	var/max = 1
	if (mytape && mytape.storedinfo && mytape.timestampInSeconds && playPosition <= mytape.storedinfo.len && mytape.timestampInSeconds[playPosition] && mytape.storedinfo[playPosition])
		timeStamp = mytape.storedinfo[playPosition]["time_stamp"]
		max = mytape.used_capacity
		progress = mytape.timestampInSeconds[playPosition]
		length = mytape.storedinfo[mytape.storedinfo.len]["time_stamp"]
	var/percent = (progress/max)*100

	setDir("default")
	var/filename = ""
	if(icon_state == "taperecorder_recording")
		filename = "taperecorder_recording.gif"
		usr << browse_rsc('icons/obj/taperecorder/taperecorder_recording.gif',filename)
	else if(icon_state == "taperecorder_playing")
		filename = "taperecorder_playing.gif"
		usr << browse_rsc('icons/obj/taperecorder/taperecorder_playing.gif',filename)
	else
		var/icon/I = new /icon(icon, icon_state)
		filename = "[ckey("[icon]_[icon_state]_[dir]")].png"
		user << browse_rsc(I, filename)

	// Rotate the image as well, sorry boys IE only :^)
	dat += "<center><IMG src='[filename]' style='height: 200px; -ms-transform-origin: top left; -ms-transform: rotate(90deg) translateY(-100%);'></center>"

	dat += {"<center><div style="width:80%; height:50px; border:1px solid black;background-color:gainsboro;position:relative;">
				<div style="width:100%; height:50px; border:1px solid black;background-color:gainsboro;position:relative;">
				        <div style="top:15px;width:100%;position:absolute;z-index: 10;color:black;"><center>\[[timeStamp]\] / \[[length]\]</center></div>
							  <div style="position:absolute;width:[percent]%; background-color:grey; height:50px;top:0;left:0;"></div>
							</div>
				</div>
				</center><br><br>"}
	dat += "<form name='seek' id='seek' action='?src=\ref[src]' method='get' style='display: inline'>"
	dat += "<input type='hidden' name='src' value='\ref[src]'>"
	dat += "<input type='hidden' name='operation' value='seek'>"
	dat += "<input type='text' id='seekfield' name='seekfield' style='width:50px; background-color:#FFDDDD;' onkeyup='process()'>"
	dat += " <a href='#' onclick='submit()'>Seek</a> (Format: XX:XX)<br><br>"
	dat += "<a href='byond://?src=\ref[src];operation=playPause'>Play/Pause</a><br><br>"
	dat += "<a href='byond://?src=\ref[src];operation=stopRewind'>Stop/Rewind</a><br><br>"
	dat += "<a href='byond://?src=\ref[src];operation=record'>Record</a><br><br>"
	dat += "<a href='byond://?src=\ref[src];operation=toggleRecordComms'>Toggle radio record</a><br><br>"
	dat += "<a href='byond://?src=\ref[src];operation=toggleAnnounce'>Toggle announcements</a><br><br>"
	dat += "<a href='byond://?src=\ref[src];operation=viewTranscript'>View Transcript</a><br><br>"
	dat += "<a href='byond://?src=\ref[src];operation=print_transcript'>Print Transcript</a>"

	var/datum/browser/popup = new(user, browserWindowName, name, 400, 700)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/item/device/taperecorder/Topic(href, href_list)
	..()
	if(!href_list["operation"])
		return

	var/mob/living/U = usr
	if(usr.canUseTopic(src) && !href_list["close"])
		src.add_fingerprint(U)
		U.set_machine(src)
		switch(href_list["operation"])
			if("seek")
				if (!mytape || !mytape.storedinfo)
					return
				var/seekfield = href_list["seekfield"]
				// Grab the minutes and seconds
				var/regex/re = new("(^\\d{1,2}):(\\d{1,2})$")
				if (re.Find(seekfield) == 0)
					return
				var/mins = round(text2num(re.group[1]))
				var/secs = round(text2num(re.group[2]))
				secs += (mins * 60) // Needed for easier comparison
				var/lastIter = 1
				for (var/iter=1; iter <= mytape.timestampInSeconds.len; iter++)
					var/iterTimestamp = mytape.timestampInSeconds[iter]
					if (iterTimestamp > secs)
						break
					lastIter = iter
				if (playing)
					announce("*tape winding noise*")
				playPosition = lastIter
			if ("playPause")
				play()
			if ("stopRewind")
				stop()
			if ("record")
				record()
			if ("toggleRecordComms")
				toggleRecordComms()
			if ("toggleAnnounce")
				toggleAnnounce()
			if ("viewTranscript")
				viewTranscript()
			if ("print_transcript")
				print_transcript()
	else // If not in range, can't interact or not using the pda.
		U.unset_machine()
		U << browse(null, "window=[browserWindowName]") // Might be needed
		return

	refreshBrowseMenu()
	return

/obj/item/device/taperecorder/proc/refreshBrowseMenu()
	var/mob/living/U = usr
	if(U.machine == src)//Final safety.
		attack_self(U)//It auto-closes the menu prior if the user is not in range and so on.
	else
		U.unset_machine()
		U << browse(null, "window=[browserWindowName]") // Might be needed

// Taken from communications.dm, checks if the user put the right format for seeking
/obj/item/device/taperecorder/proc/get_javascript_header(form_id)
	var/dat = {"<script type="text/javascript">
					var re = /^\\d{1,2}:\\d{1,2}$/;
						function submit() {
							document.getElementById('[form_id]').submit();
						}
						function process(){
							var seekfield = document.getElementById('seekfield');
							if(re.test(seekfield.value)){
								seekfield.style.backgroundColor = "#DDFFDD";
							}
							else {
								seekfield.style.backgroundColor = "#FFDDDD";
							}
						}
					</script>"}
	return dat

/obj/item/device/taperecorder/AltClick(mob/living/user)
	if(!mytape || mytape.ruined)
		return
	if(recording)
		stop()
	else
		record()

/obj/item/device/taperecorder/proc/createPaperData()
	if(!can_use(usr))
		return
	if(!mytape)
		return
	var/t1 = "<B>Transcript:</B><BR><BR>"
	for(var/i = 1, mytape.storedinfo.len >= i, i++)
		if (mytape.storedinfo[i]["announce"])
			t1 += "** \[[mytape.storedinfo[i]["time_stamp"]]\] [mytape.storedinfo[i]["message"]]<BR>"
		else
			if (mytape.premade)
				t1 += "\[[mytape.storedinfo[i]["time_stamp"]]\] [mytape.storedinfo[i]["nosrc_speaker"]] says, \"[mytape.storedinfo[i]["raw_message"]]\"<BR>"
			else
				t1 += "\[[mytape.storedinfo[i]["time_stamp"]]\] [mytape.storedinfo[i]["message"]]<BR>"
	return t1

// copy pasted code from paper.dm
/obj/item/device/taperecorder/proc/viewTranscript()
	if(!can_use(usr))
		return
	if(!mytape)
		return
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/paper)
	var/info = createPaperData()
	var/paperName = "Transcript"
	assets.send(usr)
	if(in_range(usr, src) || isobserver(usr))
		if(usr.is_literate())
			usr << browse("<HTML><HEAD><TITLE>[paperName]</TITLE></HEAD><BODY>[info]<HR></BODY></HTML>", "window=[paperName]")
			onclose(usr, "[paperName]")
		else
			usr << browse("<HTML><HEAD><TITLE>[paperName]</TITLE></HEAD><BODY>[stars(info)]<HR></BODY></HTML>", "window=[paperName]")
			onclose(usr, "[paperName]")
	else
		to_chat(usr, "<span class='notice'>It is too far away.</span>")

/obj/item/device/taperecorder/verb/print_transcript()
	set name = "Print Transcript"
	set category = "Object"

	if(!can_use(usr))
		return
	if(!mytape)
		return
	if(!canprint)
		to_chat(usr, "<span class='notice'>The recorder can't print that fast!</span>")
		return
	if(recording || playing)
		return

	to_chat(usr, "<span class='notice'>Transcript printed.</span>")
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(get_turf(src))
	P.info = createPaperData()
	P.name = "paper- 'Transcript'"
	usr.put_in_hands(P)
	canprint = 0
	sleep(300)
	canprint = 1

/obj/item/device/taperecorder/proc/announce(message)
	var/list/spans = get_spans()
	spans = spans.Copy() // hur durrr I am byond and I cannot do chaining hurrr durrr
	spans += recorderTalkSpan
	send_speech(message,, src,, spans)


/obj/item/device/taperecorder/proc/recorderSay(i)
	if (!mytape || !mytape.storedinfo[i])
		return
	var/x = mytape.storedinfo[i]
	var/list/span = x["spans"]
	span = span.Copy() // hur durrr I am byond and I cannot do chaining hurrr durrr
	if (!x["announce"])
		if (mytape.premade)
			myVoice = x["nosrc_speaker"]
		else
			var/atom/movable/iObj = x["speaker"]
			myVoice = iObj.GetVoice() // Make the recorder disguise itself as the recorded voice
	if (announce)
		span += recorderTalkSpan // So people see easier that the tape is talking
	if (announce && x["announce"])
		var/timestamp = x["time_stamp"]
		send_speech("\[[timestamp]\] " + x["raw_message"],, x["speaker"],, span) // Add a timestamp at the beginning
	else if (!x["announce"])
		if (mytape.premade)
			send_speech(x["raw_message"],, src,, span) // This will make the tape recorder show as the universal recorder's name on radios, but oh well
		else
			send_speech(x["raw_message"],, x["speaker"],, span)
	myVoice = name


//empty tape recorders
/obj/item/device/taperecorder/empty/New()
	return


/obj/item/device/tape
	name = "tape"
	desc = "A magnetic tape that can hold up to ten minutes of content."
	icon_state = "tape_white"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_TINY
	materials = list(MAT_METAL=20, MAT_GLASS=5)
	force = 1
	throwforce = 0
	var/max_capacity = 600
	var/used_capacity = 0
	var/list/storedinfo = list()
	var/list/timestampInSeconds = list()
	var/ruined = 0
	var/premade = FALSE

/obj/item/device/tape/fire_act(exposed_temperature, exposed_volume)
	ruin()
	..()

/obj/item/device/tape/attack_self(mob/user)
	if(!ruined)
		to_chat(user, "<span class='notice'>You pull out all the tape!</span>")
		ruin()


/obj/item/device/tape/proc/ruin()
	//Lets not add infinite amounts of overlays when our fireact is called
	//repeatedly
	if(!ruined)
		add_overlay("ribbonoverlay")
	ruined = 1


/obj/item/device/tape/proc/fix()
	cut_overlay("ribbonoverlay")
	ruined = 0

/obj/item/device/tape/proc/addInfo(message, speaker, message_langs, raw_message, radio_freq, spans)
	timestampInSeconds += used_capacity
	// remove radio_freq
	// storedinfo[++storedinfo.len] = list(message, speaker, message_langs, raw_message, , spans, time2text(used_capacity * 10,"mm:ss"), FALSE) // OLD
	var/x[0]
	x["message"] = message
	x["speaker"] = speaker
	x["message_langs"] = message_langs
	x["raw_message"] = raw_message
	x["spans"] = spans
	x["time_stamp"] = time2text(used_capacity * 10,"mm:ss")
	x["announce"] = FALSE
	storedinfo[++storedinfo.len] = x

/obj/item/device/tape/proc/addInfoAnnounce(src, message)
	timestampInSeconds += used_capacity
	var/spans = get_spans()
	var/rendered = compose_message(src, languages_spoken, message, , spans)
	// storedinfo[++storedinfo.len] = list(rendered, src, languages_spoken, message, , spans, time2text(used_capacity * 10,"mm:ss"), TRUE) // OLD
	var/x[0]
	x["message"] = rendered
	x["speaker"] = src
	x["message_langs"] = languages_spoken
	x["raw_message"] = message
	x["spans"] = spans
	x["time_stamp"] = time2text(used_capacity * 10,"mm:ss")
	x["announce"] = TRUE
	storedinfo[++storedinfo.len] = x

// A helper function for setDialogue
/obj/item/device/tape/proc/addInfoNoSrc(message, speaker)
	if (!premade)
		return
	timestampInSeconds += used_capacity
	var/spans = list()
	var/x[0]
	x["nosrc_speaker"] = speaker
	x["message_langs"] = languages_spoken
	x["raw_message"] = message
	x["spans"] = spans
	x["time_stamp"] = time2text(used_capacity * 10,"mm:ss")
	x["announce"] = FALSE
	storedinfo[++storedinfo.len] = x


/obj/item/device/tape/attackby(obj/item/I, mob/user, params)
	if(ruined)
		var/delay = -1
		if (istype(I, /obj/item/weapon/screwdriver))
			delay = 120*I.toolspeed
		else if(istype(I, /obj/item/weapon/pen))
			delay = 120*1.5
		if (delay != -1)
			to_chat(user, "<span class='notice'>You start winding the tape back in...</span>")
			if(do_after(user, delay, target = src))
				to_chat(user, "<span class='notice'>You wound the tape back in.</span>")
				fix()

//Random colour tapes
/obj/item/device/tape/random/New()
	icon_state = "tape_[pick("white", "blue", "red", "yellow", "purple")]"
	..()

/*
// A constructor for map-makers to make tapes with messages
/obj/item/device/tape/proc/New(txt, color="white")
	icon_state = "tape_[color]"
	// setDialogue(txt) // FIXME
	premade = TRUE
	..()
	*/

// FIXME: change back to proc
/obj/item/device/tape/verb/setDialogue(txt as text)
	premade = TRUE
	// Reset everything
	used_capacity = 1
	max_capacity = 600
	storedinfo = list()
	timestampInSeconds = list()

	var/start = 1
	// For reference: https://regex101.com/r/0jjDGb/6
	// Our regex: \[([^\]]*)\]([^[]*)
	var str = "\\\[(\[^\\]]*)\\](\[^\[]*)"
	var/regex/re = new(str,"g")
	var/regex/re2 = new("^(.*);$")
	var/regex/re3 = new("^wait=(\\d+)$")
	while(re.Find(txt, start))
		start = re.next // Get our next match
		var/speaker = ""
		var/message = ""
		var/wait = 0
		if (re3.Find(re.group[1])) // Is this a [wait] command?
			wait = re3.group[1] // Add silence
			used_capacity += round(text2num(wait))
		else
			if (length(re.group[1]) != 0) // Is it a blank []?
				if (re.group[1] == ";") // Quick announcement?
					speaker = TAPE_RECORDER_NAME
				else if (!re2.Find(re.group[1])) // is there a ; in our square brackets?
					wait = 1
					speaker = re.group[1]
				else
					speaker = re2.group[1]
			else
				wait = 1
				speaker = TAPE_RECORDER_NAME
			message = re.group[2]
			used_capacity += round(text2num(wait))
			// Add the dialogue
			addInfoNoSrc(message, speaker)
	max_capacity = used_capacity + 1