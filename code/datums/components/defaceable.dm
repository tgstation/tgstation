/// Lets you graffiti on an object
/datum/component/defaceable
	/// Icon file from which to draw our overlay
	var/icon
	/// Icon states to draw from our file, optionally use as a list key for TRUE to skip recolouring that icon state
	var/list/icon_states
	/// String description of what you have drawn
	var/drawing_of
	/// What colour have we been drawn with?
	var/ink_colour
	/// Optional callback called when we are drawn on, we pass in the ink colour
	var/datum/callback/on_defaced
	/// Our overlays
	var/list/cached_overlays = list()

/datum/component/defaceable/Initialize(icon, list/icon_states, drawing_of, datum/callback/on_defaced)
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.icon = icon
	src.icon_states = icon_states
	src.drawing_of = drawing_of
	src.on_defaced = on_defaced

/datum/component/defaceable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_drawn))

/datum/component/defaceable/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_ITEM_INTERACTION, COMSIG_ATOM_EXAMINE, COMSIG_COMPONENT_CLEAN_ACT, COMSIG_ATOM_UPDATE_OVERLAYS))
	var/atom/atom_parent = parent
	atom_parent.update_appearance(UPDATE_OVERLAYS)

/// See if someone can draw on us
/datum/component/defaceable/proc/on_drawn(atom/source, mob/living/user, obj/item/tool)
	SIGNAL_HANDLER
	if (user.combat_mode)
		return
	var/ink_colour
	if(istype(tool, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/crayon = tool
		ink_colour = crayon.paint_color
	else if(istype(tool, /obj/item/pen))
		var/obj/item/pen/pen = tool
		ink_colour = pen.colour

	if (!ink_colour)
		return

	ADD_TRAIT(parent, TRAIT_DEFACED, ref(src))

	on_defaced?.Invoke(ink_colour)

	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_cleaned))

	if (drawing_of)
		RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))

	if (icon && icon_states)
		for (var/state in icon_states)
			var/mutable_appearance/appearance = mutable_appearance(icon, state)
			if (!icon_states[state])
				appearance.color = ink_colour
			cached_overlays += appearance
		RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	source.update_appearance(UPDATE_OVERLAYS)

	UnregisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION)

	return ITEM_INTERACT_SUCCESS

/// Render our beautiful drawing
/datum/component/defaceable/proc/on_update_overlays(atom/source, list/overlays)
	SIGNAL_HANDLER
	overlays += cached_overlays

/// Wash it off
/datum/component/defaceable/proc/on_cleaned(atom/source, clean_types)
	SIGNAL_HANDLER
	if (!(clean_types & (CLEAN_WASH|CLEAN_SCRUB)))
		return

	cached_overlays = list()
	REMOVE_TRAIT(parent, TRAIT_DEFACED, ref(src))
	RegisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_drawn))
	UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE, COMSIG_COMPONENT_CLEAN_ACT, COMSIG_ATOM_UPDATE_OVERLAYS))
	source.update_appearance(UPDATE_OVERLAYS)

/// See it there
/datum/component/defaceable/proc/on_examined(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("Someone has crudely drawn [drawing_of] on [source.p_them()].")
