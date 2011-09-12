//GUYS REMEMBER TO ADD A += to UPDATE_ADMINS
//AND A -= TO CLEAR_ADMIN_VERBS



//Some verbs that are still in the code but not used atm
			// Debug
//			verbs += /client/proc/radio_report //for radio debugging dont think its been used in a very long time
//			verbs += /client/proc/fix_next_move //has not been an issue in a very very long time


			// Mapping helpers added via enable_mapping_debug verb
// 			verbs += /client/proc/do_not_use_these
// 			verbs += /client/proc/camera_view
// 			verbs += /client/proc/sec_camera_report
// 			verbs += /client/proc/intercom_view
//			verbs += /client/proc/air_status //Air things
//			verbs += /client/proc/Cell //More air things

/client/proc/update_admins(var/rank)

	if(!holder)
		holder = new /obj/admins(src)

	holder.rank = rank

	if(!holder.state)
		var/state = alert("Which state do you the admin to begin in?", "Admin-state", "Play", "Observe", "Neither")
		if(state == "Play")
			holder.state = 1
			admin_play()
			return
		else if(state == "Observe")
			holder.state = 2
			admin_observe()
			return
		else
			del(holder)
			return

	switch (rank)
		if ("Game Master")
			deadchat = 1
			seeprayers = 1
			holder.level = 6


		if ("Game Admin")
			deadchat = 1
			seeprayers = 1
			holder.level = 5


		if ("Badmin")
			deadchat = 1
			seeprayers = 1
			holder.level = 4


		if ("Trial Admin")
			deadchat = 1
			seeprayers = 1
			holder.level = 3

			if(holder.state == 2) // if observing
				// Debug
				verbs += /client/proc/debug_variables
				verbs += /client/proc/cmd_modify_object_variables
				verbs += /client/proc/cmd_modify_ticker_variables

				// Admin helpers
				verbs += /client/proc/toggle_view_range

				// Admin game intrusion
				verbs += /client/proc/Getmob
				verbs += /client/proc/sendmob
				verbs += /client/proc/Jump
				verbs += /client/proc/jumptokey
				verbs += /client/proc/jumptomob
				verbs += /client/proc/jumptoturf

				verbs += /client/proc/cmd_admin_add_freeform_ai_law
				verbs += /client/proc/cmd_admin_rejuvenate
				verbs += /client/proc/cmd_admin_drop_everything


		if ("Admin Candidate")
			holder.level = 2
			if(holder.state == 2) // if observing
				deadchat = 1
				// Settings
				verbs += /obj/admins/proc/toggleaban			//abandon mob
				verbs += /client/proc/deadchat					//toggles deadchat
				// Admin helpers
				verbs += /client/proc/cmd_admin_attack_log
				verbs += /client/proc/cmd_admin_check_contents
				// Admin game intrusion
				verbs += /client/proc/Jump
				verbs += /client/proc/jumptokey
				verbs += /client/proc/jumptomob


		if ("Temporary Admin")
			holder.level = 1


		if ("Moderator")
			holder.level = 0


		if ("Admin Observer")
			holder.level = -1


		if ("Banned")
			holder.level = -2
			del(src)
			return

		else
			del(holder)
			return

	if (holder)//Slightly easier to edit way of granting powers
		holder.owner = src
		if (holder.level >= 6)//Game Master********************************************************************
			verbs += /client/proc/callproc
			verbs += /client/proc/colorooc
			verbs += /obj/admins/proc/toggle_aliens			//toggle aliens
			verbs += /obj/admins/proc/toggle_space_ninja	//toggle ninjas
			verbs += /obj/admins/proc/adjump
			verbs += /client/proc/triple_ai
			verbs += /client/proc/get_admin_state
			verbs += /client/proc/reload_admins
			verbs += /client/proc/kill_air
			verbs += /client/proc/cmd_debug_make_powernets
			verbs += /client/proc/object_talk
			verbs += /client/proc/strike_team
			verbs += /client/proc/enable_mapping_debug

		if (holder.level >= 5)//Game Admin********************************************************************
			verbs += /obj/admins/proc/view_txt_log
			verbs += /client/proc/cmd_mass_modify_object_variables
			verbs += /client/proc/cmd_admin_list_open_jobs
			verbs += /client/proc/cmd_admin_direct_narrate
			verbs += /client/proc/cmd_admin_world_narrate
			verbs += /client/proc/cmd_debug_del_all
			verbs += /client/proc/cmd_debug_tog_aliens
			verbs += /client/proc/ticklag
			verbs += /obj/admins/proc/spawn_atom
			verbs += /client/proc/check_words
			verbs += /client/proc/drop_bomb
			verbs += /client/proc/give_spell
			verbs += /client/proc/cmd_admin_ninjafy
			verbs += /client/proc/cmd_admin_grantfullaccess
			verbs += /client/proc/cmd_admin_explosion
			verbs += /client/proc/cmd_admin_emp
			verbs += /client/proc/cmd_admin_drop_everything
			verbs += /client/proc/make_sound
			verbs += /client/proc/play_local_sound
			verbs += /client/proc/only_one
			verbs += /client/proc/send_space_ninja
			verbs += /client/proc/restartcontroller //Can call via aproccall --I_hate_easy_things.jpg, Mport --Agouri

		if (holder.level >= 4)//Badmin********************************************************************
			verbs += /obj/admins/proc/adrev					//toggle admin revives
			verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			verbs += /client/proc/debug_variables
			verbs += /client/proc/cmd_modify_object_variables
			verbs += /client/proc/cmd_modify_ticker_variables
			verbs += /client/proc/Debug2					//debug toggle switch
			verbs += /client/proc/toggle_view_range
			verbs += /client/proc/Getmob
			verbs += /client/proc/sendmob
			verbs += /client/proc/Jump
			verbs += /client/proc/jumptokey
			verbs += /client/proc/jumptomob
			verbs += /client/proc/jumptoturf
			verbs += /client/proc/cmd_admin_add_freeform_ai_law
			verbs += /client/proc/cmd_admin_add_random_ai_law
			verbs += /client/proc/cmd_admin_godmode
			verbs += /client/proc/cmd_admin_rejuvenate
			verbs += /client/proc/cmd_admin_gib
			verbs += /client/proc/cmd_admin_delete
			verbs += /proc/togglebuildmode
			verbs += /client/proc/togglebuildmodeself
			verbs += /client/proc/hide_most_verbs

		if (holder.level >= 3)//Trial Admin********************************************************************
			verbs += /obj/admins/proc/toggleaban			//abandon mob
			verbs += /client/proc/cmd_admin_remove_plasma
			verbs += /client/proc/admin_call_shuttle
			verbs += /client/proc/admin_cancel_shuttle
			verbs += /obj/admins/proc/show_traitor_panel
			verbs += /client/proc/cmd_admin_dress
			verbs += /client/proc/respawn_character
			verbs += /client/proc/spawn_xeno
			verbs += /proc/possess
			verbs += /proc/release
			verbs += /client/proc/toggleprayers


		if (holder.level >= 2)//Admin Candidate********************************************************************
			verbs += /client/proc/cmd_admin_add_random_ai_law
			verbs += /client/proc/secrets
			verbs += /client/proc/play_sound
			verbs += /client/proc/stealth


		if (holder.level >= 1)//Temp Admin********************************************************************
			verbs += /client/proc/cmd_admin_attack_log
			verbs += /client/proc/cmd_admin_check_contents
			verbs += /obj/admins/proc/delay					//game start delay
			verbs += /obj/admins/proc/immreboot				//immediate reboot
			verbs += /obj/admins/proc/restart				//restart
			verbs += /client/proc/cmd_admin_create_centcom_report


		if (holder.level >= 0)//Mod********************************************************************
			verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			verbs += /obj/admins/proc/toggleguests			//Toggle guests entering
			verbs += /obj/admins/proc/toggleooc				//toggle ooc
			verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			verbs += /obj/admins/proc/voteres 				//toggle votes
			verbs += /client/proc/deadchat					//toggles deadchat
			verbs += /client/proc/cmd_admin_mute
			verbs += /client/proc/cmd_admin_pm
			verbs += /client/proc/cmd_admin_subtle_message
			verbs += /client/proc/warn
			verbs += /obj/admins/proc/announce
			verbs += /obj/admins/proc/startnow
			verbs += /client/proc/dsay
			verbs += /client/proc/admin_play
			verbs += /client/proc/admin_observe
			verbs += /client/proc/game_panel
			verbs += /client/proc/player_panel
			verbs += /client/proc/unban_panel
			verbs += /client/proc/jobbans
			verbs += /client/proc/unjobban_panel
			verbs += /obj/admins/proc/vmode
			verbs += /obj/admins/proc/votekill
			verbs += /client/proc/voting
			verbs += /obj/admins/proc/show_player_panel
			verbs += /client/proc/cmd_admin_prison
			verbs += /obj/admins/proc/unprison
			verbs += /client/proc/hide_verbs
			verbs += /client/proc/general_report
			verbs += /client/proc/air_report


		if (holder.level >= -1)//Admin Observer
			verbs += /client/proc/cmd_admin_say
			verbs += /client/proc/cmd_admin_gib_self


/client/proc/clear_admin_verbs()
	deadchat = 0

	verbs -= /client/proc/hide_verbs
	verbs -= /client/proc/hide_most_verbs
	verbs -= /client/proc/show_verbs
	verbs -= /client/proc/colorooc
	verbs -= /obj/admins/proc/toggle_aliens			//toggle aliens
	verbs -= /obj/admins/proc/toggle_space_ninja	//toggle ninjas
	verbs -= /obj/admins/proc/adjump
	verbs -= /client/proc/triple_ai
	verbs -= /client/proc/get_admin_state
	verbs -= /client/proc/reload_admins
	verbs -= /client/proc/kill_air
	verbs -= /client/proc/cmd_debug_make_powernets
	verbs -= /client/proc/object_talk
	verbs -= /client/proc/strike_team
	verbs -= /obj/admins/proc/view_txt_log
	verbs -= /client/proc/cmd_mass_modify_object_variables
	verbs -= /client/proc/cmd_admin_list_open_jobs
	verbs -= /client/proc/cmd_admin_direct_narrate
	verbs -= /client/proc/cmd_admin_world_narrate
	verbs -= /client/proc/callproc
	verbs -= /client/proc/Cell
	verbs -= /client/proc/cmd_debug_del_all
	verbs -= /client/proc/cmd_debug_tog_aliens
	verbs -= /client/proc/ticklag
	verbs -= /obj/admins/proc/spawn_atom
	verbs -= /client/proc/check_words
	verbs -= /client/proc/drop_bomb
	verbs -= /client/proc/give_spell
	verbs -= /client/proc/cmd_admin_ninjafy
	verbs -= /client/proc/cmd_admin_grantfullaccess
	verbs -= /client/proc/cmd_admin_explosion
	verbs -= /client/proc/cmd_admin_emp
	verbs -= /client/proc/cmd_admin_drop_everything
	verbs -= /client/proc/make_sound
	verbs -= /client/proc/only_one
	verbs -= /client/proc/send_space_ninja
	verbs -= /obj/admins/proc/adrev					//toggle admin revives
	verbs -= /obj/admins/proc/adspawn				//toggle admin item spawning
	verbs -= /obj/admins/proc/toggleaban			//abandon mob
	verbs -= /client/proc/debug_variables
	verbs -= /client/proc/cmd_modify_object_variables
	verbs -= /client/proc/cmd_modify_ticker_variables
	verbs -= /client/proc/Debug2					//debug toggle switch
	verbs -= /client/proc/toggle_view_range
	verbs -= /client/proc/Getmob
	verbs -= /client/proc/sendmob
	verbs -= /client/proc/Jump
	verbs -= /client/proc/jumptokey
	verbs -= /client/proc/jumptomob
	verbs -= /client/proc/jumptoturf
	verbs -= /client/proc/cmd_admin_add_freeform_ai_law
	verbs -= /client/proc/cmd_admin_add_random_ai_law
	verbs -= /client/proc/cmd_admin_godmode
	verbs -= /client/proc/cmd_admin_rejuvenate
	verbs -= /client/proc/cmd_admin_gib
	verbs -= /client/proc/cmd_admin_delete
	verbs -= /proc/togglebuildmode
	verbs -= /client/proc/togglebuildmodeself
	verbs -= /client/proc/cmd_admin_remove_plasma
	verbs -= /client/proc/admin_call_shuttle
	verbs -= /client/proc/admin_cancel_shuttle
	verbs -= /obj/admins/proc/show_traitor_panel
	verbs -= /client/proc/cmd_admin_dress
	verbs -= /client/proc/respawn_character
	verbs -= /client/proc/spawn_xeno
	verbs -= /proc/possess
	verbs -= /proc/release
	verbs -= /client/proc/cmd_admin_add_random_ai_law
	verbs -= /client/proc/secrets
	verbs -= /client/proc/play_sound
	verbs -= /client/proc/stealth
	verbs -= /client/proc/cmd_admin_attack_log
	verbs -= /client/proc/cmd_admin_check_contents
	verbs -= /obj/admins/proc/delay					//game start delay
	verbs -= /obj/admins/proc/immreboot				//immediate reboot
	verbs -= /obj/admins/proc/restart				//restart
	verbs -= /client/proc/cmd_admin_create_centcom_report
	verbs -= /obj/admins/proc/toggleAI				//Toggle the AI
	verbs -= /obj/admins/proc/toggleenter			//Toggle enterting
	verbs -= /obj/admins/proc/toggleguests			//Toggle guests entering
	verbs -= /obj/admins/proc/toggleooc				//toggle ooc
	verbs -= /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
	verbs -= /obj/admins/proc/voteres 				//toggle votes
	verbs -= /client/proc/deadchat					//toggles deadchat
	verbs -= /client/proc/cmd_admin_mute
	verbs -= /client/proc/cmd_admin_pm
	verbs -= /client/proc/cmd_admin_say
	verbs -= /client/proc/cmd_admin_subtle_message
	verbs -= /client/proc/warn
	verbs -= /obj/admins/proc/announce
	verbs -= /obj/admins/proc/startnow
	verbs -= /client/proc/dsay
	verbs -= /client/proc/admin_play
	verbs -= /client/proc/admin_observe
	verbs -= /client/proc/game_panel
	verbs -= /client/proc/player_panel
	verbs -= /client/proc/unban_panel
	verbs -= /client/proc/jobbans
	verbs -= /client/proc/unjobban_panel
	verbs -= /obj/admins/proc/vmode
	verbs -= /obj/admins/proc/votekill
	verbs -= /client/proc/voting
	verbs -= /obj/admins/proc/show_player_panel
	verbs -= /client/proc/cmd_admin_prison
	verbs -= /obj/admins/proc/unprison
	verbs -= /client/proc/hide_verbs
	verbs -= /client/proc/general_report
	verbs -= /client/proc/air_report
	verbs -= /client/proc/cmd_admin_say
	verbs -= /client/proc/cmd_admin_gib_self
	verbs -= /client/proc/restartcontroller
	verbs -= /client/proc/play_local_sound
	verbs -= /client/proc/enable_mapping_debug
	return


/client/proc/admin_observe()
	set category = "Admin"
	set name = "Set Observe"
	if(!holder)
		alert("You are not an admin")
		return

	verbs -= /client/proc/admin_play
	spawn( 1200 )
		verbs += /client/proc/admin_play
	var/rank = holder.rank
	clear_admin_verbs()
	holder.state = 2
	update_admins(rank)
	if(!istype(mob, /mob/dead/observer))
		mob.adminghostize(1)
	src << "\blue You are now observing"

/client/proc/admin_play()
	set category = "Admin"
	set name = "Set Play"
	if(!holder)
		alert("You are not an admin")
		return
	verbs -= /client/proc/admin_observe
	spawn( 1200 )
		verbs += /client/proc/admin_observe
	var/rank = holder.rank
	clear_admin_verbs()
	holder.state = 1
	update_admins(rank)
	if(istype(mob, /mob/dead/observer))
		mob:reenter_corpse()
	src << "\blue You are now playing"

/client/proc/get_admin_state()
	set name = "Get Admin State"
	set category = "Debug"
	for(var/mob/M in world)
		if(M.client && M.client.holder)
			if(M.client.holder.state == 1)
				src << "[M.key] is playing - [M.client.holder.state]"
			else if(M.client.holder.state == 2)
				src << "[M.key] is observing - [M.client.holder.state]"
			else
				src << "[M.key] is undefined - [M.client.holder.state]"


/client/proc/player_panel()
	set name = "Player Panel"
	set category = "Admin"
	if (holder)
		holder.player()
	return

/client/proc/jobbans()
	set name = "Display Job bans"
	set category = "Admin"
	if(holder)
		holder.Jobbans()
	return

/client/proc/unban_panel()
	set name = "Unban Panel"
	set category = "Admin"
	if (holder)
		holder.unbanpanel()
	return

/client/proc/game_panel()
	set name = "Game Panel"
	set category = "Admin"
	if (holder)
		holder.Game()
	return

/client/proc/secrets()
	set name = "Secrets"
	set category = "Admin"
	if (holder)
		holder.Secrets()
	return

/client/proc/voting()
	set name = "Voting"
	set category = "Admin"
	if (holder)
		holder.Voting()

/client/proc/colorooc()
	set category = "Fun"
	set name = "OOC Text Color"
	ooccolor = input(src, "Please select your OOC colour.", "OOC colour") as color
	return

/client/proc/stealth()
	set category = "Admin"
	set name = "Stealth Mode"
	if(!authenticated || !holder)
		src << "Only administrators may use this command."
		return
	stealth = !stealth
	if(stealth)
		var/new_key = trim(input("Enter your desired display name.", "Fake Key", key))
		if(!new_key)
			stealth = 0
			return
		new_key = strip_html(new_key)
		if(length(new_key) >= 26)
			new_key = copytext(new_key, 1, 26)
		fakekey = new_key
	else
		fakekey = null
	log_admin("[key_name(usr)] has turned stealth mode [stealth ? "ON" : "OFF"]")
	message_admins("[key_name_admin(usr)] has turned stealth mode [stealth ? "ON" : "OFF"]", 1)

#define AUTOBATIME 10
/client/proc/warn(var/mob/M in world)
	set category = "Special Verbs"
	set name = "Warn"
	set desc = "Warn a player"
	if(!authenticated || !holder)
		src << "Only administrators may use this command."
		return
	if(M.client && M.client.holder && (M.client.holder.level >= holder.level))
		alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
		return
	if(!M.client.warned)
		M << "\red <B>You have been warned by an administrator. This is the only warning you will recieve.</B>"
		M.client.warned = 1
		message_admins("\blue [ckey] warned [M.ckey].")
	else
		AddBan(M.ckey, M.computer_id, "Autobanning due to previous warn", ckey, 1, AUTOBATIME)
		M << "\red<BIG><B>You have been autobanned by [ckey]. This is what we in the biz like to call a \"second warning\".</B></BIG>"
		M << "\red This is a temporary ban; it will automatically be removed in [AUTOBATIME] minutes."
		log_admin("[ckey] warned [M.ckey], resulting in a [AUTOBATIME] minute autoban.")
		message_admins("\blue [ckey] warned [M.ckey], resulting in a [AUTOBATIME] minute autoban.")

		del(M.client)


/client/proc/drop_bomb() // Some admin dickery that can probably be done better -- TLE
	set category = "Special Verbs"
	set name = "Drop Bomb"
	set desc = "Cause an explosion of varying strength at your location."

	var/turf/epicenter = mob.loc
	var/list/choices = list("Small Bomb", "Medium Bomb", "Big Bomb", "Custom Bomb")
	var/choice = input("What size explosion would you like to produce?") in choices
	switch(choice)
		if(null)
			return 0
		if("Small Bomb")
			explosion(epicenter, 1, 2, 3, 3)
		if("Medium Bomb")
			explosion(epicenter, 2, 3, 4, 4)
		if("Big Bomb")
			explosion(epicenter, 3, 5, 7, 5)
		if("Custom Bomb")
			var/devastation_range = input("Devastation range (in tiles):") as num
			var/heavy_impact_range = input("Heavy impact range (in tiles):") as num
			var/light_impact_range = input("Light impact range (in tiles):") as num
			var/flash_range = input("Flash range (in tiles):") as num
			explosion(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range)
	message_admins("\blue [ckey] creating an admin explosion at [epicenter.loc].")

/client/proc/give_spell(mob/T as mob in world) // -- Urist
	set category = "Fun"
	set name = "Give Spell"
	set desc = "Gives a spell to a mob."
	var/obj/proc_holder/spell/S = input("Choose the spell to give to that guy", "ABRAKADABRA") in spells
	T.spell_list += new S

/client/proc/make_sound(var/obj/O in world) // -- TLE
	set category = "Special Verbs"
	set name = "Make Sound"
	set desc = "Display a message to everyone who can hear the target"
	if(O)
		var/message = input("What do you want the message to be?", "Make Sound") as text|null
		if(!message)
			return
		for (var/mob/V in hearers(O))
			V.show_message(message, 2)

/client/proc/togglebuildmodeself()
	set name = "Toggle Build Mode Self"
	set category = "Special Verbs"
	if(src.mob)
		togglebuildmode(src.mob)

/client/proc/object_talk(var/msg as text) // -- TLE
	set category = "Special Verbs"
	set name = "oSay"
	set desc = "Display a message to everyone who can hear the target"
	if(mob.control_object)
		if(!msg)
			return
		for (var/mob/V in hearers(mob.control_object))
			V.show_message("<b>[mob.control_object.name]</b> says: \"" + msg + "\"", 2)

/client/proc/kill_air() // -- TLE
	set category = "Debug"
	set name = "Kill Air"
	set desc = "Toggle Air Processing"
	if(kill_air)
		kill_air = 0
		usr << "<b>Enabled air processing.</b>"
	else
		kill_air = 1
		usr << "<b>Disabled air processing.</b>"

/client/proc/show_verbs()
	set name = "Toggle admin verb visibility"
	set category = "Admin"
	src << "Restoring admin verbs back"

	var/temp = deadchat
	clear_admin_verbs()
	update_admins(holder.rank)
	deadchat = temp

/client/proc/hide_most_verbs()//Allows you to keep some functionality while hiding some verbs
	set name = "Toggle most admin verb visibility"
	set category = "Admin"
	src << "Hiding most admin verbs"

	var/temp = deadchat
	clear_admin_verbs()
	deadchat = temp
	verbs -= /client/proc/hide_verbs
	verbs -= /client/proc/hide_most_verbs
	verbs += /client/proc/show_verbs

	if(holder.level >= 6)//Game Master********************************************************************
		verbs += /client/proc/colorooc

	if(holder.level >= 4)//Badmin********************************************************************
		verbs += /client/proc/debug_variables
		verbs += /client/proc/cmd_modify_object_variables
		verbs += /client/proc/Jump
		verbs += /client/proc/jumptoturf
		verbs += /client/proc/togglebuildmodeself

	verbs += /client/proc/dsay
	verbs += /client/proc/admin_play
	verbs += /client/proc/admin_observe
	verbs += /client/proc/game_panel
	verbs += /client/proc/player_panel
	verbs += /client/proc/cmd_admin_subtle_message
	verbs += /client/proc/cmd_admin_pm
	verbs += /client/proc/cmd_admin_gib_self

	verbs += /client/proc/deadchat					//toggles deadchat
	verbs += /obj/admins/proc/toggleooc				//toggle ooc
	verbs += /client/proc/cmd_admin_say//asay
	return


/client/proc/hide_verbs()
	set name = "Toggle admin verb visibility"
	set category = "Admin"
	src << "Hiding almost all admin verbs"

	var/temp = deadchat
	clear_admin_verbs()
	deadchat = temp
	verbs -= /client/proc/hide_verbs
	verbs -= /client/proc/hide_most_verbs
	verbs += /client/proc/show_verbs

	verbs += /client/proc/deadchat					//toggles deadchat
	verbs += /obj/admins/proc/toggleooc				//toggle ooc
	verbs += /client/proc/cmd_admin_say//asay
	return
