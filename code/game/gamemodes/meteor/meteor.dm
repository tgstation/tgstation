/datum/game_mode/meteor
	name = "meteor"
	config_tag = "meteor"

	var/const/waittime_l = 600 //Lower interval on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //Upper interval on time before intercept arrives (in tenths of seconds)

	var/const/meteor_announce_delay_l = 2100 //Lower interval on announcement, here 3 minutes and 30 seconds
	var/const/meteor_announce_delay_h = 3000 //Upper interval on announcement, here 5 minutes
	var/meteor_announce_delay = 2400 //Default final announcement delay

	required_players = 0
	required_players_secret = 20

	uplink_welcome = "EVIL METEOR Uplink Console:"
	uplink_uses = 10

/datum/game_mode/meteor/announce()
	to_chat(world, "<B>The current game mode is - Meteor!</B>")
	to_chat(world, "<B>The space station is about to be struck by a major meteor shower. You must hold out until the escape shuttle arrives.</B>")

/datum/game_mode/meteor/pre_setup()
	log_admin("Starting a round of meteor.")
	message_admins("Starting a round of meteor.")
	return 1

/datum/game_mode/meteor/post_setup()

	//Let's set up the announcement and meteor delay immediatly to send to the admins and use later
	meteor_announce_delay = rand((meteor_announce_delay_l/600), (meteor_announce_delay_h/600)) * 600 //Minute interval for simplicity

	spawn(300) //Give everything 30 seconds to initialize, this does not delay the rest of post_setup() nor the game and ensures deadmins aren't aware in advance and the admins are
		message_admins("Meteor storm confirmed by Space Weather Incorporated. Announcement arrives in approximately [round((meteor_announce_delay-200)/600)] minutes, further information will be given then.")

	spawn(rand(waittime_l, waittime_h))
		if(!mixed)
			send_intercept()

	spawn(meteor_announce_delay)

		meteor_universal_state()

/datum/universal_state/meteor_storm
	name = "Meteor Storm"
	desc = "A meteor storm is currently wrecking havoc around this sector. Duck and cover."

	decay_rate = 0 //Just to make sure

	var/meteor_extra_announce_delay = 0 //Independent from the gamemode delay. Delay from firing universal state before stuff happens

	var/supply_delay = 100 //Delay before meteor supplies are spawned in tenth of seconds

	var/meteor_shuttle_multiplier = 3 //How much more will we need to hold out ? Here 30 minutes until the shuttle arrives. Multiplies by 10

	var/const/meteor_delay_l = 4500 //Lower interval to meteor wave arrival, here 7.5 minutes
	var/const/meteor_delay_h = 6000 //Higher interval to meteor wave arrival, here 10 minutes
	var/meteor_delay = 0 //Final meteor delay, must be defined as 0 to automatically generate

	var/meteors_allowed = 0 //Can we send the meteors ?

	var/meteor_wave_size_l = 150 //Lower interval to meteor wave size
	var/meteor_wave_size_h = 200 //Higher interval to meteor wave size

//We want a ton of extra variables to allow us to do fancy things with it
//We can't inherit directly because of a host of reasons, all good I assure you
/proc/meteor_universal_state(var/on_exit = 1, var/extra_delay = 100, var/supply_delay = 100, var/shuttle_mult = 3, var/delay = 0, var/size_l = 150, var/size_h = 200)

	if(on_exit)
		universe.OnExit()

	var/datum/universal_state/meteor_storm/meteor_storm = new /datum/universal_state/meteor_storm

	meteor_storm.meteor_extra_announce_delay = extra_delay
	meteor_storm.supply_delay = supply_delay
	meteor_storm.meteor_shuttle_multiplier = shuttle_mult
	meteor_storm.meteor_delay = delay
	meteor_storm.meteor_wave_size_l = size_l
	meteor_storm.meteor_wave_size_h = size_h

	meteor_storm.OnEnter()

/datum/universal_state/meteor_storm/OnShuttleCall(var/mob/user)
	if(user)
		to_chat(user, "<span class='sinister'>You hear an automatic dispatch from Nanotrasen. It states that Centcomm is being shielded due to an incoming meteor storm and that regular shuttle service has been interrupted.</span>")
	return 0

/datum/universal_state/meteor_storm/OnEnter()

	sleep(meteor_extra_announce_delay) //Pause everything as according to the extra delay

	world << sound('sound/machines/warning.ogg') //The same chime as the Delta countdown, just twice

	if(!meteor_delay)
		meteor_delay = rand((meteor_delay_l/600), (meteor_delay_h/600))*600 //Let's set up the meteor delay in here

	sleep(20) //Two seconds for warning to play

	if(prob(70)) //Slighty off-scale
		command_alert("A meteor storm has been detected in proximity of [station_name()] and is expected to strike within [round((rand(meteor_delay - 600, meteor_delay + 600))/600)] minutes. A backup emergency shuttle is being dispatched and emergency gear should be teleported into your station's Bar area in [supply_delay/10] seconds.", \
		"Space Weather Automated Announcements", alert = 'sound/AI/meteorround.ogg')
	else //Oh boy
		command_alert("A meteor storm has been detected in proximity of [station_name()] and is expected to strike within [round((rand(meteor_delay - 1800, meteor_delay + 1800))/600)] minutes. A backup emergency shuttle is being dispatched and emergency gear should be teleported into your station's Bar area in [supply_delay/10] seconds.", \
		"Space Weather Automated Announcements", alert = 'sound/AI/meteorround.ogg')

	message_admins("Meteor Storm announcement given. Meteors will arrive in approximately [round(meteor_delay/600)] minutes. Shuttle will take [10*meteor_shuttle_multiplier] minutes to arrive and supplies are about to be dispatched in the Bar.")

	spawn(100) //Time for the announcement to spell out)

		emergency_shuttle.incall(meteor_shuttle_multiplier)
		captain_announce("A backup emergency shuttle has been called. It will arrive in [round((emergency_shuttle.timeleft())/60)] minutes. Justification : 'Major meteor storm inbound. Evacuation procedures deferred to Space Weather Inc. THIS IS NOT A DRILL'")
		world << sound('sound/AI/shuttlecalled.ogg')

	spawn(supply_delay) //Panic inverval

		meteor_initial_supply() //Handled in meteor_supply.dm

		ticker.StartThematic("endgame") //We can start building up now and then. If someone feels like this gamemode deserves a unique music playlist, they can go ahead and do that

		spawn(meteor_delay)
			meteors_allowed = 1

/datum/universal_state/meteor_storm/process()
	if(meteors_allowed)
		var/meteors_in_wave = rand(meteor_wave_size_l, meteor_wave_size_h)
		meteor_wave(meteors_in_wave, 3)
	return

//Important note : This will only fire if the Meteors gamemode was fired
/datum/game_mode/meteor/declare_completion()
	var/text
	var/escapees = 0
	var/survivors = 0
	for(var/mob/living/player in player_list)
		if(player.stat != DEAD)
			var/turf/location = get_turf(player.loc)
			if(!location)
				continue
			switch(location.loc.type)
				if(/area/shuttle/escape/centcom)
					text += "<br><b><font size=2>[player.real_name] escaped on the emergency shuttle</font></b>"
					escapees++
					survivors++
				if(/area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod5/centcom)
					text += "<br><font size=2>[player.real_name] escaped in a life pod.</font>"
					escapees++
					survivors++
				else
					text += "<br><font size=1>[player.real_name] is stranded in outer space without any hope of rescue.</font>"
					survivors++

	if(escapees)
		to_chat(world, "<span class='info'><B>The following escaped from the meteor storm</B>:[text]</span>")
	else if(survivors)
		to_chat(world, "<span class='info'><B>No-one escaped the meteor storm. The following are still alive for now</B>:[text]</span>")
	else
		to_chat(world, "<span class='info'><B>The meteor storm crashed this station with no survivors!</B></span>")

	feedback_set_details("round_end_result", "end - evacuation")
	feedback_set("round_end_result", survivors)

	..()
	return 1
