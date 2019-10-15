#define DEMOCRACY_MODE "democracy"
#define ANARCHY_MODE "anarchy"

/datum/component/deadchat_control
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/list/inputs = list("up", "down", "left", "right", "north", "south", "west", "east")
	var/list/ckey_to_cooldown = list()
	var/deadchat_mode = DEMOCRACY_MODE
	var/democracy_cooldown
	var/anarchy_cooldown
	var/force_move
	var/require_orbiting

/datum/component/deadchat_control/Initialize(_deadchat_mode, _democracy_cooldown = 12 SECONDS, _anarchy_cooldown = 20 SECONDS, _force_move = TRUE, _require_orbiting = FALSE)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(SSdcs, COMSIG_GLOB_DEAD_SAY, .proc/deadchat_react)
	deadchat_mode = _deadchat_mode
	if(deadchat_mode == DEMOCRACY_MODE)
		addtimer(CALLBACK(src, .proc/democracy_loop), democracy_cooldown)
	democracy_cooldown = _democracy_cooldown
	anarchy_cooldown = _anarchy_cooldown
	force_move = _force_move
	require_orbiting = _require_orbiting

/datum/component/deadchat_control/proc/deadchat_react(datum/source, mob/player, message)
	var/atom/movable/A = parent
	if(require_orbiting)
		if(!(player in A.orbiters?.orbiters))
			return
	if(deadchat_mode == ANARCHY_MODE)
		var/cooldown = ckey_to_cooldown[player.ckey]
		if(cooldown)
			return
		var/direction
		message = lowertext(message)
		switch(message)
			if("up" || "north")
				direction = NORTH
			if("down" || "south")
				direction = SOUTH
			if("left" || "west")
				direction = WEST
			if("right" || "east")
				direction = EAST
		if(direction)
			if(force_move)
				A.forceMove(get_step(A, direction))
			else
				step(A, direction)
			ckey_to_cooldown[player.ckey] = TRUE
			addtimer(VARSET_LIST_CALLBACK(ckey_to_cooldown, player.ckey, FALSE), anarchy_cooldown)
	else if(deadchat_mode == DEMOCRACY_MODE)
		message = lowertext(message)
		if(message in inputs)
			ckey_to_cooldown[player.ckey] = message

/datum/component/deadchat_control/proc/democracy_loop()
	if(QDELETED(parent) || deadchat_mode != DEMOCRACY_MODE)
		return 
	var/result = count_democracy_votes()
	var/atom/movable/A = parent
	if(result != NONE)
		if(force_move)
			A.forceMove(get_step(A, result))
		else
			step(A, result)
		var/direction_name
		switch(result)
			if(NORTH)
				direction_name = "up"
			if(SOUTH)
				direction_name = "down"
			if(WEST)
				direction_name = "left"
			if(EAST)
				direction_name = "right"
		var/message = "<span class='deadsay italics bold'>[parent] has moved [direction_name]!<br>New vote started. It will end in [democracy_cooldown/10] seconds.</span>"
		if(!require_orbiting)
			deadchat_broadcast(message)
		else
			for(var/M in A.orbiters?.orbiters)
				to_chat(M, message)
	else
		var/message = "<span class='deadsay italics bold'>No votes were cast this cycle. Type 'up', 'down', 'left' or 'right' to cast your vote!</span>"
		if(!require_orbiting)
			deadchat_broadcast(message)
		else
			for(var/M in A.orbiters?.orbiters)
				to_chat(M, message)
	addtimer(CALLBACK(src, .proc/democracy_loop), democracy_cooldown)
			
/datum/component/deadchat_control/proc/count_democracy_votes()
	var/list/votes = list("up" = 0, "down" = 0, "left" = 0, "right" = 0)
	var/found_vote = FALSE
	for(var/vote in ckey_to_cooldown)
		votes[ckey_to_cooldown[vote]]++
		if(ckey_to_cooldown[vote] != NONE)
			found_vote = TRUE
		ckey_to_cooldown.Remove(vote)
	if(!found_vote)
		return NONE
	
	// Solve which had most votes.
	var/prev_value = 0
	var/result
	for(var/vote in votes)
		if(votes[vote] > prev_value)
			prev_value = votes[vote]
			result = vote
	
	if(result == "up" || result == "north")
		return NORTH
	else if(result == "down" || result == "south")
		return SOUTH
	else if(result == "left" || result == "west")
		return WEST
	else if(result == "right" || result == "east")
		return EAST
	else
		return NONE

/datum/component/deadchat_control/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	if(var_name != NAMEOF(src, deadchat_mode))
		return
	ckey_to_cooldown = list()
	if(var_value == DEMOCRACY_MODE)
		addtimer(CALLBACK(src, .proc/democracy_loop), democracy_cooldown)

#undef DEMOCRACY_MODE
#undef ANARCHY_MODE
