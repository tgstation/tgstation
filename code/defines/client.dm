/client
//START Admin Things
	//This should be changed to a datum
	var/obj/admins/holder = null
	var/buildmode = 0
	var/stealth = 0
	var/fakekey = null
	//Hosts can change their color
	var/ooccolor = "#b82e00"

//END Admin Things

	//Key auth things
	authenticate = 0
	var/authenticated = 0
	var/authenticating = 0

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
	var/karma = 0
	var/karma_spent = 0


	var/midis = 1 //Check if midis should be played for someone -- Urist
	var/bubbles = 1 //Check if bubbles should be displayed for someone -- Doohl
	var/be_alien = 0 //Check if that guy wants to be an alien -- Urist
	var/be_pai = 1 //Consider client when searching for players to recruit as a pAI -- TLE


	var/vote = null
	var/showvote = null



	// comment out the line below when debugging locally to enable the options & messages menu
	control_freak = 1