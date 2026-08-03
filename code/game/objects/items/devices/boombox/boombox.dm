/obj/item/boombox
	name = "\proper Nanomusic boombox"
	desc = "Never quit making all that racket with this booming box."
	icon = 'icons/obj/devices/voice.dmi'
	icon_state = "boombox"
	inhand_icon_state = "boombox"
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'
	custom_premium_price = PAYCHECK_COMMAND * 7
	/// Is the boombox actively playing anything?
	var/active = FALSE
	/// Is the boombox being worn on the holder's shoulder?
	var/swag_mode = FALSE
	/// Reference to the tapedeck that's inserted into the boombox.
	var/obj/item/music_tape/tapedeck = null
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
	RegisterSignal(src, COMSIG_MOUSEDROP_ONTO, PROC_REF(on_drag_pickup))

/obj/item/boombox/Destroy(force)
	if(tapedeck)
		tapedeck.forceMove(drop_location())
	QDEL_NULL(boombox_audio)
	return ..()

/obj/item/boombox/examine(mob/user)
	. = ..()
	. += span_notice("The tie can be worn in hand or on your shoulder. Alt-Right-click to toggle.")
	if(tapedeck)
		. += "It has [span_bold("tapedeck")] inside."
	else
		. += "It has no record inside."

/obj/item/boombox/click_alt_secondary(mob/user)
	swag_mode = !swag_mode
	inhand_icon_state = swag_mode ? "boombox_swag" : "boombox"
	balloon_alert(user, "wearing [swag_mode ? "on shoulder" : "in hand"].")
	if(loc == user)
		playsound(user, pickup_sound, 30)
	update_appearance()
	user.update_held_items()

/obj/item/boombox/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/music_tape))
		if(tapedeck)
			balloon_alert(user, "eject first")
			return ITEM_INTERACT_BLOCKING
		var/obj/item/music_tape/tunes = tool
		user.transferItemToLoc(tunes, src)
		tapedeck = tunes
		balloon_alert(user, "tape inserted")
		playsound(src, 'sound/items/taperecorder/taperecorder_close.ogg', 50, FALSE)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/tape))
		balloon_alert(user, "won't fit!")
		return ITEM_INTERACT_BLOCKING
	return ..()

/obj/item/boombox/attack_hand(mob/user, list/modifiers)
	. = ..()
	update_available_icons()
	if(!check_menu(user))
		return
	display_radial_menu(user)

/obj/item/boombox/attack_self(mob/user, modifiers)
	. = ..()
	update_available_icons()
	if(!check_menu(user))
		return
	display_radial_menu(user)

/obj/item/boombox/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_RMB] = "Control boombox"
	context[SCREENTIP_CONTEXT_LMB] = "Pick up (Drag)"
	context[SCREENTIP_CONTEXT_ALT_RMB] = "Change worn style"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/boombox/proc/on_drag_pickup(atom/movable/source, atom/over, mob/user)
	SIGNAL_HANDLER
	if(user.particles || !src.particles)
		return
	user.particles = particles // We're transferring the music particles from the boombox to the user.
	update_appearance()

/obj/item/boombox/dropped(mob/user, silent)
	. = ..()
	if(!user.particles)
		return
	if(istype(user.particles, /particles/musical_notes))
		src.particles =	user.particles
		user.particles = null

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
			if(!user.particles && loc == user)
				user.particles = particles
			boombox_audio.start()
			icon_state = "boombox_on"
			update_appearance()
			active = TRUE

		if("Stop")
			if(!boombox_audio)
				balloon_alert(user, "nothing playing")
				return
			stop_music(user)
			active = FALSE

		if("Eject")
			stop_music(user)
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

/// Stops looping audio, handles particles
/obj/item/boombox/proc/stop_music(mob/user)
	if(!boombox_audio)
		return
	boombox_audio.stop()
	boombox_audio = qdel(boombox_audio)

	if(particles)
		particles = qdel(particles)
	if(loc == user && istype(user?.particles, /particles/musical_notes))
		qdel(user.particles)
	icon_state = "boombox"
	update_appearance()
