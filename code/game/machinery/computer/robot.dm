


/obj/machinery/computer/robotics
	name = "robotics control console"
	desc = "Used to remotely lockdown or detonate linked Cyborgs."
	icon_screen = "robot"
	icon_keyboard = "rd_key"
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/weapon/circuitboard/computer/robotics
	var/temp = null

	light_color = LIGHT_COLOR_PINK

/obj/machinery/computer/robotics/proc/can_control(mob/user, mob/living/silicon/robot/R)
	if(!istype(R))
		return 0
	if(isAI(user))
		if (R.connected_ai != user)
			return 0
	if(iscyborg(user))
		if (R != user)
			return 0
	if(R.scrambledcodes)
		return 0
	return 1

/obj/machinery/computer/robotics/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/robotics/interact(mob/user)
	if (src.z > 6)
		to_chat(user, "<span class='boldannounce'>Unable to establish a connection</span>: \black You're too far away from the station!")
		return
	user.set_machine(src)
	var/dat
	var/robots = 0
	for(var/mob/living/silicon/robot/R in GLOB.mob_list)
		if(!can_control(user, R))
			continue
		robots++
		dat += "[R.name] |"
		if(R.stat)
			dat += " Not Responding |"
		else if (!R.canmove)
			dat += " Locked Down |"
		else
			dat += " Operating Normally |"
		if (!R.canmove)
		else if(R.cell)
			dat += " Battery Installed ([R.cell.charge]/[R.cell.maxcharge]) |"
		else
			dat += " No Cell Installed |"
		if(R.module)
			dat += " Module Installed ([R.module.name]) |"
		else
			dat += " No Module Installed |"
		if(R.connected_ai)
			dat += " Slaved to [R.connected_ai.name] |"
		else
			dat += " Independent from AI |"
		if(issilicon(user) || IsAdminGhost(user))
			if(is_servant_of_ratvar(user) && user != R)
				dat += "<A href='?src=\ref[src];convert=\ref[R]'>(<font color=#BE8700><i>Convert</i></font>)</A> "
			else if(((issilicon(user) && is_special_character(user)) || IsAdminGhost(user)) && !R.emagged && (user != R || R.syndicate))
				dat += "<A href='?src=\ref[src];magbot=\ref[R]'>(<font color=blue><i>Hack</i></font>)</A> "
		dat += "<A href='?src=\ref[src];stopbot=\ref[R]'>(<font color=green><i>[R.canmove ? "Lockdown" : "Release"]</i></font>)</A> "
		dat += "<A href='?src=\ref[src];killbot=\ref[R]'>(<font color=red><i>Destroy</i></font>)</A>"
		dat += "<BR>"

	if(!robots)
		dat += "No Cyborg Units detected within access parameters."
		dat += "<BR>"

	var/drones = 0
	for(var/mob/living/simple_animal/drone/D in GLOB.mob_list)
		if(D.hacked)
			continue
		drones++
		dat += "[D.name] |"
		if(D.stat)
			dat += " Not Responding |"
		dat += "<A href='?src=\ref[src];killdrone=\ref[D]'>(<font color=red><i>Destroy</i></font>)</A>"
		dat += "<BR>"

	if(!drones)
		dat += "No Drone Units detected within access parameters."

	var/datum/browser/popup = new(user, "computer", "Cyborg Control Console", 400, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/computer/robotics/Topic(href, href_list)
	if(..())
		return

	if (href_list["temp"])
		src.temp = null

	else if (href_list["killbot"])
		if(src.allowed(usr))
			var/mob/living/silicon/robot/R = locate(href_list["killbot"]) in GLOB.silicon_mobs
			if(can_control(usr, R))
				var/choice = input("Are you certain you wish to detonate [R.name]?") in list("Confirm", "Abort")
				if(choice == "Confirm" && can_control(usr, R) && !..())
					if(R.syndicate && R.emagged)
						to_chat(R, "Extreme danger.  Termination codes detected.  Scrambling security codes and automatic AI unlink triggered.")
						if(R.connected_ai)
							to_chat(R.connected_ai, "<br><br><span class='alert'>ALERT - Cyborg detonation detected: [R.name]</span><br>")
						R.ResetSecurityCodes()
					else
						var/turf/T = get_turf(R)
						message_admins("<span class='notice'>[ADMIN_LOOKUPFLW(usr)] detonated [key_name(R, R.client)][ADMIN_JMP(T)]!</span>")
						log_game("\<span class='notice'>[key_name(usr)] detonated [key_name(R)]!</span>")
						if(R.connected_ai)
							to_chat(R.connected_ai, "<br><br><span class='alert'>ALERT - Cyborg detonation detected: [R.name]</span><br>")
						R.self_destruct()
		else
			to_chat(usr, "<span class='danger'>Access Denied.</span>")

	else if (href_list["stopbot"])
		if(src.allowed(usr))
			var/mob/living/silicon/robot/R = locate(href_list["stopbot"]) in GLOB.silicon_mobs
			if(can_control(usr, R))
				var/choice = input("Are you certain you wish to [R.canmove ? "lock down" : "release"] [R.name]?") in list("Confirm", "Abort")
				if(choice == "Confirm" && can_control(usr, R) && !..())
					message_admins("<span class='notice'>[ADMIN_LOOKUPFLW(usr)] [R.canmove ? "locked down" : "released"] [key_name(R, R.client)][ADMIN_LOOKUPFLW(R)]!</span>")
					log_game("[key_name(usr)] [R.canmove ? "locked down" : "released"] [key_name(R)]!")
					R.SetLockdown(!R.lockcharge)
					to_chat(R, "[!R.lockcharge ? "<span class='notice'>Your lockdown has been lifted!" : "<span class='alert'>You have been locked down!"]</span>")
					if(R.connected_ai)
						to_chat(R.connected_ai, "[!R.lockcharge ? "<span class='notice'>NOTICE - Cyborg lockdown lifted" : "<span class='alert'>ALERT - Cyborg lockdown detected"]: <a href='?src=\ref[R.connected_ai];track=[html_encode(R.name)]'>[R.name]</a></span><br>")

		else
			to_chat(usr, "<span class='danger'>Access Denied.</span>")

	else if (href_list["magbot"])
		if((issilicon(usr) && is_special_character(usr)) || IsAdminGhost(usr))
			var/mob/living/silicon/robot/R = locate(href_list["magbot"]) in GLOB.silicon_mobs
			if(istype(R) && !R.emagged && ((R.syndicate && R == usr) || R.connected_ai == usr || IsAdminGhost(usr)) && !R.scrambledcodes && can_control(usr, R))
				log_game("[key_name(usr)] emagged [R.name] using robotic console!")
				message_admins("[key_name_admin(usr)] emagged cyborg [key_name_admin(R)] using robotic console!")
				R.SetEmagged(1)
				if(is_special_character(R))
					R.verbs += /mob/living/silicon/robot/proc/ResetSecurityCodes

	else if(href_list["convert"])
		if(issilicon(usr) && is_special_character(usr))
			var/mob/living/silicon/robot/R = locate(href_list["convert"]) in GLOB.silicon_mobs
			if(istype(R) && !is_servant_of_ratvar(R) && is_servant_of_ratvar(usr) && R.connected_ai == usr)
				log_game("[key_name(usr)] converted [R.name] using robotic console!")
				message_admins("[key_name_admin(usr)] converted cyborg [key_name_admin(R)] using robotic console!")
				add_servant_of_ratvar(R)

	else if (href_list["killdrone"])
		if(src.allowed(usr))
			var/mob/living/simple_animal/drone/D = locate(href_list["killdrone"])
			if(D.hacked)
				to_chat(usr, "<span class='danger'>ERROR: [D] is not responding to external commands.</span>")
			else
				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(3, 1, D)
				s.start()
				D.visible_message("<span class='danger'>\the [D] self destructs!</span>")
				D.gib()

	src.updateUsrDialog()
	return
