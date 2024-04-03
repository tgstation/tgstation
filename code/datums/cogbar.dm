#define COGBAR_ANIMATION_TIME 5

/**
 * ### Cogbar
 * Represents that the user is busy doing something .
 */
/datum/cogbar
	/// The user of the cogbar
	var/mob/user
	/// The user client
	var/client/user_client
	/// The visible element to other players
	var/obj/effect/overlay/vis/cog
	/// The blank image to hide the cog
	var/image/blank
	/// The offset of the icon
	var/offset_y


/datum/cogbar/New(mob/user)
	src.user = user
	src.user_client = user.client

	var/list/icon_offsets = user.get_oversized_icon_offsets()
	offset_y = icon_offsets["y"]

	add_cog_to_user()


/datum/cogbar/Destroy()
	SSvis_overlays.remove_vis_overlay(user, user.managed_vis_overlays)
	user_client?.images -= blank

	user = null
	user_client = null
	QDEL_NULL(cog)
	QDEL_NULL(blank)

	return ..()


/// Adds the cog to the user, visible by other players
/datum/cogbar/proc/add_cog_to_user()
	cog = SSvis_overlays.add_vis_overlay(user, 
		icon = 'icons/effects/progressbar.dmi',
		iconstate = "cog",
		plane = ABOVE_HUD_PLANE,
		add_appearance_flags = APPEARANCE_UI_IGNORE_ALPHA,
		unique = TRUE,
		alpha = 0,
	)
	cog.pixel_y = world.icon_size + offset_y
	animate(cog, alpha = 255, time = COGBAR_ANIMATION_TIME)

	if(isnull(user_client))
		return

	blank = image('icons/blanks/32x32.dmi', cog, "nothing")
	SET_PLANE_EXPLICIT(blank, ABOVE_HUD_PLANE, user)
	blank.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	blank.override = TRUE	

	user_client.images += blank


/// Removes the cog from the user
/datum/cogbar/proc/remove()
	animate(cog, alpha = 0, time = COGBAR_ANIMATION_TIME)

	QDEL_IN(src, COGBAR_ANIMATION_TIME)   
	

#undef COGBAR_ANIMATION_TIME
