/client
	var/obj/admins/holder = null
	var/authenticated = 0
	var/goon = 0
	var/beta_tester = 0
	var/authenticating = 0
	var/listen_ooc = 1
	var/move_delay = 1
	var/moving = null
	var/vote = null
	var/showvote = null
	var/adminobs = null
	var/deadchat = 0.0
	var/changes = 0
	var/canplaysound = 1
	var/ambience_playing = null
	var/no_ambi = 0
	var/area = null
	var/played = 0
	var/team = null
	var/buildmode = 0
	var/stealth = 0
	var/fakekey = null
	var/warned = 0
	var/karma = 0
	var/karma_spent = 0
	var/ooccolor = "#b82e00" //only used for admins of host level, default is equal to admin default
	var/midis = 1 //Check if midis should be played for someone -- Urist
	var/be_alien = 0 //Check if that guy wants to be an alien -- Urist

	authenticate = 0
	// comment out the line below when debugging locally to enable the options & messages menu
	control_freak = 1