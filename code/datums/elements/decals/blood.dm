/datum/element/decal/blood
	/// Whenever the parent atom has a color filter applied to it, and thus needs additional overlay handling
	var/uses_filter = FALSE
	/// Emissive alpha of our parent
	var/emissive_alpha = null

/datum/element/decal/blood/Attach(datum/target, _icon, _icon_state, _dir, _plane, _layer, _alpha, _color, _smoothing, _cleanable = CLEAN_TYPE_BLOOD, _description, mutable_appearance/_pic, _uses_filter, _emissive)
	if (!isitem(target))
		return ELEMENT_INCOMPATIBLE

	var/obj/item/as_item = target
	if (_uses_filter != !isnull(as_item.cached_color_filter))
		as_item.AddElement(type, _icon, _icon_state, _dir, _plane, _layer, _alpha, _color, _smoothing, _cleanable, _description, _pic, !isnull(as_item.cached_color_filter), _emissive)
		return

	uses_filter = _uses_filter
	emissive_alpha = _emissive
	. = ..()
	RegisterSignal(as_item, COMSIG_ATOM_GET_EXAMINE_NAME, PROC_REF(get_examine_name), TRUE)
	RegisterSignal(as_item, COMSIG_ATOM_COLOR_UPDATED, PROC_REF(on_color_update), TRUE)

/datum/element/decal/blood/Detach(atom/source)
	UnregisterSignal(source, list(COMSIG_ATOM_GET_EXAMINE_NAME, COMSIG_ATOM_COLOR_UPDATED))
	if (isitem(source))
		var/obj/item/source_item = source
		REMOVE_KEEP_TOGETHER(source_item, type)
	return ..()

/datum/element/decal/blood/generate_appearance(_icon, _icon_state, _dir, _plane, _layer, _color = BLOOD_COLOR_RED, _alpha, _smoothing, source)
	var/obj/item/as_item = source
	ADD_KEEP_TOGETHER(as_item, type)
	var/scale_factor_x = as_item.get_cached_width() / ICON_SIZE_X
	var/scale_factor_y = as_item.get_cached_height() / ICON_SIZE_Y
	var/mutable_appearance/blood_splatter = mutable_appearance('icons/effects/blood.dmi', "itemblood", appearance_flags = RESET_COLOR) //MA of the blood that we apply
	blood_splatter.transform = blood_splatter.transform.Scale(scale_factor_x, scale_factor_y)
	blood_splatter.blend_mode = BLEND_INSET_OVERLAY
	blood_splatter.color = _color
	var/mutable_appearance/emissive_splatter = null
	if (emissive_alpha)
		emissive_splatter = emissive_appearance('icons/effects/blood.dmi', "itemblood", as_item, alpha = emissive_alpha, effect_type = EMISSIVE_NO_BLOOM)
		emissive_splatter.blend_mode = BLEND_INSET_OVERLAY
	if (uses_filter)
		blood_splatter.appearance_flags |= KEEP_APART
		if (!as_item.render_target)
			as_item.render_target = "blood_target_[REF(as_item)]"
		blood_splatter.add_filter("blood_cutout", -1, alpha_mask_filter(render_source = as_item.render_target))
		if (emissive_splatter)
			emissive_splatter.add_filter("blood_cutout", -1, alpha_mask_filter(render_source = as_item.render_target))
	if (emissive_splatter)
		blood_splatter.overlays += emissive_splatter
	pic = blood_splatter
	return TRUE

/datum/element/decal/blood/proc/get_examine_name(atom/source, mob/user, list/override)
	SIGNAL_HANDLER

	var/list/blood_stains = GET_ATOM_BLOOD_DECALS(source)
	if (!length(blood_stains))
		return
	var/datum/blood_type/blood_type = blood_stains[blood_stains[length(blood_stains)]]
	var/blood_descriptor = "blood"
	if(istype(blood_type))
		blood_descriptor = LOWER_TEXT(blood_type.get_blood_name())

	override[EXAMINE_POSITION_BEFORE] = "[blood_descriptor]-stained"

/datum/element/decal/blood/proc/on_color_update(obj/item/source, color_updated)
	SIGNAL_HANDLER

	if (!color_updated || uses_filter == !isnull(source.cached_color_filter))
		return

	Detach(source)
	source.AddElement(type, pic.icon, base_icon_state, directional, pic.plane, pic.layer, pic.alpha, pic.color, smoothing, cleanable, description, null, !isnull(source.cached_color_filter))
	return COMPONENT_CANCEL_COLOR_APPEARANCE_UPDATE
