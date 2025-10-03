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
	/// overlay on top of the cog
	var/obj/effect/overlay/vis/overlaid_on_cog
	/// The blank1 image that overlaps the cog - hides it from the source user
	var/image/blank1
	/// The blank2 image that overlaps the overlaid_on_cog - hides it from the source user
	var/image/blank2
	/// The offset of the icon
	var/offset_y
	/// Icon path of the cog
	var/cogicon
	/// The icon state
	var/cogiconstate
	/// weakref of the item being overlaid on top of the cogbar
	var/datum/weakref/used_item_weakref


/datum/cogbar/New(mob/user, cogicon, cogiconstate, atom/used_item)
	src.user = user
	src.user_client = user.client
	src.cogicon = cogicon
	src.cogiconstate = cogiconstate
	src.used_item_weakref = WEAKREF(used_item)
	var/list/icon_offsets = user.get_oversized_icon_offsets()
	offset_y = icon_offsets["y"]
	if(isnull(cogicon))
		stack_trace("/datum/cogbar was created with a null icon.")
		qdel(src)
		return
	if(isnull(cogiconstate))
		stack_trace("/datum/cogbar was created with a null icon state.")
		qdel(src)
		return

	add_cog_to_user()

	RegisterSignal(user, COMSIG_QDELETING, PROC_REF(on_user_delete))


/datum/cogbar/Destroy()
	if(user)
		if(overlaid_on_cog)
			SSvis_overlays.remove_vis_overlay(cog, cog.managed_vis_overlays)
			user_client?.images -= blank2
		SSvis_overlays.remove_vis_overlay(user, user.managed_vis_overlays)
		user_client?.images -= blank1

	user = null
	user_client = null
	cog = null
	overlaid_on_cog = null
	QDEL_NULL(blank1)
	QDEL_NULL(blank2)

	return ..()


/// Adds the cog to the user, visible by other players
/datum/cogbar/proc/add_cog_to_user()
	cog = SSvis_overlays.add_vis_overlay(user,
		icon = cogicon,
		iconstate = cogiconstate,
		plane = HIGH_GAME_PLANE,
		add_appearance_flags = APPEARANCE_UI_IGNORE_ALPHA,
		unique = TRUE,
		alpha = 0,
	)
	cog.pixel_y = ICON_SIZE_Y + offset_y
	animate(cog, alpha = user.alpha, time = COGBAR_ANIMATION_TIME)

	var/atom/used_item = used_item_weakref?.resolve()

	if(used_item)
		overlaid_on_cog = SSvis_overlays.add_vis_overlay(cog,
			icon = used_item.icon,
			iconstate = used_item.icon_state,
			plane = HIGH_GAME_PLANE,
			layer = 5,
			add_appearance_flags = APPEARANCE_UI_IGNORE_ALPHA,
			unique = TRUE,
			alpha = 0,
		)
		overlaid_on_cog.pixel_y -= 8
		animate(overlaid_on_cog, alpha = user.alpha, time = COGBAR_ANIMATION_TIME)

	if(isnull(user_client))
		return

	blank1 = image('icons/blanks/32x32.dmi', cog, "nothing")
	SET_PLANE_EXPLICIT(blank1, HIGH_GAME_PLANE, user)
	blank1.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	blank1.override = TRUE
	user_client.images += blank1

	if(overlaid_on_cog)
		blank2 = image('icons/blanks/32x32.dmi', overlaid_on_cog, "nothing")
		SET_PLANE_EXPLICIT(blank2, HIGH_GAME_PLANE, user)
		blank2.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
		blank2.override = TRUE
		user_client.images += blank2

/// Removes the cog from the user
/datum/cogbar/proc/remove()
	if(isnull(cog))
		qdel(src)
		return

	animate(cog, alpha = 0, time = COGBAR_ANIMATION_TIME)
	if(overlaid_on_cog)
		animate(overlaid_on_cog, alpha = 0, time = COGBAR_ANIMATION_TIME)

	QDEL_IN(src, COGBAR_ANIMATION_TIME)


/// When the user is deleted, remove the cog
/datum/cogbar/proc/on_user_delete(datum/source)
	SIGNAL_HANDLER

	qdel(src)


#undef COGBAR_ANIMATION_TIME
