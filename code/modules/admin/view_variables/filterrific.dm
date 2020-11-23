/datum/filter_editor
	var/atom/target

/datum/filter_editor/New(atom/target)
	src.target = target

/datum/filter_editor/ui_state(mob/user)
	return GLOB.admin_state

/datum/filter_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Filteriffic", "Filteriffic")
		ui.open()

/datum/filter_editor/ui_data()
	var/list/data = list()
	data["target_filter_data"] = target.filter_data

/datum/filter_editor/ui_act(action, list/params)
	. = ..()
	if(.)
		return

