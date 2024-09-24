/// Allows us to move through glass but not electrified glass. Can also do a little slowdown before passing through
/datum/component/glass_passer
	/// How long does it take us to move into glass?
	var/pass_time = 0 SECONDS

/datum/component/glass_passer/Initialize(pass_time)
	if(!ismob(parent)) //if its not a mob then just directly use passwindow
		return COMPONENT_INCOMPATIBLE

	src.pass_time = pass_time

	if(!pass_time)
		passwindow_on(parent, type)
	else
		RegisterSignal(parent, COMSIG_MOVABLE_BUMP, PROC_REF(bumped))

	var/mob/mobbers = parent
	mobbers.generic_canpass = FALSE
	RegisterSignal(parent, COMSIG_MOVABLE_CROSS_OVER, PROC_REF(cross_over))

/datum/component/glass_passer/Destroy()
	. = ..()
	if(parent)
		passwindow_off(parent, type)

/datum/component/glass_passer/proc/cross_over(mob/passer, atom/crosser)
	SIGNAL_HANDLER

	if(istype(crosser, /obj/structure/grille))
		var/obj/structure/grille/grillefriend = crosser
		if(grillefriend.is_shocked()) //prevent passage of shocked
			crosser.balloon_alert(passer, "is shocked!")
			return COMPONENT_BLOCK_CROSS

	return null

/datum/component/glass_passer/proc/bumped(mob/living/owner, atom/bumpee)
	SIGNAL_HANDLER

	if(!istype(bumpee, /obj/structure/window))
		return

	INVOKE_ASYNC(src, PROC_REF(phase_through_glass), owner, bumpee)

/datum/component/glass_passer/proc/phase_through_glass(mob/living/owner, atom/bumpee)
	if(!do_after(owner, pass_time, bumpee))
		return
	passwindow_on(owner, type)
	try_move_adjacent(owner, get_dir(owner, bumpee))
	passwindow_off(owner, type)
