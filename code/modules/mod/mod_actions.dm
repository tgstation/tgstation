/datum/action/item_action/mod
	background_icon_state = "bg_tech_blue"
	icon_icon = 'icons/mob/actions/actions_mod.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	/// Whether this action is intended for the AI. Stuff breaks a lot if this is done differently.
	var/ai_action = FALSE
	/// The MODsuit linked to this action
	var/obj/item/mod/control/mod

/datum/action/item_action/mod/New(Target)
	..()
	mod = Target
	if(ai_action)
		background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND

/datum/action/item_action/mod/Grant(mob/user)
	if(ai_action && user != mod.ai)
		return
	else if(!ai_action && user == mod.ai)
		return
	return ..()

/datum/action/item_action/mod/Remove(mob/user)
	if(ai_action && user != mod.ai)
		return
	else if(!ai_action && user == mod.ai)
		return
	return ..()

/datum/action/item_action/mod/Trigger(trigger_flags)
	if(!IsAvailable())
		return FALSE
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
		if(!ai_action)
			background_icon_state = "bg_tech"
		UpdateButtonIcon()
		addtimer(CALLBACK(src, .proc/reset_ready), 3 SECONDS)
		return
	reset_ready()
	mod.toggle_activate(usr)

/// Resets the state requiring to be doubleclicked again.
/datum/action/item_action/mod/activate/proc/reset_ready()
	ready = FALSE
	button_icon_state = initial(button_icon_state)
	if(!ai_action)
		background_icon_state = initial(background_icon_state)
	UpdateButtonIcon()

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
	mod.ui_interact(usr)

/datum/action/item_action/mod/panel/ai
	ai_action = TRUE

/datum/action/item_action/mod/pinned_module
	desc = "Activate the module."
	/// Overrides the icon applications.
	var/override = FALSE
	/// Module we are linked to.
	var/obj/item/mod/module/module
	/// Mob we are pinned to.
	var/mob/pinner

/datum/action/item_action/mod/pinned_module/New(Target, obj/item/mod/module/linked_module, mob/user)
	if(isAI(user))
		ai_action = TRUE
	..()
	module = linked_module
	name = "Activate [capitalize(linked_module.name)]"
	desc = "Quickly activate [linked_module]."
	icon_icon = linked_module.icon
	button_icon_state = linked_module.icon_state
	pinner = user
	RegisterSignal(mod, COMSIG_MOD_MODULE_SELECTED, .proc/on_module_select)
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE, .proc/on_mod_activation)
	RegisterSignal(linked_module, COMSIG_MOD_MODULE_TRIGGERED, .proc/on_module_trigger)

/datum/action/item_action/mod/pinned_module/Grant(mob/user)
	if(user != pinner)
		return
	return ..()

/datum/action/item_action/mod/pinned_module/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	module.on_select()

/datum/action/item_action/mod/pinned_module/ApplyIcon(atom/movable/screen/movable/action_button/current_button, force)
	. = ..(current_button, force = TRUE)
	if(override)
		return
	if(module == mod.selected_module)
		current_button.add_overlay(image(icon = 'icons/hud/radial.dmi', icon_state = "module_selected", layer = FLOAT_LAYER-0.1))
	else if(module.active)
		current_button.add_overlay(image(icon = 'icons/hud/radial.dmi', icon_state = "module_active", layer = FLOAT_LAYER-0.1))
	if(!COOLDOWN_FINISHED(module, cooldown_timer))
		var/image/cooldown_image = image(icon = 'icons/hud/radial.dmi', icon_state = "module_cooldown")
		current_button.add_overlay(cooldown_image)
		addtimer(CALLBACK(current_button, /image.proc/cut_overlay, cooldown_image), COOLDOWN_TIMELEFT(module, cooldown_timer))

/// When the module is selected, we update the icon.
/datum/action/item_action/mod/pinned_module/proc/on_module_select(datum/source, obj/item/mod/module/selected_module)
	SIGNAL_HANDLER

	if(selected_module != mod.selected_module && selected_module != module)
		return
	UpdateButtonIcon()

/// When the suit is being activated, we update the icon.
/datum/action/item_action/mod/pinned_module/proc/on_mod_activation(datum/source, mob/user)
	SIGNAL_HANDLER

	if(mod.active)
		override = TRUE
	else
		override = FALSE
	UpdateButtonIcon()

/// When the module is triggered, we update the icon.
/datum/action/item_action/mod/pinned_module/proc/on_module_trigger(datum/source)
	SIGNAL_HANDLER

	UpdateButtonIcon()
