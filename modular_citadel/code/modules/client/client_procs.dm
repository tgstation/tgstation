/client/New()
	. = ..()
	mentor_datum_set()

/client/proc/citadel_client_procs(href_list)
	if(href_list["mentor_msg"])
		if(CONFIG_GET(flag/mentors_mobname_only))
			var/mob/M = locate(href_list["mentor_msg"])
			cmd_mentor_pm(M,null)
		else
			cmd_mentor_pm(href_list["mentor_msg"],null)
		return TRUE

	//Mentor Follow
	if(href_list["mentor_follow"])
		var/mob/living/M = locate(href_list["mentor_follow"])

		if(istype(M))
			mentor_follow(M)
		return TRUE

/client/proc/mentor_datum_set(admin)
	mentor_datum = GLOB.mentor_datums[ckey]
	if(!mentor_datum && check_rights_for(src, R_ADMIN,0)) // admin with no mentor datum?let's fix that
		new /datum/mentors(ckey)
	if(mentor_datum)
		if(!check_rights_for(src, R_ADMIN,0) && !admin)
			GLOB.mentors |= src // don't add admins to this list too.
		mentor_datum.owner = src
		add_mentor_verbs()
		mentor_memo_output("Show")

/client/proc/is_mentor() // admins are mentors too.
	if(mentor_datum || check_rights_for(src, R_ADMIN,0))
		return TRUE

/client/verb/togglerightclickstuff()
	set category = "OOC"
	set name = "Toggle Rightclick"
	set desc = "Did the context menu get stuck on or off? Press this button."

	show_popup_menus = !show_popup_menus
	to_chat(src, "<span class='notice'>The right-click context menu is now [show_popup_menus ? "enabled" : "disabled"].</span>")
