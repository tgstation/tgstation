/obj/item/instrument_syncer
	name = "conductor's baton"
	desc = "A beautifully crafted baton - no, not the kind you hit people with - used to conduct symphonies and orchestras."
	icon = 'icons/obj/weapons/baton.dmi'
	icon_state = "classic_baton"
	inhand_icon_state = "classic_baton"
	worn_icon_state = "classic_baton"
	icon_angle = -45
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	force = 8
	throwforce = 8
	throw_range = 5
	demolition_mod = 1.2
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT)
	attack_verb_continuous = list("beats", "conducts", "orchestrates", "directs", "leads", "symphonizes", "syncronizes")
	attack_verb_simple = list("beat", "conduct", "orchestrate", "direct", "lead", "symphonize", "syncronize")
	custom_price = PAYCHECK_COMMAND
	/// Assoc list of instruments linked to this syncer to an image that can be used to display linked instruments on the user's screen.
	var/list/obj/item/linked_instruments = list()

/obj/item/instrument_syncer/Initialize(mapload)
	. = ..()
	register_item_context()
	register_context()

/obj/item/jammer/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	context[SCREENTIP_CONTEXT_LMB] = "Conduct all"
	context[SCREENTIP_CONTEXT_RMB] = "Clear all"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/jammer/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	if(!isobj(target))
		return NONE
	context[SCREENTIP_CONTEXT_LMB] = "Link instrument"
	context[SCREENTIP_CONTEXT_RMB] = "Unlink instrument"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/instrument_syncer/examine(mob/user)
	. = ..()
	. += span_info("&bull; Click on an instrument to link it. Right click on an instrument to unlink it.")
	. += span_info("&bull; Use in hand to start conducting all linked instruments, causing them to simultaneously play the first instrument's song.")
	. += span_info("&bull; Right click on it while in hand to unlink all instruments.")

/obj/item/instrument_syncer/Destroy()
	for(var/obj/item/thing as anything in linked_instruments)
		unlink_instrument(thing)
	return ..()

/obj/item/instrument_syncer/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	for(var/datum/song/existing_song as anything in SSinstruments.songs)
		if(interacting_with != existing_song.parent)
			continue
		if(linked_instruments[interacting_with])
			balloon_alert(user, "already linked!")
			return ITEM_INTERACT_BLOCKING
		balloon_alert(user, "linked")
		link_instrument(interacting_with)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/instrument_syncer/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	for(var/datum/song/existing_song as anything in SSinstruments.songs)
		if(interacting_with != existing_song.parent)
			continue
		if(!linked_instruments[interacting_with])
			balloon_alert(user, "not linked!")
			return ITEM_INTERACT_BLOCKING
		balloon_alert(user, "unlinked")
		unlink_instrument(interacting_with)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/instrument_syncer/equipped(mob/user, slot, initial)
	. = ..()
	if(slot & ITEM_SLOT_HANDS)
		for(var/i in linked_instruments)
			user.client?.images |= linked_instruments[i]

/obj/item/instrument_syncer/dropped(mob/user, silent)
	. = ..()
	for(var/i in linked_instruments)
		user.client.images -= linked_instruments[i]
	if(isliving(loc)) // hand to hand
		return
	for(var/obj/item/playable as anything in linked_instruments)
		var/datum/song/song = get_song(playable)
		if(song?.music_player == user)
			song.stop_playing()

/obj/item/instrument_syncer/proc/link_instrument(obj/item/thing)
	var/image/help_image = image(
		icon = 'icons/hud/screen_bci.dmi',
		loc = thing,
		icon_state = "hud_corners[length(linked_instruments) ? "_red" : ""]",
	)
	help_image.alpha = 160

	RegisterSignal(thing, COMSIG_QDELETING, PROC_REF(unlink_instrument))
	RegisterSignal(thing, COMSIG_INSTRUMENT_SHOULD_STOP_PLAYING, PROC_REF(keep_playing))
	linked_instruments[thing] = help_image

	var/mob/living/user = loc
	if(istype(user) && (user.get_slot_by_item(src) & ITEM_SLOT_HANDS))
		user.client?.images |= help_image

/obj/item/instrument_syncer/proc/unlink_instrument(obj/item/thing)
	SIGNAL_HANDLER

	// Promotes the next instrument in the list to be the leading instrument
	// Handles removing the existing image, the next instrument's image, and replacing it with the new leading image
	if(length(linked_instruments) >= 2 && thing == linked_instruments[1])
		var/next_prime_instrument = linked_instruments[2]
		var/cleared_image = linked_instruments[next_prime_instrument]
		var/image/new_leading_image = image(
			icon = 'icons/hud/screen_bci.dmi',
			loc = next_prime_instrument,
			icon_state = "hud_corners",
		)
		new_leading_image.alpha = 160
		linked_instruments[next_prime_instrument] = new_leading_image

		if(isliving(loc))
			var/mob/living/user = loc
			user.client?.images -= cleared_image
			user.client?.images -= linked_instruments[thing]
			if(user.get_slot_by_item(src) & ITEM_SLOT_HANDS)
				user.client?.images |= new_leading_image

	// Otherwise just clear images
	else if(isliving(loc))
		var/mob/living/user = loc
		user.client?.images -= linked_instruments[thing]

	UnregisterSignal(thing, COMSIG_QDELETING)
	UnregisterSignal(thing, COMSIG_INSTRUMENT_SHOULD_STOP_PLAYING)
	linked_instruments -= thing

	var/datum/song/existing_song = get_song(thing)
	existing_song?.stop_playing()

/obj/item/instrument_syncer/proc/keep_playing(datum/source, mob/player)
	SIGNAL_HANDLER

	if(player != loc)
		return NONE
	if(can_play(player, source))
		return IGNORE_INSTRUMENT_CHECKS
	return STOP_PLAYING

/// Gets the song datum associated with the passed object.
/obj/item/instrument_syncer/proc/get_song(obj/item/thing)
	for(var/datum/song/existing_song as anything in SSinstruments.songs)
		if(thing == existing_song.parent)
			return existing_song
	return null

/// Checks if the user can play the passed instrument.
/obj/item/instrument_syncer/proc/can_play(mob/living/user, obj/item/thing)
	return user.Adjacent(thing)

/obj/item/instrument_syncer/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return
	if(!length(linked_instruments))
		return

	var/datum/song/main_song = get_song(linked_instruments[1])
	if(main_song.music_player == user)
		for(var/obj/item/playable as anything in linked_instruments)
			var/datum/song/song = get_song(playable)
			if(song?.music_player == user)
				song.stop_playing()

		balloon_alert(user, "stopped conducting")
		visible_message(
			span_notice("[user] stops conducting the instruments."),
			span_notice("You stop conducting the instruments."),
		)
		return TRUE

	for(var/obj/item/playable as anything in linked_instruments)
		if(!can_play(user, playable))
			continue

		var/datum/song/song = get_song(playable)
		if(!song || song.playing)
			continue

		play_song(user, song, main_song)

	balloon_alert(user, "now conducting")
	visible_message(
		span_notice("[user] starts conducting the instruments!"),
		span_nicegreen("You start conducting the instruments!"),
	)
	return TRUE

/obj/item/instrument_syncer/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(.)
		return

	for(var/i in linked_instruments)
		unlink_instrument(i)
	balloon_alert(user, "unlinked all instruments")
	return TRUE

/obj/item/instrument_syncer/proc/play_song(mob/user, datum/song/target, datum/song/main)
	if(main && target != main)
		// copies the main song info to target songs
		target.lines = main.lines.Copy()
		target.max_repeats = main.max_repeats
		target.tempo = main.tempo

	target.start_playing(user)

/obj/item/instrument_syncer/radio
	name = "radio star's baton"
	desc = "A baton shaped radio that can be used to sync multiple instruments together, regardless of distance."
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	custom_price = PAYCHECK_COMMAND * 3
	force = 6

/obj/item/instrument_syncer/radio/can_play(mob/living/user, obj/item/thing)
	return TRUE // Can play from anywhere, no need to be adjacent

/obj/item/instrument_syncer/radio/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return interact_with_atom(interacting_with, user, modifiers)

/obj/item/instrument_syncer/radio/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	return interact_with_atom_secondary(interacting_with, user, modifiers)
