/// A simple subtype intended for emissive decals, does not support directionals
/datum/element/decal/emissive

/datum/element/decal/emissive/generate_appearance(_icon, _icon_state, _dir, _plane, _layer, _color, _alpha, _smoothing, source)
	if(!_icon || !_icon_state)
		return FALSE
	pic = emissive_appearance(_icon, isnull(_smoothing) ? _icon_state : "[_icon_state]-[_smoothing]", source, _layer, _alpha)
	return TRUE
