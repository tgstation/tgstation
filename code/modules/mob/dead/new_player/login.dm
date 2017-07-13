/mob/dead/new_player/Login()
	if(!mind)
		mind = new /datum/mind(key)
		mind.active = 1
		mind.current = src

	..()

	if(GLOB.join_motd)
		to_chat(src, "<div class=\"motd\">[GLOB.join_motd]</div>")

	if(GLOB.admin_notice)
		to_chat(src, "<span class='notice'><b>Admin Notice:</b>\n \t [GLOB.admin_notice]</span>")

	if(config.soft_popcap && living_player_count() >= config.soft_popcap)
		to_chat(src, "<span class='notice'><b>Server Notice:</b>\n \t [config.soft_popcap_message]</span>")

	sight |= SEE_TURFS

/*
	var/list/watch_locations = list()
	for(var/obj/effect/landmark/landmark in landmarks_list)
		if(landmark.tag == "landmark*new_player")
			watch_locations += landmark.loc

	if(watch_locations.len>0)
		loc = pick(watch_locations)
*/
	new_player_panel()
	client.playtitlemusic()
	if(SSticker.current_state < GAME_STATE_SETTING_UP)
		var/tl = round(SSticker.GetTimeLeft(), 1)/10
		var/postfix
		if(tl >= 0)
			postfix = "in about [tl] seconds"
		else
			postfix = "soon"
		to_chat(src, "Please set up your character and select \"Ready\". The game will start [postfix].")
