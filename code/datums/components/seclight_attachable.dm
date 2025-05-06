/**
 * Component which allows you to attach a seclight to an item,
 * be it a piece of clothing or a tool.
 */
/datum/component/seclite_attachable
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Whether we can remove the light with a screwdriver or not.
	var/is_light_removable = TRUE
	/// If passed, we wil simply update our item's icon_state when a light is attached.
	/// Formatted as parent_base_state-[light_icon-state]-"on"
	var/light_icon_state
	/// If passed, we will add overlays to the item when a light is attached.
	/// This is the icon file it grabs the overlay from.
	var/light_overlay_icon
	/// The state to take from the light overlay icon if supplied.
	var/light_overlay
	/// The X offset of our overlay if supplied.
	var/overlay_x = 0
	/// The Y offset of our overlay if supplied.
	var/overlay_y = 0

	// Internal vars.
	/// A reference to the actual light that's attached.
	var/obj/item/flashlight/seclite/light
	/// A weakref to the item action we add with the light.
	var/datum/weakref/toggle_action_ref
	/// Static typecache of all lights we consider seclites (all lights we can attach).
	var/static/list/valid_lights = typecacheof(list(/obj/item/flashlight/seclite))

/datum/component/seclite_attachable/Initialize(
	obj/item/flashlight/seclite/starting_light,
	is_light_removable = TRUE,
	light_icon_state,
	light_overlay_icon,
	light_overlay,
	overlay_x = 0,
	overlay_y = 0,
)

	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.is_light_removable = is_light_removable
	src.light_icon_state = light_icon_state
	src.light_overlay_icon = light_overlay_icon
	src.light_overlay = light_overlay
	src.overlay_x = overlay_x
	src.overlay_y = overlay_y

	if(istype(starting_light))
		add_light(starting_light)

/datum/component/seclite_attachable/Destroy(force)
	if(light)
		remove_light()
	return ..()

// Inheriting component allows lights to be added externally to things which already have a mount.
/datum/component/seclite_attachable/InheritComponent(
	datum/component/seclite_attachable/new_component,
	original,
	obj/item/flashlight/seclite/starting_light,
	is_light_removable = TRUE,
	light_icon_state,
	light_overlay_icon,
	light_overlay,
	overlay_x,
	overlay_y,
)

	if(!original)
		return

	src.is_light_removable = is_light_removable

	// For the rest of these arguments, default to what already exists
	if(light_icon_state)
		src.light_icon_state = light_icon_state
	if(light_overlay_icon)
		src.light_overlay_icon = light_overlay_icon
	if(light_overlay)
		src.light_overlay = light_overlay
	if(overlay_x)
		src.overlay_x = overlay_x
	if(overlay_x)
		src.overlay_y = overlay_y

	if(istype(starting_light))
		add_light(starting_light)

/datum/component/seclite_attachable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_OBJ_DECONSTRUCT, PROC_REF(on_parent_deconstructed))
	RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(on_light_exit))
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), PROC_REF(on_screwdriver))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON_STATE, PROC_REF(on_update_icon_state))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(parent, COMSIG_ITEM_UI_ACTION_CLICK, PROC_REF(on_action_click))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_SABOTEUR_ACT, PROC_REF(on_hit_by_saboteur))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_parent_deleted))

/datum/component/seclite_attachable/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_OBJ_DECONSTRUCT,
		COMSIG_ATOM_EXITED,
		COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER),
		COMSIG_ATOM_UPDATE_ICON_STATE,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_ITEM_UI_ACTION_CLICK,
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ATOM_EXAMINE,
		COMSIG_ATOM_SABOTEUR_ACT,
		COMSIG_QDELETING,
	))

/// Sets a new light as our current light for our parent.
/datum/component/seclite_attachable/proc/add_light(obj/item/flashlight/new_light, mob/attacher)
	if(light)
		CRASH("[type] tried to add a new light when it already had one.")

	light = new_light

	light.set_light_flags(light.light_flags | LIGHT_ATTACHED)
	// We may already exist within in our parent's contents... But if we don't move it over now
	if(light.loc != parent)
		light.forceMove(parent)

	// We already have an action for the light for some reason? Clean it up
	if(toggle_action_ref?.resolve())
		stack_trace("[type] - add_light had an existing toggle action when add_light was called.")
		QDEL_NULL(toggle_action_ref)

	// Make a new toggle light item action for our parent
	var/obj/item/item_parent = parent
	var/datum/action/item_action/toggle_seclight/toggle_action = item_parent.add_item_action(/datum/action/item_action/toggle_seclight)
	toggle_action_ref = WEAKREF(toggle_action)

	update_light()

/// Removes the current light from our parent.
/datum/component/seclite_attachable/proc/remove_light()
	// Our action may be linked to our parent,
	// but it's really sourced from our light. Get rid of it.
	QDEL_NULL(toggle_action_ref)

	// It is possible the light was removed by being deleted.
	if(!QDELETED(light))
		light.set_light_flags(light.light_flags & ~LIGHT_ATTACHED)
		light.update_brightness()

	light = null
	update_light()

/// Toggles the light within on or off.
/// Returns TRUE if there is a light inside, FALSE otherwise.
/datum/component/seclite_attachable/proc/toggle_light(mob/user)
	if(!light)
		return FALSE

	var/successful_toggle = light.toggle_light(user)
	if(!successful_toggle)
		return TRUE
	user.balloon_alert(user, "[light.name] toggled [light.light_on ? "on":"off"]")
	update_light()
	return TRUE

/// Called after the a light is added, removed, or toggles.
/// Ensures all of our appearances look correct for the new light state.
/datum/component/seclite_attachable/proc/update_light()
	var/obj/item/item_parent = parent
	item_parent.update_appearance()
	item_parent.update_item_action_buttons()

/// Signal proc for [COMSIG_ATOM_EXITED] that handles our light being removed or deleted from our parent.
/datum/component/seclite_attachable/proc/on_light_exit(obj/item/source, atom/movable/gone, direction)
	SIGNAL_HANDLER

	if(gone == light)
		remove_light()

/// Signal proc for [COMSIG_OBJ_DECONSTRUCT] that drops our light to the ground if our parent is deconstructed.
/datum/component/seclite_attachable/proc/on_parent_deconstructed(obj/item/source, disassembled)
	SIGNAL_HANDLER

	// Our light is gone already - Probably destroyed by whatever destroyed our parent. Just remove it.
	if(QDELETED(light) || !is_light_removable)
		remove_light()
		return

	// We were deconstructed in any other way, so we can just drop the light on the ground (which removes it via signal).
	light.forceMove(source.drop_location())

/// Signal proc for [COMSIG_QDELETING] that deletes our light if our parent is deleted.
/datum/component/seclite_attachable/proc/on_parent_deleted(obj/item/source)
	SIGNAL_HANDLER

	QDEL_NULL(light)

/// Signal proc for [COMSIG_ITEM_UI_ACTION_CLICK] that toggles our light on and off if our action button is clicked.
/datum/component/seclite_attachable/proc/on_action_click(obj/item/source, mob/user, datum/action)
	SIGNAL_HANDLER

	// This isn't OUR action specifically, we don't care.
	if(!IS_WEAKREF_OF(action, toggle_action_ref))
		return

	// Toggle light fails = no light attached = shouldn't be possible
	if(!toggle_light(user))
		CRASH("[type] - on_action_click somehow both HAD AN ACTION and also HAD A TRIGGERABLE ACTION, without having an attached light.")

	return COMPONENT_ACTION_HANDLED

/// Signal proc for [COMSIG_ATOM_ATTACKBY] that allows a user to attach a seclite by hitting our parent with it.
/datum/component/seclite_attachable/proc/on_attackby(obj/item/source, obj/item/attacking_item, mob/attacker, list/modifiers)
	SIGNAL_HANDLER

	if(!is_type_in_typecache(attacking_item, valid_lights))
		return

	if(light)
		source.balloon_alert(attacker, "already has \a [light]!")
		return

	if(!attacker.transferItemToLoc(attacking_item, source))
		return

	add_light(attacking_item, attacker)
	source.balloon_alert(attacker, "attached [attacking_item]")
	return COMPONENT_NO_AFTERATTACK

/// Signal proc for [COMSIG_ATOM_TOOL_ACT] via [TOOL_SCREWDRIVER] that removes any attached seclite.
/datum/component/seclite_attachable/proc/on_screwdriver(obj/item/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER

	if(!light || !is_light_removable)
		return

	INVOKE_ASYNC(src, PROC_REF(unscrew_light), source, user, tool)
	return ITEM_INTERACT_BLOCKING

/// Invoked asyncronously from [proc/on_screwdriver]. Handles removing the light from our parent.
/datum/component/seclite_attachable/proc/unscrew_light(obj/item/source, mob/user, obj/item/tool)
	tool?.play_tool_sound(source)
	source.balloon_alert(user, "unscrewed [light]")

	var/obj/item/flashlight/seclite/to_remove = light

	// The forcemove here will call exited on the light, and automatically update our references / etc
	to_remove.forceMove(source.drop_location())
	if(source.Adjacent(user) && !issilicon(user))
		user.put_in_hands(to_remove)

/// Signal proc for [COMSIG_ATOM_EXAMINE] that shows our item can have / does have a seclite attached.
/datum/component/seclite_attachable/proc/on_examine(obj/item/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER

	if(light)
		examine_list += "It has \a [light] [is_light_removable ? "mounted on it with a few <b>screws</b>" : "permanently mounted on it"]."
	else
		examine_list += "It has a mounting point for a <b>seclite</b>."

/// Signal proc for [COMSIG_ATOM_UPDATE_OVERLAYS] that updates our parent with our seclite overlays, if we have some.
/datum/component/seclite_attachable/proc/on_update_overlays(obj/item/source, list/overlays)
	SIGNAL_HANDLER

	// No overlays to add, no reason to run
	if(!light_overlay || !light_overlay_icon)
		return
	// No light, nothing to add
	if(!light)
		return

	var/overlay_state = "[light_overlay][light.light_on ? "_on":""]"
	var/mutable_appearance/flashlight_overlay = mutable_appearance(light_overlay_icon, overlay_state)
	flashlight_overlay.pixel_w = overlay_x
	flashlight_overlay.pixel_z = overlay_y
	overlays += flashlight_overlay

/// Signal proc for [COMSIG_ATOM_UPDATE_ICON_STATE] that updates our parent's icon state, if we have one.
/datum/component/seclite_attachable/proc/on_update_icon_state(obj/item/source)
	SIGNAL_HANDLER

	// No icon state to set, no reason to run
	if(!light_icon_state)
		return

	// Get the "base icon state" to work on
	var/base_state = source.base_icon_state || initial(source.icon_state)
	// Updates our icon state based on our light state.
	if(light)
		source.icon_state = "[base_state]-[light_icon_state][light.light_on ? "-on":""]"

	// Reset their icon state when if we've got no light.
	else if(source.icon_state != base_state)
		// Yes, this might mess with other icon state alterations,
		// but that's the downside of using icon states over overlays.
		source.icon_state = base_state

//turns the light off for a few seconds.
/datum/component/seclite_attachable/proc/on_hit_by_saboteur(datum/source, disrupt_duration)
	. = light.on_saboteur(source, disrupt_duration)
	update_light()
	return .
