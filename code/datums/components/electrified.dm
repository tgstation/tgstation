/**
  * # Electrified Component
  *
  * A component for shocking objects
  */
/datum/component/electrified
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/electrification_state = MACHINE_NOT_ELECTRIFIED
	var/duration
	var/duration_timer

/datum/component/electrified/Initialize(electrification_state, mob/user, duration)
	log_electrification(src, user)

	if(electrification_state == MACHINE_NOT_ELECTRIFIED)
		return INITIALIZE_HINT_QDEL

	if(electrification_state == MACHINE_ELECTRIFIED_PERM_TOGGLE)
		src.electrification_state = MACHINE_ELECTRIFIED_PERMANENT
	else
		src.electrification_state = electrification_state

	if(!duration)
		switch(electrification_state)
			if(MACHINE_ELECTRIFIED_TEMPORARY)
				duration = MACHINE_DEFAULT_ELECTRIFY_TIME
			if(MACHINE_ELECTRIFIED_EMP)
				duration = MACHINE_DEFAULT_EMP_ELECTRIFY_TIME

	if(duration)
		if(duration_timer && timeleft(duration_timer) >= duration)
			return
		duration_timer = addtimer(CALLBACK(src, .proc/end_electrification), duration, TIMER_STOPPABLE|TIMER_OVERRIDE)

/datum/component/electrified/machinery/Initialize(electrification_state, mob/user, duration)
	if(!istype(parent, /obj/machinery) || is_type_in_typecache(parent.type, typecacheof(list(/obj/machinery/door/airlock/cult)))) // relies on parent having powered()
		return COMPONENT_INCOMPATIBLE

	. = ..()

	ui_update()

/// this is for the base generic electrified to make eg: walls electric
/datum/component/electrified/proc/register_interactions()
	RegisterSignal(parent, list(
		COMSIG_ATOM_ATTACK_HAND, 
		COMSIG_ATOM_BUMPED,
		COMSIG_MOVABLE_IMPACT), .proc/cooldown_shock)

/datum/component/electrified/proc/unregister_interactions()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_ATTACK_HAND, 
		COMSIG_ATOM_BUMPED,
		COMSIG_MOVABLE_IMPACT))

/datum/component/electrified/machinery/register_interactions()
	return

/datum/component/electrified/RegisterWithParent()
	registersignals()
	register_interactions()

/datum/component/electrified/machinery/RegisterWithParent()
	. = ..()
	RegisterSignal(src, COMSIG_MACHINERY_POWER_RESTORED, .proc/power_restored)
	RegisterSignal(src, COMSIG_MACHINERY_POWER_LOST, .proc/power_loss)
	RegisterSignal(parent, COMSIG_AIRLOCK_SILICON_ELECTRIFY, .proc/electrified)
	RegisterSignal(parent, COMSIG_MACHINERY_BROKEN, .proc/end_electrification)

/datum/component/electrified/UnregisterFromParent()
	unregistersignals()
	unregister_interactions()

/datum/component/electrified/machinery/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_MACHINERY_POWER_RESTORED,
		COMSIG_MACHINERY_POWER_LOST,
		COMSIG_AIRLOCK_SILICON_ELECTRIFY,
		COMSIG_MACHINERY_BROKEN
	))

/datum/component/electrified/Destroy(force, silent)
	unregister_interactions()
	return ..()

/datum/component/electrified/machinery/Destroy(force, silent)
	ui_update(FALSE)
	return ..()

/datum/component/electrified/InheritComponent(datum/component/C, i_am_original, list/arguments)
	switch(arguments[1])
		if(MACHINE_NOT_ELECTRIFIED, MACHINE_ELECTRIFIED_PERM_TOGGLE)
			end_electrification(null, arguments[2])
		if(MACHINE_ELECTRIFIED_PERMANENT) // always overrides other states
			clear_timer(FALSE)
			src.electrification_state = MACHINE_ELECTRIFIED_PERMANENT
		if(MACHINE_ELECTRIFIED_EMP) // only overrides temporary shocking
			if(src.electrification_state == MACHINE_ELECTRIFIED_PERMANENT)
				return
			src.electrification_state = MACHINE_ELECTRIFIED_EMP
			addtimer(CALLBACK(src, .proc/end_electrification), MACHINE_DEFAULT_EMP_ELECTRIFY_TIME, TIMER_STOPPABLE|TIMER_OVERRIDE)

/**
  * Returns something to indicate there's electrification
  *
  */
/datum/component/electrified/machinery/proc/electrified()
	return 1

/**
  * Signals the parent datum when theres something that may need UI updates
  *
  * This will signal false if there's eg. no power and therefore electrification is 'paused'
  *
  * Arguments:
  * * state indicates current electrification state
  */
/datum/component/electrified/machinery/proc/ui_update(state = TRUE)
	SEND_SIGNAL(parent, COMSIG_ELECTRIFICATION_CHANGE, state)

/**
  * Clears the current timer if the electrification is temporary
  *
  * Arguments:
  * * store_duration whether you care about keeping the time remaining on the timer
  */
/datum/component/electrified/proc/clear_timer(store_duration=TRUE)
	if(duration_timer)
		if(store_duration)
			duration = timeleft(duration_timer)
		deltimer(duration_timer)
	duration_timer = null
	if(!store_duration)
		duration = null

/**
  * Logs any electrification related events
  *
  * Arguments:
  * * source unused
  * * user the usr/source of the event
  */
/datum/component/electrified/proc/log_electrification(datum/source, mob/user)
	return

/datum/component/electrified/machinery/log_electrification(datum/source, mob/user)
	if(user)
		var/message
		switch(src.electrification_state)
			if(MACHINE_ELECTRIFIED_PERMANENT)
				message = "permanently shocked"
			if(MACHINE_NOT_ELECTRIFIED)
				message = "unshocked"
			else
				message = "temp shocked for [timeleft(duration_timer)] seconds"
		var/obj/machinery/P = parent
		LAZYADD(P.shockedby, text("\[[time_stamp()]\] [key_name(user)] - ([uppertext(message)])"))
		log_combat(user, parent, message)
		P.add_hiddenprint(user)

/**
  * Ends the electrification and logs the source/cause of it if applicable
  *
  * Arguments:
  * * source unused
  * * user the usr/source of the event
  */
/datum/component/electrified/proc/end_electrification(datum/source, mob/user)
	log_electrification(source, user)
	qdel(src)

/datum/component/electrified/machinery/end_electrification(datum/source, mob/user)
	ui_update(FALSE)
	return ..()

/**
  * Invoked when the parent loses power
  *
  */
/datum/component/electrified/proc/power_loss(datum/source)
	unregistersignals()
	if(duration_timer && electrification_state == MACHINE_ELECTRIFIED_TEMPORARY)
		clear_timer()

/**
  * Invoked when the parent regains power
  *
  */
/datum/component/electrified/proc/power_restored(datum/source)
	registersignals()
	if(duration && electrification_state == MACHINE_ELECTRIFIED_TEMPORARY)
		addtimer(CALLBACK(src, .proc/end_electrification), duration, TIMER_STOPPABLE|TIMER_OVERRIDE)
		duration = null

/**
  * Registers all the signals that will cause shocks to occur
  *
  * Separate proc due to unregistering when on shock cooldown
  */
/datum/component/electrified/proc/registersignals()
	RegisterSignal(parent, list(
		COMSIG_AIRLOCK_BUMPOPEN,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_AIRLOCK_ATTACKBY_CONDUCTIVE,
		COMSIG_AIRLOCK_ATTACKBY_POWERCROWBAR,
		COMSIG_AIRLOCK_ATTACK_ALIEN,
		COMSIG_AIRLOCK_WIRES_INTERACT,
		COMSIG_OBJ_ATTACK_ANIMAL,
		COMSIG_VENDING_TRY_INTERACT), .proc/cooldown_shock)
	RegisterSignal(parent, COMSIG_WIRE_INTERACT, .proc/wire_zap)

/datum/component/electrified/machinery/registersignals()
	var/obj/machinery/P = parent
	if(!P.powered())
		return
	return ..()

/**
  * Unregisters all the signals that will cause shocks to occur
  *
  * Separate proc due to registering when shock cooldown finishes
  */
/datum/component/electrified/proc/unregistersignals()
	UnregisterSignal(parent, list(
		COMSIG_AIRLOCK_BUMPOPEN,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_AIRLOCK_ATTACKBY_CONDUCTIVE,
		COMSIG_AIRLOCK_ATTACKBY_POWERCROWBAR,
		COMSIG_AIRLOCK_ATTACK_ALIEN,
		COMSIG_AIRLOCK_WIRES_INTERACT,
		COMSIG_OBJ_ATTACK_ANIMAL,
		COMSIG_WIRE_INTERACT,
		COMSIG_VENDING_TRY_INTERACT))

/**
  * Applies a shock and starts a cooldown before the next shock can occur
  *
  * Arguments:
  * * source unused
  * * user the mob to be shocked
  */
/datum/component/electrified/proc/cooldown_shock(datum/source, mob/user)
	. = shock(source, user)
	if(.)
		unregistersignals()
		addtimer(CALLBACK(src, .proc/registersignals), 1 SECONDS)

/**
  * Callback for wire related shock
  *
  * Functionally a wrapper for cooldown_shock with a return value for wire related signals
  *
  * Arguments:
  * * source unused
  * * user the mob to be shocked
  */
/datum/component/electrified/proc/wire_zap(datum/source, mob/user)
	if(cooldown_shock(source, user))
		return COMPONENT_NO_WIRE_INTERACT

/**
  * Actually applies a shock
  *
  * Avoid calling this directly as there is no cooldown.
  *
  * Arguments:
  * * source unused
  * * user the mob to be shocked
  */
/datum/component/electrified/proc/shock(datum/source, mob/user)
	if(!isliving(user) || issilicon(user) || IsAdminGhost(user))
		return

	do_sparks(5, TRUE, parent)
	if(electrocute_mob(user, get_area(parent), parent, 1, TRUE))
		return COMPONENT_NO_ATTACK_HAND|COMSIG_ELECTRIFIED_SHOCK
