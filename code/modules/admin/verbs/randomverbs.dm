/client/proc/cmd_admin_drop_everything(mob/M in mob_list)
	set category = null
	set name = "Drop Everything"
	if(!holder)
		src << "Only administrators may use this command."
		return

	var/confirm = alert(src, "Make [M] drop everything?", "Message", "Yes", "No")
	if(confirm != "Yes")
		return

	for(var/obj/item/W in M)
		if(!M.unEquip(W))
			qdel(W)
			M.regenerate_icons()

	log_admin("[key_name(usr)] made [key_name(M)] drop everything!")
	message_admins("[key_name_admin(usr)] made [key_name_admin(M)] drop everything!")
	feedback_add_details("admin_verb","DEVR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_admin_subtle_message(mob/M in mob_list)
	set category = "Special Verbs"
	set name = "Subtle Message"

	if(!ismob(M))
		return
	if (!holder)
		src << "Only administrators may use this command."
		return

	message_admins("[key_name_admin(src)] has started answering [key_name(M.key, 0, 0)]'s prayer.")
	var/msg = input("Message:", text("Subtle PM to [M.key]")) as text

	if (!msg)
		message_admins("[key_name_admin(src)] decided not to answer [key_name(M.key, 0, 0)]'s prayer")
		return
	if(usr)
		if (usr.client)
			if(usr.client.holder)
				M << "<i>You hear a voice in your head... <b>[msg]</i></b>"

	log_admin("SubtlePM: [key_name(usr)] -> [key_name(M)] : [msg]")
	message_admins("<span class='adminnotice'><b> SubtleMessage: [key_name_admin(usr)] -> [key_name_admin(M)] :</b> [msg]</span>")
	feedback_add_details("admin_verb","SMS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_world_narrate()
	set category = "Special Verbs"
	set name = "Global Narrate"

	if (!holder)
		src << "Only administrators may use this command."
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to everyone:")) as text

	if (!msg)
		return
	world << "[msg]"
	log_admin("GlobalNarrate: [key_name(usr)] : [msg]")
	message_admins("<span class='adminnotice'><b> GlobalNarrate: [key_name_admin(usr)] :</b> [msg]<BR></span>")
	feedback_add_details("admin_verb","GLN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_direct_narrate(mob/M)
	set category = "Special Verbs"
	set name = "Direct Narrate"

	if(!holder)
		src << "Only administrators may use this command."
		return

	if(!M)
		M = input("Direct narrate to who?", "Active Players") as null|anything in player_list

	if(!M)
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to your target:")) as text

	if( !msg )
		return

	M << msg
	log_admin("DirectNarrate: [key_name(usr)] to ([M.name]/[M.key]): [msg]")
	message_admins("<span class='adminnotice'><b> DirectNarrate: [key_name(usr)] to ([M.name]/[M.key]):</b> [msg]<BR></span>")
	feedback_add_details("admin_verb","DIRN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_local_narrate(atom/A)
	set category = "Special Verbs"
	set name = "Local Narrate"

	if (!holder)
		src << "Only administrators may use this command."
		return
	if(!A)
		return
	var/range = input("Range:", "Narrate to mobs within how many tiles:", 7) as num
	if(!range)
		return
	var/msg = input("Message:", text("Enter the text you wish to appear to everyone within view:")) as text
	if (!msg)
		return
	for(var/mob/M in view(range,A))
		M << msg

	log_admin("LocalNarrate: [key_name(usr)] at ([get_area(A)]): [msg]")
	message_admins("<span class='adminnotice'><b> LocalNarrate: [key_name_admin(usr)] at (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[A.x];Y=[A.y];Z=[A.z]'>[get_area(A)]</a>):</b> [msg]<BR></span>")
	feedback_add_details("admin_verb","LN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_godmode(mob/M in mob_list)
	set category = "Special Verbs"
	set name = "Godmode"
	if(!holder)
		src << "Only administrators may use this command."
		return
	M.status_flags ^= GODMODE
	usr << "<span class='adminnotice'>Toggled [(M.status_flags & GODMODE) ? "ON" : "OFF"]</span>"

	log_admin("[key_name(usr)] has toggled [key_name(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]")
	message_admins("[key_name_admin(usr)] has toggled [key_name_admin(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]")
	feedback_add_details("admin_verb","GOD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/proc/cmd_admin_mute(whom, mute_type, automute = 0)
	if(!whom)
		return

	var/muteunmute
	var/mute_string
	switch(mute_type)
		if(MUTE_IC)
			mute_string = "IC (say and emote)"
		if(MUTE_OOC)
			mute_string = "OOC"
		if(MUTE_PRAY)
			mute_string = "pray"
		if(MUTE_ADMINHELP)
			mute_string = "adminhelp, admin PM and ASAY"
		if(MUTE_DEADCHAT)
			mute_string = "deadchat and DSAY"
		if(MUTE_ALL)
			mute_string = "everything"
		else
			return

	var/client/C
	if(istype(whom, /client))
		C = whom
	else if(istext(whom))
		C = directory[whom]
	else
		return

	var/datum/preferences/P
	if(C)
		P = C.prefs
	else
		P = preferences_datums[whom]
	if(!P)
		return

	if(automute)
		if(!config.automute_on)
			return
	else
		if(!check_rights())
			return

	if(automute)
		muteunmute = "auto-muted"
		P.muted |= mute_type
		log_admin("SPAM AUTOMUTE: [muteunmute] [key_name(whom)] from [mute_string]")
		message_admins("SPAM AUTOMUTE: [muteunmute] [key_name_admin(whom)] from [mute_string].")
		if(C)
			C << "You have been [muteunmute] from [mute_string] by the SPAM AUTOMUTE system. Contact an admin."
		feedback_add_details("admin_verb","AUTOMUTE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return

	if(P.muted & mute_type)
		muteunmute = "unmuted"
		P.muted &= ~mute_type
	else
		muteunmute = "muted"
		P.muted |= mute_type

	log_admin("[key_name(usr)] has [muteunmute] [key_name(whom)] from [mute_string]")
	message_admins("[key_name_admin(usr)] has [muteunmute] [key_name_admin(whom)] from [mute_string].")
	if(C)
		C << "You have been [muteunmute] from [mute_string] by [key_name(usr, include_name = FALSE)]."
	feedback_add_details("admin_verb","MUTE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_admin_add_random_ai_law()
	set category = "Fun"
	set name = "Add Random AI Law"
	if(!holder)
		src << "Only administrators may use this command."
		return
	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes")
		return
	log_admin("[key_name(src)] has added a random AI law.")
	message_admins("[key_name_admin(src)] has added a random AI law.")

	var/show_log = alert(src, "Show ion message?", "Message", "Yes", "No")
	var/announce_ion_laws = (show_log == "Yes" ? 1 : -1)

	new /datum/round_event/ion_storm(0, announce_ion_laws)
	feedback_add_details("admin_verb","ION") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


//I use this proc for respawn character too. /N
/proc/create_xeno(ckey)
	if(!ckey)
		var/list/candidates = list()
		for(var/mob/M in player_list)
			if(M.stat != DEAD)
				continue	//we are not dead!
			if(!(ROLE_ALIEN in M.client.prefs.be_special))
				continue	//we don't want to be an alium
			if(M.client.is_afk())
				continue	//we are afk
			if(M.mind && M.mind.current && M.mind.current.stat != DEAD)
				continue	//we have a live body we are tied to
			candidates += M.ckey
		if(candidates.len)
			ckey = input("Pick the player you want to respawn as a xeno.", "Suitable Candidates") as null|anything in candidates
		else
			usr << "<font color='red'>Error: create_xeno(): no suitable candidates.</font>"
	if(!istext(ckey))
		return 0

	var/alien_caste = input(usr, "Please choose which caste to spawn.","Pick a caste",null) as null|anything in list("Queen","Praetorian","Hunter","Sentinel","Drone","Larva")
	var/obj/effect/landmark/spawn_here = xeno_spawn.len ? pick(xeno_spawn) : pick(latejoin)
	var/mob/living/carbon/alien/new_xeno
	switch(alien_caste)
		if("Queen")
			new_xeno = new /mob/living/carbon/alien/humanoid/royal/queen(spawn_here)
		if("Praetorian")
			new_xeno = new /mob/living/carbon/alien/humanoid/royal/praetorian(spawn_here)
		if("Hunter")
			new_xeno = new /mob/living/carbon/alien/humanoid/hunter(spawn_here)
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(spawn_here)
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/humanoid/drone(spawn_here)
		if("Larva")
			new_xeno = new /mob/living/carbon/alien/larva(spawn_here)
		else
			return 0

	new_xeno.ckey = ckey
	message_admins("<span class='notice'>[key_name_admin(usr)] has spawned [ckey] as a filthy xeno [alien_caste].</span>")
	return 1

/*
If a guy was gibbed and you want to revive him, this is a good way to do so.
Works kind of like entering the game with a new character. Character receives a new mind if they didn't have one.
Traitors and the like can also be revived with the previous role mostly intact.
/N */
/client/proc/respawn_character()
	set category = "Special Verbs"
	set name = "Respawn Character"
	set desc = "Respawn a person that has been gibbed/dusted/killed. They must be a ghost for this to work and preferably should not have a body to go back into."
	if(!holder)
		src << "Only administrators may use this command."
		return
	return // TODO BLAH BLAH BLAH


/client/proc/cmd_admin_add_freeform_ai_law()
	set category = "Fun"
	set name = "Add Custom AI law"
	if(!holder)
		src << "Only administrators may use this command."
		return
	var/input = input(usr, "Please enter anything you want the AI to do. Anything. Serious.", "What?", "") as text|null
	if(!input)
		return

	log_admin("Admin [key_name(usr)] has added a new AI law - [input]")
	message_admins("Admin [key_name_admin(usr)] has added a new AI law - [input]")

	var/show_log = alert(src, "Show ion message?", "Message", "Yes", "No")
	var/announce_ion_laws = (show_log == "Yes" ? 1 : -1)

	new /datum/round_event/ion_storm(0, announce_ion_laws, input)

	feedback_add_details("admin_verb","IONC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_rejuvenate(mob/living/M in mob_list)
	set category = "Special Verbs"
	set name = "Rejuvenate"
	if(!holder)
		src << "Only administrators may use this command."
		return
	if(!mob)
		return
	if(!istype(M))
		alert("Cannot revive a ghost")
		return
	M.revive(full_heal = 1, admin_revive = 1)

	log_admin("[key_name(usr)] healed / revived [key_name(M)]")
	message_admins("<span class='danger'>Admin [key_name_admin(usr)] healed / revived [key_name_admin(M)]!</span>")
	feedback_add_details("admin_verb","REJU") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_create_centcom_report()
	set category = "Special Verbs"
	set name = "Create Command Report"
	if(!holder)
		src << "Only administrators may use this command."
		return
	var/input = input(usr, "Please enter anything you want. Anything. Serious.", "What?", "") as message|null
	if(!input)
		return

	var/confirm = alert(src, "Do you want to announce the contents of the report to the crew?", "Announce", "Yes", "No")
	if(confirm == "Yes")
		priority_announce(input, null, 'sound/AI/commandreport.ogg')
	else
		priority_announce("A report has been downloaded and printed out at all communications consoles.", "Incoming Classified Message", 'sound/AI/commandreport.ogg')

	print_command_report(input,"[confirm=="Yes" ? "" : "Classified "][command_name()] Update")

	log_admin("[key_name(src)] has created a command report: [input]")
	message_admins("[key_name_admin(src)] has created a command report")
	feedback_add_details("admin_verb","CCR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_change_command_name()
	set category = "Special Verbs"
	set name = "Change Command Name"
	if(!holder)
		src << "Only administrators may use this command."
		return
	var/input = input(usr, "Please input a new name for Central Command.", "What?", "") as text|null
	if(!input)
		return
	change_command_name(input)
	message_admins("[key_name_admin(src)] has changed Central Command's name to [input]")
	log_admin("[key_name(src)] has changed the Central Command name to: [input]")

/client/proc/cmd_admin_delete(atom/O as obj|mob|turf in world)
	set category = "Admin"
	set name = "Delete"

	if (!holder)
		src << "Only administrators may use this command."
		return

	if (alert(src, "Are you sure you want to delete:\n[O]\nat ([O.x], [O.y], [O.z])?", "Confirmation", "Yes", "No") == "Yes")
		log_admin("[key_name(usr)] deleted [O] at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] deleted [O] at ([O.x],[O.y],[O.z])")
		feedback_add_details("admin_verb","DEL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		qdel(O)

/client/proc/cmd_admin_list_open_jobs()
	set category = "Admin"
	set name = "Manage Job Slots"

	if (!holder)
		src << "Only administrators may use this command."
		return
	holder.manage_free_slots()
	feedback_add_details("admin_verb","MFS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_explosion(atom/O as obj|mob|turf in world)
	set category = "Special Verbs"
	set name = "Explosion"

	if (!holder)
		src << "Only administrators may use this command."
		return

	var/devastation = input("Range of total devastation. -1 to none", text("Input"))  as num|null
	if(devastation == null) return
	var/heavy = input("Range of heavy impact. -1 to none", text("Input"))  as num|null
	if(heavy == null) return
	var/light = input("Range of light impact. -1 to none", text("Input"))  as num|null
	if(light == null) return
	var/flash = input("Range of flash. -1 to none", text("Input"))  as num|null
	if(flash == null) return
	var/flames = input("Range of flames. -1 to none", text("Input"))  as num|null
	if(flames == null) return

	if ((devastation != -1) || (heavy != -1) || (light != -1) || (flash != -1) || (flames != -1))
		if ((devastation > 20) || (heavy > 20) || (light > 20) || (flames > 20))
			if (alert(src, "Are you sure you want to do this? It will laaag.", "Confirmation", "Yes", "No") == "No")
				return

		explosion(O, devastation, heavy, light, flash, null, null,flames)
		log_admin("[key_name(usr)] created an explosion ([devastation],[heavy],[light],[flames]) at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] created an explosion ([devastation],[heavy],[light],[flames]) at ([O.x],[O.y],[O.z])")
		feedback_add_details("admin_verb","EXPL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return
	else
		return

/client/proc/cmd_admin_emp(atom/O as obj|mob|turf in world)
	set category = "Special Verbs"
	set name = "EM Pulse"

	if (!holder)
		src << "Only administrators may use this command."
		return

	var/heavy = input("Range of heavy pulse.", text("Input"))  as num|null
	if(heavy == null) return
	var/light = input("Range of light pulse.", text("Input"))  as num|null
	if(light == null) return

	if (heavy || light)

		empulse(O, heavy, light)
		log_admin("[key_name(usr)] created an EM Pulse ([heavy],[light]) at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] created an EM PUlse ([heavy],[light]) at ([O.x],[O.y],[O.z])")
		feedback_add_details("admin_verb","EMP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

		return
	else
		return

/client/proc/cmd_admin_gib(mob/M in mob_list)
	set category = "Special Verbs"
	set name = "Gib"

	if (!holder)
		src << "Only administrators may use this command."
		return

	var/confirm = alert(src, "Drop a brain?", "Confirm", "Yes", "No","Cancel")
	if(confirm == "Cancel")
		return
	//Due to the delay here its easy for something to have happened to the mob
	if(!M)
		return

	log_admin("[key_name(usr)] has gibbed [key_name(M)]")
	message_admins("[key_name_admin(usr)] has gibbed [key_name_admin(M)]")

	if(istype(M, /mob/dead/observer))
		gibs(M.loc, M.viruses)
		return
	if(confirm == "Yes")
		M.gib()
	else
		M.gib(1)
	feedback_add_details("admin_verb","GIB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_gib_self()
	set name = "Gibself"
	set category = "Fun"

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm == "Yes")
		log_admin("[key_name(usr)] used gibself.")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] used gibself.</span>")
		feedback_add_details("admin_verb","GIBS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		mob.gib(1, 1)

/client/proc/cmd_admin_check_contents(mob/living/M in mob_list)
	set category = "Special Verbs"
	set name = "Check Contents"

	var/list/L = M.get_contents()
	for(var/t in L)
		usr << "[t]"
	feedback_add_details("admin_verb","CC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_view_range()
	set category = "Special Verbs"
	set name = "Change View Range"
	set desc = "switches between 1x and custom views"

	if(view == world.view)
		view = input("Select view range:", "FUCK YE", 7) in list(1,2,3,4,5,6,7,8,9,10,11,12,13,14,128)
	else
		view = world.view

	log_admin("[key_name(usr)] changed their view range to [view].")
	//message_admins("\blue [key_name_admin(usr)] changed their view range to [view].")	//why? removed by order of XSI

	feedback_add_details("admin_verb","CVRA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/admin_call_shuttle()

	set category = "Admin"
	set name = "Call Shuttle"

	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	if (!holder)
		src << "Only administrators may use this command."
		return

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes")
		return

	SSshuttle.emergency.request()
	feedback_add_details("admin_verb","CSHUT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-called the emergency shuttle.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] admin-called the emergency shuttle.</span>")
	return

/client/proc/admin_cancel_shuttle()
	set category = "Admin"
	set name = "Cancel Shuttle"
	if(!check_rights(0))
		return
	if(alert(src, "You sure?", "Confirm", "Yes", "No") != "Yes")
		return

	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	SSshuttle.emergency.cancel()
	feedback_add_details("admin_verb","CCSHUT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-recalled the emergency shuttle.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] admin-recalled the emergency shuttle.</span>")

	return

/client/proc/cmd_admin_attack_log(mob/M in mob_list)
	set category = "Special Verbs"
	set name = "Attack Log"

	usr << "<span class='boldannounce'>Attack Log for [mob]</span>"
	for(var/t in M.attack_log)
		usr << t
	feedback_add_details("admin_verb","ATTL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/everyone_random()
	set category = "Fun"
	set name = "Make Everyone Random"
	set desc = "Make everyone have a random appearance. You can only use this before rounds!"

	if(ticker && ticker.mode)
		usr << "Nope you can't do this, the game's already started. This only works before rounds!"
		return

	if(config.force_random_names)
		config.force_random_names = 0
		message_admins("Admin [key_name_admin(usr)] has disabled \"Everyone is Special\" mode.")
		usr << "Disabled."
		return


	var/notifyplayers = alert(src, "Do you want to notify the players?", "Options", "Yes", "No", "Cancel")
	if(notifyplayers == "Cancel")
		return

	log_admin("Admin [key_name(src)] has forced the players to have random appearances.")
	message_admins("Admin [key_name_admin(usr)] has forced the players to have random appearances.")

	if(notifyplayers == "Yes")
		world << "<span class='adminnotice'>Admin [usr.key] has forced the players to have completely random identities!</span>"

	usr << "<i>Remember: you can always disable the randomness by using the verb again, assuming the round hasn't started yet</i>."

	config.force_random_names = 1
	feedback_add_details("admin_verb","MER") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/toggle_random_events()
	set category = "Server"
	set name = "Toggle random events on/off"
	set desc = "Toggles random events such as meteors, black holes, blob (but not space dust) on/off"
	if(!config.allow_random_events)
		config.allow_random_events = 1
		usr << "Random events enabled"
		message_admins("Admin [key_name_admin(usr)] has enabled random events.")
	else
		config.allow_random_events = 0
		usr << "Random events disabled"
		message_admins("Admin [key_name_admin(usr)] has disabled random events.")
	feedback_add_details("admin_verb","TRE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/admin_change_sec_level()
	set category = "Special Verbs"
	set name = "Set Security Level"
	set desc = "Changes the security level. Announcement only, i.e. setting to Delta won't activate nuke"

	if (!holder)
		src << "Only administrators may use this command."
		return

	var/level = input("Select security level to change to","Set Security Level") as null|anything in list("green","blue","red","delta")
	if(level)
		set_security_level(level)

		log_admin("[key_name(usr)] changed the security level to [level]")
		message_admins("[key_name_admin(usr)] changed the security level to [level]")
		feedback_add_details("admin_verb","CSL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_nuke(obj/machinery/nuclearbomb/N in nuke_list)
	set name = "Toggle Nuke"
	set category = "Fun"
	set popup_menu = 0
	if(!check_rights(R_DEBUG))
		return

	if(!N.timing)
		var/newtime = input(usr, "Set activation timer.", "Activate Nuke", "[N.timeleft]") as num
		if(!newtime)
			return
		N.timeleft = newtime
	N.set_safety()
	N.set_active()

	log_admin("[key_name(usr)] [N.timing ? "activated" : "deactivated"] a nuke at ([N.x],[N.y],[N.z]).")
	message_admins("[key_name_admin(usr)] (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[usr]'>FLW</A>) [N.timing ? "activated" : "deactivated"] a nuke at ([N.x],[N.y],[N.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[N.x];Y=[N.y];Z=[N.z]'>JMP</a>).")
	feedback_add_details("admin_verb","TN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/reset_latejoin_spawns()
	set category = "Debug"
	set name = "Remove Latejoin Spawns"

	if(!check_rights(R_DEBUG))
		return

	latejoin.Cut()

	log_admin("[key_name(usr)] removed latejoin spawnpoints.")
	message_admins("[key_name_admin(usr)] removed latejoin spawnpoints.")




var/list/datum/outfit/custom_outfits = list() //Admin created outfits

/client/proc/create_outfits()
	set category = "Debug"
	set name = "Create Custom Outfit"

	if(!check_rights(R_DEBUG))
		return

	holder.create_outfit()

/datum/admins/proc/create_outfit()
	var/list/uniforms = typesof(/obj/item/clothing/under)
	var/list/suits = typesof(/obj/item/clothing/suit)
	var/list/gloves = typesof(/obj/item/clothing/gloves)
	var/list/shoes = typesof(/obj/item/clothing/shoes)
	var/list/headwear = typesof(/obj/item/clothing/head)
	var/list/glasses = typesof(/obj/item/clothing/glasses)
	var/list/masks = typesof(/obj/item/clothing/mask)
	var/list/ids = typesof(/obj/item/weapon/card/id)

	var/uniform_select = "<select name=\"outfit_uniform\"><option value=\"\">None</option>"
	for(var/path in uniforms)
		uniform_select += "<option value=\"[path]\">[path]</option>"
	uniform_select += "</select>"

	var/suit_select = "<select name=\"outfit_suit\"><option value=\"\">None</option>"
	for(var/path in suits)
		suit_select += "<option value=\"[path]\">[path]</option>"
	suit_select += "</select>"

	var/gloves_select = "<select name=\"outfit_gloves\"><option value=\"\">None</option>"
	for(var/path in gloves)
		gloves_select += "<option value=\"[path]\">[path]</option>"
	gloves_select += "</select>"

	var/shoes_select = "<select name=\"outfit_shoes\"><option value=\"\">None</option>"
	for(var/path in shoes)
		shoes_select += "<option value=\"[path]\">[path]</option>"
	shoes_select += "</select>"

	var/head_select = "<select name=\"outfit_head\"><option value=\"\">None</option>"
	for(var/path in headwear)
		head_select += "<option value=\"[path]\">[path]</option>"
	head_select += "</select>"

	var/glasses_select = "<select name=\"outfit_glasses\"><option value=\"\">None</option>"
	for(var/path in glasses)
		glasses_select += "<option value=\"[path]\">[path]</option>"
	glasses_select += "</select>"

	var/mask_select = "<select name=\"outfit_mask\"><option value=\"\">None</option>"
	for(var/path in masks)
		mask_select += "<option value=\"[path]\">[path]</option>"
	mask_select += "</select>"

	var/id_select = "<select name=\"outfit_id\"><option value=\"\">None</option>"
	for(var/path in ids)
		id_select += "<option value=\"[path]\">[path]</option>"
	id_select += "</select>"

	var/dat = {"
	<html><head><title>Create Outfit</title></head><body>
	<form name="outfit" action="byond://?src=\ref[src]" method="get">
	<input type="hidden" name="src" value="\ref[src]">
	<input type="hidden" name="create_outfit" value="1">
	<table>
		<tr>
			<th>Name:</th>
			<td>
				<input type="text" name="outfit_name" value="Custom Outfit">
			</td>
		</tr>
		<tr>
			<th>Uniform:</th>
			<td>
			   [uniform_select]
			</td>
		</tr>
		<tr>
			<th>Suit:</th>
			<td>
				[suit_select]
			</td>
		</tr>
		<tr>
			<th>Back:</th>
			<td>
				<input type="text" name="outfit_back" value="">
			</td>
		</tr>
		<tr>
			<th>Belt:</th>
			<td>
				<input type="text" name="outfit_belt" value="">
			</td>
		</tr>
		<tr>
			<th>Gloves:</th>
			<td>
				[gloves_select]
			</td>
		</tr>
		<tr>
			<th>Shoes:</th>
			<td>
				[shoes_select]
			</td>
		</tr>
		<tr>
			<th>Head:</th>
			<td>
				[head_select]
			</td>
		</tr>
		<tr>
			<th>Mask:</th>
			<td>
				[mask_select]
			</td>
		</tr>
		<tr>
			<th>Ears:</th>
			<td>
				<input type="text" name="outfit_ears" value="">
			</td>
		</tr>
		<tr>
			<th>Glasses:</th>
			<td>
				[glasses_select]
			</td>
		</tr>
		<tr>
			<th>ID:</th>
			<td>
				[id_select]
			</td>
		</tr>
		<tr>
			<th>Left Pocket:</th>
			<td>
				<input type="text" name="outfit_l_pocket" value="">
			</td>
		</tr>
		<tr>
			<th>Right Pocket:</th>
			<td>
				<input type="text" name="outfit_r_pocket" value="">
			</td>
		</tr>
		<tr>
			<th>Suit Store:</th>
			<td>
				<input type="text" name="outfit_s_store" value="">
			</td>
		</tr>
		<tr>
			<th>Right Hand:</th>
			<td>
				<input type="text" name="outfit_r_hand" value="">
			</td>
		</tr>
		<tr>
			<th>Left Hand:</th>
			<td>
				<input type="text" name="outfit_l_hand" value="">
			</td>
		</tr>
	</table>
	<br>
	<input type="submit" value="Save">
	</form></body></html>
	"}
	usr << browse(dat, "window=dressup;size=550x600")

/client/proc/toggle_antag_hud()
	set category = "Admin"
	set name = "Toggle AntagHUD"
	set desc = "Toggles the Admin AntagHUD"

	if(!holder) return

	var/datum/atom_hud/A = huds[ANTAG_HUD_TRAITOR]
	var/adding_hud = (usr in A.hudusers) ? 0 : 1

	for(var/datum/atom_hud/H in huds)
		if(istype(H, /datum/atom_hud/antag))
			(adding_hud) ? H.add_hud_to(usr) : H.remove_hud_from(usr)

	for(var/datum/gang/G in ticker.mode.gangs)
		var/datum/atom_hud/antag/H = G.ganghud
		(adding_hud) ? H.add_hud_to(usr) : H.remove_hud_from(usr)

	usr << "You toggled your admin antag HUD [adding_hud ? "ON" : "OFF"]."
	message_admins("[key_name_admin(usr)] toggled their admin antag HUD [adding_hud ? "ON" : "OFF"].")
	log_admin("[key_name(usr)] toggled their admin antag HUD [adding_hud ? "ON" : "OFF"].")
	feedback_add_details("admin_verb","TAH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/open_shuttle_manipulator()
	set category = "Admin"
	set name = "Shuttle Manipulator"
	set desc = "Opens the shuttle manipulator UI."

	for(var/obj/machinery/shuttle_manipulator/M in machines)
		M.ui_interact(usr)
