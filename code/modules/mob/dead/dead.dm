//Dead mobs can exist whenever. This is needful

INITIALIZE_IMMEDIATE(/mob/dead)

/mob/dead
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	throwforce = 0

/mob/dead/Initialize()
	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1
	tag = "mob_[next_mob_id++]"
	GLOB.mob_list += src

	prepare_huds()

	if(length(CONFIG_GET(keyed_list/cross_server)))
		verbs += /mob/dead/proc/server_hop
	set_focus(src)
	return INITIALIZE_HINT_NORMAL

/mob/dead/dust(just_ash, drop_items, force)	//ghosts can't be vaporised.
	return

/mob/dead/gib()		//ghosts can't be gibbed.
	return

/mob/dead/ConveyorMove()	//lol
	return

/mob/dead/forceMove(atom/destination)
	loc = destination

/mob/dead/Stat()
	..()

	if(!statpanel("Status"))
		return
	stat(null, "Game Mode: [SSticker.hide_mode ? "Secret" : "[GLOB.master_mode]"]")

	if(SSticker.HasRoundStarted())
		return

	var/time_remaining = SSticker.GetTimeLeft()
	if(time_remaining > 0)
		stat(null, "Time To Start: [round(time_remaining/10)]s")
	else if(time_remaining == -10)
		stat(null, "Time To Start: DELAYED")
	else
		stat(null, "Time To Start: SOON")

	stat(null, "Players: [SSticker.totalPlayers]")
	if(client.holder)
		stat(null, "Players Ready: [SSticker.totalPlayersReady]")

/mob/dead/proc/server_hop()
	set category = "OOC"
	set name = "Server Hop!"
	set desc= "Jump to the other server"
	if(notransform)
		return
	var/list/csa = CONFIG_GET(keyed_list/cross_server)
	var/pick
	switch(csa.len)
		if(0)
			verbs -= /mob/dead/proc/server_hop
			to_chat(src, "<span class='notice'>Server Hop has been disabled.</span>")
		if(1)
			pick = csa[0]
		else
			pick = input(src, "Pick a server to jump to", "Server Hop") as null|anything in csa

	if(!pick)
		return

	var/addr = csa[pick]

	if(alert(src, "Jump to server [pick] ([addr])?", "Server Hop", "Yes", "No") != "Yes")
		return

	var/client/C = client
	to_chat(C, "<span class='notice'>Sending you to [pick].</span>")
	new /obj/screen/splash(C)

	notransform = TRUE
	sleep(29)	//let the animation play
	notransform = FALSE

	if(!C)
		return

	winset(src, null, "command=.options") //other wise the user never knows if byond is downloading resources

	C << link("[addr]?server_hop=[key]")
