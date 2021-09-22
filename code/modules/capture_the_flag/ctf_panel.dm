/datum/ctf_panel
	var/mob/dead/observer/owner

/datum/ctf_panel/New(mob/dead/observer/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner

/datum/ctf_panel/Destroy()
	owner = null
	return ..()

/datum/ctf_panel/ui_state(mob/user)
	return GLOB.observer_state

/datum/ctf_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CTFPanel")
		ui.open()
