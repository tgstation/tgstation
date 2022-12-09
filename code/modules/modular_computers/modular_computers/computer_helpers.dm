/**
 * computer_helpers.dm
 *
 * Helper functions for our modular computer. All of these are useful for writing computer programs.
 */

/**
 * Relays an update_appearance to the icon of our physical atom.
 * You really want to use this instead of `physical.update_appearance()`.
 */
/datum/modular_computer_host/proc/relay_appearance_update(updates = ALL)
	physical.update_appearance(updates)

/**
 * Displays notification text alongside a soundbeep when requested to by a program.
 *
 * After checking that the requesting program is allowed to send an alert, creates
 * a visible message of the requested text alongside a soundbeep. This proc adds
 * text to indicate that the message is coming from this device and the program
 * on it, so the supplied text should be the exact message and ending punctuation.
 *
 * Arguments:
 * The program calling this proc.
 * The message that the program wishes to display.
 */
/datum/modular_computer_host/proc/alert_call(datum/computer_file/program/caller, alerttext, sound = 'sound/machines/twobeep_high.ogg')
	if(!caller || !caller.alert_able || caller.alert_silenced || !alerttext) //Yeah, we're checking alert_able. No, you don't get to make alerts that the user can't silence.
		return FALSE
	playsound(physical, sound, 50, TRUE)
	visible_message(span_notice("[icon2html(physical)] [span_notice("The [physical] displays a [caller.filedesc] notification: [alerttext]")]"))


/datum/modular_computer_host/proc/send_sound()
	playsound(physical, 'sound/machines/terminal_success.ogg', 15, TRUE)

/datum/modular_computer_host/proc/set_flashlight_color(color)
	return FALSE

/datum/modular_computer_host/proc/toggle_flashlight()
	return FALSE

/**
 * Display an audible message in chat, forwards visible_message to our holder.
 * This proc is a simpler implementation to [atom/visible_message].
 * Args:
 * message - The message to be displayed
 * sender - The program that sent this message
 * range - Visible range of the message
 */

/datum/modular_computer_host/proc/audible_message(message, datum/computer_file/sender, range = DEFAULT_MESSAGE_RANGE)
	physical.audible_message(message, hearing_distance = range)

/**
 * Display a visible message in chat, forwards visible_message to our holder.
 * This proc is a simpler implementation to [atom/visible_message].
 * Args:
 * message - The message to be displayed
 * sender - The program that sent this message
 * range - Visible range of the message
 */

/datum/modular_computer_host/proc/visible_message(message, datum/computer_file/sender, range = DEFAULT_MESSAGE_RANGE)
	physical.visible_message(message, vision_distance = range)

/**
 * Will attempt to make our holder say something, if it even is an object.
 * Args:
 * message - The message to be said
 * sender - The program that sent this message
 */
/datum/modular_computer_host/proc/say(message, datum/computer_file/sender)
	if(!isobj(physical))
		return
	var/obj/holder_object = physical
	holder_object.say(message)

/**
 * Attempt to insert the ID in either card slot.
 * Args:
 * inserting_id - the ID being inserted
 * user - The person inserting the ID
 */
/datum/modular_computer_host/proc/insert_card(obj/item/card/inserting_id, mob/user)
	//all slots taken
	if(inserted_id)
		return FALSE

	if(user)
		if(!user.transferItemToLoc(inserting_id, physical))
			return FALSE
		user.balloon_alert(user, "inserted id")
		to_chat(user, span_notice("You insert \the [inserting_id] into the card slot."))
	else
		inserting_id.forceMove(physical)

	inserted_id = inserting_id

	playsound(physical, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
	if(ishuman(user))
		var/mob/living/carbon/human/human_wearer = user
		if(human_wearer.wear_id == physical)
			human_wearer.sec_hud_set_ID()
	return TRUE

/**
 * Removes the ID card from the computer, and puts it in loc's hand if it's a mob
 * Args:
 * user - The mob trying to remove the ID, if there is one
 */
/datum/modular_computer_host/proc/remove_card(mob/user)
	if(user)
		if(!issilicon(user) && in_range(physical, user))
			user.put_in_hands(inserted_id)
		physical.balloon_alert(user, "removed ID")
		to_chat(user, span_notice("You remove the card from the card slot."))
	else
		inserted_id.forceMove(physical.drop_location())

	inserted_id = null
	playsound(physical, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)

	if(ishuman(user))
		var/mob/living/carbon/human/human_wearer = user
		if(human_wearer.wear_id == physical)
			human_wearer.sec_hud_set_ID()

	relay_appearance_update()

///Inserts a disk if we don't already have a disk
/datum/modular_computer_host/proc/insert_disk(mob/user, obj/item/computer_disk/disk)
	if(!isnull(inserted_disk))
		return FALSE
	if(!istype(user))
		disk.forceMove(physical)
		return TRUE

	return user.transferItemToLoc(disk, physical)

///Takes out the disk if we have one stored and returns TRUE, FALSE if we did not have a disk.
/datum/modular_computer_host/proc/remove_disk(mob/user)
	if(!inserted_disk)
		return FALSE
	user.put_in_hands(inserted_disk)
	return TRUE

///Returns 0 for No Signal, 1 for Low Signal and 2 for Good Signal. 3 is for wired connection (always-on)
/datum/modular_computer_host/proc/get_ntnet_status(specific_action = 0)
	if(!SSmodular_computers.check_function(specific_action)) // NTNet is down and we are not connected via wired connection. No signal.
		return NTNET_NO_SIGNAL

	// computers are connected through ethernet
	if(hardware_flag & PROGRAM_CONSOLE)
		return NTNET_ETHERNET_SIGNAL

	var/turf/current_turf = get_turf(physical)
	if(!current_turf || !istype(current_turf))
		return NTNET_NO_SIGNAL
	if(is_station_level(current_turf.z))
		if(hardware_flag & PROGRAM_LAPTOP) //laptops can connect to ethernet but they have to be on station for that
			return NTNET_ETHERNET_SIGNAL
		return NTNET_GOOD_SIGNAL
	else if(is_mining_level(current_turf.z))
		return NTNET_LOW_SIGNAL
	else if(ntnet_bypass_rangelimit)
		return NTNET_LOW_SIGNAL
	return NTNET_NO_SIGNAL

///Wipes the computer's current program. Doesn't handle any of the niceties around doing this
/datum/modular_computer_host/proc/wipe_program(forced)
	if(!active_program)
		return
	active_program.kill_program(forced)
	active_program = null
	relay_appearance_update(UPDATE_ICON)

///Relays kill program request to currently active program. Use this to quit current program.
/datum/modular_computer_host/proc/kill_program(forced = FALSE)
	wipe_program(forced)
	var/mob/user = usr
	if(user && istype(user))
		//Here to prevent programs sleeping in destroy
		INVOKE_ASYNC(src, TYPE_PROC_REF(/datum, ui_interact), user) // Re-open the UI on this computer. It should show the main screen now.

/**
 * App
 */

/datum/modular_computer_host/proc/open_program(mob/user, datum/computer_file/program/program)
	if(program.computer != src)
		CRASH("tried to open program that does not belong to this computer")

	if(!program || !istype(program)) // Program not found or it's not executable program.
		to_chat(user, span_danger("\The [physical]'s screen shows \"I/O ERROR - Unable to run program\" warning."))
		return FALSE

	// The program is already running. Resume it.
	if(program in idle_threads)
		program.program_state = PROGRAM_STATE_ACTIVE
		active_program = program
		program.alert_pending = FALSE
		LAZYREMOVE(idle_threads, program)
		return TRUE

	if(!program.is_supported_by_hardware(hardware_flag, 1, user))
		return FALSE

	if(idle_threads.len > max_idle_programs)
		to_chat(user, span_danger("\The [physical] displays a \"Maximal CPU load reached. Unable to run another program.\" error."))
		return FALSE

	if(program.requires_ntnet && !get_ntnet_status(program.requires_ntnet_feature)) // The program requires NTNet connection, but we are not connected to NTNet.
		to_chat(user, span_danger("\The [physical]'s screen shows \"Unable to connect to NTNet. Please retry. If problem persists contact your system administrator.\" warning."))
		return FALSE

	if(!program.on_start(user))
		return FALSE

	active_program = program
	program.alert_pending = FALSE

	relay_appearance_update(UPDATE_ICON)

	return TRUE

/datum/modular_computer_host/proc/turn_on(mob/user, open_ui = TRUE)
	var/issynth = issilicon(user) // Robots and AIs get different activation messages.
	if(nonfunctional)
		if(issynth)
			to_chat(user, span_warning("You send an activation signal to \the [physical], but it responds with an error code. It must be damaged."))
		else
			to_chat(user, span_warning("You press the power button, but the computer fails to boot up, displaying variety of errors before shutting down again."))
		return FALSE

	if(use_power()) // use_power() checks if the PC is powered
		if(issynth)
			to_chat(user, span_notice("You send an activation signal to \the [physical], turning it on."))
		else
			to_chat(user, span_notice("You press the power button and start up \the [physical]."))
		if(looping_sound)
			soundloop.start()
		powered_on = TRUE
		if(open_ui)
			ui_interact(user)
		relay_appearance_update(UPDATE_ICON)
		return TRUE
	else // Unpowered
		if(issynth)
			to_chat(user, span_warning("You send an activation signal to \the [physical] but it does not respond."))
		else
			to_chat(user, span_warning("You press the power button but \the [physical] does not respond."))
		return FALSE

/datum/modular_computer_host/proc/turn_off(loud = TRUE)
	kill_program(forced = TRUE)
	for(var/datum/computer_file/program/P in idle_threads)
		P.kill_program(forced = TRUE)
	if(looping_sound)
		soundloop.stop()
	if(physical && loud)
		physical.visible_message(span_notice("\The [physical] shuts down."))
	powered_on = FALSE
	relay_appearance_update()

/datum/modular_computer_host/proc/print_text(text_to_print, paper_title = "")
	if(!stored_paper)
		return FALSE

	var/obj/item/paper/printed_paper = new /obj/item/paper(physical.drop_location())
	printed_paper.add_raw_text(text_to_print)
	if(paper_title)
		printed_paper.name = paper_title
	printed_paper.update_appearance()
	stored_paper--
	return TRUE
