/obj/item/device/taperecorder
	desc = "A device that can record up to a minute of dialogue and play it back."
	name = "tape recorder"
	icon_state = "taperecorderidle"
	item_state = "analyzer"
	w_class = 1.0
	m_amt = 60
	g_amt = 30
	var/emagged = 0.0
	var/recording = 0.0
	var/playing = 0.0
	var/timerecorded = 0.0
	var/list/storedinfo = new/list()
	flags = FPRINT | TABLEPASS| CONDUCT
	throwforce = 2
	throw_speed = 4
	throw_range = 20

/obj/item/device/taperecorder/hear_talk(mob/M as mob, msg)
	if (src.recording)
		var/ending = copytext(msg, length(msg))
		if (M.stuttering)
			src.storedinfo += "[M.name] stammers, \"[msg]\""
			return
		if (M.brainloss >= 60)
			src.storedinfo += "[M.name] gibbers, \"[msg]\""
			return
		if (ending == "?")
			src.storedinfo += "[M.name] asks, \"[msg]\""
			return
		else if (ending == "!")
			src.storedinfo += "[M.name] exclaims, \"[msg]\""
			return
		src.storedinfo += "[M.name] says, \"[msg]\""
		return

/obj/item/device/taperecorder/attackby(obj/item/weapon/W as obj, mob/user as mob)
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
	set name = "record"
	if(usr.stat)
		usr << "Not when you're incapicated."
		return
	if(src.emagged == 1)
		usr << "\red The tape recorder makes a scratchy noise."
		return
	src.icon_state = "taperecorderrecording"
	if(src.timerecorded < 60 && src.playing == 0)
		src.recording = 1
		for(src.timerecorded, src.timerecorded<60)
			if(src.recording == 0)
				break
			src.timerecorded++
			sleep(10)
		src.recording = 0
		src.icon_state = "taperecorderidle"
		return
	else
		usr << "\red Either your tape recorder's memory is full, or it is currently playing back its memory."


/obj/item/device/taperecorder/verb/stop_recording()
	set name = "stop"

	if(usr.stat)
		usr << "Not when you're incapicated."
		return
	if (src.recording == 1 || src.playing == 1)
		src.recording = 0
		src.playing = 0
		usr << "\blue Stopped."
		src.icon_state = "taperecorderidle"
		return
	else
		usr << "\red Stop what?"
		return


/obj/item/device/taperecorder/verb/clear_memory()
	set name = "clear memory"

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
		src.timerecorded = 0
		usr << "\blue Memory cleared."
		return


/obj/item/device/taperecorder/verb/playback_memory()
	set name = "playback memory"

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
	for(var/i=1,src.timerecorded<60,sleep(10 * (src.timerecorded/src.storedinfo.len)))
		if (src.playing == 0)
			break
		if (src.storedinfo.len < i)
			break
		var/turf/T = get_turf(src)
		for(var/mob/O in hearers(world.view-1, T))
			O.show_message("\green <B>Tape Recorder</B>: \"[src.storedinfo[i]]\"",2)
		i++
	src.icon_state = "taperecorderidle"
	src.playing = 0
	var/turf/T = get_turf(src)
	for(var/mob/O in hearers(world.view-1, T))
		O.show_message("Tape Recorder: End playback.",2)
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