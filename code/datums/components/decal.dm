/datum/component/decal
	dupe_mode = COMPONENT_DUPE_ALLOWED
	can_transfer = TRUE
	var/cleanable
	var/description
	var/mutable_appearance/pic

	var/first_dir // This only stores the dir arg from init

/datum/component/decal/Initialize(_icon, _icon_state, _dir, _cleanable=FALSE, _color, _layer=TURF_LAYER, _description, _alpha=255)
	if(!isatom(parent) || !generate_appearance(_icon, _icon_state, _dir, _layer, _color, _alpha))
		return COMPONENT_INCOMPATIBLE
	first_dir = _dir
	description = _description
	cleanable = _cleanable

	apply()

/datum/component/decal/RegisterWithParent()
	if(first_dir)
		RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, .proc/rotate_react)
	if(cleanable != FALSE)
		RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, .proc/clean_react)
	if(description)
		RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)

/datum/component/decal/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_DIR_CHANGE, COMSIG_COMPONENT_CLEAN_ACT, COMSIG_PARENT_EXAMINE))

/datum/component/decal/Destroy()
	remove()
	return ..()

/datum/component/decal/PreTransfer()
	remove()

/datum/component/decal/PostTransfer()
	remove()
	apply()

/datum/component/decal/proc/generate_appearance(_icon, _icon_state, _dir, _layer, _color, _alpha)
	if(!_icon || !_icon_state)
		return FALSE
	// It has to be made from an image or dir breaks because of a byond bug
	var/temp_image = image(_icon, null, _icon_state, _layer, _dir)
	pic = new(temp_image)
	pic.color = _color
	pic.alpha = _alpha
	return TRUE

/datum/component/decal/proc/apply(atom/thing)
	var/atom/master = thing || parent
	RegisterSignal(master,COMSIG_ATOM_UPDATE_OVERLAYS,.proc/apply_overlay)
	if(master.flags_1 & INITIALIZED_1)
		master.update_icon() //could use some queuing here now maybe.
	else
		RegisterSignal(master,COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE,.proc/late_update_icon)
	if(isitem(master))
		addtimer(CALLBACK(master, /obj/item/.proc/update_slot_icon), 0, TIMER_UNIQUE)

/datum/component/decal/proc/late_update_icon(atom/source)
	if(source && istype(source))
		source.update_icon()
		UnregisterSignal(source,COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE)

/datum/component/decal/proc/apply_overlay(atom/source, list/overlay_list)
	overlay_list += pic

/datum/component/decal/proc/remove(atom/thing)
	var/atom/master = thing || parent
	UnregisterSignal(master,COMSIG_ATOM_UPDATE_OVERLAYS)
	master.update_icon()
	if(isitem(master))
		addtimer(CALLBACK(master, /obj/item/.proc/update_slot_icon), 0, TIMER_UNIQUE)

/datum/component/decal/proc/rotate_react(datum/source, old_dir, new_dir)
	if(old_dir == new_dir)
		return
	remove()
	pic.dir = turn(pic.dir, dir2angle(old_dir) - dir2angle(new_dir))
	apply()

/datum/component/decal/proc/clean_react(datum/source, clean_types)
	if(clean_types & cleanable)
		qdel(src)
		return TRUE

/datum/component/decal/proc/examine(datum/source, mob/user, list/examine_list)
	examine_list += description
