/// Adds clickable balloons whenever someone holds the examine key (is it still shift in the future?)
/datum/component/examine_balloon
	/// Offset applied on the hologram
	var/pixel_y_offset
	/// Our x and y size is multiplied by this, for small sprites like buttons
	var/size_upscaling

	/// Offset applied on the bubble
	var/pixel_y_offset_arrow = 16
	/// The alpha we apply to the hologram
	var/hologram_alpha = 200
	/// Add a hologram when we're in these directions
	var/draw_in_dirs = NORTH | EAST | WEST
	/// Balloon holo that is actually displayed to players
	var/obj/effect/abstract/balloon_hologram/balloon
	/*

/datum/component/examine_balloon/Initialize(pixel_y_offset = 28, pixel_y_offset_arrow = 16, size_upscaling = 1)
	. = ..()

	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.pixel_y_offset = pixel_y_offset
	src.size_upscaling = size_upscaling
	src.pixel_y_offset_arrow = pixel_y_offset_arrow

	var/atom/movable/atom_parent = parent
	balloon = new(atom_parent, atom_parent, pixel_y_offset_arrow - pixel_y_offset)
	balloon.pixel_y = pixel_y_offset
	balloon.transform = balloon.transform.Scale(size_upscaling, size_upscaling)
	atom_parent.vis_contents += balloon

	// We use UPDATED_ICON specifically because we need to be last in the icon chain, even if UPDATE_OVERLAYS would otherwise be more apt
	RegisterSignal(atom_parent, COMSIG_ATOM_UPDATED_ICON, PROC_REF(on_updated_icon))
	atom_parent.update_appearance()

/datum/component/examine_balloon/UnregisterFromParent()
	var/atom/movable/atom_parent = parent
	atom_parent.vis_contents -= balloon
	qdel(balloon)

/datum/component/examine_balloon/proc/on_updated_icon(atom/movable/source, updates)
	SIGNAL_HANDLER

	// Generally south facing directions are already obvious, so we dont add a hologram (south is the default exception dont shoot me)
	if(!(source.dir & draw_in_dirs))
		balloon.invisibility = INVISIBILITY_MAXIMUM
		return

	balloon.invisibility = INVISIBILITY_NONE
	balloon.icon = source.icon
	balloon.icon_state = source.icon_state
	balloon.pixel_y = pixel_y_offset

	// We need to set all our overlay's planes to the wallmount balloons plane, or we get stuff like emissives sticking through the lighting plane
	var/list/new_overlays = list()
	for(var/mutable_appearance/immutable_appearance as anything in source.overlays)
		var/mutable_appearance/actually_mutable_appearance = new(immutable_appearance)
		if(PLANE_TO_TRUE(actually_mutable_appearance.plane) != FLOAT_PLANE)
			continue
		new_overlays += actually_mutable_appearance

	var/mutable_appearance/examine_arrow = mutable_appearance('icons/effects/effects.dmi', "examine_arrow", appearance_flags = RESET_COLOR | RESET_TRANSFORM)
	examine_arrow.pixel_y = pixel_y_offset_arrow - balloon.pixel_y
	new_overlays += examine_arrow

	balloon.overlays = new_overlays
	balloon.alpha = hologram_alpha
*/

/obj/effect/abstract/balloon_hologram
	plane = EXAMINE_BALLOONS_PLANE
	/// Atom that we're copying
	var/atom/original
	/// Y offset for our arrow
	var/arrow_offset

/obj/effect/abstract/balloon_hologram/Initialize(mapload, atom/to_copy, arrow_y)
	. = ..()
	if (isnull(to_copy))
		return
	original = to_copy
	name = original.name
	desc = original.desc
	arrow_offset = arrow_y
	update_appearance()

/obj/effect/abstract/balloon_hologram/Destroy(force)
	original = null
	return ..()

/obj/effect/abstract/balloon_hologram/Click(location, control, params)
	var/list/modifiers = params2list(params)
	LAZYREMOVE(modifiers, SHIFT_CLICK)
	original.Click(location, control, list2params(modifiers))
