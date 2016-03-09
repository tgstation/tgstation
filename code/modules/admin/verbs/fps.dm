//replaces the old Ticklag verb, fps is easier to understand
/client/proc/fps()
	set category = "Debug"
	set name = "Set fps"
	set desc = "Sets game speed in frames-per-second. Can potentially break the game"

	if(!check_rights(R_DEBUG))
		return

	var/fps = round(input("Sets game frames-per-second. Can potentially break the game","FPS", config.fps) as num|null)

	if(fps <= 0)
		src << "<span class='danger'>Error: ticklag(): Invalid world.ticklag value. No changes made.</span>"
		return
	if(fps > config.fps)
		if(alert(src, "You are setting fps to a high value:\n\t[fps] frames-per-second\n\tconfig.fps = [config.fps]","Warning!","Confirm","ABORT-ABORT-ABORT") != "Confirm")
			return

	var/msg = "[key_name(src)] has modified world.fps to [fps]"
	log_admin(msg, 0)
	message_admins(msg, 0)
	feedback_add_details("admin_verb","TICKLAG") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	world.fps = fps