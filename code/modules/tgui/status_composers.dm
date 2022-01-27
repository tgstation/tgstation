/// The sane defaults for a UI such as a computer or a machine.
/proc/default_ui_state(mob/user, atom/source)
	return min(
		ui_status_user_is_abled(user, source),
		ui_status_user_has_free_hands(user, source),
		ui_status_user_is_advanced_tool_user(user),
		ui_status_only_living(user),
		max(
			ui_status_user_is_adjacent(user, source),
			ui_status_silicon_has_access(user, source),
		)
	)

/// Returns a UI status such that users adjacent to source will be able to interact,
/// far away users will be able to see, and anyone farther won't see anything.
/// Dead users will receive updates no matter what, though you likely want to add
/// a [`ui_status_only_living`] check for finer observer interactions.
/proc/ui_status_user_is_adjacent(mob/user, atom/source, allow_tk = TRUE)
	if (isliving(user))
		var/mob/living/living_user = user
		return living_user.shared_living_ui_distance(source, allow_tk = allow_tk)
	else
		return UI_UPDATE

/// Returns a UI status such that the dead will be able to watch, but not interact.
/proc/ui_status_only_living(mob/user, source)
	if (isliving(user))
		return UI_INTERACTIVE

	if(isobserver(user))
		// If they turn on ghost AI control, admins can always interact.
		if(isAdminGhostAI(user))
			return UI_INTERACTIVE

		// Regular ghosts can always at least view if in range.
		var/datum/client_interface/client = GET_CLIENT(user)
		if(client)
			var/clientviewlist = getviewsize(client.view)
			if(get_dist(source, user) < max(clientviewlist[1], clientviewlist[2]))
				return UI_UPDATE

	return UI_CLOSE

/// Returns a UI status such that users with debilitating conditions, such as
/// being dead or not having power for silicons, will not be able to interact.
/// Being dead will disable UI, being incapacitated will continue updating it,
/// and anything else will make it interactive.
/proc/ui_status_user_is_abled(mob/user, atom/source)
	return user.shared_ui_interaction(source)

/// Returns a UI status such that those without blocked hands will be able to interact,
/// but everyone else can only watch.
/proc/ui_status_user_has_free_hands(mob/user, atom/source)
	return HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) ? UI_UPDATE : UI_INTERACTIVE

/// Returns a UI status such that advanced tool users will be able to interact,
/// but everyone else can only watch.
/proc/ui_status_user_is_advanced_tool_user(mob/user)
	return ISADVANCEDTOOLUSER(user) ? UI_INTERACTIVE : UI_UPDATE

/// Returns a UI status such that silicons will be able to interact with whatever
/// they would have access to if this was a machine. For example, AIs can
/// interact if there's cameras with wireless control is enabled.
/proc/ui_status_silicon_has_access(mob/user, atom/source)
	if (!issilicon(user))
		return UI_CLOSE
	var/mob/living/silicon/silicon_user = user
	return silicon_user.get_ui_access(source)

/// Returns a UI status representing this silicon's capability to access
/// the given source. Called by `ui_status_silicon_has_access`.
/mob/living/silicon/proc/get_ui_access(atom/source)
	return UI_CLOSE

/mob/living/silicon/robot/get_ui_access(atom/source)
	// Robots can interact with anything they can see.
	var/list/clientviewlist = getviewsize(client.view)
	if(get_dist(src, source) <= min(clientviewlist[1],clientviewlist[2]))
		return UI_INTERACTIVE
	return UI_DISABLED // Otherwise they can keep the UI open.

/mob/living/silicon/ai/get_ui_access(atom/source)
	// The AI can interact with anything it can see nearby, or with cameras while wireless control is enabled.
	if(!control_disabled && can_see(source))
		return UI_INTERACTIVE
	return UI_CLOSE

/mob/living/silicon/pai/get_ui_access(atom/source)
	// pAIs can only use themselves and the owner's radio.
	if((source == src || source == radio) && !stat)
		return UI_INTERACTIVE
	else
		return UI_CLOSE

/// Returns UI_INTERACTIVE if the user is conscious and lying down.
/// Returns UI_UPDATE otherwise.
/proc/ui_status_user_is_conscious_and_lying_down(mob/user)
	if (!isliving(user))
		return UI_UPDATE

	var/mob/living/living_user = user
	return (living_user.body_position == LYING_DOWN && living_user.stat == CONSCIOUS) \
		? UI_INTERACTIVE \
		: UI_UPDATE

/// Return UI_INTERACTIVE if the user is strictly adjacent to the target atom, whether they can see it or not.
/// Return UI_CLOSE otherwise.
/proc/ui_status_user_strictly_adjacent(mob/user, atom/target)
	if(get_dist(target, user) > 1)
		return UI_CLOSE

	return UI_INTERACTIVE
