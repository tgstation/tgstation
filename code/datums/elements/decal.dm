/datum/element/decal
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	var/cleanable
	var/description
	/// If true this was initialized with no set direction - will follow the parent dir.
	var/directional
	var/mutable_appearance/pic

/// Remove old decals and apply new decals after rotation as necessary
/datum/controller/subsystem/processing/dcs/proc/rotate_decals(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER

	if(old_dir == new_dir)
		return
	var/list/resulting_decals_params = list() // param lists
	var/list/old_decals = list() //instances

	if(!source.comp_lookup || !source.comp_lookup[COMSIG_ATOM_UPDATE_OVERLAYS])
		//should probably also unregister itself
		return

	if(length(source.comp_lookup[COMSIG_ATOM_UPDATE_OVERLAYS]))
		for(var/datum/element/decal/decal in source.comp_lookup[COMSIG_ATOM_UPDATE_OVERLAYS])
			old_decals += decal
			resulting_decals_params += list(decal.get_rotated_parameters(old_dir,new_dir))
	else
		var/datum/element/decal/decal = source.comp_lookup[COMSIG_ATOM_UPDATE_OVERLAYS]
		if(!istype(decal))
			return
		old_decals += decal
		resulting_decals_params += list(decal.get_rotated_parameters(old_dir,new_dir))

	//Instead we could generate ids and only remove duplicates to save on churn on four-corners symmetry ?
	for(var/datum/element/decal/decal in old_decals)
		decal.Detach(source)

	for(var/result in resulting_decals_params)
		source.AddElement(/datum/element/decal, result["icon"], result["icon_state"], result["dir"], result["cleanable"], result["color"], result["layer"], result["desc"], result["alpha"])


/datum/element/decal/proc/get_rotated_parameters(old_dir,new_dir)
	var/rotation = 0
	if(directional) //Even when the dirs are the same rotation is coming out as not 0 for some reason
		rotation = SIMPLIFY_DEGREES(dir2angle(new_dir)-dir2angle(old_dir))
		new_dir = turn(pic.dir,-rotation)
	return list(
		"icon" = pic.icon,
		"icon_state" = pic.icon_state,
		"dir" = new_dir,
		"cleanable" = cleanable,
		"color" = pic.color,
		"layer" = pic.layer,
		"desc" = description,
		"alpha" = pic.alpha
	)



/datum/element/decal/Attach(atom/target, _icon, _icon_state, _dir, _cleanable=FALSE, _color, _layer=TURF_LAYER, _description, _alpha=255, mutable_appearance/_pic)
	. = ..()
	if(!isatom(target) || !generate_appearance(_icon, _icon_state, _dir, _layer, _color, _alpha, target))
		return ELEMENT_INCOMPATIBLE
	if(_pic)
		pic = _pic
	description = _description
	cleanable = _cleanable
	directional = _dir

	RegisterSignal(target,COMSIG_ATOM_UPDATE_OVERLAYS,.proc/apply_overlay, TRUE)
	if(target.flags_1 & INITIALIZED_1)
		target.update_appearance() //could use some queuing here now maybe.
	else
		RegisterSignal(target,COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE,.proc/late_update_icon, TRUE)
	if(isitem(target))
		INVOKE_ASYNC(target, /obj/item/.proc/update_slot_icon, TRUE)
	if(_dir)
		SSdcs.RegisterSignal(target,COMSIG_ATOM_DIR_CHANGE, /datum/controller/subsystem/processing/dcs/proc/rotate_decals, TRUE)
	if(_cleanable)
		RegisterSignal(target, COMSIG_COMPONENT_CLEAN_ACT, .proc/clean_react,TRUE)
	if(_description)
		RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/examine,TRUE)

	RegisterSignal(target, COMSIG_TURF_ON_SHUTTLE_MOVE, .proc/shuttle_move_react,TRUE)

/datum/element/decal/proc/generate_appearance(_icon, _icon_state, _dir, _layer, _color, _alpha, source)
	if(!_icon || !_icon_state)
		return FALSE
	var/temp_image = image(_icon, null, _icon_state, _layer, _dir)
	pic = new(temp_image)
	pic.color = _color
	pic.alpha = _alpha
	return TRUE

/datum/element/decal/Detach(atom/source, force)
	UnregisterSignal(source, list(COMSIG_ATOM_DIR_CHANGE, COMSIG_COMPONENT_CLEAN_ACT, COMSIG_PARENT_EXAMINE, COMSIG_ATOM_UPDATE_OVERLAYS, COMSIG_TURF_ON_SHUTTLE_MOVE))
	source.update_appearance()
	if(isitem(source))
		INVOKE_ASYNC(source, /obj/item/.proc/update_slot_icon)
	return ..()

/datum/element/decal/proc/late_update_icon(atom/source)
	SIGNAL_HANDLER

	if(source && istype(source))
		source.update_appearance()
		UnregisterSignal(source,COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE)


/datum/element/decal/proc/apply_overlay(atom/source, list/overlay_list)
	SIGNAL_HANDLER

	overlay_list += pic

/datum/element/decal/proc/clean_react(datum/source, clean_types)
	SIGNAL_HANDLER

	if(clean_types & cleanable)
		Detach(source)
		return COMPONENT_CLEANED
	return NONE

/datum/element/decal/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += description

/datum/element/decal/proc/shuttle_move_react(datum/source, turf/new_turf)
	SIGNAL_HANDLER

	if(new_turf == source)
		return
	Detach(source)
	new_turf.AddElement(/datum/element/decal, pic.icon, pic.icon_state, directional, cleanable, pic.color, pic.layer, description, pic.alpha)
