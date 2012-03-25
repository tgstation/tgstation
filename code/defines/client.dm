/client
//START Admin Things
	//This should be changed to a datum
	var/obj/admins/holder = null // Stays null if client isn't an admin. Stores properties about the admin, if not null.
	var/buildmode = 0
	var/stealth = 0
	var/fakekey = null
	var/seeprayers = 0
	//Hosts can change their color
	var/ooccolor = "#b82e00"
	var/muted = null //Can't talk in OOC, say, whisper, emote... anything except for adminhelp and admin-pm. An admin punishment
	var/muted_complete = null //Can't talk in any way shape or form (muted + can't adminhelp or respond to admin pm-s). An admin punishment
	var/admin_invis = 0

//END Admin Things

	var/listen_ooc = 1
	var/move_delay = 1
	var/moving = null
	var/adminobs = null
	var/deadchat = 0.0
	var/changes = 0
	var/canplaysound = 1
	var/ambience_playing = null
	var/no_ambi = 0
	var/area = null
	var/played = 0
	var/team = null
	var/warned = 0
	var/be_syndicate = 0 //Moving this into client vars, since I was silly when I made it.

	var/STFU_ghosts		//80+ people rounds are fun to admin when text flies faster than airport security
	var/STFU_radio		//80+ people rounds are fun to admin when text flies faster than airport security
	var/sound_adminhelp = 0 //If set to 1 this will play a sound when adminhelps are received.

	var/midis = 1 //Check if midis should be played for someone
	var/bubbles = 1 //Check if bubbles should be displayed for someone
	var/be_alien = 0 //Check if that guy wants to be an alien
	var/be_pai = 1 //Consider client when searching for players to recruit as a pAI


	var/vote = null
	var/showvote = null



	// comment out the line below when debugging locally to enable the options & messages menu
	//control_freak = 1