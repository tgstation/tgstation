/datum/element/decal/blood

/datum/element/decal/blood/Attach(datum/target, _icon, _icon_state, _dir, _plane, _layer, _alpha, _color, _smoothing, _cleanable=CLEAN_TYPE_BLOOD, _description, mutable_appearance/_pic)
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	. = ..()
	RegisterSignal(target, COMSIG_ATOM_GET_EXAMINE_NAME, PROC_REF(get_examine_name), TRUE)

/datum/element/decal/blood/Detach(atom/source)
	UnregisterSignal(source, COMSIG_ATOM_GET_EXAMINE_NAME)
	return ..()

/datum/element/decal/blood/generate_appearance(_icon, _icon_state, _dir, _plane, _layer, _color, _alpha, _smoothing, source)
	var/obj/item/I = source
	if(!_icon)
		_icon = 'icons/effects/blood.dmi'
	if(!_icon_state)
		_icon_state = "itemblood"
	var/icon = I.icon
	var/icon_state = I.icon_state
	if(!icon || !icon_state)
		// It's something which takes on the look of other items, probably
		icon = I.icon
		icon_state = I.icon_state
	var/icon/icon_for_size = icon(icon, icon_state)
	var/scale_factor_x = icon_for_size.Width()/world.icon_size
	var/scale_factor_y = icon_for_size.Height()/world.icon_size
	var/static/list/blood_splatter_appearances = list()
	//try to find a pre-processed blood-splatter. otherwise, make a new one
	var/index = "[scale_factor_x]-[scale_factor_y]"
	pic = blood_splatter_appearances[index]
	pic.color = _color

	if(!pic)
		var/mutable_appearance/blood_splatter = mutable_appearance(_icon, _icon_state, appearance_flags = RESET_COLOR) //MA of the blood that we apply
		blood_splatter.transform = blood_splatter.transform.Scale(scale_factor_x, scale_factor_y)
		blood_splatter.blend_mode = BLEND_INSET_OVERLAY
		pic = blood_splatter
		blood_splatter_appearances[index] = pic
	return TRUE

/datum/element/decal/blood/proc/get_examine_name(datum/source, mob/user, list/override)
	SIGNAL_HANDLER

	var/atom/A = source
	override[EXAMINE_POSITION_ARTICLE] = A.gender == PLURAL? "some" : "a"
	override[EXAMINE_POSITION_BEFORE] = " blood-stained "
	return COMPONENT_EXNAME_CHANGED
