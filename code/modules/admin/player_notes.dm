//This stuff was originally intended to be integrated into the ban-system I was working on
//but it's safe to say that'll never be finished. So I've merged it into the current player panel.
//enjoy				~Carn

#define NOTESFILE "data/player_notes.sav"	//where the player notes are saved

/proc/see_own_notes()
	if(!config.see_own_notes)
		return
	var/ckey = usr.client.ckey
	if(!ckey)
		usr << "<span class='warning'>Error: No ckey found.</span>"
		return
	var/savefile/notesfile = new(NOTESFILE)
	if(!notesfile)
		usr << "<span class='warning'>Error: Cannot access [NOTESFILE]</span>"
		return
	notesfile.cd = "/[ckey]"
	var/dat = "<b>Notes for [ckey]:</b><br>"
	while(!notesfile.eof)
		var/note
		notesfile >> note
		dat += note + "<br>"
	var/datum/browser/popup = new(usr, "player_notes", "Player Notes", 700, 400)
	popup.set_content(dat)
	popup.open()


/datum/admins/proc/notes_show(var/ckey)
	usr << browse("<head><title>Player Notes</title></head><body>[notes_gethtml(ckey)]</body>","window=player_notes;size=700x400")


/datum/admins/proc/notes_gethtml(var/ckey)
	var/savefile/notesfile = new(NOTESFILE)
	if(!notesfile)	return "<span class='warning'>Error: Cannot access [NOTESFILE]</span>"
	if(ckey)
		. = "<b>Notes for <a href='?_src_=holder;notes=show'>[ckey]</a>:</b> <a href='?_src_=holder;notes=add;ckey=[ckey]'>\[+\]</a><br>"
		notesfile.cd = "/[ckey]"
		var/index = 1
		while( !notesfile.eof )
			var/note
			notesfile >> note
			. += "[note] <a href='?_src_=holder;notes=remove;ckey=[ckey];from=[index]'>\[-\]</a><br>"
			index++
	else
		. = "<b>All Notes:</b> <a href='?_src_=holder;notes=add'>\[+\]</a><br>"
		notesfile.cd = "/"
		for(var/dir in notesfile.dir)
			. += "<a href='?_src_=holder;notes=show;ckey=[dir]'>[dir]</a><br>"
	return


//handles adding notes to the end of a ckey's buffer
//originally had seperate entries such as var/by to record who left the note and when
//but the current bansystem is a heap of dung.
/proc/notes_add(var/ckey, var/note, var/lognote = 0)
	if(!ckey)
		ckey = ckey(input(usr,"Who would you like to add notes for?","Enter a ckey",null) as text|null)
		if(!ckey)	return

	if(!note)
		note = html_encode(input(usr,"Enter your note:","Enter some text",null) as message|null)
		if(!note)	return

	var/savefile/notesfile = new(NOTESFILE)
	if(!notesfile)	return
	notesfile.cd = "/[ckey]"
	notesfile.eof = 1		//move to the end of the buffer
	notesfile << "[time2text(world.realtime,"DD-MMM-YYYY")] | [note][(usr && usr.ckey)?" ~[usr.ckey]":""]"

	if(lognote)//don't need an admin log for the notes applied automatically during bans.
		message_admins("[key_name(usr)] added note '[note]' to [ckey]")
		log_admin("[key_name(usr)] added note '[note]' to [ckey]")

	return

//handles removing entries from the buffer, or removing the entire directory if no start_index is given
/proc/notes_remove(var/ckey, var/start_index, var/end_index)
	var/savefile/notesfile = new(NOTESFILE)
	var/admin_msg
	if(!notesfile)	return

	if(!ckey)
		notesfile.cd = "/"
		ckey = ckey(input(usr,"Who would you like to remove notes for?","Enter a ckey",null) as null|anything in notesfile.dir)
		if(!ckey)	return

	if(start_index)
		notesfile.cd = "/[ckey]"
		var/list/noteslist = list()
		if(!end_index)	end_index = start_index
		var/index = 0
		while( !notesfile.eof )
			index++
			var/temp
			notesfile >> temp
			if( (start_index <= index) && (index <= end_index) )
				admin_msg = temp
				continue

			noteslist += temp

		notesfile.eof = -2		//Move to the start of the buffer and then erase.

		for( var/note in noteslist )
			notesfile << note

		message_admins("[key_name(usr)] removed a note '[admin_msg]' from [ckey]")
		log_admin("[key_name(usr)] removed a note '[admin_msg]' from [ckey]")

		if(noteslist.len == 0)
			notesfile.cd = "/"
			notesfile.dir.Remove(ckey)
			message_admins("[ckey] has no notes and was removed from the notes list.")
	return

#undef NOTESFILE