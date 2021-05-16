// Clickable stat() button.
/atom/movable/statclick
	name = "Initializing..."
	var/target

INITIALIZE_IMMEDIATE(/atom/movable/statclick)

/atom/movable/statclick/Initialize(mapload, text, target)
	. = ..()
	name = text
	src.target = target
	if(istype(target, /datum)) //Harddel man bad
		RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/cleanup)

/atom/movable/statclick/Destroy()
	target = null
	return ..()

/atom/movable/statclick/proc/cleanup()
	SIGNAL_HANDLER
	qdel(src)

/atom/movable/statclick/proc/update(text)
	name = text
	return src

/atom/movable/statclick/debug
	var/class

/atom/movable/statclick/debug/Click()
	if(!usr.client.holder || !target)
		return
	if(!class)
		if(istype(target, /datum/controller/subsystem))
			class = "subsystem"
		else if(istype(target, /datum/controller))
			class = "controller"
		else if(istype(target, /datum))
			class = "datum"
		else
			class = "unknown"

	usr.client.debug_variables(target)
	message_admins("Admin [key_name_admin(usr)] is debugging the [target] [class].")


// Debug verbs.
/client/proc/restart_controller(controller in list("Master", "Failsafe"))
	set category = "Debug"
	set name = "Restart Controller"
	set desc = "Restart one of the various periodic loop controllers for the game (be careful!)"

	if(!holder)
		return
	switch(controller)
		if("Master")
			Recreate_MC()
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Restart Master Controller")
		if("Failsafe")
			new /datum/controller/failsafe()
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Restart Failsafe Controller")

	message_admins("Admin [key_name_admin(usr)] has restarted the [controller] controller.")
