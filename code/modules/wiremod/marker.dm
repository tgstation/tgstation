/obj/item/multitool/circuit
	name = "circuit multitool"

	/// The marked atom of this multitool
	var/atom/marked_atom

/obj/item/multitool/circuit/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return
	if(!marked_atom)
		return

	say("Cleared marked targets.")
	clear_marked_atom()
	return TRUE

/obj/item/multitool/circuit/melee_attack_chain(mob/user, atom/target, params)
	var/is_right_clicking = LAZYACCESS(params2list(params), RIGHT_CLICK)

	if(marked_atom == target || !user.Adjacent(target) || is_right_clicking)
		return ..()

	clear_marked_atom()
	say("Marked \the [target].")
	marked_atom = target
	RegisterSignal(marked_atom, COMSIG_PARENT_QDELETING, .proc/cleanup_marked_atom)
	return TRUE

/// Clears the current marked atom
/obj/item/multitool/circuit/proc/clear_marked_atom()
	if(!marked_atom)
		return
	UnregisterSignal(marked_atom, COMSIG_PARENT_QDELETING)
	marked_atom = null

/obj/item/multitool/circuit/proc/cleanup_marked_atom(datum/source)
	SIGNAL_HANDLER
	if(source == marked_atom)
		clear_marked_atom()
