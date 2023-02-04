//replaces the old Ticklag verb, fps is easier to understand
ADMIN_VERB(debug, set_server_fps, "Set Server FPS", "Sets game speed in frames-per-second. Will break the game, but that's why it's fun!", R_DEBUG)
	var/cfg_fps = CONFIG_GET(number/fps)
	var/new_fps = round(input("Sets game frames-per-second. Can potentially break the game (default: [cfg_fps])","FPS", world.fps) as num|null)

	if(new_fps <= 0)
		to_chat(usr, span_danger("Error: set_server_fps(): Invalid world.fps value. No changes made."), confidential = TRUE)
		return
	if(new_fps > cfg_fps * 1.5)
		if(tgui_alert(usr, "You are setting fps to a high value:\n\t[new_fps] frames-per-second\n\tconfig.fps = [cfg_fps]","Warning!",list("Confirm","ABORT-ABORT-ABORT")) != "Confirm")
			return

	var/msg = "[key_name(usr)] has modified world.fps to [new_fps]"
	log_admin(msg, 0)
	message_admins(msg, 0)
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Set Server FPS", "[new_fps]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	CONFIG_SET(number/fps, new_fps)
	world.change_fps(new_fps)
