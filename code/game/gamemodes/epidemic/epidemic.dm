/datum/game_mode/epidemic
	name = "epidemic"
	config_tag = "epidemic"
	required_players = 6

	var/const/waittime_l = 300 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 600 //upper bound on time before intercept arrives (in tenths of seconds)
	var/checkwin_counter =0
	var/finished = 0

	var/cruiser_arrival

	var/virus_name = ""

	var/stage = 0
	var/doctors = 0

///////////////////////////
//Announces the game type//
///////////////////////////
/datum/game_mode/epidemic/announce()
	world << "<B>The current game mode is - Epidemic!</B>"
	world << "<B>A deadly epidemic is spreading on the station. Find a cure as fast as possible, and keep your distance to anyone who speaks in a hoarse voice!</B>"


///////////////////////////////////////////////////////////////////////////////
//Gets the round setup, cancelling if there's not enough players at the start//
///////////////////////////////////////////////////////////////////////////////
/datum/game_mode/epidemic/pre_setup()
	doctors = 0
	for(var/mob/new_player/player in world)
		if(player.mind.assigned_role in list("Chief Medical Officer","Medical Doctor"))
			doctors++
			break

	if(doctors < 1)
		return 0

	return 1

/datum/game_mode/epidemic/proc/cruiser_seconds()
	return (cruiser_arrival - world.time) / 10

////////////////////// INTERCEPT ////////////////////////
/// OVERWRITE THE INTERCEPT WITH A QUARANTINE WARNING ///
/////////////////////////////////////////////////////////

/datum/game_mode/epidemic/send_intercept()
	var/intercepttext = "<FONT size = 3 color='red'><B>CONFIDENTIAL REPORT</FONT><HR>"
	virus_name = "X-[rand(1,99)]&trade;"
	intercepttext += "<B>Warning: Pathogen [virus_name] has been detected on [station_name()].</B><BR><BR>"
	intercepttext += "<B>Code violet quarantine of [station_name()] put under immediate effect.</B><BR>"
	intercepttext += "<B>Class [rand(2,5)] cruiser has been dispatched. ETA: [round(cruiser_seconds() / 60)] minutes.</B><BR>"
	intercepttext += "<BR><B><FONT size = 2 color='blue'>Instructions</FONT></B><BR>"
	intercepttext += "<B>* ELIMINATE THREAT WITH EXTREME PREJUDICE. [virus_name] IS HIGHLY CONTAGIOUS. INFECTED CREW MEMBERS MUST BE QUARANTINED IMMEDIATELY.</B><BR>"
	intercepttext += "<B>* [station_name()] is under QUARANTINE. Any vessels outbound from [station_name()] will be tracked down and destroyed.</B><BR>"
	intercepttext += "<B>* The existence of [virus_name] is highly confidential. To prevent a panic, only high-ranking staff members are authorized to know of its existence. Crew members that illegally obtained knowledge of [virus_name] are to be neutralized.</B><BR>"
	intercepttext += "<B>* A cure is to be researched immediately, but NanoTrasen intellectual property must be respected. To prevent knowledge of [virus_name] from falling into unauthorized hands, all medical staff that work with the pathogen must be enhanced with a NanoTrasen loyality implant.</B><BR>"


	for (var/obj/machinery/computer/communications/comm in world)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper"
			intercept.info = intercepttext

			comm.messagetitle.Add("Cent. Com. CONFIDENTIAL REPORT")
			comm.messagetext.Add(intercepttext)

	world << sound('commandreport.ogg')

	// add an extra law to the AI to make sure it cooperates with the heads
	var/extra_law = "Crew authorized to know of pathogen [virus_name]'s existence are: Heads of command, any crew member with loyalty implant. Do not allow unauthorized personnel to gain knowledge of [virus_name]. Aid authorized personnel in quarantining and neutrlizing the outbreak. This law overrides all other laws."
	for(var/mob/living/silicon/ai/M in world)
		M.add_ion_law(extra_law)
		M << "\red " + extra_law

/datum/game_mode/epidemic/proc/announce_to_kill_crew()
	var/intercepttext = "<FONT size = 3 color='red'><B>CONFIDENTIAL REPORT</FONT><HR>"
	intercepttext += "<FONT size = 2;color='red'><B>PATHOGEN [virus_name] IS STILL PRESENT ON [station_name()]. IN COMPLIANCE WITH NANOTRASEN LAWS FOR INTERSTELLAR SAFETY, EMERGENCY SAFETY MEASURES HAVE BEEN AUTHORIZED. ALL INFECTED CREW MEMBERS ON [station_name()] ARE TO BE NEUTRALIZED AND DISPOSED OF IN A MANNER THAT WILL DESTROY ALL TRACES OF THE PATHOGEN. FAILURE TO COMPLY WILL RESULT IN IMMEDIATE DESTRUCTION OF [station_name].</B></FONT><BR>"
	intercepttext += "<B>CRUISER WILL ARRIVE IN [round(cruiser_seconds()/60)] MINUTES</B><BR>"

	for (var/obj/machinery/computer/communications/comm in world)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper"
			intercept.info = intercepttext

			comm.messagetitle.Add("Cent. Com. CONFIDENTIAL REPORT")
			comm.messagetext.Add(intercepttext)
	world << sound('commandreport.ogg')


/datum/game_mode/epidemic/post_setup()
	// make sure viral outbreak events don't happen on this mode
	EventTypes.Remove(/datum/event/viralinfection)

	// scan the crew for possible infectees
	var/list/crew = list()
	for(var/mob/living/carbon/human/H in world) if(H.client)
		// heads should not be infected
		if(H.mind.assigned_role in command_positions) continue
		crew += H

	if(crew.len < 2)
		world << "\red There aren't enough players for this mode!"
		world << "\red Rebooting world in 5 seconds."

		if(blackbox)
			blackbox.save_all_data_to_sql()
		sleep(50)
		world.Reboot()

	var/datum/disease2/disease/lethal = new
	lethal.makerandom(1)
	lethal.infectionchance = 5

	// the more doctors, the more will be infected
	var/lethal_amount = doctors * 2

	// keep track of initial infectees
	var/list/infectees = list()

	for(var/i = 0, i < lethal_amount, i++)
		var/mob/living/carbon/human/H = pick(crew)
		if(H.virus2)
			i--
			continue
		H.virus2 = lethal.getcopy()
		infectees += H

	var/mob/living/carbon/human/patient_zero = pick(infectees)
	patient_zero.virus2.stage = 3

	cruiser_arrival = world.time + (10 * 90 * 60)
	stage = 1

	spawn (rand(waittime_l, waittime_h))
		send_intercept()


	..()


/datum/game_mode/epidemic/process()
	if(stage == 1 && cruiser_seconds() < 60 * 30)
		announce_to_kill_crew()
		stage = 2
	else if(stage == 2 && cruiser_seconds() <= 60 * 5)
		command_alert("Inbound cruiser detected on collision course. Scans indicate the ship to be armed and ready to fire. Estimated time of arrival: 5 minutes.", "[station_name()] Early Warning System")
		stage = 3
	else if(stage == 3 && cruiser_seconds() <= 0)
		crew_lose()
		stage = 4

	checkwin_counter++
	if(checkwin_counter >= 20)
		if(!finished)
			ticker.mode.check_win()
		checkwin_counter = 0
	return 0

//////////////////////////////////////
//Checks if the revs have won or not//
//////////////////////////////////////
/datum/game_mode/epidemic/check_win()
	var/alive = 0
	var/sick = 0
	for(var/mob/living/carbon/human/H in world)
		if(H.key && H.stat != 2) alive++
		if(H.virus2 && H.stat != 2) sick++

	if(alive == 0)
		finished = 2
	if(sick == 0)
		finished = 1
	return

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/epidemic/check_finished()
	if(finished != 0)
		return 1
	else
		return 0

///////////////////////////////////////////
///Handle crew failure(station explodes)///
///////////////////////////////////////////
/datum/game_mode/epidemic/proc/crew_lose()
	ticker.mode:explosion_in_progress = 1
	for(var/mob/M in world)
		if(M.client)
			M << 'Alarm.ogg'
	world << "\blue<b>Incoming missile detected.. Impact in 10..</b>"
	for (var/i=9 to 1 step -1)
		sleep(10)
		world << "\blue<b>[i]..</b>"
	sleep(10)
	enter_allowed = 0
	if(ticker)
		ticker.station_explosion_cinematic(0,null)
		if(ticker.mode)
			ticker.mode:station_was_nuked = 1
			ticker.mode:explosion_in_progress = 0
	return


//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relavent information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/epidemic/declare_completion()
	if(finished == 1)
		feedback_set_details("round_end_result","win - epidemic cured")
		world << "\red <FONT size = 3><B> The virus outbreak was contained! The crew wins!</B></FONT>"
	else if(finished == 2)
		feedback_set_details("round_end_result","loss - rev heads killed")
		world << "\red <FONT size = 3><B> The crew succumbed to the epidemic!</B></FONT>"
	..()
	return 1