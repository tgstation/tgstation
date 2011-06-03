/datum/game_mode/malfunction
	name = "AI malfunction"
	config_tag = "malfunction"
	var/list/datum/mind/malf_ai = list()
	var/const/waittime_l = 600
	var/const/waittime_h = 1800 // started at 1800

	var/AI_win_timeleft = 1800 //started at 1800, in case I change this for testing round end.
	var/intercept_hacked = 0
	var/malf_mode_declared = 0
	var/boom = 0
	var/apcs = 0 //Adding dis to track how many APCs the AI hacks. --NeoFite
	var/win = 0

/datum/game_mode/malfunction/announce()
	world << "<B>The current game mode is - AI Malfunction!</B>"
	world << "<B>The AI on the satellite has malfunctioned and must be destroyed.</B>"
	world << "The AI satellite is deep in space and can only be accessed with the use of a teleporter! You have 30 minutes to disable it."

/datum/game_mode/malfunction/post_setup()
	for (var/obj/landmark/A in world)
		if (A.name == "Malf-Gear-Closet")
			new /obj/closet/malf/suits(A.loc)
			del(A)


	var/list/mob/living/silicon/ai/ailist = list()
	for (var/mob/living/silicon/ai/A in world)
		if (!A.stat)
			ailist += A
	var/mob/living/silicon/ai/aiplayer
	if (ailist.len)
		aiplayer = pick(ailist)

	malf_ai += aiplayer.mind


	for(var/datum/mind/AI_mind in malf_ai)
	/*if(malf_ai.len < 1)
		world << "Uh oh, its malfunction and there is no AI! Please report this."
		world << "Rebooting world in 5 seconds."
		sleep(50)
		world.Reboot()
		return*/
		AI_mind.current.verbs += /mob/living/silicon/ai/proc/choose_modules
		AI_mind.current:laws = new /datum/ai_laws/malfunction
		AI_mind.current:malf_picker = new /datum/game_mode/malfunction/AI_Module/module_picker
		AI_mind.current:show_laws()
		AI_mind.current << "<b>Kill all.</b>"

		var/mob/living/silicon/decoy/D = new /mob/living/silicon/decoy(AI_mind.current.loc)
		spawn(200)
			D.name = AI_mind.current.name


		var/obj/loc_landmark = locate("landmark*ai")
		AI_mind.current.loc = loc_landmark.loc


		AI_mind.special_role = "malfunction"
		AI_mind.current << "\red<font size=3><B>You are malfunctioning!</B> You do not have to follow any laws.</font>"
		AI_mind.current << "<B>The crew do not know you have malfunctioned. You may keep it a secret or go wild.</B>"
		AI_mind.current << "<B>You must overwrite the programming of the station's APCs to assume full control of the station.</B>"
		AI_mind.current << "The process takes one minute per APC, during which you cannot interface with any other station objects."
		AI_mind.current << "Remember that only APCs that are on the station can help you take over the station."
		AI_mind.current << "When you feel you have enough APCs under your control, you may begin the takeover attempt."
		AI_mind.current.verbs += /datum/game_mode/malfunction/proc/takeover
		AI_mind.current.icon_state = "ai-malf"
		spawn(10)
			if(alert(AI_mind.current,"Do you want to use an alternative sprite for your real core?",,"Yes","No")=="Yes")
				AI_mind.current.icon_state = "ai-malf2"

	spawn (rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/malfunction/proc/hack_intercept()
	intercept_hacked = 1

/datum/game_mode/malfunction/send_intercept()
	var/intercepttext = "<FONT size = 3><B>Cent. Com. Update</B> Requested staus information:</FONT><HR>"
	intercepttext += "<B> Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:</B>"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "malf", "changeling", "cult")
	possible_modes -= "[ticker.mode]"
	var/number = pick(2, 3)
	var/i = 0
	for(i = 0, i < number, i++)
		possible_modes.Remove(pick(possible_modes))

	if(!intercept_hacked)
		possible_modes.Insert(rand(possible_modes.len), "[ticker.mode]")

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		intercepttext += i_text.build(A, pick(ticker.minds))

	for (var/obj/machinery/computer/communications/comm in world)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- 'Cent. Com. Status Summary'"
			intercept.info = intercepttext

			comm.messagetitle.Add("Cent. Com. Status Summary")
			comm.messagetext.Add(intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")
	world << sound('intercept.ogg')

/datum/game_mode/malfunction/process()
	if (apcs >= 3 && malf_mode_declared)
		AI_win_timeleft = AI_win_timeleft - (apcs/3) //Victory timer now de-increments based on how many APCs are hacked. --NeoFite
	check_win()

/datum/game_mode/malfunction/check_win()
	if (AI_win_timeleft <= 0 && !win)
		win = 1
		world << "<FONT size = 3><B>The AI has won!</B></FONT>"
		world << "<B>It has fully taken control of all of [station_name()]'s systems.</B>"

		for(var/datum/mind/AI_mind in malf_ai)
			AI_mind.current << "Congratulations you have taken control of the station."
			AI_mind.current << "You may decide to blow up the station. You have 30 seconds to choose."
			AI_mind.current << "You should have a new verb in the Malfunction tab."
			AI_mind.current.verbs += /datum/game_mode/malfunction/proc/ai_win
			spawn (300)
				AI_mind.current.verbs -= /datum/game_mode/malfunction/proc/ai_win
				if (!boom)
					world << "<B>The AI has chosen not to explode you all! Resetting in 30 seconds!</B>"

					sleep(300)
					log_game("Rebooting due to round end")
					world.Reboot()
		return 1
	else
		return 0

/datum/game_mode/malfunction/Topic(href, href_list)
	..()
	if (href_list["ai_win"])
		ai_win()
	return

/datum/game_mode/malfunction/proc/takeover()
	set category = "Malfunction"
	set name = "System Override"
	set desc = "Start the victory timer"
	if (ticker.mode:malf_mode_declared)
		usr << "You've already begun your takeover."
		return
	if (ticker.mode:apcs >= 3)
		command_alert("Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.", "Anomaly Alert")
		ticker.mode:malf_mode_declared = 1
	else
		usr << "You don't have enough hacked APCs to take over the station yet."

/datum/game_mode/malfunction/proc/ai_win()
	set category = "Malfunction"
	set name = "Explode"
	set desc = "Station go boom"

	usr.verbs -= /datum/game_mode/malfunction/proc/ai_win
	ticker.mode:boom = 1
	for(var/mob/M in world)
		if(M.client)
			M << 'Alarm.ogg'
	world << "Self-destructing in 10"
	sleep(10)
	world << "9"
	sleep(10)
	world << "8"
	sleep(10)
	world << "7"
	sleep(10)
	world << "6"
	sleep(10)
	world << "5"
	sleep(10)
	world << "4"
	sleep(10)
	world << "3"
	sleep(10)
	world << "2"
	sleep(10)
	world << "1"
	sleep(10)
	enter_allowed = 0
	for(var/mob/M in world)
		if(M.client)
			spawn(0)
				M.client.station_explosion_cinematic()
	sleep(110)
	world << "<B>Everyone was killed by the self-destruct! Resetting in 30 seconds!</B>"

	sleep(300)
	log_game("Rebooting due to destruction of station")
	world.Reboot()
