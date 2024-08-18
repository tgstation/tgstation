/// Draws a shadow overlay under the attachee
/datum/component/drop_shadow
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// The overlay we are using
	var/mutable_appearance/shadow
	/// Extra offset to apply to the shadow
	var/shadow_offset
	/// Any temporary extra offsets we are tracking
	var/additional_offset = 0
	/// Additional offset to apply while mob is dead
	var/death_offset
	/// Timer to make sure
	var/unhide_shadow_timer

/datum/component/drop_shadow/Initialize(icon = 'icons/mob/mob_shadows.dmi', icon_state = SHADOW_MEDIUM, shadow_offset_x = 0, shadow_offset_y = 0, death_offset = 0)
	. = ..()
	if (!ismovable(parent)) // Only being used for mobs at the moment but it seems reasonably likely that we'll want to put it on some effect some time
		return COMPONENT_INCOMPATIBLE

	src.death_offset = death_offset
	shadow_offset = shadow_offset_y

	var/atom/movable/movable_parent = parent

	shadow = mutable_appearance(
		icon,
		icon_state,
		layer = BELOW_MOB_LAYER,
		appearance_flags = KEEP_APART | RESET_TRANSFORM | RESET_COLOR
	)
	shadow.pixel_x = shadow_offset_x - movable_parent.pixel_x
	update_shadow_position()

/datum/component/drop_shadow/InheritComponent(icon = 'icons/mob/mob_shadows.dmi', icon_state = SHADOW_MEDIUM, shadow_offset_x = 0, shadow_offset_y = 0, death_offset = 0)
	var/changed_appearance = FALSE

	if (shadow.pixel_x != shadow_offset_x)
		shadow.pixel_x = shadow_offset_x
		changed_appearance = TRUE

	if (shadow.icon != icon)
		shadow.icon = icon
		changed_appearance = TRUE

	if (shadow.icon_state != icon_state)
		shadow.icon_state = icon_state
		changed_appearance = TRUE

	var/changed_offset = FALSE

	if (death_offset != src.death_offset)
		if (src.death_offset == 0)
			RegisterSignal(parent, COMSIG_MOB_STATCHANGE, PROC_REF(update_shadow_position))
		else if (death_offset == 0)
			UnregisterSignal(parent, COMSIG_MOB_STATCHANGE, PROC_REF(update_shadow_position))
		src.death_offset = death_offset

	if (shadow_offset_y != shadow_offset)
		shadow_offset = shadow_offset_y

	if (changed_offset)
		update_shadow_position() // Calling this will also update the overlays so we can return here and safely apply any of the above changes too
		return

	if (changed_appearance && !HAS_TRAIT(parent, TRAIT_SHADOWLESS)) // If we changed position this will get called anyway so don't do it twice
		var/atom/atom_parent = parent
		atom_parent.update_appearance(UPDATE_OVERLAYS)

/datum/component/drop_shadow/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignals(parent, list(COMSIG_ATOM_FULTON_BEGAN, COMSIG_ATOM_BEGAN_ORBITING), PROC_REF(hide_shadow))
	RegisterSignals(parent, list(COMSIG_ATOM_FULTON_LANDED, COMSIG_ATOM_STOPPED_ORBITING), PROC_REF(show_shadow))
	RegisterSignals(parent, list(SIGNAL_ADDTRAIT(TRAIT_SHADOWLESS), SIGNAL_REMOVETRAIT(TRAIT_SHADOWLESS)), PROC_REF(shadowless_trait_updated))

	if (isliving(parent))
		RegisterSignal(parent, COMSIG_LIVING_POST_UPDATE_TRANSFORM, PROC_REF(on_transform_updated))
		RegisterSignal(parent, COMSIG_MOB_BUCKLED, PROC_REF(hide_shadow))
		RegisterSignal(parent, COMSIG_MOB_UNBUCKLED, PROC_REF(show_shadow))
		if (death_offset != 0)
			RegisterSignal(parent, COMSIG_MOB_STATCHANGE, PROC_REF(update_shadow_position))

	if (!HAS_TRAIT(parent, TRAIT_SHADOWLESS))
		var/atom/atom_parent = parent
		atom_parent.update_appearance(UPDATE_OVERLAYS)

/datum/component/drop_shadow/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_ATOM_FULTON_BEGAN,
		COMSIG_ATOM_FULTON_LANDED,
		COMSIG_ATOM_BEGAN_ORBITING,
		COMSIG_ATOM_STOPPED_ORBITING,
		COMSIG_LIVING_POST_UPDATE_TRANSFORM,
		COMSIG_MOB_BUCKLED,
		COMSIG_MOB_STATCHANGE,
		COMSIG_MOB_UNBUCKLED,
		SIGNAL_ADDTRAIT(TRAIT_SHADOWLESS),
		SIGNAL_REMOVETRAIT(TRAIT_SHADOWLESS),
	))

/// Repositions the shadow to try and stay under our mob should be at under current conditions
/datum/component/drop_shadow/proc/update_shadow_position()
	SIGNAL_HANDLER

	var/living_offset = 0
	if (isliving(parent))
		var/mob/living/living_parent = parent
		if (living_parent.rotate_on_lying && living_parent.body_position != STANDING_UP)
			living_offset -= living_parent.body_position_pixel_y_offset
		if (death_offset != 0 && living_parent.stat == DEAD)
			living_offset += death_offset
		shadow.transform = matrix() * living_parent.current_size

	shadow.pixel_z = -DEPTH_OFFSET - additional_offset + living_offset + shadow_offset

	if (!HAS_TRAIT(parent, TRAIT_SHADOWLESS))
		var/atom/atom_parent = parent
		atom_parent.update_appearance(UPDATE_OVERLAYS)

/// Handles actually displaying it
/datum/component/drop_shadow/proc/on_update_overlays(atom/source, list/overlays)
	SIGNAL_HANDLER
	if (!HAS_TRAIT(parent, TRAIT_SHADOWLESS))
		overlays += shadow

/// Called when we gain or lose the "shadowless" trait
/datum/component/drop_shadow/proc/shadowless_trait_updated()
	SIGNAL_HANDLER
	var/atom/atom_parent = parent
	atom_parent.update_appearance(UPDATE_OVERLAYS)

/// Called when a mob is resized or rotated
/datum/component/drop_shadow/proc/on_transform_updated(mob/living/source, previous_size, lying_angle, is_opposite_angle, final_pixel_y, animate_time)
	SIGNAL_HANDLER
	additional_offset = final_pixel_y
	update_shadow_position()
	if (animate_time > 0)
		temporarily_hide_shadow(animate_time)

/// Make the shadow visible
/datum/component/drop_shadow/proc/show_shadow()
	SIGNAL_HANDLER
	shadow.alpha = 255
	deltimer(unhide_shadow_timer)
	if (!HAS_TRAIT(parent, TRAIT_SHADOWLESS))
		var/atom/atom_parent = parent
		atom_parent.update_appearance(UPDATE_OVERLAYS)

/// Make the shadow invisible
/datum/component/drop_shadow/proc/hide_shadow()
	SIGNAL_HANDLER
	shadow.alpha = 0
	deltimer(unhide_shadow_timer)
	if (!HAS_TRAIT(parent, TRAIT_SHADOWLESS))
		var/atom/atom_parent = parent
		atom_parent.update_appearance(UPDATE_OVERLAYS)

/// Hide shadow then display it again after a delay
/datum/component/drop_shadow/proc/temporarily_hide_shadow(show_in)
	if (!show_in)
		return
	hide_shadow()
	unhide_shadow_timer = addtimer(CALLBACK(src, PROC_REF(show_shadow)), show_in, TIMER_STOPPABLE | TIMER_UNIQUE | TIMER_DELETE_ME)
