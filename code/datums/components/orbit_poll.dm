/**
 * A replacement for the standard poll_ghost_candidate.
 * Use this to subtly ask players to join - it picks from orbiters.
 * Please use named arguments for this.
 *
 * @params ignore_key - Required so it doesn't spam
 * @params job_bans - You can insert a list or single items here.
 * @params cb - Invokes this proc and appends the poll winner as the last argument, mob/dead/observer/ghost
 * @params title - Optional. Useful if the role name does not match the parent.
 *
 * @usage
 * ```
 * var/datum/callback/cb = CALLBACK(src, PROC_REF(do_stuff), arg1, arg2)
 * AddComponent(/datum/component/orbit_poll, \
 *   ignore_key = POLL_IGNORE_EXAMPLE, \
 *   job_bans = ROLE_EXAMPLE or list(ROLE_EXAMPLE, ROLE_EXAMPLE2), \
 *   title = "Use this if you want something other than the parent name", \
 *   to_call = cb, \
 * )
 */
/datum/component/orbit_poll
	/// Prevent players with this ban from being selected
	var/list/job_bans = list()
	/// Title of the role to announce after it's done
	var/title
	/// Proc to invoke whenever the poll is complete
	var/datum/callback/to_call

/datum/component/orbit_poll/Initialize( \
	ignore_key, \
	list/job_bans, \
	datum/callback/to_call, \
	title, \
	header = "Ghost Poll", \
	custom_message, \
	timeout = 20 SECONDS \
)
	. = ..()
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	var/atom/owner = parent

	src.job_bans |= job_bans
	src.title = title || owner.name
	src.to_call = to_call

	var/message = custom_message || "[capitalize(src.title)] is looking for volunteers"

	notify_ghosts("[message]. An orbiter will be chosen in [DisplayTimeText(timeout)].\n", \
		action = NOTIFY_ORBIT, \
		enter_link = "<a href='?src=[REF(src)];ignore=[ignore_key]'>(Ignore)</a>", \
		flashwindow = FALSE, \
		header = "Volunteers requested", \
		ignore_key = ignore_key, \
		source = parent \
	)

	addtimer(CALLBACK(src, PROC_REF(end_poll)), timeout, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE|TIMER_DELETE_ME)

/datum/component/orbit_poll/Topic(href, list/href_list)
	if(!href_list["ignore"])
		return

	var/mob/user = usr

	var/ignore_key = href_list["ignore"]
	if(tgui_alert(user, "Ignore further [title] alerts?", "Ignore Alert", list("Yes", "No"), 20 SECONDS, TRUE) != "Yes")
		return

	GLOB.poll_ignore[ignore_key] |= user.ckey

/// Concludes the poll, picking one of the orbiters
/datum/component/orbit_poll/proc/end_poll()
	if(QDELETED(parent))
		return

	var/list/candidates = list()
	var/atom/owner = parent

	var/datum/component/orbiter/orbiter_comp = owner.GetComponent(/datum/component/orbiter)
	if(isnull(orbiter_comp))
		phone_home()
		return

	for(var/mob/dead/observer/ghost as anything in orbiter_comp.orbiter_list)
		if(QDELETED(ghost) || isnull(ghost.client))
			continue
		if(is_banned_from(ghost.ckey, job_bans))
			continue

		candidates += ghost

	if(!length(candidates))
		phone_home()
		return

	var/mob/dead/observer/chosen = pick(candidates)

	if(chosen)
		deadchat_broadcast("[key_name(chosen, include_name = FALSE)] was selected for the role ([title]).", "Ghost Poll: ", parent)

	phone_home(chosen)

/// Make sure to call your parents my dude
/datum/component/orbit_poll/proc/phone_home(mob/dead/observer/chosen)
	to_call.Invoke(chosen)
	qdel(src)
