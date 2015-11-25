/datum/game_mode/meteor
	name = "meteor"
	config_tag = "meteor"

	var/const/waittime_l = 600 //Lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //Upper bound on time before intercept arrives (in tenths of seconds)

	var/const/meteorannouncedelay_l = 2100 //Lower bound on announcement, here 3 minutes and 30 seconds
	var/const/meteorannouncedelay_h = 3000 //Upper bound on announcement, here 5 minutes
	var/meteorannouncedelay = 2400 //Default final announcement delay
	var/const/supplydelay = 100 //Delay before meteor supplies are spawned in tenth of seconds
	var/const/meteordelay_l = 3000 //Lower bound to meteor wave arrival, here 5 minutes
	var/const/meteordelay_h = 4500 //Higher bound to meteor wave arrival, here 7 and a half minutes
	var/const/meteorshuttlemultiplier = 3 //How much more will we need to hold out ? Here 30 minutes until the shuttle arrives. Multiplies by 10
	var/meteordelay = 7500 //Default final meteor delay
	var/meteors_allowed = 0 //Can we send the meteors ?
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

/datum/universal_state/meteor_storm
 	name = "Meteor Storm"
 	desc = "A meteor storm is currently wrecking havoc around this sector. Duck and cover."

 	decay_rate = 0 //Just to make sure

/datum/universal_state/meteor_storm/OnShuttleCall(var/mob/user)
	if(user)
		to_chat(user, "<span class='sinister'>You hear an automatic dispatch from Nanotrasen. It states that Centcomm is being shielded due to an incoming meteor storm and that regular shuttle service has been interrupted.</span>")
	return 0

/datum/game_mode/meteor/post_setup()

	//Let's set up the announcement and meteor delay immediatly to send to the admins and use later
	meteorannouncedelay = rand((meteorannouncedelay_l/600), (meteorannouncedelay_h/600))*600 //Minute interval for simplicity
	meteordelay = rand((meteordelay_l/600), (meteordelay_h/600))*600 //Ditto above

	spawn(450) //Give everything 45 seconds to initialize, this does not delay the rest of post_setup() nor the game and ensures deadmins aren't aware in advance and the admins are
		message_admins("Meteor storm confirmed by Space Weather Incorporated. Announcement arrives in [round((meteorannouncedelay-450)/600)] minutes, actual meteors in [round((meteordelay+meteorannouncedelay-450)/600)] minutes. Shuttle will take [10*meteorshuttlemultiplier] minutes to arrive and supplies will be dispatched in the Bar.")

	spawn(rand(waittime_l, waittime_h))
		send_intercept()

	spawn(meteorannouncedelay)
		if(prob(70)) //Slighty off-scale
			command_alert("A meteor storm has been detected in proximity of [station_name()] and is expected to strike within [round((rand(meteordelay - 600, meteordelay + 600))/600)] minutes. A backup emergency shuttle is being dispatched and emergency gear should be teleported into your station's Bar area in [supplydelay/10] seconds.", \
			"Space Weather Automated Announcements")
		else //Oh boy
			command_alert("A meteor storm has been detected in proximity of [station_name()] and is expected to strike within [round((rand(meteordelay - 1800, meteordelay + 1800))/600)] minutes. A backup emergency shuttle is being dispatched and emergency gear should be teleported into your station's Bar area in [supplydelay/10] seconds.", \
			"Space Weather Automated Announcements")
		world << sound('sound/AI/meteorround.ogg')
		/*
		for(var/obj/item/mecha_parts/mecha_equipment/tool/rcd/rcd in world) //Borg RCDs are fairly cheap, so disabling those
			rcd.disabled = 1
		*/

		spawn(100) //Panic interval
			emergency_shuttle.incall(meteorshuttlemultiplier)
			captain_announce("A backup emergency shuttle has been called. It will arrive in [round((emergency_shuttle.timeleft())/60)] minutes. Justification : 'Major meteor storm inbound. Evacuation procedures deferred to Space Weather Inc. THIS IS NOT A DRILL'")
			world << sound('sound/AI/shuttlecalled.ogg')
			SetUniversalState(/datum/universal_state/meteor_storm)

		spawn(supplydelay)

			meteor_initial_supply() //Handled in meteor_supply.dm

		spawn(meteordelay)
			meteors_allowed = 1

/datum/game_mode/meteor/process()
	if(meteors_allowed)
		var/meteors_in_wave = rand(50, 100) //Between 25 and 50 meteors per wave
		meteor_wave(meteors_in_wave, 3)
	return

/datum/game_mode/meteor/declare_completion()
	var/text
	var/survivors = 0
	for(var/mob/living/player in player_list)
		if(player.stat != DEAD)
			var/turf/location = get_turf(player.loc)
			if(!location)
				continue
			switch(location.loc.type)
				if(/area/shuttle/escape/centcom)
					text += "<br><b><font size=2>[player.real_name] escaped on the emergency shuttle</font></b>"
				if(/area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod5/centcom)
					text += "<br><font size=2>[player.real_name] escaped in a life pod.</font>"
				else
					text += "<br><font size=1>[player.real_name] survived but is stranded without any hope of rescue.</font>"
			survivors++

	if(survivors)
		to_chat(world, "<span class='info'><B>The following survived the meteor storm</B>:[text]</span>")
	else
		to_chat(world, "<span class='info'><B>The meteors crashed this station with no survivors!</B></span>")

	feedback_set_details("round_end_result", "end - evacuation")
	feedback_set("round_end_result", survivors)

	..()
	return 1
