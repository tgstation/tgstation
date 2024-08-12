/datum/component/friendship_container
	///our friendship thresholds from lowest to highest
	var/list/friendship_levels = list()
	///our current friends stored as a weakref = amount
	var/list/weakrefed_friends = list()
	///list of friendship levels that we send BEFRIEND signals on, if someone drops below these levels its over
	var/befriend_level
	///list of all befriended refs
	var/list/befriended_refs = list()

/datum/component/friendship_container/Initialize(friendship_levels = list(), befriend_level)
	. = ..()
	if(!length(friendship_levels))
		return FALSE

	src.friendship_levels = friendship_levels
	src.befriend_level = befriend_level


/datum/component/friendship_container/Destroy(force, silent)
	. = ..()
	befriended_refs = null
	weakrefed_friends = null
	friendship_levels = null

/datum/component/friendship_container/RegisterWithParent()
	RegisterSignal(parent, COMSIG_FRIENDSHIP_CHECK_LEVEL, PROC_REF(check_friendship_level))
	RegisterSignal(parent, COMSIG_FRIENDSHIP_CHANGE, PROC_REF(change_friendship))
	RegisterSignal(parent, COMSIG_FRIENDSHIP_PASS_FRIENDSHIP, PROC_REF(pass_friendship))
	RegisterSignal(parent, COMSIG_ATOM_MOUSE_ENTERED, PROC_REF(view_friendship))

/datum/component/friendship_container/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_FRIENDSHIP_CHECK_LEVEL)
	UnregisterSignal(parent, COMSIG_FRIENDSHIP_CHANGE)
	UnregisterSignal(parent, COMSIG_FRIENDSHIP_PASS_FRIENDSHIP)
	UnregisterSignal(parent, COMSIG_ATOM_MOUSE_ENTERED)

/datum/component/friendship_container/proc/change_friendship(mob/living/source, atom/target, amount)
	for(var/datum/weakref/ref as anything in weakrefed_friends)
		if(ref.resolve() == target)

			///handles registering pet commands and other things that use BEFRIEND
			if(amount < 0)
				if((friendship_levels[befriend_level] > weakrefed_friends[ref]) && (ref in befriended_refs))
					SEND_SIGNAL(parent, COMSIG_LIVING_UNFRIENDED, ref.resolve())
					befriended_refs -= ref
					source.ai_controller?.remove_thing_from_blackboard_key(BB_FRIENDS_LIST, target)

			else if((friendship_levels[befriend_level] <= weakrefed_friends[ref]) && !(ref in befriended_refs))
				SEND_SIGNAL(parent, COMSIG_LIVING_BEFRIENDED, ref.resolve())
				befriended_refs += ref
				source.ai_controller?.insert_blackboard_key_lazylist(BB_FRIENDS_LIST, target)

			weakrefed_friends[ref] += amount
			return TRUE
	weakrefed_friends += list(WEAKREF(target) = amount)
	return TRUE

///Returns {TRUE} if friendship is above a certain threshold else returns {FALSE}
/datum/component/friendship_container/proc/check_friendship_level(mob/living/source, atom/target, friendship_level)
	for(var/datum/weakref/ref as anything in weakrefed_friends)
		if(isnull(ref) || QDELETED(ref))
			weakrefed_friends -= ref
			continue
		if(ref.resolve() == target)
			if(friendship_levels[friendship_level] <= weakrefed_friends[ref])
				return TRUE
			return FALSE
	return FALSE


/datum/component/friendship_container/proc/pass_friendship(datum/source, atom/target)
	if(!target.GetComponent(/datum/component/friendship_container))
		target.AddComponent(/datum/component/friendship_container, friendship_levels, befriend_level)

	for(var/datum/weakref/ref as anything in weakrefed_friends)
		if(isnull(ref) || QDELETED(ref))
			weakrefed_friends -= ref
			continue
		var/amount = weakrefed_friends[ref]
		var/atom/resolved = ref.resolve()
		SEND_SIGNAL(target, COMSIG_FRIENDSHIP_CHANGE, resolved, amount)


/datum/component/friendship_container/proc/view_friendship(mob/living/source, mob/living/clicker)
	if(!istype(clicker) || !length(weakrefed_friends) || !clicker.client)
		return
	var/max_level = friendship_levels[length(friendship_levels)]
	var/max_level_value = friendship_levels[max_level]
	for(var/datum/weakref/ref as anything in weakrefed_friends)
		if(isnull(ref) || QDELETED(ref))
			weakrefed_friends -= ref
			continue
		if(ref.resolve() != clicker)
			continue

		var/list/offset_to_add = get_icon_dimensions(source.icon)
		var/y_position = offset_to_add["height"] + 1
		var/obj/effect/overlay/happiness_overlay/hearts = new(null, clicker)
		var/lowest_level = friendship_levels[1]
		var/lowest_level_value = friendship_levels[lowest_level]
		hearts.pixel_y = y_position
		hearts.set_hearts((weakrefed_friends[ref] - (lowest_level_value)) / (max_level_value - (lowest_level_value)))
		var/image/new_image = new(source)
		new_image.appearance = hearts.appearance
		if(!isturf(source.loc))
			new_image.loc = source.loc
		else
			new_image.loc = source
		SET_PLANE(new_image, new_image.plane, source)
		clicker.client.images += new_image
		hearts.image = new_image


/obj/effect/overlay/happiness_overlay
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE
	layer = ABOVE_HUD_PLANE
	plane = GAME_PLANE_UPPER
	///how many hearts should we display
	VAR_PRIVATE/hearts_percentage
	///icon of our heart
	var/heart_icon = 'icons/effects/effects.dmi'
	var/client/stored_client
	var/image/image
	var/full_icon = "full_heart"
	var/empty_icon = "empty_heart"

/obj/effect/overlay/happiness_overlay/New(loc, mob/living/clicker)
	. = ..()
	if(!clicker)
		return

	RegisterSignal(clicker.client, COMSIG_CLIENT_HOVER_NEW, PROC_REF(clear_view))
	stored_client = clicker.client

/obj/effect/overlay/happiness_overlay/Destroy(force)
	. = ..()
	stored_client?.images -= image
	QDEL_NULL(image)
	stored_client = null

/obj/effect/overlay/happiness_overlay/proc/set_hearts(happiness_percentage)
	hearts_percentage = happiness_percentage
	update_appearance(UPDATE_OVERLAYS)

/obj/effect/overlay/happiness_overlay/update_overlays()
	. = ..()
	var/static/list/heart_positions = list(-24, -16, -8, 0, 8, 16, 24)
	var/display_amount = round(length(heart_positions) * hearts_percentage, 1)
	for(var/index in 1 to length(heart_positions))
		var/heart_icon_state = display_amount >= index ? full_icon : empty_icon
		var/mutable_appearance/display_icon = mutable_appearance(icon = heart_icon, icon_state = heart_icon_state, layer = ABOVE_HUD_PLANE)
		display_icon.pixel_x = heart_positions[index]
		. += display_icon

/obj/effect/overlay/happiness_overlay/proc/clear_view()
	qdel(src)
