/datum/minigames_menu
	var/mob/dead/observer/owner

/datum/minigames_menu/New(mob/dead/observer/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner

/datum/minigames_menu/Destroy()
	owner = null
	return ..()

/datum/minigames_menu/ui_state(mob/user)
	return GLOB.observer_state

/datum/minigames_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MinigamesMenu")
		ui.open()
