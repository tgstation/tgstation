/client/verb/ooc(msg as text)
	set name = "OOC" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set category = "OOC"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	if(!mob)
		return

	if(!holder)
		if(!GLOB.ooc_allowed)
			to_chat(src, "<span class='danger'>OOC is globally muted.</span>")
			return
		if(!GLOB.dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='danger'>OOC for dead mobs has been turned off.</span>")
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, "<span class='danger'>You cannot use OOC (muted).</span>")
			return
		if(jobban_isbanned(src.mob, "OOC"))
			to_chat(src, "<span class='danger'>You have been banned from OOC.</span>")
			return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	var/raw_msg = msg

	if(!msg)
		return

	msg = emoji_parse(msg)

	if((copytext(msg, 1, 2) in list(".",";",":","#")) || (findtext(lowertext(copytext(msg, 1, 5)), "say")))
		if(alert("Your message \"[raw_msg]\" looks like it was meant for in game communication, say it in OOC?", "Meant for OOC?", "No", "Yes") != "Yes")
			return

	if(!holder)
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in OOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
			return

	if(!(prefs.chat_toggles & CHAT_OOC))
		to_chat(src, "<span class='danger'>You have OOC muted.</span>")
		return


	log_talk(mob,"[key_name(src)] : [raw_msg]",LOGOOC)
	mob.log_message("[key]: [raw_msg]", INDIVIDUAL_OOC_LOG)

	var/keyname = key
	if(prefs.unlock_content)
		if(prefs.toggles & MEMBER_PUBLIC)
			keyname = "<font color='[prefs.ooccolor ? prefs.ooccolor : GLOB.normal_ooc_colour]'>[bicon(icon('icons/member_content.dmi', "blag"))][keyname]</font>"

	for(var/client/C in GLOB.clients)
		if(C.prefs.chat_toggles & CHAT_OOC)
			if(holder)
				if(!holder.fakekey || C.holder)
					if(check_rights_for(src, R_ADMIN))
						to_chat(C, "<span class='adminooc'>[config.allow_admin_ooccolor && prefs.ooccolor ? "<font color=[prefs.ooccolor]>" :"" ]<span class='prefix'>OOC:</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message'>[msg]</span></span></font>")
					else
						to_chat(C, "<span class='adminobserverooc'><span class='prefix'>OOC:</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message'>[msg]</span></span>")
				else
					to_chat(C, "<font color='[GLOB.normal_ooc_colour]'><span class='ooc'><span class='prefix'>OOC:</span> <EM>[holder.fakekey ? holder.fakekey : key]:</EM> <span class='message'>[msg]</span></span></font>")
			else if(!(key in C.prefs.ignoring))
				to_chat(C, "<font color='[GLOB.normal_ooc_colour]'><span class='ooc'><span class='prefix'>OOC:</span> <EM>[keyname]:</EM> <span class='message'>[msg]</span></span></font>")

/proc/toggle_ooc(toggle = null)
	if(toggle != null) //if we're specifically en/disabling ooc
		if(toggle != GLOB.ooc_allowed)
			GLOB.ooc_allowed = toggle
		else
			return
	else //otherwise just toggle it
		GLOB.ooc_allowed = !GLOB.ooc_allowed
	to_chat(world, "<B>The OOC channel has been globally [GLOB.ooc_allowed ? "enabled" : "disabled"].</B>")

GLOBAL_VAR_INIT(normal_ooc_colour, OOC_COLOR)

/client/proc/set_ooc(newColor as color)
	set name = "Set Player OOC Color"
	set desc = "Modifies player OOC Color"
	set category = "Fun"
	GLOB.normal_ooc_colour = sanitize_ooccolor(newColor)

/client/proc/reset_ooc()
	set name = "Reset Player OOC Color"
	set desc = "Returns player OOC Color to default"
	set category = "Fun"
	GLOB.normal_ooc_colour = OOC_COLOR

/client/verb/colorooc()
	set name = "Set Your OOC Color"
	set category = "Preferences"

	if(!holder || check_rights_for(src, R_ADMIN))
		if(!is_content_unlocked())
			return

	var/new_ooccolor = input(src, "Please select your OOC color.", "OOC color", prefs.ooccolor) as color|null
	if(new_ooccolor)
		prefs.ooccolor = sanitize_ooccolor(new_ooccolor)
		prefs.save_preferences()
	SSblackbox.add_details("admin_verb","Set OOC Color") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/verb/resetcolorooc()
	set name = "Reset Your OOC Color"
	set desc = "Returns your OOC Color to default"
	set category = "Preferences"

	if(!holder || check_rights_for(src, R_ADMIN))
		if(!is_content_unlocked())
			return

		prefs.ooccolor = initial(prefs.ooccolor)
		prefs.save_preferences()

//Checks admin notice
/client/verb/admin_notice()
	set name = "Adminnotice"
	set category = "Admin"
	set desc ="Check the admin notice if it has been set"

	if(GLOB.admin_notice)
		to_chat(src, "<span class='boldnotice'>Admin Notice:</span>\n \t [GLOB.admin_notice]")
	else
		to_chat(src, "<span class='notice'>There are no admin notices at the moment.</span>")

/client/verb/fix_chat()
	set name = "Fix chat"
	set category = "OOC"
	if (!chatOutput || !istype(chatOutput))
		var/action = alert(src, "Invalid Chat Output data found!\nRecreate data?", "Wot?", "Recreate Chat Output data", "Cancel")
		if (action != "Recreate Chat Output data")
			return
		chatOutput = new /datum/chatOutput(src)
		chatOutput.start()
		action = alert(src, "Goon chat reloading, wait a bit and tell me if it's fixed", "", "Fixed", "Nope")
		if (action == "Fixed")
			log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by re-creating the chatOutput datum")
		else
			chatOutput.load()
			action = alert(src, "How about now? (give it a moment (it may also try to load twice))", "", "Yes", "No")
			if (action == "Yes")
				log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by re-creating the chatOutput datum and forcing a load()")
			else
				action = alert(src, "Welp, I'm all out of ideas. Try closing byond and reconnecting.\nWe could also disable fancy chat and re-enable oldchat", "", "Thanks anyways", "Switch to old chat")
				if (action == "Switch to old chat")
					winset(src, "output", "is-visible=true;is-disabled=false")
					winset(src, "browseroutput", "is-visible=false")
				log_game("GOONCHAT: [key_name(src)] Failed to fix their goonchat window after recreating the chatOutput and forcing a load()")

	else if (chatOutput.loaded)
		var/action = alert(src, "ChatOutput seems to be loaded\nDo you want me to force a reload, wiping the chat log or just refresh the chat window because it broke/went away?", "Hmmm", "Force Reload", "Refresh", "Cancel")
		switch (action)
			if ("Force Reload")
				chatOutput.loaded = FALSE
				chatOutput.start() //this is likely to fail since it asks , but we should try it anyways so we know.
				action = alert(src, "Goon chat reloading, wait a bit and tell me if it's fixed", "", "Fixed", "Nope")
				if (action == "Fixed")
					log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by forcing a start()")
				else
					chatOutput.load()
					action = alert(src, "How about now? (give it a moment (it may also try to load twice))", "", "Yes", "No")
					if (action == "Yes")
						log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by forcing a load()")
					else
						action = alert(src, "Welp, I'm all out of ideas. Try closing byond and reconnecting.\nWe could also disable fancy chat and re-enable oldchat", "", "Thanks anyways", "Switch to old chat")
						if (action == "Switch to old chat")
							winset(src, "output", "is-visible=true;is-disabled=false")
							winset(src, "browseroutput", "is-visible=false")
						log_game("GOONCHAT: [key_name(src)] Failed to fix their goonchat window forcing a start() and forcing a load()")

			if ("Refresh")
				chatOutput.showChat()
				action = alert(src, "Goon chat refreshing, wait a bit and tell me if it's fixed", "", "Fixed", "Nope, force a reload")
				if (action == "Fixed")
					log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by forcing a show()")
				else
					chatOutput.loaded = FALSE
					chatOutput.load()
					action = alert(src, "How about now? (give it a moment)", "", "Yes", "No")
					if (action == "Yes")
						log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by forcing a load()")
					else
						action = alert(src, "Welp, I'm all out of ideas. Try closing byond and reconnecting.\nWe could also disable fancy chat and re-enable oldchat", "", "Thanks anyways", "Switch to old chat")
						if (action == "Switch to old chat")
							winset(src, "output", "is-visible=true;is-disabled=false")
							winset(src, "browseroutput", "is-visible=false")
						log_game("GOONCHAT: [key_name(src)] Failed to fix their goonchat window forcing a show() and forcing a load()")
		return

	else
		chatOutput.start()
		var/action = alert(src, "Manually loading Chat, wait a bit and tell me if it's fixed", "", "Fixed", "Nope")
		if (action == "Fixed")
			log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by manually calling start()")
		else
			chatOutput.load()
			alert(src, "How about now? (give it a moment (it may also try to load twice))", "", "Yes", "No")
			if (action == "Yes")
				log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by manually calling start() and forcing a load()")
			else
				action = alert(src, "Welp, I'm all out of ideas. Try closing byond and reconnecting.\nWe could also disable fancy chat and re-enable oldchat", "", "Thanks anyways", "Switch to old chat")
				if (action == "Switch to old chat")
					winset(src, "output", list2params(list("on-show" = "", "is-disabled" = "false", "is-visible" = "true")))
					winset(src, "browseroutput", "is-disabled=true;is-visible=false")
				log_game("GOONCHAT: [key_name(src)] Failed to fix their goonchat window after manually calling start() and forcing a load()")



/client/verb/motd()
	set name = "MOTD"
	set category = "OOC"
	set desc ="Check the Message of the Day"

	if(GLOB.join_motd)
		to_chat(src, "<div class=\"motd\">[GLOB.join_motd]</div>")
	else
		to_chat(src, "<span class='notice'>The Message of the Day has not been set.</span>")

/client/proc/self_notes()
	set name = "View Admin Remarks"
	set category = "OOC"
	set desc = "View the notes that admins have written about you"

	if(!config.see_own_notes)
		to_chat(usr, "<span class='notice'>Sorry, that function is not enabled on this server.</span>")
		return

	browse_messages(null, usr.ckey, null, 1)

/client/proc/ignore_key(client)
	var/client/C = client
	if(C.key in prefs.ignoring)
		prefs.ignoring -= C.key
	else
		prefs.ignoring |= C.key
	to_chat(src, "You are [(C.key in prefs.ignoring) ? "now" : "no longer"] ignoring [C.key] on the OOC channel.")
	prefs.save_preferences()

/client/verb/select_ignore()
	set name = "Ignore"
	set category = "OOC"
	set desc ="Ignore a player's messages on the OOC channel"

	var/selection = input("Please, select a player!", "Ignore", null, null) as null|anything in sortKey(GLOB.clients)
	if(!selection)
		return
	if(selection == src)
		to_chat(src, "You can't ignore yourself.")
		return
	ignore_key(selection)
