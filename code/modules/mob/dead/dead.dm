//Dead mobs can exist whenever. This is needful

INITIALIZE_IMMEDIATE(/mob/dead)

/mob/dead/Initialize()
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE
	tag = "mob_[next_mob_id++]"
	GLOB.mob_list += src

	prepare_huds()

	if(config.cross_allowed)
		verbs += /mob/dead/proc/server_hop
	return INITIALIZE_HINT_NORMAL

/mob/dead/dust()	//ghosts can't be vaporised.
	return

/mob/dead/gib()		//ghosts can't be gibbed.
	return

/mob/dead/ConveyorMove()	//lol
	return



/mob/dead/proc/server_hop()
	set category = "OOC"
	set name = "Server Hop!"
	set desc= "Jump to the other server"
	if(notransform)
		return
	if(!config.cross_allowed)
		verbs -= /mob/dead/proc/server_hop
		to_chat(src, "<span class='notice'>Server Hop has been disabled.</span>")
		return
	if (alert(src, "Jump to server running at [config.cross_address]?", "Server Hop", "Yes", "No") != "Yes")
		return 0
	if (client && config.cross_allowed)
		to_chat(src, "<span class='notice'>Sending you to [config.cross_address].</span>")
		new /obj/screen/splash(client)
		notransform = TRUE
		sleep(29)	//let the animation play
		notransform = FALSE
		winset(src, null, "command=.options") //other wise the user never knows if byond is downloading resources
		client << link(config.cross_address + "?server_hop=[key]")
	else
		to_chat(src, "<span class='error'>There is no other server configured!</span>")
