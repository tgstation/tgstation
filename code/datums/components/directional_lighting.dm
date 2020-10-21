/**
  * Movable light system-based directional lighting component
  *
  * * Component works by creating and moving an abstract atom that uses the movable light system, it also adds a cosmetic cone shaped mask.
  *
  * * The component tracks the parent's loc to determine the current_holder.
  * * The current_holder is either the parent or its loc, whichever is on a turf. If none, then the current_holder is null and the light is not visible.
  *
  * * The component tracks current_holder's direction and, if the light is turned on - casts the abstract atom a distance into that direction.
  * * The cast distance is dependant on the light_range of the parent
  *
*/

#define SHORT_CAST 2

/datum/component/directional_lighting
	///Abstractional atom that is a movable light, we're manipulating this
	var/obj/effect/abstract/directional_lighting/light_holder_atom
	///A cone overlay to make the light feel truly directional, it's alpha and color are dependant on the light
	var/obj/effect/overlay/light_cone/cone
	///Which direction are we shining at
	var/direction = SOUTH
	///Movable atom currently holding the light. Parent might be a flashlight, for example, but that might be held by a mob or something else.
	var/atom/movable/current_holder
	///Whether the light is enabled or not
	var/light_enabled = FALSE
	///The distance the abstractional atom is cast at a direction
	var/cast_distance = 2

/datum/component/directional_lighting/Initialize(_range, _power, _color)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	var/atom/movable/movable_parent = parent
	if(movable_parent.light_system != MOVABLE_LIGHT_DIRECTIONAL)
		stack_trace("[type] added to [parent], with [movable_parent.light_system] value for the light_system var. Use [MOVABLE_LIGHT_DIRECTIONAL] instead.")
		return COMPONENT_INCOMPATIBLE

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
	RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, .proc/on_parent_dir_change)
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
		COMSIG_ATOM_DIR_CHANGE,
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
	if(parent != current_holder)
		return
	set_direction(Dir)
	if(!(light_enabled) || !current_holder)
		return
	update_visual()

///Called when parent changes dir
/datum/component/directional_lighting/proc/on_parent_dir_change(atom/movable/source, olddir, newdir)
	SIGNAL_HANDLER
	if(parent != current_holder)
		return
	set_direction(newdir)
	if(!light_enabled)
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
		light_holder_atom.moveToNullspace()
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

///Sets the direction. Cares about truthy values to not set it to 0
/datum/component/directional_lighting/proc/set_direction(new_dir)
	if(new_dir)
		cone.dir = new_dir
		direction = new_dir

///Used to cast the abstractional atom at a direction, to create the effect of a directional light
/datum/component/directional_lighting/proc/update_visual()
	var/final_distance = cast_distance
	//Lower the distance by 1 if we're not looking at a cardinal direction, and we're not a short cast
	if(final_distance > SHORT_CAST && !(ALL_CARDINALS & direction))
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
	UnregisterSignal(current_holder, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE))
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

///Handles the range for the cast distance, and passes it to the abstract atom
/datum/component/directional_lighting/proc/set_range(atom/source, new_range)
	SIGNAL_HANDLER
	cast_distance = FLOOR(new_range/2, 1)
	light_holder_atom.set_light_range(new_range)

///Handles the power for the cone alpha, and passes it to the abstract atom
/datum/component/directional_lighting/proc/set_power(atom/source, new_power)
	SIGNAL_HANDLER
	cone.alpha = min(200, (abs(new_power) * 110))
	light_holder_atom.set_light_power(new_power)

///Handles the color for the cone alpha, and passes it to the abstract atom
/datum/component/directional_lighting/proc/set_color(atom/source, new_color)
	SIGNAL_HANDLER
	cone.color = new_color
	light_holder_atom.set_light_color(new_color)

///Passes whether the light is ON or OFF to the atom, and handles its position and the cone mask if nessecary
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

///Passes the flags to the abstract atom
/datum/component/directional_lighting/proc/on_light_flags_change(atom/source, new_value)
	SIGNAL_HANDLER
	light_holder_atom.set_light_flags(new_value)

#undef SHORT_CAST
