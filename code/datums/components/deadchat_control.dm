#define DEMOCRACY_MODE "democracy"
#define ANARCHY_MODE "anarchy"

/datum/component/deadchat_control
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/list/datum/callback/inputs = list()
	var/list/ckey_to_cooldown = list()
	var/orbiters = list()
	var/deadchat_mode
	var/democracy_cooldown
	var/anarchy_cooldown
	var/global_control

/datum/component/deadchat_control/Initialize(_deadchat_mode, _inputs, _democracy_cooldown = 12 SECONDS, _anarchy_cooldown = 20 SECONDS, _force_move = FALSE, _global_control = FALSE)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(SSdcs, COMSIG_GLOB_DEAD_SAY, .proc/deadchat_react)
	RegisterSignal(parent, COMSIG_ATOM_ORBIT_BEGIN, .proc/orbit_begin)
	RegisterSignal(parent, COMSIG_ATOM_ORBIT_STOP, .proc/orbit_stop)
	deadchat_mode = _deadchat_mode
	if(deadchat_mode == DEMOCRACY_MODE)
		addtimer(CALLBACK(src, .proc/democracy_loop), democracy_cooldown)
	inputs = _inputs
	democracy_cooldown = _democracy_cooldown
	anarchy_cooldown = _anarchy_cooldown
	global_control = _global_control

/datum/component/deadchat_control/proc/deadchat_react(datum/source, mob/player, message)
	if(!global_control)
		if(!(player in orbiters))
			return
	message = lowertext(message)
	if(!(message in inputs))
		return 
	if(deadchat_mode == ANARCHY_MODE)
		var/cooldown = ckey_to_cooldown[player.ckey]
		if(cooldown)
			return SIGNAL_INTERCEPT
		inputs[message].Invoke()
		ckey_to_cooldown[player.ckey] = TRUE
		addtimer(CALLBACK(src, .proc/remove_cooldown, player.ckey), anarchy_cooldown)
	else if(deadchat_mode == DEMOCRACY_MODE)
		ckey_to_cooldown[player.ckey] = message
	return SIGNAL_INTERCEPT

/datum/component/deadchat_control/proc/remove_cooldown(ckey)
	ckey_to_cooldown.Remove(ckey)

/datum/component/deadchat_control/proc/democracy_loop()
	if(QDELETED(parent) || deadchat_mode != DEMOCRACY_MODE)
		return 
	var/result = count_democracy_votes()
	if(!isnull(result))
		inputs[result].Invoke()
		var/message = "<span class='deadsay italics bold'>[parent] has done action [result]!<br>New vote started. It will end in [democracy_cooldown/10] seconds.</span>"
		if(global_control)
			deadchat_broadcast(message)
		else
			for(var/M in orbiters)
				to_chat(M, message)
	else
		var/message = "<span class='deadsay italics bold'>No votes were cast this cycle.</span>"
		if(global_control)
			deadchat_broadcast(message)
		else
			for(var/M in orbiters)
				to_chat(M, message)
	addtimer(CALLBACK(src, .proc/democracy_loop), democracy_cooldown)
			
/datum/component/deadchat_control/proc/count_democracy_votes()
	var/list/votes
	for(var/command in inputs)
		votes[command] = 0
	var/found_vote = FALSE
	for(var/vote in ckey_to_cooldown)
		votes[ckey_to_cooldown[vote]]++
		if(ckey_to_cooldown[vote] != NONE)
			found_vote = TRUE
		ckey_to_cooldown.Remove(vote)
	if(!found_vote)
		return
	
	// Solve which had most votes.
	var/prev_value = 0
	var/result
	for(var/vote in votes)
		if(votes[vote] > prev_value)
			prev_value = votes[vote]
			result = vote
	
	if(result in inputs)
		return result
	else
		return

/datum/component/deadchat_control/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	if(var_name != NAMEOF(src, deadchat_mode))
		return
	ckey_to_cooldown = list()
	if(var_value == DEMOCRACY_MODE)
		addtimer(CALLBACK(src, .proc/democracy_loop), democracy_cooldown)

// TODO: Make orbit_begin and orbit_stop open and close an UI if global control is disabled.
/datum/component/deadchat_control/proc/orbit_begin(atom/source, atom/orbiter)
	orbiters |= orbiter

/datum/component/deadchat_control/proc/orbit_stop(atom/source, atom/orbiter)
	if(orbiter in orbiters)
		orbiters -= orbiter
