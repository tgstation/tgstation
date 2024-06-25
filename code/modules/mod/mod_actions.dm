/datum/action/item_action/mod
	background_icon_state = "bg_mod"
	overlay_icon_state = "bg_mod_border"
	button_icon = 'icons/mob/actions/actions_mod.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	/// Whether this action is intended for the AI. Stuff breaks a lot if this is done differently.
	var/ai_action = FALSE

/datum/action/item_action/mod/New(Target)
	..()
	if(!istype(Target, /obj/item/mod/control))
		qdel(src)
		return
	if(ai_action)
		background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND

/datum/action/item_action/mod/Grant(mob/user)
	var/obj/item/mod/control/mod = target
	if(ai_action && user != mod.ai_assistant)
		return
	else if(!ai_action && user == mod.ai_assistant)
		return
	return ..()

/datum/action/item_action/mod/Remove(mob/user)
	var/obj/item/mod/control/mod = target
	if(ai_action && user != mod.ai_assistant)
		return
	else if(!ai_action && user == mod.ai_assistant)
		return
	return ..()

/datum/action/item_action/mod/Trigger(trigger_flags)
	if(!IsAvailable(feedback = TRUE))
		return FALSE
	var/obj/item/mod/control/mod = target
	if(mod.malfunctioning && prob(75))
		mod.balloon_alert(usr, "button malfunctions!")
		return FALSE
	return TRUE

/datum/action/item_action/mod/deploy
	name = "Deploy MODsuit"
	desc = "LMB: Deploy/Undeploy part. RMB: Deploy/Undeploy full suit."
	button_icon_state = "deploy"

/datum/action/item_action/mod/deploy/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/obj/item/mod/control/mod = target
	if(trigger_flags & TRIGGER_SECONDARY_ACTION)
		mod.quick_deploy(usr)
	else
		mod.choose_deploy(usr)

/datum/action/item_action/mod/deploy/ai
	ai_action = TRUE

/datum/action/item_action/mod/activate
	name = "Activate MODsuit"
	desc = "LMB: Activate/Deactivate suit with prompt. RMB: Activate/Deactivate suit skipping prompt."
	button_icon_state = "activate"
	/// First time clicking this will set it to TRUE, second time will activate it.
	var/ready = FALSE

/datum/action/item_action/mod/activate/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	if(!(trigger_flags & TRIGGER_SECONDARY_ACTION) && !ready)
		ready = TRUE
		button_icon_state = "activate-ready"
		build_all_button_icons()
		addtimer(CALLBACK(src, PROC_REF(reset_ready)), 3 SECONDS)
		return
	var/obj/item/mod/control/mod = target
	reset_ready()
	mod.toggle_activate(usr)

/// Resets the state requiring to be doubleclicked again.
/datum/action/item_action/mod/activate/proc/reset_ready()
	ready = FALSE
	button_icon_state = initial(button_icon_state)
	build_all_button_icons()

/datum/action/item_action/mod/activate/ai
	ai_action = TRUE

/datum/action/item_action/mod/module
	name = "Toggle Module"
	desc = "Toggle a MODsuit module."
	button_icon_state = "module"

/datum/action/item_action/mod/module/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/obj/item/mod/control/mod = target
	mod.quick_module(usr)

/datum/action/item_action/mod/module/ai
	ai_action = TRUE

/datum/action/item_action/mod/panel
	name = "MODsuit Panel"
	desc = "Open the MODsuit's panel."
	button_icon_state = "panel"

/datum/action/item_action/mod/panel/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/obj/item/mod/control/mod = target
	mod.ui_interact(usr)

/datum/action/item_action/mod/panel/ai
	ai_action = TRUE

/datum/action/item_action/mod/pinnable
	/// A reference to the mob we are pinned to.
	var/mob/pinner

/datum/action/item_action/mod/pinnable/New(Target, mob/user)
	. = ..()
	var/obj/item/mod/control/mod = Target
	if(user == mod.ai_assistant)
		ai_action = TRUE
	pinner = user
	RegisterSignal(user, COMSIG_QDELETING, PROC_REF(pinner_deleted))

/datum/action/item_action/mod/pinnable/Grant(mob/user)
	if(pinner != user)
		return
	return ..()

/// If the guy whose UI we are pinned to got deleted
/datum/action/item_action/mod/pinnable/proc/pinner_deleted()
	SIGNAL_HANDLER
	pinner = null
	qdel(src)

/datum/action/item_action/mod/pinnable/module
	desc = "Activate the module."
	/// Overrides the icon applications.
	var/override = FALSE
	/// Module we are linked to.
	var/obj/item/mod/module/module
	/// Timer until we remove our cooldown overlay
	var/cooldown_timer

/datum/action/item_action/mod/pinnable/module/New(Target, mob/user, obj/item/mod/module/linked_module)
	button_icon = linked_module.icon
	button_icon_state = linked_module.icon_state
	. = ..()
	module = linked_module
	module.pinned_to[REF(user)] = src
	if(linked_module.allow_flags & MODULE_ALLOW_INCAPACITATED)
		// clears check hands and check conscious
		check_flags = NONE
	name = "Activate [capitalize(linked_module.name)]"
	desc = "Quickly activate [linked_module]."
	RegisterSignals(linked_module, list(
		COMSIG_MODULE_ACTIVATED,
		COMSIG_MODULE_DEACTIVATED,
		COMSIG_MODULE_USED,
	), PROC_REF(module_interacted_with))
	RegisterSignal(linked_module, COMSIG_MODULE_COOLDOWN_STARTED, PROC_REF(cooldown_started))

/datum/action/item_action/mod/pinnable/module/Destroy()
	deltimer(cooldown_timer)
	UnregisterSignal(module, list(
		COMSIG_MODULE_ACTIVATED,
		COMSIG_MODULE_DEACTIVATED,
		COMSIG_MODULE_COOLDOWN_STARTED,
		COMSIG_MODULE_USED,
	))
	module.pinned_to -= REF(pinner)
	module = null
	pinner = null
	return ..()

/datum/action/item_action/mod/pinnable/module/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	module.on_select()

/datum/action/item_action/mod/pinnable/module/apply_button_overlay(atom/movable/screen/movable/action_button/current_button, force)
	current_button.cut_overlays()
	if(override)
		return ..()

	var/obj/item/mod/control/mod = target
	if(module == mod.selected_module)
		current_button.add_overlay(image(icon = 'icons/hud/radial.dmi', icon_state = "module_selected", layer = FLOAT_LAYER-0.1))
	else if(module.active)
		current_button.add_overlay(image(icon = 'icons/hud/radial.dmi', icon_state = "module_active", layer = FLOAT_LAYER-0.1))
	if(!COOLDOWN_FINISHED(module, cooldown_timer))
		current_button.add_overlay(image(icon = 'icons/hud/radial.dmi', icon_state = "module_cooldown"))
	return ..()

/datum/action/item_action/mod/pinnable/module/proc/module_interacted_with(datum/source)
	SIGNAL_HANDLER

	build_all_button_icons(UPDATE_BUTTON_OVERLAY|UPDATE_BUTTON_STATUS)

/datum/action/item_action/mod/pinnable/module/proc/cooldown_started(datum/source, cooldown_time)
	SIGNAL_HANDLER

	deltimer(cooldown_timer)
	build_all_button_icons(UPDATE_BUTTON_OVERLAY)
	if (cooldown_time == 0)
		return
	cooldown_timer = addtimer(CALLBACK(src, PROC_REF(build_all_button_icons), UPDATE_BUTTON_OVERLAY), cooldown_time + 1, TIMER_STOPPABLE)
