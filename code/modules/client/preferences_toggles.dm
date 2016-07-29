<<<<<<< HEAD
//toggles
/client/verb/toggle_ghost_ears()
	set name = "Show/Hide GhostEars"
	set category = "Preferences"
	set desc = ".Toggle Between seeing all mob speech, and only speech of nearby mobs"
	prefs.chat_toggles ^= CHAT_GHOSTEARS
	src << "As a ghost, you will now [(prefs.chat_toggles & CHAT_GHOSTEARS) ? "see all speech in the world" : "only see speech from nearby mobs"]."
	prefs.save_preferences()
	feedback_add_details("admin_verb","TGE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_sight()
	set name = "Show/Hide GhostSight"
	set category = "Preferences"
	set desc = ".Toggle Between seeing all mob emotes, and only emotes of nearby mobs"
	prefs.chat_toggles ^= CHAT_GHOSTSIGHT
	src << "As a ghost, you will now [(prefs.chat_toggles & CHAT_GHOSTSIGHT) ? "see all emotes in the world" : "only see emotes from nearby mobs"]."
	prefs.save_preferences()
	feedback_add_details("admin_verb","TGS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_whispers()
	set name = "Show/Hide GhostWhispers"
	set category = "Preferences"
	set desc = ".Toggle between hearing all whispers, and only whispers of nearby mobs"
	prefs.chat_toggles ^= CHAT_GHOSTWHISPER
	src << "As a ghost, you will now [(prefs.chat_toggles & CHAT_GHOSTWHISPER) ? "see all whispers in the world" : "only see whispers from nearby mobs"]."
	prefs.save_preferences()
	feedback_add_details("admin_verb","TGW") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_radio()
	set name = "Show/Hide GhostRadio"
	set category = "Preferences"
	set desc = ".Enable or disable hearing radio chatter as a ghost"
	prefs.chat_toggles ^= CHAT_GHOSTRADIO
	src << "As a ghost, you will now [(prefs.chat_toggles & CHAT_GHOSTRADIO) ? "see radio chatter" : "not see radio chatter"]."
	prefs.save_preferences()
	feedback_add_details("admin_verb","TGR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc! //social experiment, increase the generation whenever you copypaste this shamelessly GENERATION 1

/client/verb/toggle_ghost_pda()
	set name = "Show/Hide GhostPDA"
	set category = "Preferences"
	set desc = ".Toggle Between seeing all mob pda messages, and only pda messages of nearby mobs"
	prefs.chat_toggles ^= CHAT_GHOSTPDA
	src << "As a ghost, you will now [(prefs.chat_toggles & CHAT_GHOSTPDA) ? "see all pda messages in the world" : "only see pda messages from nearby mobs"]."
	prefs.save_preferences()
	feedback_add_details("admin_verb","TGP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_hear_radio()
	set name = "Show/Hide RadioChatter"
	set category = "Preferences"
	set desc = "Toggle seeing radiochatter from nearby radios and speakers"
	if(!holder) return
	prefs.chat_toggles ^= CHAT_RADIO
	prefs.save_preferences()
	usr << "You will [(prefs.chat_toggles & CHAT_RADIO) ? "now" : "no longer"] see radio chatter from nearby radios or speakers"
	feedback_add_details("admin_verb","THR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_deathrattle()
	set name = "Toggle Deathrattle"
	set category = "Preferences"
	set desc = "Toggle recieving a message in deadchat when sentient mobs \
		die."
	prefs.toggles ^= DISABLE_DEATHRATTLE
	prefs.save_preferences()
	usr << "You will \
		[(prefs.toggles & DISABLE_DEATHRATTLE) ? "no longer" : "now"] get \
		messages when a sentient mob dies."
	feedback_add_details("admin_verb", "TDR") // If you are copy-pasting this, maybe you should spend some time reading the comments.

/client/verb/toggle_arrivalrattle()
	set name = "Toggle Arrivalrattle"
	set category = "Preferences"
	set desc = "Toggle recieving a message in deadchat when someone joins \
		the station."
	prefs.toggles ^= DISABLE_ARRIVALRATTLE
	usr << "You will \
		[(prefs.toggles & DISABLE_ARRIVALRATTLE) ? "no longer" : "now"] get \
		messages when someone joins the station."
	prefs.save_preferences()
	feedback_add_details("admin_verb", "TAR") // If you are copy-pasting this, maybe you should rethink where your life went so wrong.

/client/proc/toggleadminhelpsound()
	set name = "Hear/Silence Adminhelps"
	set category = "Preferences"
	set desc = "Toggle hearing a notification when admin PMs are received"
	if(!holder)
		return
	prefs.toggles ^= SOUND_ADMINHELP
	prefs.save_preferences()
	usr << "You will [(prefs.toggles & SOUND_ADMINHELP) ? "now" : "no longer"] hear a sound when adminhelps arrive."
	feedback_add_details("admin_verb","AHS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleannouncelogin()
	set name = "Do/Don't Announce Login"
	set category = "Preferences"
	set desc = "Toggle if you want an announcement to admins when you login during a round"
	if(!holder)
		return
	prefs.toggles ^= ANNOUNCE_LOGIN
	prefs.save_preferences()
	usr << "You will [(prefs.toggles & ANNOUNCE_LOGIN) ? "now" : "no longer"] have an announcement to other admins when you login."
	feedback_add_details("admin_verb","TAL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/deadchat()
	set name = "Show/Hide Deadchat"
	set category = "Preferences"
	set desc ="Toggles seeing deadchat"
	prefs.chat_toggles ^= CHAT_DEAD
	prefs.save_preferences()
	src << "You will [(prefs.chat_toggles & CHAT_DEAD) ? "now" : "no longer"] see deadchat."
	feedback_add_details("admin_verb","TDV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleprayers()
	set name = "Show/Hide Prayers"
	set category = "Preferences"
	set desc = "Toggles seeing prayers"
	prefs.chat_toggles ^= CHAT_PRAYER
	prefs.save_preferences()
	src << "You will [(prefs.chat_toggles & CHAT_PRAYER) ? "now" : "no longer"] see prayerchat."
	feedback_add_details("admin_verb","TP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggleprayersounds()
	set name = "Hear/Silence Prayer Sounds"
	set category = "Preferences"
	set desc = "Toggles hearing pray sounds."
	prefs.toggles ^= SOUND_PRAYERS
	prefs.save_preferences()
	if(prefs.toggles & SOUND_PRAYERS)
		src << "You will now hear prayer sounds."
	else
		src << "You will no longer prayer sounds."
	feedback_add_details("admin_verb", "PSounds")

/client/verb/togglemidroundantag()
	set name = "Toggle Midround Antagonist"
	set category = "Preferences"
	set desc = "Toggles whether or not you will be considered for antagonist status given during a round."
	prefs.toggles ^= MIDROUND_ANTAG
	prefs.save_preferences()
	src << "You will [(prefs.toggles & MIDROUND_ANTAG) ? "now" : "no longer"] be considered for midround antagonist positions."
	feedback_add_details("admin_verb","TMidroundA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggletitlemusic()
	set name = "Hear/Silence LobbyMusic"
	set category = "Preferences"
	set desc = "Toggles hearing the GameLobby music"
	prefs.toggles ^= SOUND_LOBBY
	prefs.save_preferences()
	if(prefs.toggles & SOUND_LOBBY)
		src << "You will now hear music in the game lobby."
		if(istype(mob, /mob/new_player))
			playtitlemusic()
	else
		src << "You will no longer hear music in the game lobby."
		if(istype(mob, /mob/new_player))
			mob.stopLobbySound()
	feedback_add_details("admin_verb","TLobby") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/togglemidis()
	set name = "Hear/Silence Midis"
	set category = "Preferences"
	set desc = "Toggles hearing sounds uploaded by admins"
	prefs.toggles ^= SOUND_MIDI
	prefs.save_preferences()
	if(prefs.toggles & SOUND_MIDI)
		src << "You will now hear any sounds uploaded by admins."
		if(admin_sound)
			src << admin_sound
	else
		src << "You will no longer hear sounds uploaded by admins; any currently playing midis have been disabled."
		if(admin_sound && !(admin_sound.status & SOUND_PAUSED))
			admin_sound.status |= SOUND_PAUSED
			src << admin_sound
			admin_sound.status ^= SOUND_PAUSED
	feedback_add_details("admin_verb","TMidi") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/stop_client_sounds()
	set name = "Stop Sounds"
	set category = "Preferences"
	set desc = "Kills all currently playing sounds, use if admin taste in midis a shite"
	src << sound(null)
	feedback_add_details("admin_verb","SAPS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/listen_ooc()
	set name = "Show/Hide OOC"
	set category = "Preferences"
	set desc = "Toggles seeing OutOfCharacter chat"
	prefs.chat_toggles ^= CHAT_OOC
	prefs.save_preferences()
	src << "You will [(prefs.chat_toggles & CHAT_OOC) ? "now" : "no longer"] see messages on the OOC channel."
	feedback_add_details("admin_verb","TOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/Toggle_Soundscape() //All new ambience should be added here so it works with this verb until someone better at things comes up with a fix that isn't awful
	set name = "Hear/Silence Ambience"
	set category = "Preferences"
	set desc = "Toggles hearing ambient sound effects"
	prefs.toggles ^= SOUND_AMBIENCE
	prefs.save_preferences()
	if(prefs.toggles & SOUND_AMBIENCE)
		src << "You will now hear ambient sounds."
	else
		src << "You will no longer hear ambient sounds."
		src << sound(null, repeat = 0, wait = 0, volume = 0, channel = 1)
		src << sound(null, repeat = 0, wait = 0, volume = 0, channel = 2)
	feedback_add_details("admin_verb","TAmbi") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

// This needs a toggle because you people are awful and spammed terrible music
/client/verb/toggle_instruments()
	set name = "Hear/Silence Instruments"
	set category = "Preferences"
	set desc = "Toggles hearing musical instruments like the violin and piano"
	prefs.toggles ^= SOUND_INSTRUMENTS
	prefs.save_preferences()
	if(prefs.toggles & SOUND_INSTRUMENTS)
		src << "You will now hear people playing musical instruments."
	else
		src << "You will no longer hear musical instruments."
	feedback_add_details("admin_verb","TInstru") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//Lots of people get headaches from the normal ship ambience, this is to prevent that
/client/verb/toggle_ship_ambience()
	set name = "Hear/Silence Ship Ambience"
	set category = "Preferences"
	set desc = "Toggles hearing generalized ship ambience, no matter your area."
	prefs.toggles ^= SOUND_SHIP_AMBIENCE
	prefs.save_preferences()
	if(prefs.toggles & SOUND_SHIP_AMBIENCE)
		src << "You will now hear ship ambience."
	else
		src << "You will no longer hear ship ambience."
		src << sound(null, repeat = 0, wait = 0, volume = 0, channel = 2)
		src.ambience_playing = 0
	feedback_add_details("admin_verb", "SAmbi") //If you are copy-pasting this, I bet you read this comment expecting to see the same thing :^)

var/global/list/ghost_forms = list("ghost","ghostking","ghostian2","skeleghost","ghost_red","ghost_black", \
							"ghost_blue","ghost_yellow","ghost_green","ghost_pink", \
							"ghost_cyan","ghost_dblue","ghost_dred","ghost_dgreen", \
							"ghost_dcyan","ghost_grey","ghost_dyellow","ghost_dpink", "ghost_purpleswirl","ghost_funkypurp","ghost_pinksherbert","ghost_blazeit",\
							"ghost_mellow","ghost_rainbow","ghost_camo","ghost_fire", "catghost")
/client/proc/pick_form()
	if(!is_content_unlocked())
		alert("This setting is for accounts with BYOND premium only.")
		return
	var/new_form = input(src, "Thanks for supporting BYOND - Choose your ghostly form:","Thanks for supporting BYOND",null) as null|anything in ghost_forms
	if(new_form)
		prefs.ghost_form = new_form
		prefs.save_preferences()
		if(istype(mob,/mob/dead/observer))
			var/mob/dead/observer/O = mob
			O.update_icon(new_form)

var/global/list/ghost_orbits = list(GHOST_ORBIT_CIRCLE,GHOST_ORBIT_TRIANGLE,GHOST_ORBIT_SQUARE,GHOST_ORBIT_HEXAGON,GHOST_ORBIT_PENTAGON)

/client/proc/pick_ghost_orbit()
	if(!is_content_unlocked())
		alert("This setting is for accounts with BYOND premium only.")
		return
	var/new_orbit = input(src, "Thanks for supporting BYOND - Choose your ghostly orbit:","Thanks for supporting BYOND",null) as null|anything in ghost_orbits
	if(new_orbit)
		prefs.ghost_orbit = new_orbit
		prefs.save_preferences()
		if(istype(mob, /mob/dead/observer))
			var/mob/dead/observer/O = mob
			O.ghost_orbit = new_orbit

/client/proc/pick_ghost_accs()
	var/new_ghost_accs = alert("Do you want your ghost to show full accessories where possible, hide accessories but still use the directional sprites where possible, or also ignore the directions and stick to the default sprites?",,"full accessories", "only directional sprites", "default sprites")
	if(new_ghost_accs)
		switch(new_ghost_accs)
			if("full accessories")
				prefs.ghost_accs = GHOST_ACCS_FULL
			if("only directional sprites")
				prefs.ghost_accs = GHOST_ACCS_DIR
			if("default sprites")
				prefs.ghost_accs = GHOST_ACCS_NONE
		prefs.save_preferences()
		if(istype(mob, /mob/dead/observer))
			var/mob/dead/observer/O = mob
			O.update_icon()

/client/verb/pick_ghost_customization()
	set name = "Ghost Customization"
	set category = "Preferences"
	set desc = "Customize your ghastly appearance."
	if(is_content_unlocked())
		switch(alert("Which setting do you want to change?",,"Ghost Form","Ghost Orbit","Ghost Accessories"))
			if("Ghost Form")
				pick_form()
			if("Ghost Orbit")
				pick_ghost_orbit()
			if("Ghost Accessories")
				pick_ghost_accs()
	else
		pick_ghost_accs()

/client/verb/pick_ghost_others()
	set name = "Ghosts of Others"
	set category = "Preferences"
	set desc = "Change display settings for the ghosts of other players."
	var/new_ghost_others = alert("Do you want the ghosts of others to show up as their own setting, as their default sprites or always as the default white ghost?",,"Their Setting", "Default Sprites", "White Ghost")
	if(new_ghost_others)
		switch(new_ghost_others)
			if("Their Setting")
				prefs.ghost_others = GHOST_OTHERS_THEIR_SETTING
			if("Default Sprites")
				prefs.ghost_others = GHOST_OTHERS_DEFAULT_SPRITE
			if("White Ghost")
				prefs.ghost_others = GHOST_OTHERS_SIMPLE
		prefs.save_preferences()
		if(istype(mob, /mob/dead/observer))
			var/mob/dead/observer/O = mob
			O.updateghostsight()

/client/verb/toggle_intent_style()
	set name = "Toggle Intent Selection Style"
	set category = "Preferences"
	set desc = "Toggle between directly clicking the desired intent or clicking to rotate through."
	prefs.toggles ^= INTENT_STYLE
	src << "[(prefs.toggles & INTENT_STYLE) ? "Clicking directly on intents selects them." : "Clicking on intents rotates selection clockwise."]"
	prefs.save_preferences()
	feedback_add_details("admin_verb","ITENTS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/setup_character()
	set name = "Game Preferences"
	set category = "Preferences"
	set desc = "Allows you to access the Setup Character screen. Changes to your character won't take effect until next round, but other changes will."
	prefs.current_tab = 1
	prefs.ShowChoices(usr)

/client/verb/toggle_ghost_hud_pref()
	set name = "Toggle Ghost HUD"
	set category = "Preferences"
	set desc = "Hide/Show Ghost HUD"

	prefs.ghost_hud = !prefs.ghost_hud
	src << "Ghost HUD will now be [prefs.ghost_hud ? "visible" : "hidden"]."
	prefs.save_preferences()
	if(istype(mob,/mob/dead/observer))
		mob.hud_used.show_hud()

/client/verb/toggle_inquisition() // warning: unexpected inquisition
	set name = "Toggle Inquisitiveness"
	set desc = "Sets whether your ghost examines everything on click by default"
	set category = "Preferences"

	prefs.inquisitive_ghost = !prefs.inquisitive_ghost
	prefs.save_preferences()
	if(prefs.inquisitive_ghost)
		src << "<span class='notice'>You will now examine everything you click on.</span>"
	else
		src << "<span class='notice'>You will no longer examine things you click on.</span>"

/client/verb/toggle_announcement_sound()
	set name = "Hear/Silence Announcements"
	set category = "Preferences"
	set desc = ".Toggles hearing Central Command, Captain, VOX, and other announcement sounds"
	prefs.toggles ^= SOUND_ANNOUNCEMENTS
	src << "You will now [(prefs.toggles & SOUND_ANNOUNCEMENTS) ? "hear announcement sounds" : "no longer hear announcements"]."
	prefs.save_preferences()
	feedback_add_details("admin_verb","TAS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
=======
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
			src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1)// stop the jamsz

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
		src << sound(null, repeat = 0, wait = 0, volume = 0, channel = 1)
		src << sound(null, repeat = 0, wait = 0, volume = 0, channel = 2)
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

/client/verb/toggle_space_parallax()
	set name = "Toggle Space Parallax"
	set category = "Preferences"
	set desc = "Toggle the parallax effect of space turfs."
	prefs.space_parallax = !prefs.space_parallax

	prefs.save_preferences_sqlite(src,ckey)

	if(!prefs.space_parallax)
		to_chat(usr, "Space parallax is now deactivated.")
	else
		to_chat(usr, "Space parallax is now activated.")

	if(mob && mob.hud_used)
		mob.hud_used.update_parallax_existence()

/client/verb/toggle_space_dust()
	set name = "Toggle Space Dust"
	set category = "Preferences"
	set desc = "Toggle the presence of dust on space turfs."
	prefs.space_dust = !prefs.space_dust

	prefs.save_preferences_sqlite(src,ckey)

	if(!prefs.space_dust)
		to_chat(usr, "Space dust is now deactivated.")
	else
		to_chat(usr, "Space dust is now activated.")

	if(mob && mob.hud_used)
		mob.hud_used.update_parallax_existence()

/client/verb/toggle_parallax_speed()
	set name = "Change Parallax Speed"
	set category = "Preferences"
	set desc = "Change the speed at which parallax moves."

	prefs.parallax_speed = min(max(input(usr, "Enter a number between 0 and 5 included (default=2)","Parallax Speed Preferences",prefs.parallax_speed),0),5)

	prefs.save_preferences_sqlite(src,ckey)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
