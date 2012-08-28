//GUYS REMEMBER TO ADD A += to UPDATE_ADMINS
//AND A -= TO CLEAR_ADMIN_VERBS



//Some verbs that are still in the code but not used atm
			// Debug
//			verbs += /client/proc/radio_report //for radio debugging dont think its been used in a very long time
//			verbs += /client/proc/fix_next_move //has not been an issue in a very very long time

			// Mapping helpers added via enable_debug_verbs verb
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
		var/state = alert("Which state do you want the admin to begin in?", "Admin-state", "Play", "Observe", "Neither")
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
			holder.level = 6

		if ("Game Admin")
			holder.level = 5

		if ("Badmin")
			holder.level = 4

		if ("Trial Admin")
			holder.level = 3
			if(holder.state == 2) // if observing
				verbs += /client/proc/debug_variables
				verbs += /client/proc/cmd_modify_ticker_variables
				verbs += /client/proc/toggle_view_range
				verbs += /client/proc/Getmob
				verbs += /client/proc/Getkey
				verbs += /client/proc/sendmob
				verbs += /client/proc/Jump
				verbs += /client/proc/jumptokey
				verbs += /client/proc/jumptomob
				verbs += /client/proc/jumptoturf
				verbs += /client/proc/jumptocoord
				verbs += /client/proc/cmd_admin_delete
				verbs += /client/proc/cmd_admin_add_freeform_ai_law
				verbs += /client/proc/cmd_admin_rejuvenate
				//verbs += /client/proc/cmd_admin_drop_everything		--Merged with view variables
				//verbs += /client/proc/cmd_modify_object_variables 	--Merged with view variables

		if ("Admin Candidate")
			holder.level = 2
			if(holder.state == 2) // if observing
				deadchat = 1
				verbs += /obj/admins/proc/toggleaban					//abandon mob
				verbs += /client/proc/deadchat							//toggles deadchat
				verbs += /client/proc/cmd_admin_check_contents
				verbs += /client/proc/Jump
				verbs += /client/proc/jumptokey
				verbs += /client/proc/jumptomob
				//verbs += /client/proc/cmd_admin_attack_log			--Merged with view variables

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

	if (holder)		//THE BELOW handles granting powers. The above is for special cases only!
		holder.owner = src

		//Admin Observer
		if (holder.level >= -1)
			verbs += /client/proc/investigate_show
			verbs += /client/proc/cmd_admin_say
			verbs += /client/proc/cmd_admin_gib_self
			verbs += /client/proc/deadmin_self
		else	return

		//Moderator
		if (holder.level >= 0)
			verbs += /obj/admins/proc/announce
			verbs += /obj/admins/proc/startnow
			verbs += /obj/admins/proc/toggleAI							//Toggle the AI
			verbs += /obj/admins/proc/toggleenter						//Toggle enterting
			verbs += /obj/admins/proc/toggleguests						//Toggle guests entering
			verbs += /obj/admins/proc/toggleooc							//toggle ooc
			verbs += /obj/admins/proc/toggleoocdead						//toggle ooc for dead/unc
			verbs += /obj/admins/proc/voteres 							//toggle votes
			verbs += /obj/admins/proc/vmode
			verbs += /obj/admins/proc/votekill
			verbs += /obj/admins/proc/show_player_panel
			verbs += /client/proc/deadchat								//toggles deadchat
			//verbs += /client/proc/cmd_admin_mute	--was never used (according to stats trackind) - use show player panel --erro
			verbs += /client/proc/cmd_admin_pm_context
			verbs += /client/proc/cmd_admin_pm_panel
			verbs += /client/proc/cmd_admin_subtle_message
			//verbs += /client/proc/warn	- was never used
			verbs += /client/proc/dsay
			verbs += /client/proc/admin_play
			verbs += /client/proc/admin_observe
			verbs += /client/proc/game_panel
			verbs += /client/proc/player_panel
			verbs += /client/proc/player_panel_new
			verbs += /client/proc/unban_panel
			verbs += /client/proc/jobbans
			verbs += /client/proc/unjobban_panel
			verbs += /client/proc/voting
			verbs += /client/proc/hide_verbs
			verbs += /client/proc/general_report
			verbs += /client/proc/air_report
			verbs += /client/proc/deadmin_self
			verbs += /client/proc/check_ai_laws
			//verbs += /client/proc/cmd_admin_prison 					--Merged with player panel
			//verbs += /obj/admins/proc/unprison  						--Merged with player panel
		else	return

		//Temporary Admin
		if (holder.level >= 1)
			verbs += /obj/admins/proc/delay								//game start delay
			verbs += /obj/admins/proc/immreboot							//immediate reboot
			verbs += /obj/admins/proc/restart							//restart
			verbs += /client/proc/cmd_admin_check_contents
			verbs += /client/proc/cmd_admin_create_centcom_report
			verbs += /client/proc/toggle_hear_deadcast
			verbs += /client/proc/toggle_hear_radio
			verbs += /client/proc/toggle_hear_atklog
			verbs += /client/proc/deadmin_self
			//verbs += /client/proc/cmd_admin_attack_log				--Merged with view variables
		else	return

		//Admin Candidate
		if (holder.level >= 2)
			verbs += /client/proc/cmd_admin_add_random_ai_law
			verbs += /client/proc/secrets
			verbs += /client/proc/check_antagonists
			verbs += /client/proc/play_sound
			verbs += /client/proc/stealth
			verbs += /client/proc/deadmin_self
		else	return

		//Trial Admin
		if (holder.level >= 3)
			deadchat = 1
			seeprayers = 1

			verbs += /obj/admins/proc/view_txt_log
			verbs += /obj/admins/proc/view_atk_log
			verbs += /obj/admins/proc/toggleaban						//abandon mob
			verbs += /obj/admins/proc/show_traitor_panel
			verbs += /client/proc/getserverlog							//fetch an old serverlog to look at
			//verbs += /client/proc/cmd_admin_remove_plasma 			--This proc is outdated, does not do anything
			verbs += /client/proc/admin_call_shuttle
			verbs += /client/proc/admin_cancel_shuttle
			verbs += /client/proc/cmd_admin_dress
			verbs += /client/proc/respawn_character
			verbs += /client/proc/spawn_xeno
			verbs += /client/proc/toggleprayers
			verbs += /client/proc/deadmin_self
			verbs += /client/proc/toggleadminhelpsound
			verbs += /proc/possess
			verbs += /proc/release


		else	return

		//Badmin
		if (holder.level >= 4)
			verbs += /obj/admins/proc/adrev								//toggle admin revives
			verbs += /obj/admins/proc/adspawn							//toggle admin item spawning
			verbs += /client/proc/debug_variables
			verbs += /client/proc/cmd_modify_ticker_variables
			verbs += /client/proc/Debug2								//debug toggle switch
			verbs += /client/proc/toggle_view_range
			verbs += /client/proc/Getmob
			verbs += /client/proc/Getkey
			verbs += /client/proc/sendmob
			verbs += /client/proc/Jump
			verbs += /client/proc/jumptokey
			verbs += /client/proc/jumptomob
			verbs += /client/proc/jumptoturf
			verbs += /client/proc/cmd_admin_delete
			verbs += /client/proc/cmd_admin_add_freeform_ai_law
			verbs += /client/proc/cmd_admin_add_random_ai_law
			verbs += /client/proc/cmd_admin_rejuvenate
			verbs += /client/proc/hide_most_verbs
			verbs += /client/proc/jumptocoord
			verbs += /client/proc/deadmin_self
			verbs += /client/proc/giveruntimelog						//used by coders to retrieve runtime logs
			//verbs += /client/proc/cmd_admin_godmode					--Merged with view variables
			//verbs += /client/proc/cmd_admin_gib 						--Merged with view variables
			//verbs += /proc/togglebuildmode 							--Merged with view variables
			//verbs += /client/proc/cmd_modify_object_variables 		--Merged with view variables
			verbs += /client/proc/togglebuildmodeself
			verbs += /client/proc/debug_controller
		else	return

		//Game Admin
		if (holder.level >= 5)
			verbs += /obj/admins/proc/spawn_atom
			verbs += /client/proc/cmd_admin_list_open_jobs
			verbs += /client/proc/cmd_admin_direct_narrate
			verbs += /client/proc/colorooc
			verbs += /client/proc/kill_air
			verbs += /client/proc/cmd_admin_world_narrate
			verbs += /client/proc/cmd_debug_del_all
			verbs += /client/proc/cmd_debug_tog_aliens
//			verbs += /client/proc/mapload
			verbs += /client/proc/check_words
			verbs += /client/proc/drop_bomb
			verbs += /client/proc/kill_airgroup
			//verbs += /client/proc/cmd_admin_drop_everything			--Merged with view variables
			verbs += /client/proc/make_sound
			verbs += /client/proc/play_local_sound
			verbs += /client/proc/send_space_ninja
			verbs += /client/proc/restart_controller						//Can call via aproccall --I_hate_easy_things.jpg, Mport --Agouri
			verbs += /client/proc/Blobize								//I need to remember to move/remove this later
			verbs += /client/proc/Blobcount								//I need to remember to move/remove this later
			verbs += /client/proc/toggle_clickproc 						//TODO ERRORAGE (Temporary proc while the new clickproc is being tested)
			verbs += /client/proc/toggle_gravity_on
			verbs += /client/proc/toggle_gravity_off
			verbs += /client/proc/toggle_random_events
			verbs += /client/proc/deadmin_self
			verbs += /client/proc/Set_Holiday							//Force-set a Holiday
			verbs += /client/proc/admin_memo
			verbs += /client/proc/ToRban								//ToRban  frontend to access its features.
			//verbs += /client/proc/cmd_mass_modify_object_variables 	--Merged with view variables
			//verbs += /client/proc/cmd_admin_explosion					--Merged with view variables
			//verbs += /client/proc/cmd_admin_emp						--Merged with view variables
			//verbs += /client/proc/give_spell 							--Merged with view variables
			//verbs += /client/proc/cmd_admin_ninjafy					--Merged with view variables
			//verbs += /client/proc/cmd_switch_radio					--removed as tcommsat is staying
		else	return

		//Game Master
		if (holder.level >= 6)
			verbs += /obj/admins/proc/toggle_aliens						//toggle aliens
			verbs += /obj/admins/proc/toggle_space_ninja				//toggle ninjas
			verbs += /obj/admins/proc/adjump
			verbs += /client/proc/callproc
			verbs += /client/proc/triple_ai
			verbs += /client/proc/get_admin_state
			verbs += /client/proc/reload_admins
			verbs += /client/proc/cmd_debug_make_powernets
			verbs += /client/proc/object_talk
			verbs += /client/proc/strike_team
			verbs += /client/proc/enable_debug_verbs
			verbs += /client/proc/everyone_random
			verbs += /client/proc/only_one
			verbs += /client/proc/deadmin_self
			verbs += /client/proc/cinematic								//show a cinematic sequence
			verbs += /client/proc/startSinglo							//Used to prevent the station from losing power while testing stuff out.
			verbs += /client/proc/toggle_log_hrefs
			verbs += /client/proc/cmd_debug_mob_lists
		else	return
	return


/client/proc/clear_admin_verbs()
	deadchat = 0

	verbs -= /obj/admins/proc/vmode
	verbs -= /obj/admins/proc/votekill
	verbs -= /obj/admins/proc/announce
	verbs -= /obj/admins/proc/startnow
	verbs -= /obj/admins/proc/toggleAI									//Toggle the AI
	verbs -= /obj/admins/proc/toggleenter								//Toggle enterting
	verbs -= /obj/admins/proc/toggleguests								//Toggle guests entering
	verbs -= /obj/admins/proc/toggleooc									//toggle ooc
	verbs -= /obj/admins/proc/toggleoocdead         					//toggle ooc for dead/unc
	verbs -= /obj/admins/proc/voteres 									//toggle votes
	verbs -= /obj/admins/proc/delay										//game start delay
	verbs -= /obj/admins/proc/immreboot									//immediate reboot
	verbs -= /obj/admins/proc/restart									//restart
	verbs -= /obj/admins/proc/show_traitor_panel
	verbs -= /obj/admins/proc/show_player_panel
	verbs -= /obj/admins/proc/toggle_aliens								//toggle aliens
	verbs -= /obj/admins/proc/toggle_space_ninja						//toggle ninjas
	verbs -= /obj/admins/proc/adjump
	verbs -= /obj/admins/proc/view_txt_log
	verbs -= /obj/admins/proc/view_atk_log
	verbs -= /obj/admins/proc/spawn_atom
	verbs -= /obj/admins/proc/adrev										//toggle admin revives
	verbs -= /obj/admins/proc/adspawn									//toggle admin item spawning
	verbs -= /obj/admins/proc/toggleaban								//abandon mob
	verbs -= /client/proc/hide_verbs
	verbs -= /client/proc/hide_most_verbs
	verbs -= /client/proc/show_verbs
	verbs -= /client/proc/colorooc
	verbs -= /client/proc/triple_ai
	verbs -= /client/proc/get_admin_state
	verbs -= /client/proc/reload_admins
	verbs -= /client/proc/kill_air
	verbs -= /client/proc/cmd_debug_make_powernets
	verbs -= /client/proc/object_talk
	verbs -= /client/proc/strike_team
	verbs -= /client/proc/cmd_admin_list_open_jobs
	verbs -= /client/proc/cmd_admin_direct_narrate
	verbs -= /client/proc/cmd_admin_world_narrate
	verbs -= /client/proc/callproc
	verbs -= /client/proc/Cell
	verbs -= /client/proc/cmd_debug_del_all
	verbs -= /client/proc/cmd_debug_tog_aliens
//	verbs -= /client/proc/mapload
	verbs -= /client/proc/check_words
	verbs -= /client/proc/drop_bomb
	//verbs -= /client/proc/cmd_admin_drop_everything					--merged with view variables
	verbs -= /client/proc/make_sound
	verbs -= /client/proc/only_one
	verbs -= /client/proc/send_space_ninja
	verbs -= /client/proc/debug_variables
	verbs -= /client/proc/cmd_modify_ticker_variables
	verbs -= /client/proc/Debug2										//debug toggle switch
	verbs -= /client/proc/toggle_view_range
	verbs -= /client/proc/Getmob
	verbs -= /client/proc/Getkey
	verbs -= /client/proc/sendmob
	verbs -= /client/proc/Jump
	verbs -= /client/proc/jumptokey
	verbs -= /client/proc/jumptomob
	verbs -= /client/proc/jumptoturf
	verbs -= /client/proc/cmd_admin_add_freeform_ai_law
	verbs -= /client/proc/cmd_admin_add_random_ai_law
	verbs -= /client/proc/cmd_admin_rejuvenate
	verbs -= /client/proc/cmd_admin_delete
	verbs -= /client/proc/toggleadminhelpsound
	//verbs -= /client/proc/cmd_admin_remove_plasma						--This proc is outdated, does not do anything
	verbs -= /client/proc/admin_call_shuttle
	verbs -= /client/proc/admin_cancel_shuttle
	verbs -= /client/proc/cmd_admin_dress
	verbs -= /client/proc/respawn_character
	verbs -= /client/proc/spawn_xeno
	verbs -= /client/proc/cmd_admin_add_random_ai_law
	verbs -= /client/proc/secrets
	verbs -= /client/proc/check_antagonists
	verbs -= /client/proc/play_sound
	verbs -= /client/proc/stealth
	verbs -= /client/proc/cmd_admin_check_contents
	verbs -= /client/proc/cmd_admin_create_centcom_report
	verbs -= /client/proc/deadchat										//toggles deadchat
	//verbs -= /client/proc/cmd_admin_mute	--was never used (according to stats trackind) - use show player panel --erro
	verbs -= /client/proc/cmd_admin_pm_context
	verbs -= /client/proc/cmd_admin_pm_panel
	verbs -= /client/proc/cmd_admin_say
	verbs -= /client/proc/cmd_admin_subtle_message
	//verbs -= /client/proc/warn
	verbs -= /client/proc/dsay
	verbs -= /client/proc/admin_play
	verbs -= /client/proc/admin_observe
	verbs -= /client/proc/game_panel
	verbs -= /client/proc/player_panel
	verbs -= /client/proc/unban_panel
	verbs -= /client/proc/jobbans
	verbs -= /client/proc/unjobban_panel
	verbs -= /client/proc/voting
	verbs -= /client/proc/hide_verbs
	verbs -= /client/proc/general_report
	verbs -= /client/proc/air_report
	verbs -= /client/proc/cmd_admin_say
	verbs -= /client/proc/cmd_admin_gib_self
	verbs -= /client/proc/restart_controller
	verbs -= /client/proc/play_local_sound
	verbs -= /client/proc/enable_debug_verbs
	verbs -= /client/proc/toggleprayers
	verbs -= /client/proc/Blobize
	verbs -= /client/proc/Blobcount
	verbs -= /client/proc/toggle_clickproc 								//TODO ERRORAGE (Temporary proc while the enw clickproc is being tested)
	verbs -= /client/proc/toggle_hear_deadcast
	verbs -= /client/proc/toggle_hear_radio
	verbs -= /client/proc/toggle_hear_atklog
	verbs -= /client/proc/player_panel_new
	verbs -= /client/proc/toggle_gravity_on
	verbs -= /client/proc/toggle_gravity_off
	verbs -= /client/proc/toggle_random_events
	verbs -= /client/proc/deadmin_self
	verbs -= /client/proc/jumptocoord
	verbs -= /client/proc/everyone_random
	verbs -= /client/proc/Set_Holiday
	verbs -= /client/proc/giveruntimelog								//used by coders to retrieve runtime logs
	verbs -= /client/proc/getserverlog
	verbs -= /client/proc/cinematic										//show a cinematic sequence
	verbs -= /client/proc/admin_memo
	verbs -= /client/proc/investigate_show								//investigate in-game mishaps using various logs.
	verbs -= /client/proc/toggle_log_hrefs
	verbs -= /client/proc/ToRban
	verbs -= /proc/possess
	verbs -= /proc/release
	//verbs -= /client/proc/give_spell 									--Merged with view variables
	//verbs -= /client/proc/cmd_admin_ninjafy 							--Merged with view variables
	//verbs -= /client/proc/cmd_modify_object_variables 				--Merged with view variables
	//verbs -= /client/proc/cmd_admin_explosion							--Merged with view variables
	//verbs -= /client/proc/cmd_admin_emp								--Merged with view variables
	//verbs -= /client/proc/cmd_admin_godmode							--Merged with view variables
	//verbs -= /client/proc/cmd_admin_gib 								--Merged with view variables
	//verbs -= /client/proc/cmd_mass_modify_object_variables			--Merged with view variables
	//verbs -= /client/proc/cmd_admin_attack_log						--Merged with view variables
	//verbs -= /proc/togglebuildmode									--Merged with view variables
	//verbs -= /client/proc/cmd_admin_prison 							--Merged with player panel
	//verbs -= /obj/admins/proc/unprison 								--Merged with player panel
	//verbs -= /client/proc/cmd_switch_radio							--removed because tcommsat is staying
	verbs -= /client/proc/togglebuildmodeself
	verbs -= /client/proc/kill_airgroup
	verbs -= /client/proc/debug_controller
	verbs -= /client/proc/check_ai_laws
	verbs -= /client/proc/cmd_debug_mob_lists
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
		mob.ghostize(1)
	src << "\blue You are now observing"
	feedback_add_details("admin_verb","O") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

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
		var/mob/dead/observer/ghost = mob
		ghost.can_reenter_corpse = 1	//just in-case.
		ghost.reenter_corpse()
	deadchat = 0
	src << "\blue You are now playing"
	feedback_add_details("admin_verb","P") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/get_admin_state()
	set name = "Get Admin State"
	set category = "Debug"
	for(var/client/C in admin_list)
		if(C.holder.state == 1)
			src << "[C.key] is playing - [C.holder.state]"
		else if(C.holder.state == 2)
			src << "[C.key] is observing - [C.holder.state]"
		else
			src << "[C.key] is undefined - [C.holder.state]"
	feedback_add_details("admin_verb","GAS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/player_panel()
	set name = "Player Panel"
	set category = "Admin"
	if(holder)
		holder.player_panel_old()
	feedback_add_details("admin_verb","PP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/player_panel_new()
	set name = "Player Panel New"
	set category = "Admin"
	if(holder)
		holder.player_panel_new()
	feedback_add_details("admin_verb","PPN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/check_antagonists()
	set name = "Check Antagonists"
	set category = "Admin"
	if(holder)
		holder.check_antagonists()
		log_admin("[key_name(usr)] checked antagonists.")	//for tsar~
	feedback_add_details("admin_verb","CHA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/jobbans()
	set name = "Display Job bans"
	set category = "Admin"
	if(holder)
		holder.Jobbans()
	feedback_add_details("admin_verb","VJB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/unban_panel()
	set name = "Unban Panel"
	set category = "Admin"
	if(holder)
		holder.unbanpanel()
	feedback_add_details("admin_verb","UBP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/game_panel()
	set name = "Game Panel"
	set category = "Admin"
	if(holder)
		holder.Game()
	feedback_add_details("admin_verb","GP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/secrets()
	set name = "Secrets"
	set category = "Admin"
	if (holder)
		holder.Secrets()
	feedback_add_details("admin_verb","S") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/voting()
	set name = "Voting"
	set category = "Admin"
	if (holder)
		holder.Voting()
	feedback_add_details("admin_verb","VO") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/colorooc()
	set category = "Fun"
	set name = "OOC Text Color"
	ooccolor = input(src, "Please select your OOC colour.", "OOC colour") as color
	feedback_add_details("admin_verb","OC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/stealth()
	set category = "Admin"
	set name = "Stealth Mode"
	if(!holder)
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
	feedback_add_details("admin_verb","SM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

#define AUTOBATIME 10
/client/proc/warn(var/mob/M in player_list)
	/*set category = "Special Verbs"
	set name = "Warn"
	set desc = "Warn a player"*/ //Based on the information I gathered via stat logging this verb was not used. Use the show player panel alternative. --erro
	if(!holder)
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
		ban_unban_log_save("[ckey] warned [M.ckey], resulting in a [AUTOBATIME] minute autoban.")
		message_admins("\blue [ckey] warned [M.ckey], resulting in a [AUTOBATIME] minute autoban.")
		feedback_inc("ban_warn",1)

		del(M.client)
	feedback_add_details("admin_verb","WARN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


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
	feedback_add_details("admin_verb","DB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/give_spell(mob/T as mob in mob_list) // -- Urist
	set category = "Fun"
	set name = "Give Spell"
	set desc = "Gives a spell to a mob."
	var/obj/effect/proc_holder/spell/S = input("Choose the spell to give to that guy", "ABRAKADABRA") as null|anything in spells
	if(!S) return
	T.spell_list += new S
	feedback_add_details("admin_verb","GS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(T)] the spell [S].")
	message_admins("\blue [key_name_admin(usr)] gave [key_name(T)] the spell [S].", 1)

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
		log_admin("[key_name(usr)] made [O] at [O.x], [O.y], [O.z]. make a sound")
		message_admins("\blue [key_name_admin(usr)] made [O] at [O.x], [O.y], [O.z]. make a sound", 1)
		feedback_add_details("admin_verb","MS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/togglebuildmodeself()
	set name = "Toggle Build Mode Self"
	set category = "Special Verbs"
	if(src.mob)
		togglebuildmode(src.mob)
	feedback_add_details("admin_verb","TBMS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/toggleadminhelpsound()
	set name = "Toggle Adminhelp Sound"
	set category = "Admin"
	sound_adminhelp = !sound_adminhelp
	if(sound_adminhelp)
		usr << "You will now hear a sound when adminhelps arrive"
	else
		usr << "You will no longer hear a sound when adminhelps arrive"
	feedback_add_details("admin_verb","AHS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/object_talk(var/msg as text) // -- TLE
	set category = "Special Verbs"
	set name = "oSay"
	set desc = "Display a message to everyone who can hear the target"
	if(mob.control_object)
		if(!msg)
			return
		for (var/mob/V in hearers(mob.control_object))
			V.show_message("<b>[mob.control_object.name]</b> says: \"" + msg + "\"", 2)
	feedback_add_details("admin_verb","OT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

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
	feedback_add_details("admin_verb","KA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] used 'kill air'.")
	message_admins("\blue [key_name_admin(usr)] used 'kill air'.", 1)

/client/proc/show_verbs()
	set name = "Toggle admin verb visibility"
	set category = "Admin"
	src << "Restoring admin verbs back"

	var/temp = deadchat
	clear_admin_verbs()
	update_admins(holder.rank)
	deadchat = temp
	feedback_add_details("admin_verb","TAVVS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_clickproc() //TODO ERRORAGE (This is a temporary verb here while I test the new clicking proc)
	set name = "Toggle NewClickProc"
	set category = "Debug"

	if(!holder) return
	using_new_click_proc = !using_new_click_proc
	world << "Testing of new click proc [using_new_click_proc ? "enabled" : "disabled"]"
	feedback_add_details("admin_verb","TNCP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_hear_deadcast()
	set name = "Toggle Hear Deadcast"
	set category = "Admin"

	if(!holder) return
	STFU_ghosts = !STFU_ghosts
	usr << "You will now [STFU_ghosts ? "not hear" : "hear"] ghosts"
	feedback_add_details("admin_verb","THDC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_hear_radio()
	set name = "Toggle Hear Radio"
	set category = "Admin"

	if(!holder) return
	STFU_radio = !STFU_radio
	usr << "You will now [STFU_radio ? "not hear" : "hear"] radio chatter from nearby radios or speakers"
	feedback_add_details("admin_verb","THR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_hear_atklog()
	set name = "Toggle Hear Attacks"
	set category = "Admin"

	if(!holder) return
	STFU_atklog = !STFU_atklog
	usr << "You will now [STFU_atklog ? "not hear" : "hear"] attack logs"
	feedback_add_details("admin_verb","THAL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/deadmin_self()
	set name = "De-admin self"
	set category = "Admin"

	if(src.holder)
		if(alert("Confirm self-deadmin for the round? You can't re-admin yourself without someont promoting you.",,"Yes","No") == "Yes")
			del(holder)
			log_admin("[src] deadmined themself.")
			message_admins("[src] deadmined themself.", 1)
			src.clear_admin_verbs()
			src.update_admins(null)
			admins.Remove(src.ckey)
			admin_list -= src
			usr << "You are now a normal player."
	feedback_add_details("admin_verb","DAS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


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

	if(holder.level >= 5)//Game Admin********************************************************************
		verbs += /client/proc/colorooc

	if(holder.level >= 4)//Badmin********************************************************************
		verbs += /client/proc/debug_variables
		//verbs += /client/proc/cmd_modify_object_variables --merged with view vairiables
		verbs += /client/proc/Jump
		verbs += /client/proc/jumptoturf
		verbs += /client/proc/togglebuildmodeself

	verbs += /client/proc/dsay
	verbs += /client/proc/admin_play
	verbs += /client/proc/admin_observe
	verbs += /client/proc/game_panel
	verbs += /client/proc/player_panel
	verbs += /client/proc/cmd_admin_subtle_message
	verbs += /client/proc/cmd_admin_pm_context
	verbs += /client/proc/cmd_admin_pm_panel
	verbs += /client/proc/cmd_admin_gib_self

	verbs += /client/proc/deadchat					//toggles deadchat
	verbs += /obj/admins/proc/toggleooc				//toggle ooc
	verbs += /client/proc/cmd_admin_say//asay
	verbs += /client/proc/toggleadminhelpsound
	feedback_add_details("admin_verb","HMV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
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
	feedback_add_details("admin_verb","TAVVH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/toggle_log_hrefs()
	set name = "Toggle href logging"
	set category = "Server"
	if(!holder)	return
	if(config)
		if(config.log_hrefs)
			config.log_hrefs = 0
			src << "<b>Stopped logging hrefs</b>"
		else
			config.log_hrefs = 1
			src << "<b>Started logging hrefs</b>"

/client/proc/check_ai_laws()
	set name = "Check AI Laws"
	set category = "Admin"
	if(holder)
		src.holder.output_ai_laws()

