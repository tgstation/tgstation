/datum/game_mode/malfunction
	name = "AI malfunction"
	config_tag = "malfunction"
	var/list/datum/mind/malf_ai = list()
	var/const/waittime_l = 600
	var/const/waittime_h = 1800

	var/AI_win_timeleft = 1800
	var/intercept_hacked = 0
	var/malf_mode_declared = 0

/datum/game_mode/malfunction/announce()
	world << "<B>The current game mode is - AI Malfunction!</B>"
	world << "<B>The AI on the satellite has malfunctioned and must be destroyed.</B>"
	world << "The AI satellite is deep in space and can only be accessed with the use of a teleporter! You have 30 minutes to disable it."

/datum/game_mode/malfunction/post_setup()
	for (var/obj/landmark/A in world)
		if (A.name == "Malf-Gear-Closet")
			new /obj/closet/malf/suits(A.loc)
			del(A)
	for (var/mob/living/silicon/ai/aiplayer in world)
		malf_ai += aiplayer.mind



	/*if(malf_ai.len < 1)
		world << "Uh oh, its malfunction and there is no AI! Please report this."
		world << "Rebooting world in 5 seconds."
		sleep(50)
		world.Reboot()
		return*/


	malf_ai.current << "\red<font size=3><B>You are malfunctioning!</B> You do not have to follow any laws.</font>"
	malf_ai.current << "<B>The crew do not know you have malfunctioned. You may keep it a secret or go wild. The timer will appear for humans 10 minutes in.</B>"

	malf_ai.current.icon_state = "ai-malf"

	spawn (rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/malfunction/proc/hack_intercept()
	intercept_hacked = 1

/datum/game_mode/malfunction/send_intercept()
	var/intercepttext = "<FONT size = 3><B>Cent. Com. Update</B> Requested staus information:</FONT><HR>"
	intercepttext += "<B> Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:</B>"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "malf")
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


/datum/game_mode/malfunction/process()
	AI_win_timeleft--
//	if(AI_win_timeleft == 1200) // Was 1790
//		malf_mode_declared = 1
	check_win()

/datum/game_mode/malfunction/check_win()
	if (AI_win_timeleft == 0)
		world << "<FONT size = 3><B>The AI has won!</B></FONT>"
		world << "<B>It has fully taken control of all of [station_name()]'s systems.</B>"
		spawn(400)
			world << "\blue Rebooting due to end of game"
			world.Reboot()
		for(var/datum/mind/AI_mind in malf_ai)
			malf_ai:current << "Congratulations you have taken control of the station."
			malf_ai:current << "You may decide to blow up the station. You have 30 seconds to choose."
			malf_ai:current << text("<A HREF=?src=\ref[src];ai_win=\ref[malf_ai:current]>Self-destruct the station</A>)")
		return 1
	else
		return 0

/datum/game_mode/malfunction/Topic(href, href_list)
	..()
	if (href_list["ai_win"])
		ai_win()
	return

/datum/game_mode/malfunction/proc/ai_win()

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
	var/turf/ground_zero = locate("landmark*blob-directive")

	if (ground_zero)
		ground_zero = get_turf(ground_zero)
	else
		ground_zero = locate(45,45,1)

	explosion(ground_zero, 100, 250, 500, 750)
