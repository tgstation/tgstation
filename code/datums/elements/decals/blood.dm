/datum/element/decal/blood
	/// Whenever the parent atom has a color filter applied to it, and thus needs additional overlay handling
	var/uses_filter = FALSE

/datum/element/decal/blood/Attach(datum/target, _icon, _icon_state, _dir, _plane, _layer, _alpha, _color, _smoothing, _cleanable=CLEAN_TYPE_BLOOD, _description, mutable_appearance/_pic, _uses_filter)
	if (!isitem(target))
		return ELEMENT_INCOMPATIBLE

	var/obj/item/as_item = target
	if (_uses_filter != !isnull(as_item.cached_color_filter))
		as_item.AddElement(type, _icon, _icon_state, _dir, _plane, _layer, _alpha, _color, _smoothing, _cleanable, _description, _pic, !isnull(as_item.cached_color_filter))
		return

	uses_filter = _uses_filter
	. = ..()
	RegisterSignal(as_item, COMSIG_ATOM_GET_EXAMINE_NAME, PROC_REF(get_examine_name), TRUE)
	RegisterSignal(as_item, COMSIG_ATOM_COLOR_UPDATED, PROC_REF(on_color_update), TRUE)

/datum/element/decal/blood/Detach(atom/source)
	UnregisterSignal(source, list(COMSIG_ATOM_GET_EXAMINE_NAME, COMSIG_ATOM_COLOR_UPDATED))
	if (isitem(source))
		var/obj/item/source_item = source
		REMOVE_KEEP_TOGETHER(source_item, type)
	return ..()

/datum/element/decal/blood/generate_appearance(_icon, _icon_state, _dir, _plane, _layer, _color, _alpha, _smoothing, source)
	var/obj/item/as_item = source
	ADD_KEEP_TOGETHER(as_item, type)
	var/icon/icon_for_size = icon(as_item.icon, as_item.icon_state)
	var/scale_factor_x = icon_for_size.Width()/ICON_SIZE_X
	var/scale_factor_y = icon_for_size.Height()/ICON_SIZE_Y
	var/mutable_appearance/blood_splatter = mutable_appearance('icons/effects/blood.dmi', "itemblood", appearance_flags = RESET_COLOR) //MA of the blood that we apply
	blood_splatter.transform = blood_splatter.transform.Scale(scale_factor_x, scale_factor_y)
	blood_splatter.blend_mode = BLEND_INSET_OVERLAY
	blood_splatter.color = _color
	if (uses_filter)
		blood_splatter.appearance_flags |= KEEP_APART
		if (!as_item.render_target)
			as_item.render_target = "blood_target_[REF(as_item)]"
		blood_splatter.add_filter("blood_cutout", -1, alpha_mask_filter(render_source = as_item.render_target))
	pic = blood_splatter
	return TRUE

/datum/element/decal/blood/proc/get_examine_name(atom/source, mob/user, list/override)
	SIGNAL_HANDLER

	override[EXAMINE_POSITION_BEFORE] = "blood-stained"

/datum/element/decal/blood/proc/on_color_update(obj/item/source, color_updated)
	SIGNAL_HANDLER

	if (!color_updated || uses_filter == !isnull(source.cached_color_filter))
		return

	Detach(source)
	source.AddElement(type, pic.icon, base_icon_state, directional, pic.plane, pic.layer, pic.alpha, pic.color, smoothing, cleanable, description, null, !isnull(source.cached_color_filter))
	return COMPONENT_CANCEL_COLOR_APPEARANCE_UPDATE
