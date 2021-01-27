/**
 * Decals that support smoothing with the parent atom
 *
 * Currently only supports bitmask smoothing
 */
/datum/element/decal/smoothing
	/// The icon state used as the base of the smoothed icon state
	var/base_icon_state
	/// The smoothing junction used to generate the smoothed icon state
	var/smoothing_junction

/datum/element/decal/smoothing/Attach(atom/target, _icon, _icon_state, _dir, _cleanable=FALSE, _color, _layer=TURF_LAYER, _plane=FLOOR_PLANE, _description, _alpha=255, _smoothing_junction=0)
	base_icon_state = _icon_state
	smoothing_junction = _smoothing_junction
	_icon_state = "[_icon_state]-[_smoothing_junction]"
	. = ..()
	if(. & ELEMENT_INCOMPATIBLE)
		return
	RegisterSignal(target, COMSIG_ATOM_SMOOTH_BITMASK, .proc/smooth_react)

/datum/element/decal/smoothing/Detach(atom/source, force)
	UnregisterSignal(source, COMSIG_ATOM_SMOOTH_BITMASK)
	return ..()


/datum/element/decal/smoothing/rotate_react(datum/source, old_dir, new_dir)
	// SIGNAL_HANDLER <-- Already defined on parent. We can't define it again and we can't call parent. So we're stuck.
	if(old_dir == new_dir)
		return
	Detach(source)
	source.AddElement(/datum/element/decal/smoothing, pic.icon, base_icon_state, new_dir, cleanable, pic.color, pic.layer, pic.plane, description, pic.alpha, smoothing_junction)

/// Reacts to the source atom smoothing
/datum/element/decal/smoothing/proc/smooth_react(datum/source, old_junction, new_junction)
	SIGNAL_HANDLER

	if(old_junction == new_junction)
		return
	Detach(source)
	source.AddElement(/datum/element/decal/smoothing, pic.icon, base_icon_state, pic.dir, cleanable, pic.color, pic.layer, pic.plane, description, pic.alpha, new_junction)
