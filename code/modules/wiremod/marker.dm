/obj/item/multitool/circuit
	name = "circuit multitool"

	var/atom/marked_atom

/obj/item/multitool/circuit/melee_attack_chain(mob/user, atom/target, params)
	var/is_right_clicking = LAZYACCESS(params2list(params), RIGHT_CLICK)

	if(marked_atom == target || !user.Adjacent(target) || is_right_clicking)
		return ..()

	if(marked_atom)
		UnregisterSignal(marked_atom, COMSIG_PARENT_QDELETING)
	to_chat(user, "<span class='notice'>You mark \the [target].</span>")
	marked_atom = target
	RegisterSignal(marked_atom, COMSIG_PARENT_QDELETING, .proc/cleanup_marked_atom)
	return TRUE

/obj/item/multitool/circuit/proc/cleanup_marked_atom(datum/source)
	SIGNAL_HANDLER
	if(source == marked_atom)
		marked_atom = null
