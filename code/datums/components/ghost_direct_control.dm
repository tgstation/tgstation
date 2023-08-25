/**
 * Component which lets ghosts click on a mob to take control of it
 */
/datum/component/ghost_direct_control
	/// Message to display upon successful possession
	var/assumed_control_message
	/// Type of ban you can get to prevent you from accepting this role
	var/ban_type
	/// Any extra checks which need to run before we take over
	var/datum/callback/extra_control_checks
	/// Callback run after someone successfully takes over the body
	var/datum/callback/after_assumed_control
	/// If we're currently awaiting the results of a ghost poll
	var/awaiting_ghosts = FALSE

/datum/component/ghost_direct_control/Initialize(
	ban_type = ROLE_SENTIENCE,
	role_name = null,
	poll_candidates = TRUE,
	poll_length = 10 SECONDS,
	poll_ignore_key = POLL_IGNORE_SENTIENCE_POTION,
	assumed_control_message = null,
	datum/callback/extra_control_checks,
	datum/callback/after_assumed_control,
)
	. = ..()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.ban_type = ban_type
	src.assumed_control_message = assumed_control_message || "You are [parent]!"
	src.extra_control_checks = extra_control_checks
	src.after_assumed_control= after_assumed_control

	var/mob/mob_parent = parent
	LAZYADD(GLOB.joinable_mobs[format_text("[initial(mob_parent.name)]")], mob_parent)

	if (poll_candidates)
		INVOKE_ASYNC(src, PROC_REF(request_ghost_control), role_name || "[parent]", poll_length, poll_ignore_key)

/datum/component/ghost_direct_control/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST, PROC_REF(on_ghost_clicked))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))

/datum/component/ghost_direct_control/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_ATTACK_GHOST, COMSIG_ATOM_EXAMINE))
	return ..()

/datum/component/ghost_direct_control/Destroy(force, silent)
	extra_control_checks = null
	after_assumed_control = null

	var/mob/mob_parent = parent
	var/list/spawners = GLOB.joinable_mobs[format_text("[initial(mob_parent.name)]")]
	LAZYREMOVE(spawners, mob_parent)
	if(!LAZYLEN(spawners))
		GLOB.joinable_mobs -= format_text("[initial(mob_parent.name)]")
	return ..()

/// Inform ghosts that they can possess this
/datum/component/ghost_direct_control/proc/on_examined(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if (!isobserver(user))
		return
	var/mob/living/our_mob = parent
	if (our_mob.stat == DEAD || our_mob.key || awaiting_ghosts)
		return
	examine_text += span_boldnotice("You could take control of this mob by clicking on it.")

/// Send out a request for a brain
/datum/component/ghost_direct_control/proc/request_ghost_control(role_name, poll_length, poll_ignore_key)
	if (!(GLOB.ghost_role_flags & GHOSTROLE_SPAWNER))
		return
	awaiting_ghosts = TRUE
	var/list/mob/dead/observer/candidates = poll_ghost_candidates(
		question = "Do you want to play as [role_name]?",
		jobban_type = ban_type,
		be_special_flag = ban_type,
		poll_time = poll_length,
		ignore_category = poll_ignore_key,
	)
	awaiting_ghosts = FALSE
	if (!LAZYLEN(candidates))
		return
	assume_direct_control(pick(candidates))

/// A ghost clicked on us, they want to get in this body
/datum/component/ghost_direct_control/proc/on_ghost_clicked(mob/our_mob, mob/dead/observer/hopeful_ghost)
	SIGNAL_HANDLER
	if (our_mob.key)
		qdel(src)
		return
	if (!hopeful_ghost.client)
		return
	if (!(GLOB.ghost_role_flags & GHOSTROLE_SPAWNER))
		to_chat(hopeful_ghost, span_warning("Ghost roles have been temporarily disabled!"))
		return
	if (awaiting_ghosts)
		to_chat(hopeful_ghost, span_warning("Ghost candidate selection currently in progress!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if (!SSticker.HasRoundStarted())
		to_chat(hopeful_ghost, span_warning("You cannot assume control of this until after the round has started!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	INVOKE_ASYNC(src, PROC_REF(attempt_possession), our_mob, hopeful_ghost)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// We got far enough to establish that this mob is a valid target, let's try to posssess it
/datum/component/ghost_direct_control/proc/attempt_possession(mob/our_mob, mob/dead/observer/hopeful_ghost)
	var/ghost_asked = tgui_alert(usr, "Become [our_mob]?", "Are you sure?", list("Yes", "No"))
	if (ghost_asked != "Yes" || QDELETED(our_mob))
		return
	assume_direct_control(hopeful_ghost)

/// Grant possession of our mob, component is now no longer required
/datum/component/ghost_direct_control/proc/assume_direct_control(mob/harbinger)
	if (QDELETED(src))
		to_chat(harbinger, span_warning("Offer to possess creature has expired!"))
		return
	if (is_banned_from(harbinger.ckey, list(ban_type)))
		to_chat(harbinger, span_warning("You are banned from playing as this role!"))
		return
	if (!(GLOB.ghost_role_flags & GHOSTROLE_SPAWNER))
		to_chat(harbinger, span_warning("Ghost roles have been temporarily disabled!"))
		return
	var/mob/living/new_body = parent
	if (new_body.stat == DEAD)
		to_chat(harbinger, span_warning("This body has passed away, it is of no use!"))
		return
	if (new_body.key)
		to_chat(harbinger, span_warning("[parent] has already become sapient!"))
		qdel(src)
		return
	if (extra_control_checks && !extra_control_checks.Invoke(harbinger))
		return
	harbinger.log_message("took control of [new_body].", LOG_GAME)
	new_body.key = harbinger.key
	to_chat(new_body, span_boldnotice(assumed_control_message))
	after_assumed_control?.Invoke(harbinger)
	qdel(src)
