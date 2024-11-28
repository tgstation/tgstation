/datum/element/decal/blood

/datum/element/decal/blood/Attach(datum/target, _icon, _icon_state, _dir, _plane, _layer, _alpha, _color, _smoothing, _cleanable=CLEAN_TYPE_BLOOD, _description, mutable_appearance/_pic)
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	. = ..()
	RegisterSignal(target, COMSIG_ATOM_GET_EXAMINE_NAME, PROC_REF(get_examine_name), TRUE)

/datum/element/decal/blood/Detach(atom/source)
	UnregisterSignal(source, COMSIG_ATOM_GET_EXAMINE_NAME)
	if(isitem(source))
		var/obj/item/source_item = source
		REMOVE_KEEP_TOGETHER(source_item, type)
	return ..()

/datum/element/decal/blood/generate_appearance(_icon, _icon_state, _dir, _plane, _layer, _color, _alpha, _smoothing, source)
	var/obj/item/source_item = source
	ADD_KEEP_TOGETHER(source_item, type)
	var/scale_factor_x = source_item.get_cached_width()/ICON_SIZE_X
	var/scale_factor_y = source_item.get_cached_height()/ICON_SIZE_Y
	var/mutable_appearance/blood_splatter = mutable_appearance('icons/effects/blood.dmi', "itemblood", appearance_flags = RESET_COLOR) //MA of the blood that we apply
	blood_splatter.transform = blood_splatter.transform.Scale(scale_factor_x, scale_factor_y)
	blood_splatter.blend_mode = BLEND_INSET_OVERLAY
	blood_splatter.color = _color
	pic = blood_splatter
	return TRUE

/datum/element/decal/blood/proc/get_examine_name(atom/source, mob/user, list/override)
	SIGNAL_HANDLER

	override[EXAMINE_POSITION_BEFORE] = "blood-stained"
