/obj/item/device/taperecorder
	desc = "A device that can record up to an hour of dialogue and play it back. It automatically translates the content in playback."
	name = "universal recorder"
	icon_state = "taperecorderidle"
	item_state = "analyzer"
	w_class = 1.0
	m_amt = 60
	g_amt = 30
	var/emagged = 0.0
	var/recording = 0.0
	var/playing = 0.0
	var/timerecorded = 0.0
	var/playsleepseconds = 0.0
	var/list/storedinfo = new/list()
	var/list/timestamp = new/list()
	var/canprint = 1
	flags = FPRINT | TABLEPASS | CONDUCT
	throwforce = 2
	throw_speed = 4
	throw_range = 20

/obj/item/device/taperecorder/hear_talk(mob/M as mob, msg)
	if (recording)
		var/ending = copytext(msg, length(msg))
		src.timestamp+= src.timerecorded
		if (issilicon(M))
			src.storedinfo += "\[[time2text(src.timerecorded*10,"hh:mm:ss")]\] [M.name] states, \"[msg]\""
			return
		if (M.stuttering)
			src.storedinfo += "\[[time2text(src.timerecorded*10,"hh:mm:ss")]\] [M.name] stammers, \"[msg]\""
			return
		if (M.getBrainLoss() >= 60)
			src.storedinfo += "\[[time2text(src.timerecorded*10,"hh:mm:ss")]\] [M.name] gibbers, \"[msg]\""
			return
		if (ending == "?")
			src.storedinfo += "\[[time2text(src.timerecorded*10,"hh:mm:ss")]\] [M.name] asks, \"[msg]\""
			return
		else if (ending == "!")
			src.storedinfo += "\[[time2text(src.timerecorded*10,"hh:mm:ss")]\] [M.name] exclaims, \"[msg]\""
			return
		src.storedinfo += "\[[time2text(src.timerecorded*10,"hh:mm:ss")]\] [M.name] says, \"[msg]\""
		return

/obj/item/device/taperecorder/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/card/emag))
		if (src.emagged == 0)
			src.emagged = 1
			src.recording = 0
			user << "\red PZZTTPFFFT"
			src.icon_state = "taperecorderidle"
		else
			user << "\red That is already emagged!"

/obj/item/device/taperecorder/proc/explode()
	var/turf/T = get_turf(src.loc)
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.show_message("\red The [src] explodes!", 1)
	if(T)
		T.hotspot_expose(700,125)
		explosion(T, -1, -1, 0, 4)
	del(src)
	return

/obj/item/device/taperecorder/verb/record()
	set name = "Start Recording"
	set category = "Object"
	if(usr.stat)
		usr << "Not when you're incapacitated."
		return
	if(src.emagged == 1)
		usr << "\red The tape recorder makes a scratchy noise."
		return
	src.icon_state = "taperecorderrecording"
	if(src.timerecorded < 10800 && src.playing == 0)
		usr << "\blue Recording started."
		src.recording = 1
		src.timestamp+= src.timerecorded
		src.storedinfo += "\[[time2text(src.timerecorded*10,"hh:mm:ss")]\] Recording started."
		for(src.timerecorded, src.timerecorded<10800)
			if(src.recording == 0)
				break
			src.timerecorded++
			sleep(10)
		src.recording = 0
		src.icon_state = "taperecorderidle"
		return
	else
		usr << "\red Either your tape recorder's memory is full, or it is currently playing back its memory."


/obj/item/device/taperecorder/verb/stop()
	set name = "Stop"
	set category = "Object"

	if(usr.stat)
		usr << "Not when you're incapacitated."
		return
	if (src.recording == 1)
		src.recording = 0
		src.timestamp+= src.timerecorded
		src.storedinfo += "\[[time2text(src.timerecorded*10,"hh:mm:ss")]\] Recording stopped."
		usr << "\blue Recording stopped."
		src.icon_state = "taperecorderidle"
		return
	else if (src.playing == 1)
		src.playing = 0
		var/turf/T = get_turf(src)
		for(var/mob/O in hearers(world.view-1, T))
			O.show_message("<font color=Maroon><B>Tape Recorder</B>: Playback stopped.</font>",2)
		src.icon_state = "taperecorderidle"
		return
	else
		usr << "\red Stop what?"
		return


/obj/item/device/taperecorder/verb/clear_memory()
	set name = "Clear Memory"
	set category = "Object"

	if(usr.stat)
		usr << "Not when you're incapicated."
		return
	if(src.emagged == 1)
		usr << "\red The tape recorder makes a scratchy noise."
		return
	if (src.recording == 1 || src.playing == 1)
		usr << "\red You can't clear the memory while playing or recording!"
		return
	else
		src.storedinfo -= src.storedinfo
		src.timestamp -= src.timestamp
		src.timerecorded = 0
		usr << "\blue Memory cleared."
		return


/obj/item/device/taperecorder/verb/playback_memory()
	set name = "Playback Memory"
	set category = "Object"

	if(usr.stat)
		usr << "Not when you're incapicated."
		return
	if (src.recording == 1)
		usr << "\red You can't playback when recording!"
		return
	if (src.playing == 1)
		usr << "\red You're already playing!"
		return
	src.playing = 1
	src.icon_state = "taperecorderplaying"
	usr << "\blue Playing started."
	for(var/i=1,src.timerecorded<10800,sleep(10 * (src.playsleepseconds) ))
		if (src.playing == 0)
			break
		if (src.storedinfo.len < i)
			break
		var/turf/T = get_turf(src)
		for(var/mob/O in hearers(world.view-1, T))
			O.show_message("<font color=Maroon><B>Tape Recorder</B>: [src.storedinfo[i]]</font>",2)
		if (src.storedinfo.len < i+1)
			src.playsleepseconds = 1
			sleep(10)
			T = get_turf(src)
			for(var/mob/O in hearers(world.view-1, T))
				O.show_message("<font color=Maroon><B>Tape Recorder</B>: End of recording.</font>",2)
		else
			src.playsleepseconds = src.timestamp[i+1] - src.timestamp[i]
		if (src.playsleepseconds > 19)
			sleep(10)
			T = get_turf(src)
			for(var/mob/O in hearers(world.view-1, T))
				O.show_message("<font color=Maroon><B>Tape Recorder</B>: Skipping [src.playsleepseconds] seconds of silence</font>",2)
			src.playsleepseconds = 1
		i++
	src.icon_state = "taperecorderidle"
	src.playing = 0
	if (src.emagged == 1.0)
		for(var/mob/O in hearers(world.view-1, get_turf(src)))
			O.show_message("Tape Recorder: This tape recorder will self destruct in <B>5</B>",2)
		sleep(10)
		for(var/mob/O in hearers(world.view-1, get_turf(src)))
			O.show_message("<B>4</B>",2)
		sleep(10)
		for(var/mob/O in hearers(world.view-1, get_turf(src)))
			O.show_message("<B>3</B>",2)
		sleep(10)
		for(var/mob/O in hearers(world.view-1, get_turf(src)))
			O.show_message("<B>2</B>",2)
		sleep(10)
		for(var/mob/O in hearers(world.view-1, get_turf(src)))
			O.show_message("<B>1</B>",2)
		sleep(10)
		src.explode()


/obj/item/device/taperecorder/verb/print_transcript()
	set name = "Print Transcript"
	set category = "Object"

	if (!canprint)
		usr << "\red The recorder can't print that fast!"
		return
	if (src.recording == 1 || src.playing == 1)
		usr << "\red You can't print the transcript while playing or recording!"
		return
	usr << "\blue Transcript printed."
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(get_turf(src))
	var/t1 = "<B>Transcript:</B><BR><BR>"
	for(var/i=1,src.storedinfo.len >= i,i++)
		t1 += "[src.storedinfo[i]]<BR>"
	P.info = t1
	P.name = "paper - 'Transcript'"
	P.overlays += "paper_words"
	canprint = 0
	sleep(300)
	canprint = 1


/obj/item/device/taperecorder/attack_self(mob/user)
	if(src.recording == 0 && src.playing == 0)
		if(usr.stat)
			usr << "Not when you're incapacitated."
			return
		if(src.emagged == 1)
			usr << "\red The tape recorder makes a scratchy noise."
			return
		src.icon_state = "taperecorderrecording"
		if(src.timerecorded < 10800 && src.playing == 0)
			usr << "\blue Recording started."
			src.recording = 1
			src.timestamp+= src.timerecorded
			src.storedinfo += "\[[time2text(src.timerecorded*10,"hh:mm:ss")]\] Recording started."
			for(src.timerecorded, src.timerecorded<10800)
				if(src.recording == 0)
					break
				src.timerecorded++
				sleep(10)
			src.recording = 0
			src.icon_state = "taperecorderidle"
			return
		else
			usr << "\red Either your tape recorder's memory is full, or it is currently playing back its memory."
	else
		if(usr.stat)
			usr << "Not when you're incapacitated."
			return
		if (src.recording == 1)
			src.recording = 0
			src.timestamp+= src.timerecorded
			src.storedinfo += "\[[time2text(src.timerecorded*10,"hh:mm:ss")]\] Recording stopped."
			usr << "\blue Recording stopped."
			src.icon_state = "taperecorderidle"
			return
		else if (src.playing == 1)
			src.playing = 0
			var/turf/T = get_turf(src)
			for(var/mob/O in hearers(world.view-1, T))
				O.show_message("<font color=Maroon><B>Tape Recorder</B>: Playback stopped.</font>",2)
			src.icon_state = "taperecorderidle"
			return
		else
			usr << "\red Stop what?"
			return