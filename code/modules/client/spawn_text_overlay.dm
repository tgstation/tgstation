/// Displays a typewriter-style spawn text overlay that includes station/area/job name and time
/client/proc/show_spawn_text_overlay(duration = 5 SECONDS)
	set waitfor = FALSE

	var/mob_name = mob.name
	var/job_title = mob.mind?.assigned_role.title || "Unknown"

	var/station_name = station_name()
	var/area_name = get_area_name(mob, format_text = TRUE) || "Unknown Location"
	var/time_date = server_timestamp(format = "YYYY-MM-DD hh:mm:ss", ic_time = TRUE)

	var/text = {"
		[mob_name] - [job_title]
		[station_name]
		[area_name]
		[time_date]
	"}
	text = uppertext(text)

	var/atom/movable/screen/spawn_text = new()
	spawn_text.maptext_height = 64
	spawn_text.maptext_width = 512
	spawn_text.layer = FLY_LAYER
	spawn_text.plane = FULLSCREEN_PLANE
	spawn_text.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	spawn_text.screen_loc = "LEFT+1,TOP-3"

	screen += spawn_text
	animate(spawn_text, alpha = 255, time = 1 SECONDS)

	for(var/i in 1 to length_char(text) + 1)
		if(QDELETED(spawn_text) || QDELETED(src))
			return
		spawn_text.maptext = MAPTEXT_PIXELLARI(copytext_char(text, 1, i))
		sleep(1)

	addtimer(CALLBACK(src, PROC_REF(fade_spawn_text_overlay), src, spawn_text), duration)

/client/proc/fade_spawn_text_overlay(client/player_client, atom/movable/screen/spawn_text)
	if(QDELETED(spawn_text))
		return
	animate(spawn_text, alpha = 0, time = 0.5 SECONDS)
	sleep(5)
	if(player_client && !QDELETED(spawn_text))
		player_client.screen -= spawn_text
	qdel(spawn_text)
