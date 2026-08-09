// Tapes containing music.
/obj/item/music_tape
	name = "tapedeck"
	desc = "A special tape that holds music."
	icon_state = "tape_white"
	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	inhand_icon_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.2, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.2)
	force = 1
	throwforce = 0
	obj_flags = UNIQUE_RENAME
	drop_sound = 'sound/items/handling/tape_drop.ogg'
	pickup_sound = 'sound/items/handling/tape_pickup.ogg'
	var/datum/looping_sound/song_inside = /datum/looping_sound/boombox
	/// Song name to append to the examine text.
	var/song_name = "Industrial Crush"

/obj/item/music_tape/examine(mob/user)
	. = ..()
	. += span_notice("You could probably play this in a Nanotrasen Brand [span_smallnoticeital("tm")] \
		Nanomusic [span_smallnoticeital("tm")] boombox, at least until they trademark the concept of a boombox, too.")

/obj/item/music_tape/Initialize(mapload)
	. = ..()
	if(!song_inside)
		CRASH("We spawned a tape deck without any looping audio inside.")

/obj/item/music_tape/examine(mob/user)
	. = ..()
	. += span_notice("The track is labled [span_boldnotice(song_name)].")

/obj/item/music_tape/rock
	icon_state = "tape_red"
	song_inside = /datum/looping_sound/boombox/rock
	song_name = "Bainmack"

/obj/item/music_tape/hiphop
	icon_state = "tape_purple"
	song_inside = /datum/looping_sound/boombox/hiphop
	song_name = "Groovepad"

/obj/item/music_tape/jazz
	desc = "A special tape that holds music. Wait, this one has jazz on it? You don't see that much anymore..."
	icon_state = "tape_yellow"
	song_inside = /datum/looping_sound/boombox/jazz
	song_name = "Franky's Gonna Boom"

/obj/item/music_tape/jazz/Initialize(mapload)
	. = ..()
	add_deep_lore()

/obj/item/music_tape/jazz/proc/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore_hint = span_notice("You can [EXAMINE_HINT("look closer")] to learn a little more about [src]."), \
		lore = "Jazz is, by all definitions, completely legal in the spinward sector. After all, sounds\
			tend not to be the sort of thing that a major corporation can effectively police.\
			Freeform Jazz, on the other hand, had taken on a scandalous identity in the late 2590s, following\
			the legendary crime spree left by freeform jazz musician and criminal mastermind [span_bold("Rezz 'The Tips' C'thoni")].\
			In an attempt to prevent a repeat of what happened on Rhozz Alpha, which we ALL remember,\
			TerraGov and a multinational coalition of planets deemed Freeform Jazz to be an active threat to public safety.\
			The more free the jazz, the more serious the crime."\
	)

/obj/item/music_tape/pop
	icon_state = "tape_blue"
	song_inside = /datum/looping_sound/boombox/pop
	song_name = "Bubblegum"

// This exists mostly for testing
/obj/item/storage/box/music_tapes
	name = "box of music tapes"
	desc = "Contains several proprietary, company approved songs for waving above your head on your own jukebox."
	illustration = "music"

/obj/item/storage/box/music_tapes/PopulateContents()
	var/list/items_inside = list(
		/obj/item/music_tape = 1,
		/obj/item/music_tape/rock = 1,
		/obj/item/music_tape/hiphop = 1,
		/obj/item/music_tape/pop = 1,
	)
	generate_items_inside(items_inside, src)
