#define POSIBRAIN_NAG_COOLDOWN 60 SECONDS

/obj/item/brain_processor/positronic
	name = "positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."
	icon_state = "posibrain"
	base_icon_state = "posibrain"
	w_class = WEIGHT_CLASS_NORMAL
	req_access = list(ACCESS_ROBOTICS)
	braintype = "Android"
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.85, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 0.67, /datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT)

	/// Holds the timer ID for pinging ghosts.
	VAR_PRIVATE/ghost_ping_timer
	/// Time before pinging ghosts will also play a sound.
	STATIC_COOLDOWN_DECLARE(ghost_nag_cooldown)

	///Role assigned to the newly created mind
	var/posibrain_job_path = /datum/job/positronic_brain
	///Can be set to tell ghosts what the brain will be used for
	VAR_FINAL/requested_personality
	///Hashset of all ckeys who has already entered this posibrain once before. Lazy.
	VAR_FINAL/list/ckeys_entered

/obj/item/brain_processor/positronic/Initialize(mapload, autoping = TRUE)
	. = ..()
	set_brainmob(new /mob/living/brain(src))
	brainmob.grant_language(/datum/language/machine, source = LANGUAGE_ATOM)

	var/new_name = pick(GLOB.posibrain_names)
	var/new_id = num2text(rand(1, 999), 3, 10)
	set_name("[new_name]-[new_id]")
	if(autoping)
		ping_ghosts("created", TRUE)

/obj/item/brain_processor/positronic/Destroy(force)
	stop_requesting_ghost()
	return ..()

/obj/item/brain_processor/positronic/update_icon_state()
	. = ..()
	var/suffix
	if(is_searching())
		suffix = "searching"
	else if(brainmob.ckey)
		suffix = "occupied"

	icon_state = "[base_icon_state][suffix ? "-[suffix]" : null]"

/obj/item/brain_processor/positronic/examine(mob/user)
	. = ..()
	if(brainmob.key)
		if(brainmob.stat >= DEAD)
			. += span_deadsay("It appears to be completely inactive.")
		else if(!brainmob.client)
			. += "It appears to be in stand-by mode." //afk
		return

	if(is_searching())
		. += span_info("It's emitting light in a steady pulse.")
	else
		. += span_deadsay("It appears to be completely inactive. The reset light is blinking.")

	if(requested_personality && (isobserver(user) || user.is_holding(src)))
		. += span_notice("Current consciousness seed: \"[requested_personality]\"")
	. += span_boldnotice("Alt-click to set a consciousness seed, specifying what [src] will be used for. This can help generate a personality interested in that role.")

/obj/item/brain_processor/positronic/click_alt(mob/living/user)
	var/input_seed = tgui_input_text(user, "Enter a personality seed:", "Enter seed", html_decode(requested_personality), max_length = MAX_NAME_LEN)

	if(!user.can_perform_action(src) || isnull(input_seed))
		return CLICK_ACTION_BLOCKING

	if(!input_seed)
		to_chat(user, span_notice("You clear the personality seed."))
		requested_personality = null
	else
		to_chat(user, span_notice("You set the personality seed to \"[input_seed]\"."))
		requested_personality = input_seed

	return CLICK_ACTION_SUCCESS

/obj/item/brain_processor/positronic/attack_self(mob/user)
	if(is_occupied())
		balloon_alert(user, "already active!")
		return
	if(is_searching())
		balloon_alert(user, "already searching!")
		return
	if(!(GLOB.ghost_role_flags & GHOSTROLE_SILICONS))
		to_chat(user, span_warning("Central Command has outlawed posibrain sentience in this sector."))
		return

	to_chat(user, span_notice("You press the manual activation button and start [src]'s boot process."))
	start_requesting_ghost()

/obj/item/brain_processor/positronic/attack_ghost(mob/user)
	if(is_occupied())
		return
	if(LAZYACCESS(ckeys_entered, user.ckey))
		to_chat(user, span_warning("You cannot re-enter [src] a second time!"))
		return

	if(is_banned_from(user.ckey, ROLE_POSIBRAIN))
		to_chat(user, span_warning("You are currently [span_bold("BANNED")] from playing as [ROLE_POSIBRAIN]!"))
		return
	if(QDELETED(src) || QDELETED(user)) // is_banned_from is a sleeping proc
		return

	var/posi_ask = tgui_alert(user, "Become \a [initial(name)]?\nYou will longer be revivable and all past lives will be forgotten!", "Confirm", list("Yes","No"))
	if(posi_ask != "Yes" || QDELETED(src) || QDELETED(user))
		return
	if(is_occupied()) // check one more time...
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(tgui_alert), user, "[src] was possessed before you could confirm.", "Too late", list(pick("Dang", "Aw shucks", "Aww", ":(")))
		return

	// now insert the ghost
	insert_ghost(user)
	var/policy = get_policy(ROLE_POSIBRAIN)
	if(policy)
		to_chat(brainmob, policy)

	stop_requesting_ghost()
	visible_message(span_notice("[src] pings as [p_their()] lights start flashing!"), null, span_hear("You hear something make a \"ping\" sound."))
	playsound(src, 'sound/machines/ping.ogg', 15, TRUE)

/// Notify ghosts that the posibrain is up for grabs.
/obj/item/brain_processor/positronic/proc/ping_ghosts(msg, forced)
	SHOULD_NOT_OVERRIDE(TRUE)
	PRIVATE_PROC(TRUE)

	var/should_nag = !forced && COOLDOWN_FINISHED(src, ghost_nag_cooldown)

	notify_ghosts(
		"[name] [msg] in [get_area(src)]! [requested_personality ? "Personality requested: \[[requested_personality]\]" : ""]",
		source = src,
		header = "Ghost in the Machine",
		click_interact = TRUE,
		ghost_sound = should_nag ? 'sound/effects/ghost2.ogg' : null,
		ignore_key = POLL_IGNORE_POSIBRAIN,
		notify_flags = (GHOST_NOTIFY_IGNORE_MAPLOAD),
		notify_volume = 75,
	)

	if(should_nag)
		COOLDOWN_START(src, ghost_nag_cooldown, POSIBRAIN_NAG_COOLDOWN)

/// Sends out a request for a ghost to possess this posibrain.
/obj/item/brain_processor/positronic/proc/start_requesting_ghost()
	SHOULD_NOT_OVERRIDE(TRUE)
	PROTECTED_PROC(TRUE)

	ghost_ping_timer = addtimer(CALLBACK(src, PROC_REF(stop_requesting_ghost)), POSIBRAIN_NAG_COOLDOWN, TIMER_STOPPABLE)
	update_appearance(UPDATE_ICON)

	ping_ghosts("requested", FALSE)

/obj/item/brain_processor/positronic/proc/stop_requesting_ghost()
	SHOULD_NOT_OVERRIDE(TRUE)
	PRIVATE_PROC(TRUE)

	deltimer(ghost_ping_timer)
	ghost_ping_timer = null
	update_appearance(UPDATE_ICON)

	if(!brainmob.ckey) // not an ideal spot for this but it works...
		visible_message(span_notice("[src]'s lights fade away as [p_they()] slowly turn[p_s()] dormant..."))

/// Forces a ghost into the posibrain.
/obj/item/brain_processor/positronic/proc/insert_ghost(mob/dead/observer/user)
	set_suicide(FALSE) // the old occupant may have suicided
	brainmob.set_stat(STABLE)

	// Note that if we are currently possessed you will send the old ghost back to the lobby (and kick them if still logged in)
	brainmob.PossessByPlayer(user.ckey) // inits our mind if relevant
	brainmob.mind.set_assigned_role(SSjob.get_job_type(posibrain_job_path))

	LAZYSET(ckeys_entered, brainmob.ckey, TRUE)

/obj/item/brain_processor/positronic/proc/is_occupied()
	if(brainmob.key)
		return TRUE
	if(astype(loc, /mob/living/silicon/robot)?.mmi == src)
		return TRUE
	return FALSE

/obj/item/brain_processor/positronic/proc/is_searching()
	return !!ghost_ping_timer // lol

/obj/item/brain_processor/positronic/transfer_identity(mob/living/transferred_user)
	. = ..()
	// this is a little awkward...
	transferred_user.mind.set_assigned_role(SSjob.get_job_type(posibrain_job_path))
	transferred_user.mind.remove_all_antag_datums()
	transferred_user.mind.wipe_memory()
	update_appearance(UPDATE_ICON)

/obj/item/brain_processor/positronic/display
	name = "display positronic brain"
	desc = "A small positronic brain that doesn't allow the downloading of personalities."

/obj/item/brain_processor/positronic/display/is_occupied()
	return TRUE

/// Posibrains but spherical. They can roll around and you can kick them
/obj/item/brain_processor/positronic/sphere
	name = "positronic sphere"
	desc = "Recent developments on cost-cutting measures have allowed us to cut positronic brain cubes into twice-as-cheap spheres. \
	Unfortunately, it also allows them to move around the lab via rolling maneuvers."
	icon_state = "spheribrain"
	base_icon_state = "spheribrain"
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 4.2, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 3.2, /datum/material/gold = SMALL_MATERIAL_AMOUNT * 2.5)
	/// Delay between movements
	var/move_delay = 0.5 SECONDS
	/// when can we move again?
	var/can_move

/obj/item/brain_processor/positronic/sphere/Initialize(mapload, autoping)
	. = ..()

	var/matrix/matrix = matrix()
	transform = matrix.Scale(0.8, 0.8)

/obj/item/brain_processor/positronic/sphere/relaymove(mob/living/user, direction)
	if(isspaceturf(loc) || !direction)
		return

	if(can_move >= world.time)
		return
	can_move = world.time + move_delay

	// ESCAPE PRISON
	if(istype(loc, /obj/item/storage) && prob(25))
		var/obj/item/item = pick(loc.contents)
		item.forceMove(loc.drop_location()) //throw stuff out of the inventory till we free ourselves!
		playsound(src, SFX_RUSTLE, 30, TRUE)
		return

	// MOVE US
	if(isturf(loc))
		can_move = world.time + move_delay
		try_step_multiz(direction)
		SpinAnimation(move_delay, 1, direction == NORTH || direction == EAST)

/obj/item/brain_processor/positronic/sphere/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(brainmob && isturf(loc))
		anchored = TRUE //anchor so we dont broom ourselves.
		do_sweep(src, brainmob, loc, get_dir(old_loc, loc)) //movement dir doesnt work on objects
		anchored = FALSE

/// Punt the shit across the room
/obj/item/brain_processor/positronic/sphere/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return .
	throw_at(get_edge_target_turf(src, get_dir(user, src)), 7, 1, user)
	user.do_attack_animation(src)
	can_move = world.time + move_delay //pweeze stawp
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

#undef POSIBRAIN_NAG_COOLDOWN
