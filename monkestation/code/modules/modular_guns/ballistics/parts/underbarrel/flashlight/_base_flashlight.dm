/obj/item/attachment/underbarrel/flashlight
	name = "generic flashlight"
	///the flashlight we store
	var/obj/item/flashlight/seclite/light_object
	/// A weakref to the item action we add with the light.
	var/datum/weakref/toggle_action_ref
	/// are we toggled on?
	var/toggled = FALSE

/obj/item/attachment/underbarrel/flashlight/unique_attachment_effects(obj/item/gun/modular)
	RegisterSignal(modular, COMSIG_ITEM_UI_ACTION_CLICK, PROC_REF(on_action_click))

	light_object = new /obj/item/flashlight/seclite(modular)

	light_object.set_light_flags(light_object.light_flags | LIGHT_ATTACHED)
	// We may already exist within in our parent's contents... But if we don't move it over now
	if(light_object.loc != modular)
		light_object.forceMove(modular)

	// We already have an action for the light for some reason? Clean it up
	if(toggle_action_ref?.resolve())
		stack_trace("[type] - add_light had an existing toggle action when add_light was called.")
		QDEL_NULL(toggle_action_ref)

	var/datum/action/item_action/toggle_seclight/toggle_action = modular.add_item_action(/datum/action/item_action/toggle_seclight)
	toggle_action_ref = WEAKREF(toggle_action)
	modular.update_item_action_buttons()

/// Signal proc for [COMSIG_ITEM_UI_ACTION_CLICK] that toggles our light on and off if our action button is clicked.
/obj/item/attachment/underbarrel/flashlight/proc/on_action_click(obj/item/source, mob/user, datum/action)
	SIGNAL_HANDLER

	// This isn't OUR action specifically, we don't care.
	if(!IS_WEAKREF_OF(action, toggle_action_ref))
		return

	// Toggle light fails = no light attached = shouldn't be possible
	if(!toggle_light(user))
		CRASH("[type] - on_action_click somehow both HAD AN ACTION and also HAD A TRIGGERABLE ACTION, without having an attached light.")

	return COMPONENT_ACTION_HANDLED

/obj/item/attachment/underbarrel/flashlight/proc/toggle_light(mob/user)
	if(!light_object)
		return FALSE

	light_object.on = !light_object.on
	light_object.update_brightness()
	if(user)
		user.balloon_alert(user, "[light_object.name] toggled [light_object.on ? "on":"off"]")

	playsound(light_object, 'sound/weapons/empty.ogg', 100, TRUE)
	toggled = !toggled
	return TRUE
