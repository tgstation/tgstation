/datum/artifactpanel
	var/user

/datum/admins/proc/open_artifactpanel()
	set category = "Admin.Game"
	set name = "Artifact Panel"
	set desc = "Artifact panel"

	if(!check_rights(R_ADMIN))
		return

	var/datum/artifactpanel/artifactpanel = new(usr)

	artifactpanel.ui_interact(usr)

/datum/artifactpanel/New(to_user, mob/living/silicon/robot/to_borg)
	user = CLIENT_FROM_VAR(to_user)

/datum/artifactpanel/ui_state(mob/user)
	return GLOB.admin_state

/datum/artifactpanel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ArtifactPanel")
		ui.open()

/datum/artifactpanel/ui_data(mob/user)
	. = list()
	.["artifacts"] = list()
	for(var/obj/art in GLOB.running_artifact_list)
		var/datum/component/artifact/component = GLOB.running_artifact_list[art]
		.["artifacts"] += list(list(
			"name" = art.name,
			"ref" = REF(art),
			"loc" = "[AREACOORD(art)]",
			"active" = component.active,
			"typename" = component.type_name,
			"lastprint" = "[art.fingerprintslast]",
		))

/datum/artifactpanel/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch (action)
		if ("delete")
			var/atom/movable/to_delete = locate(params["ref"]) in GLOB.running_artifact_list
			if(isnull(to_delete))
				return
			var/ask = tgui_alert(usr, "Are you sure you want to delete that?", "Are you sure about that?", list("YEAH BABY LETS GO", "Naw"))
			if(ask == "YEAH BABY LETS GO")
				message_admins("[key_name_admin(user)] has deleted [to_delete] via Artifact Panel at [ADMIN_VERBOSEJMP(to_delete)].")
				qdel(to_delete)
		if ("toggle")
			var/atom/movable/object = locate(params["ref"]) in GLOB.running_artifact_list
			if(isnull(object))
				return
			var/datum/component/artifact/component = GLOB.running_artifact_list[object]
			var/ask = tgui_alert(usr, "Do you want to do it silently?", "Silently?", list("Visible", "Silent"))
			var/do_silently = FALSE
			if(ask == "Silent")
				do_silently = TRUE

			message_admins("[key_name_admin(user)] has [component.active ? "deactivated" : "activated"] [object][ADMIN_FLW(object)] via Artifact Panel.")
			if(component.active)
				component.artifact_deactivate(do_silently)
			else
				component.artifact_activate(do_silently)
