/// The subsystem for controlling drastic performance enhancements aimed at reducing server load for a smoother albeit slightly duller gaming experience
SUBSYSTEM_DEF(lag_switch)
	name = "Lag Switch"
	flags = SS_NO_FIRE

	/// If the lag switch measures should attempt to trigger automatically, TRUE if a config value exists
	var/auto_switch = FALSE
	/// Amount of connected clients at which the Lag Switch should engage, set via config or admin panel
	var/trigger_pop = INFINITY - 1337
	/// List of bools corresponding to code/__DEFINES/lag_switch.dm
	var/static/list/measures[MEASURES_AMOUNT]
	/// List of measures that toggle automatically
	var/list/auto_measures = list(DISABLE_GHOST_ZOOM_TRAY, DISABLE_RUNECHAT, DISABLE_USR_ICON2HTML, DISABLE_PARALLAX, DISABLE_FOOTSTEPS)
	/// Timer ID for the automatic veto period
	var/veto_timer_id
	/// Cooldown between say verb uses when slowmode is enabled
	var/slowmode_cooldown = 3 SECONDS

/datum/controller/subsystem/lag_switch/Initialize()
	for(var/i in 1 to measures.len)
		measures[i] = FALSE
	var/auto_switch_pop = CONFIG_GET(number/auto_lag_switch_pop)
	if(auto_switch_pop)
		auto_switch = TRUE
		trigger_pop = auto_switch_pop
		RegisterSignal(SSdcs, COMSIG_GLOB_CLIENT_CONNECT, PROC_REF(client_connected))
	return SS_INIT_SUCCESS

/datum/controller/subsystem/lag_switch/proc/client_connected(datum/source, client/connected)
	SIGNAL_HANDLER
	if(TGS_CLIENT_COUNT < trigger_pop)
		return

	auto_switch = FALSE
	UnregisterSignal(SSdcs, COMSIG_GLOB_CLIENT_CONNECT)
	veto_timer_id = addtimer(CALLBACK(src, PROC_REF(set_all_measures), TRUE, TRUE), 20 SECONDS, TIMER_STOPPABLE)
	message_admins("Lag Switch population threshold reached. Automatic activation of lag mitigation measures occuring in 20 seconds. (<a href='byond://?_src_=holder;[HrefToken()];change_lag_switch_option=CANCEL'>CANCEL</a>)")
	log_admin("Lag Switch population threshold reached. Automatic activation of lag mitigation measures occuring in 20 seconds.")

/// (En/Dis)able automatic triggering of switches based on client count
/datum/controller/subsystem/lag_switch/proc/toggle_auto_enable()
	auto_switch = !auto_switch
	if(auto_switch)
		RegisterSignal(SSdcs, COMSIG_GLOB_CLIENT_CONNECT, PROC_REF(client_connected))
	else
		UnregisterSignal(SSdcs, COMSIG_GLOB_CLIENT_CONNECT)

/// Called from an admin chat link
/datum/controller/subsystem/lag_switch/proc/cancel_auto_enable_in_progress()
	if(!veto_timer_id)
		return FALSE

	deltimer(veto_timer_id)
	veto_timer_id = null
	return TRUE

/// Update the slowmode timer length and clear existing ones if reduced
/datum/controller/subsystem/lag_switch/proc/change_slowmode_cooldown(length)
	if(!length)
		return FALSE

	var/length_secs = length SECONDS
	if(length_secs <= 0)
		length_secs = 1 // one tick because cooldowns do not like 0

	if(length_secs < slowmode_cooldown)
		for(var/client/C as anything in GLOB.clients)
			COOLDOWN_RESET(C, say_slowmode)

	slowmode_cooldown = length_secs
	if(measures[SLOWMODE_SAY])
		to_chat(world, span_boldannounce("Slowmode timer has been changed to [length] seconds by an admin."))
	return TRUE

/// Handle the state change for individual measures
/datum/controller/subsystem/lag_switch/proc/set_measure(measure_key, state)
	if(isnull(measure_key) || isnull(state))
		stack_trace("SSlag_switch.set_measure() was called with a null arg")
		return FALSE
	if(isnull(LAZYACCESS(measures, measure_key)))
		stack_trace("SSlag_switch.set_measure() was called with a measure_key not in the list of measures")
		return FALSE
	if(measures[measure_key] == state)
		return TRUE

	measures[measure_key] = state

	switch(measure_key)
		if(DISABLE_DEAD_KEYLOOP)
			if(state)
				for(var/mob/user as anything in GLOB.player_list)
					if(user.stat == DEAD && !user.client?.holder)
						GLOB.keyloop_list -= user
				deadchat_broadcast(span_big("To increase performance Observer freelook is now disabled. Please use Orbit, Teleport, and Jump to look around."), message_type = DEADCHAT_ANNOUNCEMENT)
			else
				GLOB.keyloop_list |= GLOB.player_list
				deadchat_broadcast("Observer freelook has been re-enabled. Enjoy your wooshing.", message_type = DEADCHAT_ANNOUNCEMENT)
		if(DISABLE_GHOST_ZOOM_TRAY)
			if(state) // if enabling make sure current ghosts are updated
				for(var/mob/dead/observer/ghost in GLOB.dead_mob_list)
					if(!ghost.client)
						continue
					if(!ghost.client.holder && ghost.client.view_size.getView() != ghost.client.view_size.default)
						ghost.client.view_size.resetToDefault()
		if(SLOWMODE_SAY)
			if(state)
				to_chat(world, span_boldannounce("Slowmode for IC/dead chat has been enabled with [slowmode_cooldown/10] seconds between messages."))
			else
				for(var/client/C as anything in GLOB.clients)
					COOLDOWN_RESET(C, say_slowmode)
				to_chat(world, span_boldannounce("Slowmode for IC/dead chat has been disabled by an admin."))
		if(DISABLE_NON_OBSJOBS)
			world.update_status()
		if(DISABLE_PARALLAX)
			if (state)
				to_chat(world, span_boldannounce("Parallax has been disabled for performance concerns."))
			else
				to_chat(world, span_boldannounce("Parallax has been re-enabled."))

			for (var/mob/mob as anything in GLOB.mob_list)
				mob.hud_used?.update_parallax_pref()
		if (DISABLE_FOOTSTEPS)
			if (state)
				to_chat(world, span_boldannounce("Footstep sounds have been disabled for performance concerns."))
			else
				to_chat(world, span_boldannounce("Footstep sounds have been re-enabled."))

	return TRUE

/// Helper to loop over all measures for mass changes
/datum/controller/subsystem/lag_switch/proc/set_all_measures(state, automatic = FALSE)
	if(isnull(state))
		stack_trace("SSlag_switch.set_all_measures() was called with a null state arg")
		return FALSE

	if(automatic)
		message_admins("Lag Switch enabling automatic measures now.")
		log_admin("Lag Switch enabling automatic measures now.")
		veto_timer_id = null
		for(var/i in 1 to auto_measures.len)
			set_measure(auto_measures[i], state)
		return TRUE

	for(var/i in 1 to measures.len)
		set_measure(i, state)
	return TRUE
