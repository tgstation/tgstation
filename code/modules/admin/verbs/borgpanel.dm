/datum/admins/proc/open_borgopanel(mob/living/silicon/robot/borgo in GLOB.silicon_mobs)
	set category = "Admin"
	set name = "Show Borg Panel"
	set desc = "Show borg panel"

	if(!check_rights(R_ADMIN))
		return

	if (!borgo)
		borgo = input("Select a borg", "Select a borg", null, null) as null|anything in GLOB.silicon_mobs
	if (!borgo)
		to_chat(usr, "<span class='warning'>Borg is required for borgpanel</span>")

	var/datum/borgpanel/borgpanel = new(usr, borgo)

	borgpanel.ui_interact(usr)



/datum/borgpanel
	var/mob/living/silicon/robot/borg
	var/user
	var/datum/tgui/ui

/datum/borgpanel/New(user, mob/living/silicon/robot/borg)
	if(!istype(borg))
		to_chat(usr, "<span class='warning'>Borg panel is only available for borgs</span>")
		qdel(src)
	src.user = user
	src.borg = borg

/datum/borgpanel/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.admin_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "borgopanel", "Borg Panel", 700, 600, master_ui, state)
		src.ui = ui
		ui.open()

/datum/borgpanel/ui_data(mob/user)
	. = list()
	.["borg"] = list(
		"ref" = REF(borg),
		"name" = "[borg]",
		"emagged" = borg.emagged,
		"active_module" = "[borg.module.type]",
		"lawupdate" = borg.lawupdate,
		"lockdown" = borg.lockcharge
	)
	.["upgrades"] = getBorgUpgradesForType(borg)
	.["laws"] = borg.laws ? borg.laws.get_law_list(include_zeroth = TRUE) : list()
	.["cell"] = borg.cell ? list("missing" = FALSE, "maxcharge" = borg.cell.maxcharge, "charge" = borg.cell.charge) : list("missing" = TRUE, "maxcharge" = 1, "charge" = 0)
	.["modules"] = list()
	for(var/moduletype in typesof(/obj/item/robot_module))
		var/obj/item/robot_module/module = moduletype
		.["modules"] += list(list(
			"name" = initial(module.name),
			"type" = "[module]"
		))
	.["ais"] = list(list("name" = "None", "ref" = "null", "connected" = isnull(borg.connected_ai)))
	for(var/mob/living/silicon/ai/ai in GLOB.ai_list)
		.["ais"] += list(list("name" = ai.name, "ref" = REF(ai), "connected" = (borg.connected_ai == ai)))


/datum/borgpanel/ui_act(action, params)
	if(..())
		return
	switch (action)
		if ("set_charge")
			var/newcharge = input("New charge (0-[borg.cell.maxcharge]):", borg.name, borg.cell.charge) as num|null
			if (newcharge)
				borg.cell.charge = CLAMP(newcharge, 0, borg.cell.maxcharge)
		if ("toggle_emagged")
			borg.SetEmagged(!borg.emagged)
		if ("toggle_lawupdate")
			borg.lawupdate = !borg.lawupdate
		if ("toggle_lockdown")
			borg.SetLockdown(!borg.lockcharge)
		if ("setmodule")
			warning("params is [json_encode(params)]")
			var/newmodulepath = text2path(params["module"])
			if (ispath(newmodulepath))
				borg.module.transform_to(newmodulepath)
		if ("slavetoai")
			warning("params is [json_encode(params)]")
			var/mob/living/silicon/ai/newai = locate(params["slavetoai"]) in GLOB.ai_list
			if (newai && newai != borg.connected_ai)
				borg.notify_ai(DISCONNECT)
				if(borg.shell)
					borg.undeploy()
				borg.connected_ai = newai
				borg.notify_ai(TRUE)
			else if (params["slavetoai"] == "null")
				borg.notify_ai(DISCONNECT)
				if(borg.shell)
					borg.undeploy()
				borg.connected_ai = null
			if (borg.lawupdate)
				borg.lawsync()

	. = TRUE

/datum/borgpanel/proc/getBorgUpgradesForType(borg)
	. = list()
	//VTEC
	. += list(list("name" = "VTEC", "installed" = (borg.speed < 0), "type" = /obj/item/borg/upgrade/vtec))
	//Expansion module
	. += list(list("name" = "Borg expander", "installed" = borg.hasExpanded, "type" = /obj/item/borg/upgrade/expand))
	//Ion Thrusters
	. += list(list("name" = "Ion thrusters", "installed" = borg.ionpulse, "type" = /obj/item/borg/upgrade/thrusters))
	//AI shell
	. += list(list("name" = "AI Shell", "installed" = borg.shell, "type" = /obj/item/borg/upgrade/ai))
	//Self-repair module
	. += list(list("name" = "Self-repair", "installed" = (locate(/obj/item/borg/upgrade/selfrepair) in borg ? TRUE : FALSE), "type" = /obj/item/borg/upgrade/selfrepair))
	switch (borg.module.type)
		if (/obj/item/robot_module/miner)
		if (/obj/item/robot_module/medical)
			//Pinpointer
			. += list(list("name" = "Crew pinpointer", "installed" = (locate(/obj/item/pinpointer/crew) in borg ? TRUE : FALSE), "type" = /obj/item/borg/upgrade/pinpointer)
			//Defibrillator
			. += list(list("name" = "Crew pinpointer", "installed" = (locate(/obj/item/twohanded/shockpaddles/cyborg) in borg ? TRUE : FALSE), "type" = /obj/item/borg/upgrade/defib)
		if (/obj/item/robot_module/engineering)
			//RPED
			. += list(list("name" = "RPED", "installed" = (locate(/obj/item/storage/part_replacer/cyborg) in borg ? TRUE : FALSE), "type" = /obj/item/borg/upgrade/rped)
		if (/obj/item/robot_module/security)

