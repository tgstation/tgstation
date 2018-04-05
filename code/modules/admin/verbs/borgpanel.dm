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

/datum/borgpanel/New(user, mob/living/silicon/robot/borg)
	if(!istype(borg))
		to_chat(usr, "<span class='warning'>Borg panel is only available for borgs</span>")
		qdel(src)
	src.user = user
	src.borg = borg

/datum/borgpanel/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.admin_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "borgopanel", "Borg Panel", 700, 700, master_ui, state)
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
	.["upgrades"] = list()
	for (var/upgradetype in subtypesof(/obj/item/borg/upgrade)-/obj/item/borg/upgrade/hypospray) //hypospray is a dummy parent for hypospray upgrades
		var/obj/item/borg/upgrade/upgrade = upgradetype
		if (initial(upgrade.module_type) && !istype(borg.module, initial(upgrade.module_type))) // Upgrade requires a different module
			continue
		var/installed = FALSE
		if (locate(upgradetype) in borg)
			installed = TRUE
		.["upgrades"] += list(list("name" = initial(upgrade.name), "installed" = installed, "type" = upgradetype))
	.["laws"] = borg.laws ? borg.laws.get_law_list(include_zeroth = TRUE) : list()
	.["channels"] = list()
	for (var/k in GLOB.radiochannels)
		if (k == "Common")
			continue
		.["channels"] += list(list("name" = k, "installed" = (k in borg.radio.channels)))
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
		if ("toggle_upgrade")
			var/upgradepath = text2path(params["upgrade"])
			var/obj/item/borg/upgrade/installedupgrade = locate(upgradepath) in borg
			if (installedupgrade)
				installedupgrade.deactivate(borg, user)
				borg.upgrades -= installedupgrade
				qdel(installedupgrade)
			else
				var/obj/item/borg/upgrade/upgrade = new upgradepath(borg)
				upgrade.action(borg, user)
				borg.upgrades += upgrade
		if ("toggle_radio")
			var/channel = params["channel"]
			if (channel in borg.radio.channels) // We're removing a channel
				if (!borg.radio.keyslot) // There's no encryption key. This shouldn't happen but we can cope
					borg.radio.channels -= channel
					if (channel == "Syndicate")
						borg.radio.syndie = FALSE
					else if (channel == "CentCom")
						borg.radio.independent = FALSE
				else
					borg.radio.keyslot.channels -= channel
					if (channel == "Syndicate")
						borg.radio.keyslot.syndie = FALSE
					else if (channel == "CentCom")
						borg.radio.keyslot.independent = FALSE
			else	// We're adding a channel
				if (!borg.radio.keyslot) // Assert that an encryption key exists
					borg.radio.keyslot = new (borg.radio)
				borg.radio.keyslot.channels += channel
				if (channel == "Syndicate")
					borg.radio.keyslot.syndie = TRUE
				else if (channel == "CentCom")
					borg.radio.keyslot.independent = TRUE
			borg.radio.recalculateChannels()
		if ("setmodule")
			var/newmodulepath = text2path(params["module"])
			if (ispath(newmodulepath))
				borg.module.transform_to(newmodulepath)
		if ("slavetoai")
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
