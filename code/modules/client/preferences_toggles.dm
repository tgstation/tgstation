//toggles
/client/verb/toggle_ghost_ears()
	set name = "Show/Hide GhostEars"
	set category = "Preferences"
	set desc = "Toggle Between seeing all mob speech, and only speech of nearby mobs"
	prefs.toggles ^= CHAT_GHOSTEARS
	to_chat(src, "As a ghost, you will now [(prefs.toggles & CHAT_GHOSTEARS) ? "see all speech in the world" : "only see speech from nearby mobs"].")
	prefs.save_preferences_sqlite(src, ckey)
	feedback_add_details("admin_verb","TGE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_sight()
	set name = "Show/Hide GhostSight"
	set category = "Preferences"
	set desc = "Toggle Between seeing all mob emotes, and only emotes of nearby mobs"
	prefs.toggles ^= CHAT_GHOSTSIGHT
	to_chat(src, "As a ghost, you will now [(prefs.toggles & CHAT_GHOSTSIGHT) ? "see all emotes in the world" : "only see emotes from nearby mobs"].")
	prefs.save_preferences_sqlite(src, ckey)
	feedback_add_details("admin_verb","TGS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_radio()
	set name = "Enable/Disable GhostRadio"
	set category = "Preferences"
	set desc = "Toggle between hearing all radio chatter, or only from nearby speakers"
	prefs.toggles ^= CHAT_GHOSTRADIO
	to_chat(src, "As a ghost, you will now [(prefs.toggles & CHAT_GHOSTRADIO) ? "hear all radio chat in the world" : "only hear from nearby speakers"].")
	prefs.save_preferences_sqlite(src, ckey)
	feedback_add_details("admin_verb","TGR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_pda()
	set name = "Enable/Disable GhostPDA"
	set category = "Preferences"
	set desc = "Toggle between hearing all PDA messages, or none"
	prefs.toggles ^= CHAT_GHOSTPDA
	to_chat(src, "As a ghost, you will now [(prefs.toggles & CHAT_GHOSTPDA) ? "hear all PDA messages in the world" : "hear no PDA messages at all"].")
	prefs.save_preferences_sqlite(src, ckey)
	feedback_add_details("admin_verb","TGP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_hear_radio()
	set name = "Show/Hide RadioChatter"
	set category = "Preferences"
	set desc = "Toggle seeing radiochatter from radios and speakers"

	if(!holder) return
	prefs.toggles ^= CHAT_RADIO
	prefs.save_preferences_sqlite(src, ckey)
	to_chat(usr, "You will [(prefs.toggles & CHAT_RADIO) ? "now" : "no longer"] see radio chatter from radios or speakers")
	feedback_add_details("admin_verb","THR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleadminhelpsound()
	set name = "Hear/Silence Adminhelps"
	set category = "Preferences"
	set desc = "Toggle hearing a notification when admin PMs are recieved"

	if(!holder)	return
	prefs.toggles ^= SOUND_ADMINHELP
	prefs.save_preferences_sqlite(src, ckey)
	to_chat(usr, "You will [(prefs.toggles & SOUND_ADMINHELP) ? "now" : "no longer"] hear a sound when adminhelps arrive.")
	feedback_add_details("admin_verb","AHS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/deadchat() // Deadchat toggle is usable by anyone.
	set name = "Show/Hide Deadchat"
	set category = "Preferences"
	set desc ="Toggles seeing deadchat"
	prefs.toggles ^= CHAT_DEAD
	prefs.save_preferences_sqlite(src, ckey)

	if(src.holder)
		to_chat(src, "You will [(prefs.toggles & CHAT_DEAD) ? "now" : "no longer"] see deadchat.")
	else
		to_chat(src, "As a ghost, you will [(prefs.toggles & CHAT_DEAD) ? "now" : "no longer"] see deadchat.")

	feedback_add_details("admin_verb","TDV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleprayers()
	set name = "Show/Hide Prayers"
	set category = "Preferences"
	set desc = "Toggles seeing prayers"

	prefs.toggles ^= CHAT_PRAYER
	prefs.save_preferences_sqlite(src, ckey)
	to_chat(src, "You will [(prefs.toggles & CHAT_PRAYER) ? "now" : "no longer"] see prayerchat.")
	feedback_add_details("admin_verb","TP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggletitlemusic()
	set name = "Hear/Silence LobbyMusic"
	set category = "Preferences"
	set desc = "Toggles hearing the GameLobby music"
	prefs.toggles ^= SOUND_LOBBY
	prefs.save_preferences_sqlite(src, ckey)
	if(prefs.toggles & SOUND_LOBBY)
		to_chat(src, "You will now hear music in the game lobby.")
		if(istype(mob, /mob/new_player))
			playtitlemusic()
	else
		to_chat(src, "You will no longer hear music in the game lobby.")
		if(istype(mob, /mob/new_player))
			to_chat(src, sound(null, repeat = 0, wait = 0, volume = 85, channel = 1))// stop the jamsz

	feedback_add_details("admin_verb","TLobby") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/togglemidis()
	set name = "Hear/Silence Midis"
	set category = "Preferences"
	set desc = "Toggles hearing sounds uploaded by admins"
	prefs.toggles ^= SOUND_MIDI
	prefs.save_preferences_sqlite(src, ckey)
	if(prefs.toggles & SOUND_MIDI)
		to_chat(src, "You will now hear any sounds uploaded by admins.")
	else
		var/sound/break_sound = sound(null, repeat = 0, wait = 0, channel = 777)
		break_sound.priority = 255
		src << break_sound //breaks the client's sound output on channel 777

		to_chat(src, "You will no longer hear sounds uploaded by admins; any currently playing midis have been disabled.")
	feedback_add_details("admin_verb","TMidi") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/listen_ooc()
	set name = "Show/Hide OOC"
	set category = "Preferences"
	set desc = "Toggles seeing OutOfCharacter chat"
	prefs.toggles ^= CHAT_OOC
	prefs.save_preferences_sqlite(src,ckey)
	to_chat(src, "You will [(prefs.toggles & CHAT_OOC) ? "now" : "no longer"] see messages on the OOC channel.")
	feedback_add_details("admin_verb","TOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/verb/listen_looc()
	set name = "Show/Hide LOOC"
	set category = "Preferences"
	set desc = "Toggles seeing Local OutOfCharacter chat"
	prefs.toggles ^= CHAT_LOOC
	prefs.save_preferences_sqlite(src, ckey)
	to_chat(src, "You will [(prefs.toggles & CHAT_LOOC) ? "now" : "no longer"] see messages on the LOOC channel.")
	feedback_add_details("admin_verb","TLOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/verb/Toggle_Soundscape() //All new ambience should be added here so it works with this verb until someone better at things comes up with a fix that isn't awful
	set name = "Hear/Silence Ambience"
	set category = "Preferences"
	set desc = "Toggles hearing ambient sound effects"
	prefs.toggles ^= SOUND_AMBIENCE
	prefs.save_preferences_sqlite(src, ckey)
	if(prefs.toggles & SOUND_AMBIENCE)
		to_chat(src, "You will now hear ambient sounds.")
	else
		to_chat(src, "You will no longer hear ambient sounds.")
		to_chat(src, sound(null, repeat = 0, wait = 0, volume = 0, channel = 1))
		to_chat(src, sound(null, repeat = 0, wait = 0, volume = 0, channel = 2))
	feedback_add_details("admin_verb","TAmbi") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/verb/change_ui()
	set name = "Change UI"
	set category = "Preferences"
	set desc = "Configure your user interface"

	if(!ishuman(usr))
		to_chat(usr, "This only for human")
		return

	var/UI_style_new = input(usr, "Select a style, we recommend White for customization") in list("White", "Midnight", "Orange", "old")
	if(!UI_style_new) return

	var/UI_style_alpha_new = input(usr, "Select a new alpha(transparence) parametr for UI, between 50 and 255") as num
	if(!UI_style_alpha_new | !(UI_style_alpha_new <= 255 && UI_style_alpha_new >= 50)) return

	var/UI_style_color_new = input(usr, "Choose your UI color, dark colors are not recommended!") as color|null
	if(!UI_style_color_new) return

	//update UI
	var/list/icons = usr.hud_used.adding + usr.hud_used.other +usr.hud_used.hotkeybuttons
	icons.Add(usr.zone_sel)

	if(alert("Like it? Save changes?",,"Yes", "No") == "Yes")
		prefs.UI_style = UI_style_new
		prefs.UI_style_alpha = UI_style_alpha_new
		prefs.UI_style_color = UI_style_color_new
		prefs.save_preferences_sqlite(src, ckey)
		to_chat(usr, "UI was saved")
		for(var/obj/screen/I in icons)
			if(I.color && I.alpha)
				I.icon = ui_style2icon(UI_style_new)
				I.color = UI_style_color_new
				I.alpha = UI_style_alpha_new

/client/verb/toggle_media()
	set name = "Hear/Silence Streaming"
	set category = "Preferences"
	set desc = "Toggle hearing streaming media (radios, jukeboxes, etc)"

	prefs.toggles ^= SOUND_STREAMING
	prefs.save_preferences_sqlite(src, ckey)
	to_chat(usr, "You will [(prefs.toggles & SOUND_STREAMING) ? "now" : "no longer"] hear streamed media.")
	if(!media) return
	if(prefs.toggles & SOUND_STREAMING)
		media.update_music()
	else
		media.stop_music()

/client/verb/toggle_wmp()
	set name = "Change Streaming Program"
	set category = "Preferences"
	set desc = "Toggle between using VLC and WMP to stream jukebox media"

	prefs.usewmp = !prefs.usewmp
	prefs.save_preferences_sqlite(src, ckey)
	to_chat(usr, "You will use [(prefs.usewmp) ? "WMP" : "VLC"] to hear streamed media.")
	if(!media) return
	media.stop_music()
	media.playerstyle = (prefs.usewmp ? PLAYER_OLD_HTML : PLAYER_HTML)
	if(prefs.toggles & SOUND_STREAMING)
		media.open()
		media.update_music()

/client/verb/setup_special_roles()
	set name = "Setup Special Roles"
	set category = "Preferences"
	set desc = "Toggle hearing streaming media (radios, jukeboxes, etc)"

	prefs.configure_special_roles(usr)

/client/verb/toggle_nanoui()
	set name = "Toggle nanoUI"
	set category = "Preferences"
	set desc = "Toggle using nanoUI or retro style UIs for objects that support both."
	prefs.usenanoui = !prefs.usenanoui

	prefs.save_preferences_sqlite(src, ckey)

	if(!prefs.usenanoui)
		to_chat(usr, "You will no longer use nanoUI on cross compatible UIs.")
	else
		to_chat(usr, "You will now use nanoUI on cross compatible UIs.")

/client/verb/toggle_progress_bars()
	set name = "Toggle Progress Bars"
	set category = "Preferences"
	set desc = "Toggle the display of a progress bar above the target of action."
	prefs.progress_bars = !prefs.progress_bars

	prefs.save_preferences_sqlite(src,ckey)

	if(!prefs.progress_bars)
		to_chat(usr, "You will no longer see progress bars when doing delayed actions.")
	else
		to_chat(usr, "You will now see progress bars when doing delayed actions")
