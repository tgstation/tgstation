/// Adds clickable balloons whenever someone holds the examine key (is it still shift in the future?)
/datum/component/examine_balloon
	/// Store the overlays applied in the previous turn and clean them up (because of how managed_overlays checks for changes we need to do this manually)
	var/list/previous_overlays
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

/datum/component/examine_balloon/Initialize(pixel_y_offset = 28, pixel_y_offset_arrow = 16, size_upscaling = 1)
	. = ..()

	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.pixel_y_offset = pixel_y_offset
	src.size_upscaling = size_upscaling
	src.pixel_y_offset_arrow = pixel_y_offset_arrow

	var/atom/atom_parent = parent

	// We use UPDATED_ICON specifically because we need to be last in the icon chain, even if UPDATE_OVERLAYS would otherwise be more apt
	RegisterSignal(atom_parent, COMSIG_ATOM_UPDATED_ICON, PROC_REF(on_updated_icon))

	atom_parent.update_icon(UPDATE_OVERLAYS)

/datum/component/examine_balloon/proc/on_updated_icon(atom/movable/parent, updates)
	SIGNAL_HANDLER

	if(!(updates & UPDATE_OVERLAYS))
		return

	// Generally south facing directions are already obvious, so we dont add a hologram (south is the default exception dont shoot me)
	if(!(parent.dir & draw_in_dirs))
		return

	parent.cut_overlay(previous_overlays)

	// Make a copy of the wallmount and force it south
	var/mutable_appearance/hologram = make_mutable_appearance_directional(new /mutable_appearance(parent), SOUTH)
	SET_PLANE_EXPLICIT(hologram, EXAMINE_BALLOONS_PLANE, parent)

	hologram.pixel_w = 0
	hologram.pixel_x = 0
	hologram.pixel_y = pixel_y_offset
	hologram.pixel_z = 0

	// We need to set all our overlay's planes to the wallmount balloons plane, or we get stuff like emissives sticking through the lighting plane
	var/list/new_overlays = list()
	for(var/mutable_appearance/immutable_appearance as anything in parent.overlays)
		var/mutable_appearance/actually_mutable_appearance = new(immutable_appearance)
		if(PLANE_TO_TRUE(actually_mutable_appearance.plane) != FLOAT_PLANE)
			continue
		new_overlays += actually_mutable_appearance

	hologram.overlays = new_overlays

	hologram.transform = hologram.transform.Scale(size_upscaling, size_upscaling)
	hologram.alpha = hologram_alpha

	var/mutable_appearance/examine_arrow = mutable_appearance(
		'icons/effects/effects.dmi',
		"examine_arrow",
	)

	examine_arrow.pixel_y = pixel_y_offset_arrow

	SET_PLANE_EXPLICIT(examine_arrow, EXAMINE_BALLOONS_PLANE, parent)

	previous_overlays = list(hologram, examine_arrow)

	parent.add_overlay(previous_overlays)

