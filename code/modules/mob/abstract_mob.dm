/// A mob that's only a mob for some sort of technical purpose, and is not really an actual in-game mob, if that makes sense.
/mob/abstract
	icon_state = null
	density = FALSE
	move_resist = INFINITY
	invisibility = INVISIBILITY_NONE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	logging = null
	held_items = null //all of these are list objects that should not exist for something like us
	faction = null
	alerts = null
	screens = null
	client_colours = null
	hud_possible = null

/mob/abstract/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1
	return INITIALIZE_HINT_NORMAL

/mob/abstract/Move()
	SHOULD_CALL_PARENT(FALSE)
	stack_trace("ABSTRACT MOB [src]([type]) MOVED SOMEHOW")
	return FALSE

/mob/abstract/abstract_move(atom/destination)
	SHOULD_CALL_PARENT(FALSE)
	stack_trace("ABSTRACT MOB [src]([type]) MOVED SOMEHOW")

/mob/abstract/Bump()
	SHOULD_CALL_PARENT(FALSE)
	return FALSE

/mob/abstract/log_message(message, message_type, color, log_globally, list/data)
	SHOULD_CALL_PARENT(FALSE)
	return
