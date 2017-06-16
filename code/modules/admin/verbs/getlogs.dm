//This proc allows download of past server logs saved within the data/logs/ folder.
//It works similarly to show-server-log.
/client/proc/getserverlog()
	set name = ".getserverlog"
	set desc = "Fetch logfiles from data/logs"
	set category = null

	var/path = browse_files("data/logs/")
	if(!path)
		return

	if(file_spam_check())
		return

	message_admins("[key_name_admin(src)] accessed file: [path]")
	src << ftp(file(path))
	to_chat(src, "Attempting to send file, this may take a fair few minutes if the file is very large.")
	return


//Other log stuff put here for the sake of organisation

//Shows today's server log
/datum/admins/proc/view_txt_log()
	set category = "Admin"
	set name = "Show Server Log"
	set desc = "Shows server log for this round."

	if(fexists("[GLOB.world_game_log]"))
		src << ftp(GLOB.world_game_log)
	else
		to_chat(src, "<font color='red'>Server log not found, try using .getserverlog.</font>")
		return
	SSblackbox.add_details("admin_verb","Show Server Log") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

//Shows today's attack log
/datum/admins/proc/view_atk_log()
	set category = "Admin"
	set name = "Show Server Attack Log"
	set desc = "Shows server attack log for this round."

	if(fexists("[GLOB.world_attack_log]"))
		src << ftp(GLOB.world_attack_log)
	else
		to_chat(src, "<font color='red'>Server attack log not found, try using .getserverlog.</font>")
		return
	SSblackbox.add_details("admin_verb","Show Server Attack log") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return
