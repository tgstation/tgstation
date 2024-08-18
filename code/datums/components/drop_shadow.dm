/// Draws a shadow overlay under the attachee
/datum/component/drop_shadow
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// The overlay we are using
	var/mutable_appearance/shadow
	/// Extra offset to apply to the shadow
	var/shadow_offset
	/// Any temporary extra offsets we are tracking
	var/additional_offset = 0
	/// Timer to make sure
	var/unhide_shadow_timer
	/// An override to the default layer(s) used by the shadow appearance
	var/layer_override

/datum/component/drop_shadow/Initialize(icon = 'icons/mob/mob_shadows.dmi', icon_state = SHADOW_MEDIUM, shadow_offset_x = 0, shadow_offset_y = 0, layer_override)
	. = ..()
	if (!ismovable(parent)) // Only being used for mobs at the moment but it seems reasonably likely that we'll want to put it on some effect some time
		return COMPONENT_INCOMPATIBLE

	shadow_offset = shadow_offset_y
	src.layer_override = layer_override

	var/atom/movable/movable_parent = parent

	make_mutable_appearance(icon, icon_state, layer_override)
	shadow.pixel_x = shadow_offset_x - movable_parent.pixel_x
	update_shadow_position()

/datum/component/drop_shadow/proc/make_mutable_appearance(icon, icon_state, layer)
	shadow = mutable_appearance(
			icon,
			icon_state,
			layer = layer || BELOW_MOB_LAYER,
			appearance_flags = KEEP_APART | RESET_TRANSFORM | RESET_COLOR
		)


/datum/component/drop_shadow/InheritComponent(icon = 'icons/mob/mob_shadows.dmi', icon_state = SHADOW_MEDIUM, shadow_offset_x = 0, shadow_offset_y = 0)
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

	if (shadow_offset_y != shadow_offset)
		shadow_offset = shadow_offset_y
		update_shadow_position() // Calling this will also update the overlays so we can return here and safely apply any of the above changes too
		return

	if (changed_appearance && !HAS_TRAIT(parent, TRAIT_SHADOWLESS)) // If we changed position this will get called anyway so don't do it twice
		add_shadow()

/datum/component/drop_shadow/RegisterWithParent()
	if(!layer_override)
		var/atom/movable/movable_parent = parent
		shadow.layer = movable_parent.layer > BELOW_MOB_LAYER ? BELOW_MOB_LAYER : LOW_ITEM_LAYER
	shadow.alpha = HAS_TRAIT(parent, TRAIT_FAINT_SHADOW) ? 125 : 255

	var/self_shadow = HAS_TRAIT(parent, TRAIT_SELF_SHADOW)

	if(!self_shadow)
		RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignals(parent, list(COMSIG_ATOM_FULTON_BEGAN, COMSIG_ATOM_BEGAN_ORBITING), PROC_REF(hide_shadow))
	RegisterSignals(parent, list(COMSIG_ATOM_FULTON_LANDED, COMSIG_ATOM_STOPPED_ORBITING), PROC_REF(show_shadow))
	RegisterSignals(parent, list(SIGNAL_ADDTRAIT(TRAIT_SHADOWLESS), SIGNAL_REMOVETRAIT(TRAIT_SHADOWLESS)), PROC_REF(shadowless_trait_updated))

	var/isliving = FALSE
	if (ismob(parent))
		isliving = isliving(parent)
		RegisterSignals(parent, list(SIGNAL_ADDTRAIT(TRAIT_SELF_SHADOW), SIGNAL_REMOVETRAIT(TRAIT_SELF_SHADOW)), PROC_REF(on_self_shadow_updated))
		if(self_shadow)
			RegisterSignal(parent, COMSIG_MOB_LOGIN, PROC_REF(on_mob_login))
	if(isliving)
		var/mob/living/living_parent = parent
		RegisterSignal(parent, COMSIG_LIVING_POST_UPDATE_TRANSFORM, PROC_REF(on_transform_updated))
		RegisterSignal(parent, COMSIG_MOB_BUCKLED, PROC_REF(hide_shadow))
		RegisterSignal(parent, COMSIG_MOB_UNBUCKLED, PROC_REF(show_shadow))
		if(!living_parent.buckled)
			RegisterSignals(parent, list(SIGNAL_ADDTRAIT(TRAIT_FAINT_SHADOW), SIGNAL_REMOVETRAIT(TRAIT_FAINT_SHADOW)), PROC_REF(faint_shadow_trait_updated))
		else
			shadow.alpha = 0
	else
		RegisterSignals(parent, list(SIGNAL_ADDTRAIT(TRAIT_FAINT_SHADOW), SIGNAL_REMOVETRAIT(TRAIT_FAINT_SHADOW)), PROC_REF(faint_shadow_trait_updated))

	if (!HAS_TRAIT(parent, TRAIT_SHADOWLESS))
		add_shadow()

/datum/component/drop_shadow/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_ATOM_FULTON_BEGAN,
		COMSIG_ATOM_FULTON_LANDED,
		COMSIG_ATOM_BEGAN_ORBITING,
		COMSIG_ATOM_STOPPED_ORBITING,
		COMSIG_LIVING_POST_UPDATE_TRANSFORM,
		COMSIG_MOB_BUCKLED,
		COMSIG_MOB_UNBUCKLED,
		SIGNAL_ADDTRAIT(TRAIT_SHADOWLESS),
		SIGNAL_REMOVETRAIT(TRAIT_SHADOWLESS),
		SIGNAL_ADDTRAIT(TRAIT_FAINT_SHADOW),
		SIGNAL_REMOVETRAIT(TRAIT_FAINT_SHADOW),
		SIGNAL_ADDTRAIT(TRAIT_SELF_SHADOW),
		SIGNAL_REMOVETRAIT(TRAIT_SELF_SHADOW),
		COMSIG_MOB_LOGIN,
	))

	shadow.loc = null

	if(HAS_TRAIT(parent, TRAIT_SHADOWLESS))
		return
	if(HAS_TRAIT(parent, TRAIT_SELF_SHADOW))
		var/mob/mob_parent = parent
		if(mob_parent.client)
			mob_parent?.client -= shadow
		return
	if(!QDELETED(parent))
		var/atom/atom_parent = parent
		atom_parent.update_appearance(UPDATE_OVERLAYS)

/// Repositions the shadow to try and stay under our mob should be at under current conditions
/datum/component/drop_shadow/proc/update_shadow_position()
	var/lying_offset = 0
	if (isliving(parent))
		var/mob/living/living_parent = parent
		if (living_parent.rotate_on_lying && living_parent.body_position != STANDING_UP)
			lying_offset = living_parent.body_position_pixel_y_offset
		shadow.transform = matrix() * living_parent.current_size

	shadow.pixel_z = -DEPTH_OFFSET - additional_offset - lying_offset + shadow_offset

	if (!HAS_TRAIT(parent, TRAIT_SHADOWLESS))
		add_shadow()

/// Called by RegisterWithParent and update_shadow_position, for adding the shadow to the mob.
/datum/component/drop_shadow/proc/add_shadow()
	if(!HAS_TRAIT(parent, TRAIT_SELF_SHADOW))
		var/atom/atom_parent = parent
		atom_parent.update_appearance(UPDATE_OVERLAYS)
	else
		add_to_client_images()

/// Called when the mob gains a client
/datum/component/drop_shadow/proc/on_mob_login()
	SIGNAL_HANDLER
	if(!HAS_TRAIT(parent, TRAIT_SHADOWLESS))
		add_to_client_images()

/// Add the shadow to the images shown to the client
/datum/component/drop_shadow/proc/add_to_client_images()
	var/mob/mob_parent = parent
	if(!mob_parent.client)
		return
	if(shadow.type != /image) //mutable_appearances don't work with client locs, so we need to convert it to an image.
		shadow = image(shadow)
		shadow.loc = mob_parent //loc is not passed down to the image, but other things (the appareance) are.
	mob_parent.client.images |= shadow

/// Called when we gain or lose the "self-shadow" trait
/datum/component/drop_shadow/proc/on_self_shadow_updated()
	SIGNAL_HANDLER
	var/mob/mob_parent = parent
	if(HAS_TRAIT(parent, TRAIT_SELF_SHADOW))
		RegisterSignal(parent, COMSIG_MOB_LOGIN, PROC_REF(on_mob_login))
		UnregisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS)
		mob_parent.update_appearance(UPDATE_OVERLAYS)
		add_to_client_images()
		return
	UnregisterSignal(parent, COMSIG_MOB_LOGIN)
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	if(mob_parent.client)
		mob_parent.client.images -= shadow
	///Revert the shadow from image to mutable appearance
	make_mutable_appearance(shadow.icon, shadow.icon_state, shadow.layer)
	shadow.alpha = HAS_TRAIT(parent, TRAIT_FAINT_SHADOW) ? 125 : 255
	mob_parent.update_appearance(UPDATE_OVERLAYS)

/// Handles actually displaying it
/datum/component/drop_shadow/proc/on_update_overlays(atom/source, list/overlays)
	SIGNAL_HANDLER
	if (!HAS_TRAIT(parent, TRAIT_SHADOWLESS))
		overlays += shadow

/// Called when we gain or lose the "shadowless" trait
/datum/component/drop_shadow/proc/shadowless_trait_updated()
	SIGNAL_HANDLER
	if(!HAS_TRAIT(parent, TRAIT_SELF_SHADOW))
		var/atom/atom_parent = parent
		atom_parent.update_appearance(UPDATE_OVERLAYS)
		return

	var/mob/mob_parent = parent
	if(!mob_parent.client)
		return
	if(HAS_TRAIT(parent, TRAIT_SHADOWLESS))
		mob_parent.client.images -= shadow
	else
		mob_parent.client.images |= shadow

/// Called when we gain or lose the "shadowless" trait
/datum/component/drop_shadow/proc/faint_shadow_trait_updated()
	SIGNAL_HANDLER
	shadow.alpha = HAS_TRAIT(parent, TRAIT_FAINT_SHADOW) ? 125 : 255
	if(HAS_TRAIT(parent, TRAIT_SHADOWLESS) || HAS_TRAIT(parent, TRAIT_SELF_SHADOW))
		return
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
	shadow.alpha = HAS_TRAIT(parent, TRAIT_FAINT_SHADOW) ? 125 : 255
	RegisterSignals(parent, list(SIGNAL_ADDTRAIT(TRAIT_FAINT_SHADOW), SIGNAL_REMOVETRAIT(TRAIT_FAINT_SHADOW)), PROC_REF(faint_shadow_trait_updated))
	deltimer(unhide_shadow_timer)
	if(HAS_TRAIT(parent, TRAIT_SHADOWLESS) || HAS_TRAIT(parent, TRAIT_SELF_SHADOW))
		return
	var/atom/atom_parent = parent
	atom_parent.update_appearance(UPDATE_OVERLAYS)

/// Make the shadow invisible
/datum/component/drop_shadow/proc/hide_shadow()
	SIGNAL_HANDLER
	shadow.alpha = 0
	UnregisterSignal(parent, list(SIGNAL_ADDTRAIT(TRAIT_FAINT_SHADOW), SIGNAL_REMOVETRAIT(TRAIT_FAINT_SHADOW)))
	deltimer(unhide_shadow_timer)
	if(HAS_TRAIT(parent, TRAIT_SHADOWLESS) || HAS_TRAIT(parent, TRAIT_SELF_SHADOW))
		return
	var/atom/atom_parent = parent
	atom_parent.update_appearance(UPDATE_OVERLAYS)

/// Hide shadow then display it again after a delay
/datum/component/drop_shadow/proc/temporarily_hide_shadow(show_in)
	if (!show_in)
		return
	hide_shadow()
	unhide_shadow_timer = addtimer(CALLBACK(src, PROC_REF(show_shadow)), show_in, TIMER_STOPPABLE | TIMER_UNIQUE | TIMER_DELETE_ME)
