
GLOBAL_DATUM(highlander_controller, /datum/highlander_controller)

/**
 * The highlander controller handles the admin highlander mode, if enabled.
 * It is first created when "there can only be one" triggers it, and it can be referenced from GLOB.highlander_controller
 */
/datum/highlander_controller

/datum/highlander_controller/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, PROC_REF(new_highlander))
	sound_to_playing_players('sound/misc/highlander.ogg')
	send_to_playing_players(span_boldannounce("<font size=6>THERE CAN BE ONLY ONE</font>"))
	for(var/obj/item/disk/nuclear/nuke_disk as anything in SSpoints_of_interest.real_nuclear_disks)
		var/datum/component/stationloving/component = nuke_disk.GetComponent(/datum/component/stationloving)
		component?.relocate() //Gets it out of bags and such

	for(var/mob/living/carbon/human/human in GLOB.player_list)
		if(human.stat == DEAD)
			continue
		human.make_scottish()

	for(var/mob/living/silicon/ai/AI in GLOB.player_list)
		if(!istype(AI) || AI.stat == DEAD)
			continue
		if(AI.deployed_shell)
			AI.deployed_shell.undeploy()
		AI.change_mob_type_unchecked(/mob/living/silicon/robot)
		AI.gib()

	for(var/mob/living/silicon/robot/robot in GLOB.player_list)
		if(!istype(robot) || robot.stat == DEAD)
			continue
		if(robot.shell)
			robot.gib()
			continue
		robot.make_scottish()
	addtimer(CALLBACK(SSshuttle.emergency, TYPE_PROC_REF(/obj/docking_port/mobile/emergency, request), null, 1), 5 SECONDS)

/datum/highlander_controller/Destroy(force)
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)

/**
 * Triggers at beginning of the game when there is a confirmed list of valid, ready players.
 * Creates a 100% ready game that has NOT started (no players in bodies)
 * Followed by start game
 *
 * Does the following:
 * * Picks map, and loads it
 * * Grabs landmarks if it is the first time it's loading
 * * Sets up the role list
 * * Puts players in each role randomly
 * Arguments:
 * * setup_list: list of all the datum setups (fancy list of roles) that would work for the game
 * * ready_players: list of filtered, sane players (so not playing or disconnected) for the game to put into roles
 */
/datum/highlander_controller/proc/new_highlander(datum/source, mob/living/new_crewmember, rank)
	SIGNAL_HANDLER

	to_chat(new_crewmember, span_userdanger("<i>THERE CAN BE ONLY ONE!!!</i>"))
	new_crewmember.make_scottish()

/**
 * Gives everyone kilts, berets, claymores, and pinpointers, with the objective to hijack the emergency shuttle.
 * Uses highlander controller to do so!
 *
 * Arguments:
 * * was_delayed: boolean: whether the option to do a "delayed" highlander was pressed before this was called, changes up the logging a bit.

 */
/client/proc/only_one(was_delayed = FALSE)
	if(!SSticker.HasRoundStarted())
		tgui_alert(usr,"The game hasn't started yet!")
		return

	if(was_delayed) //sends more accurate logs
		message_admins(span_adminnotice("[key_name_admin(usr)]'s delayed THERE CAN ONLY BE ONE started!"))
		log_admin("[key_name(usr)] delayed THERE CAN ONLY BE ONE started.")
	else
		message_admins(span_adminnotice("[key_name_admin(usr)] used THERE CAN BE ONLY ONE!"))
		log_admin("[key_name(usr)] used THERE CAN BE ONLY ONE.")

	GLOB.highlander_controller = new /datum/highlander_controller

/client/proc/only_one_delayed()
	send_to_playing_players(span_userdanger("Bagpipes begin to blare. You feel Scottish pride coming over you."))
	message_admins(span_adminnotice("[key_name_admin(usr)] used (delayed) THERE CAN BE ONLY ONE!"))
	log_admin("[key_name(usr)] used delayed THERE CAN BE ONLY ONE.")
	addtimer(CALLBACK(src, PROC_REF(only_one), TRUE), 42 SECONDS)

/mob/living/proc/make_scottish()
	return

/mob/living/carbon/human/make_scottish()
	mind.add_antag_datum(/datum/antagonist/highlander)

/mob/living/silicon/robot/make_scottish()
	mind.add_antag_datum(/datum/antagonist/highlander/robot)
