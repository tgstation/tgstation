/client
		////////////////
		//ADMIN THINGS//
		////////////////
	var/datum/admins/holder = null
	var/buildmode		= 0
	var/list/buildmode_objs = list()

	var/last_message	= "" //Contains the last message sent by this client - used to protect against copy-paste spamming.
	var/last_message_count = 0 //contins a number of how many times a message identical to last_message was sent.

	var/teleport_here_pref = "Flashy"	//Flashy, teleports instantly; Stealthy, teleports with a discret fade-in
	var/flashy_level = 1	//0 = no additional effect, 1 = visual effect and sound, 2 = shake the fucking screen!, 3 = [atom] HAS RISEN!
	var/stealthy_level = 20	//how many tenth of seconds seconds do you want the fade-in to last?

		/////////
		//OTHER//
		/////////
	var/datum/preferences/prefs = null
	var/moving			= null
	var/adminobs		= null
	var/area			= null
	var/time_died_as_mouse = null //when the client last died as a mouse


		///////////////
		//SOUND STUFF//
		///////////////
	var/ambience_playing= null
	var/played			= 0

		////////////
		//SECURITY//
		////////////
	var/next_allowed_topic_time = 10
	// comment out the line below when debugging locally to enable the options & messages menu
	//control_freak = 1


		////////////////////////////////////
		//things that require the database//
		////////////////////////////////////
	var/player_age = "Requires database"	//So admins know why it isn't working - Used to determine how old the account is - in days.
	var/related_accounts_ip = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this ip
	var/related_accounts_cid = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this computer id

	//This breaks a lot of shit.  - N3X
	preload_rsc = 1 // This is 0 so we can set it to an URL once the player logs in and have them download the resources from a different server.

	// Used by html_interface module.
	var/hi_last_pos

	/////////////////////////////////////////////
	// /vg/: MEDIAAAAAAAA
	// Set on login.
	var/datum/media_manager/media = null

	var/filling = 0 //SOME STUPID SHIT POMF IS DOING
	var/haszoomed = 0
	var/updating_colour = 0

	// Their chat window, sort of important.
	// See /goon/code/datums/browserOutput.dm
	var/datum/chatOutput/chatOutput

		////////////
		//PARALLAX//
		////////////
	var/list/parallax = list()
	var/list/parallax_movable = list()
	var/list/parallax_offset = list()
	var/turf/previous_turf = null
	var/obj/screen/plane_master/parallax_master/parallax_master = null
	var/obj/screen/plane_master/parallax_dustmaster/parallax_dustmaster = null
	var/obj/screen/plane_master/parallax_spacemaster/parallax_spacemaster = null