/**
 * # Render over, Keep hitbox element!
 *
 * Non bespoke element (1 in existence) that makes structures render over mobs, but still allow you to attack the mob's hitbox!
 * Used in plastic flaps, and directional windows!
 */
/datum/element/render_over_keep_hitbox

/datum/element/render_over_keep_hitbox/Attach(datum/target)
	. = ..()
	if(!isstructure(target))
		return ELEMENT_INCOMPATIBLE
	var/obj/structure/obj_target = target

	RegisterSignal(obj_target, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_changed_z_level))
	obj_target.alpha = 0
	gen_overlay(obj_target)

/datum/element/render_over_keep_hitbox/Detach(obj/structure/target, ...)
	UnregisterSignal(target, COMSIG_MOVABLE_Z_CHANGED)
	target.alpha = initial(target.alpha)
	SSvis_overlays.remove_vis_overlay(target.managed_vis_overlays)
	return ..()

/datum/element/render_over_keep_hitbox/proc/on_changed_z_level(obj/structure/target, turf/old_turf, turf/new_turf, same_z_layer)
	SIGNAL_HANDLER

	if(same_z_layer)
		return
	SSvis_overlays.remove_vis_overlay(target.managed_vis_overlays)
	gen_overlay(target)

/datum/element/render_over_keep_hitbox/proc/gen_overlay(obj/structure/target)
	var/turf/our_turf = get_turf(target)
	//you see mobs under it, but you hit them like they are above it
	SSvis_overlays.add_vis_overlay(
		target,
		target.icon,
		target.icon_state,
		ABOVE_MOB_LAYER,
		MUTATE_PLANE(GAME_PLANE, our_turf),
		target.dir,
		add_appearance_flags = RESET_ALPHA
	)
