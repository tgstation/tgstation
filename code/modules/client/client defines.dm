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
	var/muted			= null 	//Can't talk in OOC, say, whisper, emote... anything except for adminhelp and admin-pm. An admin punishment
	var/muted_complete	= null	//Can't talk in any way shape or form (muted + can't adminhelp or respond to admin pm-s). An admin punishment
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



