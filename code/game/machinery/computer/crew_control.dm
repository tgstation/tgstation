/obj/machinery/computer/crewcontrol
	name = "crew control console"
	desc = "Used to remotely lockdown or detonate crew members."
	icon_screen = "robot"
	icon_keyboard = "rd_key"
	req_access = list(ACCESS_CMO)
	circuit = /obj/item/circuitboard/computer/crewcontrol
	light_color = LIGHT_COLOR_BLUE
	ui_x = 500
	ui_y = 460

/obj/machinery/computer/crewcontrol/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "crew_control_console", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/computer/crewcontrol/ui_data(mob/user)
	var/list/data = list()

	data["can_hack"] = FALSE

	data["crew"] = list()
	for(var/mob/living/carbon/human/H in GLOB.crew_mobs)
		if(z != (get_turf(H)).z)
			continue
		if(QDELETED(H)) //If we somehow missed removing a human that got deleted
			GLOB.crew_mobs -= H
			continue

		var/list/crew_data = list(
			name = H.name,
			locked_down = H.lockdown,
			status = H.stat,
			ref = REF(H)
		)
		data["crew"] += list(crew_data)
	return data

/obj/machinery/computer/crewcontrol/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("killcrew")
			if(allowed(usr))
				var/mob/living/carbon/human/H = locate(params["ref"]) in GLOB.crew_mobs
				var/turf/T = get_turf(H)
				message_admins("<span class='notice'>[ADMIN_LOOKUPFLW(usr)] detonated [key_name_admin(H, H.client)] at [ADMIN_VERBOSEJMP(T)]!</span>")
				log_game("\<span class='notice'>[key_name(usr)] detonated [key_name(H)]!</span>")
				H.gib(FALSE,TRUE,TRUE)
			else
				to_chat(usr, "<span class='danger'>Access Denied.</span>")
		if("stopcrew")
			if(allowed(usr))
				var/mob/living/carbon/human/H = locate(params["ref"]) in GLOB.crew_mobs
				H.SetLockdown(!H.lockdown)
				message_admins("<span class='notice'>[ADMIN_LOOKUPFLW(usr)] [H.lockdown ? "locked down" : "released"] [ADMIN_LOOKUPFLW(H)]!</span>")
				log_game("[key_name(usr)] [H.lockdown ? "locked down" : "released"] [key_name(H)]!")
				to_chat(H, "[!H.lockdown ? "<span class='notice'>You feel your muscles relax!" : "<span class='alert'>Your muscles tighten up!"]</span>")
			else
				to_chat(usr, "<span class='danger'>Access Denied.</span>")