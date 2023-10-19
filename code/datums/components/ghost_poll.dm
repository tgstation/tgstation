/**
 * A replacement for the standard poll_ghost_candidate.
 * Use this to more subtly ask players to join - it takes the orbiters.
 */
/datum/component/ghost_poll

/datum/component/ghost_poll/Initialize(ignore_key, title = "A ghost role", header = "Ghost Poll")
	. = ..()
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	notify_ghosts("[title] is looking for volunteers. An orbiter will be chosen in twenty seconds.", \
		source = parent, \
		action = NOTIFY_ORBIT, \
		header = "Volunteers requested"\
	)

	add_timer(CALLBACK(src, PROC_REF(end_poll)), 20 SECONDS, TIMER_OVERRIDE|TIMER_STOPPABLE|TIMER_DELETE_ME)

/datum/component/ghost_poll/proc/end_poll()
	var/list/candidates = list()
	var/atom/owner = parent

	var/datum/component/orbiter/orbiter_comp = owner.GetComponent(/datum/component/orbiter)
	if(isnull(orbiter_comp))
		return

	for(var/mob/dead/observer/ghost as anything in orbiter_comp.orbiter_list)
		if(isnull(ghost.client))
			continue
		candidates += ghost

	if(!length(candidates))
		return

	var/mob/dead/observer/chosen = pick(candidates)

	SEND_SIGNAL(src, COMSIG_GHOSTPOLL_CONCLUDED, chosen)
	qdel(src)

