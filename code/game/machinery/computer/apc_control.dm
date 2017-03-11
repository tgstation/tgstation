/obj/machinery/computer/apc_control
	name = "power flow control console"
	desc = "Used to remotely control the flow of power to different parts of the station."
	icon_screen = "solar"
	icon_keyboard = "power_key"
	circuit = /obj/item/weapon/circuitboard/computer/apc_control
	light_color = LIGHT_COLOR_YELLOW
	var/list/apcs //APCs the computer has access to
	var/mob/living/operator //Who's operating the computer right now
	var/obj/machinery/power/apc/active_apc //The APC we're using right now
	var/list/filters //For sorting the results

/obj/machinery/computer/apc_control/Initialize()
	apcs = list() //To avoid BYOND making the list run through a ton of procs
	filters = list("Name" = null, "Charge Above" = null, "Charge Below" = null, "Responsive" = null)
	..()

/obj/machinery/computer/apc_control/process()
	apcs = list() //Clear the list every tick
	for(var/V in apcs_list)
		var/obj/machinery/power/apc/APC = V
		if(check_apc(APC))
			apcs[APC.name] = APC
	if(operator)
		if(!operator.Adjacent(src))
			operator = null
			if(active_apc)
				if(!active_apc.locked)
					active_apc.say("Remote access canceled. Interface locked.")
				active_apc.locked = TRUE
				active_apc.update_icon()
				active_apc = null
		else
			interact(operator) //keep the interface updated!

/obj/machinery/computer/apc_control/proc/check_apc(obj/machinery/power/apc/APC)
	return APC.z == z && !APC.malfhack && !APC.stat && !istype(APC.area, /area/ai_monitored) && !APC.area.outdoors

/obj/machinery/computer/apc_control/interact(mob/living/user)
	var/dat
	dat += "<i>Filters</i><br>"
	dat += "<b> Name:</b> <a href='?src=\ref[src];name_filter=1'>[filters["Name"] ? filters["Name"] : "None set"]</a><br>"
	dat += "<b>Charge:</b> <a href='?src=\ref[src];above_filter=1'>>[filters["Charge Above"] ? filters["Charge Above"] : "NaN"]%</a> and <a href='?src=\ref[src];below_filter=1'><[filters["Charge Below"] ? filters["Charge Below"] : "NaN"]%</a><br>"
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
		[APC.aidisabled ? "<font color='#FF0000'>APC does not respond to interface query.</font>" : "<font color='#00FF00'>APC responds to interface query.</font>"]<br><br>"
	var/datum/browser/popup = new(user, "apc_control", name, 600, 400)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()
	return TRUE

/obj/machinery/computer/apc_control/Topic(href, href_list)
	if(..())
		return
	var/image/I = image(src) //For feedback message flavor
	if(href_list["access_apc"])
		var/obj/machinery/power/apc/APC = locate(href_list["access_apc"]) in apcs_list
		if(!APC || APC.aidisabled)
			to_chat(usr, "<span class='robot danger'>\icon[I] APC does not return interface request. Remote access may be disabled.</span>")
			return
		if(active_apc)
			to_chat(usr, "<span class='robot danger'>\icon[I] Disconnected from [active_apc].</span>")
			active_apc.locked = TRUE
			active_apc = null
		to_chat(usr, "<span class='robot notice'>\icon[I] Connected to APC in [get_area(APC)]. Interface request sent.</span>")
		APC.interact(usr, not_incapacitated_state)
		if(APC.locked)
			APC.say("Remote access detected. Interface unlocked.")
		APC.locked = FALSE
		APC.update_icon()
		operator = usr
		active_apc = APC
	if(href_list["name_filter"])
		var/new_filter = stripped_input(usr, "What name are you looking for?", name) as null|text
		if(!src || !usr.Adjacent(src))
			return
		filters["Name"] = new_filter
	if(href_list["above_filter"])
		var/new_filter = input(usr, "Enter a percentage from 1-100 to sort by (greater than).", name) as null|num
		if(!src || !usr.Adjacent(src))
			return
		if(new_filter)
			new_filter = Clamp(new_filter, 0, 100)
		filters["Charge Above"] = new_filter
	if(href_list["below_filter"])
		var/new_filter = input(usr, "Enter a percentage from 1-100 to sort by (lesser than).", name) as null|num
		if(!src || !usr.Adjacent(src))
			return
		if(new_filter)
			new_filter = Clamp(new_filter, 0, 100)
		filters["Charge Below"] = new_filter
	if(href_list["access_filter"])
		if(isnull(filters["Responsive"]))
			filters["Responsive"] = 1
		else
			filters["Responsive"] = !filters["Responsive"]
	interact(usr) //Refresh the UI after a filter changes
