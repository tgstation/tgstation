// Clickable stat() button.
/obj/effect/statclick
	name = "Initializing..."
	blocks_emissive = EMISSIVE_BLOCK_NONE
	var/target

INITIALIZE_IMMEDIATE(/obj/effect/statclick)

/obj/effect/statclick/Initialize(mapload, text, target)
	. = ..()
	name = text
	src.target = target
	if(isdatum(target)) //Harddel man bad
		RegisterSignal(target, COMSIG_QDELETING, PROC_REF(cleanup))

/obj/effect/statclick/Destroy()
	target = null
	return ..()

/obj/effect/statclick/proc/cleanup()
	SIGNAL_HANDLER
	qdel(src)

/obj/effect/statclick/proc/update(text)
	name = text
	return src

/obj/effect/statclick/debug
	var/class

/obj/effect/statclick/debug/Click()
	if(!usr.client.holder || !target)
		return
	if(!class)
		if(istype(target, /datum/controller/subsystem))
			class = "subsystem"
		else if(istype(target, /datum/controller))
			class = "controller"
		else if(isdatum(target))
			class = "datum"
		else
			class = "unknown"

	usr.client.debug_variables(target)
	message_admins("Admin [key_name_admin(usr)] is debugging the [target] [class].")

ADMIN_VERB(restart_controller, R_DEBUG, "Restart Controller", "Restart one of the various periodic loop controllers for the game (be careful!)", ADMIN_CATEGORY_DEBUG, controller in list("Master", "Failsafe"))
	switch(controller)
		if("Master")
			Recreate_MC()
			BLACKBOX_LOG_ADMIN_VERB("Restart Master Controller")
		if("Failsafe")
			new /datum/controller/failsafe()
			BLACKBOX_LOG_ADMIN_VERB("Restart Failsafe Controller")

	message_admins("Admin [key_name_admin(user)] has restarted the [controller] controller.")

ADMIN_VERB(debug_controller, R_DEBUG, "Debug Controller", "Debug the various periodic loop controllers for the game (be careful!)", ADMIN_CATEGORY_DEBUG)
	var/list/controllers = list()
	var/list/controller_choices = list()

	for (var/var_key in global.vars)
		var/datum/controller/controller = global.vars[var_key]
		if(!istype(controller) || istype(controller, /datum/controller/subsystem))
			continue
		controllers[controller.name] = controller //we use an associated list to ensure clients can't hold references to controllers
		controller_choices += controller.name

	var/datum/controller/controller_string = input("Select controller to debug", "Debug Controller") as null|anything in controller_choices
	var/datum/controller/controller = controllers[controller_string]

	if (!istype(controller))
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/debug_variables, controller)

	BLACKBOX_LOG_ADMIN_VERB("Debug Controller")
	message_admins("Admin [key_name_admin(user)] is debugging the [controller] controller.")
