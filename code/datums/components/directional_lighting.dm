/obj/effect/abstract/directional_lighting
	light_system = MOVABLE_LIGHT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/overlay/light_cone
	name = ""
	icon = 'icons/effects/light_overlays/light_cone.dmi'
	icon_state = "light"
	layer = O_LIGHTING_VISUAL_LAYER
	plane = O_LIGHTING_VISUAL_PLANE
	appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = NONE
	alpha = 110

/datum/component/directional_lighting
	var/obj/effect/abstract/directional_lighting/light_holder_atom
	var/obj/effect/overlay/light_cone/cone
	var/direction = SOUTH
	///Movable atom currently holding the light. Parent might be a flashlight, for example, but that might be held by a mob or something else.
	var/atom/movable/current_holder
	var/light_enabled = FALSE
	var/cast_distance = 2

/datum/component/directional_lighting/Initialize(_range, _power, _color)
	. = ..()
	light_holder_atom = new()
	cone = new()
	cone.transform = cone.transform.Translate(-32, -32)
	if(_range)
		set_range(parent, _range)
	if(_power)
		set_power(parent, _power)
	if(_color)
		set_color(parent, _color)

/datum/component/directional_lighting/Destroy()
	set_holder(null)
	QDEL_NULL(cone)
	QDEL_NULL(light_holder_atom)
	return ..()

/datum/component/directional_lighting/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/on_parent_moved)
	RegisterSignal(parent, COMSIG_ATOM_SET_LIGHT_RANGE, .proc/set_range)
	RegisterSignal(parent, COMSIG_ATOM_SET_LIGHT_POWER, .proc/set_power)
	RegisterSignal(parent, COMSIG_ATOM_SET_LIGHT_COLOR, .proc/set_color)
	RegisterSignal(parent, COMSIG_ATOM_SET_LIGHT_ON, .proc/on_toggle)
	RegisterSignal(parent, COMSIG_ATOM_SET_LIGHT_FLAGS, .proc/on_light_flags_change)
	var/atom/movable/movable_parent = parent
	check_holder()
	set_range(parent, movable_parent.light_range)
	set_power(parent, movable_parent.light_power)
	set_color(parent, movable_parent.light_color)
	on_toggle(parent, movable_parent.light_on)

/datum/component/directional_lighting/UnregisterFromParent()
	set_holder(null)
	UnregisterSignal(parent, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_ATOM_SET_LIGHT_RANGE,
		COMSIG_ATOM_SET_LIGHT_POWER,
		COMSIG_ATOM_SET_LIGHT_COLOR,
		COMSIG_ATOM_SET_LIGHT_ON,
		COMSIG_ATOM_SET_LIGHT_FLAGS,
		))
	return ..()

///Called when parent changes loc.
/datum/component/directional_lighting/proc/on_parent_moved(atom/movable/source, OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	check_holder()
	set_direction(Dir)
	if(!(light_enabled) || !current_holder)
		return
	update_visual()

///Called to change the value of current_holder.
/datum/component/directional_lighting/proc/set_holder(atom/movable/new_holder)
	if(new_holder == current_holder)
		return
	if(current_holder)
		if(light_enabled)
			current_holder.vis_contents -= cone
		if(current_holder != parent)
			UnregisterSignal(current_holder, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE))
	current_holder = new_holder
	if(new_holder == null)
		return
	if(light_enabled)
		new_holder.vis_contents += cone
	if(new_holder != parent)
		RegisterSignal(new_holder, COMSIG_PARENT_QDELETING, .proc/on_holder_qdel)
		RegisterSignal(new_holder, COMSIG_MOVABLE_MOVED, .proc/on_holder_moved)
		RegisterSignal(new_holder, COMSIG_ATOM_DIR_CHANGE, .proc/on_holder_dir_change)
		set_direction(new_holder.dir)
		update_visual()

///Used to determine the new valid current_holder from the parent's loc.
/datum/component/directional_lighting/proc/check_holder()
	var/atom/movable/movable_parent = parent
	if(isturf(movable_parent.loc))
		set_holder(movable_parent)
		return
	var/atom/inside = movable_parent.loc //Parent's loc
	if(isnull(inside))
		set_holder(null)
		return
	if(isturf(inside.loc))
		set_holder(inside)
		return
	set_holder(null)

/datum/component/directional_lighting/proc/set_direction(new_dir)
	if(new_dir)
		cone.dir = new_dir
		direction = new_dir

/datum/component/directional_lighting/proc/update_visual()
	var/final_distance = cast_distance
	//Lower the distance by 1 if we're not looking at a cardinal direction, and we're not a short cast
	if(final_distance > 2 && !(ALL_CARDINALS & direction))
		final_distance -= 1
	var/turf/scanning = get_turf(current_holder)
	for(var/i in 1 to cast_distance)
		var/turf/next_turf = get_step(scanning, direction)
		if(IS_OPAQUE_TURF(next_turf))
			break
		scanning = next_turf
	light_holder_atom.forceMove(scanning)

///Called when the current_holder is qdeleted, to remove the light effect.
/datum/component/directional_lighting/proc/on_holder_qdel(atom/movable/source, force)
	SIGNAL_HANDLER
	UnregisterSignal(current_holder, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_MOVED))
	set_holder(null)

///Called when current_holder changes loc.
/datum/component/directional_lighting/proc/on_holder_moved(atom/movable/source, OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	set_direction(Dir)
	if(!light_enabled)
		return
	update_visual()

///Called when current_holder changes loc.
/datum/component/directional_lighting/proc/on_holder_dir_change(atom/movable/source, olddir, newdir)
	SIGNAL_HANDLER
	set_direction(newdir)
	if(!light_enabled)
		return
	update_visual()

/datum/component/directional_lighting/proc/set_range(atom/source, new_range)
	SIGNAL_HANDLER
	cast_distance = FLOOR(new_range/2, 1)
	light_holder_atom.set_light_range(new_range)

/datum/component/directional_lighting/proc/set_power(atom/source, new_power)
	SIGNAL_HANDLER
	cone.alpha = min(200, (abs(new_power) * 110))
	light_holder_atom.set_light_power(new_power)

/datum/component/directional_lighting/proc/set_color(atom/source, new_color)
	SIGNAL_HANDLER
	cone.color = new_color
	light_holder_atom.set_light_color(new_color)

/datum/component/directional_lighting/proc/on_toggle(atom/source, new_value)
	SIGNAL_HANDLER
	light_holder_atom.set_light_on(new_value)
	if(light_enabled == new_value)
		return
	light_enabled = new_value
	//We hide the atom if we dont need it at the moment
	if(!new_value)
		light_holder_atom.moveToNullspace()
		if(current_holder)
			current_holder.vis_contents -= cone
		return
	if(current_holder)
		current_holder.vis_contents += cone
	update_visual()

/datum/component/directional_lighting/proc/on_light_flags_change(atom/source, new_value)
	SIGNAL_HANDLER
	light_holder_atom.set_light_flags(new_value)
