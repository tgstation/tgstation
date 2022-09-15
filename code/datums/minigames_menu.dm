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

/datum/minigames_menu/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("mafia")
			ui.close()
			mafia()
			return TRUE
		if("ctf")
			ui.close()
			ctf()
			return TRUE

/datum/minigames_menu/proc/mafia()
	var/datum/mafia_controller/game = GLOB.mafia_game //this needs to change if you want multiple mafia games up at once.
	if(!game)
		game = create_mafia_game("mafia")
	game.ui_interact(usr)

/datum/minigames_menu/proc/ctf()
	var/datum/ctf_panel/ctf_panel
	if(!ctf_panel)
		ctf_panel = new(src)
	ctf_panel.ui_interact(usr)
