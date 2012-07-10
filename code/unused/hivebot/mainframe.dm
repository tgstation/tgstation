/mob/living/silicon/hive_mainframe/New()
	Namepick()

/mob/living/silicon/hive_mainframe/Life()
	if (src.stat == 2)
		return
	else
		src.updatehealth()

		if (src.health <= 0)
			death()
			return

	if(src.force_mind)
		if(!src.mind)
			if(src.client)
				src.mind = new
				src.mind.key = src.key
				src.mind.current = src
		src.force_mind = 0

/mob/living/silicon/hive_mainframe/Stat()
	..()
	statpanel("Status")
	if (src.client.statpanel == "Status")
		if(emergency_shuttle.online && emergency_shuttle.location < 2)
			var/timeleft = emergency_shuttle.timeleft()
			if (timeleft)
				stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")
/*
		if(ticker.mode.name == "AI malfunction")
			stat(null, "Points left until the AI takes over: [AI_points]/[AI_points_win]")
*/

/mob/living/silicon/hive_mainframe/updatehealth()
	if (src.nodamage == 0)
		src.health = 100 - src.getFireLoss() - src.getBruteLoss()
	else
		src.health = 100
		src.stat = 0

/mob/living/silicon/hive_mainframe/death(gibbed)
	src.stat = 2
	src.canmove = 0
	if(src.blind)
		src.blind.layer = 0
	src.sight |= SEE_TURFS
	src.sight |= SEE_MOBS
	src.sight |= SEE_OBJS
	src.see_in_dark = 8
	src.see_invisible = 2
	src.lying = 1
	src.icon_state = "hive_main-crash"

	var/tod = time2text(world.realtime,"hh:mm:ss") //weasellos time of death patch
	mind.store_memory("Time of death: [tod]", 0)

	if (src.key)
		spawn(50)
			if(src.key && src.stat == 2)
				src.verbs += /client/proc/ghost
	return ..(gibbed)


/mob/living/silicon/hive_mainframe/say_understands(var/other)
	if (istype(other, /mob/living/carbon/human))
		return 1
	if (istype(other, /mob/living/silicon/robot))
		return 1
	if (istype(other, /mob/living/silicon/hivebot))
		return 1
	if (istype(other, /mob/living/silicon/ai))
		return 1
	return ..()

/mob/living/silicon/hive_mainframe/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "queries, \"[text]\"";
	else if (ending == "!")
		return "declares, \"[copytext(text, 1, length(text))]\"";

	return "states, \"[text]\"";


/mob/living/silicon/hive_mainframe/proc/return_to(var/mob/user)
	if(user.mind)
		user.mind.transfer_to(src)
		spawn(20)
			user:shell = 1
			user:real_name = "Robot [pick(rand(1, 999))]"
			user:name = user:real_name


		return

/mob/living/silicon/hive_mainframe/verb/cmd_deploy_to()
	set category = "Mainframe Commands"
	set name = "Deploy to shell."
	deploy_to()

/mob/living/silicon/hive_mainframe/verb/deploy_to()

	if(usr.stat == 2)
		usr << "You can't deploy because you are dead!"
		return

	var/list/bodies = new/list()

	for(var/mob/living/silicon/hivebot/H in world)
		if(H.z == src.z)
			if(H.shell)
				if(!H.stat)
					bodies += H

	var/target_shell = input(usr, "Which body to control?") as null|anything in bodies

	if (!target_shell)
		return

	else if(src.mind)
		spawn(30)
			target_shell:mainframe = src
			target_shell:dependent = 1
			target_shell:real_name = src.name
			target_shell:name = target_shell:real_name
		src.mind.transfer_to(target_shell)
		return


/client/proc/MainframeMove(n,direct,var/mob/living/silicon/hive_mainframe/user)
	return
/obj/hud/proc/hive_mainframe_hud()
	return





/mob/living/silicon/hive_mainframe/Login()
	..()
	update_clothing()
	for(var/S in src.client.screen)
		del(S)
	src.flash = new /obj/screen( null )
	src.flash.icon_state = "blank"
	src.flash.name = "flash"
	src.flash.screen_loc = "1,1 to 15,15"
	src.flash.layer = 17
	src.blind = new /obj/screen( null )
	src.blind.icon_state = "black"
	src.blind.name = " "
	src.blind.screen_loc = "1,1 to 15,15"
	src.blind.layer = 0
	src.client.screen += list( src.blind, src.flash )
	if(!isturf(src.loc))
		src.client.eye = src.loc
		src.client.perspective = EYE_PERSPECTIVE
	if (src.stat == 2)
		src.verbs += /client/proc/ghost
	return



/mob/living/silicon/hive_mainframe/proc/Namepick()
	var/randomname = pick(ai_names)
	var/newname = input(src,"You are the a Mainframe Unit. Would you like to change your name to something else?", "Name change",randomname)

	if (length(newname) == 0)
		newname = randomname

	if (newname)
		if (length(newname) >= 26)
			newname = copytext(newname, 1, 26)
		newname = dd_replacetext(newname, ">", "'")
		src.real_name = newname
		src.name = newname