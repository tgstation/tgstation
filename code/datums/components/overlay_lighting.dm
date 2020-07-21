///For switchable lights, is it on and currently emitting light?
#define LIGHTING_ON (1<<0)

/**
  * Movable atom overlay-based lighting component.
  *
  * * Component works by applying a visual object to the parent target.
  *
  * * The component tracks the parent's loc to determine the current_holder.
  * * The current_holder is either the parent or its loc, whichever is on a turf. If none, then the current_holder is null and the light is not visible.
  *
  * * Lighting works at its base by applying a dark overlay and "cutting" said darkness with light, adding (possibly colored) transparency.
  * * This component uses the visible_mask visual object to apply said light mask on the darkness.
  *
  * * The main limitation of this system is that it uses a limited number of pre-baked geometrical shapes, but for most uses it does the job.
  *
  * * Another limitation is for big lights: you only see the light if you see the object emiting it.
  * * For small objects this is good (you can't see them behind a wall), but for big ones this quickly becomes prety clumsy.
*/
/datum/component/overlay_lighting
	///How far the light reaches, float.
	var/range = 1
	///Ceiling of range, integer without decimal entries.
	var/lumcount_range = 0
	///How much this light affects the dynamic_lumcount of turfs.
	var/lum_power = 0.5
	///Transparency value.
	var/set_alpha = 0
	///For light sources that can be turned on and off.
	var/overlay_lighting_flags = NONE

	///Cache of the possible light overlays, according to size.
	var/static/list/light_overlays = list(
		"32" = 'icons/effects/light_overlays/light_32.dmi',
		"64" = 'icons/effects/light_overlays/light_64.dmi',
		"96" = 'icons/effects/light_overlays/light_96.dmi',
		"128" = 'icons/effects/light_overlays/light_128.dmi',
		"160" = 'icons/effects/light_overlays/light_160.dmi',
		"192" = 'icons/effects/light_overlays/light_192.dmi',
		"224" = 'icons/effects/light_overlays/light_224.dmi',
		"256" = 'icons/effects/light_overlays/light_256.dmi',
		"288" = 'icons/effects/light_overlays/light_288.dmi',
		"320" = 'icons/effects/light_overlays/light_320.dmi',
		"352" = 'icons/effects/light_overlays/light_352.dmi',
		)

	///Overlay effect to cut into the darkness and provide light.
	var/obj/effect/overlay/light_visible/visible_mask
	///Lazy list to track the turfs being affected by our light, to determine their visibility.
	var/list/turf/affected_turfs
	///Atom currently holding the light. Parent might be a flashlight, for example, but that might be held by a mob or something else.
	var/atom/movable/current_holder


/datum/component/overlay_lighting/Initialize(_range, _power, _color, starts_on)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	var/atom/movable/light_holder = parent
	if(light_holder.light_system != MOVABLE_LIGHT)
		stack_trace("[type] added to [parent], with [light_holder.light_system] value for the light_system var. Use [MOVABLE_LIGHT] instead.")
		return COMPONENT_INCOMPATIBLE

	. = ..()

	visible_mask = new()
	if(!isnull(_range))
		light_holder.set_light_range(_range)
	set_range(parent, light_holder.light_range)
	if(!isnull(_power))
		light_holder.set_light_power(_power)
	set_power(parent, light_holder.light_power)
	if(!isnull(_color))
		light_holder.set_light_color(_color)
	set_color(parent, light_holder.light_color)
	if(!isnull(starts_on))
		light_holder.set_light_on(starts_on)


/datum/component/overlay_lighting/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/on_parent_moved)
	RegisterSignal(parent, COMSIG_ATOM_SET_LIGHT_RANGE, .proc/set_range)
	RegisterSignal(parent, COMSIG_ATOM_SET_LIGHT_POWER, .proc/set_power)
	RegisterSignal(parent, COMSIG_ATOM_SET_LIGHT_COLOR, .proc/set_color)
	RegisterSignal(parent, COMSIG_ATOM_SET_LIGHT_ON, .proc/on_toggle)
	check_holder()
	var/atom/movable/light_holder = parent
	if(light_holder.light_on)
		turn_on()


/datum/component/overlay_lighting/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_ATOM_SET_LIGHT_RANGE,
		COMSIG_ATOM_SET_LIGHT_POWER,
		COMSIG_ATOM_SET_LIGHT_COLOR,
		COMSIG_ATOM_SET_LIGHT_ON,
		))
	if(overlay_lighting_flags & LIGHTING_ON)
		turn_off()
	return ..()


/datum/component/overlay_lighting/Destroy()
	for(var/t in affected_turfs)
		var/turf/lit_turf = t
		lit_turf.dynamic_lumcount -= lum_power
	affected_turfs = null
	QDEL_NULL(visible_mask)
	return ..()


///Clears the affected_turfs lazylist, removing from its contents the effects of being near the light.
/datum/component/overlay_lighting/proc/clean_old_turfs()
	for(var/t in affected_turfs)
		var/turf/lit_turf = t
		lit_turf.dynamic_lumcount -= lum_power
	affected_turfs = null


///Populates the affected_turfs lazylist, adding to its contents the effects of being near the light.
/datum/component/overlay_lighting/proc/get_new_turfs()
	if(!current_holder)
		return
	for(var/t in RANGE_TURFS(lumcount_range, current_holder.loc))
		var/turf/lit_turf = t
		lit_turf.dynamic_lumcount += lum_power
		LAZYADD(affected_turfs, lit_turf)


///Clears the old affected turfs and populates the new ones.
/datum/component/overlay_lighting/proc/make_luminosity_update()
	clean_old_turfs()
	get_new_turfs()


///Adds the luminosity and source for the afected movable atoms to keep track of their visibility.
/datum/component/overlay_lighting/proc/add_dynamic_lumi(atom/movable/affected_movable)
	LAZYSET(affected_movable.affected_dynamic_lights, src, lumcount_range + 1)
	affected_movable.vis_contents += visible_mask
	affected_movable.update_dynamic_luminosity()


///Removes the luminosity and source for the afected movable atoms to keep track of their visibility.
/datum/component/overlay_lighting/proc/remove_dynamic_lumi(atom/movable/affected_movable)
	LAZYREMOVE(affected_movable.affected_dynamic_lights, src)
	affected_movable.vis_contents -= visible_mask
	affected_movable.update_dynamic_luminosity()


///Called to change the value of current_holder.
/datum/component/overlay_lighting/proc/set_holder(atom/movable/new_holder)
	if(new_holder == current_holder)
		return
	if(current_holder)
		if(current_holder != parent)
			UnregisterSignal(current_holder, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_MOVED))
		if(overlay_lighting_flags & LIGHTING_ON)
			remove_dynamic_lumi(current_holder)
	current_holder = new_holder
	if(new_holder == null)
		clean_old_turfs()
		return
	if(overlay_lighting_flags & LIGHTING_ON)
		add_dynamic_lumi(new_holder)
	if(new_holder != parent)
		RegisterSignal(new_holder, COMSIG_PARENT_QDELETING, .proc/on_holder_qdel)
		RegisterSignal(new_holder, COMSIG_MOVABLE_MOVED, .proc/on_holder_moved)


///Used to determine the new valid current_holder from the parent's loc.
/datum/component/overlay_lighting/proc/check_holder()
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
	if(inside.light_flags & LIGHT_ATTACHED) //If the light is attached it should behave as if it was located in its loc's loc.
		if(isnull(inside.loc))
			set_holder(null)
			return
		inside = inside.loc //One more level, parent loc's loc.
		if(isturf(inside.loc))
			set_holder(inside)
			return
	set_holder(null)


///Called when the current_holder is qdeleted, to remove the light effect.
/datum/component/overlay_lighting/proc/on_holder_qdel(atom/movable/source, force)
	UnregisterSignal(current_holder, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_MOVED))
	set_holder(null)


///Called when current_holder changes loc.
/datum/component/overlay_lighting/proc/on_holder_moved(atom/movable/source, OldLoc, Dir, Forced)
	if(!(overlay_lighting_flags & LIGHTING_ON))
		return
	make_luminosity_update()


///Called when parent changes loc.
/datum/component/overlay_lighting/proc/on_parent_moved(atom/movable/source, OldLoc, Dir, Forced)
	check_holder()
	if(!(overlay_lighting_flags & LIGHTING_ON) || !current_holder)
		return
	make_luminosity_update()


///Changes the range which the light reaches. 0 means no light, 6 is the maximum value.
/datum/component/overlay_lighting/proc/set_range(atom/source, new_range)
	if(range == new_range)
		return
	if(range == 0)
		turn_off()
	range = clamp(CEILING(new_range, 0.5), 1, 6)
	var/pixel_bounds = ((range - 1) * 64) + 32
	lumcount_range = CEILING(range, 1)
	visible_mask.icon = light_overlays["[pixel_bounds]"]
	if(pixel_bounds == 32)
		return
	var/offset = (pixel_bounds - 32) * 0.5
	var/matrix/transform = new
	transform.Translate(-offset, -offset)
	visible_mask.transform = transform
	if(overlay_lighting_flags & LIGHTING_ON)
		make_luminosity_update()


///Changes the intensity/brightness of the light by altering the visual object's alpha.
/datum/component/overlay_lighting/proc/set_power(atom/source, new_power)
	set_lum_power(new_power >= 0 ? 0.5 : -0.5)
	set_alpha = min(230, (abs(new_power) * 120) + 30)
	visible_mask.alpha = set_alpha


///Changes the light's color, pretty straightforward.
/datum/component/overlay_lighting/proc/set_color(atom/source, new_color)
	visible_mask.color = new_color


///Toggles the light on and off.
/datum/component/overlay_lighting/proc/on_toggle(atom/source, new_value)
	if(new_value) //Truthy value input, turn on.
		turn_on()
		return
	turn_off() //Falsey value, turn off.


///Toggles the light on.
/datum/component/overlay_lighting/proc/turn_on()
	if(overlay_lighting_flags & LIGHTING_ON)
		return
	if(current_holder)
		add_dynamic_lumi(current_holder)
	overlay_lighting_flags |= LIGHTING_ON
	get_new_turfs()


///Toggles the light off.
/datum/component/overlay_lighting/proc/turn_off()
	if(!(overlay_lighting_flags & LIGHTING_ON))
		return
	if(current_holder)
		remove_dynamic_lumi(current_holder)
	overlay_lighting_flags &= ~LIGHTING_ON
	clean_old_turfs()


///Here we append the behavior associated to changing lum_power.
/datum/component/overlay_lighting/proc/set_lum_power(new_lum_power)
	if(lum_power == new_lum_power)
		return
	. = lum_power
	lum_power = new_lum_power
	var/difference = . - lum_power
	for(var/t in affected_turfs)
		var/turf/lit_turf = t
		lit_turf.dynamic_lumcount -= difference


#undef LIGHTING_ON
