//Some of this is being changed to a datum to cut down on uneccessary variables at the client level.	~Carn
/client
		////////////////
		//ADMIN THINGS//
		////////////////
	var/obj/admins/holder = null
	var/buildmode		= 0
	var/stealth			= 0
	var/fakekey			= null
	var/seeprayers		= 0
	var/ooccolor		= "#b82e00"

	var/muted_ic			//can't use 'say' while alive or emotes.
	var/muted_ooc			//can't speak in ooc
	var/muted_deadchat		//can't use 'say' while dead or DSAY
	var/muted_pray			//can't send prayers
	var/muted_adminhelp		//can't send adminhelps, PM-s or use ASAY

	var/last_message = "" //Contains the last message sent by this client - used to protect against copy-paste spamming.
	var/last_message_count = 0 //contins a number of how many times a message identical to last_message was sent.

	var/warned			= 0
	var/sound_adminhelp = 0 	//If set to 1 this will play a sound when adminhelps are received.

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
	var/team			= null
	var/be_alien		= 0		//Check if that guy wants to be an alien
	var/be_pai			= 1		//Consider client when searching for players to recruit as a pAI
	var/vote			= null
	var/showvote		= null
	var/activeslot		= 1		//Default active slot!
	var/STFU_ghosts				//80+ people rounds are fun to admin when text flies faster than airport security
	var/STFU_radio				//80+ people rounds are fun to admin when text flies faster than airport security

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



