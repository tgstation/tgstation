/// A simple subtype intended for emissive decals, does not support directionals
/datum/element/decal/emissive
	/// Emissive behavior to use
	var/emissive_type

/datum/element/decal/emissive/Attach(atom/target, _icon, _icon_state, _dir, _plane, _layer, _alpha = 255, _color, _smoothing, _cleanable = FALSE, _description, mutable_appearance/_pic, _emissive_type = EMISSIVE_BLOOM)
	emissive_type = _emissive_type
	return ..()

/datum/element/decal/emissive/generate_appearance(_icon, _icon_state, _dir, _plane, _layer, _color, _alpha, _smoothing, source)
	if(!_icon || !_icon_state)
		return FALSE
	pic = emissive_appearance(_icon, isnull(_smoothing) ? _icon_state : "[_icon_state]-[_smoothing]", source, _layer, _alpha, effect_type = emissive_type)
	return TRUE

/datum/element/decal/emissive/shuttle_move_react(datum/source, turf/new_turf)
	if(new_turf == source)
		return
	Detach(source)
	new_turf.AddElement(type, pic.icon, base_icon_state, directional, pic.plane, pic.layer, pic.alpha, pic.color, smoothing, cleanable, description, null, emissive_type)

/datum/element/decal/emissive/smooth_react(atom/source)
	var/smoothing_junction = source.smoothing_junction
	if(smoothing_junction == smoothing)
		return NONE

	Detach(source)
	source.AddElement(type, pic.icon, base_icon_state, directional, PLANE_TO_TRUE(pic.plane), pic.layer, pic.alpha, pic.color, smoothing_junction, cleanable, description, null, emissive_type)
	return NONE
