/datum/action
	var/name = "Generic Action"
	var/desc
	var/datum/target
	var/check_flags = NONE
	var/processing = FALSE
	var/atom/movable/screen/movable/action_button/button = null
	var/buttontooltipstyle = ""
	var/transparent_when_unavailable = TRUE

	var/button_icon = 'icons/mob/actions/backgrounds.dmi' //This is the file for the BACKGROUND icon
	var/background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND //And this is the state for the background icon

	var/icon_icon = 'icons/hud/actions.dmi' //This is the file for the ACTION icon
	var/button_icon_state = "default" //And this is the state for the action icon
	var/mob/owner
	///All mobs that are sharing our action button.
	var/list/sharers = list()

/datum/action/New(Target)
	link_to(Target)
	button = new
	button.linked_action = src
	button.name = name
	button.actiontooltipstyle = buttontooltipstyle
	if(desc)
		button.desc = desc

/datum/action/proc/link_to(Target)
	target = Target
	RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/clear_ref, override = TRUE)

	if(isatom(target))
		RegisterSignal(target, COMSIG_ATOM_UPDATED_ICON, .proc/on_target_update_icon)

	if(istype(target, /datum/mind))
		RegisterSignal(target, COMSIG_MIND_TRANSFERRED, .proc/on_target_mind_swapped)

/datum/action/Destroy()
	if(owner)
		Remove(owner)
	target = null
	QDEL_NULL(button)
	return ..()

/datum/action/proc/Grant(mob/M)
	if(M)
		if(owner)
			if(owner == M)
				return
			Remove(owner)
		owner = M
		RegisterSignal(owner, COMSIG_PARENT_QDELETING, .proc/clear_ref, override = TRUE)

		//button id generation
		var/counter = 0
		var/bitfield = 0
		for(var/datum/action/A in M.actions)
			if(A.name == name && A.button.id)
				counter += 1
				bitfield |= A.button.id
		bitfield = ~bitfield
		var/bitflag = 1
		for(var/i in 1 to (counter + 1))
			if(bitfield & bitflag)
				button.id = bitflag
				break
			bitflag *= 2

		LAZYADD(M.actions, src)
		if(M.client)
			M.client.screen += button
			button.locked = M.client.prefs.read_preference(/datum/preference/toggle/buttons_locked) || button.id ? M.client.prefs.action_buttons_screen_locs["[name]_[button.id]"] : FALSE //even if it's not defaultly locked we should remember we locked it before
			button.moved = button.id ? M.client.prefs.action_buttons_screen_locs["[name]_[button.id]"] : FALSE
		M.update_action_buttons()
	else
		Remove(owner)

/datum/action/proc/clear_ref(datum/ref)
	SIGNAL_HANDLER
	if(ref == owner)
		Remove(owner)
	if(ref == target)
		qdel(src)

/datum/action/proc/Remove(mob/M)
	for(var/datum/weakref/reference as anything in sharers)
		var/mob/freeloader = reference.resolve()
		if(!freeloader)
			continue
		Unshare(freeloader)
	sharers = null
	if(M)
		if(M.client)
			M.client.screen -= button
		LAZYREMOVE(M.actions, src)
		M.update_action_buttons()
	if(owner)
		UnregisterSignal(owner, COMSIG_PARENT_QDELETING)
		if(target == owner)
			RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/clear_ref)
		owner = null
	if(button)
		button.moved = FALSE //so the button appears in its normal position when given to another owner.
		button.locked = FALSE
		button.id = null

/datum/action/proc/Trigger(trigger_flags)
	if(!IsAvailable())
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER, src) & COMPONENT_ACTION_BLOCK_TRIGGER)
		return FALSE
	return TRUE


/datum/action/proc/IsAvailable()
	if(!owner)
		return FALSE
	if((check_flags & AB_CHECK_HANDS_BLOCKED) && HAS_TRAIT(owner, TRAIT_HANDS_BLOCKED))
		return FALSE
	if((check_flags & AB_CHECK_IMMOBILE) && HAS_TRAIT(owner, TRAIT_IMMOBILIZED))
		return FALSE
	if((check_flags & AB_CHECK_LYING) && isliving(owner))
		var/mob/living/action_user = owner
		if(action_user.body_position == LYING_DOWN)
			return FALSE
	if((check_flags & AB_CHECK_CONSCIOUS) && owner.stat != CONSCIOUS)
		return FALSE
	return TRUE


/datum/action/proc/UpdateButtonIcon(status_only = FALSE, force = FALSE)
	if(button)
		if(!status_only)
			button.name = name
			button.desc = desc
			if(owner?.hud_used && background_icon_state == ACTION_BUTTON_DEFAULT_BACKGROUND)
				var/list/settings = owner.hud_used.get_action_buttons_icons()
				if(button.icon != settings["bg_icon"])
					button.icon = settings["bg_icon"]
				if(button.icon_state != settings["bg_state"])
					button.icon_state = settings["bg_state"]
			else
				if(button.icon != button_icon)
					button.icon = button_icon
				if(button.icon_state != background_icon_state)
					button.icon_state = background_icon_state

			ApplyIcon(button, force)

		if(!IsAvailable())
			button.color = transparent_when_unavailable ? rgb(128,0,0,128) : rgb(128,0,0)
		else
			button.color = rgb(255,255,255,255)
			return TRUE

/datum/action/proc/ApplyIcon(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(icon_icon && button_icon_state && ((current_button.button_icon_state != button_icon_state) || force))
		current_button.cut_overlays(TRUE)
		current_button.add_overlay(mutable_appearance(icon_icon, button_icon_state))
		current_button.button_icon_state = button_icon_state

/datum/action/proc/on_target_update_icon(datum/source)
	SIGNAL_HANDLER

	UpdateButtonIcon()

/datum/action/proc/on_target_mind_swapped(datum/mind/source, mob/old_current)
	SIGNAL_HANDLER

	Grant(source.current)

//Adds our action button to the screen of another player
/datum/action/proc/Share(mob/freeloader)
	if(!freeloader.client)
		return
	sharers += WEAKREF(freeloader)
	freeloader.client.screen += button
	freeloader.actions += src
	freeloader.update_action_buttons()

//Removes our action button from the screen of another player
/datum/action/proc/Unshare(mob/freeloader)
	if(!freeloader.client)
		return
	for(var/freeloader_reference in sharers)
		if(IS_WEAKREF_OF(freeloader, freeloader_reference))
			sharers -= freeloader_reference
			break
	freeloader.client.screen -= button
	freeloader.actions -= src
	freeloader.update_action_buttons()
