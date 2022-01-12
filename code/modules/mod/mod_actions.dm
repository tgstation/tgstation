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

/datum/action/item_action/mod/Trigger(list/modifiers)
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

/datum/action/item_action/mod/deploy/Trigger(list/modifiers)
	. = ..()
	if(!.)
		return
	if(LAZYACCESS(modifiers, LEFT_CLICK))
		mod.choose_deploy(usr)
	else
		mod.quick_deploy(usr)

/datum/action/item_action/mod/deploy/ai
	ai_action = TRUE

/datum/action/item_action/mod/activate
	name = "Activate MODsuit"
	desc = "LMB: Activate/Deactivate suit with prompt. RMB: Activate/Deactivate suit skipping prompt."
	button_icon_state = "activate"
	/// First time clicking this will set it to TRUE, second time will activate it.
	var/ready = FALSE

/datum/action/item_action/mod/activate/Trigger(list/modifiers)
	. = ..()
	if(!.)
		return
	if(LAZYACCESS(modifiers, LEFT_CLICK) && !ready)
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

/datum/action/item_action/mod/module/Trigger(list/modifiers)
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

/datum/action/item_action/mod/panel/Trigger(list/modifiers)
	. = ..()
	if(!.)
		return
	mod.ui_interact(usr)

/datum/action/item_action/mod/panel/ai
	ai_action = TRUE

/datum/action/item_action/mod/pinned_module
	desc = "Activate the module."
	var/obj/item/mod/module/module
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

/datum/action/item_action/mod/pinned_module/Grant(mob/user)
	if(user != pinner)
		return
	return ..()

/datum/action/item_action/mod/pinned_module/Trigger(list/modifiers)
	. = ..()
	if(!.)
		return
	module.on_select()

/datum/action/item_action/mod/pinned_module/ApplyIcon(atom/movable/screen/movable/action_button/current_button, force)
	. = ..(current_button, force = TRUE)
	if(module == mod.selected_module)
		current_button.add_overlay(image(icon = 'icons/hud/radial.dmi', icon_state = "module_selected", layer = FLOAT_LAYER-0.1))
	else if(module.active)
		current_button.add_overlay(image(icon = 'icons/hud/radial.dmi', icon_state = "module_active", layer = FLOAT_LAYER-0.1))

/// When the module is selected, we update the icon.
/datum/action/item_action/mod/pinned_module/proc/on_module_select(datum/source, obj/item/mod/module/selected_module)
	SIGNAL_HANDLER

	if(selected_module != mod.selected_module && selected_module != module)
		return
	UpdateButtonIcon()

/// When the suit is being activated, we update the icon.
/datum/action/item_action/mod/pinned_module/proc/on_mod_activation(datum/source, mob/user)
	SIGNAL_HANDLER

	UpdateButtonIcon()
