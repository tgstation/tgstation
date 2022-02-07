/datum/action/item_action/mod
	background_icon_state = "bg_tech_blue"
	icon_icon = 'icons/mob/actions/actions_mod.dmi'
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
	if(ai_action && user != mod.ai)
		return
	else if(!ai_action && user == mod.ai)
		return
	return ..()

/datum/action/item_action/mod/Remove(mob/user)
	var/obj/item/mod/control/mod = target
	if(ai_action && user != mod.ai)
		return
	else if(!ai_action && user == mod.ai)
		return
	return ..()

/datum/action/item_action/mod/Trigger(trigger_flags)
	if(!IsAvailable())
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
		if(!ai_action)
			background_icon_state = "bg_tech"
		UpdateButtonIcon()
		addtimer(CALLBACK(src, .proc/reset_ready), 3 SECONDS)
		return
	var/obj/item/mod/control/mod = target
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

/datum/action/item_action/mod/pinned_module
	desc = "Activate the module."
	/// Overrides the icon applications.
	var/override = FALSE
	/// Module we are linked to.
	var/obj/item/mod/module/module
	/// A ref to the mob we are pinned to.
	var/pinner_ref

/datum/action/item_action/mod/pinned_module/New(Target, obj/item/mod/module/linked_module, mob/user)
	if(isAI(user))
		ai_action = TRUE
	..()
	module = linked_module
	name = "Activate [capitalize(linked_module.name)]"
	desc = "Quickly activate [linked_module]."
	icon_icon = linked_module.icon
	button_icon_state = linked_module.icon_state
	RegisterSignal(linked_module, COMSIG_MODULE_ACTIVATED, .proc/on_module_activate)
	RegisterSignal(linked_module, COMSIG_MODULE_DEACTIVATED, .proc/on_module_deactivate)
	RegisterSignal(linked_module, COMSIG_MODULE_USED, .proc/on_module_use)

/datum/action/item_action/mod/pinned_module/Destroy()
	module.pinned_to -= pinner_ref
	module = null
	return ..()

/datum/action/item_action/mod/pinned_module/Grant(mob/user)
	var/user_ref = REF(user)
	if(!pinner_ref)
		pinner_ref = user_ref
		module.pinned_to[pinner_ref] = src
	else if(pinner_ref != user_ref)
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
	var/obj/item/mod/control/mod = target
	if(module == mod.selected_module)
		current_button.add_overlay(image(icon = 'icons/hud/radial.dmi', icon_state = "module_selected", layer = FLOAT_LAYER-0.1))
	else if(module.active)
		current_button.add_overlay(image(icon = 'icons/hud/radial.dmi', icon_state = "module_active", layer = FLOAT_LAYER-0.1))
	if(!COOLDOWN_FINISHED(module, cooldown_timer))
		var/image/cooldown_image = image(icon = 'icons/hud/radial.dmi', icon_state = "module_cooldown")
		current_button.add_overlay(cooldown_image)
		addtimer(CALLBACK(current_button, /image.proc/cut_overlay, cooldown_image), COOLDOWN_TIMELEFT(module, cooldown_timer))


/datum/action/item_action/mod/pinned_module/proc/on_module_activate(datum/source)
	SIGNAL_HANDLER

	UpdateButtonIcon()

/datum/action/item_action/mod/pinned_module/proc/on_module_deactivate(datum/source)
	SIGNAL_HANDLER

	UpdateButtonIcon()

/datum/action/item_action/mod/pinned_module/proc/on_module_use(datum/source)
	SIGNAL_HANDLER

	UpdateButtonIcon()
