
GLOBAL_VAR(highlander_datum)

//yep you guessed it back at it again with another datum singleton. proc to create it further down
/datum/highlander_controller

/datum/highlander_controller/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, .proc/new_highlander)
	sound_to_playing_players('sound/misc/highlander.ogg')
	send_to_playing_players("<span class='boldannounce'><font size=6>THERE CAN BE ONLY ONE</font></span>")
	for(var/obj/item/disk/nuclear/N in GLOB.poi_list)
		var/datum/component/stationloving/component = N.GetComponent(/datum/component/stationloving)
		if (component)
			component.relocate() //Gets it out of bags and such

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD)
			continue
		H.make_scottish()

	for(var/mob/living/silicon/ai/AI in GLOB.player_list)
		if(!istype(AI) || AI.stat == DEAD)
			continue
		if(AI.deployed_shell)
			AI.deployed_shell.undeploy()
		AI.change_mob_type(/mob/living/silicon/robot , null, null)
		AI.gib()

	for(var/mob/living/silicon/robot/robot in GLOB.player_list)
		if(!istype(robot) || robot.stat == DEAD)
			continue
		if(robot.shell)
			robot.gib()
			continue
		robot.make_scottish()
	addtimer(CALLBACK(SSshuttle.emergency, /obj/docking_port/mobile/emergency.proc/request, null, 1), 50)

/datum/highlander_controller/Destroy(force, ...)
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)

/datum/highlander_controller/proc/new_highlander(mob/living/carbon/human/new_crewmember, rank)
	SIGNAL_HANDLER

	to_chat(new_crewmember, "<span class='userdanger'><i>THERE CAN BE ONLY ONE!!!</i></span>")
	new_crewmember.make_scottish()

/client/proc/only_one(was_delayed = FALSE) //Gives everyone kilts, berets, claymores, and pinpointers, with the objective to hijack the emergency shuttle.
	if(!SSticker.HasRoundStarted())
		alert("The game hasn't started yet!")
		return

	if(was_delayed) //sends more accurate logs
		message_admins("<span class='adminnotice'>[key_name_admin(usr)]'s delayed THERE CAN ONLY BE ONE started!</span>")
		log_admin("[key_name(usr)] delayed THERE CAN ONLY BE ONE started.")
	else
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] used THERE CAN BE ONLY ONE!</span>")
		log_admin("[key_name(usr)] used THERE CAN BE ONLY ONE.")

	GLOB.highlander = new /datum/highlander_controller

/client/proc/only_one_delayed()
	send_to_playing_players("<span class='userdanger'>Bagpipes begin to blare. You feel Scottish pride coming over you.</span>")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] used (delayed) THERE CAN BE ONLY ONE!</span>")
	log_admin("[key_name(usr)] used delayed THERE CAN BE ONLY ONE.")
	addtimer(CALLBACK(src, .proc/only_one, TRUE), 42 SECONDS)

/mob/living/carbon/human/proc/make_scottish()
	mind.add_antag_datum(/datum/antagonist/highlander)

/mob/living/silicon/robot/proc/make_scottish()
	mind.add_antag_datum(/datum/antagonist/highlander/robot)

/proc/new_highlander(mob/living/carbon/human/new_crewmember, rank)
	SIGNAL_HANDLER

	to_chat(new_crewmember, "<span class='userdanger'><i>THERE CAN BE ONLY ONE!!!</i></span>")
	new_crewmember.make_scottish()
