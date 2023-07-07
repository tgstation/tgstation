/datum/crew_manifest

/datum/crew_manifest/ui_state(mob/user)
	return GLOB.always_state

/datum/crew_manifest/ui_status(mob/user, datum/ui_state/state)
	return (isnewplayer(user) || isobserver(user) || isAI(user) || ispAI(user)) ? UI_INTERACTIVE : UI_CLOSE

/datum/crew_manifest/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "CrewManifest")
		ui.open()

/datum/crew_manifest/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

/datum/crew_manifest/ui_data(mob/user)
	var/list/positions = list()
	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		var/open = 0
		var/list/exceptions = list()
		for(var/datum/job/job as anything in department.department_jobs)
			if(job.total_positions == -1)
				exceptions += job.title
				continue
			var/open_slots = job.total_positions - job.current_positions
			if(open_slots < 1)
				continue
			open += open_slots
		positions[department.department_name] = list("exceptions" = exceptions, "open" = open)

	return list(
		"manifest" = GLOB.manifest.get_manifest(),
		"positions" = positions
	)
