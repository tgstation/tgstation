/client
		////////////////
		//ADMIN THINGS//
		////////////////
	var/datum/admins/holder = null
	var/buildmode		= 0
	var/seeprayers		= 0

	var/muted			= 0
	var/last_message	= "" //Contains the last message sent by this client - used to protect against copy-paste spamming.
	var/last_message_count = 0 //contins a number of how many times a message identical to last_message was sent.

	var/warned			= 0

		/////////
		//OTHER//
		/////////
	var/listen_ooc		= 1
	var/move_delay		= 1
	var/moving			= null
	var/adminobs		= null
	var/deadchat		= 0
	var/changes			= 0
	var/area			= null
	var/played			= 0
	var/be_alien		= 0		//Check if that guy wants to be an alien
	var/be_pai			= 1		//Consider client when searching for players to recruit as a pAI
	var/be_syndicate    = 1     //Consider client for late-game autotraitor
	var/activeslot		= 1		//Default active slot!
	var/STFU_ghosts				//80+ people rounds are fun to admin when text flies faster than airport security
	var/STFU_radio				//80+ people rounds are fun to admin when text flies faster than airport security
	var/STFU_atklog		= 0

		///////////////
		//SOUND STUFF//
		///////////////
	var/canplaysound	= 1
	var/ambience_playing= null
	var/no_ambi			= 0		//Toggle Ambience
	var/midis			= 1		//Toggle Midis

		////////////
		//SECURITY//
		////////////
	var/next_allowed_topic_time = 10
	// comment out the line below when debugging locally to enable the options & messages menu
	control_freak = 1
