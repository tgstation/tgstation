#define SOUND_CHANNEL_ADMIN 777
var/sound/admin_sound

/client/proc/play_sound(S as sound)
	set category = "Fun"
	set name = "Play Global Sound"
	if(!check_rights(R_SOUNDS))	return

	admin_sound = sound(S, repeat = 0, wait = 1, channel = SOUND_CHANNEL_ADMIN)
	admin_sound.priority = 250
	admin_sound.status = SOUND_UPDATE|SOUND_STREAM

	log_admin("[key_name(src)] played sound [S]")
	message_admins("[key_name_admin(src)] played sound [S]", 1)

	if(events.holiday == "April Fool's Day")
		admin_sound.frequency = pick(0.5, 0.7, 0.8, 0.85, 0.9, 0.95, 1.1, 1.2, 1.4, 1.6, 2.0, 2.5)
		src << "You feel the Honkmother messing with your song..."

	for(var/mob/M in player_list)
		if(M.client.prefs.toggles & SOUND_MIDI)
			M << admin_sound

	admin_sound.frequency = 1 //Remove this line when the AFD stuff above is gone
	admin_sound.wait = 0
	feedback_add_details("admin_verb","PGS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/play_local_sound(S as sound)
	set category = "Fun"
	set name = "Play Local Sound"
	if(!check_rights(R_SOUNDS))	return

	log_admin("[key_name(src)] played a local sound [S]")
	message_admins("[key_name_admin(src)] played a local sound [S]", 1)
	playsound(get_turf(src.mob), S, 50, 0, 0)
	feedback_add_details("admin_verb","PLS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/stop_sounds()
	set category = "Debug"
	set name = "Stop Sounds"
	if((check_rights(R_SOUNDS)) || (check_rights(R_DEBUG)))

		log_admin("[key_name(src)] stopped all currently playing sounds.")
		message_admins("[key_name_admin(src)] stopped all currently playing sounds.")
		for(var/mob/M in player_list)
			if(M.client)
				M << sound(null)
		feedback_add_details("admin_verb","SS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	else
		return
#undef SOUND_CHANNEL_ADMIN