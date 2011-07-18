//GUYS REMEMBER TO ADD A += to UPDATE_ADMINS
//AND A -= TO CLEAR_ADMIN_VERBS

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
			holder.level = 6

			// Settings
			verbs += /obj/admins/proc/view_txt_log
			verbs += /client/proc/colorooc // -- Urist
			verbs += /obj/admins/proc/adjump				//toggle admin jumping
			verbs += /obj/admins/proc/adrev					//toggle admin revives
			verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			verbs += /obj/admins/proc/delay					//game start delay
			verbs += /obj/admins/proc/toggleaban			//abandon mob
			verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			verbs += /obj/admins/proc/toggleguests			//Toggle guests entering
			verbs += /obj/admins/proc/toggleooc				//toggle ooc
			verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			verbs += /obj/admins/proc/toggle_aliens			//toggle aliens
			verbs += /obj/admins/proc/toggle_space_ninja	//toggle ninjas
			verbs += /obj/admins/proc/voteres 				//toggle votes
			verbs += /client/proc/deadchat					//toggles deadchat
			verbs += /proc/toggle_adminmsg

			verbs += /client/proc/triple_ai					//triple AIs~ --NEO
			verbs += /client/proc/cmd_mass_modify_object_variables
			// Admin "must have"
			verbs += /client/proc/cmd_admin_list_occ
			verbs += /client/proc/cmd_admin_mute
			verbs += /client/proc/cmd_admin_pm
			verbs += /client/proc/cmd_admin_direct_narrate 	// -- TLE
			verbs += /client/proc/cmd_admin_say
			verbs += /client/proc/cmd_admin_subtle_message
			verbs += /client/proc/cmd_admin_world_narrate 	// -- TLE
			verbs += /client/proc/get_admin_state
			verbs += /client/proc/warn
			verbs += /obj/admins/proc/announce				//global announce
			verbs += /obj/admins/proc/immreboot				//immediate reboot
			verbs += /obj/admins/proc/restart				//restart
			verbs += /obj/admins/proc/startnow				//start now bitch

			// Debug
			verbs += /client/proc/restartcontroller //exactly what it sounds like
			verbs += /client/proc/atmosscan //for locating piping breaks
			verbs += /client/proc/debug_variables
			verbs += /client/proc/cmd_modify_object_variables
			verbs += /client/proc/cmd_modify_ticker_variables
			verbs += /client/proc/general_report
			verbs += /client/proc/air_report
			verbs += /client/proc/air_status
			verbs += /client/proc/radio_report
			verbs += /client/proc/reload_admins
			verbs += /client/proc/kill_air // -- TLE
			verbs += /client/proc/modifytemperature
			verbs += /client/proc/callproc
			verbs += /client/proc/Cell
			verbs += /client/proc/cmd_debug_make_powernets
			verbs += /client/proc/cmd_debug_del_all
			verbs += /client/proc/cmd_debug_tog_aliens
			verbs += /client/proc/Debug2					//debug toggle switch
			verbs += /client/proc/fix_next_move
			verbs += /client/proc/ticklag

			verbs += /proc/givetestverbs
			verbs += /obj/admins/proc/spawn_atom
			verbs += /obj/admins/proc/toggletintedweldhelmets

			// Mapping helpers
// 			verbs += /client/proc/do_not_use_these 			//-errorage
// 			verbs += /client/proc/camera_view 				//-errorage
// 			verbs += /client/proc/sec_camera_report 		//-errorage
// 			verbs += /client/proc/intercom_view 			//-errorage
			verbs += /client/proc/enable_mapping_debug 			//-rastaf0

			// Admin helpers
			verbs += /client/proc/cmd_admin_attack_log
			verbs += /client/proc/cmd_admin_check_contents
			verbs += /client/proc/check_words // -- Urist
			verbs += /client/proc/dsay
			verbs += /client/proc/jobbans
			verbs += /client/proc/toggle_view_range

			// Admin game intrusion
			verbs += /client/proc/cmd_admin_remove_plasma
			verbs += /client/proc/drop_bomb 				// -- TLE

			verbs += /client/proc/admin_call_shuttle 		// -- Skie
			verbs += /client/proc/admin_cancel_shuttle 		// -- Skie
			verbs += /client/proc/cmd_admin_create_centcom_report
			verbs += /obj/admins/proc/vmode   				//start vote
			verbs += /obj/admins/proc/votekill 				//abort vote

			verbs += /client/proc/give_spell
			verbs += /obj/admins/proc/edit_memory
			verbs += /obj/admins/proc/edit_player
			verbs += /client/proc/cmd_admin_dress
			//verbs += /client/proc/cmd_admin_alienize
			//verbs += /client/proc/cmd_admin_changelinginize
			//verbs += /client/proc/cmd_admin_abominize 		// -- TLE
			//verbs += /client/proc/cmd_admin_monkeyize
			//verbs += /client/proc/cmd_admin_robotize
			//verbs += /client/proc/make_cultist 				// -- TLE
			verbs += /client/proc/cmd_admin_ninjafy 			//N
			//verbs += /client/proc/makepAI					// -- TLE
			verbs += /client/proc/respawn_character			//N

			verbs += /client/proc/Getmob
			verbs += /client/proc/sendmob
			verbs += /client/proc/Jump
			verbs += /client/proc/jumptokey
			verbs += /client/proc/jumptomob
			verbs += /client/proc/jumptoturf

			verbs += /client/proc/cmd_admin_add_freeform_ai_law
			verbs += /client/proc/cmd_admin_add_random_ai_law

			verbs += /client/proc/secrets
			verbs += /client/proc/cmd_admin_godmode
			verbs += /client/proc/cmd_admin_rejuvenate
			verbs += /client/proc/cmd_admin_grantfullaccess
			verbs += /client/proc/cmd_admin_gib
			verbs += /client/proc/cmd_admin_gib_self
			verbs += /client/proc/cmd_admin_explosion
			verbs += /client/proc/cmd_admin_emp
			verbs += /client/proc/cmd_admin_delete
			verbs += /client/proc/cmd_admin_drop_everything
			verbs += /client/proc/cmd_admin_prison
			verbs += /obj/admins/proc/unprison
			verbs += /proc/togglebuildmode

			// Unnecessary commands
			//verbs += /client/proc/funbutton
			verbs += /client/proc/make_sound 				// -- TLE
			verbs += /client/proc/object_talk 				// -- TLE
			verbs += /client/proc/play_sound
//			verbs += /client/proc/cuban_pete 				// -- Urist
//			verbs += /client/proc/bananaphone				// -- Darem
//			verbs += /client/proc/honk_theme				// -- Urist the Honky
			verbs += /client/proc/only_one  				// muskets
//			verbs += /client/proc/space_asshole 			// --Agouri :3
			verbs += /client/proc/strike_team				//N
			verbs += /client/proc/send_space_ninja			//N
			verbs += /client/proc/spawn_xeno				//N
			verbs += /proc/possess
			verbs += /proc/release
			verbs += /client/proc/unjobban_panel
//			verbs += /obj/admins/proc/togglegoonsay
//			verbs += /client/proc/grillify
//			verbs += /client/proc/cmd_admin_list_admins
//			verbs += /client/proc/getmobs

		if ("Game Admin")
			deadchat = 1
			holder.level = 5

			// Settings
			//verbs += /client/proc/colorooc 				// -- Urist
			verbs += /obj/admins/proc/view_txt_log
			verbs += /obj/admins/proc/adjump				//toggle admin jumping
			verbs += /obj/admins/proc/adrev					//toggle admin revives
			verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			verbs += /obj/admins/proc/delay					//game start delay
			verbs += /obj/admins/proc/toggleaban			//abandon mob
			verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			verbs += /obj/admins/proc/toggleguests			//Toggle guests entering
			verbs += /obj/admins/proc/toggleooc				//toggle ooc
			verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//verbs += /obj/admins/proc/toggle_aliens
			//verbs += /obj/admins/proc/toggle_space_ninja	//toggle ninjas
			verbs += /obj/admins/proc/voteres 				//toggle votes
			verbs += /client/proc/deadchat					//toggles deadchat
			verbs += /proc/toggle_adminmsg
			verbs += /client/proc/cmd_mass_modify_object_variables
			// Admin "must have"
			verbs += /client/proc/cmd_admin_list_occ
			verbs += /client/proc/cmd_admin_mute
			verbs += /client/proc/cmd_admin_pm
			verbs += /client/proc/cmd_admin_direct_narrate 	// -- TLE
			verbs += /client/proc/cmd_admin_say
			verbs += /client/proc/cmd_admin_subtle_message
			verbs += /client/proc/cmd_admin_world_narrate 	// -- TLE
			verbs += /client/proc/get_admin_state
			verbs += /client/proc/warn
			verbs += /obj/admins/proc/announce				//global announce
			verbs += /obj/admins/proc/immreboot				//immediate reboot
			verbs += /obj/admins/proc/restart				//restart
			verbs += /obj/admins/proc/startnow				//start now bitch

			// Debug
			verbs += /client/proc/restartcontroller //exactly what it sounds like
			verbs += /client/proc/atmosscan //for locating piping breaks
			verbs += /client/proc/debug_variables
			verbs += /client/proc/cmd_modify_object_variables
			verbs += /client/proc/cmd_modify_ticker_variables
			verbs += /client/proc/general_report
			verbs += /client/proc/air_report
			verbs += /client/proc/air_status
			verbs += /client/proc/radio_report
			verbs += /client/proc/reload_admins
			//verbs += /client/proc/kill_air // -- TLE
			verbs += /client/proc/modifytemperature
			verbs += /client/proc/callproc
			verbs += /client/proc/Cell
			verbs += /client/proc/cmd_debug_del_all
			verbs += /client/proc/cmd_debug_tog_aliens
			verbs += /client/proc/Debug2					//debug toggle switch
			verbs += /client/proc/fix_next_move
			verbs += /client/proc/ticklag
			verbs += /proc/givetestverbs
			verbs += /obj/admins/proc/spawn_atom
			verbs += /obj/admins/proc/toggletintedweldhelmets

			// Admin helpers
			verbs += /client/proc/cmd_admin_attack_log
			verbs += /client/proc/cmd_admin_check_contents
			verbs += /client/proc/check_words // -- Urist
			verbs += /client/proc/dsay
			verbs += /client/proc/jobbans
			verbs += /client/proc/toggle_view_range

			// Admin game intrusion
			verbs += /client/proc/cmd_admin_remove_plasma
			verbs += /client/proc/drop_bomb 				// -- TLE

			verbs += /client/proc/admin_call_shuttle 		// -- Skie
			verbs += /client/proc/admin_cancel_shuttle 		// -- Skie
			verbs += /client/proc/cmd_admin_create_centcom_report
			verbs += /obj/admins/proc/vmode   				//start vote
			verbs += /obj/admins/proc/votekill 				//abort vote

			verbs += /client/proc/give_spell
			verbs += /obj/admins/proc/edit_memory
			verbs += /obj/admins/proc/edit_player
			verbs += /client/proc/cmd_admin_dress
			//verbs += /client/proc/cmd_admin_alienize
			//verbs += /client/proc/cmd_admin_changelinginize
			//verbs += /client/proc/cmd_admin_abominize 		// -- TLE
			//verbs += /client/proc/cmd_admin_monkeyize
			//verbs += /client/proc/cmd_admin_robotize
			//verbs += /client/proc/make_cultist 				// -- TLE
			verbs += /client/proc/cmd_admin_ninjafy 			//N
			//verbs += /client/proc/makepAI					// -- TLE
			verbs += /client/proc/respawn_character			//N

			verbs += /client/proc/Getmob
			verbs += /client/proc/sendmob
			verbs += /client/proc/Jump
			verbs += /client/proc/jumptokey
			verbs += /client/proc/jumptomob
			verbs += /client/proc/jumptoturf

			verbs += /client/proc/cmd_admin_add_freeform_ai_law
			verbs += /client/proc/cmd_admin_add_random_ai_law

			verbs += /client/proc/secrets
			verbs += /client/proc/cmd_admin_godmode
			verbs += /client/proc/cmd_admin_rejuvenate
			verbs += /client/proc/cmd_admin_grantfullaccess
			verbs += /client/proc/cmd_admin_gib
			verbs += /client/proc/cmd_admin_gib_self
			verbs += /client/proc/cmd_admin_explosion
			verbs += /client/proc/cmd_admin_emp
			verbs += /client/proc/cmd_admin_delete
			verbs += /client/proc/cmd_admin_drop_everything
			verbs += /client/proc/cmd_admin_prison
			verbs += /obj/admins/proc/unprison
			verbs += /proc/togglebuildmode

			// Unnecessary commands
			//verbs += /client/proc/funbutton
			verbs += /client/proc/make_sound 				// -- TLE
			//verbs += /client/proc/object_talk 			// -- TLE
			verbs += /client/proc/play_sound
//			verbs += /client/proc/cuban_pete 				// -- Urist
//			verbs += /client/proc/honk_theme				// -- Urist the Honky
//			verbs += /client/proc/bananaphone
			verbs += /client/proc/only_one  				// muskets
//			verbs += /client/proc/space_asshole 			// --Agouri :3
			//verbs += /client/proc/strike_team				//N
			verbs += /client/proc/send_space_ninja			//N
			verbs += /client/proc/spawn_xeno				//N
			verbs += /proc/possess
			verbs += /proc/release

			// Old and unused
//			verbs += /obj/admins/proc/togglegoonsay
//			verbs += /client/proc/grillify
//			verbs += /client/proc/cmd_admin_list_admins
//			verbs += /client/proc/getmobs

		if ("Badmin")
			deadchat = 1
			holder.level = 4

			// Settings
			//verbs += /client/proc/colorooc 				// -- Urist
			verbs += /obj/admins/proc/adjump				//toggle admin jumping
			verbs += /obj/admins/proc/adrev					//toggle admin revives
			verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			verbs += /obj/admins/proc/delay					//game start delay
			verbs += /obj/admins/proc/toggleaban			//abandon mob
			verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			verbs += /obj/admins/proc/toggleguests			//Toggle guests entering
			verbs += /obj/admins/proc/toggleooc				//toggle ooc
			verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//verbs += /obj/admins/proc/toggle_aliens
			//verbs += /obj/admins/proc/toggle_space_ninja	//toggle ninjas
			verbs += /obj/admins/proc/voteres 				//toggle votes
			verbs += /client/proc/deadchat					//toggles deadchat
			verbs += /proc/toggle_adminmsg

			// Admin "must have"
			//verbs += /client/proc/cmd_admin_list_occ
			verbs += /client/proc/cmd_admin_mute
			verbs += /client/proc/cmd_admin_pm
			//verbs += /client/proc/cmd_admin_direct_narrate 	// -- TLE
			verbs += /client/proc/cmd_admin_say
			verbs += /client/proc/cmd_admin_subtle_message
			//verbs += /client/proc/cmd_admin_world_narrate 	// -- TLE
			//verbs += /client/proc/get_admin_state
			verbs += /client/proc/warn
			verbs += /obj/admins/proc/announce				//global announce
			verbs += /obj/admins/proc/immreboot				//immediate reboot
			verbs += /obj/admins/proc/restart				//restart
			verbs += /obj/admins/proc/startnow				//start now bitch

			// Debug
			verbs += /client/proc/debug_variables
			verbs += /client/proc/cmd_modify_object_variables
			verbs += /client/proc/cmd_modify_ticker_variables
			verbs += /client/proc/general_report
			verbs += /client/proc/air_report
			verbs += /client/proc/air_status
			verbs += /client/proc/radio_report
			//verbs += /client/proc/kill_air // -- TLE
			verbs += /client/proc/modifytemperature
			//verbs += /client/proc/callproc
			//verbs += /client/proc/Cell
			//verbs += /client/proc/cmd_debug_del_all
			//verbs += /client/proc/cmd_debug_tog_aliens
			verbs += /client/proc/Debug2					//debug toggle switch
			verbs += /client/proc/fix_next_move
			//verbs += /client/proc/ticklag
			//verbs += /proc/givetestverbs
			//verbs += /obj/admins/proc/spawn_atom
			verbs += /obj/admins/proc/toggletintedweldhelmets

			// Admin helpers
			verbs += /client/proc/cmd_admin_attack_log
			verbs += /client/proc/cmd_admin_check_contents
			//verbs += /client/proc/check_words 			// -- Urist
			verbs += /client/proc/dsay
			verbs += /client/proc/jobbans
			verbs += /client/proc/toggle_view_range

			// Admin game intrusion
			verbs += /client/proc/cmd_admin_remove_plasma
			//verbs += /client/proc/drop_bomb 				// -- TLE

			verbs += /client/proc/admin_call_shuttle 		// -- Skie
			verbs += /client/proc/admin_cancel_shuttle 		// -- Skie
			verbs += /client/proc/cmd_admin_create_centcom_report
			verbs += /obj/admins/proc/vmode   				//start vote
			verbs += /obj/admins/proc/votekill 				//abort vote

			verbs += /obj/admins/proc/edit_memory
			verbs += /obj/admins/proc/edit_player
			verbs += /client/proc/cmd_admin_dress
			//verbs += /client/proc/cmd_admin_alienize
			//verbs += /client/proc/cmd_admin_changelinginize
			//verbs += /client/proc/cmd_admin_abominize 		// -- TLE
			//verbs += /client/proc/cmd_admin_monkeyize
			//verbs += /client/proc/cmd_admin_robotize
			//verbs += /client/proc/make_cultist 				// -- TLE
			//verbs += /client/proc/cmd_admin_ninjafy 		//N
			verbs += /client/proc/respawn_character			//N

			verbs += /client/proc/Getmob
			verbs += /client/proc/sendmob
			verbs += /client/proc/Jump
			verbs += /client/proc/jumptokey
			verbs += /client/proc/jumptomob
			verbs += /client/proc/jumptoturf

			verbs += /client/proc/cmd_admin_add_freeform_ai_law
			verbs += /client/proc/cmd_admin_add_random_ai_law

			verbs += /client/proc/secrets
			verbs += /client/proc/cmd_admin_godmode
			verbs += /client/proc/cmd_admin_rejuvenate
			//verbs += /client/proc/cmd_admin_grantfullaccess
			verbs += /client/proc/cmd_admin_gib
			verbs += /client/proc/cmd_admin_gib_self
			//verbs += /client/proc/cmd_admin_explosion
			//verbs += /client/proc/cmd_admin_emp
			verbs += /client/proc/cmd_admin_delete
			verbs += /client/proc/cmd_admin_drop_everything
			verbs += /client/proc/cmd_admin_prison
			verbs += /obj/admins/proc/unprison
			verbs += /proc/togglebuildmode

			// Unnecessary commands
			//verbs += /client/proc/funbutton
			//verbs += /client/proc/make_sound 				// -- TLE
			//verbs += /client/proc/object_talk 			// -- TLE
			verbs += /client/proc/play_sound
			//verbs += /client/proc/cuban_pete 				// -- Urist
			//verbs += /client/proc/bananaphone
			//verbs += /client/proc/space_asshole 			// --Agouri :3
			//verbs += /client/proc/strike_team				//N
			//verbs += /client/proc/send_space_ninja			//N
			verbs += /client/proc/spawn_xeno				//N
			verbs += /proc/possess
			verbs += /proc/release
			verbs += /client/proc/unjobban_panel
			// Old and unused
//			verbs += /obj/admins/proc/togglegoonsay
//			verbs += /client/proc/grillify
//			verbs += /client/proc/cmd_admin_list_admins
//			verbs += /client/proc/getmobs

		if ("Trial Admin")
			deadchat = 1
			holder.level = 3

			if(holder.state == 2) // if observing
				// Settings
				verbs += /obj/admins/proc/toggleaban			//abandon mob
				verbs += /obj/admins/proc/toggleooc				//toggle ooc
				verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
				verbs += /obj/admins/proc/toggletraitorscaling

				// Admin "must have"

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

			// Settings
			//verbs += /client/proc/colorooc 				// -- Urist
			verbs += /obj/admins/proc/adjump				//toggle admin jumping
			verbs += /obj/admins/proc/adrev					//toggle admin revives
			verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			verbs += /obj/admins/proc/delay					//game start delay
			//verbs += /obj/admins/proc/toggleaban			//abandon mob
			verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			verbs += /obj/admins/proc/toggleguests			//Toggle guests entering
			//verbs += /obj/admins/proc/toggleooc				//toggle ooc
			//verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			//verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//verbs += /obj/admins/proc/toggle_aliens
			//verbs += /obj/admins/proc/toggle_space_ninja	//toggle ninjas
			verbs += /obj/admins/proc/voteres 				//toggle votes
			verbs += /client/proc/deadchat					//toggles deadchat
			verbs += /proc/toggle_adminmsg

			// Admin "must have"
			//verbs += /client/proc/cmd_admin_list_occ
			verbs += /client/proc/cmd_admin_mute
			verbs += /client/proc/cmd_admin_pm
			//verbs += /client/proc/cmd_admin_direct_narrate 	// -- TLE
			verbs += /client/proc/cmd_admin_say
			verbs += /client/proc/cmd_admin_subtle_message
			//verbs += /client/proc/cmd_admin_world_narrate 	// -- TLE
			//verbs += /client/proc/get_admin_state
			verbs += /client/proc/warn
			verbs += /obj/admins/proc/announce				//global announce
			verbs += /obj/admins/proc/immreboot				//immediate reboot
			verbs += /obj/admins/proc/restart				//restart
			verbs += /obj/admins/proc/startnow				//start now bitch

			// Debug
			//verbs += /client/proc/debug_variables
			//verbs += /client/proc/cmd_modify_object_variables
			//verbs += /client/proc/cmd_modify_ticker_variables
			verbs += /client/proc/general_report
			verbs += /client/proc/air_report
			verbs += /client/proc/air_status
			verbs += /client/proc/radio_report
			//verbs += /client/proc/kill_air // -- TLE
			//verbs += /client/proc/modifytemperature
			//verbs += /client/proc/callproc
			//verbs += /client/proc/Cell
			//verbs += /client/proc/cmd_debug_del_all
			//verbs += /client/proc/cmd_debug_tog_aliens
			//verbs += /client/proc/Debug2					//debug toggle switch
			//verbs += /client/proc/fix_next_move
			//verbs += /client/proc/ticklag
			//verbs += /proc/givetestverbs
			//verbs += /obj/admins/proc/spawn_atom
			verbs += /obj/admins/proc/toggletintedweldhelmets

			// Admin helpers
			verbs += /client/proc/cmd_admin_attack_log
			verbs += /client/proc/cmd_admin_check_contents
			//verbs += /client/proc/check_words 			// -- Urist
			verbs += /client/proc/dsay
			verbs += /client/proc/jobbans
			//verbs += /client/proc/toggle_view_range

			// Admin game intrusion
			verbs += /client/proc/cmd_admin_remove_plasma
			//verbs += /client/proc/drop_bomb 				// -- TLE

			verbs += /client/proc/admin_call_shuttle 		// -- Skie
			verbs += /client/proc/admin_cancel_shuttle 		// -- Skie
			verbs += /client/proc/cmd_admin_create_centcom_report
			verbs += /obj/admins/proc/vmode   				//start vote
			verbs += /obj/admins/proc/votekill 				//abort vote

			verbs += /obj/admins/proc/edit_memory
			verbs += /obj/admins/proc/edit_player
			verbs += /client/proc/cmd_admin_dress
			//verbs += /client/proc/cmd_admin_alienize
			//verbs += /client/proc/cmd_admin_changelinginize
			//verbs += /client/proc/cmd_admin_abominize 	// -- TLE
			//verbs += /client/proc/cmd_admin_monkeyize
			//verbs += /client/proc/cmd_admin_robotize
			//verbs += /client/proc/make_cultist 				// -- TLE
			//verbs += /client/proc/cmd_admin_ninjafy 		//N
			verbs += /client/proc/respawn_character			//N

			//verbs += /client/proc/Getmob
			//verbs += /client/proc/sendmob
			//verbs += /client/proc/Jump
			//verbs += /client/proc/jumptokey
			//verbs += /client/proc/jumptomob
			//verbs += /client/proc/jumptoturf

			//verbs += /client/proc/cmd_admin_add_freeform_ai_law
			verbs += /client/proc/cmd_admin_add_random_ai_law

			verbs += /client/proc/secrets
			//verbs += /client/proc/cmd_admin_godmode
			//verbs += /client/proc/cmd_admin_rejuvenate
			//verbs += /client/proc/cmd_admin_grantfullaccess
			//verbs += /client/proc/cmd_admin_gib
			verbs += /client/proc/cmd_admin_gib_self
			//verbs += /client/proc/cmd_admin_explosion
			//verbs += /client/proc/cmd_admin_emp
			//verbs += /client/proc/cmd_admin_delete
			//verbs += /client/proc/cmd_admin_drop_everything
			verbs += /client/proc/cmd_admin_prison
			verbs += /obj/admins/proc/unprison
			//verbs += /proc/togglebuildmode

			// Unnecessary commands
			//verbs += /client/proc/funbutton
			//verbs += /client/proc/make_sound 				// -- TLE
			//verbs += /client/proc/object_talk 			// -- TLE
			verbs += /client/proc/play_sound
			//verbs += /client/proc/cuban_pete 				// -- Urist
			//verbs += /client/proc/bananaphone
			//verbs += /client/proc/space_asshole 			// --Agouri :3
			//verbs += /client/proc/strike_team				//N
			//verbs += /client/proc/send_space_ninja		//N
			verbs += /client/proc/spawn_xeno				//N
			verbs += /proc/possess
			verbs += /proc/release

			// Old and unused
//			verbs += /obj/admins/proc/togglegoonsay
//			verbs += /client/proc/grillify
//			verbs += /client/proc/cmd_admin_list_admins
//			verbs += /client/proc/getmobs

		if ("Admin Candidate")
			holder.level = 2

			if(holder.state == 2) // if observing
				deadchat = 1

				// Settings
				verbs += /obj/admins/proc/toggleaban			//abandon mob
				verbs += /client/proc/deadchat					//toggles deadchat

				// Admin "must have"

				// Debug

				// Admin helpers
				verbs += /client/proc/cmd_admin_attack_log
				verbs += /client/proc/cmd_admin_check_contents

				// Admin game intrusion
				verbs += /client/proc/Jump
				verbs += /client/proc/jumptokey
				verbs += /client/proc/jumptomob

			// Settings
			//verbs += /client/proc/colorooc 				// -- Urist
			//verbs += /obj/admins/proc/adjump				//toggle admin jumping
			//verbs += /obj/admins/proc/adrev					//toggle admin revives
			//verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			verbs += /obj/admins/proc/delay					//game start delay
			//verbs += /obj/admins/proc/toggleaban			//abandon mob
			verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			verbs += /obj/admins/proc/toggleguests			//Toggle guests entering
			//verbs += /obj/admins/proc/toggleooc				//toggle ooc
			//verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			//verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//verbs += /obj/admins/proc/toggle_aliens
			//verbs += /obj/admins/proc/toggle_space_ninja	//toggle ninjas
			verbs += /obj/admins/proc/voteres 				//toggle votes
			verbs += /client/proc/deadchat					//toggles deadchat
			//verbs += /proc/toggle_adminmsg

			// Admin "must have"
			//verbs += /client/proc/cmd_admin_list_occ
			verbs += /client/proc/cmd_admin_mute
			verbs += /client/proc/cmd_admin_pm
			//verbs += /client/proc/cmd_admin_direct_narrate 	// -- TLE
			verbs += /client/proc/cmd_admin_say
			verbs += /client/proc/cmd_admin_subtle_message
			//verbs += /client/proc/cmd_admin_world_narrate 	// -- TLE
			//verbs += /client/proc/get_admin_state
			verbs += /client/proc/warn
			verbs += /obj/admins/proc/announce				//global announce
			verbs += /obj/admins/proc/immreboot				//immediate reboot
			verbs += /obj/admins/proc/restart				//restart
			verbs += /obj/admins/proc/startnow				//start now bitch

			// Debug
			//verbs += /client/proc/debug_variables
			//verbs += /client/proc/cmd_modify_object_variables
			//verbs += /client/proc/cmd_modify_ticker_variables
			verbs += /client/proc/general_report
			verbs += /client/proc/air_report
			verbs += /client/proc/air_status
			verbs += /client/proc/radio_report
			//verbs += /client/proc/kill_air // -- TLE
			//verbs += /client/proc/modifytemperature
			//verbs += /client/proc/callproc
			//verbs += /client/proc/Cell
			//verbs += /client/proc/cmd_debug_del_all
			//verbs += /client/proc/cmd_debug_tog_aliens
			//verbs += /client/proc/Debug2					//debug toggle switch
			//verbs += /client/proc/fix_next_move
			//verbs += /client/proc/ticklag
			//verbs += /proc/givetestverbs
			//verbs += /obj/admins/proc/spawn_atom
			verbs += /obj/admins/proc/toggletintedweldhelmets

			// Admin helpers
			//verbs += /client/proc/cmd_admin_attack_log
			//verbs += /client/proc/cmd_admin_check_contents
			//verbs += /client/proc/check_words 			// -- Urist
			verbs += /client/proc/dsay
			verbs += /client/proc/jobbans
			//verbs += /client/proc/toggle_view_range

			// Admin game intrusion
			//verbs += /client/proc/cmd_admin_remove_plasma
			//verbs += /client/proc/drop_bomb 				// -- TLE

			//verbs += /client/proc/admin_call_shuttle 		// -- Skie
			//verbs += /client/proc/admin_cancel_shuttle 		// -- Skie
			verbs += /client/proc/cmd_admin_create_centcom_report
			verbs += /obj/admins/proc/vmode   				//start vote
			verbs += /obj/admins/proc/votekill 				//abort vote

			//verbs += /obj/admins/proc/edit_memory
			verbs += /obj/admins/proc/edit_player
			//verbs += /client/proc/cmd_admin_alienize
			//verbs += /client/proc/cmd_admin_changelinginize
			//verbs += /client/proc/cmd_admin_abominize 	// -- TLE
			//verbs += /client/proc/cmd_admin_monkeyize
			//verbs += /client/proc/cmd_admin_robotize
			//verbs += /client/proc/make_cultist 				// -- TLE
			//verbs += /client/proc/cmd_admin_ninjafy 		//N
			//verbs += /client/proc/respawn_character			//N

			//verbs += /client/proc/Getmob
			//verbs += /client/proc/sendmob
			//verbs += /client/proc/Jump
			//verbs += /client/proc/jumptokey
			//verbs += /client/proc/jumptomob
			//verbs += /client/proc/jumptoturf

			//verbs += /client/proc/cmd_admin_add_freeform_ai_law
			verbs += /client/proc/cmd_admin_add_random_ai_law

			verbs += /client/proc/secrets
			//verbs += /client/proc/cmd_admin_godmode
			//verbs += /client/proc/cmd_admin_rejuvenate
			//verbs += /client/proc/cmd_admin_grantfullaccess
			//verbs += /client/proc/cmd_admin_gib
			verbs += /client/proc/cmd_admin_gib_self
			//verbs += /client/proc/cmd_admin_explosion
			//verbs += /client/proc/cmd_admin_emp
			//verbs += /client/proc/cmd_admin_delete
			//verbs += /client/proc/cmd_admin_drop_everything
			verbs += /client/proc/cmd_admin_prison
			verbs += /obj/admins/proc/unprison
			//verbs += /proc/togglebuildmode

			// Unnecessary commands
			//verbs += /client/proc/funbutton
			//verbs += /client/proc/make_sound 				// -- TLE
			//verbs += /client/proc/object_talk 			// -- TLE
			verbs += /client/proc/play_sound
			//verbs += /client/proc/cuban_pete 				// -- Urist
			//verbs += /client/proc/bananaphone
			//verbs += /client/proc/space_asshole 			// --Agouri :3
			//verbs += /client/proc/strike_team				//N
			//verbs += /client/proc/send_space_ninja		//N
			//verbs += /client/proc/spawn_xeno				//N
			//verbs += /proc/possess
			//verbs += /proc/release
			verbs += /client/proc/unjobban_panel
			// Old and unused
//			verbs += /obj/admins/proc/togglegoonsay
//			verbs += /client/proc/grillify
//			verbs += /client/proc/cmd_admin_list_admins
//			verbs += /client/proc/getmobs

		if ("Temporary Admin")
			holder.level = 1

			if(holder.state == 2) // if observing
				// Settings
				verbs += /obj/admins/proc/toggleaban			//abandon mob
				verbs += /obj/admins/proc/toggleooc				//toggle ooc
				verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc

				// Admin "must have"

				// Debug

				// Admin helpers
				verbs += /client/proc/cmd_admin_attack_log
				verbs += /client/proc/cmd_admin_check_contents

				// Admin game intrusion

			// Settings
			//verbs += /client/proc/colorooc 				// -- Urist
			//verbs += /obj/admins/proc/adjump				//toggle admin jumping
			//verbs += /obj/admins/proc/adrev					//toggle admin revives
			//verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			verbs += /obj/admins/proc/delay					//game start delay
			//verbs += /obj/admins/proc/toggleaban			//abandon mob
			verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			verbs += /obj/admins/proc/toggleguests			//Toggle guests entering
			//verbs += /obj/admins/proc/toggleooc				//toggle ooc
			//verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			//verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//verbs += /obj/admins/proc/toggle_aliens
			//verbs += /obj/admins/proc/toggle_space_ninja	//toggle ninjas
			verbs += /obj/admins/proc/voteres 				//toggle votes
			verbs += /client/proc/deadchat					//toggles deadchat
			//verbs += /proc/toggle_adminmsg

			// Admin "must have"
			//verbs += /client/proc/cmd_admin_list_occ
			verbs += /client/proc/cmd_admin_mute
			verbs += /client/proc/cmd_admin_pm
			//verbs += /client/proc/cmd_admin_direct_narrate 	// -- TLE
			verbs += /client/proc/cmd_admin_say
			verbs += /client/proc/cmd_admin_subtle_message
			//verbs += /client/proc/cmd_admin_world_narrate 	// -- TLE
			//verbs += /client/proc/get_admin_state
			verbs += /client/proc/warn
			verbs += /obj/admins/proc/announce				//global announce
			verbs += /obj/admins/proc/immreboot				//immediate reboot
			verbs += /obj/admins/proc/restart				//restart
			verbs += /obj/admins/proc/startnow				//start now bitch

			// Debug
			//verbs += /client/proc/debug_variables
			//verbs += /client/proc/cmd_modify_object_variables
			//verbs += /client/proc/cmd_modify_ticker_variables
			verbs += /client/proc/general_report
			verbs += /client/proc/air_report
			verbs += /client/proc/air_status
			verbs += /client/proc/radio_report
			//verbs += /client/proc/kill_air // -- TLE
			//verbs += /client/proc/modifytemperature
			//verbs += /client/proc/callproc
			//verbs += /client/proc/Cell
			//verbs += /client/proc/cmd_debug_del_all
			//verbs += /client/proc/cmd_debug_tog_aliens
			//verbs += /client/proc/Debug2					//debug toggle switch
			//verbs += /client/proc/fix_next_move
			//verbs += /client/proc/ticklag
			//verbs += /proc/givetestverbs
			//verbs += /obj/admins/proc/spawn_atom

			// Admin helpers
			//verbs += /client/proc/cmd_admin_attack_log
			//verbs += /client/proc/cmd_admin_check_contents
			//verbs += /client/proc/check_words 			// -- Urist
			verbs += /client/proc/dsay
			verbs += /client/proc/jobbans
			//verbs += /client/proc/toggle_view_range

			// Admin game intrusion
			//verbs += /client/proc/cmd_admin_remove_plasma
			//verbs += /client/proc/drop_bomb 				// -- TLE

			//verbs += /client/proc/admin_call_shuttle 		// -- Skie
			//verbs += /client/proc/admin_cancel_shuttle 		// -- Skie
			verbs += /client/proc/cmd_admin_create_centcom_report
			verbs += /obj/admins/proc/vmode   				//start vote
			verbs += /obj/admins/proc/votekill 				//abort vote

			//verbs += /obj/admins/proc/edit_memory
			verbs += /obj/admins/proc/edit_player
			//verbs += /client/proc/cmd_admin_alienize
			//verbs += /client/proc/cmd_admin_changelinginize
			//verbs += /client/proc/cmd_admin_abominize 	// -- TLE
			//verbs += /client/proc/cmd_admin_monkeyize
			//verbs += /client/proc/cmd_admin_robotize
			//verbs += /client/proc/make_cultist 				// -- TLE
			//verbs += /client/proc/cmd_admin_ninjafy 		//N
			//verbs += /client/proc/respawn_character			//N

			//verbs += /client/proc/Getmob
			//verbs += /client/proc/sendmob
			//verbs += /client/proc/Jump
			//verbs += /client/proc/jumptokey
			//verbs += /client/proc/jumptomob
			//verbs += /client/proc/jumptoturf

			//verbs += /client/proc/cmd_admin_add_freeform_ai_law
			//verbs += /client/proc/cmd_admin_add_random_ai_law

			//verbs += /client/proc/secrets
			//verbs += /client/proc/cmd_admin_godmode
			//verbs += /client/proc/cmd_admin_rejuvenate
			//verbs += /client/proc/cmd_admin_grantfullaccess
			//verbs += /client/proc/cmd_admin_gib
			verbs += /client/proc/cmd_admin_gib_self
			//verbs += /client/proc/cmd_admin_explosion
			//verbs += /client/proc/cmd_admin_emp
			//verbs += /client/proc/cmd_admin_delete
			//verbs += /client/proc/cmd_admin_drop_everything
			verbs += /client/proc/cmd_admin_prison
			verbs += /obj/admins/proc/unprison
			//verbs += /proc/togglebuildmode

			// Unnecessary commands
			//verbs += /client/proc/funbutton
			//verbs += /client/proc/make_sound 				// -- TLE
			//verbs += /client/proc/object_talk 			// -- TLE
			//verbs += /client/proc/play_sound
			//verbs += /client/proc/cuban_pete 				// -- Urist
			//verbs += /client/proc/bananaphone
			//verbs += /client/proc/space_asshole 			// --Agouri :3
			//verbs += /client/proc/strike_team				//N
			//verbs += /client/proc/send_space_ninja		//N
			//verbs += /client/proc/spawn_xeno				//N
			//verbs += /proc/possess
			//verbs += /proc/release

			// Old and unused
//			verbs += /obj/admins/proc/togglegoonsay
//			verbs += /client/proc/grillify
//			verbs += /client/proc/cmd_admin_list_admins
//			verbs += /client/proc/getmobs

		if ("Moderator")
			holder.level = 0

			// Settings
			//verbs += /client/proc/colorooc 				// -- Urist
			//verbs += /obj/admins/proc/adjump				//toggle admin jumping
			//verbs += /obj/admins/proc/adrev					//toggle admin revives
			//verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			//verbs += /obj/admins/proc/delay					//game start delay
			//verbs += /obj/admins/proc/toggleaban			//abandon mob
			verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			verbs += /obj/admins/proc/toggleguests			//Toggle guests entering
			verbs += /obj/admins/proc/toggleooc				//toggle ooc
			verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			//verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//verbs += /obj/admins/proc/toggle_aliens
			//verbs += /obj/admins/proc/toggle_space_ninja	//toggle ninjas
			verbs += /obj/admins/proc/voteres 				//toggle votes
			verbs += /client/proc/deadchat					//toggles deadchat
			verbs += /proc/toggle_adminmsg

			// Admin "must have"
			//verbs += /client/proc/cmd_admin_list_occ
			verbs += /client/proc/cmd_admin_mute
			verbs += /client/proc/cmd_admin_pm
			//verbs += /client/proc/cmd_admin_direct_narrate 	// -- TLE
			verbs += /client/proc/cmd_admin_say
			verbs += /client/proc/cmd_admin_subtle_message
			//verbs += /client/proc/cmd_admin_world_narrate 	// -- TLE
			//verbs += /client/proc/get_admin_state
			verbs += /client/proc/warn
			verbs += /obj/admins/proc/announce				//global announce
			//verbs += /obj/admins/proc/immreboot				//immediate reboot
			//verbs += /obj/admins/proc/restart				//restart
			verbs += /obj/admins/proc/startnow				//start now bitch

			// Debug
			//verbs += /client/proc/debug_variables
			//verbs += /client/proc/cmd_modify_object_variables
			//verbs += /client/proc/cmd_modify_ticker_variables
			verbs += /client/proc/general_report
			verbs += /client/proc/air_report
			verbs += /client/proc/air_status
			verbs += /client/proc/radio_report
			//verbs += /client/proc/kill_air // -- TLE
			//verbs += /client/proc/modifytemperature
			//verbs += /client/proc/callproc
			//verbs += /client/proc/Cell
			//verbs += /client/proc/cmd_debug_del_all
			//verbs += /client/proc/cmd_debug_tog_aliens
			//verbs += /client/proc/Debug2					//debug toggle switch
			//verbs += /client/proc/fix_next_move
			//verbs += /client/proc/ticklag
			//verbs += /proc/givetestverbs
			//verbs += /obj/admins/proc/spawn_atom

			// Admin helpers
			//verbs += /client/proc/cmd_admin_attack_log
			//verbs += /client/proc/cmd_admin_check_contents
			//verbs += /client/proc/check_words 			// -- Urist
			verbs += /client/proc/dsay
			verbs += /client/proc/jobbans
			//verbs += /client/proc/toggle_view_range

			// Admin game intrusion
			//verbs += /client/proc/cmd_admin_remove_plasma
			//verbs += /client/proc/drop_bomb 				// -- TLE

			//verbs += /client/proc/admin_call_shuttle 		// -- Skie
			//verbs += /client/proc/admin_cancel_shuttle 		// -- Skie
			//verbs += /client/proc/cmd_admin_create_centcom_report
			verbs += /obj/admins/proc/vmode   				//start vote
			verbs += /obj/admins/proc/votekill 				//abort vote

			//verbs += /obj/admins/proc/edit_memory
			verbs += /obj/admins/proc/edit_player
			//verbs += /client/proc/cmd_admin_alienize
			//verbs += /client/proc/cmd_admin_changelinginize
			//verbs += /client/proc/cmd_admin_abominize 	// -- TLE
			//verbs += /client/proc/cmd_admin_monkeyize
			//verbs += /client/proc/cmd_admin_robotize
			//verbs += /client/proc/make_cultist 				// -- TLE
			//verbs += /client/proc/cmd_admin_ninjafy 		//N
			//verbs += /client/proc/respawn_character			//N

			//verbs += /client/proc/Getmob
			//verbs += /client/proc/sendmob
			//verbs += /client/proc/Jump
			//verbs += /client/proc/jumptokey
			//verbs += /client/proc/jumptomob
			//verbs += /client/proc/jumptoturf

			//verbs += /client/proc/cmd_admin_add_freeform_ai_law
			//verbs += /client/proc/cmd_admin_add_random_ai_law

			//verbs += /client/proc/secrets
			//verbs += /client/proc/cmd_admin_godmode
			//verbs += /client/proc/cmd_admin_rejuvenate
			//verbs += /client/proc/cmd_admin_grantfullaccess
			//verbs += /client/proc/cmd_admin_gib
			verbs += /client/proc/cmd_admin_gib_self
			//verbs += /client/proc/cmd_admin_explosion
			//verbs += /client/proc/cmd_admin_emp
			//verbs += /client/proc/cmd_admin_delete
			//verbs += /client/proc/cmd_admin_drop_everything
			verbs += /client/proc/cmd_admin_prison
			verbs += /obj/admins/proc/unprison
			//verbs += /proc/togglebuildmode

			// Unnecessary commands
			//verbs += /client/proc/funbutton
			//verbs += /client/proc/make_sound 				// -- TLE
			//verbs += /client/proc/object_talk 			// -- TLE
			//verbs += /client/proc/play_sound
			//verbs += /client/proc/cuban_pete 				// -- Urist
			//verbs += /client/proc/bananaphone
			//verbs += /client/proc/space_asshole 			// --Agouri :3
			//verbs += /client/proc/strike_team				//N
			//verbs += /client/proc/send_space_ninja		//N
			//verbs += /client/proc/spawn_xeno				//N
			//verbs += /proc/possess
			//verbs += /proc/release
			verbs += /client/proc/unjobban_panel
			// Old and unused
//			verbs += /obj/admins/proc/togglegoonsay
//			verbs += /client/proc/grillify
//			verbs += /client/proc/cmd_admin_list_admins
//			verbs += /client/proc/getmobs

		if ("Admin Observer")
			holder.level = -1
			verbs += /client/proc/cmd_admin_say
			verbs += /client/proc/cmd_admin_gib_self

		if ("Banned")
			del(src)
			return

		else
			del(holder)
			return

	if (holder)
		holder.owner = src
		if (holder.level > -1)
			verbs += /client/proc/stealthadmin
			verbs += /client/proc/admin_play
			verbs += /client/proc/admin_observe
			verbs += /client/proc/voting
			verbs += /client/proc/game_panel
			verbs += /client/proc/unban_panel
			verbs += /client/proc/player_panel

		if(holder.level > 1)
			verbs += /client/proc/stealth

/client/proc/clear_admin_verbs()
	deadchat = 0

	// Verbs manager
	verbs -= /client/proc/stealthadmin
	verbs -= /client/proc/unstealthadmin

	// Settings
	verbs -= /obj/admins/proc/view_txt_log
	verbs -= /client/proc/colorooc // -- Urist
	verbs -= /obj/admins/proc/adjump				//toggle admin jumping
	verbs -= /obj/admins/proc/adrev					//toggle admin revives
	verbs -= /obj/admins/proc/adspawn				//toggle admin item spawning
	verbs -= /obj/admins/proc/delay					//game start delay
	verbs -= /obj/admins/proc/toggleaban			//abandon mob
	verbs -= /obj/admins/proc/toggleAI				//Toggle the AI
	verbs -= /obj/admins/proc/toggleenter			//Toggle enterting
	verbs -= /obj/admins/proc/toggleguests			//Toggle guests entering
	verbs -= /obj/admins/proc/toggleooc				//toggle ooc
	verbs -= /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
	verbs -= /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
	verbs -= /obj/admins/proc/toggle_aliens
	verbs -= /obj/admins/proc/toggle_space_ninja	//toggle ninjas
	verbs -= /obj/admins/proc/voteres 				//toggle votes
	verbs -= /client/proc/deadchat					//toggles deadchat
	verbs -= /proc/toggle_adminmsg

	// Admin "must have"
	verbs -= /client/proc/cmd_admin_list_occ
	verbs -= /client/proc/cmd_admin_mute
	verbs -= /client/proc/cmd_admin_pm
	verbs -= /client/proc/cmd_admin_direct_narrate 	// -- TLE
	//verbs -= /client/proc/cmd_admin_say
	verbs -= /client/proc/cmd_admin_subtle_message
	verbs -= /client/proc/cmd_admin_world_narrate 	// -- TLE
	verbs -= /client/proc/get_admin_state
	verbs -= /client/proc/warn
	verbs -= /obj/admins/proc/announce				//global announce
	verbs -= /obj/admins/proc/immreboot				//immediate reboot
	verbs -= /obj/admins/proc/restart				//restart
	verbs -= /obj/admins/proc/startnow				//start now bitch

	// Debug
	verbs -= /client/proc/debug_variables
	verbs -= /client/proc/cmd_modify_object_variables
	verbs -= /client/proc/cmd_modify_ticker_variables
	verbs -= /client/proc/general_report
	verbs -= /client/proc/air_report
	verbs -= /client/proc/air_status
	verbs -= /client/proc/radio_report
	verbs -= /client/proc/kill_air // -- TLE
	verbs -= /client/proc/modifytemperature
	verbs -= /client/proc/callproc
	verbs -= /client/proc/Cell
	verbs -= /client/proc/cmd_debug_del_all
	verbs -= /client/proc/cmd_debug_tog_aliens
	verbs -= /client/proc/Debug2					//debug toggle switch
	verbs -= /client/proc/fix_next_move
	verbs -= /client/proc/ticklag
	verbs -= /proc/givetestverbs
	verbs -= /obj/admins/proc/spawn_atom
	verbs -= /obj/admins/proc/toggletintedweldhelmets
	verbs -= /client/proc/atmosscan
	verbs -= /client/proc/restartcontroller
	verbs -= /client/proc/enable_mapping_debug
	verbs -= /client/proc/do_not_use_these
	verbs -= /client/proc/camera_view
	verbs -= /client/proc/sec_camera_report
	verbs -= /client/proc/intercom_view


	// Admin helpers
	verbs -= /client/proc/cmd_admin_attack_log
	verbs -= /client/proc/cmd_admin_check_contents
	verbs -= /client/proc/check_words // -- Urist
	verbs -= /client/proc/dsay
	verbs -= /client/proc/jobbans
	verbs -= /client/proc/toggle_view_range

	// Admin game intrusion
	verbs -= /client/proc/cmd_admin_remove_plasma
	verbs -= /client/proc/drop_bomb 				// -- TLE

	verbs -= /client/proc/admin_call_shuttle 		// -- Skie
	verbs -= /client/proc/admin_cancel_shuttle 		// -- Skie
	verbs -= /client/proc/cmd_admin_create_centcom_report
	verbs -= /obj/admins/proc/vmode   				//start vote
	verbs -= /obj/admins/proc/votekill 				//abort vote

	verbs -= /client/proc/give_spell
	verbs -= /obj/admins/proc/edit_memory
	verbs -= /obj/admins/proc/edit_player
	verbs -= /client/proc/cmd_admin_dress
	//verbs -= /client/proc/cmd_admin_alienize
	//verbs -= /client/proc/cmd_admin_changelinginize
	//verbs -= /client/proc/cmd_admin_abominize 		// -- TLE
	//verbs -= /client/proc/cmd_admin_monkeyize
	//verbs -= /client/proc/cmd_admin_robotize
	//verbs -= /client/proc/make_cultist 				// -- TLE
	verbs -= /client/proc/cmd_admin_ninjafy 		//N
	//verbs -= /client/proc/makepAI
	verbs -= /client/proc/respawn_character			//N

	verbs -= /client/proc/Getmob
	verbs -= /client/proc/sendmob
	verbs -= /client/proc/Jump
	verbs -= /client/proc/jumptokey
	verbs -= /client/proc/jumptomob
	verbs -= /client/proc/jumptoturf

	verbs -= /client/proc/cmd_admin_add_freeform_ai_law
	verbs -= /client/proc/cmd_admin_add_random_ai_law

	verbs -= /client/proc/secrets
	verbs -= /client/proc/cmd_admin_godmode
	verbs -= /client/proc/cmd_admin_rejuvenate
	verbs -= /client/proc/cmd_admin_grantfullaccess
	verbs -= /client/proc/cmd_admin_gib
	verbs -= /client/proc/cmd_admin_gib_self
	verbs -= /client/proc/cmd_admin_explosion
	verbs -= /client/proc/cmd_admin_emp
	verbs -= /client/proc/cmd_admin_delete
	verbs -= /client/proc/cmd_admin_drop_everything
	verbs -= /client/proc/cmd_admin_prison
	verbs -= /obj/admins/proc/unprison
	verbs -= /proc/togglebuildmode
	verbs -= /client/proc/cmd_mass_modify_object_variables

	verbs -= /client/proc/triple_ai
	verbs -= /client/proc/only_one
	// Unnecessary commands
	//verbs -= /client/proc/funbutton
	verbs -= /client/proc/make_sound 				// -- TLE
	verbs -= /client/proc/object_talk 				// -- TLE
	verbs -= /client/proc/play_sound
//	verbs -= /client/proc/cuban_pete 				// -- Urist
//	verbs -= /client/proc/honk_theme				// -- Urist the Honky
//	verbs -= /client/proc/bananaphone				// -- Darem
//	verbs -= /client/proc/space_asshole 			// --Agouri :3
	verbs -= /client/proc/strike_team				//N
	verbs -= /client/proc/send_space_ninja			//N
	verbs -= /client/proc/spawn_xeno				//N
	verbs -= /proc/possess
	verbs -= /proc/release
	verbs -= /client/proc/unjobban_panel
//	verbs -= /obj/admins/proc/togglegoonsay
//	verbs -= /client/proc/grillify
//	verbs -= /client/proc/cmd_admin_list_admins
//	verbs -= /client/proc/getmobs

	if(holder)
		holder.level = 0
		holder.owner = src

		verbs -= /client/proc/admin_play
		verbs -= /client/proc/admin_observe
		verbs -= /client/proc/voting
		verbs -= /client/proc/game_panel
		verbs -= /client/proc/unban_panel
		verbs -= /client/proc/player_panel
		verbs -= /client/proc/stealth

/client/proc/admin_observe()
	set category = "Admin"
	set name = "Set Observe"
	if(!holder)
		alert("You are not an admin")
		return
/*
	if(!mob.start)
		alert("You cannot observe while in the starting position")
		return
*/
	verbs -= /client/proc/admin_play
	spawn( 1200 )										//change this to 1200
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
	spawn( 1200 )										//change this to 1200
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

//admin client procs ported over from mob.dm

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
/*
/client/proc/goons()
	set name = "Goons"
	set category = "Admin"
	if (holder)
		holder.goons()
	return

/client/proc/beta_testers()
	set name = "Testers"
	set category = "Admin"
	if (holder)
		holder.beta_testers()
	return
*/
/client/proc/voting()
	set name = "Voting"
	set category = "Admin"
	if (holder)
		holder.Voting()

/* This thing does nothing but crash the server.
/client/proc/funbutton()
	set category = "Fun"
	set name = "Boom Boom Boom Shake The Room"
	if(!authenticated || !holder)
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
*/

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
	if(!mob)
		return
	message_admins("\blue [ckey] dropping a plasma bomb at [bomb_strength] strength.")
	var/obj/item/weapon/tank/plasma/P = new(mob.loc)
	P.air_contents.toxins = bomb_strength
	*/
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

/client/proc/unstealthadmin()
	set name = "Toggle admin verb visibility"
	set category = "Admin"
	src << "Here's your rightclick admin verbs back"

	verbs -= /client/proc/unstealthadmin
	var/temp = deadchat
	update_admins(holder.rank)
	deadchat = temp

/client/proc/stealthadmin()
	set name = "Toggle admin verb visibility"
	set category = "Admin"
	src << "Hiding your rightclick admin verbs so you can play without 'accidentally' gibbing someone"

	var/temp = deadchat

	clear_admin_verbs()

	deadchat = temp

	verbs += /client/proc/unstealthadmin

	switch (holder.rank)
		if ("Game Master") //Former Host
			// Settings
			//verbs += /client/proc/colorooc // -- Urist
			verbs += /obj/admins/proc/adjump				//toggle admin jumping
			verbs += /obj/admins/proc/adrev					//toggle admin revives
			verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			verbs += /obj/admins/proc/delay					//game start delay
			verbs += /obj/admins/proc/toggleaban			//abandon mob
			verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			verbs += /obj/admins/proc/toggleguests			//Toggle guests entering
			verbs += /obj/admins/proc/toggleooc				//toggle ooc
			verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			verbs += /obj/admins/proc/toggle_aliens
			verbs += /obj/admins/proc/toggle_space_ninja	//toggle ninjas
			verbs += /obj/admins/proc/voteres 				//toggle votes
			verbs += /client/proc/deadchat					//toggles deadchat
			verbs += /proc/toggle_adminmsg

			// Admin "must have"

			// Debug

			// Admin helpers

			// Admin game intrusion

			// Unnecessary commands

			// Old and unused

		if ("Game Admin") //Former Coder
			// Settings
			//verbs += /client/proc/colorooc 				// -- Urist
			verbs += /obj/admins/proc/adjump				//toggle admin jumping
			verbs += /obj/admins/proc/adrev					//toggle admin revives
			verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			verbs += /obj/admins/proc/delay					//game start delay
			verbs += /obj/admins/proc/toggleaban			//abandon mob
			verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			verbs += /obj/admins/proc/toggleguests			//Toggle guests entering
			verbs += /obj/admins/proc/toggleooc				//toggle ooc
			verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//verbs += /obj/admins/proc/toggle_aliens
			//verbs += /obj/admins/proc/toggle_space_ninja	//toggle ninjas
			verbs += /obj/admins/proc/voteres 				//toggle votes
			verbs += /client/proc/deadchat					//toggles deadchat
			verbs += /proc/toggle_adminmsg

			// Admin "must have"

			// Debug

			// Admin helpers

			// Admin game intrusion

			// Unnecessary commands

			// Old and unused

		if ("Badmin") //Former Shit Guy
			// Settings
			//verbs += /client/proc/colorooc 				// -- Urist
			verbs += /obj/admins/proc/adjump				//toggle admin jumping
			verbs += /obj/admins/proc/adrev					//toggle admin revives
			verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			verbs += /obj/admins/proc/delay					//game start delay
			verbs += /obj/admins/proc/toggleaban			//abandon mob
			verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			verbs += /obj/admins/proc/toggleguests			//Toggle guests entering
			verbs += /obj/admins/proc/toggleooc				//toggle ooc
			verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//verbs += /obj/admins/proc/toggle_aliens
			//verbs += /obj/admins/proc/toggle_space_ninja	//toggle ninjas
			verbs += /obj/admins/proc/voteres 				//toggle votes
			verbs += /client/proc/deadchat					//toggles deadchat
			verbs += /proc/toggle_adminmsg

			// Admin "must have"

			// Debug

			// Admin helpers

			// Admin game intrusion

			// Unnecessary commands

			// Old and unused

		if ("Trial Admin") //Former Primary Administrator
			if(holder.state == 2) // if observing
				// Settings
				verbs += /obj/admins/proc/toggleaban			//abandon mob
				verbs += /obj/admins/proc/toggleooc				//toggle ooc
				verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
				verbs += /obj/admins/proc/toggletraitorscaling

			// Settings
			//verbs += /client/proc/colorooc 				// -- Urist
			verbs += /obj/admins/proc/adjump				//toggle admin jumping
			verbs += /obj/admins/proc/adrev					//toggle admin revives
			verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			verbs += /obj/admins/proc/delay					//game start delay
			//verbs += /obj/admins/proc/toggleaban			//abandon mob
			verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			verbs += /obj/admins/proc/toggleguests			//Toggle guests entering
			//verbs += /obj/admins/proc/toggleooc				//toggle ooc
			//verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			//verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//verbs += /obj/admins/proc/toggle_aliens
			//verbs += /obj/admins/proc/toggle_space_ninja	//toggle ninjas
			verbs += /obj/admins/proc/voteres 				//toggle votes
			verbs += /client/proc/deadchat					//toggles deadchat
			verbs += /proc/toggle_adminmsg

			// Admin "must have"

			// Debug

			// Admin helpers

			// Admin game intrusion

			// Unnecessary commands

			// Old and unused

		if ("Admin Candidate") //Removed the 'Administrator' rank, has same rights as Trial Admin (Expected that these will be set manually each round)
			if(holder.state == 2) // if observing
				// Settings
				verbs += /obj/admins/proc/toggleaban			//abandon mob
				verbs += /obj/admins/proc/toggleooc				//toggle ooc
				verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
				verbs += /obj/admins/proc/toggletraitorscaling

			// Settings
			//verbs += /client/proc/colorooc 				// -- Urist
			verbs += /obj/admins/proc/adjump				//toggle admin jumping
			verbs += /obj/admins/proc/adrev					//toggle admin revives
			verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			verbs += /obj/admins/proc/delay					//game start delay
			//verbs += /obj/admins/proc/toggleaban			//abandon mob
			verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			verbs += /obj/admins/proc/toggleguests			//Toggle guests entering
			//verbs += /obj/admins/proc/toggleooc				//toggle ooc
			//verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			//verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//verbs += /obj/admins/proc/toggle_aliens
			//verbs += /obj/admins/proc/toggle_space_ninja	//toggle ninjas
			verbs += /obj/admins/proc/voteres 				//toggle votes
			verbs += /client/proc/deadchat					//toggles deadchat
			verbs += /proc/toggle_adminmsg


		if ("Temporary Admin") //Former Secondary Administrator
			if(holder.state == 2) // if observing
				// Settings
				verbs += /obj/admins/proc/toggleaban			//abandon mob
				verbs += /obj/admins/proc/toggleooc				//toggle ooc
				verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc

			// Settings
			//verbs += /client/proc/colorooc 				// -- Urist
			//verbs += /obj/admins/proc/adjump				//toggle admin jumping
			//verbs += /obj/admins/proc/adrev					//toggle admin revives
			//verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			verbs += /obj/admins/proc/delay					//game start delay
			//verbs += /obj/admins/proc/toggleaban			//abandon mob
			verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			verbs += /obj/admins/proc/toggleguests			//Toggle guests entering
			//verbs += /obj/admins/proc/toggleooc				//toggle ooc
			//verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			//verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//verbs += /obj/admins/proc/toggle_aliens
			//verbs += /obj/admins/proc/toggle_space_ninja	//toggle ninjas
			verbs += /obj/admins/proc/voteres 				//toggle votes
			verbs += /client/proc/deadchat					//toggles deadchat
			//verbs += /proc/toggle_adminmsg

			// Admin "must have"

			// Debug

			// Admin helpers

			// Admin game intrusion

			// Unnecessary commands

			// Old and unused

		if ("Moderator") //Former Moderator
			// Settings
			//verbs += /client/proc/colorooc 				// -- Urist
			//verbs += /obj/admins/proc/adjump				//toggle admin jumping
			//verbs += /obj/admins/proc/adrev					//toggle admin revives
			//verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			//verbs += /obj/admins/proc/delay					//game start delay
			//verbs += /obj/admins/proc/toggleaban			//abandon mob
			verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			verbs += /obj/admins/proc/toggleguests			//Toggle guests entering
			verbs += /obj/admins/proc/toggleooc				//toggle ooc
			verbs += /obj/admins/proc/toggleoocdead         //toggle ooc for dead/unc
			//verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			//verbs += /obj/admins/proc/toggle_aliens
			//verbs += /obj/admins/proc/toggle_space_ninja	//toggle ninjas
			verbs += /obj/admins/proc/voteres 				//toggle votes
			verbs += /client/proc/deadchat					//toggles deadchat
			verbs += /proc/toggle_adminmsg

			// Admin "must have"

			// Debug

			// Admin helpers

			// Admin game intrusion

			// Unnecessary commands

			// Old and unused

		if ("Admin Observer") //Former Filthy Xeno
