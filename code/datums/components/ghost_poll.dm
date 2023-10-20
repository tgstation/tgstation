/**
 * A replacement for the standard poll_ghost_candidate.
 * Use this to subtly ask players to join - it picks from orbiters.
 *
 * @params ignore_key - Required so it doesn't spam
 * @params job_bans - You can insert a list or single items here.
 * @params cb - Invokes this proc and appends the poll winner as the last argument, mob/dead/observer/ghost
 */
/datum/component/ghost_poll
	/// Prevent players with this ban from being selected
	var/list/job_bans = list()
	/// Title of the role to announce after it's done
	var/title
	/// Proc to invoke whenever the poll is complete
	var/datum/callback/to_call

/datum/component/ghost_poll/Initialize(ignore_key, list/job_bans, datum/callback/cb, title, header = "Ghost Poll", custom_message)
	. = ..()
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	var/atom/owner = parent

	src.to_call = cb
	src.job_bans |= job_bans
	src.title = title || owner.name

	var/message = custom_message || "[capitalize(title)] is looking for volunteers"

	notify_ghosts("[message]. An orbiter will be chosen in twenty seconds.", \
		action = NOTIFY_ORBIT, \
		flashwindow = FALSE, \
		header = "Volunteers requested", \
		ignore_key = ignore_key, \
		source = parent \
	)

	addtimer(CALLBACK(src, PROC_REF(end_poll)), 20 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE|TIMER_DELETE_ME)

/// Concludes the poll, picking one of the orbiters
/datum/component/ghost_poll/proc/end_poll()
	if(QDELETED(parent))
		return

	var/list/candidates = list()
	var/atom/owner = parent

	var/datum/component/orbiter/orbiter_comp = owner.GetComponent(/datum/component/orbiter)
	if(isnull(orbiter_comp))
		return

	for(var/mob/dead/observer/ghost as anything in orbiter_comp.orbiter_list)
		if(QDELETED(ghost) || isnull(ghost.client))
			continue
		if(is_banned_from(ghost.ckey, job_bans))
			continue

		candidates += ghost

	if(!length(candidates))
		return

	var/mob/dead/observer/chosen = pick(candidates)

	if(chosen)
		deadchat_broadcast("[chosen.ckey] was selected for the role ([title]).", "Ghost Poll: ", parent)

	to_call.Invoke(chosen)

	qdel(src)
