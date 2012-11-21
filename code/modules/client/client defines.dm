/client
		////////////////
		//ADMIN THINGS//
		////////////////
	var/datum/admins/holder = null
	var/buildmode		= 0

	var/last_message	= "" //Contains the last message sent by this client - used to protect against copy-paste spamming.
	var/last_message_count = 0 //contins a number of how many times a message identical to last_message was sent.

		/////////
		//OTHER//
		/////////
	var/datum/preferences/prefs = null
	var/move_delay		= 1
	var/moving			= null
	var/adminobs		= null
	var/area			= null

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
	control_freak = 1



