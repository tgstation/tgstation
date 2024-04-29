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
	var/obj/item/I = source
	ADD_KEEP_TOGETHER(I, type)
	var/icon = I.icon
	var/icon_state = I.icon_state
	if(!icon || !icon_state)
		// It's something which takes on the look of other items, probably
		icon = I.icon
		icon_state = I.icon_state
	var/icon/icon_for_size = icon(icon, icon_state)
	var/scale_factor_x = icon_for_size.Width()/world.icon_size
	var/scale_factor_y = icon_for_size.Height()/world.icon_size
	var/mutable_appearance/blood_splatter = mutable_appearance('icons/effects/blood.dmi', "itemblood", appearance_flags = RESET_COLOR) //MA of the blood that we apply
	blood_splatter.transform = blood_splatter.transform.Scale(scale_factor_x, scale_factor_y)
	blood_splatter.blend_mode = BLEND_INSET_OVERLAY
	blood_splatter.color = _color
	pic = blood_splatter
	return TRUE

/datum/element/decal/blood/proc/get_examine_name(atom/source, mob/user, list/override)
	SIGNAL_HANDLER

	override[EXAMINE_POSITION_BEFORE] = "blood-stained"
