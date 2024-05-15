#define COGBAR_ANIMATION_TIME (0.5 SECONDS)

/**
 * ### Cogbar
 * Represents that the user is busy doing something.
 */
/datum/cogbar
	/// Who's doing the thing
	var/mob/user
	/// The user client
	var/client/user_client
	/// The visible element to other players
	var/obj/effect/overlay/vis/cog
	/// The blank image that overlaps the cog - hides it from the source user
	var/image/blank
	/// The offset of the icon
	var/offset_y


/datum/cogbar/New(mob/user)
	src.user = user
	src.user_client = user.client

	var/list/icon_offsets = user.get_oversized_icon_offsets()
	offset_y = icon_offsets["y"]

	add_cog_to_user()

	RegisterSignal(user, COMSIG_QDELETING, PROC_REF(on_user_delete))


/datum/cogbar/Destroy()
	if(user)
		SSvis_overlays.remove_vis_overlay(user, user.managed_vis_overlays)
		user_client?.images -= blank

	user = null
	user_client = null
	cog = null
	QDEL_NULL(blank)

	return ..()


/// Adds the cog to the user, visible by other players
/datum/cogbar/proc/add_cog_to_user()
	cog = SSvis_overlays.add_vis_overlay(user, 
		icon = 'icons/effects/progressbar.dmi',
		iconstate = "cog",
		plane = HIGH_GAME_PLANE,
		add_appearance_flags = APPEARANCE_UI_IGNORE_ALPHA,
		unique = TRUE,
		alpha = 0,
	)
	cog.pixel_y = world.icon_size + offset_y
	animate(cog, alpha = 255, time = COGBAR_ANIMATION_TIME)

	if(isnull(user_client))
		return

	blank = image('icons/blanks/32x32.dmi', cog, "nothing")
	SET_PLANE_EXPLICIT(blank, HIGH_GAME_PLANE, user)
	blank.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	blank.override = TRUE	

	user_client.images += blank


/// Removes the cog from the user
/datum/cogbar/proc/remove()
	if(isnull(cog))
		qdel(src)
		return

	animate(cog, alpha = 0, time = COGBAR_ANIMATION_TIME)

	QDEL_IN(src, COGBAR_ANIMATION_TIME)   


/// When the user is deleted, remove the cog
/datum/cogbar/proc/on_user_delete(datum/source)
	SIGNAL_HANDLER

	qdel(src)
	

#undef COGBAR_ANIMATION_TIME
