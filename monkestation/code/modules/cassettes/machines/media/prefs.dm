/// Whether or not to toggle ambient occlusion, the shadows around people
/datum/preference/toggle/hear_music
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "hearmusic"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = TRUE

/datum/preference/toggle/hear_music/apply_to_client(client/client, value)
	. = ..()
	if(istype(client, /datum/client_interface))
		return
	if(client.media)
		if(!value)
			var/area/A = get_area(client.mob)
			if(!A)
				return
			var/obj/machinery/media/M = A.media_source
			if(M && M.playing)
				client.media.stop_music()

		client.media.update_music()
