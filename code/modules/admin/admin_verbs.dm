//GUYS REMEMBER TO ADD A += to UPDATE_ADMINS
//AND A -= TO CLEAR_ADMIN_VERBS

/client/proc/update_admins(var/rank)

	if(!src.holder)
		src.holder = new /obj/admins(src)

	src.holder.rank = rank

	if(!src.holder.state)
		var/state = alert("Which state do you the admin to begin in?", "Admin-state", "Play", "Observe", "Neither")
		if(state == "Play")
			src.holder.state = 1
			src.admin_play()
			return
		else if(state == "Observe")
			src.holder.state = 2
			src.admin_observe()
			return
		else
			del(src.holder)
			return

	switch (rank)
		if ("Game Master")
			src.deadchat = 1
			src.holder.level = 6

			// Settings

			src.verbs += /client/proc/colorooc // -- Urist
			src.verbs += /obj/admins/proc/adjump				//toggle admin jumping
			src.verbs += /obj/admins/proc/adrev					//toggle admin revives
			src.verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			src.verbs += /obj/admins/proc/delay					//game start delay
			src.verbs += /obj/admins/proc/toggleaban			//abandon mob
			src.verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			src.verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
			src.verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			src.verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			src.verbs += /obj/admins/proc/toggle_aliens
			src.verbs += /obj/admins/proc/voteres 				//toggle votes
			src.verbs += /client/proc/deadchat					//toggles deadchat
			src.verbs += /proc/toggle_adminmsg

			src.verbs += /client/proc/triple_ai					//triple AIs~ --NEO
			src.verbs += /client/proc/cmd_mass_modify_object_variables
			// Admin "must have"
			src.verbs += /client/proc/cmd_admin_list_occ
			src.verbs += /client/proc/cmd_admin_mute
			src.verbs += /client/proc/cmd_admin_pm
			src.verbs += /client/proc/cmd_admin_direct_narrate 	// -- TLE
			src.verbs += /client/proc/cmd_admin_say
			src.verbs += /client/proc/cmd_admin_subtle_message
			src.verbs += /client/proc/cmd_admin_world_narrate 	// -- TLE
			src.verbs += /client/proc/get_admin_state
			src.verbs += /client/proc/warn
			src.verbs += /obj/admins/proc/announce				//global announce
			src.verbs += /obj/admins/proc/immreboot				//immediate reboot
			src.verbs += /obj/admins/proc/restart				//restart
			src.verbs += /obj/admins/proc/startnow				//start now bitch

			// Debug
			src.verbs += /client/proc/restartcontroller //exactly what it sounds like
			src.verbs += /client/proc/atmosscan //for locating piping breaks
			src.verbs += /client/proc/debug_variables
			src.verbs += /client/proc/cmd_modify_object_variables
			src.verbs += /client/proc/cmd_modify_ticker_variables
			src.verbs += /client/proc/general_report
			src.verbs += /client/proc/air_report
			src.verbs += /client/proc/air_status
			src.verbs += /client/proc/radio_report
			src.verbs += /client/proc/kill_air // -- TLE
			src.verbs += /client/proc/modifytemperature
			src.verbs += /client/proc/callproc
			src.verbs += /client/proc/Cell
			src.verbs += /client/proc/cmd_debug_del_all
			src.verbs += /client/proc/cmd_debug_tog_aliens
			src.verbs += /client/proc/Debug2					//debug toggle switch
			src.verbs += /client/proc/fix_next_move
			src.verbs += /client/proc/ticklag

			src.verbs += /proc/givetestverbs
			src.verbs += /obj/admins/proc/spawn_atom
			src.verbs += /obj/admins/proc/toggletintedweldhelmets

			// Mapping helpers
// 			src.verbs += /client/proc/do_not_use_these 			//-errorage
// 			src.verbs += /client/proc/camera_view 				//-errorage
// 			src.verbs += /client/proc/sec_camera_report 		//-errorage
// 			src.verbs += /client/proc/intercom_view 			//-errorage
			src.verbs += /client/proc/enable_mapping_debug 			//-rastaf0

			// Admin helpers
			src.verbs += /client/proc/cmd_admin_attack_log
			src.verbs += /client/proc/cmd_admin_check_contents
			src.verbs += /client/proc/check_words // -- Urist
			src.verbs += /client/proc/dsay
			src.verbs += /client/proc/jobbans
			src.verbs += /client/proc/toggle_view_range

			// Admin game intrusion
			src.verbs += /client/proc/cmd_admin_remove_plasma
			src.verbs += /client/proc/drop_bomb 				// -- TLE

			src.verbs += /client/proc/admin_call_shuttle 		// -- Skie
			src.verbs += /client/proc/admin_cancel_shuttle 		// -- Skie
			src.verbs += /client/proc/cmd_admin_create_centcom_report
			src.verbs += /obj/admins/proc/vmode   				//start vote
			src.verbs += /obj/admins/proc/votekill 				//abort vote

			src.verbs += /client/proc/give_spell
			src.verbs += /client/proc/cmd_admin_alienize
			src.verbs += /client/proc/cmd_admin_changelinginize
			src.verbs += /client/proc/cmd_admin_abominize 		// -- TLE
			src.verbs += /client/proc/cmd_admin_monkeyize
			src.verbs += /client/proc/cmd_admin_robotize
			src.verbs += /client/proc/make_cultist 				// -- TLE
			src.verbs += /client/proc/respawn_character			//N

			src.verbs += /client/proc/Getmob
			src.verbs += /client/proc/sendmob
			src.verbs += /client/proc/Jump
			src.verbs += /client/proc/jumptokey
			src.verbs += /client/proc/jumptomob
			src.verbs += /client/proc/jumptoturf

			src.verbs += /client/proc/cmd_admin_add_freeform_ai_law
			src.verbs += /client/proc/cmd_admin_add_random_ai_law

			src.verbs += /client/proc/secrets
			src.verbs += /client/proc/cmd_admin_godmode
			src.verbs += /client/proc/cmd_admin_rejuvenate
			src.verbs += /client/proc/cmd_admin_grantfullaccess
			src.verbs += /client/proc/cmd_admin_gib
			src.verbs += /client/proc/cmd_admin_gib_self
			src.verbs += /client/proc/cmd_admin_explosion
			src.verbs += /client/proc/cmd_admin_emp
			src.verbs += /client/proc/cmd_admin_delete
			src.verbs += /client/proc/cmd_admin_drop_everything
			src.verbs += /client/proc/cmd_admin_prison
			src.verbs += /obj/admins/proc/unprison
			src.verbs += /proc/togglebuildmode

			// Unnecessary commands
			src.verbs += /client/proc/funbutton
			src.verbs += /client/proc/make_sound 				// -- TLE
			src.verbs += /client/proc/object_talk 				// -- TLE
			src.verbs += /client/proc/play_sound
			src.verbs += /client/proc/cuban_pete 				// -- Urist
			src.verbs += /client/proc/only_one  				// muskets
			src.verbs += /client/proc/space_asshole 			// --Agouri :3
			src.verbs += /client/proc/strike_team				//N
			src.verbs += /client/proc/space_ninja				//N
			src.verbs += /client/proc/spawn_xeno				//N
			src.verbs += /proc/possess
			src.verbs += /proc/release

//			src.verbs += /obj/admins/proc/togglegoonsay
//			src.verbs += /client/proc/grillify
//			src.verbs += /client/proc/cmd_admin_list_admins
//			src.verbs += /client/proc/getmobs

		if ("Game Admin")
			src.deadchat = 1
			src.holder.level = 5

			// Settings
			//src.verbs += /client/proc/colorooc 				// -- Urist
			src.verbs += /obj/admins/proc/adjump				//toggle admin jumping
			src.verbs += /obj/admins/proc/adrev					//toggle admin revives
			src.verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			src.verbs += /obj/admins/proc/delay					//game start delay
			src.verbs += /obj/admins/proc/toggleaban			//abandon mob
			src.verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			src.verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
			src.verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			src.verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//src.verbs += /obj/admins/proc/toggle_aliens
			src.verbs += /obj/admins/proc/voteres 				//toggle votes
			src.verbs += /client/proc/deadchat					//toggles deadchat
			src.verbs += /proc/toggle_adminmsg
			src.verbs += /client/proc/cmd_mass_modify_object_variables
			// Admin "must have"
			src.verbs += /client/proc/cmd_admin_list_occ
			src.verbs += /client/proc/cmd_admin_mute
			src.verbs += /client/proc/cmd_admin_pm
			src.verbs += /client/proc/cmd_admin_direct_narrate 	// -- TLE
			src.verbs += /client/proc/cmd_admin_say
			src.verbs += /client/proc/cmd_admin_subtle_message
			src.verbs += /client/proc/cmd_admin_world_narrate 	// -- TLE
			src.verbs += /client/proc/get_admin_state
			src.verbs += /client/proc/warn
			src.verbs += /obj/admins/proc/announce				//global announce
			src.verbs += /obj/admins/proc/immreboot				//immediate reboot
			src.verbs += /obj/admins/proc/restart				//restart
			src.verbs += /obj/admins/proc/startnow				//start now bitch

			// Debug
			src.verbs += /client/proc/restartcontroller //exactly what it sounds like
			src.verbs += /client/proc/atmosscan //for locating piping breaks
			src.verbs += /client/proc/debug_variables
			src.verbs += /client/proc/cmd_modify_object_variables
			src.verbs += /client/proc/cmd_modify_ticker_variables
			src.verbs += /client/proc/general_report
			src.verbs += /client/proc/air_report
			src.verbs += /client/proc/air_status
			src.verbs += /client/proc/radio_report
			//src.verbs += /client/proc/kill_air // -- TLE
			src.verbs += /client/proc/modifytemperature
			src.verbs += /client/proc/callproc
			src.verbs += /client/proc/Cell
			src.verbs += /client/proc/cmd_debug_del_all
			src.verbs += /client/proc/cmd_debug_tog_aliens
			src.verbs += /client/proc/Debug2					//debug toggle switch
			src.verbs += /client/proc/fix_next_move
			src.verbs += /client/proc/ticklag
			src.verbs += /proc/givetestverbs
			src.verbs += /obj/admins/proc/spawn_atom
			src.verbs += /obj/admins/proc/toggletintedweldhelmets

			// Admin helpers
			src.verbs += /client/proc/cmd_admin_attack_log
			src.verbs += /client/proc/cmd_admin_check_contents
			src.verbs += /client/proc/check_words // -- Urist
			src.verbs += /client/proc/dsay
			src.verbs += /client/proc/jobbans
			src.verbs += /client/proc/toggle_view_range

			// Admin game intrusion
			src.verbs += /client/proc/cmd_admin_remove_plasma
			src.verbs += /client/proc/drop_bomb 				// -- TLE

			src.verbs += /client/proc/admin_call_shuttle 		// -- Skie
			src.verbs += /client/proc/admin_cancel_shuttle 		// -- Skie
			src.verbs += /client/proc/cmd_admin_create_centcom_report
			src.verbs += /obj/admins/proc/vmode   				//start vote
			src.verbs += /obj/admins/proc/votekill 				//abort vote

			src.verbs += /client/proc/give_spell
			src.verbs += /client/proc/cmd_admin_alienize
			src.verbs += /client/proc/cmd_admin_changelinginize
			src.verbs += /client/proc/cmd_admin_abominize 		// -- TLE
			src.verbs += /client/proc/cmd_admin_monkeyize
			src.verbs += /client/proc/cmd_admin_robotize
			src.verbs += /client/proc/make_cultist 				// -- TLE
			src.verbs += /client/proc/respawn_character			//N

			src.verbs += /client/proc/Getmob
			src.verbs += /client/proc/sendmob
			src.verbs += /client/proc/Jump
			src.verbs += /client/proc/jumptokey
			src.verbs += /client/proc/jumptomob
			src.verbs += /client/proc/jumptoturf

			src.verbs += /client/proc/cmd_admin_add_freeform_ai_law
			src.verbs += /client/proc/cmd_admin_add_random_ai_law

			src.verbs += /client/proc/secrets
			src.verbs += /client/proc/cmd_admin_godmode
			src.verbs += /client/proc/cmd_admin_rejuvenate
			src.verbs += /client/proc/cmd_admin_grantfullaccess
			src.verbs += /client/proc/cmd_admin_gib
			src.verbs += /client/proc/cmd_admin_gib_self
			src.verbs += /client/proc/cmd_admin_explosion
			src.verbs += /client/proc/cmd_admin_emp
			src.verbs += /client/proc/cmd_admin_delete
			src.verbs += /client/proc/cmd_admin_drop_everything
			src.verbs += /client/proc/cmd_admin_prison
			src.verbs += /obj/admins/proc/unprison
			src.verbs += /proc/togglebuildmode

			// Unnecessary commands
			src.verbs += /client/proc/funbutton
			src.verbs += /client/proc/make_sound 				// -- TLE
			//src.verbs += /client/proc/object_talk 			// -- TLE
			src.verbs += /client/proc/play_sound
			src.verbs += /client/proc/cuban_pete 				// -- Urist
			src.verbs += /client/proc/only_one  				// muskets
			src.verbs += /client/proc/space_asshole 			// --Agouri :3
			//src.verbs += /client/proc/strike_team				//N
			src.verbs += /client/proc/space_ninja				//N
			src.verbs += /client/proc/spawn_xeno				//N
			src.verbs += /proc/possess
			src.verbs += /proc/release

			// Old and unused
//			src.verbs += /obj/admins/proc/togglegoonsay
//			src.verbs += /client/proc/grillify
//			src.verbs += /client/proc/cmd_admin_list_admins
//			src.verbs += /client/proc/getmobs

		if ("Badmin")
			src.deadchat = 1
			src.holder.level = 4

			// Settings
			//src.verbs += /client/proc/colorooc 				// -- Urist
			src.verbs += /obj/admins/proc/adjump				//toggle admin jumping
			src.verbs += /obj/admins/proc/adrev					//toggle admin revives
			src.verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			src.verbs += /obj/admins/proc/delay					//game start delay
			src.verbs += /obj/admins/proc/toggleaban			//abandon mob
			src.verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			src.verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
			src.verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			src.verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//src.verbs += /obj/admins/proc/toggle_aliens
			src.verbs += /obj/admins/proc/voteres 				//toggle votes
			src.verbs += /client/proc/deadchat					//toggles deadchat
			src.verbs += /proc/toggle_adminmsg

			// Admin "must have"
			//src.verbs += /client/proc/cmd_admin_list_occ
			src.verbs += /client/proc/cmd_admin_mute
			src.verbs += /client/proc/cmd_admin_pm
			//src.verbs += /client/proc/cmd_admin_direct_narrate 	// -- TLE
			src.verbs += /client/proc/cmd_admin_say
			src.verbs += /client/proc/cmd_admin_subtle_message
			//src.verbs += /client/proc/cmd_admin_world_narrate 	// -- TLE
			//src.verbs += /client/proc/get_admin_state
			src.verbs += /client/proc/warn
			src.verbs += /obj/admins/proc/announce				//global announce
			src.verbs += /obj/admins/proc/immreboot				//immediate reboot
			src.verbs += /obj/admins/proc/restart				//restart
			src.verbs += /obj/admins/proc/startnow				//start now bitch

			// Debug
			src.verbs += /client/proc/debug_variables
			src.verbs += /client/proc/cmd_modify_object_variables
			src.verbs += /client/proc/cmd_modify_ticker_variables
			src.verbs += /client/proc/general_report
			src.verbs += /client/proc/air_report
			src.verbs += /client/proc/air_status
			src.verbs += /client/proc/radio_report
			//src.verbs += /client/proc/kill_air // -- TLE
			src.verbs += /client/proc/modifytemperature
			//src.verbs += /client/proc/callproc
			//src.verbs += /client/proc/Cell
			//src.verbs += /client/proc/cmd_debug_del_all
			//src.verbs += /client/proc/cmd_debug_tog_aliens
			src.verbs += /client/proc/Debug2					//debug toggle switch
			src.verbs += /client/proc/fix_next_move
			//src.verbs += /client/proc/ticklag
			//src.verbs += /proc/givetestverbs
			//src.verbs += /obj/admins/proc/spawn_atom
			src.verbs += /obj/admins/proc/toggletintedweldhelmets

			// Admin helpers
			src.verbs += /client/proc/cmd_admin_attack_log
			src.verbs += /client/proc/cmd_admin_check_contents
			//src.verbs += /client/proc/check_words 			// -- Urist
			src.verbs += /client/proc/dsay
			src.verbs += /client/proc/jobbans
			src.verbs += /client/proc/toggle_view_range

			// Admin game intrusion
			src.verbs += /client/proc/cmd_admin_remove_plasma
			//src.verbs += /client/proc/drop_bomb 				// -- TLE

			src.verbs += /client/proc/admin_call_shuttle 		// -- Skie
			src.verbs += /client/proc/admin_cancel_shuttle 		// -- Skie
			src.verbs += /client/proc/cmd_admin_create_centcom_report
			src.verbs += /obj/admins/proc/vmode   				//start vote
			src.verbs += /obj/admins/proc/votekill 				//abort vote

			//src.verbs += /client/proc/cmd_admin_alienize
			//src.verbs += /client/proc/cmd_admin_changelinginize
			//src.verbs += /client/proc/cmd_admin_abominize 	// -- TLE
			src.verbs += /client/proc/cmd_admin_monkeyize
			src.verbs += /client/proc/cmd_admin_robotize
			//src.verbs += /client/proc/make_cultist 				// -- TLE
			src.verbs += /client/proc/respawn_character			//N

			src.verbs += /client/proc/Getmob
			src.verbs += /client/proc/sendmob
			src.verbs += /client/proc/Jump
			src.verbs += /client/proc/jumptokey
			src.verbs += /client/proc/jumptomob
			src.verbs += /client/proc/jumptoturf

			src.verbs += /client/proc/cmd_admin_add_freeform_ai_law
			src.verbs += /client/proc/cmd_admin_add_random_ai_law

			src.verbs += /client/proc/secrets
			src.verbs += /client/proc/cmd_admin_godmode
			src.verbs += /client/proc/cmd_admin_rejuvenate
			//src.verbs += /client/proc/cmd_admin_grantfullaccess
			src.verbs += /client/proc/cmd_admin_gib
			src.verbs += /client/proc/cmd_admin_gib_self
			//src.verbs += /client/proc/cmd_admin_explosion
			//src.verbs += /client/proc/cmd_admin_emp
			src.verbs += /client/proc/cmd_admin_delete
			src.verbs += /client/proc/cmd_admin_drop_everything
			src.verbs += /client/proc/cmd_admin_prison
			src.verbs += /obj/admins/proc/unprison
			src.verbs += /proc/togglebuildmode

			// Unnecessary commands
			//src.verbs += /client/proc/funbutton
			//src.verbs += /client/proc/make_sound 				// -- TLE
			//src.verbs += /client/proc/object_talk 			// -- TLE
			src.verbs += /client/proc/play_sound
			//src.verbs += /client/proc/cuban_pete 				// -- Urist
			//src.verbs += /client/proc/space_asshole 			// --Agouri :3
			//src.verbs += /client/proc/strike_team				//N
			src.verbs += /client/proc/space_ninja				//N
			src.verbs += /client/proc/spawn_xeno				//N
			src.verbs += /proc/possess
			src.verbs += /proc/release

			// Old and unused
//			src.verbs += /obj/admins/proc/togglegoonsay
//			src.verbs += /client/proc/grillify
//			src.verbs += /client/proc/cmd_admin_list_admins
//			src.verbs += /client/proc/getmobs

		if ("Trial Admin")
			src.deadchat = 1
			src.holder.level = 3

			if(src.holder.state == 2) // if observing
				// Settings
				src.verbs += /obj/admins/proc/toggleaban			//abandon mob
				src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
				src.verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
				src.verbs += /obj/admins/proc/toggletraitorscaling

				// Admin "must have"

				// Debug
				src.verbs += /client/proc/debug_variables
				src.verbs += /client/proc/cmd_modify_object_variables
				src.verbs += /client/proc/cmd_modify_ticker_variables

				// Admin helpers
				src.verbs += /client/proc/toggle_view_range

				// Admin game intrusion
				src.verbs += /client/proc/Getmob
				src.verbs += /client/proc/sendmob
				src.verbs += /client/proc/Jump
				src.verbs += /client/proc/jumptokey
				src.verbs += /client/proc/jumptomob
				src.verbs += /client/proc/jumptoturf

				src.verbs += /client/proc/cmd_admin_add_freeform_ai_law
				src.verbs += /client/proc/cmd_admin_rejuvenate
				src.verbs += /client/proc/cmd_admin_drop_everything

			// Settings
			//src.verbs += /client/proc/colorooc 				// -- Urist
			src.verbs += /obj/admins/proc/adjump				//toggle admin jumping
			src.verbs += /obj/admins/proc/adrev					//toggle admin revives
			src.verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			src.verbs += /obj/admins/proc/delay					//game start delay
			//src.verbs += /obj/admins/proc/toggleaban			//abandon mob
			src.verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			src.verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			//src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
			//src.verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			//src.verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//src.verbs += /obj/admins/proc/toggle_aliens
			src.verbs += /obj/admins/proc/voteres 				//toggle votes
			src.verbs += /client/proc/deadchat					//toggles deadchat
			src.verbs += /proc/toggle_adminmsg

			// Admin "must have"
			//src.verbs += /client/proc/cmd_admin_list_occ
			src.verbs += /client/proc/cmd_admin_mute
			src.verbs += /client/proc/cmd_admin_pm
			//src.verbs += /client/proc/cmd_admin_direct_narrate 	// -- TLE
			src.verbs += /client/proc/cmd_admin_say
			src.verbs += /client/proc/cmd_admin_subtle_message
			//src.verbs += /client/proc/cmd_admin_world_narrate 	// -- TLE
			//src.verbs += /client/proc/get_admin_state
			src.verbs += /client/proc/warn
			src.verbs += /obj/admins/proc/announce				//global announce
			src.verbs += /obj/admins/proc/immreboot				//immediate reboot
			src.verbs += /obj/admins/proc/restart				//restart
			src.verbs += /obj/admins/proc/startnow				//start now bitch

			// Debug
			//src.verbs += /client/proc/debug_variables
			//src.verbs += /client/proc/cmd_modify_object_variables
			//src.verbs += /client/proc/cmd_modify_ticker_variables
			src.verbs += /client/proc/general_report
			src.verbs += /client/proc/air_report
			src.verbs += /client/proc/air_status
			src.verbs += /client/proc/radio_report
			//src.verbs += /client/proc/kill_air // -- TLE
			//src.verbs += /client/proc/modifytemperature
			//src.verbs += /client/proc/callproc
			//src.verbs += /client/proc/Cell
			//src.verbs += /client/proc/cmd_debug_del_all
			//src.verbs += /client/proc/cmd_debug_tog_aliens
			//src.verbs += /client/proc/Debug2					//debug toggle switch
			//src.verbs += /client/proc/fix_next_move
			//src.verbs += /client/proc/ticklag
			//src.verbs += /proc/givetestverbs
			//src.verbs += /obj/admins/proc/spawn_atom
			src.verbs += /obj/admins/proc/toggletintedweldhelmets

			// Admin helpers
			src.verbs += /client/proc/cmd_admin_attack_log
			src.verbs += /client/proc/cmd_admin_check_contents
			//src.verbs += /client/proc/check_words 			// -- Urist
			src.verbs += /client/proc/dsay
			src.verbs += /client/proc/jobbans
			//src.verbs += /client/proc/toggle_view_range

			// Admin game intrusion
			src.verbs += /client/proc/cmd_admin_remove_plasma
			//src.verbs += /client/proc/drop_bomb 				// -- TLE

			src.verbs += /client/proc/admin_call_shuttle 		// -- Skie
			src.verbs += /client/proc/admin_cancel_shuttle 		// -- Skie
			src.verbs += /client/proc/cmd_admin_create_centcom_report
			src.verbs += /obj/admins/proc/vmode   				//start vote
			src.verbs += /obj/admins/proc/votekill 				//abort vote

			//src.verbs += /client/proc/cmd_admin_alienize
			//src.verbs += /client/proc/cmd_admin_changelinginize
			//src.verbs += /client/proc/cmd_admin_abominize 	// -- TLE
			src.verbs += /client/proc/cmd_admin_monkeyize
			src.verbs += /client/proc/cmd_admin_robotize
			//src.verbs += /client/proc/make_cultist 				// -- TLE
			src.verbs += /client/proc/respawn_character			//N

			//src.verbs += /client/proc/Getmob
			//src.verbs += /client/proc/sendmob
			//src.verbs += /client/proc/Jump
			//src.verbs += /client/proc/jumptokey
			//src.verbs += /client/proc/jumptomob
			//src.verbs += /client/proc/jumptoturf

			//src.verbs += /client/proc/cmd_admin_add_freeform_ai_law
			src.verbs += /client/proc/cmd_admin_add_random_ai_law

			src.verbs += /client/proc/secrets
			//src.verbs += /client/proc/cmd_admin_godmode
			//src.verbs += /client/proc/cmd_admin_rejuvenate
			//src.verbs += /client/proc/cmd_admin_grantfullaccess
			//src.verbs += /client/proc/cmd_admin_gib
			src.verbs += /client/proc/cmd_admin_gib_self
			//src.verbs += /client/proc/cmd_admin_explosion
			//src.verbs += /client/proc/cmd_admin_emp
			//src.verbs += /client/proc/cmd_admin_delete
			//src.verbs += /client/proc/cmd_admin_drop_everything
			src.verbs += /client/proc/cmd_admin_prison
			src.verbs += /obj/admins/proc/unprison
			//src.verbs += /proc/togglebuildmode

			// Unnecessary commands
			//src.verbs += /client/proc/funbutton
			//src.verbs += /client/proc/make_sound 				// -- TLE
			//src.verbs += /client/proc/object_talk 			// -- TLE
			src.verbs += /client/proc/play_sound
			//src.verbs += /client/proc/cuban_pete 				// -- Urist
			//src.verbs += /client/proc/space_asshole 			// --Agouri :3
			//src.verbs += /client/proc/strike_team				//N
			//src.verbs += /client/proc/space_ninja				//N
			src.verbs += /client/proc/spawn_xeno				//N
			src.verbs += /proc/possess
			src.verbs += /proc/release

			// Old and unused
//			src.verbs += /obj/admins/proc/togglegoonsay
//			src.verbs += /client/proc/grillify
//			src.verbs += /client/proc/cmd_admin_list_admins
//			src.verbs += /client/proc/getmobs

		if ("Admin Candidate")
			src.holder.level = 2

			if(src.holder.state == 2) // if observing
				src.deadchat = 1

				// Settings
				src.verbs += /obj/admins/proc/toggleaban			//abandon mob
				src.verbs += /client/proc/deadchat					//toggles deadchat

				// Admin "must have"

				// Debug

				// Admin helpers
				src.verbs += /client/proc/cmd_admin_attack_log
				src.verbs += /client/proc/cmd_admin_check_contents

				// Admin game intrusion
				src.verbs += /client/proc/Jump
				src.verbs += /client/proc/jumptokey
				src.verbs += /client/proc/jumptomob

			// Settings
			//src.verbs += /client/proc/colorooc 				// -- Urist
			//src.verbs += /obj/admins/proc/adjump				//toggle admin jumping
			//src.verbs += /obj/admins/proc/adrev					//toggle admin revives
			//src.verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			src.verbs += /obj/admins/proc/delay					//game start delay
			//src.verbs += /obj/admins/proc/toggleaban			//abandon mob
			src.verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			src.verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			//src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
			//src.verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			//src.verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//src.verbs += /obj/admins/proc/toggle_aliens
			src.verbs += /obj/admins/proc/voteres 				//toggle votes
			src.verbs += /client/proc/deadchat					//toggles deadchat
			//src.verbs += /proc/toggle_adminmsg

			// Admin "must have"
			//src.verbs += /client/proc/cmd_admin_list_occ
			src.verbs += /client/proc/cmd_admin_mute
			src.verbs += /client/proc/cmd_admin_pm
			//src.verbs += /client/proc/cmd_admin_direct_narrate 	// -- TLE
			src.verbs += /client/proc/cmd_admin_say
			src.verbs += /client/proc/cmd_admin_subtle_message
			//src.verbs += /client/proc/cmd_admin_world_narrate 	// -- TLE
			//src.verbs += /client/proc/get_admin_state
			src.verbs += /client/proc/warn
			src.verbs += /obj/admins/proc/announce				//global announce
			src.verbs += /obj/admins/proc/immreboot				//immediate reboot
			src.verbs += /obj/admins/proc/restart				//restart
			src.verbs += /obj/admins/proc/startnow				//start now bitch

			// Debug
			//src.verbs += /client/proc/debug_variables
			//src.verbs += /client/proc/cmd_modify_object_variables
			//src.verbs += /client/proc/cmd_modify_ticker_variables
			src.verbs += /client/proc/general_report
			src.verbs += /client/proc/air_report
			src.verbs += /client/proc/air_status
			src.verbs += /client/proc/radio_report
			//src.verbs += /client/proc/kill_air // -- TLE
			//src.verbs += /client/proc/modifytemperature
			//src.verbs += /client/proc/callproc
			//src.verbs += /client/proc/Cell
			//src.verbs += /client/proc/cmd_debug_del_all
			//src.verbs += /client/proc/cmd_debug_tog_aliens
			//src.verbs += /client/proc/Debug2					//debug toggle switch
			//src.verbs += /client/proc/fix_next_move
			//src.verbs += /client/proc/ticklag
			//src.verbs += /proc/givetestverbs
			//src.verbs += /obj/admins/proc/spawn_atom
			src.verbs += /obj/admins/proc/toggletintedweldhelmets

			// Admin helpers
			//src.verbs += /client/proc/cmd_admin_attack_log
			//src.verbs += /client/proc/cmd_admin_check_contents
			//src.verbs += /client/proc/check_words 			// -- Urist
			src.verbs += /client/proc/dsay
			src.verbs += /client/proc/jobbans
			//src.verbs += /client/proc/toggle_view_range

			// Admin game intrusion
			//src.verbs += /client/proc/cmd_admin_remove_plasma
			//src.verbs += /client/proc/drop_bomb 				// -- TLE

			//src.verbs += /client/proc/admin_call_shuttle 		// -- Skie
			//src.verbs += /client/proc/admin_cancel_shuttle 		// -- Skie
			src.verbs += /client/proc/cmd_admin_create_centcom_report
			src.verbs += /obj/admins/proc/vmode   				//start vote
			src.verbs += /obj/admins/proc/votekill 				//abort vote

			//src.verbs += /client/proc/cmd_admin_alienize
			//src.verbs += /client/proc/cmd_admin_changelinginize
			//src.verbs += /client/proc/cmd_admin_abominize 	// -- TLE
			//src.verbs += /client/proc/cmd_admin_monkeyize
			//src.verbs += /client/proc/cmd_admin_robotize
			//src.verbs += /client/proc/make_cultist 				// -- TLE
			//src.verbs += /client/proc/respawn_character			//N

			//src.verbs += /client/proc/Getmob
			//src.verbs += /client/proc/sendmob
			//src.verbs += /client/proc/Jump
			//src.verbs += /client/proc/jumptokey
			//src.verbs += /client/proc/jumptomob
			//src.verbs += /client/proc/jumptoturf

			//src.verbs += /client/proc/cmd_admin_add_freeform_ai_law
			src.verbs += /client/proc/cmd_admin_add_random_ai_law

			src.verbs += /client/proc/secrets
			//src.verbs += /client/proc/cmd_admin_godmode
			//src.verbs += /client/proc/cmd_admin_rejuvenate
			//src.verbs += /client/proc/cmd_admin_grantfullaccess
			//src.verbs += /client/proc/cmd_admin_gib
			src.verbs += /client/proc/cmd_admin_gib_self
			//src.verbs += /client/proc/cmd_admin_explosion
			//src.verbs += /client/proc/cmd_admin_emp
			//src.verbs += /client/proc/cmd_admin_delete
			//src.verbs += /client/proc/cmd_admin_drop_everything
			src.verbs += /client/proc/cmd_admin_prison
			src.verbs += /obj/admins/proc/unprison
			//src.verbs += /proc/togglebuildmode

			// Unnecessary commands
			//src.verbs += /client/proc/funbutton
			//src.verbs += /client/proc/make_sound 				// -- TLE
			//src.verbs += /client/proc/object_talk 			// -- TLE
			src.verbs += /client/proc/play_sound
			//src.verbs += /client/proc/cuban_pete 				// -- Urist
			//src.verbs += /client/proc/space_asshole 			// --Agouri :3
			//src.verbs += /client/proc/strike_team				//N
			//src.verbs += /client/proc/space_ninja				//N
			//src.verbs += /client/proc/spawn_xeno				//N
			//src.verbs += /proc/possess
			//src.verbs += /proc/release

			// Old and unused
//			src.verbs += /obj/admins/proc/togglegoonsay
//			src.verbs += /client/proc/grillify
//			src.verbs += /client/proc/cmd_admin_list_admins
//			src.verbs += /client/proc/getmobs

		if ("Temporary Admin")
			src.holder.level = 1

			if(src.holder.state == 2) // if observing
				// Settings
				src.verbs += /obj/admins/proc/toggleaban			//abandon mob
				src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
				src.verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc

				// Admin "must have"

				// Debug

				// Admin helpers
				src.verbs += /client/proc/cmd_admin_attack_log
				src.verbs += /client/proc/cmd_admin_check_contents

				// Admin game intrusion

			// Settings
			//src.verbs += /client/proc/colorooc 				// -- Urist
			//src.verbs += /obj/admins/proc/adjump				//toggle admin jumping
			//src.verbs += /obj/admins/proc/adrev					//toggle admin revives
			//src.verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			src.verbs += /obj/admins/proc/delay					//game start delay
			//src.verbs += /obj/admins/proc/toggleaban			//abandon mob
			src.verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			src.verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			//src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
			//src.verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			//src.verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//src.verbs += /obj/admins/proc/toggle_aliens
			src.verbs += /obj/admins/proc/voteres 				//toggle votes
			src.verbs += /client/proc/deadchat					//toggles deadchat
			//src.verbs += /proc/toggle_adminmsg

			// Admin "must have"
			//src.verbs += /client/proc/cmd_admin_list_occ
			src.verbs += /client/proc/cmd_admin_mute
			src.verbs += /client/proc/cmd_admin_pm
			//src.verbs += /client/proc/cmd_admin_direct_narrate 	// -- TLE
			src.verbs += /client/proc/cmd_admin_say
			src.verbs += /client/proc/cmd_admin_subtle_message
			//src.verbs += /client/proc/cmd_admin_world_narrate 	// -- TLE
			//src.verbs += /client/proc/get_admin_state
			src.verbs += /client/proc/warn
			src.verbs += /obj/admins/proc/announce				//global announce
			src.verbs += /obj/admins/proc/immreboot				//immediate reboot
			src.verbs += /obj/admins/proc/restart				//restart
			src.verbs += /obj/admins/proc/startnow				//start now bitch

			// Debug
			//src.verbs += /client/proc/debug_variables
			//src.verbs += /client/proc/cmd_modify_object_variables
			//src.verbs += /client/proc/cmd_modify_ticker_variables
			src.verbs += /client/proc/general_report
			src.verbs += /client/proc/air_report
			src.verbs += /client/proc/air_status
			src.verbs += /client/proc/radio_report
			//src.verbs += /client/proc/kill_air // -- TLE
			//src.verbs += /client/proc/modifytemperature
			//src.verbs += /client/proc/callproc
			//src.verbs += /client/proc/Cell
			//src.verbs += /client/proc/cmd_debug_del_all
			//src.verbs += /client/proc/cmd_debug_tog_aliens
			//src.verbs += /client/proc/Debug2					//debug toggle switch
			//src.verbs += /client/proc/fix_next_move
			//src.verbs += /client/proc/ticklag
			//src.verbs += /proc/givetestverbs
			//src.verbs += /obj/admins/proc/spawn_atom

			// Admin helpers
			//src.verbs += /client/proc/cmd_admin_attack_log
			//src.verbs += /client/proc/cmd_admin_check_contents
			//src.verbs += /client/proc/check_words 			// -- Urist
			src.verbs += /client/proc/dsay
			src.verbs += /client/proc/jobbans
			//src.verbs += /client/proc/toggle_view_range

			// Admin game intrusion
			//src.verbs += /client/proc/cmd_admin_remove_plasma
			//src.verbs += /client/proc/drop_bomb 				// -- TLE

			//src.verbs += /client/proc/admin_call_shuttle 		// -- Skie
			//src.verbs += /client/proc/admin_cancel_shuttle 		// -- Skie
			src.verbs += /client/proc/cmd_admin_create_centcom_report
			src.verbs += /obj/admins/proc/vmode   				//start vote
			src.verbs += /obj/admins/proc/votekill 				//abort vote

			//src.verbs += /client/proc/cmd_admin_alienize
			//src.verbs += /client/proc/cmd_admin_changelinginize
			//src.verbs += /client/proc/cmd_admin_abominize 	// -- TLE
			//src.verbs += /client/proc/cmd_admin_monkeyize
			//src.verbs += /client/proc/cmd_admin_robotize
			//src.verbs += /client/proc/make_cultist 				// -- TLE
			//src.verbs += /client/proc/respawn_character			//N

			//src.verbs += /client/proc/Getmob
			//src.verbs += /client/proc/sendmob
			//src.verbs += /client/proc/Jump
			//src.verbs += /client/proc/jumptokey
			//src.verbs += /client/proc/jumptomob
			//src.verbs += /client/proc/jumptoturf

			//src.verbs += /client/proc/cmd_admin_add_freeform_ai_law
			//src.verbs += /client/proc/cmd_admin_add_random_ai_law

			//src.verbs += /client/proc/secrets
			//src.verbs += /client/proc/cmd_admin_godmode
			//src.verbs += /client/proc/cmd_admin_rejuvenate
			//src.verbs += /client/proc/cmd_admin_grantfullaccess
			//src.verbs += /client/proc/cmd_admin_gib
			src.verbs += /client/proc/cmd_admin_gib_self
			//src.verbs += /client/proc/cmd_admin_explosion
			//src.verbs += /client/proc/cmd_admin_emp
			//src.verbs += /client/proc/cmd_admin_delete
			//src.verbs += /client/proc/cmd_admin_drop_everything
			src.verbs += /client/proc/cmd_admin_prison
			src.verbs += /obj/admins/proc/unprison
			//src.verbs += /proc/togglebuildmode

			// Unnecessary commands
			//src.verbs += /client/proc/funbutton
			//src.verbs += /client/proc/make_sound 				// -- TLE
			//src.verbs += /client/proc/object_talk 			// -- TLE
			//src.verbs += /client/proc/play_sound
			//src.verbs += /client/proc/cuban_pete 				// -- Urist
			//src.verbs += /client/proc/space_asshole 			// --Agouri :3
			//src.verbs += /client/proc/strike_team				//N
			//src.verbs += /client/proc/space_ninja				//N
			//src.verbs += /client/proc/spawn_xeno				//N
			//src.verbs += /proc/possess
			//src.verbs += /proc/release

			// Old and unused
//			src.verbs += /obj/admins/proc/togglegoonsay
//			src.verbs += /client/proc/grillify
//			src.verbs += /client/proc/cmd_admin_list_admins
//			src.verbs += /client/proc/getmobs

		if ("Moderator")
			src.holder.level = 0

			// Settings
			//src.verbs += /client/proc/colorooc 				// -- Urist
			//src.verbs += /obj/admins/proc/adjump				//toggle admin jumping
			//src.verbs += /obj/admins/proc/adrev					//toggle admin revives
			//src.verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			//src.verbs += /obj/admins/proc/delay					//game start delay
			//src.verbs += /obj/admins/proc/toggleaban			//abandon mob
			src.verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			src.verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
			src.verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			//src.verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//src.verbs += /obj/admins/proc/toggle_aliens
			src.verbs += /obj/admins/proc/voteres 				//toggle votes
			src.verbs += /client/proc/deadchat					//toggles deadchat
			src.verbs += /proc/toggle_adminmsg

			// Admin "must have"
			//src.verbs += /client/proc/cmd_admin_list_occ
			src.verbs += /client/proc/cmd_admin_mute
			src.verbs += /client/proc/cmd_admin_pm
			//src.verbs += /client/proc/cmd_admin_direct_narrate 	// -- TLE
			src.verbs += /client/proc/cmd_admin_say
			src.verbs += /client/proc/cmd_admin_subtle_message
			//src.verbs += /client/proc/cmd_admin_world_narrate 	// -- TLE
			//src.verbs += /client/proc/get_admin_state
			src.verbs += /client/proc/warn
			src.verbs += /obj/admins/proc/announce				//global announce
			//src.verbs += /obj/admins/proc/immreboot				//immediate reboot
			//src.verbs += /obj/admins/proc/restart				//restart
			src.verbs += /obj/admins/proc/startnow				//start now bitch

			// Debug
			//src.verbs += /client/proc/debug_variables
			//src.verbs += /client/proc/cmd_modify_object_variables
			//src.verbs += /client/proc/cmd_modify_ticker_variables
			src.verbs += /client/proc/general_report
			src.verbs += /client/proc/air_report
			src.verbs += /client/proc/air_status
			src.verbs += /client/proc/radio_report
			//src.verbs += /client/proc/kill_air // -- TLE
			//src.verbs += /client/proc/modifytemperature
			//src.verbs += /client/proc/callproc
			//src.verbs += /client/proc/Cell
			//src.verbs += /client/proc/cmd_debug_del_all
			//src.verbs += /client/proc/cmd_debug_tog_aliens
			//src.verbs += /client/proc/Debug2					//debug toggle switch
			//src.verbs += /client/proc/fix_next_move
			//src.verbs += /client/proc/ticklag
			//src.verbs += /proc/givetestverbs
			//src.verbs += /obj/admins/proc/spawn_atom

			// Admin helpers
			//src.verbs += /client/proc/cmd_admin_attack_log
			//src.verbs += /client/proc/cmd_admin_check_contents
			//src.verbs += /client/proc/check_words 			// -- Urist
			src.verbs += /client/proc/dsay
			src.verbs += /client/proc/jobbans
			//src.verbs += /client/proc/toggle_view_range

			// Admin game intrusion
			//src.verbs += /client/proc/cmd_admin_remove_plasma
			//src.verbs += /client/proc/drop_bomb 				// -- TLE

			//src.verbs += /client/proc/admin_call_shuttle 		// -- Skie
			//src.verbs += /client/proc/admin_cancel_shuttle 		// -- Skie
			//src.verbs += /client/proc/cmd_admin_create_centcom_report
			src.verbs += /obj/admins/proc/vmode   				//start vote
			src.verbs += /obj/admins/proc/votekill 				//abort vote

			//src.verbs += /client/proc/cmd_admin_alienize
			//src.verbs += /client/proc/cmd_admin_changelinginize
			//src.verbs += /client/proc/cmd_admin_abominize 	// -- TLE
			//src.verbs += /client/proc/cmd_admin_monkeyize
			//src.verbs += /client/proc/cmd_admin_robotize
			//src.verbs += /client/proc/make_cultist 				// -- TLE
			//src.verbs += /client/proc/respawn_character			//N

			//src.verbs += /client/proc/Getmob
			//src.verbs += /client/proc/sendmob
			//src.verbs += /client/proc/Jump
			//src.verbs += /client/proc/jumptokey
			//src.verbs += /client/proc/jumptomob
			//src.verbs += /client/proc/jumptoturf

			//src.verbs += /client/proc/cmd_admin_add_freeform_ai_law
			//src.verbs += /client/proc/cmd_admin_add_random_ai_law

			//src.verbs += /client/proc/secrets
			//src.verbs += /client/proc/cmd_admin_godmode
			//src.verbs += /client/proc/cmd_admin_rejuvenate
			//src.verbs += /client/proc/cmd_admin_grantfullaccess
			//src.verbs += /client/proc/cmd_admin_gib
			src.verbs += /client/proc/cmd_admin_gib_self
			//src.verbs += /client/proc/cmd_admin_explosion
			//src.verbs += /client/proc/cmd_admin_emp
			//src.verbs += /client/proc/cmd_admin_delete
			//src.verbs += /client/proc/cmd_admin_drop_everything
			src.verbs += /client/proc/cmd_admin_prison
			src.verbs += /obj/admins/proc/unprison
			//src.verbs += /proc/togglebuildmode

			// Unnecessary commands
			//src.verbs += /client/proc/funbutton
			//src.verbs += /client/proc/make_sound 				// -- TLE
			//src.verbs += /client/proc/object_talk 			// -- TLE
			//src.verbs += /client/proc/play_sound
			//src.verbs += /client/proc/cuban_pete 				// -- Urist
			//src.verbs += /client/proc/space_asshole 			// --Agouri :3
			//src.verbs += /client/proc/strike_team				//N
			//src.verbs += /client/proc/space_ninja				//N
			//src.verbs += /client/proc/spawn_xeno				//N
			//src.verbs += /proc/possess
			//src.verbs += /proc/release

			// Old and unused
//			src.verbs += /obj/admins/proc/togglegoonsay
//			src.verbs += /client/proc/grillify
//			src.verbs += /client/proc/cmd_admin_list_admins
//			src.verbs += /client/proc/getmobs

		if ("Admin Observer")
			src.holder.level = -1
			src.verbs += /client/proc/cmd_admin_say
			src.verbs += /client/proc/cmd_admin_gib_self

		if ("Banned")
			del(src)
			return

		else
			del(src.holder)
			return

	if (src.holder)
		src.holder.owner = src
		if (src.holder.level > -1)
			src.verbs += /client/proc/stealthadmin
			src.verbs += /client/proc/admin_play
			src.verbs += /client/proc/admin_observe
			src.verbs += /client/proc/voting
			src.verbs += /client/proc/game_panel
			src.verbs += /client/proc/unban_panel
			src.verbs += /client/proc/player_panel

		if(src.holder.level > 1)
			src.verbs += /client/proc/stealth

/client/proc/clear_admin_verbs()
	src.deadchat = 0

	// Verbs manager
	src.verbs -= /client/proc/stealthadmin
	src.verbs -= /client/proc/unstealthadmin

	// Settings
	src.verbs -= /client/proc/colorooc // -- Urist
	src.verbs -= /obj/admins/proc/adjump				//toggle admin jumping
	src.verbs -= /obj/admins/proc/adrev					//toggle admin revives
	src.verbs -= /obj/admins/proc/adspawn				//toggle admin item spawning
	src.verbs -= /obj/admins/proc/delay					//game start delay
	src.verbs -= /obj/admins/proc/toggleaban			//abandon mob
	src.verbs -= /obj/admins/proc/toggleAI				//Toggle the AI
	src.verbs -= /obj/admins/proc/toggleenter			//Toggle enterting
	src.verbs -= /obj/admins/proc/toggleooc				//toggle ooc
	src.verbs -= /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
	src.verbs -= /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
	src.verbs -= /obj/admins/proc/toggle_aliens
	src.verbs -= /obj/admins/proc/voteres 				//toggle votes
	src.verbs -= /client/proc/deadchat					//toggles deadchat
	src.verbs -= /proc/toggle_adminmsg

	// Admin "must have"
	src.verbs -= /client/proc/cmd_admin_list_occ
	src.verbs -= /client/proc/cmd_admin_mute
	src.verbs -= /client/proc/cmd_admin_pm
	src.verbs -= /client/proc/cmd_admin_direct_narrate 	// -- TLE
	//src.verbs -= /client/proc/cmd_admin_say
	src.verbs -= /client/proc/cmd_admin_subtle_message
	src.verbs -= /client/proc/cmd_admin_world_narrate 	// -- TLE
	src.verbs -= /client/proc/get_admin_state
	src.verbs -= /client/proc/warn
	src.verbs -= /obj/admins/proc/announce				//global announce
	src.verbs -= /obj/admins/proc/immreboot				//immediate reboot
	src.verbs -= /obj/admins/proc/restart				//restart
	src.verbs -= /obj/admins/proc/startnow				//start now bitch

	// Debug
	src.verbs -= /client/proc/debug_variables
	src.verbs -= /client/proc/cmd_modify_object_variables
	src.verbs -= /client/proc/cmd_modify_ticker_variables
	src.verbs -= /client/proc/general_report
	src.verbs -= /client/proc/air_report
	src.verbs -= /client/proc/air_status
	src.verbs -= /client/proc/radio_report
	src.verbs -= /client/proc/kill_air // -- TLE
	src.verbs -= /client/proc/modifytemperature
	src.verbs -= /client/proc/callproc
	src.verbs -= /client/proc/Cell
	src.verbs -= /client/proc/cmd_debug_del_all
	src.verbs -= /client/proc/cmd_debug_tog_aliens
	src.verbs -= /client/proc/Debug2					//debug toggle switch
	src.verbs -= /client/proc/fix_next_move
	src.verbs -= /client/proc/ticklag
	src.verbs -= /proc/givetestverbs
	src.verbs -= /obj/admins/proc/spawn_atom
	src.verbs -= /obj/admins/proc/toggletintedweldhelmets
	src.verbs -= /client/proc/atmosscan
	src.verbs -= /client/proc/restartcontroller
	src.verbs -= /client/proc/enable_mapping_debug
	src.verbs -= /client/proc/do_not_use_these
	src.verbs -= /client/proc/camera_view
	src.verbs -= /client/proc/sec_camera_report
	src.verbs -= /client/proc/intercom_view

	// Admin helpers
	src.verbs -= /client/proc/cmd_admin_attack_log
	src.verbs -= /client/proc/cmd_admin_check_contents
	src.verbs -= /client/proc/check_words // -- Urist
	src.verbs -= /client/proc/dsay
	src.verbs -= /client/proc/jobbans
	src.verbs -= /client/proc/toggle_view_range

	// Admin game intrusion
	src.verbs -= /client/proc/cmd_admin_remove_plasma
	src.verbs -= /client/proc/drop_bomb 				// -- TLE

	src.verbs -= /client/proc/admin_call_shuttle 		// -- Skie
	src.verbs -= /client/proc/admin_cancel_shuttle 		// -- Skie
	src.verbs -= /client/proc/cmd_admin_create_centcom_report
	src.verbs -= /obj/admins/proc/vmode   				//start vote
	src.verbs -= /obj/admins/proc/votekill 				//abort vote

	src.verbs -= /client/proc/give_spell
	src.verbs -= /client/proc/cmd_admin_alienize
	src.verbs -= /client/proc/cmd_admin_changelinginize
	src.verbs -= /client/proc/cmd_admin_abominize 		// -- TLE
	src.verbs -= /client/proc/cmd_admin_monkeyize
	src.verbs -= /client/proc/cmd_admin_robotize
	src.verbs -= /client/proc/make_cultist 				// -- TLE
	src.verbs -= /client/proc/respawn_character			//N

	src.verbs -= /client/proc/Getmob
	src.verbs -= /client/proc/sendmob
	src.verbs -= /client/proc/Jump
	src.verbs -= /client/proc/jumptokey
	src.verbs -= /client/proc/jumptomob
	src.verbs -= /client/proc/jumptoturf

	src.verbs -= /client/proc/cmd_admin_add_freeform_ai_law
	src.verbs -= /client/proc/cmd_admin_add_random_ai_law

	src.verbs -= /client/proc/secrets
	src.verbs -= /client/proc/cmd_admin_godmode
	src.verbs -= /client/proc/cmd_admin_rejuvenate
	src.verbs -= /client/proc/cmd_admin_grantfullaccess
	src.verbs -= /client/proc/cmd_admin_gib
	src.verbs -= /client/proc/cmd_admin_gib_self
	src.verbs -= /client/proc/cmd_admin_explosion
	src.verbs -= /client/proc/cmd_admin_emp
	src.verbs -= /client/proc/cmd_admin_delete
	src.verbs -= /client/proc/cmd_admin_drop_everything
	src.verbs -= /client/proc/cmd_admin_prison
	src.verbs -= /obj/admins/proc/unprison
	src.verbs -= /proc/togglebuildmode
	src.verbs -= /client/proc/cmd_mass_modify_object_variables

	src.verbs -= /client/proc/triple_ai
	src.verbs -= /client/proc/only_one
	// Unnecessary commands
	src.verbs -= /client/proc/funbutton
	src.verbs -= /client/proc/make_sound 				// -- TLE
	src.verbs -= /client/proc/object_talk 				// -- TLE
	src.verbs -= /client/proc/play_sound
	src.verbs -= /client/proc/cuban_pete 				// -- Urist
	src.verbs -= /client/proc/space_asshole 			// --Agouri :3
	src.verbs -= /client/proc/strike_team				//N
	src.verbs -= /client/proc/space_ninja				//N
	src.verbs -= /client/proc/spawn_xeno				//N
	src.verbs -= /proc/possess
	src.verbs -= /proc/release

//	src.verbs -= /obj/admins/proc/togglegoonsay
//	src.verbs -= /client/proc/grillify
//	src.verbs -= /client/proc/cmd_admin_list_admins
//	src.verbs -= /client/proc/getmobs

	if(src.holder)
		src.holder.level = 0
		src.holder.owner = src

		src.verbs -= /client/proc/admin_play
		src.verbs -= /client/proc/admin_observe
		src.verbs -= /client/proc/voting
		src.verbs -= /client/proc/game_panel
		src.verbs -= /client/proc/unban_panel
		src.verbs -= /client/proc/player_panel
		src.verbs -= /client/proc/stealth

/client/proc/admin_observe()
	set category = "Admin"
	set name = "Set Observe"
	if(!src.holder)
		alert("You are not an admin")
		return
/*
	if(!src.mob.start)
		alert("You cannot observe while in the starting position")
		return
*/
	src.verbs -= /client/proc/admin_play
	spawn( 1200 )										//change this to 1200
		src.verbs += /client/proc/admin_play
	var/rank = src.holder.rank
	clear_admin_verbs()
	src.holder.state = 2
	update_admins(rank)
	if(!istype(src.mob, /mob/dead/observer))
		src.mob.adminghostize(1)
	src << "\blue You are now observing"

/client/proc/admin_play()
	set category = "Admin"
	set name = "Set Play"
	if(!src.holder)
		alert("You are not an admin")
		return
	src.verbs -= /client/proc/admin_observe
	spawn( 1200 )										//change this to 1200
		src.verbs += /client/proc/admin_observe
	var/rank = src.holder.rank
	clear_admin_verbs()
	src.holder.state = 1
	update_admins(rank)
	if(istype(src.mob, /mob/dead/observer))
		src.mob:reenter_corpse()
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

//admin client procs ported over from mob.dm

/client/proc/player_panel()
	set name = "Player Panel"
	set category = "Admin"
	if (src.holder)
		src.holder.player()
	return

/client/proc/jobbans()
	set name = "Display Job bans"
	set category = "Admin"
	if(src.holder)
		src.holder.Jobbans()
	return

/client/proc/unban_panel()
	set name = "Unban Panel"
	set category = "Admin"
	if (src.holder)
		src.holder.unbanpanel()
	return

/client/proc/game_panel()
	set name = "Game Panel"
	set category = "Admin"
	if (src.holder)
		src.holder.Game()
	return

/client/proc/secrets()
	set name = "Secrets"
	set category = "Admin"
	if (src.holder)
		src.holder.Secrets()
	return
/*
/client/proc/goons()
	set name = "Goons"
	set category = "Admin"
	if (src.holder)
		src.holder.goons()
	return

/client/proc/beta_testers()
	set name = "Testers"
	set category = "Admin"
	if (src.holder)
		src.holder.beta_testers()
	return
*/
/client/proc/voting()
	set name = "Voting"
	set category = "Admin"
	if (src.holder)
		src.holder.Voting()

/client/proc/funbutton()
	set category = "Fun"
	set name = "Boom Boom Boom Shake The Room"
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	if(alert("BLOW EVERYTHING UP?",,"Yes","No")=="Yes")
		for(var/turf/simulated/floor/T in world)
			if(prob(4) && T.z == 1 && istype(T))
				spawn(50+rand(0,3000))
					explosion(T, rand(1,5), rand(1,6), rand(3,10), 0)

		usr << "\blue Blowing up station ..."

		log_admin("[key_name(usr)] has used boom boom boom shake the room")
		message_admins("[key_name_admin(usr)] has used boom boom boom shake the room", 1)

/client/proc/colorooc()
	set category = "Fun"
	set name = "OOC Text Color"
	src.ooccolor = input(src, "Please select your OOC colour.", "OOC colour") as color
	return

/client/proc/stealth()
	set category = "Admin"
	set name = "Stealth Mode"
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	src.stealth = !src.stealth
	if(src.stealth)
		var/new_key = trim(input("Enter your desired display name.", "Fake Key", src.key))
		if(!new_key)
			src.stealth = 0
			return
		new_key = strip_html(new_key)
		if(length(new_key) >= 26)
			new_key = copytext(new_key, 1, 26)
		src.fakekey = new_key
	else
		src.fakekey = null
	log_admin("[key_name(usr)] has turned stealth mode [src.stealth ? "ON" : "OFF"]")
	message_admins("[key_name_admin(usr)] has turned stealth mode [src.stealth ? "ON" : "OFF"]", 1)


/client/proc/warn(var/mob/M in world)
	set category = "Special Verbs"
	set name = "Warn"
	set desc = "Warn a player"
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	if(M.client && M.client.holder && (M.client.holder.level >= src.holder.level))
		alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
		return
	if(!M.client.warned)
		M << "\red <B>You have been warned by an administrator. This is the only warning you will recieve.</B>"
		M.client.warned = 1
		message_admins("\blue [src.ckey] warned [M.ckey].")
	else
		AddBan(M.ckey, M.computer_id, "Autobanning due to previous warn", src.ckey, 1, 10)
		M << "\red<BIG><B>You have been autobanned by [src.ckey]. This is what we in the biz like to call a \"second warning\".</B></BIG>"
		M << "\red This is a temporary ban; it will automatically be removed in 10 minutes."
		log_admin("[src.ckey] warned [M.ckey], resulting in a 10 minute autoban.")
		message_admins("\blue [src.ckey] warned [M.ckey], resulting in a 10 minute autoban.")

		del(M.client)
		//del(M)

/client/proc/drop_bomb() // Some admin dickery that can probably be done better -- TLE
	set category = "Special Verbs"
	set name = "Drop Bomb"
	set desc = "Cause an explosion of varying strength at your location."
	// Old code - mostly leaving in for legacy reasons. Remove it if you like.
	/*
	set desc = "Spawn a plasma tank with overloaded pressure. Will trigger explosion on next air cycle."
	var/bomb_strength = input("Enter a value greater than 299:", "Blowing Shit Up", 300) as num
	if(bomb_strength < 300)
		return
	if(!src.mob)
		return
	message_admins("\blue [src.ckey] dropping a plasma bomb at [bomb_strength] strength.")
	var/obj/item/weapon/tank/plasma/P = new(src.mob.loc)
	P.air_contents.toxins = bomb_strength
	*/
	var/turf/epicenter = src.mob.loc
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
	message_admins("\blue [src.ckey] creating an admin explosion at [epicenter.loc].")
/*
/client/proc/check_words() // -- Urist
	set category = "Special Verbs"
	set name = "Check Rune Words"
	set desc = "Check the rune-word meaning"
	if(!wordtravel)
		runerandom()
	usr << "[wordtravel] is travel, [wordblood] is blood, [wordjoin] is join, [wordhell] is Hell, [worddestr] is destroy, [wordtech] is technology, [wordself] is self, [wordsee] is see"
*/
/client/proc/give_spell(mob/T as mob in world) // -- Urist
	set category = "Fun"
	set name = "Give Spell"
	set desc = "Gives a spell to a mob."
	var/obj/spell/S = input("Choose the spell to give to that guy", "ABRAKADABRA") in spells
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

/client/proc/object_talk(var/msg as text) // -- TLE
	set category = "Special Verbs"
	set name = "oSay"
	set desc = "Display a message to everyone who can hear the target"
	if(src.mob.control_object)
		if(!msg)
			return
		for (var/mob/V in hearers(src.mob.control_object))
			V.show_message("<b>[src.mob.control_object.name]</b> says: \"" + msg + "\"", 2)

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

/client/proc/unstealthadmin()
	set name = "Toggle admin verb visibility"
	set category = "Admin"
	src << "Here's your rightclick admin verbs back"

	src.verbs -= /client/proc/unstealthadmin
	var/temp = src.deadchat
	src.update_admins(src.holder.rank)
	src.deadchat = temp

/client/proc/stealthadmin()
	set name = "Toggle admin verb visibility"
	set category = "Admin"
	src << "Hiding your rightclick admin verbs so you can play without 'accidentally' gibbing someone"

	var/temp = src.deadchat

	src.clear_admin_verbs()

	src.deadchat = temp

	src.verbs += /client/proc/unstealthadmin

	switch (src.holder.rank)
		if ("Game Master") //Former Host
			// Settings
			//src.verbs += /client/proc/colorooc // -- Urist
			src.verbs += /obj/admins/proc/adjump				//toggle admin jumping
			src.verbs += /obj/admins/proc/adrev					//toggle admin revives
			src.verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			src.verbs += /obj/admins/proc/delay					//game start delay
			src.verbs += /obj/admins/proc/toggleaban			//abandon mob
			src.verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			src.verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
			src.verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			src.verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			src.verbs += /obj/admins/proc/toggle_aliens
			src.verbs += /obj/admins/proc/voteres 				//toggle votes
			src.verbs += /client/proc/deadchat					//toggles deadchat
			src.verbs += /proc/toggle_adminmsg

			// Admin "must have"

			// Debug

			// Admin helpers

			// Admin game intrusion

			// Unnecessary commands

			// Old and unused

		if ("Game Admin") //Former Coder
			// Settings
			//src.verbs += /client/proc/colorooc 				// -- Urist
			src.verbs += /obj/admins/proc/adjump				//toggle admin jumping
			src.verbs += /obj/admins/proc/adrev					//toggle admin revives
			src.verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			src.verbs += /obj/admins/proc/delay					//game start delay
			src.verbs += /obj/admins/proc/toggleaban			//abandon mob
			src.verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			src.verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
			src.verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			src.verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//src.verbs += /obj/admins/proc/toggle_aliens
			src.verbs += /obj/admins/proc/voteres 				//toggle votes
			src.verbs += /client/proc/deadchat					//toggles deadchat
			src.verbs += /proc/toggle_adminmsg

			// Admin "must have"

			// Debug

			// Admin helpers

			// Admin game intrusion

			// Unnecessary commands

			// Old and unused

		if ("Badmin") //Former Shit Guy
			// Settings
			//src.verbs += /client/proc/colorooc 				// -- Urist
			src.verbs += /obj/admins/proc/adjump				//toggle admin jumping
			src.verbs += /obj/admins/proc/adrev					//toggle admin revives
			src.verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			src.verbs += /obj/admins/proc/delay					//game start delay
			src.verbs += /obj/admins/proc/toggleaban			//abandon mob
			src.verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			src.verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
			src.verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			src.verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//src.verbs += /obj/admins/proc/toggle_aliens
			src.verbs += /obj/admins/proc/voteres 				//toggle votes
			src.verbs += /client/proc/deadchat					//toggles deadchat
			src.verbs += /proc/toggle_adminmsg

			// Admin "must have"

			// Debug

			// Admin helpers

			// Admin game intrusion

			// Unnecessary commands

			// Old and unused

		if ("Trial Admin") //Former Primary Administrator
			if(src.holder.state == 2) // if observing
				// Settings
				src.verbs += /obj/admins/proc/toggleaban			//abandon mob
				src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
				src.verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
				src.verbs += /obj/admins/proc/toggletraitorscaling

			// Settings
			//src.verbs += /client/proc/colorooc 				// -- Urist
			src.verbs += /obj/admins/proc/adjump				//toggle admin jumping
			src.verbs += /obj/admins/proc/adrev					//toggle admin revives
			src.verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			src.verbs += /obj/admins/proc/delay					//game start delay
			//src.verbs += /obj/admins/proc/toggleaban			//abandon mob
			src.verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			src.verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			//src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
			//src.verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			//src.verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//src.verbs += /obj/admins/proc/toggle_aliens
			src.verbs += /obj/admins/proc/voteres 				//toggle votes
			src.verbs += /client/proc/deadchat					//toggles deadchat
			src.verbs += /proc/toggle_adminmsg

			// Admin "must have"

			// Debug

			// Admin helpers

			// Admin game intrusion

			// Unnecessary commands

			// Old and unused

		if ("Admin Candidate") //Removed the 'Administrator' rank, has same rights as Trial Admin (Expected that these will be set manually each round)
			if(src.holder.state == 2) // if observing
				// Settings
				src.verbs += /obj/admins/proc/toggleaban			//abandon mob
				src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
				src.verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
				src.verbs += /obj/admins/proc/toggletraitorscaling

			// Settings
			//src.verbs += /client/proc/colorooc 				// -- Urist
			src.verbs += /obj/admins/proc/adjump				//toggle admin jumping
			src.verbs += /obj/admins/proc/adrev					//toggle admin revives
			src.verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			src.verbs += /obj/admins/proc/delay					//game start delay
			//src.verbs += /obj/admins/proc/toggleaban			//abandon mob
			src.verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			src.verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			//src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
			//src.verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			//src.verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//src.verbs += /obj/admins/proc/toggle_aliens
			src.verbs += /obj/admins/proc/voteres 				//toggle votes
			src.verbs += /client/proc/deadchat					//toggles deadchat
			src.verbs += /proc/toggle_adminmsg


		if ("Temporary Admin") //Former Secondary Administrator
			if(src.holder.state == 2) // if observing
				// Settings
				src.verbs += /obj/admins/proc/toggleaban			//abandon mob
				src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
				src.verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc

			// Settings
			//src.verbs += /client/proc/colorooc 				// -- Urist
			//src.verbs += /obj/admins/proc/adjump				//toggle admin jumping
			//src.verbs += /obj/admins/proc/adrev					//toggle admin revives
			//src.verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			src.verbs += /obj/admins/proc/delay					//game start delay
			//src.verbs += /obj/admins/proc/toggleaban			//abandon mob
			src.verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			src.verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			//src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
			//src.verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			//src.verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//src.verbs += /obj/admins/proc/toggle_aliens
			src.verbs += /obj/admins/proc/voteres 				//toggle votes
			src.verbs += /client/proc/deadchat					//toggles deadchat
			//src.verbs += /proc/toggle_adminmsg

			// Admin "must have"

			// Debug

			// Admin helpers

			// Admin game intrusion

			// Unnecessary commands

			// Old and unused

		if ("Moderator") //Former Moderator
			// Settings
			//src.verbs += /client/proc/colorooc 				// -- Urist
			//src.verbs += /obj/admins/proc/adjump				//toggle admin jumping
			//src.verbs += /obj/admins/proc/adrev					//toggle admin revives
			//src.verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			//src.verbs += /obj/admins/proc/delay					//game start delay
			//src.verbs += /obj/admins/proc/toggleaban			//abandon mob
			src.verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			src.verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
			src.verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			//src.verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//src.verbs += /obj/admins/proc/toggle_aliens
			src.verbs += /obj/admins/proc/voteres 				//toggle votes
			src.verbs += /client/proc/deadchat					//toggles deadchat
			src.verbs += /proc/toggle_adminmsg

			// Admin "must have"

			// Debug

			// Admin helpers

			// Admin game intrusion

			// Unnecessary commands

			// Old and unused

		if ("Admin Observer") //Former Filthy Xeno