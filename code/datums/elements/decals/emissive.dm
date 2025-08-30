/// A simple subtype intended for emissive decals, does not support directionals
/datum/element/decal/emissive
	/// Emissive behavior to use
	var/emissive_type

/datum/element/decal/emissive/Attach(atom/target, _icon, _icon_state, _dir, _plane, _layer, _alpha, _color, _smoothing, _cleanable, _description, mutable_appearance/_pic, _emissive_type = EMISSIVE_BLOOM)
	emissive_type = _emissive_type
	return ..()

/datum/element/decal/emissive/generate_appearance(_icon, _icon_state, _dir, _plane, _layer, _color, _alpha, _smoothing, source)
	if(!_icon || !_icon_state)
		return FALSE
	pic = emissive_appearance(_icon, isnull(_smoothing) ? _icon_state : "[_icon_state]-[_smoothing]", source, _layer, _alpha, effect_type = emissive_type)
	return TRUE
