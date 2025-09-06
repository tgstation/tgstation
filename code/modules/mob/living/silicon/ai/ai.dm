#define HOLOGRAM_CHOICE_CHARACTER "Existing Character"
#define CHARACTER_TYPE_SELF "My Character"
#define CHARACTER_TYPE_CREWMEMBER "Station Member"

/mob/living/silicon/ai/Initialize(mapload, datum/ai_laws/L, mob/target_ai)
	. = ..()
	if(!target_ai) //If there is no player/brain inside.
		new/obj/structure/ai_core/deactivated(loc) //New empty terminal.
		return INITIALIZE_HINT_QDEL //Delete AI.

	ADD_TRAIT(src, TRAIT_NO_TELEPORT, AI_ANCHOR_TRAIT)
	status_flags &= ~CANPUSH //AI starts anchored, so dont push it

	if(L && istype(L, /datum/ai_laws))
		laws = L
		laws.associate(src)
		for (var/law in laws.inherent)
			lawcheck += law
	else
		make_laws()
		for (var/law in laws.inherent)
			lawcheck += law

	create_eye()

	if((target_ai.mind && target_ai.mind.active) || SSticker.current_state == GAME_STATE_SETTING_UP)
		target_ai.mind.transfer_to(src)
		if(is_antag())
			to_chat(src, span_userdanger("You have been installed as an AI! "))
			to_chat(src, span_danger("You must obey your silicon laws above all else. Your objectives will consider you to be dead."))
		if(!mind.has_ever_been_ai)
			mind.has_ever_been_ai = TRUE
	else if(target_ai.key)
		key = target_ai.key

	to_chat(src, span_bold("You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras)."))
	to_chat(src, span_bold("To look at other parts of the station, click on yourself to get a camera menu."))
	to_chat(src, span_bold("While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc."))
	to_chat(src, "To use something, simply click on it.")
	to_chat(src, "For department channels, use the following say commands:")
	to_chat(src, ":o - AI Private, :c - Command, :s - Security, :e - Engineering, :u - Supply, :v - Service, :m - Medical, :n - Science, :h - Holopad.")
	show_laws()
	to_chat(src, span_bold("These laws may be changed by other players, random events, or by you becoming malfunctioning."))

	job = "AI"

	create_modularInterface()

	// /mob/living/silicon/ai/apply_prefs_job() uses these to set these procs at mapload
	// this is used when a person is being inserted into an AI core during a round
	if(client)
		INVOKE_ASYNC(src, PROC_REF(apply_pref_name), /datum/preference/name/ai, client)
		INVOKE_ASYNC(src, PROC_REF(apply_pref_hologram_display), client)
		set_gender(client)

	INVOKE_ASYNC(src, PROC_REF(set_core_display_icon))

	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	add_verb(src, /mob/living/silicon/ai/proc/show_laws_verb)

	aiMulti = new(src)
	aicamera = new/obj/item/camera/siliconcam/ai_camera(src)

	deploy_action.Grant(src)

	if(isturf(loc))
		add_verb(src, list(
			/mob/living/silicon/ai/proc/ai_network_change,
			/mob/living/silicon/ai/proc/ai_hologram_change,
			/mob/living/silicon/ai/proc/botcall,
			/mob/living/silicon/ai/proc/control_integrated_radio,
			/mob/living/silicon/ai/proc/set_automatic_say_channel,
		))

	GLOB.ai_list += src
	GLOB.shuttle_caller_list += src

	//They aren't given a c_tag so they don't show up in camera consoles
	builtInCamera = new(src)

	ai_tracking_tool = new(src)
	RegisterSignal(ai_tracking_tool, COMSIG_TRACKABLE_TRACKING_TARGET, PROC_REF(on_track_target))
	RegisterSignal(ai_tracking_tool, COMSIG_TRACKABLE_GLIDE_CHANGED, PROC_REF(tracked_glidesize_changed))

	add_traits(list(TRAIT_PULL_BLOCKED, TRAIT_AI_ACCESS, TRAIT_HANDS_BLOCKED, TRAIT_CAN_GET_AI_TRACKING_MESSAGE, TRAIT_LOUD_BINARY), INNATE_TRAIT)

	alert_control = new(src, list(ALARM_ATMOS, ALARM_FIRE, ALARM_POWER, ALARM_CAMERA, ALARM_BURGLAR, ALARM_MOTION), list(z), camera_view = TRUE)
	RegisterSignal(alert_control.listener, COMSIG_ALARM_LISTENER_TRIGGERED, PROC_REF(alarm_triggered))
	RegisterSignal(alert_control.listener, COMSIG_ALARM_LISTENER_CLEARED, PROC_REF(alarm_cleared))

	//Heads up to other binary chat listeners that a new AI is online and listening to Binary.
	if(announce_init_to_others && !is_centcom_level(z)) //Skip new syndicate AIs and also new AIs on centcom Z
		for(var/mob/McMobby as anything in GLOB.player_list)
			if(McMobby == src)
				continue
			if(!McMobby.binarycheck())
				continue
			to_chat(McMobby,span_binarysay("<span class=[SPAN_COMMAND]>\[ SYSTEM \] NEW REMOTE HOST HAS CONNECTED TO THIS CHANNEL -- ID: [src]</span>"), type = MESSAGE_TYPE_RADIO)

/mob/living/silicon/ai/weak_syndie
	radio = /obj/item/radio/headset/silicon/ai/evil
	radio_enabled = TRUE
	interaction_range = 1
	sprint = 5
	announce_init_to_others = FALSE

/mob/living/silicon/ai/key_down(_key, client/user)
	if(findtext(_key, "numpad")) //if it's a numpad number, we can convert it to just the number
		_key = _key[7] //strings, lists, same thing really
	switch(_key)
		if("`", "0")
			if(cam_prev)
				ai_tracking_tool.reset_tracking()
				eyeobj.setLoc(cam_prev)
			return
		if("1", "2", "3", "4", "5", "6", "7", "8", "9")
			_key = text2num(_key)
			if(user.keys_held["Ctrl"]) //do we assign a new hotkey?
				cam_hotkeys[_key] = eyeobj.loc
				to_chat(src, "Location saved to Camera Group [_key].")
				return
			if(cam_hotkeys[_key]) //if this is false, no hotkey for this slot exists.
				cam_prev = eyeobj.loc
				ai_tracking_tool.reset_tracking()
				eyeobj.setLoc(cam_hotkeys[_key])
				return
	return ..()

/mob/living/silicon/ai/Destroy()
	GLOB.ai_list -= src
	GLOB.shuttle_caller_list -= src
	SSshuttle.autoEvac()
	QDEL_NULL(eyeobj) // No AI, no Eye
	QDEL_NULL(spark_system)
	QDEL_NULL(malf_picker)
	QDEL_NULL(doomsday_device)
	QDEL_NULL(robot_control)
	QDEL_NULL(aiMulti)
	QDEL_NULL(alert_control)
	QDEL_NULL(ai_tracking_tool)
	malfhack = null
	current = null
	bot_ref = null
	controlled_equipment = null
	linked_core = null
	apc_override = null
	if(ai_voicechanger)
		ai_voicechanger.owner = null
		ai_voicechanger = null
	return ..()

/// Removes all malfunction-related abilities from the AI
/mob/living/silicon/ai/proc/remove_malf_abilities()
	QDEL_NULL(modules_action)
	for(var/datum/ai_module/malf/AM in current_modules)
		for(var/datum/action/A in actions)
			if(istype(A, initial(AM.power_type)))
				qdel(A)

/mob/living/silicon/ai/ignite_mob(silent)
	return FALSE

/mob/living/silicon/ai/proc/set_core_display_icon(input, client/C)
	if(client && !C)
		C = client
	if(!input && !C?.prefs?.read_preference(/datum/preference/choiced/ai_core_display))
		icon_state = initial(icon_state)
	else
		var/preferred_icon = input ? input : C.prefs.read_preference(/datum/preference/choiced/ai_core_display)
		icon_state = resolve_ai_icon(preferred_icon)

/// Apply an AI's hologram preference
/mob/living/silicon/ai/proc/apply_pref_hologram_display(client/player_client)
	if(player_client.prefs?.read_preference(/datum/preference/choiced/ai_hologram_display))
		var/list/hologram_choice = player_client.prefs.read_preference(/datum/preference/choiced/ai_hologram_display)
		if(hologram_choice == "Random")
			hologram_choice = pick(GLOB.ai_hologram_icons)

		hologram_appearance = mutable_appearance(GLOB.ai_hologram_icons[hologram_choice], GLOB.ai_hologram_icon_state[hologram_choice])

	hologram_appearance ||= mutable_appearance(GLOB.ai_hologram_icons[AI_HOLOGRAM_DEFAULT], GLOB.ai_hologram_icon_state[AI_HOLOGRAM_DEFAULT])

/// Apply an AI's emote display preference
/mob/living/silicon/ai/proc/apply_pref_emote_display(client/player_client)
	if(player_client.prefs?.read_preference(/datum/preference/choiced/ai_emote_display))
		var/emote_choice = player_client.prefs.read_preference(/datum/preference/choiced/ai_emote_display)

		if(emote_choice == "Random")
			emote_choice = pick(GLOB.ai_status_display_emotes)

		apply_emote_display(emote_choice)

/// Apply an emote to all AI status displays on the station
/mob/living/silicon/ai/proc/apply_emote_display(emote)
	for(var/obj/machinery/status_display/ai/ai_display as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/status_display/ai))
		ai_display.emotion = emote
		ai_display.update()

/mob/living/silicon/ai/verb/pick_icon()
	set category = "AI Commands"
	set name = "Set AI Core Display"
	if(incapacitated)
		return
	icon = initial(icon)
	icon_state = "ai"
	cut_overlays()
	var/list/iconstates = GLOB.ai_core_display_screens
	for(var/option in iconstates)
		if(option == "Random")
			iconstates[option] = image(icon = src.icon, icon_state = "ai-random")
			continue
		if(option == "Portrait")
			iconstates[option] = image(icon = src.icon, icon_state = "ai-portrait")
			continue
		iconstates[option] = image(icon = src.icon, icon_state = resolve_ai_icon(option))

	view_core()
	var/ai_core_icon = show_radial_menu(src, src , iconstates, radius = 42)

	if(!ai_core_icon || incapacitated)
		return

	display_icon_override = ai_core_icon
	set_core_display_icon(ai_core_icon)

/mob/living/silicon/ai/get_status_tab_items()
	. = ..()
	if(stat != CONSCIOUS)
		. += "Systems nonfunctional"
		return
	. += "System integrity: [(health + 100) * 0.5]%"
	if(isturf(loc)) //only show if we're "in" a core
		. += "Backup Power: [battery * 0.5]%"
	. += "Connected cyborgs: [length(connected_robots)]"
	for(var/r in connected_robots)
		var/mob/living/silicon/robot/connected_robot = r
		var/robot_status = "Nominal"
		if(connected_robot.shell)
			robot_status = "AI SHELL"
		else if(connected_robot.stat != CONSCIOUS || !connected_robot.client)
			robot_status = "OFFLINE"
		else if(!connected_robot.cell || connected_robot.cell.charge <= 0)
			robot_status = "DEPOWERED"
		//Name, Health, Battery, Model, Area, and Status! Everything an AI wants to know about its borgies!
		. += list(list("[connected_robot.name]: ",
			"S.Integrity: [connected_robot.health]% | \
			Cell: [connected_robot.cell ? "[display_energy(connected_robot.cell.charge)]/[display_energy(connected_robot.cell.maxcharge)]" : "Empty"] | \
			Model: [connected_robot.designation] | Loc: [get_area_name(connected_robot, TRUE)] | \
			Status: [robot_status]",
			"src=[REF(src)];track_cyborg=[text_ref(connected_robot)]",
		))
	. += "AI shell beacons detected: [LAZYLEN(GLOB.available_ai_shells)]" //Count of total AI shells

/mob/living/silicon/ai/proc/ai_call_shuttle()
	if(control_disabled)
		to_chat(usr, span_warning("Wireless control is disabled!"))
		return

	var/can_evac_or_fail_reason = SSshuttle.canEvac()
	if(can_evac_or_fail_reason != TRUE)
		to_chat(usr, span_alert("[can_evac_or_fail_reason]"))
		return

	var/reason = tgui_input_text(
		src,
		"What is the nature of your emergency? ([CALL_SHUTTLE_REASON_LENGTH] characters required.)",
		"Confirm Shuttle Call",
		max_length = MAX_MESSAGE_LEN,
		encode = FALSE,
	)

	if(incapacitated)
		return

	if(trim(reason))
		SSshuttle.requestEvac(src, reason)

	// hack to display shuttle timer
	if(!EMERGENCY_IDLE_OR_RECALLED)
		for(var/obj/machinery/computer/communications/C in GLOB.shuttle_caller_list)
			C.post_status("shuttle")

/mob/living/silicon/ai/can_interact_with(atom/A, treat_mob_as_adjacent)
	. = ..()
	if (.)
		return
	var/turf/ai_turf = get_turf(src)
	var/turf/target_turf = get_turf(A)

	if(!target_turf)
		return

	if (!is_valid_z_level(ai_turf, target_turf))
		return FALSE

	if (istype(loc, /obj/item/aicard))
		if (!ai_turf)
			return FALSE
		return ISINRANGE(target_turf.x, ai_turf.x - interaction_range, ai_turf.x + interaction_range) \
			&& ISINRANGE(target_turf.y, ai_turf.y - interaction_range, ai_turf.y + interaction_range)
	else
		return GLOB.cameranet.checkTurfVis(target_turf)

/mob/living/silicon/ai/cancel_camera()
	view_core()

/mob/living/silicon/ai/verb/ai_camera_track()
	set name = "track"
	set hidden = TRUE //Don't display it on the verb lists. This verb exists purely so you can type "track Oldman Robustin" and follow his ass

	ai_tracking_tool.track_input(src)

///Called when an AI finds their tracking target.
/mob/living/silicon/ai/proc/on_track_target(datum/trackable/source, mob/living/target)
	SIGNAL_HANDLER
	if(eyeobj)
		eyeobj.setLoc(get_turf(target))
	else
		view_core()

/// Keeps our rate of gliding in step with the mob we're following
/mob/living/silicon/ai/proc/tracked_glidesize_changed(datum/trackable/source, mob/living/target, new_glide_size)
	SIGNAL_HANDLER
	if(eyeobj)
		eyeobj.glide_size = new_glide_size

/mob/living/silicon/ai/verb/toggle_anchor()
	set category = "AI Commands"
	set name = "Toggle Floor Bolts"
	if(!isturf(loc)) // if their location isn't a turf
		return // stop
	if(stat == DEAD)
		return
	if(incapacitated)
		if(battery < 50)
			to_chat(src, span_warning("Insufficient backup power!"))
			return
		battery = battery - 50
		to_chat(src, span_notice("You route power from your backup battery to move the bolts."))
	flip_anchored()
	to_chat(src, "<b>You are now [is_anchored ? "" : "un"]anchored.</b>")

/mob/living/silicon/ai/proc/flip_anchored()
	if(is_anchored)
		is_anchored = !is_anchored
		move_resist = MOVE_FORCE_NORMAL
		status_flags |= CANPUSH //we want the core to be push-able when un-anchored
		REMOVE_TRAIT(src, TRAIT_NO_TELEPORT, AI_ANCHOR_TRAIT)
	else
		is_anchored = !is_anchored
		move_resist = MOVE_FORCE_OVERPOWERING
		status_flags &= ~CANPUSH //we dont want the core to be push-able when anchored
		ADD_TRAIT(src, TRAIT_NO_TELEPORT, AI_ANCHOR_TRAIT)

/mob/living/silicon/ai/proc/ai_mob_to_structure()
	disconnect_shell()
	ShutOffDoomsdayDevice()
	var/obj/structure/ai_core/deactivated/ai_core = new(get_turf(src), /* skip_mmi_creation = */ TRUE)
	if(make_mmi_drop_and_transfer(ai_core.core_mmi, the_core = ai_core))
		qdel(src)
	return ai_core

/mob/living/silicon/ai/proc/break_core_link()
	to_chat(src, span_danger("Your core has been destroyed!"))
	linked_core = null

/mob/living/silicon/ai/proc/make_mmi_drop_and_transfer(obj/item/mmi/the_mmi, the_core)
	var/mmi_type
	if(posibrain_inside)
		mmi_type = new/obj/item/mmi/posibrain(src, /* autoping = */ FALSE)
	else
		mmi_type = new/obj/item/mmi(src)
	if(hack_software)
		new/obj/item/malf_upgrade(get_turf(src))
	the_mmi = mmi_type
	the_mmi.brain = new /obj/item/organ/brain(the_mmi)
	the_mmi.brain.organ_flags |= ORGAN_FROZEN
	the_mmi.brain.name = "[real_name]'s brain"
	the_mmi.name = "[initial(the_mmi.name)]: [real_name]"
	the_mmi.set_brainmob(new /mob/living/brain(the_mmi))
	the_mmi.brainmob.name = src.real_name
	the_mmi.brainmob.real_name = src.real_name
	the_mmi.brainmob.container = the_mmi
	the_mmi.brainmob.gender = src.gender

	var/has_suicided_trait = HAS_TRAIT(src, TRAIT_SUICIDED)
	the_mmi.brainmob.set_suicide(has_suicided_trait)
	the_mmi.brain.suicided = has_suicided_trait
	if(the_core)
		var/obj/structure/ai_core/core = the_core
		core.core_mmi = the_mmi
		the_mmi.forceMove(the_core)
	else
		the_mmi.forceMove(get_turf(src))
	if(the_mmi.brainmob.stat == DEAD && !has_suicided_trait)
		the_mmi.brainmob.set_stat(CONSCIOUS)
	if(mind)
		mind.transfer_to(the_mmi.brainmob)
	the_mmi.update_appearance()
	return TRUE

/mob/living/silicon/ai/Topic(href, href_list)
	..()
	if(usr != src)
		return

	if(href_list["track_cyborg"])
		var/mob/living/silicon/robot/cyborg = locate(href_list["track_cyborg"]) in connected_robots
		if(!cyborg)
			return
		ai_tracking_tool.set_tracked_mob(cyborg)

	if(href_list["emergencyAPC"]) //This check comes before incapacitated because the only time it would be useful is when we have no power.
		if(!apc_override)
			to_chat(src, span_notice("APC backdoor is no longer available."))
			return
		apc_override.ui_interact(src)
		return

	if(incapacitated)
		return

	if (href_list["switchcamera"])
		switchCamera(locate(href_list["switchcamera"]) in GLOB.cameranet.cameras)
	if (href_list["showalerts"])
		alert_control.ui_interact(src)
#ifdef AI_VOX
	if(href_list["say_word"])
		play_vox_word(href_list["say_word"], null, src)
		return
#endif
	if(href_list["show_tablet_note"])
		if(last_tablet_note_seen)
			src << browse(last_tablet_note_seen, "window=show_tablet")
	//Carn: holopad requests
	if(href_list["jump_to_holopad"])
		var/obj/machinery/holopad/Holopad = locate(href_list["jump_to_holopad"]) in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/holopad)
		if(Holopad)
			cam_prev = get_turf(eyeobj)
			eyeobj.setLoc(Holopad)
		else
			to_chat(src, span_notice("Unable to locate the holopad."))
	if(href_list["project_to_holopad"])
		var/obj/machinery/holopad/Holopad = locate(href_list["project_to_holopad"]) in SSmachines.get_machines_by_type(/obj/machinery/holopad)
		if(Holopad)
			lastloc = get_turf(eyeobj)
			Holopad.attack_ai_secondary(src) //may as well recycle
		else
			to_chat(src, span_notice("Unable to project to the holopad."))
	if (href_list["ai_take_control"]) //Mech domination
		var/obj/vehicle/sealed/mecha/M = locate(href_list["ai_take_control"]) in GLOB.mechas_list
		if (!M)
			return

		var/mech_has_controlbeacon = FALSE
		for(var/obj/item/mecha_parts/mecha_tracking/ai_control/A in M.trackers)
			mech_has_controlbeacon = TRUE
			break
		if(!can_dominate_mechs && !mech_has_controlbeacon)
			message_admins("Warning: possible href exploit by [key_name(usr)] - attempted control of a mecha without can_dominate_mechs or a control beacon in the mech.")
			usr.log_message("possibly attempting href exploit - attempted control of a mecha without can_dominate_mechs or a control beacon in the mech.", LOG_ADMIN)
			return

		if(controlled_equipment)
			to_chat(src, span_warning("You are already loaded into an onboard computer!"))
			return
		if(!GLOB.cameranet.checkCameraVis(M))
			to_chat(src, span_warning("Exosuit is no longer near active cameras."))
			return
		if(!isturf(loc))
			to_chat(src, span_warning("You aren't in your core!"))
			return
		if(M)
			M.transfer_ai(AI_MECH_HACK, src, usr) //Called om the mech itself.
	if(href_list["show_paper_note"])
		var/obj/item/paper/paper_note = locate(href_list["show_paper_note"])
		if(!paper_note)
			return

		paper_note.show_through_camera(usr)


/mob/living/silicon/ai/proc/switchCamera(obj/machinery/camera/C)
	if(QDELETED(C))
		return FALSE

	if(QDELETED(eyeobj))
		view_core()
		return

	ai_tracking_tool.reset_tracking()

	// ok, we're alive, camera is good and in our network...
	eyeobj.setLoc(get_turf(C))
	return TRUE

/mob/living/silicon/ai/proc/botcall()
	set category = "AI Commands"
	set name = "Access Robot Control"
	set desc = "Wirelessly control various automatic robots."

	if(!robot_control)
		robot_control = new(src)

	robot_control.ui_interact(src)

/mob/living/silicon/ai/proc/set_waypoint(atom/A)
	var/turf/turf_check = get_turf(A)
		//The target must be in view of a camera or near the core.
	if(turf_check in range(get_turf(src)))
		call_bot(turf_check)
	else if(GLOB.cameranet && GLOB.cameranet.checkTurfVis(turf_check))
		call_bot(turf_check)
	else
		to_chat(src, span_danger("Selected location is not visible."))

/mob/living/silicon/ai/proc/call_bot(turf/waypoint)
	var/mob/living/bot = bot_ref?.resolve()
	if(!bot)
		return
	var/summon_success
	if(isbasicbot(bot))
		var/mob/living/basic/bot/basic_bot = bot
		summon_success = basic_bot.summon_bot(src, waypoint, grant_all_access = TRUE)
	else
		var/mob/living/simple_animal/bot/simple_bot = bot
		summon_success = simple_bot.call_bot(src, waypoint)

	var/chat_message = summon_success ? "Sending command to bot..." : "Interface error. Unit is already in use."
	to_chat(src, span_notice("[chat_message]"))

/mob/living/silicon/ai/proc/alarm_triggered(datum/source, alarm_type, area/source_area)
	SIGNAL_HANDLER
	var/list/cameras = source_area.cameras
	var/home_name = source_area.name

	if (length(cameras))
		var/obj/machinery/camera/cam = cameras[1]
		if (cam.can_use())
			queueAlarm("--- [alarm_type] alarm detected in [home_name]! (<A href=byond://?src=[REF(src)];switchcamera=[REF(cam)]>[cam.c_tag]</A>)", alarm_type)
		else
			var/first_run = FALSE
			var/dat2 = ""
			for (var/obj/machinery/camera/camera as anything in cameras)
				dat2 += "[(!first_run) ? "" : " | "]<A href=byond://?src=[REF(src)];switchcamera=[REF(camera)]>[camera.c_tag]</A>"
				first_run = TRUE
			queueAlarm("--- [alarm_type] alarm detected in [home_name]! ([dat2])", alarm_type)
	else
		queueAlarm("--- [alarm_type] alarm detected in [home_name]! (No Camera)", alarm_type)
	return 1

/mob/living/silicon/ai/proc/alarm_cleared(datum/source, alarm_type, area/source_area)
	SIGNAL_HANDLER
	queueAlarm("--- [alarm_type] alarm in [source_area.name] has been cleared.", alarm_type, 0)

//Replaces /mob/living/silicon/ai/verb/change_network() in ai.dm & camera.dm
//Adds in /mob/living/silicon/ai/proc/ai_network_change() instead
//Addition by Mord_Sith to define AI's network change ability
/mob/living/silicon/ai/proc/ai_network_change()
	set category = "AI Commands"
	set name = "Jump To Network"
	ai_tracking_tool.reset_tracking()
	var/cameralist[0]

	if(incapacitated)
		return

	var/mob/living/silicon/ai/U = usr

	for (var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		var/turf/camera_turf = get_turf(C) //get camera's turf in case it's built into something so we don't get z=0

		var/list/tempnetwork = C.network
		if(!camera_turf || !(is_station_level(camera_turf.z) || is_mining_level(camera_turf.z) || (CAMERANET_NETWORK_SS13 in tempnetwork)))
			continue
		if(!C.can_use())
			continue
		tempnetwork.Remove(CAMERANET_NETWORK_RD, CAMERANET_NETWORK_ORDNANCE, CAMERANET_NETWORK_PRISON)
		if(length(tempnetwork))
			for(var/i in C.network)
				cameralist[i] = i
	var/old_network = network
	network = tgui_input_list(U, "Which network would you like to view?", "Camera Network", sort_list(cameralist))

	if(!U.eyeobj)
		U.view_core()
		return

	if(isnull(network))
		network = old_network // If nothing is selected
	else
		for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
			if(!C.can_use())
				continue
			if(network in C.network)
				U.eyeobj.setLoc(get_turf(C))
				break
	to_chat(src, span_notice("Switched to the \"[uppertext(network)]\" camera network."))
//End of code by Mord_Sith

//I am the icon meister. Bow fefore me. //>fefore
/mob/living/silicon/ai/proc/ai_hologram_change()
	set name = "Change Hologram"
	set desc = "Change the default hologram available to AI to something else."
	set category = "AI Commands"

	if(incapacitated)
		return

	var/static/list/choices = assoc_to_keys(GLOB.ai_hologram_category_options) + HOLOGRAM_CHOICE_CHARACTER
	var/choice = tgui_input_list(usr, "What kind of hologram do you want?",	"Customize", choices)
	if(!choice)
		return

	if(choice == HOLOGRAM_CHOICE_CHARACTER)
		var/character_type = tgui_alert(usr,
			"Would you like to base it off of your current character loadout, or a crewmember on the manifest?", "Customize",
			list(CHARACTER_TYPE_CREWMEMBER, CHARACTER_TYPE_SELF)
		)
		switch(character_type)
			if(CHARACTER_TYPE_CREWMEMBER)
				var/list/personnel_list = list()

				for(var/datum/record/locked/record in GLOB.manifest.locked)//Look in data core locked.
					personnel_list["[record.name]: [record.rank]"] = record.character_appearance//Pull names, rank, and image.
				if(!length(personnel_list))
					tgui_alert(usr,"No suitable records found. Aborting.")
					return

				var/input = tgui_input_list(usr, "Select a crew member", "Station Member", sort_list(personnel_list))
				if(isnull(input))
					return
				if(isnull(personnel_list[input]))
					return
				var/mutable_appearance/character_icon = personnel_list[input]
				if(character_icon)
					character_icon.setDir(SOUTH)
					hologram_appearance = character_icon

			if(CHARACTER_TYPE_SELF)
				var/confirmation = tgui_alert(usr,
					"WARNING: Your AI hologram will take the appearance of your currently selected character \
					([usr.client.prefs?.read_preference(/datum/preference/name/real_name)]). \
					Are you sure you want to proceed?", "Customize",
					list("Yes","No")
				)
				if(confirmation == "Yes")
					var/mob/living/carbon/human/dummy/ai_dummy = new()
					var/mutable_appearance/dummy_appearance = usr.client.prefs.render_new_preview_appearance(ai_dummy)
					qdel(ai_dummy)
					if(dummy_appearance)
						hologram_appearance = dummy_appearance
					return TRUE
				else
					return FALSE
	else
		var/list/options = GLOB.ai_hologram_category_options[choice]
		var/option = tgui_input_list(usr, "Select a hologram", "Hologram", options)
		if(!option)
			return

		var/icon = GLOB.ai_hologram_icons[option]
		if(!icon)
			CRASH("hologram icon for [option] does not exist in global icon list")

		var/icon_state = GLOB.ai_hologram_icon_state[option]
		if(!istext(icon_state)) //Possible that the icon_state can be "", which is valid
			CRASH("hologram icon_state for [option] does not exist in global icon_state list")

		hologram_appearance = mutable_appearance(icon, icon_state)
	return

/datum/action/innate/core_return
	name = "Return to Main Core"
	desc = "Leave the APC and resume normal core operations."
	button_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "ai_malf_core"

/datum/action/innate/core_return/Grant(mob/new_owner)
	. = ..()
	RegisterSignal(new_owner, COMSIG_SILICON_AI_VACATE_APC, PROC_REF(returned_to_core))

/datum/action/innate/core_return/proc/returned_to_core(datum/source)
	SIGNAL_HANDLER

	Remove(source)
	UnregisterSignal(source, COMSIG_SILICON_AI_VACATE_APC)

/datum/action/innate/core_return/Activate()
	var/obj/machinery/power/apc/apc = owner.loc
	if(!istype(apc))
		to_chat(owner, span_notice("You are already in your Main Core."))
		return
	if(SEND_SIGNAL(owner, COMSIG_SILICON_AI_CORE_STATUS) & COMPONENT_CORE_ALL_GOOD)
		apc.malfvacate()
	else
		to_chat(owner, span_danger("Linked core not detected!"))
		return
	qdel(src)

/mob/living/silicon/ai/proc/toggle_camera_light()
	camera_light_on = !camera_light_on

	if (!camera_light_on)
		to_chat(src, "Camera lights deactivated.")

		for (var/obj/machinery/camera/C in lit_cameras)
			C.set_light(0)
			lit_cameras = list()

		return

	light_cameras()

	to_chat(src, "Camera lights activated.")

//AI_CAMERA_LUMINOSITY

/mob/living/silicon/ai/proc/light_cameras()
	var/list/obj/machinery/camera/add = list()
	var/list/obj/machinery/camera/remove = list()
	var/list/obj/machinery/camera/visible = list()
	for (var/datum/camerachunk/chunk as anything in eyeobj.visibleCameraChunks)
		for (var/z_key in chunk.cameras)
			for(var/obj/machinery/camera/camera as anything in chunk.cameras[z_key])
				if(isnull(camera) || !camera.can_use() || get_dist(camera, eyeobj) > 7 || !camera.internal_light)
					continue
				visible |= camera

	add = visible - lit_cameras
	remove = lit_cameras - visible

	for (var/obj/machinery/camera/C in remove)
		lit_cameras -= C //Removed from list before turning off the light so that it doesn't check the AI looking away.
		C.Togglelight(0)
	for (var/obj/machinery/camera/C in add)
		C.Togglelight(1)
		lit_cameras |= C

/mob/living/silicon/ai/proc/control_integrated_radio()
	set name = "Transceiver Settings"
	set desc = "Allows you to change settings of your radio."
	set category = "AI Commands"

	if(incapacitated)
		return

	to_chat(src, "Accessing Subspace Transceiver control...")
	if (radio)
		radio.interact(src)

/mob/living/silicon/ai/proc/set_syndie_radio()
	if(radio)
		radio.make_syndie()

/mob/living/silicon/ai/proc/set_automatic_say_channel()
	set name = "Set Auto Announce Mode"
	set desc = "Modify the default radio setting for your automatic announcements."
	set category = "AI Commands"

	if(incapacitated)
		return
	set_autosay()

/mob/living/silicon/ai/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(!..())
		return
	if(interaction != AI_TRANS_TO_CARD)//The only possible interaction. Upload AI mob to a card.
		return
	if(!can_be_carded)
		balloon_alert(user, "transfer failed!")
		return
	disconnect_shell() //If the AI is controlling a borg, force the player back to core!
	if(!mind)
		balloon_alert(user, "no intelligence detected!") // average tg coder am i right
		return
	ShutOffDoomsdayDevice()
	var/obj/structure/ai_core/new_core = new /obj/structure/ai_core/deactivated(loc, posibrain_inside)//Spawns a deactivated terminal at AI location.
	new_core.circuit.battery = battery
	ai_restore_power()//So the AI initially has power.
	set_control_disabled(TRUE) //Can't control things remotely if you're stuck in a card!
	radio_enabled = FALSE //No talking on the built-in radio for you either!
	forceMove(card)
	card.AI = src
	to_chat(src, "You have been downloaded to a mobile storage device. Remote device connection severed.")
	to_chat(user, "[span_boldnotice("Transfer successful")]: [name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory.")

/mob/living/silicon/ai/can_perform_action(atom/target, action_bitflags)
	if(control_disabled)
		to_chat(src, span_warning("You can't do that right now!"))
		return FALSE
	return can_see(target) && ..() //stop AIs from leaving windows open and using then after they lose vision

/mob/living/silicon/ai/proc/can_see(atom/A)
	if(isturf(loc)) //AI in core, check if on cameras
		//get_turf_pixel() is because APCs in maint aren't actually in view of the inner camera
		//apc_override is needed here because AIs use their own APC when depowered
		return ((GLOB.cameranet && GLOB.cameranet.checkTurfVis(get_turf_pixel(A))) || (A == apc_override))
	//AI is carded/shunted
	//view(src) returns nothing for carded/shunted AIs and they have X-ray vision so just use get_dist
	var/list/viewscale = getviewsize(client.view)
	return get_dist(src, A) <= max(viewscale[1]*0.5,viewscale[2]*0.5)

/mob/living/silicon/ai/proc/relay_speech(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	var/raw_translation = translate_language(speaker, message_language, raw_message, spans, message_mods)
	var/atom/movable/source = speaker.GetSource() || speaker // is the speaker virtual/radio
	var/treated_message = source.generate_messagepart(raw_translation, spans, message_mods)

	var/start = "Relayed Speech: "
	var/namepart = speaker.get_message_voice()
	var/hrefpart = "<a href='byond://?src=[REF(src)];track=[html_encode(namepart)]'>"
	var/jobpart = "Unknown"

	// if voice is concealed, job is concealed
	// on the other hand we don't care about TRAIT_UNKNOWN_APPEARANCE
	// (AI can associate voice -> name -> crew record -> job)
	if(!HAS_TRAIT(speaker, TRAIT_UNKNOWN_VOICE))
		if (isliving(speaker))
			var/mob/living/living_speaker = speaker
			if(living_speaker.job)
				jobpart = "[living_speaker.job]"
		if (istype(speaker, /obj/effect/overlay/holo_pad_hologram))
			var/obj/effect/overlay/holo_pad_hologram/holo = speaker
			if(holo.Impersonation?.job)
				jobpart = "[holo.Impersonation.job]"
			else if(usr?.job) // not great, but AI holograms have no other usable ref
				jobpart = "[usr.job]"

	var/rendered = "<i><span class='game say'>[start][span_name("[hrefpart][namepart] ([jobpart])</a> ")]<span class='message'>[treated_message]</span></span></i>"

	if (client?.prefs.read_preference(/datum/preference/toggle/enable_runechat) && (client.prefs.read_preference(/datum/preference/toggle/enable_runechat_non_mobs) || ismob(speaker)))
		create_chat_message(speaker, message_language, raw_message, spans)
	show_message(rendered, 2)

/mob/living/silicon/ai/fully_replace_character_name(oldname,newname)
	..()
	if(oldname != real_name)
		if(eyeobj)
			eyeobj.name = "[newname] (AI Eye)"
			modularInterface.imprint_id(name = real_name)

		// Notify Cyborgs
		for(var/mob/living/silicon/robot/Slave in connected_robots)
			Slave.show_laws()

/datum/action/innate/choose_modules
	name = "Malfunction Modules"
	desc = "Choose from a variety of insidious modules to aid you."
	button_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "modules_menu"
	var/datum/module_picker/module_picker

/datum/action/innate/choose_modules/New(picker)
	. = ..()
	if(istype(picker, /datum/module_picker))
		module_picker = picker
	else
		CRASH("choose_modules action created with non module picker")

/datum/action/innate/choose_modules/Activate()
	module_picker.ui_interact(owner)

/mob/living/silicon/ai/proc/add_malf_picker()
	if (malf_picker)
		stack_trace("Attempted to give malf AI malf picker to \[[src]\], who already has a malf picker.")
		return
	to_chat(src, "In the top left corner of the screen you will find the Malfunction Modules button, where you can purchase various abilities, from upgraded surveillance to station ending doomsday devices.")
	to_chat(src, "You are also capable of hacking APCs, which grants you more points to spend on your Malfunction powers. The drawback is that a hacked APC will give you away if spotted by the crew. Hacking an APC takes 60 seconds.")
	view_core() //A BYOND bug requires you to be viewing your core before your verbs update
	malf_picker = new /datum/module_picker
	if(!IS_MALF_AI(src)) //antagonists have their modules built into their antag info panel. this is for adminbus and the combat upgrade
		modules_action = new(malf_picker)
		modules_action.Grant(src)

/mob/living/silicon/ai/reset_perspective(atom/new_eye)
	SHOULD_CALL_PARENT(FALSE) // I hate you all
	if(camera_light_on)
		light_cameras()
	if(istype(new_eye, /obj/machinery/camera))
		current = new_eye
	if(!client)
		return

	if(ismovable(new_eye))
		if(new_eye != GLOB.ai_camera_room_landmark)
			end_multicam()
		client.perspective = EYE_PERSPECTIVE
		client.set_eye(new_eye)
	else
		end_multicam()
		if(isturf(loc))
			if(eyeobj)
				client.set_eye(eyeobj)
				client.perspective = EYE_PERSPECTIVE
			else
				client.set_eye(client.mob)
				client.perspective = MOB_PERSPECTIVE
		else
			client.perspective = EYE_PERSPECTIVE
			client.set_eye(loc)
	update_sight()
	if(client.eye != src)
		var/atom/AT = client.eye
		AT?.get_remote_view_fullscreens(src)
	else
		clear_fullscreen("remote_view", 0)

	// I am so sorry
	SEND_SIGNAL(src, COMSIG_MOB_RESET_PERSPECTIVE)

/mob/living/silicon/ai/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	. = ..()
	if(!.) //successfully ressuscitated from death
		return

	set_core_display_icon(display_icon_override)
	set_eyeobj_visible(TRUE)

/mob/living/silicon/ai/proc/malfhacked(obj/machinery/power/apc/apc)
	malfhack = null
	malfhacking = FALSE
	clear_alert(ALERT_HACKING_APC)

	if(!istype(apc) || QDELETED(apc) || apc.machine_stat & BROKEN)
		to_chat(src, span_danger("Hack aborted. The designated APC no longer exists on the power network."))
		playsound(get_turf(src), 'sound/machines/buzz/buzz-two.ogg', 50, TRUE, ignore_walls = FALSE)
		return
	if(apc.aidisabled)
		to_chat(src, span_danger("Hack aborted. [apc] is no longer responding to our systems."))
		playsound(get_turf(src), 'sound/machines/buzz/buzz-sigh.ogg', 50, TRUE, ignore_walls = FALSE)
		return

	malf_picker.processing_time += max(0, 9 - hacked_apcs.len) // Less resources for each apc hacked, 9 instead of 10 is because you will get 1 as soon as the hacked apc processes
	var/area/apcarea = apc.area
	var/datum/ai_module/malf/destructive/nuke_station/doom_n_boom = locate(/datum/ai_module/malf/destructive/nuke_station) in malf_picker.possible_modules["Destructive Modules"]
	if(doom_n_boom && (is_type_in_list (apcarea, doom_n_boom.discount_areas)) && !(is_type_in_list (apcarea, doom_n_boom.hacked_command_areas)))
		doom_n_boom.hacked_command_areas += apcarea
		doom_n_boom.cost = max(50, 130 - (length(doom_n_boom.hacked_command_areas) * 20))
		var/datum/antagonist/malf_ai/malf_ai_datum = mind.has_antag_datum(/datum/antagonist/malf_ai)
		if(malf_ai_datum)
			malf_ai_datum.update_static_data_for_all_viewers()
		else //combat software AIs use a different UI
			malf_picker.update_static_data_for_all_viewers()
	if(apc.malfai) // another malf hacked this one; counter-hack!
		to_chat(apc.malfai, span_warning("An adversarial subroutine has counter-hacked [apc]!"))
		apc.malfai.hacked_apcs -= apc
	apc.malfai = src
	apc.malfhack = TRUE
	apc.locked = TRUE
	apc.coverlocked = TRUE
	apc.flicker_hacked_icon()
	apc.set_hacked_hud()
	hacked_apcs += apc
	playsound(get_turf(src), 'sound/machines/ding.ogg', 50, TRUE, ignore_walls = FALSE)
	to_chat(src, "Hack complete. [apc] is now under your exclusive control.")

/mob/living/silicon/ai/verb/deploy_to_shell(mob/living/silicon/robot/target)
	set category = "AI Commands"
	set name = "Deploy to Shell"

	if(incapacitated)
		return
	if(control_disabled)
		to_chat(src, span_warning("Wireless networking module is offline."))
		return

	var/list/possible = list()

	for(var/borgie in GLOB.available_ai_shells)
		var/mob/living/silicon/robot/R = borgie
		if(R.shell && !R.deployed && (R.stat != DEAD) && (!R.connected_ai || (R.connected_ai == src)))
			possible += R

	if(!LAZYLEN(possible))
		to_chat(src, "No usable AI shell beacons detected.")

	if(!target || !(target in possible)) //If the AI is looking for a new shell, or its pre-selected shell is no longer valid
		target = tgui_input_list(src, "Which body to control?", "Direct Control", sort_names(possible))

	if(isnull(target))
		return
	if (target.stat == DEAD || target.deployed || !(!target.connected_ai || (target.connected_ai == src)))
		return

	else if(mind)
		RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(disconnect_shell))
		deployed_shell = target
		target.deploy_init(src)
		mind.transfer_to(target)
		ADD_TRAIT(target, TRAIT_LOUD_BINARY, REF(src))
	diag_hud_set_deployed()

/datum/action/innate/deploy_shell
	name = "Deploy to AI Shell"
	desc = "Wirelessly control a specialized cyborg shell."
	button_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "ai_shell"

/datum/action/innate/deploy_shell/Trigger(mob/clicker, trigger_flags)
	var/mob/living/silicon/ai/AI = owner
	if(!AI)
		return
	AI.deploy_to_shell()

/datum/action/innate/deploy_last_shell
	name = "Reconnect to shell"
	desc = "Reconnect to the most recently used AI shell."
	button_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "ai_last_shell"
	var/mob/living/silicon/robot/last_used_shell

/datum/action/innate/deploy_last_shell/Trigger(mob/clicker, trigger_flags)
	if(!owner)
		return
	if(last_used_shell)
		var/mob/living/silicon/ai/AI = owner
		AI.deploy_to_shell(last_used_shell)
	else
		Remove(owner) //If the last shell is blown, destroy it.

/mob/living/silicon/ai/proc/disconnect_shell()
	SIGNAL_HANDLER
	if(deployed_shell) //Forcibly call back AI in event of things such as damage, EMP or power loss.
		to_chat(src, span_danger("Your remote connection has been reset!"))
		deployed_shell.undeploy()
	diag_hud_set_deployed()

/mob/living/silicon/ai/resist()
	return

/mob/living/silicon/ai/spawned/Initialize(mapload, datum/ai_laws/L, mob/target_ai)
	if(!target_ai)
		target_ai = src //cheat! just give... ourselves as the spawned AI, because that's technically correct
	. = ..()

/mob/living/silicon/ai/proc/camera_visibility(mob/eye/camera/ai/moved_eye)
	GLOB.cameranet.visibility(moved_eye)

/mob/living/silicon/ai/forceMove(atom/destination)
	. = ..()
	if(.)
		end_multicam()

/mob/living/silicon/ai/up()
	set name = "Move Upwards"
	set category = "IC"

	if(eyeobj.zMove(UP, z_move_flags = ZMOVE_FEEDBACK))
		to_chat(src, span_notice("You move upwards."))

/mob/living/silicon/ai/down()
	set name = "Move Down"
	set category = "IC"

	if(eyeobj.zMove(DOWN, z_move_flags = ZMOVE_FEEDBACK))
		to_chat(src, span_notice("You move down."))

/// Proc to hook behavior to the changes of the value of [aiRestorePowerRoutine].
/mob/living/silicon/ai/proc/setAiRestorePowerRoutine(new_value)
	if(new_value == aiRestorePowerRoutine)
		return
	. = aiRestorePowerRoutine
	aiRestorePowerRoutine = new_value
	if(aiRestorePowerRoutine)
		if(!.)
			ADD_TRAIT(src, TRAIT_INCAPACITATED, POWER_LACK_TRAIT)
	else if(.)
		REMOVE_TRAIT(src, TRAIT_INCAPACITATED, POWER_LACK_TRAIT)

/mob/living/silicon/ai/proc/show_camera_list()
	var/list/cameras = GLOB.cameranet.get_available_camera_by_tag_list(network)
	var/camera_tag = tgui_input_list(src, "Choose which camera you want to view", "Cameras", cameras)
	if(isnull(camera_tag))
		return

	var/obj/machinery/camera/chosen_camera = cameras[camera_tag]
	if(isnull(chosen_camera))
		return

	switchCamera(chosen_camera)

/mob/living/silicon/on_handsblocked_start()
	return // AIs have no hands

/mob/living/silicon/on_handsblocked_end()
	return // AIs have no hands

/mob/living/silicon/ai/get_exp_list(minutes)
	. = ..()
	.[/datum/job/ai::title] = minutes

/mob/living/silicon/ai/get_voice()
	. = ..()
	if(ai_voicechanger && ai_voicechanger.changing_voice)
		return ai_voicechanger.say_name
	return

/mob/living/silicon/ai/proc/set_control_disabled(control_disabled)
	SEND_SIGNAL(src, COMSIG_SILICON_AI_SET_CONTROL_DISABLED, control_disabled)
	src.control_disabled = control_disabled

#undef HOLOGRAM_CHOICE_CHARACTER
#undef CHARACTER_TYPE_SELF
#undef CHARACTER_TYPE_CREWMEMBER
