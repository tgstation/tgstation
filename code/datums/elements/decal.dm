/datum/element/decal
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	var/cleanable
	var/description
	var/mutable_appearance/pic

/datum/element/decal/Attach(atom/target, _icon, _icon_state, _dir, _cleanable=FALSE, _color, _layer=TURF_LAYER, _description, _alpha=255)
	. = ..()
	if(!isatom(target) || !generate_appearance(_icon, _icon_state, _dir, _layer, _color, _alpha, target))
		return ELEMENT_INCOMPATIBLE
	description = _description
	cleanable = _cleanable

	RegisterSignal(target,COMSIG_ATOM_UPDATE_OVERLAYS,.proc/apply_overlay, TRUE)
	if(target.flags_1 & INITIALIZED_1)
		target.update_icon() //could use some queuing here now maybe.
	else
		RegisterSignal(target,COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE,.proc/late_update_icon, TRUE)
	if(isitem(target))
		INVOKE_ASYNC(target, /obj/item/.proc/update_slot_icon, TRUE)
	if(_dir)
		RegisterSignal(target, COMSIG_ATOM_DIR_CHANGE, .proc/rotate_react,TRUE)
	if(_cleanable)
		RegisterSignal(target, COMSIG_COMPONENT_CLEAN_ACT, .proc/clean_react,TRUE)
	if(_description)
		RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/examine,TRUE)

/datum/element/decal/proc/generate_appearance(_icon, _icon_state, _dir, _layer, _color, _alpha, source)
	if(!_icon || !_icon_state)
		return FALSE
	var/temp_image = image(_icon, null, _icon_state, _layer, _dir)
	pic = new(temp_image)
	pic.color = _color
	pic.alpha = _alpha
	return TRUE

/datum/element/decal/Detach(atom/source, force)
	UnregisterSignal(source, list(COMSIG_ATOM_DIR_CHANGE, COMSIG_COMPONENT_CLEAN_ACT, COMSIG_PARENT_EXAMINE, COMSIG_ATOM_UPDATE_OVERLAYS))
	source.update_icon()
	if(isitem(source))
		INVOKE_ASYNC(source, /obj/item/.proc/update_slot_icon)
	return ..()

/datum/element/decal/proc/late_update_icon(atom/source)
	SIGNAL_HANDLER

	if(source && istype(source))
		source.update_icon()
		UnregisterSignal(source,COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE)


/datum/element/decal/proc/apply_overlay(atom/source, list/overlay_list)
	SIGNAL_HANDLER

	overlay_list += pic


/datum/element/decal/proc/rotate_react(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER

	if(old_dir == new_dir)
		return
	Detach(source)
	source.AddElement(/datum/element/decal, pic.icon, pic.icon_state, new_dir, cleanable, pic.color, pic.layer, description, pic.alpha)

/datum/element/decal/proc/clean_react(datum/source, clean_types)
	SIGNAL_HANDLER

	if(clean_types & cleanable)
		Detach(source)
		return COMPONENT_CLEANED
	return NONE

/datum/element/decal/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += description
