//this works as is to create a single checked item, but has no back end code for toggleing the check yet
#define TOGGLE_CHECKBOX(PARENT, CHILD) PARENT/CHILD/abstract = TRUE;PARENT/CHILD/checkbox = CHECKBOX_TOGGLE;PARENT/CHILD/verb/CHILD

//Example usage TOGGLE_CHECKBOX(datum/verbs/menu/Settings/Ghost/chatterbox, toggle_ghost_ears)()

//override because we don't want to save preferences twice.
/datum/verbs/menu/Settings/Set_checked(client/C, verbpath)
	if (checkbox == CHECKBOX_GROUP)
		C.prefs.menuoptions[type] = verbpath
	else if (checkbox == CHECKBOX_TOGGLE)
		var/checked = Get_checked(C)
		C.prefs.menuoptions[type] = !checked
		winset(C, "[verbpath]", "is-checked = [!checked]")

/datum/verbs/menu/Settings/verb/setup_character()
	set name = "Game Preferences"
	set category = "Preferences"
	set desc = "Open Game Preferences Window"
	usr.client.prefs.current_tab = 1
	usr.client.prefs.ShowChoices(usr)

//toggles
/datum/verbs/menu/Settings/Ghost/chatterbox
	name = "Chat Box Spam"

TOGGLE_CHECKBOX(/datum/verbs/menu/Settings/Ghost/chatterbox, toggle_ghost_ears)()
	set name = "Show/Hide GhostEars"
	set category = "Preferences"
	set desc = "See All Speech"
	usr.client.prefs.chat_toggles ^= CHAT_GHOSTEARS
	to_chat(usr, "As a ghost, you will now [(usr.client.prefs.chat_toggles & CHAT_GHOSTEARS) ? "see all speech in the world" : "only see speech from nearby mobs"].")
	usr.client.prefs.save_preferences()
	SSblackbox.add_details("preferences_verb","Toggle Ghost Ears|[usr.client.prefs.chat_toggles & CHAT_GHOSTEARS]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/datum/verbs/menu/Settings/Ghost/chatterbox/toggle_ghost_ears/Get_checked(client/C)
	return C.prefs.chat_toggles & CHAT_GHOSTEARS

TOGGLE_CHECKBOX(/datum/verbs/menu/Settings/Ghost/chatterbox, toggle_ghost_sight)()
	set name = "Show/Hide GhostSight"
	set category = "Preferences"
	set desc = "See All Emotes"
	usr.client.prefs.chat_toggles ^= CHAT_GHOSTSIGHT
	to_chat(usr, "As a ghost, you will now [(usr.client.prefs.chat_toggles & CHAT_GHOSTSIGHT) ? "see all emotes in the world" : "only see emotes from nearby mobs"].")
	usr.client.prefs.save_preferences()
	SSblackbox.add_details("preferences_verb","Toggle Ghost Sight|[usr.client.prefs.chat_toggles & CHAT_GHOSTSIGHT]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/datum/verbs/menu/Settings/Ghost/chatterbox/toggle_ghost_sight/Get_checked(client/C)
	return C.prefs.chat_toggles & CHAT_GHOSTSIGHT

TOGGLE_CHECKBOX(/datum/verbs/menu/Settings/Ghost/chatterbox, toggle_ghost_whispers)()
	set name = "Show/Hide GhostWhispers"
	set category = "Preferences"
	set desc = "See All Whispers"
	usr.client.prefs.chat_toggles ^= CHAT_GHOSTWHISPER
	to_chat(usr, "As a ghost, you will now [(usr.client.prefs.chat_toggles & CHAT_GHOSTWHISPER) ? "see all whispers in the world" : "only see whispers from nearby mobs"].")
	usr.client.prefs.save_preferences()
	SSblackbox.add_details("preferences_verb","Toggle Ghost Whispers|[usr.client.prefs.chat_toggles & CHAT_GHOSTWHISPER]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/datum/verbs/menu/Settings/Ghost/chatterbox/toggle_ghost_whispers/Get_checked(client/C)
	return C.prefs.chat_toggles & CHAT_GHOSTWHISPER

TOGGLE_CHECKBOX(/datum/verbs/menu/Settings/Ghost/chatterbox, toggle_ghost_radio)()
	set name = "Show/Hide GhostRadio"
	set category = "Preferences"
	set desc = "See All Radio Chatter"
	usr.client.prefs.chat_toggles ^= CHAT_GHOSTRADIO
	to_chat(usr, "As a ghost, you will now [(usr.client.prefs.chat_toggles & CHAT_GHOSTRADIO) ? "see radio chatter" : "not see radio chatter"].")
	usr.client.prefs.save_preferences()
	SSblackbox.add_details("preferences_verb","Toggle Ghost Radio|[usr.client.prefs.chat_toggles & CHAT_GHOSTRADIO]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc! //social experiment, increase the generation whenever you copypaste this shamelessly GENERATION 1
/datum/verbs/menu/Settings/Ghost/chatterbox/toggle_ghost_radio/Get_checked(client/C)
	return C.prefs.chat_toggles & CHAT_GHOSTRADIO

TOGGLE_CHECKBOX(/datum/verbs/menu/Settings/Ghost/chatterbox, toggle_ghost_pda)()
	set name = "Show/Hide GhostPDA"
	set category = "Preferences"
	set desc = "See All PDA Messages"
	usr.client.prefs.chat_toggles ^= CHAT_GHOSTPDA
	to_chat(usr, "As a ghost, you will now [(usr.client.prefs.chat_toggles & CHAT_GHOSTPDA) ? "see all pda messages in the world" : "only see pda messages from nearby mobs"].")
	usr.client.prefs.save_preferences()
	SSblackbox.add_details("preferences_verb","Toggle Ghost PDA|[usr.client.prefs.chat_toggles & CHAT_GHOSTPDA]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/datum/verbs/menu/Settings/Ghost/chatterbox/toggle_ghost_pda/Get_checked(client/C)
	return C.prefs.chat_toggles & CHAT_GHOSTPDA

/datum/verbs/menu/Settings/Ghost/chatterbox/Events
	name = "Events"

//please be aware that the following two verbs have inverted stat output, so that "Toggle Deathrattle|1" still means you activated it
TOGGLE_CHECKBOX(/datum/verbs/menu/Settings/Ghost/chatterbox/Events, toggle_deathrattle)()
	set name = "Toggle Deathrattle"
	set category = "Preferences"
	set desc = "Death"
	usr.client.prefs.toggles ^= DISABLE_DEATHRATTLE
	usr.client.prefs.save_preferences()
	to_chat(usr, "You will [(usr.client.prefs.toggles & DISABLE_DEATHRATTLE) ? "no longer" : "now"] get messages when a sentient mob dies.")
	SSblackbox.add_details("preferences_verb", "Toggle Deathrattle|[!(usr.client.prefs.toggles & DISABLE_DEATHRATTLE)]") //If you are copy-pasting this, maybe you should spend some time reading the comments.
/datum/verbs/menu/Settings/Ghost/chatterbox/Events/toggle_deathrattle/Get_checked(client/C)
	return !(C.prefs.toggles & DISABLE_DEATHRATTLE)

TOGGLE_CHECKBOX(/datum/verbs/menu/Settings/Ghost/chatterbox/Events, toggle_arrivalrattle)()
	set name = "Toggle Arrivalrattle"
	set category = "Preferences"
	set desc = "New Player Arrival"
	usr.client.prefs.toggles ^= DISABLE_ARRIVALRATTLE
	to_chat(usr, "You will [(usr.client.prefs.toggles & DISABLE_ARRIVALRATTLE) ? "no longer" : "now"] get messages when someone joins the station.")
	usr.client.prefs.save_preferences()
	SSblackbox.add_details("preferences_verb", "Toggle Arrivalrattle|[!(usr.client.prefs.toggles & DISABLE_ARRIVALRATTLE)]") //If you are copy-pasting this, maybe you should rethink where your life went so wrong.
/datum/verbs/menu/Settings/Ghost/chatterbox/Events/toggle_arrivalrattle/Get_checked(client/C)
	return !(C.prefs.toggles & DISABLE_ARRIVALRATTLE)

TOGGLE_CHECKBOX(/datum/verbs/menu/Settings/Ghost, togglemidroundantag)()
	set name = "Toggle Midround Antagonist"
	set category = "Preferences"
	set desc = "Midround Antagonist"
	usr.client.prefs.toggles ^= MIDROUND_ANTAG
	usr.client.prefs.save_preferences()
	to_chat(usr, "You will [(usr.client.prefs.toggles & MIDROUND_ANTAG) ? "now" : "no longer"] be considered for midround antagonist positions.")
	SSblackbox.add_details("preferences_verb","Toggle Midround Antag|[usr.client.prefs.toggles & MIDROUND_ANTAG]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/datum/verbs/menu/Settings/Ghost/togglemidroundantag/Get_checked(client/C)
	return C.prefs.toggles & MIDROUND_ANTAG

TOGGLE_CHECKBOX(/datum/verbs/menu/Settings/Sound, toggletitlemusic)()
	set name = "Hear/Silence LobbyMusic"
	set category = "Preferences"
	set desc = "Hear Music In Lobby"
	usr.client.prefs.toggles ^= SOUND_LOBBY
	usr.client.prefs.save_preferences()
	if(usr.client.prefs.toggles & SOUND_LOBBY)
		to_chat(usr, "You will now hear music in the game lobby.")
		if(isnewplayer(usr))
			usr.client.playtitlemusic()
	else
		to_chat(usr, "You will no longer hear music in the game lobby.")
		usr.stop_sound_channel(CHANNEL_LOBBYMUSIC)
	SSblackbox.add_details("preferences_verb","Toggle Lobby Music|[usr.client.prefs.toggles & SOUND_LOBBY]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/datum/verbs/menu/Settings/Sound/toggletitlemusic/Get_checked(client/C)
	return C.prefs.toggles & SOUND_LOBBY


TOGGLE_CHECKBOX(/datum/verbs/menu/Settings/Sound, togglemidis)()
	set name = "Hear/Silence Midis"
	set category = "Preferences"
	set desc = "Hear Admin Triggered Sounds (Midis)"
	usr.client.prefs.toggles ^= SOUND_MIDI
	usr.client.prefs.save_preferences()
	if(usr.client.prefs.toggles & SOUND_MIDI)
		to_chat(usr, "You will now hear any sounds uploaded by admins.")
	else
		to_chat(usr, "You will no longer hear sounds uploaded by admins")
		usr.stop_sound_channel(CHANNEL_ADMIN)
		var/client/C = usr.client
		if(C && C.chatOutput && !C.chatOutput.broken && C.chatOutput.loaded)
			C.chatOutput.sendMusic(" ")
	SSblackbox.add_details("preferences_verb","Toggle Hearing Midis|[usr.client.prefs.toggles & SOUND_MIDI]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/datum/verbs/menu/Settings/Sound/togglemidis/Get_checked(client/C)
	return C.prefs.toggles & SOUND_MIDI


TOGGLE_CHECKBOX(/datum/verbs/menu/Settings/Sound, toggle_instruments)()
	set name = "Hear/Silence Instruments"
	set category = "Preferences"
	set desc = "Hear In-game Instruments"
	usr.client.prefs.toggles ^= SOUND_INSTRUMENTS
	usr.client.prefs.save_preferences()
	if(usr.client.prefs.toggles & SOUND_INSTRUMENTS)
		to_chat(usr, "You will now hear people playing musical instruments.")
	else
		to_chat(usr, "You will no longer hear musical instruments.")
	SSblackbox.add_details("preferences_verb","Toggle Instruments|[usr.client.prefs.toggles & SOUND_INSTRUMENTS]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/datum/verbs/menu/Settings/Sound/toggle_instruments/Get_checked(client/C)
	return C.prefs.toggles & SOUND_INSTRUMENTS


TOGGLE_CHECKBOX(/datum/verbs/menu/Settings/Sound, Toggle_Soundscape)()
	set name = "Hear/Silence Ambience"
	set category = "Preferences"
	set desc = "Hear Ambient Sound Effects"
	usr.client.prefs.toggles ^= SOUND_AMBIENCE
	usr.client.prefs.save_preferences()
	if(usr.client.prefs.toggles & SOUND_AMBIENCE)
		to_chat(usr, "You will now hear ambient sounds.")
	else
		to_chat(usr, "You will no longer hear ambient sounds.")
		usr.stop_sound_channel(CHANNEL_AMBIENCE)
		usr.stop_sound_channel(CHANNEL_BUZZ)
	SSblackbox.add_details("preferences_verb","Toggle Ambience|[usr.client.prefs.toggles & SOUND_AMBIENCE]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/datum/verbs/menu/Settings/Sound/Toggle_Soundscape/Get_checked(client/C)
	return C.prefs.toggles & SOUND_AMBIENCE


TOGGLE_CHECKBOX(/datum/verbs/menu/Settings/Sound, toggle_ship_ambience)()
	set name = "Hear/Silence Ship Ambience"
	set category = "Preferences"
	set desc = "Hear Ship Ambience Roar"
	usr.client.prefs.toggles ^= SOUND_SHIP_AMBIENCE
	usr.client.prefs.save_preferences()
	if(usr.client.prefs.toggles & SOUND_SHIP_AMBIENCE)
		to_chat(usr, "You will now hear ship ambience.")
	else
		to_chat(usr, "You will no longer hear ship ambience.")
		usr.stop_sound_channel(CHANNEL_BUZZ)
		usr.client.ambience_playing = 0
	SSblackbox.add_details("preferences_verb", "Toggle Ship Ambience|[usr.client.prefs.toggles & SOUND_SHIP_AMBIENCE]") //If you are copy-pasting this, I bet you read this comment expecting to see the same thing :^)
/datum/verbs/menu/Settings/Sound/toggle_ship_ambience/Get_checked(client/C)
	return C.prefs.toggles & SOUND_SHIP_AMBIENCE


TOGGLE_CHECKBOX(/datum/verbs/menu/Settings/Sound, toggle_announcement_sound)()
	set name = "Hear/Silence Announcements"
	set category = "Preferences"
	set desc = "Hear Announcement Sound"
	usr.client.prefs.toggles ^= SOUND_ANNOUNCEMENTS
	to_chat(usr, "You will now [(usr.client.prefs.toggles & SOUND_ANNOUNCEMENTS) ? "hear announcement sounds" : "no longer hear announcements"].")
	usr.client.prefs.save_preferences()
	SSblackbox.add_details("preferences_verb","Toggle Announcement Sound|[usr.client.prefs.toggles & SOUND_ANNOUNCEMENTS]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/datum/verbs/menu/Settings/Sound/toggle_announcement_sound/Get_checked(client/C)
	return C.prefs.toggles & SOUND_ANNOUNCEMENTS


TOGGLE_CHECKBOX(/datum/verbs/menu/Settings/Sound, toggleprayersounds)()
	set name = "Hear/Silence Prayer Sounds"
	set category = "Preferences"
	set desc = "Hear Prayer Sounds"
	usr.client.prefs.toggles ^= SOUND_PRAYERS
	usr.client.prefs.save_preferences()
	if(usr.client.prefs.toggles & SOUND_PRAYERS)
		to_chat(usr, "You will now hear prayer sounds.")
	else
		to_chat(usr, "You will no longer prayer sounds.")
	SSblackbox.add_details("admin_toggle", "Toggle Prayer Sounds|[usr.client.prefs.toggles & SOUND_PRAYERS]")
/datum/verbs/menu/Settings/Sound/toggleprayersounds/Get_checked(client/C)
	return C.prefs.toggles & SOUND_PRAYERS


/datum/verbs/menu/Settings/Sound/verb/stop_client_sounds()
	set name = "Stop Sounds"
	set category = "Preferences"
	set desc = "Stop Current Sounds"
	SEND_SOUND(usr, sound(null))
	SSblackbox.add_details("preferences_verb","Stop Self Sounds") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


TOGGLE_CHECKBOX(/datum/verbs/menu/Settings, listen_ooc)()
	set name = "Show/Hide OOC"
	set category = "Preferences"
	set desc = "Show OOC Chat"
	usr.client.prefs.chat_toggles ^= CHAT_OOC
	usr.client.prefs.save_preferences()
	to_chat(usr, "You will [(usr.client.prefs.chat_toggles & CHAT_OOC) ? "now" : "no longer"] see messages on the OOC channel.")
	SSblackbox.add_details("preferences_verb","Toggle Seeing OOC|[usr.client.prefs.chat_toggles & CHAT_OOC]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/datum/verbs/menu/Settings/listen_ooc/Get_checked(client/C)
	return C.prefs.chat_toggles & CHAT_OOC


GLOBAL_LIST_INIT(ghost_forms, list("ghost","ghostking","ghostian2","skeleghost","ghost_red","ghost_black", \
							"ghost_blue","ghost_yellow","ghost_green","ghost_pink", \
							"ghost_cyan","ghost_dblue","ghost_dred","ghost_dgreen", \
							"ghost_dcyan","ghost_grey","ghost_dyellow","ghost_dpink", "ghost_purpleswirl","ghost_funkypurp","ghost_pinksherbert","ghost_blazeit",\
							"ghost_mellow","ghost_rainbow","ghost_camo","ghost_fire", "catghost"))
/client/proc/pick_form()
	if(!is_content_unlocked())
		alert("This setting is for accounts with BYOND premium only.")
		return
	var/new_form = input(src, "Thanks for supporting BYOND - Choose your ghostly form:","Thanks for supporting BYOND",null) as null|anything in GLOB.ghost_forms
	if(new_form)
		prefs.ghost_form = new_form
		prefs.save_preferences()
		if(isobserver(mob))
			var/mob/dead/observer/O = mob
			O.update_icon(new_form)

GLOBAL_LIST_INIT(ghost_orbits, list(GHOST_ORBIT_CIRCLE,GHOST_ORBIT_TRIANGLE,GHOST_ORBIT_SQUARE,GHOST_ORBIT_HEXAGON,GHOST_ORBIT_PENTAGON))

/client/proc/pick_ghost_orbit()
	if(!is_content_unlocked())
		alert("This setting is for accounts with BYOND premium only.")
		return
	var/new_orbit = input(src, "Thanks for supporting BYOND - Choose your ghostly orbit:","Thanks for supporting BYOND",null) as null|anything in GLOB.ghost_orbits
	if(new_orbit)
		prefs.ghost_orbit = new_orbit
		prefs.save_preferences()
		if(isobserver(mob))
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
		if(isobserver(mob))
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
		if(isobserver(mob))
			var/mob/dead/observer/O = mob
			O.update_sight()

/client/verb/toggle_intent_style()
	set name = "Toggle Intent Selection Style"
	set category = "Preferences"
	set desc = "Toggle between directly clicking the desired intent or clicking to rotate through."
	prefs.toggles ^= INTENT_STYLE
	to_chat(src, "[(prefs.toggles & INTENT_STYLE) ? "Clicking directly on intents selects them." : "Clicking on intents rotates selection clockwise."]")
	prefs.save_preferences()
	SSblackbox.add_details("preferences_verb","Toggle Intent Selection|[prefs.toggles & INTENT_STYLE]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_hud_pref()
	set name = "Toggle Ghost HUD"
	set category = "Preferences"
	set desc = "Hide/Show Ghost HUD"

	prefs.ghost_hud = !prefs.ghost_hud
	to_chat(src, "Ghost HUD will now be [prefs.ghost_hud ? "visible" : "hidden"].")
	prefs.save_preferences()
	if(isobserver(mob))
		mob.hud_used.show_hud()
	SSblackbox.add_details("preferences_verb","Toggle Ghost HUD|[prefs.ghost_hud]")

/client/verb/toggle_inquisition() // warning: unexpected inquisition
	set name = "Toggle Inquisitiveness"
	set desc = "Sets whether your ghost examines everything on click by default"
	set category = "Preferences"

	prefs.inquisitive_ghost = !prefs.inquisitive_ghost
	prefs.save_preferences()
	if(prefs.inquisitive_ghost)
		to_chat(src, "<span class='notice'>You will now examine everything you click on.</span>")
	else
		to_chat(src, "<span class='notice'>You will no longer examine things you click on.</span>")
	SSblackbox.add_details("preferences_verb","Toggle Ghost Inquisitiveness|[prefs.inquisitive_ghost]")

//Admin Preferences
/client/proc/toggleadminhelpsound()
	set name = "Hear/Silence Adminhelps"
	set category = "Preferences"
	set desc = "Toggle hearing a notification when admin PMs are received"
	if(!holder)
		return
	prefs.toggles ^= SOUND_ADMINHELP
	prefs.save_preferences()
	to_chat(usr, "You will [(prefs.toggles & SOUND_ADMINHELP) ? "now" : "no longer"] hear a sound when adminhelps arrive.")
	SSblackbox.add_details("admin_toggle","Toggle Adminhelp Sound|[prefs.toggles & SOUND_ADMINHELP]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleannouncelogin()
	set name = "Do/Don't Announce Login"
	set category = "Preferences"
	set desc = "Toggle if you want an announcement to admins when you login during a round"
	if(!holder)
		return
	prefs.toggles ^= ANNOUNCE_LOGIN
	prefs.save_preferences()
	to_chat(usr, "You will [(prefs.toggles & ANNOUNCE_LOGIN) ? "now" : "no longer"] have an announcement to other admins when you login.")
	SSblackbox.add_details("admin_toggle","Toggle Login Announcement|[prefs.toggles & ANNOUNCE_LOGIN]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_hear_radio()
	set name = "Show/Hide Radio Chatter"
	set category = "Preferences"
	set desc = "Toggle seeing radiochatter from nearby radios and speakers"
	if(!holder) return
	prefs.chat_toggles ^= CHAT_RADIO
	prefs.save_preferences()
	to_chat(usr, "You will [(prefs.chat_toggles & CHAT_RADIO) ? "now" : "no longer"] see radio chatter from nearby radios or speakers")
	SSblackbox.add_details("admin_toggle","Toggle Radio Chatter|[prefs.chat_toggles & CHAT_RADIO]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/deadchat()
	set name = "Show/Hide Deadchat"
	set category = "Preferences"
	set desc ="Toggles seeing deadchat"
	prefs.chat_toggles ^= CHAT_DEAD
	prefs.save_preferences()
	to_chat(src, "You will [(prefs.chat_toggles & CHAT_DEAD) ? "now" : "no longer"] see deadchat.")
	SSblackbox.add_details("admin_toggle","Toggle Deadchat Visibility|[prefs.chat_toggles & CHAT_DEAD]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleprayers()
	set name = "Show/Hide Prayers"
	set category = "Preferences"
	set desc = "Toggles seeing prayers"
	prefs.chat_toggles ^= CHAT_PRAYER
	prefs.save_preferences()
	to_chat(src, "You will [(prefs.chat_toggles & CHAT_PRAYER) ? "now" : "no longer"] see prayerchat.")
	SSblackbox.add_details("admin_toggle","Toggle Prayer Visibility|[prefs.chat_toggles & CHAT_PRAYER]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

