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
	flags = FPRINT | TABLEPASS| CONDUCT
	throwforce = 2
	throw_speed = 4
	throw_range = 20

/obj/item/device/taperecorder/hear_talk(mob/living/M as mob, msg)
	if(recording)
		var/ending = copytext(msg, length(msg))
		timestamp+= timerecorded
		if(M.stuttering)
			storedinfo += "\[[time2text(timerecorded*10,"mm:ss")]\] [M.name] stammers, \"[msg]\""
			return
		if(M.getBrainLoss() >= 60)
			storedinfo += "\[[time2text(timerecorded*10,"mm:ss")]\] [M.name] gibbers, \"[msg]\""
			return
		if(ending == "?")
			storedinfo += "\[[time2text(timerecorded*10,"mm:ss")]\] [M.name] asks, \"[msg]\""
			return
		else if(ending == "!")
			storedinfo += "\[[time2text(timerecorded*10,"mm:ss")]\] [M.name] exclaims, \"[msg]\""
			return
		storedinfo += "\[[time2text(timerecorded*10,"mm:ss")]\] [M.name] says, \"[msg]\""
		return

/obj/item/device/taperecorder/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/card/emag))
		if(emagged == 0)
			emagged = 1
			recording = 0
			user << "<span class='warning'>PZZTTPFFFT</span>"
			icon_state = "taperecorderidle"
		else
			user << "<span class='warning'>It is already emagged!</span>"

/obj/item/device/taperecorder/proc/explode()
	var/turf/T = get_turf(loc)
	if(ismob(loc))
		var/mob/M = loc
		M << "<span class='danger'>\The [src] explodes!</span>"
	if(T)
		T.hotspot_expose(700,125)
		explosion(T, -1, -1, 0, 4)
	del(src)
	return

/obj/item/device/taperecorder/verb/record()
	set name = "Start Recording"
	set category = "Object"

	if(usr.stat)
		return
	if(emagged == 1)
		usr << "\red The tape recorder makes a scratchy noise."
		return
	icon_state = "taperecorderrecording"
	if(timerecorded < 3600 && playing == 0)
		usr << "<span class='notice'>Recording started.</span>"
		recording = 1
		timestamp+= timerecorded
		storedinfo += "\[[time2text(timerecorded*10,"mm:ss")]\] Recording started."
		for(timerecorded, timerecorded<3600)
			if(recording == 0)
				break
			timerecorded++
			sleep(10)
		recording = 0
		icon_state = "taperecorderidle"
		return
	else
		usr << "<span class='notice'>Either your tape recorder's memory is full, or it is currently playing back its memory.</span>"


/obj/item/device/taperecorder/verb/stop()
	set name = "Stop"
	set category = "Object"

	if(usr.stat)
		return
	if(emagged == 1)
		usr << "\red The tape recorder makes a scratchy noise."
		return
	if(recording == 1)
		recording = 0
		timestamp+= timerecorded
		storedinfo += "\[[time2text(timerecorded*10,"mm:ss")]\] Recording stopped."
		usr << "<span class='notice'>Recording stopped.</span>"
		icon_state = "taperecorderidle"
		return
	else if(playing == 1)
		playing = 0
		var/turf/T = get_turf(src)
		T.visible_message("<font color=Maroon><B>Tape Recorder</B>: Playback stopped.</font>")
		icon_state = "taperecorderidle"
		return


/obj/item/device/taperecorder/verb/clear_memory()
	set name = "Clear Memory"
	set category = "Object"

	if(usr.stat)
		return
	if(emagged == 1)
		usr << "<span class='warning'>The tape recorder makes a scratchy noise.</span>"
		return
	if(recording == 1 || playing == 1)
		usr << "<span class='notice'>You can't clear the memory while playing or recording!</span>"
		return
	else
		storedinfo -= storedinfo
		timestamp -= timestamp
		timerecorded = 0
		usr << "<span class='notice'>Memory cleared.</span>"
		return


/obj/item/device/taperecorder/verb/playback_memory()
	set name = "Playback Memory"
	set category = "Object"

	if(usr.stat)
		return
	if(emagged == 1)
		usr << "\red The tape recorder makes a scratchy noise."
		return
	if(recording == 1)
		usr << "<span class='notice'>You can't playback when recording!</span>"
		return
	if(playing == 1)
		usr << "<span class='notice'>You're already playing!</span>"
		return
	playing = 1
	icon_state = "taperecorderplaying"
	usr << "<span class='notice'>Playing started.</span>"
	for(var/i=1,timerecorded<3600,sleep(10 * (playsleepseconds) ))
		if(playing == 0)
			break
		if(storedinfo.len < i)
			break
		var/turf/T = get_turf(src)
		T.visible_message("<font color=Maroon><B>Tape Recorder</B>: [storedinfo[i]]</font>")
		if(storedinfo.len < i+1)
			playsleepseconds = 1
			sleep(10)
			T = get_turf(src)
			T.visible_message("<font color=Maroon><B>Tape Recorder</B>: End of recording.</font>")
		else
			playsleepseconds = timestamp[i+1] - timestamp[i]
		if(playsleepseconds > 14)
			sleep(10)
			T = get_turf(src)
			T.visible_message("<font color=Maroon><B>Tape Recorder</B>: Skipping [playsleepseconds] seconds of silence</font>")
			playsleepseconds = 1
		i++
	icon_state = "taperecorderidle"
	playing = 0
	if(emagged == 1.0)
		var/turf/T = get_turf(src)
		T.visible_message("<font color=Maroon><B>Tape Recorder</B>: This tape recorder will self-destruct in... Five.</font>")
		sleep(10)
		T = get_turf(src)
		T.visible_message("<font color=Maroon><B>Tape Recorder</B>: Four.</font>")
		sleep(10)
		T = get_turf(src)
		T.visible_message("<font color=Maroon><B>Tape Recorder</B>: Three.</font>")
		sleep(10)
		T = get_turf(src)
		T.visible_message("<font color=Maroon><B>Tape Recorder</B>: Two.</font>")
		sleep(10)
		T = get_turf(src)
		T.visible_message("<font color=Maroon><B>Tape Recorder</B>: One.</font>")
		sleep(10)
		explode()


/obj/item/device/taperecorder/verb/print_transcript()
	set name = "Print Transcript"
	set category = "Object"

	if(usr.stat)
		return
	if(emagged == 1)
		usr << "\red The tape recorder makes a scratchy noise."
		return
	if(!canprint)
		usr << "<span class='notice'>The recorder can't print that fast!</span>"
		return
	if(recording == 1 || playing == 1)
		usr << "<span class='notice'>You can't print the transcript while playing or recording!</span>"
		return
	usr << "<span class='notice'>Transcript printed.</span>"
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(get_turf(src))
	var/t1 = "<B>Transcript:</B><BR><BR>"
	for(var/i=1,storedinfo.len >= i,i++)
		t1 += "[storedinfo[i]]<BR>"
	P.info = t1
	P.name = "paper- 'Transcript'"
	canprint = 0
	sleep(300)
	canprint = 1


/obj/item/device/taperecorder/attack_self(mob/user)
	if(recording == 0 && playing == 0)
		if(usr.stat)
			return
		if(emagged == 1)
			usr << "\red The tape recorder makes a scratchy noise."
			return
		icon_state = "taperecorderrecording"
		if(timerecorded < 3600 && playing == 0)
			usr << "\blue Recording started."
			recording = 1
			timestamp+= timerecorded
			storedinfo += "\[[time2text(timerecorded*10,"mm:ss")]\] Recording started."
			for(timerecorded, timerecorded<3600)
				if(recording == 0)
					break
				timerecorded++
				sleep(10)
			recording = 0
			icon_state = "taperecorderidle"
			return
		else
			usr << "\red Either your tape recorder's memory is full, or it is currently playing back its memory."
	else
		if(usr.stat)
			usr << "Not when you're incapacitated."
			return
		if(recording == 1)
			recording = 0
			timestamp+= timerecorded
			storedinfo += "\[[time2text(timerecorded*10,"mm:ss")]\] Recording stopped."
			usr << "\blue Recording stopped."
			icon_state = "taperecorderidle"
			return
		else if(playing == 1)
			playing = 0
			var/turf/T = get_turf(src)
			for(var/mob/O in hearers(world.view-1, T))
				O.show_message("<font color=Maroon><B>Tape Recorder</B>: Playback stopped.</font>",2)
			icon_state = "taperecorderidle"
			return
		else
			usr << "\red Stop what?"
			return