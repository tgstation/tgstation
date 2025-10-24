ADMIN_VERB(upload_jukebox_music, R_SERVER, "Jukebox Upload Music", "Upload a valid .ogg file to be accessed via the jukebox.", ADMIN_CATEGORY_SERVER)
	var/file = input(user, "Select a .ogg file to upload to the jukebox.") as file
	if(!file)
		return

	// we could theorticly support WAV or MP3 but OGG is the better format from what I am aware.
	if(!IS_OGG_FILE(file))
		tgui_alert(user, "Invalid file type. Please select an OGG file.", "Loading error", list("Ok"))
		return

	var/list/track_data = splittext(file, "+")
	if(track_data.len < 2)
		if(tgui_alert(user, "Your song currently does not have a beat in deciseconds added to its title. Continue? EX: SS13+5.ogg", "Confirmation", list("Yes", "No")) != "Yes")
			return
	if(track_data.len > 2)
		tgui_alert(user, "Titles should only have its title and beat in deciseconds, EX: SS13+5.ogg", "Loading error", list("Ok"))
		return


	var/upload_dir = CONFIG_JUKEBOX_SOUNDS
	var/clean_name = SANITIZE_FILENAME("[file]")
	var/save_path = "[upload_dir][clean_name]"

	// Copy uploaded file to the server
	fcopy(file, save_path)

	message_admins("[key_name_admin(user)] uploaded [clean_name] to the jukebox!")
	to_chat(user, span_notice("Successfully uploaded [clean_name]!"))

ADMIN_VERB(delete_jukebox_music, R_ADMIN, "Jukebox Delete Music", "Remove an uploaded jukebox track.", ADMIN_CATEGORY_SERVER)
	var/list/files = flist(CONFIG_JUKEBOX_SOUNDS)
	// Filter out things that are not sound files, like the exclude
	for(var/thing in files)
		if(!IS_SOUND_FILE(thing))
			files -= thing
	if(!files.len)
		to_chat(user, span_warning("No uploaded tracks found."))
		return

	var/choice = tgui_input_list(user, "Select a track to delete:", "Delete Jukebox Music", files)
	if(!choice)
		return

	var/path = "[global.config.directory]/jukebox_music/sounds/[choice]"
	fdel(path)

	var/msg = "[key_name_admin(user)] deleted [choice] from the jukebox!"
	message_admins(msg)
	log_admin(msg)
	to_chat(user, span_notice("Deleted [choice] successfully."))

