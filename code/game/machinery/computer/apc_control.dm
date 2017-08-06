/obj/machinery/computer/apc_control
	name = "power flow control console"
	desc = "Used to remotely control the flow of power to different parts of the station."
	icon_screen = "solar"
	icon_keyboard = "power_key"
	req_access = list(ACCESS_ENGINE)
	circuit = /obj/item/weapon/circuitboard/computer/apc_control
	light_color = LIGHT_COLOR_YELLOW
	var/list/apcs //APCs the computer has access to
	var/mob/living/operator //Who's operating the computer right now
	var/obj/machinery/power/apc/active_apc //The APC we're using right now
	var/list/filters //For sorting the results
	var/checking_logs = 0
	var/list/logs
	var/authenticated = 0
	var/auth_id = "\[NULL\]"

/obj/machinery/computer/apc_control/Initialize()
	apcs = list() //To avoid BYOND making the list run through a ton of procs
	filters = list("Name" = null, "Charge Above" = null, "Charge Below" = null, "Responsive" = null)
	..()

/obj/machinery/computer/apc_control/process()
	apcs = list() //Clear the list every tick
	for(var/V in GLOB.apcs_list)
		var/obj/machinery/power/apc/APC = V
		if(check_apc(APC))
			apcs[APC.name] = APC
	if(operator && (!operator.Adjacent(src) || stat))
		operator = null
		if(active_apc)
			if(!active_apc.locked)
				active_apc.say("Remote access canceled. Interface locked.")
				playsound(active_apc, 'sound/machines/boltsdown.ogg', 25, 0)
				playsound(active_apc, 'sound/machines/terminal_alert.ogg', 50, 0)
			active_apc.locked = TRUE
			active_apc.update_icon()
			active_apc = null

/obj/machinery/computer/apc_control/attack_ai(mob/user)
	if(!IsAdminGhost(user))
		to_chat(user,"<span class='warning'>[src] does not support AI control.</span>") //You already have APC access, cheater!
		return
	..(user)

/obj/machinery/computer/apc_control/proc/check_apc(obj/machinery/power/apc/APC)
	return APC.z == z && !APC.malfhack && !APC.aidisabled && !APC.emagged && !APC.stat && !istype(APC.area, /area/ai_monitored) && !APC.area.outdoors

/obj/machinery/computer/apc_control/interact(mob/living/user)
	var/dat
	if(authenticated)
		if(!checking_logs)
			dat += "Logged in as [auth_id].<br><br>"
			dat += "<i>Filters</i><br>"
			dat += "<b>Name:</b> <a href='?src=\ref[src];name_filter=1'>[filters["Name"] ? filters["Name"] : "None set"]</a><br>"
			dat += "<b>Charge:</b> <a href='?src=\ref[src];above_filter=1'>\>[filters["Charge Above"] ? filters["Charge Above"] : "NaN"]%</a> and <a href='?src=\ref[src];below_filter=1'>\<[filters["Charge Below"] ? filters["Charge Below"] : "NaN"]%</a><br>"
			dat += "<b>Accessible:</b> <a href='?src=\ref[src];access_filter=1'>[filters["Responsive"] ? "Non-Responsive Only" : "All"]</a><br><br>"
			for(var/A in apcs)
				var/obj/machinery/power/apc/APC = apcs[A]
				if(filters["Name"] && !findtext(APC.name, filters["Name"]) && !findtext(APC.area.name, filters["Name"]))
					continue
				if(filters["Charge Above"] && (APC.cell.charge / APC.cell.maxcharge) < filters["Charge Above"] / 100)
					continue
				if(filters["Charge Below"] && (APC.cell.charge / APC.cell.maxcharge) > filters["Charge Below"] / 100)
					continue
				if(filters["Responsive"] && !APC.aidisabled)
					continue
				dat += "<a href='?src=\ref[src];access_apc=\ref[APC]'>[A]</a><br>\
				<b>Charge:</b> [APC.cell.charge] / [APC.cell.maxcharge] W ([round((APC.cell.charge / APC.cell.maxcharge) * 100)]%)<br>\
				<b>Area:</b> [APC.area]<br>\
				[APC.aidisabled || APC.panel_open ? "<font color='#FF0000'>APC does not respond to interface query.</font>" : "<font color='#00FF00'>APC responds to interface query.</font>"]<br><br>"
			dat += "<a href='?src=\ref[src];check_logs=1'>Check Logs</a><br>"
			dat += "<a href='?src=\ref[src];log_out=1'>Log Out</a><br>"
			if(emagged)
				dat += "<font color='#FF0000'>WARNING: Logging functionality partially disabled from outside source.</font><br>"
				dat += "<a href='?src=\ref[src];restore_logging=1'>Restore logging functionality?</a><br>"
		else
			if(logs.len)
				for(var/entry in logs)
					dat += "[entry]<br>"
			else
				dat += "<i>No activity has been recorded at this time.</i><br>"
			if(emagged)
				dat += "<a href='?src=\ref[src];clear_logs=1'><font color='#FF0000'>@#%! CLEAR LOGS</a>"
			dat += "<a href='?src=\ref[src];check_apcs=1'>Return</a>"
		operator = user
	else
		dat = "<a href='?src=\ref[src];authenticate=1'>Please swipe a valid ID to log in...</a>"
	var/datum/browser/popup = new(user, "apc_control", name, 600, 400)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()

/obj/machinery/computer/apc_control/Topic(href, href_list)
	if(..())
		return
	if(!usr || !usr.canUseTopic(src) || usr.incapacitated() || stat || QDELETED(src))
		return
	if(href_list["authenticate"])
		var/obj/item/weapon/card/id/ID = usr.get_active_held_item()
		if(!istype(ID))
			ID = usr.get_idcard()
		if(ID && istype(ID))
			if(check_access(ID))
				authenticated = TRUE
				auth_id = "[ID.registered_name] ([ID.assignment])"
				log_activity("logged in")
		if(!authenticated) //Check for emags
			var/obj/item/weapon/card/emag/E = usr.get_active_held_item()
			if(E && istype(E) && usr.Adjacent(src))
				to_chat(usr, "<span class='warning'>You bypass [src]'s access requirements using your emag.</span>")
				authenticated = TRUE
				log_activity("logged in") //Auth ID doesn't change, hinting that it was illicit
	if(href_list["log_out"])
		log_activity("logged out")
		authenticated = FALSE
		auth_id = "\[NULL\]"
	if(href_list["restore_logging"])
		to_chat(usr, "<span class='robot notice'>[bicon(src)] Logging functionality restored from backup data.</span>")
		emagged = FALSE
		LAZYADD(logs, "<b>-=- Logging restored to full functionality at this point -=-</b>")
	if(href_list["access_apc"])
		playsound(src, "terminal_type", 50, 0)
		var/obj/machinery/power/apc/APC = locate(href_list["access_apc"]) in GLOB.apcs_list
		if(!APC || APC.aidisabled || APC.panel_open || QDELETED(APC))
			to_chat(usr, "<span class='robot danger'>[bicon(src)] APC does not return interface request. Remote access may be disabled.</span>")
			return
		if(active_apc)
			to_chat(usr, "<span class='robot danger'>[bicon(src)] Disconnected from [active_apc].</span>")
			active_apc.say("Remote access canceled. Interface locked.")
			playsound(active_apc, 'sound/machines/boltsdown.ogg', 25, 0)
			playsound(active_apc, 'sound/machines/terminal_alert.ogg', 50, 0)
			active_apc.locked = TRUE
			active_apc.update_icon()
			active_apc = null
		to_chat(usr, "<span class='robot notice'>[bicon(src)] Connected to APC in [APC.area]. Interface request sent.</span>")
		log_activity("remotely accessed APC in [APC.area]")
		APC.interact(usr, GLOB.not_incapacitated_state)
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
		message_admins("[key_name_admin(usr)] remotely accessed [APC] from [src] at [get_area(src)].")
		log_game("[key_name_admin(usr)] remotely accessed [APC] from [src] at [get_area(src)].")
		if(APC.locked)
			APC.say("Remote access detected. Interface unlocked.")
			playsound(APC, 'sound/machines/boltsup.ogg', 25, 0)
			playsound(APC, 'sound/machines/terminal_alert.ogg', 50, 0)
		APC.locked = FALSE
		APC.update_icon()
		active_apc = APC
	if(href_list["name_filter"])
		playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
		var/new_filter = stripped_input(usr, "What name are you looking for?", name) as null|text
		if(!src || !usr || !usr.canUseTopic(src) || stat || QDELETED(src))
			return
		log_activity("changed name filter to \"[new_filter]\"")
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
		filters["Name"] = new_filter
	if(href_list["above_filter"])
		playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
		var/new_filter = input(usr, "Enter a percentage from 1-100 to sort by (greater than).", name) as null|num
		if(!src || !usr || !usr.canUseTopic(src) || stat || QDELETED(src))
			return
		log_activity("changed greater than charge filter to \"[new_filter]\"")
		if(new_filter)
			new_filter = Clamp(new_filter, 0, 100)
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
		filters["Charge Above"] = new_filter
	if(href_list["below_filter"])
		playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
		var/new_filter = input(usr, "Enter a percentage from 1-100 to sort by (lesser than).", name) as null|num
		if(!src || !usr || !usr.canUseTopic(src) || stat || QDELETED(src))
			return
		log_activity("changed lesser than charge filter to \"[new_filter]\"")
		if(new_filter)
			new_filter = Clamp(new_filter, 0, 100)
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
		filters["Charge Below"] = new_filter
	if(href_list["access_filter"])
		if(isnull(filters["Responsive"]))
			filters["Responsive"] = 1
			log_activity("sorted by non-responsive APCs only")
		else
			filters["Responsive"] = !filters["Responsive"]
			log_activity("sorted by all APCs")
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	if(href_list["check_logs"])
		checking_logs = TRUE
		log_activity("checked logs")
	if(href_list["check_apcs"])
		checking_logs = FALSE
		log_activity("checked APCs")
	if(href_list["clear_logs"])
		logs = list()
	interact(usr) //Refresh the UI after a filter changes

/obj/machinery/computer/apc_control/emag_act(mob/user)
	if(emagged)
		return
	user.visible_message("<span class='warning'>You emag [src], disabling precise logging and allowing you to clear logs.</span>")
	log_game("[key_name_admin(user)] emagged [src] at [get_area(src)], disabling operator tracking.")
	playsound(src, "sparks", 50, 1)
	emagged = TRUE

/obj/machinery/computer/apc_control/proc/log_activity(log_text)
	var/op_string = operator && !emagged ? operator : "\[NULL OPERATOR\]"
	LAZYADD(logs, "<b>([worldtime2text()])</b> [op_string] [log_text]")

/mob/proc/using_power_flow_console()
	for(var/obj/machinery/computer/apc_control/A in range(1, src))
		if(A.operator && A.operator == src && !A.stat)
			return TRUE
	return
