//Happy April Fools. We're grabbing this as an admin secret.

/proc/call_emergency_meeting(mob/user)
	var/area/meeting_area = get_area(user)
	var/meeting_sound = sound('monkestation/sound/misc/sound_misc_emergency_meeting.ogg')
	var/announcement
	announcement += "<h1 class='alert'>Station Alert</h1>"
	announcement += "<br><span class='alert'>[user] has called an Emergency Meeting!<br><br>"

	deadchat_broadcast("[user] called an emergency meeting from <span class='name'>[get_area_name(usr, TRUE)]</span>.", user)

	for(var/mob/mob_to_teleport in GLOB.player_list) //gotta make sure the whole crew's here!
		if(isnewplayer(mob_to_teleport) || iscameramob(mob_to_teleport))
			continue
		to_chat(mob_to_teleport, announcement)
		SEND_SOUND(mob_to_teleport, meeting_sound) //no preferences here, you must hear the funny sound
		mob_to_teleport.overlay_fullscreen("emergency_meeting", /atom/movable/screen/fullscreen/emergency_meeting, 1)
		addtimer(CALLBACK(mob_to_teleport, /mob/.proc/clear_fullscreen, "emergency_meeting"), 3 SECONDS)

		if (is_station_level(mob_to_teleport.z)) //teleport the mob to the crew meeting
			var/turf/target
			var/list/turf_list = get_area_turfs(meeting_area)
			while (!target && turf_list.len)
				target = pick_n_take(turf_list)
				if (isclosedturf(target))
					target = null
					continue
				mob_to_teleport.forceMove(target)
