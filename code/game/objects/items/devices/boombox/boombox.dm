/obj/item/boombox
	name = "\a boombox"
	desc = "Never quit making all that racket with this booming box."
	icon = 'icons/obj/devices/voice.dmi'
	icon_state = "boombox"
	worn_icon_state = "boombox"
	/// Is the boombox actively playing anything?
	var/active = FALSE
	/// Reference to the tapedeck that's inserted into the boombox.
	var/obj/item/tape/music/tapedeck = null
	/// Soundloop that's managing our boombox.
	var/datum/looping_sound/boombox_audio = null
	/// A list of all available boombox actions
	var/list/boombox_acts = list()
	/// Icon file for radial objects
	var/radial_icon_file = 'icons/hud/radial_taperecorder.dmi'

/obj/item/boombox/Initialize(mapload)
	. = ..()
	interaction_flags_item &= ~INTERACT_ITEM_ATTACK_HAND_PICKUP
	AddElement(/datum/element/drag_pickup)
	update_available_icons()
	register_context()

/obj/item/boombox/Destroy(force)
	if(tapedeck)
		tapedeck.forceMove(drop_location())
	QDEL_NULL(boombox_audio)
	return ..()

/obj/item/boombox/examine(mob/user)
	. = ..()
	if(tapedeck)
		. += "It has [span_bold("tapedeck")] inside."
	else
		. += "It has no record inside."

/obj/item/boombox/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/tape/music))
		if(tapedeck)
			balloon_alert(user, "eject first")
			return ITEM_INTERACT_BLOCKING
		var/obj/item/tape/music/tunes = tool
		user.transferItemToLoc(tunes, src)
		tapedeck = tunes
		balloon_alert(user, "tape inserted")
		playsound(src, 'sound/items/taperecorder/taperecorder_close.ogg', 50, FALSE)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/tape))
		balloon_alert(user, "can't play!")
		return ITEM_INTERACT_BLOCKING
	return ..()

/obj/item/boombox/attack_hand(mob/user, list/modifiers)
	. = ..()
	update_available_icons()
	if(!check_menu(user))
		return FALSE
	display_radial_menu(user)
	return TRUE

/obj/item/boombox/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_RMB] = "Control boombox"
	context[SCREENTIP_CONTEXT_LMB] = "Pick up (Drag)"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/boombox/proc/display_radial_menu(mob/living/user)
	if(!user)
		return FALSE
	var/choice = show_radial_menu(user, src, boombox_acts, radius = 36, require_near = TRUE)
	if(!choice)
		return FALSE
	switch(choice)
		if("Play")
			if(!tapedeck)
				balloon_alert(user, "no tape")
				return
			boombox_audio = tapedeck.song_inside
			boombox_audio = new boombox_audio(src)
			particles = new /particles/musical_notes
			boombox_audio.start()
			icon_state = "boombox_on"
			update_appearance()
			active = TRUE

		if("Stop")
			if(!boombox_audio)
				balloon_alert(user, "nothing playing")
				return
			stop_music()
			active = FALSE

		if("Eject")
			stop_music()
			user.transferItemToLoc(tapedeck, drop_location())
			tapedeck = null
			update_available_icons()
			active = FALSE

	playsound(src, 'sound/machines/click.ogg', 40, TRUE)

/// Updates the list of boombox_acts for the radial menu.
/obj/item/boombox/proc/update_available_icons()
	boombox_acts = list()
	if(!active)
		boombox_acts += list("Play" = image(radial_icon_file, "play"))
	if(active)
		boombox_acts += list("Stop" = image(radial_icon_file, "stop"))
	if(tapedeck)
		boombox_acts += list("Eject" = image(radial_icon_file, "eject"))

/// Do we meet the requirements to interact with the boombox?
/obj/item/boombox/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated)
		return FALSE
	return TRUE

/// Stops looping audio
/obj/item/boombox/proc/stop_music()
	if(!boombox_audio)
		return
	boombox_audio.stop()
	boombox_audio = qdel(boombox_audio)

	if(particles)
		particles = qdel(particles)
	icon_state = "boombox"
	update_appearance()
