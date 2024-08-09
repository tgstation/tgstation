/// Draws a shadow overlay under the attachee
/datum/component/drop_shadow
	/// The overlay we are using
	var/mutable_appearance/shadow
	/// Extra offset to apply to the shadow
	var/shadow_offset
	/// Any temporary extra offsets we are tracking
	var/additional_offset
	/// Timer to make sure
	var/unhide_shadow_timer

/datum/component/drop_shadow/Initialize(icon = 'icons/mob/mob_shadows.dmi', icon_state = SHADOW_MEDIUM, shadow_offset = 0)
	. = ..()
	if (!ismovable(parent)) // Only being used for mobs at the moment but it seems reasonably likely that we'll want to put it on some effect some time
		return COMPONENT_INCOMPATIBLE

	src.shadow_offset = shadow_offset

	var/atom/movable/movable_parent = parent

	shadow = mutable_appearance(
		icon,
		icon_state,
		layer = BELOW_MOB_LAYER,
		appearance_flags = KEEP_APART | RESET_TRANSFORM | RESET_COLOR
	)
	shadow.pixel_x = movable_parent.pixel_x
	update_shadow_position()
	movable_parent.update_appearance(UPDATE_OVERLAYS)

/datum/component/drop_shadow/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))

	if (isliving(parent))
		RegisterSignal(parent, COMSIG_LIVING_POST_UPDATE_TRANSFORM, PROC_REF(on_transform_updated))
		RegisterSignal(parent, COMSIG_MOB_BUCKLED, PROC_REF(hide_shadow))
		RegisterSignal(parent, COMSIG_MOB_UNBUCKLED, PROC_REF(show_shadow))

/datum/component/drop_shadow/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_MOB_BUCKLED,
		COMSIG_MOB_UNBUCKLED,
	))

/// Repositions the shadow to try and stay under our mob should be at under current conditions
/datum/component/drop_shadow/proc/update_shadow_position()

	var/lying_offset = 0
	if (isliving(parent))
		var/mob/living/living_parent = parent
		lying_offset = (living_parent.rotate_on_lying && living_parent.resting) ? living_parent.body_position_pixel_y_offset - 4 : 0

	shadow.pixel_y = -DEPTH_OFFSET - lying_offset + shadow_offset + additional_offset
	var/atom/atom_parent = parent
	atom_parent.update_appearance(UPDATE_OVERLAYS)

/// Handles actually displaying it
/datum/component/drop_shadow/proc/on_update_overlays(atom/source, list/overlays)
	SIGNAL_HANDLER
	overlays += shadow

/// Called when a mob is resized or rotated
/datum/component/drop_shadow/proc/on_transform_updated(mob/living/source, previous_size, lying_angle, is_opposite_angle, animate_time)
	SIGNAL_HANDLER
	update_shadow_position()
	if (animate_time > 0)
		temporarily_hide_shadow(animate_time)

/// Make the shadow visible
/datum/component/drop_shadow/proc/show_shadow()
	SIGNAL_HANDLER
	shadow.alpha = 255
	var/atom/atom_parent = parent
	atom_parent.update_appearance(UPDATE_OVERLAYS)
	deltimer(unhide_shadow_timer)

/// Make the shadow invisible
/datum/component/drop_shadow/proc/hide_shadow()
	SIGNAL_HANDLER
	shadow.alpha = 0
	var/atom/atom_parent = parent
	atom_parent.update_appearance(UPDATE_OVERLAYS)
	deltimer(unhide_shadow_timer)

/datum/component/drop_shadow/proc/temporarily_hide_shadow(show_in)
	if (!show_in)
		return
	hide_shadow()
	unhide_shadow_timer = addtimer(CALLBACK(src, PROC_REF(show_shadow)), show_in, TIMER_STOPPABLE | TIMER_UNIQUE | TIMER_DELETE_ME)
