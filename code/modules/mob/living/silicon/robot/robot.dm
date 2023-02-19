/mob/living/silicon/robot/Initialize(mapload)
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	ADD_TRAIT(src, TRAIT_CAN_STRIP, INNATE_TRAIT)
	AddComponent(/datum/component/tippable, \
		tip_time = 3 SECONDS, \
		untip_time = 2 SECONDS, \
		self_right_time = 60 SECONDS, \
		post_tipped_callback = CALLBACK(src, PROC_REF(after_tip_over)), \
		post_untipped_callback = CALLBACK(src, PROC_REF(after_righted)), \
		roleplay_friendly = TRUE, \
		roleplay_emotes = list(/datum/emote/silicon/buzz, /datum/emote/silicon/buzz2, /datum/emote/living/beep), \
		roleplay_callback = CALLBACK(src, PROC_REF(untip_roleplay)))

	wires = new /datum/wires/robot(src)
	AddElement(/datum/element/empprotection, EMP_PROTECT_WIRES)
	AddElement(/datum/element/ridable, /datum/component/riding/creature/cyborg)
	RegisterSignal(src, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(charge))
	RegisterSignal(src, COMSIG_LIGHT_EATER_ACT, PROC_REF(on_light_eater))

	robot_modules_background = new()
	robot_modules_background.icon_state = "block"
	SET_PLANE_EXPLICIT(robot_modules_background, HUD_PLANE, src)

	inv1 = new /atom/movable/screen/robot/module1()
	inv2 = new /atom/movable/screen/robot/module2()
	inv3 = new /atom/movable/screen/robot/module3()

	ident = rand(1, 999)

	previous_health = health

	if(ispath(cell))
		cell = new cell(src)

	create_modularInterface()

	model = new /obj/item/robot_model(src)
	model.rebuild_modules()

	if(lawupdate)
		make_laws()
		for (var/law in laws.inherent)
			lawcheck += law
		if(!TryConnectToAI())
			lawupdate = FALSE

	if(!scrambledcodes && !builtInCamera)
		builtInCamera = new (src)
		builtInCamera.c_tag = real_name
		builtInCamera.network = list("ss13")
		builtInCamera.internal_light = FALSE
		if(wires.is_cut(WIRE_CAMERA))
			builtInCamera.status = 0
	update_icons()
	. = ..()

	//If this body is meant to be a borg controlled by the AI player
	if(shell)
		make_shell()
	else
		//MMI stuff. Held togheter by magic. ~Miauw
		if(!mmi?.brainmob)
			mmi = new (src)
			mmi.brain = new /obj/item/organ/internal/brain(mmi)
			mmi.brain.organ_flags |= ORGAN_FROZEN
			mmi.brain.name = "[real_name]'s brain"
			mmi.name = "[initial(mmi.name)]: [real_name]"
			mmi.set_brainmob(new /mob/living/brain(mmi))
			mmi.brainmob.name = src.real_name
			mmi.brainmob.real_name = src.real_name
			mmi.brainmob.container = mmi
			mmi.update_appearance()
		setup_default_name()

	aicamera = new/obj/item/camera/siliconcam/robot_camera(src)
	toner = tonermax
	diag_hud_set_borgcell()
	logevent("System brought online.")

	log_silicon("New cyborg [key_name(src)] created with [connected_ai ? "master AI: [key_name(connected_ai)]" : "no master AI"]")
	log_current_laws()

	alert_control = new(src, list(ALARM_ATMOS, ALARM_FIRE, ALARM_POWER, ALARM_CAMERA, ALARM_BURGLAR, ALARM_MOTION), list(z))
	RegisterSignal(alert_control.listener, COMSIG_ALARM_LISTENER_TRIGGERED, PROC_REF(alarm_triggered))
	RegisterSignal(alert_control.listener, COMSIG_ALARM_LISTENER_CLEARED, PROC_REF(alarm_cleared))
	alert_control.listener.RegisterSignal(src, COMSIG_LIVING_DEATH, TYPE_PROC_REF(/datum/alarm_listener, prevent_alarm_changes))
	alert_control.listener.RegisterSignal(src, COMSIG_LIVING_REVIVE, TYPE_PROC_REF(/datum/alarm_listener, allow_alarm_changes))

/mob/living/silicon/robot/model/syndicate/Initialize(mapload)
	. = ..()
	laws = new /datum/ai_laws/syndicate_override()
	addtimer(CALLBACK(src, PROC_REF(show_playstyle)), 5)

/mob/living/silicon/robot/model/syndicate/create_modularInterface()
	if(!modularInterface)
		modularInterface = new /obj/item/modular_computer/pda/silicon/cyborg/syndicate(src)
		modularInterface.saved_identification = real_name
		modularInterface.saved_job = "Cyborg"
	return ..()

/mob/living/silicon/robot/set_suicide(suicide_state)
	. = ..()
	if(mmi)
		if(mmi.brain)
			mmi.brain.suicided = suicide_state
		if(mmi.brainmob)
			mmi.brainmob.suiciding = suicide_state

/**
 * Sets the tablet theme and icon
 *
 * These variables are based on if the borg is a syndicate type or is emagged. This gets used in model change code
 * and also borg emag code.
 */
/mob/living/silicon/robot/proc/set_modularInterface_theme()
	if(istype(model, /obj/item/robot_model/syndicate) || emagged)
		modularInterface.device_theme = PDA_THEME_SYNDICATE
		modularInterface.icon_state = "tablet-silicon-syndicate"
	else
		modularInterface.device_theme = PDA_THEME_NTOS
		modularInterface.icon_state = "tablet-silicon"
		modularInterface.icon_state_powered = "tablet-silicon"
		modularInterface.icon_state_unpowered = "tablet-silicon"
	modularInterface.update_icon()

//If there's an MMI in the robot, have it ejected when the mob goes away. --NEO
/mob/living/silicon/robot/Destroy()
	var/atom/T = drop_location()//To hopefully prevent run time errors.
	if(mmi && mind)//Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		if(T)
			mmi.forceMove(T)
		if(mmi.brainmob)
			if(mmi.brainmob.stat == DEAD)
				mmi.brainmob.set_stat(CONSCIOUS)
			mind.transfer_to(mmi.brainmob)
			mmi.update_appearance()
		else
			to_chat(src, span_boldannounce("Oops! Something went very wrong, your MMI was unable to receive your mind. You have been ghosted. Please make a bug report so we can fix this bug."))
			ghostize()
			stack_trace("Borg MMI lacked a brainmob")
		mmi = null
	if(modularInterface)
		QDEL_NULL(modularInterface)
	if(connected_ai)
		set_connected_ai(null)
	if(shell)
		GLOB.available_ai_shells -= src
	else
		if(T && istype(radio) && istype(radio.keyslot))
			radio.keyslot.forceMove(T)
			radio.keyslot = null
	QDEL_NULL(wires)
	QDEL_NULL(model)
	QDEL_NULL(eye_lights)
	QDEL_NULL(inv1)
	QDEL_NULL(inv2)
	QDEL_NULL(inv3)
	QDEL_NULL(hands)
	QDEL_NULL(spark_system)
	QDEL_NULL(alert_control)
	QDEL_LIST(upgrades)
	cell = null
	return ..()

/mob/living/silicon/robot/Topic(href, href_list)
	. = ..()
	//Show alerts window if user clicked on "Show alerts" in chat
	if(href_list["showalerts"])
		alert_control.ui_interact(src)

/mob/living/silicon/robot/get_cell()
	return cell

/mob/living/silicon/robot/proc/pick_model()
	if(model.type != /obj/item/robot_model)
		return

	if(wires.is_cut(WIRE_RESET_MODEL))
		to_chat(src,span_userdanger("ERROR: Model installer reply timeout. Please check internal connections."))
		return

	if(lockcharge == TRUE)
		to_chat(src,span_userdanger("ERROR: Lockdown is engaged. Please disengage lockdown to pick module."))
		return

	var/list/model_list = list(
		"Engineering" = /obj/item/robot_model/engineering,
		"Medical" = /obj/item/robot_model/medical,
		"Miner" = /obj/item/robot_model/miner,
		"Janitor" = /obj/item/robot_model/janitor,
		"Service" = /obj/item/robot_model/service,
	)
	if(!CONFIG_GET(flag/disable_peaceborg))
		model_list["Peacekeeper"] = /obj/item/robot_model/peacekeeper
	if(!CONFIG_GET(flag/disable_secborg))
		model_list["Security"] = /obj/item/robot_model/security

	// Create radial menu for choosing borg model
	var/list/model_icons = list()
	for(var/option in model_list)
		var/obj/item/robot_model/model = model_list[option]
		var/model_icon = initial(model.cyborg_base_icon)
		model_icons[option] = image(icon = 'icons/mob/silicon/robots.dmi', icon_state = model_icon)

	var/input_model = show_radial_menu(src, src, model_icons, radius = 42)
	if(!input_model || model.type != /obj/item/robot_model)
		return

	model.transform_to(model_list[input_model])


/// Used to setup the a basic and (somewhat) unique name for the robot.
/mob/living/silicon/robot/proc/setup_default_name()
	var/new_name
	if(GLOB.current_anonymous_theme) //only robotic renames will allow for anything other than the anonymous one
		new_name = GLOB.current_anonymous_theme.anonymous_ai_name(FALSE)
	else if(custom_name)
		new_name = custom_name
	else
		new_name = get_standard_name()
	if(new_name != real_name)
		fully_replace_character_name(real_name, new_name)


/// Updates the borg name taking the client preferences into account.
/mob/living/silicon/robot/proc/updatename(client/pref_source)
	if(shell)
		return
	if(!pref_source)
		pref_source = client
	var/changed_name = ""
	if(GLOB.current_anonymous_theme) //only robotic renames will allow for anything other than the anonymous one
		changed_name = GLOB.current_anonymous_theme.anonymous_ai_name(FALSE)
	else if(custom_name)
		changed_name = custom_name
	else if(pref_source && pref_source.prefs.read_preference(/datum/preference/name/cyborg) != DEFAULT_CYBORG_NAME)
		apply_pref_name(/datum/preference/name/cyborg, pref_source)
		return //built in camera handled in proc
	else
		changed_name = get_standard_name()

	fully_replace_character_name(real_name, changed_name)


/mob/living/silicon/robot/proc/get_standard_name()
	return "[(designation ? "[designation] " : "")][mmi.braintype]-[ident]"

/mob/living/silicon/robot/proc/ionpulse()
	if(!ionpulse_on)
		return

	if(cell.charge <= 10)
		toggle_ionpulse()
		return

	cell.charge -= 10
	return TRUE

/mob/living/silicon/robot/proc/toggle_ionpulse()
	if(!ionpulse)
		to_chat(src, span_notice("No thrusters are installed!"))
		return

	if(!ion_trail)
		ion_trail = new
		ion_trail.set_up(src)

	ionpulse_on = !ionpulse_on
	to_chat(src, span_notice("You [ionpulse_on ? null :"de"]activate your ion thrusters."))
	if(ionpulse_on)
		ion_trail.start()
	else
		ion_trail.stop()

/mob/living/silicon/robot/get_status_tab_items()
	. = ..()
	if(cell)
		. += "Charge Left: [cell.charge]/[cell.maxcharge]"
	else
		. += "No Cell Inserted!"

	if(connected_ai)
		. += "Master AI: [connected_ai.name]"

/mob/living/silicon/robot/proc/alarm_triggered(datum/source, alarm_type, area/source_area)
	SIGNAL_HANDLER
	queueAlarm("--- [alarm_type] alarm detected in [source_area.name]!", alarm_type)

/mob/living/silicon/robot/proc/alarm_cleared(datum/source, alarm_type, area/source_area)
	SIGNAL_HANDLER
	queueAlarm("--- [alarm_type] alarm in [source_area.name] has been cleared.", alarm_type, FALSE)

/mob/living/silicon/robot/can_interact_with(atom/A)
	if (A == modularInterface)
		return TRUE //bypass for borg tablets
	if (low_power_mode)
		return FALSE
	return ..()


/mob/living/silicon/robot/proc/after_tip_over(mob/user)
	if(hat)
		hat.forceMove(drop_location())
	unbuckle_all_mobs()

///For any special cases for robots after being righted.
/mob/living/silicon/robot/proc/after_righted(mob/user)
	return

/mob/living/silicon/robot/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(check_access(null))
		return TRUE
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(check_access(H.get_active_held_item()) || check_access(H.wear_id))
			return TRUE
	else if(isalien(M))
		var/mob/living/carbon/george = M
		//they can only hold things :(
		if(isitem(george.get_active_held_item()))
			return check_access(george.get_active_held_item())
	return FALSE

/mob/living/silicon/robot/proc/check_access(obj/item/card/id/I)
	if(!istype(req_access, /list)) //something's very wrong
		return TRUE

	var/list/L = req_access
	if(!L.len) //no requirements
		return TRUE

	if(!isidcard(I) && isitem(I))
		I = I.GetID()

	if(!I || !I.access) //not ID or no access
		return FALSE
	for(var/req in req_access)
		if(!(req in I.access)) //doesn't have this access
			return FALSE
	return TRUE

/mob/living/silicon/robot/regenerate_icons()
	return update_icons()

/mob/living/silicon/robot/update_icons()
	cut_overlays()
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	icon_state = model.cyborg_base_icon
	if(stat != DEAD && !(HAS_TRAIT(src, TRAIT_KNOCKEDOUT) || IsStun() || IsParalyzed() || low_power_mode)) //Not dead, not stunned.
		if(!eye_lights)
			eye_lights = new()
		if(lamp_enabled || lamp_doom)
			eye_lights.icon_state = "[model.special_light_key ? "[model.special_light_key]" : "[model.cyborg_base_icon]"]_l"
			set_light_range(max(MINIMUM_USEFUL_LIGHT_RANGE, lamp_intensity))
			set_light_color(lamp_doom ? COLOR_RED : lamp_color) //Red for doomsday killborgs, borg's choice otherwise
			SET_PLANE_EXPLICIT(eye_lights, ABOVE_LIGHTING_PLANE, src) //glowy eyes
		else
			eye_lights.icon_state = "[model.special_light_key ? "[model.special_light_key]":"[model.cyborg_base_icon]"]_e"
			eye_lights.color = COLOR_WHITE
			SET_PLANE_EXPLICIT(eye_lights, ABOVE_GAME_PLANE, src)
		eye_lights.icon = icon
		add_overlay(eye_lights)

	if(opened)
		if(wiresexposed)
			add_overlay("ov-opencover +w")
		else if(cell)
			add_overlay("ov-opencover +c")
		else
			add_overlay("ov-opencover -c")
	if(hat)
		var/mutable_appearance/head_overlay = hat.build_worn_icon(default_layer = 20, default_icon_file = 'icons/mob/clothing/head/default.dmi')
		head_overlay.pixel_z += hat_offset
		add_overlay(head_overlay)
	update_fire()

/mob/living/silicon/robot/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	if(same_z_layer)
		return ..()
	cut_overlay(eye_lights)
	SET_PLANE_EXPLICIT(eye_lights, PLANE_TO_TRUE(eye_lights.plane), src)
	add_overlay(eye_lights)
	return ..()

/mob/living/silicon/robot/proc/self_destruct(mob/usr)
	var/turf/groundzero = get_turf(src)
	message_admins(span_notice("[ADMIN_LOOKUPFLW(usr)] detonated [key_name_admin(src, client)] at [ADMIN_VERBOSEJMP(groundzero)]!"))
	usr.log_message("detonated [key_name(src)]!", LOG_ATTACK)
	log_message("was detonated by [key_name(usr)]!", LOG_ATTACK, log_globally = FALSE)

	log_combat(usr, src, "detonated cyborg")
	log_silicon("CYBORG: [key_name(src)] has been detonated by [key_name(usr)].")
	if(connected_ai)
		to_chat(connected_ai, "<br><br>[span_alert("ALERT - Cyborg detonation detected: [name]")]<br>")

	if(emagged)
		QDEL_NULL(mmi)
		explosion(src, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 4, flame_range = 2)
	else
		explosion(src, devastation_range = -1, light_impact_range = 2)
	investigate_log("has self-destructed.", INVESTIGATE_DEATHS)
	gib()

/mob/living/silicon/robot/proc/UnlinkSelf()
	set_connected_ai(null)
	lawupdate = FALSE
	set_lockcharge(FALSE)
	scrambledcodes = TRUE
	log_silicon("CYBORG: [key_name(src)] has been unlinked from an AI.")
	//Disconnect it's camera so it's not so easily tracked.
	if(!QDELETED(builtInCamera))
		QDEL_NULL(builtInCamera)
		// I'm trying to get the Cyborg to not be listed in the camera list
		// Instead of being listed as "deactivated". The downside is that I'm going
		// to have to check if every camera is null or not before doing anything, to prevent runtime errors.
		// I could change the network to null but I don't know what would happen, and it seems too hacky for me.

/mob/living/silicon/robot/mode()
	set name = "Activate Held Object"
	set category = "IC"
	set src = usr

	return ..()

/mob/living/silicon/robot/execute_mode()
	if(incapacitated())
		return
	var/obj/item/W = get_active_held_item()
	if(W)
		W.attack_self(src)


/mob/living/silicon/robot/proc/SetLockdown(state = TRUE)
	// They stay locked down if their wire is cut.
	if(wires?.is_cut(WIRE_LOCKDOWN))
		state = TRUE
	if(state)
		throw_alert(ALERT_HACKED, /atom/movable/screen/alert/locked)
	else
		clear_alert(ALERT_HACKED)
	set_lockcharge(state)


///Reports the event of the change in value of the lockcharge variable.
/mob/living/silicon/robot/proc/set_lockcharge(new_lockcharge)
	if(new_lockcharge == lockcharge)
		return
	. = lockcharge
	lockcharge = new_lockcharge
	if(lockcharge)
		if(!.)
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, LOCKED_BORG_TRAIT)
	else if(.)
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LOCKED_BORG_TRAIT)
	logevent("System lockdown [lockcharge?"triggered":"released"].")


/mob/living/silicon/robot/proc/SetEmagged(new_state)
	emagged = new_state
	model.rebuild_modules()
	update_icons()
	if(emagged)
		throw_alert(ALERT_HACKED, /atom/movable/screen/alert/hacked)
	else
		clear_alert(ALERT_HACKED)
	set_modularInterface_theme()

/// Special handling for getting hit with a light eater
/mob/living/silicon/robot/proc/on_light_eater(mob/living/silicon/robot/source, datum/light_eater)
	SIGNAL_HANDLER
	if(lamp_enabled)
		smash_headlamp()
	return COMPONENT_BLOCK_LIGHT_EATER


/**
 * Handles headlamp smashing
 *
 * When called (such as by the shadowperson lighteater's attack), this proc will break the borg's headlamp
 * and then call toggle_headlamp to disable the light. It also plays a sound effect of glass breaking, and
 * tells the borg what happened to its chat. Broken lights can be repaired by using a flashlight on the borg.
 */
/mob/living/silicon/robot/proc/smash_headlamp()
	if(!lamp_functional)
		return
	lamp_functional = FALSE
	playsound(src, 'sound/effects/glass_step.ogg', 50)
	toggle_headlamp(TRUE)
	to_chat(src, span_danger("Your headlamp is broken! You'll need a human to help replace it."))

/**
 * Handles headlamp toggling, disabling, and color setting.
 *
 * The initial if statment is a bit long, but the gist of it is that should the lamp be on AND the update_color
 * arg be true, we should simply change the color of the lamp but not disable it. Otherwise, should the turn_off
 * arg be true, the lamp already be enabled, any of the normal reasons the lamp would turn off happen, or the
 * update_color arg be passed with the lamp not on, we should set the lamp off. The update_color arg is only
 * ever true when this proc is called from the borg tablet, when the color selection feature is used.
 *
 * Arguments:
 * * arg1 - turn_off, if enabled will force the lamp into an off state (rather than toggling it if possible)
 * * arg2 - update_color, if enabled, will adjust the behavior of the proc to change the color of the light if it is already on.
 */
/mob/living/silicon/robot/proc/toggle_headlamp(turn_off = FALSE, update_color = FALSE)
	//if both lamp is enabled AND the update_color flag is on, keep the lamp on. Otherwise, if anything listed is true, disable the lamp.
	if(!(update_color && lamp_enabled) && (turn_off || lamp_enabled || update_color || !lamp_functional || stat || low_power_mode))
		set_light_on(lamp_functional && stat != DEAD && lamp_doom) //If the lamp isn't broken and borg isn't dead, doomsday borgs cannot disable their light fully.
		set_light_color(COLOR_RED) //This should only matter for doomsday borgs, as any other time the lamp will be off and the color not seen
		set_light_range(1) //Again, like above, this only takes effect when the light is forced on by doomsday mode.
		lamp_enabled = FALSE
		lampButton?.update_appearance()
		update_icons()
		return
	set_light_range(max(MINIMUM_USEFUL_LIGHT_RANGE, lamp_intensity))
	set_light_color(lamp_doom ? COLOR_RED : lamp_color) //Red for doomsday killborgs, borg's choice otherwise
	set_light_on(TRUE)
	lamp_enabled = TRUE
	lampButton?.update_appearance()
	update_icons()

/mob/living/silicon/robot/proc/deconstruct()
	SEND_SIGNAL(src, COMSIG_BORG_SAFE_DECONSTRUCT)
	if(shell)
		undeploy()
	var/turf/T = get_turf(src)
	if (robot_suit)
		robot_suit.forceMove(T)
		robot_suit.l_leg.forceMove(T)
		robot_suit.l_leg = null
		robot_suit.r_leg.forceMove(T)
		robot_suit.r_leg = null
		new /obj/item/stack/cable_coil(T, robot_suit.chest.wired)
		robot_suit.chest.forceMove(T)
		robot_suit.chest.wired = FALSE
		robot_suit.chest = null
		robot_suit.l_arm.forceMove(T)
		robot_suit.l_arm = null
		robot_suit.r_arm.forceMove(T)
		robot_suit.r_arm = null
		robot_suit.head.forceMove(T)
		robot_suit.head.flash1.forceMove(T)
		robot_suit.head.flash1.burn_out()
		robot_suit.head.flash1 = null
		robot_suit.head.flash2.forceMove(T)
		robot_suit.head.flash2.burn_out()
		robot_suit.head.flash2 = null
		robot_suit.head = null
		robot_suit.update_appearance()
	else
		new /obj/item/robot_suit(T)
		new /obj/item/bodypart/leg/left/robot(T)
		new /obj/item/bodypart/leg/right/robot(T)
		new /obj/item/stack/cable_coil(T, 1)
		new /obj/item/bodypart/chest/robot(T)
		new /obj/item/bodypart/arm/left/robot(T)
		new /obj/item/bodypart/arm/right/robot(T)
		new /obj/item/bodypart/head/robot(T)
		var/b
		for(b=0, b != 2, b++)
			var/obj/item/assembly/flash/handheld/F = new /obj/item/assembly/flash/handheld(T)
			F.burn_out()
	if (cell) //Sanity check.
		cell.forceMove(T)
		cell = null
	qdel(src)

/mob/living/silicon/robot/proc/notify_ai(notifytype, oldname, newname)
	if(!connected_ai)
		return
	switch(notifytype)
		if(AI_NOTIFICATION_NEW_BORG) //New Cyborg
			to_chat(connected_ai, "<br><br>[span_notice("NOTICE - New cyborg connection detected: <a href='?src=[REF(connected_ai)];track=[html_encode(name)]'>[name]</a>")]<br>")
		if(AI_NOTIFICATION_NEW_MODEL) //New Model
			to_chat(connected_ai, "<br><br>[span_notice("NOTICE - Cyborg model change detected: [name] has loaded the [designation] model.")]<br>")
		if(AI_NOTIFICATION_CYBORG_RENAMED) //New Name
			to_chat(connected_ai, "<br><br>[span_notice("NOTICE - Cyborg reclassification detected: [oldname] is now designated as [newname].")]<br>")
		if(AI_NOTIFICATION_AI_SHELL) //New Shell
			to_chat(connected_ai, "<br><br>[span_notice("NOTICE - New cyborg shell detected: <a href='?src=[REF(connected_ai)];track=[html_encode(name)]'>[name]</a>")]<br>")
		if(AI_NOTIFICATION_CYBORG_DISCONNECTED) //Tampering with the wires
			to_chat(connected_ai, "<br><br>[span_notice("NOTICE - Remote telemetry lost with [name].")]<br>")

/mob/living/silicon/robot/can_perform_action(atom/movable/target, action_bitflags)
	if(lockcharge || low_power_mode)
		to_chat(src, span_warning("You can't do that right now!"))
		return FALSE
	return ..()

/mob/living/silicon/robot/updatehealth()
	..()
	if(!model.breakable_modules)
		return

	/// the current percent health of the robot (-1 to 1)
	var/percent_hp = health/maxHealth
	if(health <= previous_health) //if change in health is negative (we're losing hp)
		if(percent_hp <= 0.5)
			break_cyborg_slot(3)

		if(percent_hp <= 0)
			break_cyborg_slot(2)

		if(percent_hp <= -0.5)
			break_cyborg_slot(1)

	else //if change in health is positive (we're gaining hp)
		if(percent_hp >= 0.5)
			repair_cyborg_slot(3)

		if(percent_hp >= 0)
			repair_cyborg_slot(2)

		if(percent_hp >= -0.5)
			repair_cyborg_slot(1)

	previous_health = health

/mob/living/silicon/robot/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		if(SSmapping.level_trait(z, ZTRAIT_NOXRAY))
			set_sight(null)
		else if(is_secret_level(z))
			set_sight(initial(sight))
		else
			set_sight(SEE_TURFS|SEE_MOBS|SEE_OBJS)
		set_invis_see(SEE_INVISIBLE_OBSERVER)
		return

	set_invis_see(initial(see_invisible))
	var/new_sight = initial(sight)
	lighting_cutoff = LIGHTING_CUTOFF_VISIBLE
	lighting_color_cutoffs = list(lighting_cutoff_red, lighting_cutoff_green, lighting_cutoff_blue)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	if(sight_mode & BORGMESON)
		new_sight |= SEE_TURFS
		lighting_color_cutoffs = blend_cutoff_colors(lighting_color_cutoffs, list(5, 15, 5))

	if(sight_mode & BORGMATERIAL)
		new_sight |= SEE_OBJS
		lighting_color_cutoffs = blend_cutoff_colors(lighting_color_cutoffs, list(20, 25, 40))

	if(sight_mode & BORGXRAY)
		new_sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
		set_invis_see(SEE_INVISIBLE_LIVING)

	if(sight_mode & BORGTHERM)
		new_sight |= SEE_MOBS
		lighting_color_cutoffs = blend_cutoff_colors(lighting_color_cutoffs, list(25, 8, 5))
		set_invis_see(min(see_invisible, SEE_INVISIBLE_LIVING))

	if(see_override)
		set_invis_see(see_override)

	if(SSmapping.level_trait(z, ZTRAIT_NOXRAY))
		new_sight = null

	set_sight(new_sight)
	return ..()

/mob/living/silicon/robot/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= -maxHealth) //die only once
			death()
			toggle_headlamp(1)
			return
		if(HAS_TRAIT(src, TRAIT_KNOCKEDOUT) || IsStun() || IsKnockdown() || IsParalyzed())
			set_stat(UNCONSCIOUS)
		else
			set_stat(CONSCIOUS)
	diag_hud_set_status()
	diag_hud_set_health()
	diag_hud_set_aishell()
	update_health_hud()
	update_icons() //Updates eye_light overlay

/mob/living/silicon/robot/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	. = ..()
	if(!.)
		return

	if(!QDELETED(builtInCamera) && !wires.is_cut(WIRE_CAMERA))
		builtInCamera.toggle_cam(src, 0)
	if(full_heal_flags & HEAL_ADMIN)
		locked = TRUE
	notify_ai(AI_NOTIFICATION_NEW_BORG)
	toggle_headlamp(FALSE, TRUE) //This will reenable borg headlamps if doomsday is currently going on still.
	return TRUE

/mob/living/silicon/robot/fully_replace_character_name(oldname, newname)
	. = ..()
	if(!.)
		return
	notify_ai(AI_NOTIFICATION_CYBORG_RENAMED, oldname, newname)
	if(!QDELETED(builtInCamera))
		builtInCamera.c_tag = real_name
		modularInterface.saved_identification = real_name
	custom_name = newname


/mob/living/silicon/robot/proc/ResetModel()
	SEND_SIGNAL(src, COMSIG_BORG_SAFE_DECONSTRUCT)
	drop_all_held_items()
	shown_robot_modules = FALSE

	for(var/obj/item/storage/bag in model.contents) // drop all of the items that may be stored by the cyborg
		for(var/obj/item in bag)
			item.forceMove(drop_location())

	if(hud_used)
		hud_used.update_robot_modules_display()

	if (hasExpanded)
		resize = 0.5
		hasExpanded = FALSE
		update_transform()
	logevent("Chassis model has been reset.")
	log_silicon("CYBORG: [key_name(src)] has reset their cyborg model.")
	model.transform_to(/obj/item/robot_model)

	// Remove upgrades.
	for(var/obj/item/borg/upgrade/I in upgrades)
		I.forceMove(get_turf(src))

	ionpulse = FALSE
	revert_shell()

	return TRUE

/mob/living/silicon/robot/model/syndicate/ResetModel()
	return

/mob/living/silicon/robot/proc/has_model()
	if(!model || model.type == /obj/item/robot_model)
		. = FALSE
	else
		. = TRUE

/mob/living/silicon/robot/proc/update_module_innate()
	designation = model.name
	if(hands)
		hands.icon_state = model.model_select_icon

	REMOVE_TRAITS_IN(src, MODEL_TRAIT)
	if(model.model_traits)
		for(var/trait in model.model_traits)
			ADD_TRAIT(src, trait, MODEL_TRAIT)

	hat_offset = model.hat_offset

	INVOKE_ASYNC(src, PROC_REF(updatename))


/mob/living/silicon/robot/proc/place_on_head(obj/item/new_hat)
	if(hat)
		hat.forceMove(get_turf(src))
	hat = new_hat
	new_hat.forceMove(src)
	update_icons()

/**
	*Checking Exited() to detect if a hat gets up and walks off.
	*Drones and pAIs might do this, after all.
*/
/mob/living/silicon/robot/Exited(atom/movable/gone, direction)
	if(hat && hat == gone)
		hat = null
		if(!QDELETED(src)) //Don't update icons if we are deleted.
			update_icons()
	return ..()

///Use this to add upgrades to robots. It'll register signals for when the upgrade is moved or deleted, if not single use.
/mob/living/silicon/robot/proc/add_to_upgrades(obj/item/borg/upgrade/new_upgrade, mob/user)
	if(new_upgrade in upgrades)
		return FALSE
	if(!user.temporarilyRemoveItemFromInventory(new_upgrade)) //calling the upgrade's dropped() proc /before/ we add action buttons
		return FALSE
	if(!new_upgrade.action(src, user))
		to_chat(user, span_danger("Upgrade error."))
		new_upgrade.forceMove(loc) //gets lost otherwise
		return FALSE
	to_chat(user, span_notice("You apply the upgrade to [src]."))
	to_chat(src, "----------------\nNew hardware detected...Identified as \"<b>[new_upgrade]</b>\"...Setup complete.\n----------------")
	if(new_upgrade.one_use)
		logevent("Firmware [new_upgrade] run successfully.")
		qdel(new_upgrade)
		return FALSE
	upgrades += new_upgrade
	new_upgrade.forceMove(src)
	RegisterSignal(new_upgrade, COMSIG_MOVABLE_MOVED, PROC_REF(remove_from_upgrades))
	RegisterSignal(new_upgrade, COMSIG_PARENT_QDELETING, PROC_REF(on_upgrade_deleted))
	logevent("Hardware [new_upgrade] installed successfully.")

///Called when an upgrade is moved outside the robot. So don't call this directly, use forceMove etc.
/mob/living/silicon/robot/proc/remove_from_upgrades(obj/item/borg/upgrade/old_upgrade)
	SIGNAL_HANDLER
	if(loc == src)
		return
	old_upgrade.deactivate(src)
	upgrades -= old_upgrade
	UnregisterSignal(old_upgrade, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))

///Called when an applied upgrade is deleted.
/mob/living/silicon/robot/proc/on_upgrade_deleted(obj/item/borg/upgrade/old_upgrade)
	SIGNAL_HANDLER
	if(!QDELETED(src))
		old_upgrade.deactivate(src)
	upgrades -= old_upgrade
	UnregisterSignal(old_upgrade, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))

/**
 * make_shell: Makes an AI shell out of a cyborg unit
 *
 * Arguments:
 * * board - B.O.R.I.S. module board used for transforming the cyborg into AI shell
 */
/mob/living/silicon/robot/proc/make_shell(obj/item/borg/upgrade/ai/board)
	if(!board)
		upgrades |= new /obj/item/borg/upgrade/ai(src)
	shell = TRUE
	braintype = "AI Shell"
	name = "Empty AI Shell-[ident]"
	real_name = name
	GLOB.available_ai_shells |= src
	if(!QDELETED(builtInCamera))
		builtInCamera.c_tag = real_name //update the camera name too
	diag_hud_set_aishell()

/**
 * revert_shell: Reverts AI shell back into a normal cyborg unit
 */
/mob/living/silicon/robot/proc/revert_shell()
	if(!shell)
		return
	undeploy()
	for(var/obj/item/borg/upgrade/ai/boris in src)
	//A player forced reset of a borg would drop the module before this is called, so this is for catching edge cases
		qdel(boris)
	shell = FALSE
	GLOB.available_ai_shells -= src
	name = "Unformatted Cyborg-[ident]"
	real_name = name
	if(!QDELETED(builtInCamera))
		builtInCamera.c_tag = real_name
	diag_hud_set_aishell()

/**
 * deploy_init: Deploys AI unit into AI shell
 *
 * Arguments:
 * * AI - AI unit that initiated the deployment into the AI shell
 */
/mob/living/silicon/robot/proc/deploy_init(mob/living/silicon/ai/AI)
	real_name = "[AI.real_name] [designation] Shell-[ident]"
	name = real_name
	if(!QDELETED(builtInCamera))
		builtInCamera.c_tag = real_name //update the camera name too
	mainframe = AI
	deployed = TRUE
	set_connected_ai(mainframe)
	mainframe.connected_robots |= src
	lawupdate = TRUE
	lawsync()
	if(radio && AI.radio) //AI keeps all channels, including Syndie if it is a Traitor
		if(AI.radio.syndie)
			radio.make_syndie()
		radio.subspace_transmission = TRUE
		radio.channels = AI.radio.channels
		for(var/chan in radio.channels)
			radio.secure_radio_connections[chan] = add_radio(radio, GLOB.radiochannels[chan])

	diag_hud_set_aishell()
	undeployment_action.Grant(src)

/datum/action/innate/undeployment
	name = "Disconnect from shell"
	desc = "Stop controlling your shell and resume normal core operations."
	button_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "ai_core"

/datum/action/innate/undeployment/Trigger(trigger_flags)
	if(!..())
		return FALSE
	var/mob/living/silicon/robot/R = owner

	R.undeploy()
	return TRUE


/mob/living/silicon/robot/proc/undeploy()
	if(!deployed || !mind || !mainframe)
		return
	mainframe.redeploy_action.Grant(mainframe)
	mainframe.redeploy_action.last_used_shell = src
	mind.transfer_to(mainframe)
	deployed = FALSE
	mainframe.deployed_shell = null
	undeployment_action.Remove(src)
	if(radio) //Return radio to normal
		radio.recalculateChannels()
	if(!QDELETED(builtInCamera))
		builtInCamera.c_tag = real_name //update the camera name too
	diag_hud_set_aishell()
	mainframe.diag_hud_set_deployed()
	if(mainframe.laws)
		mainframe.laws.show_laws(mainframe) //Always remind the AI when switching
	if(mainframe.eyeobj)
		mainframe.eyeobj.setLoc(loc)
	mainframe = null

/mob/living/silicon/robot/attack_ai(mob/user)
	if(shell && (!connected_ai || connected_ai == user))
		var/mob/living/silicon/ai/AI = user
		AI.deploy_to_shell(src)

/mob/living/silicon/robot/mouse_buckle_handling(mob/living/M, mob/living/user)
	//Don't try buckling on INTENT_HARM so that silicons can search people's inventories without loading them
	if(can_buckle && isliving(user) && isliving(M) && !(M in buckled_mobs) && ((user != src) || (!combat_mode)))
		return user_buckle_mob(M, user, check_loc = FALSE)

/mob/living/silicon/robot/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE, buckle_mob_flags= RIDER_NEEDS_ARM)
	if(!is_type_in_typecache(M, can_ride_typecache))
		M.visible_message(span_warning("[M] really can't seem to mount [src]..."))
		return

	if(stat || incapacitated())
		return
	if(model && !model.allow_riding)
		M.visible_message(span_boldwarning("Unfortunately, [M] just can't seem to hold onto [src]!"))
		return

	buckle_mob_flags= RIDER_NEEDS_ARM // just in case
	return ..()

/mob/living/silicon/robot/execute_resist()
	. = ..()
	if(!has_buckled_mobs())
		return
	for(var/mob/unbuckle_me_now as anything in buckled_mobs)
		unbuckle_mob(unbuckle_me_now, FALSE)


/mob/living/silicon/robot/proc/TryConnectToAI()
	set_connected_ai(select_active_ai_with_fewest_borgs(z))
	if(connected_ai)
		lawsync()
		lawupdate = TRUE
		return TRUE
	picturesync()
	return FALSE

/mob/living/silicon/robot/proc/picturesync()
	if(connected_ai?.aicamera && aicamera)
		for(var/i in aicamera.stored)
			connected_ai.aicamera.stored[i] = TRUE
		for(var/i in connected_ai.aicamera.stored)
			aicamera.stored[i] = TRUE

/mob/living/silicon/robot/proc/charge(datum/source, amount, repairs)
	SIGNAL_HANDLER
	if(model)
		model.respawn_consumable(src, amount * 0.005)
	if(cell)
		cell.charge = min(cell.charge + amount, cell.maxcharge)
	if(repairs)
		heal_bodypart_damage(repairs, repairs)

/mob/living/silicon/robot/proc/set_connected_ai(new_ai)
	if(connected_ai == new_ai)
		return
	. = connected_ai
	connected_ai = new_ai
	if(.)
		var/mob/living/silicon/ai/old_ai = .
		old_ai.connected_robots -= src
	lamp_doom = FALSE
	if(connected_ai)
		connected_ai.connected_robots |= src
		lamp_doom = connected_ai.doomsday_device ? TRUE : FALSE
	toggle_headlamp(FALSE, TRUE)

/mob/living/silicon/robot/get_exp_list(minutes)
	. = ..()

	var/datum/job/cyborg/cyborg_job_ref = SSjob.GetJobType(/datum/job/cyborg)

	.[cyborg_job_ref.title] = minutes

/mob/living/silicon/robot/proc/untip_roleplay()
	to_chat(src, span_notice("Your frustration has empowered you! You can now right yourself faster!"))

/mob/living/silicon/robot/update_fire_overlay(stacks, on_fire, last_icon_state, suffix = "")
	var/fire_icon = "generic_fire[suffix]"

	if(!GLOB.fire_appearances[fire_icon])
		var/mutable_appearance/new_fire_overlay = mutable_appearance('icons/mob/effects/onfire.dmi', fire_icon, -FIRE_LAYER)
		new_fire_overlay.appearance_flags = RESET_COLOR
		GLOB.fire_appearances[fire_icon] = new_fire_overlay

	if(stacks && on_fire)
		if(last_icon_state == fire_icon)
			return last_icon_state
		add_overlay(GLOB.fire_appearances[fire_icon])
		return fire_icon

	if(!last_icon_state)
		return last_icon_state

	cut_overlay(GLOB.fire_appearances[fire_icon])
	return null

/// Draw power from the robot
/mob/living/silicon/robot/proc/draw_power(power_to_draw)
	cell?.use(power_to_draw)
