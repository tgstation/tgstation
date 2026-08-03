// Tapes containing music.
/obj/item/tape/music
	name = "tapedeck"
	desc = "A special tape that holds music."
	icon_state = "tape_white"
	var/datum/looping_sound/song_inside = /datum/looping_sound/boombox
	/// Song name to append to the examine text.
	var/song_name = "Industrial Crush"

/obj/item/tape/music/examine(mob/user)
	. = ..()
	. += span_notice("You could probably play this in a Nanotrasen Brand [span_smallnoticeital("tm")] \
		Nanomusic [span_smallnoticeital("tm")] boombox, at least until they trademark the concept of a boombox, too.")

/obj/item/tape/music/Initialize(mapload)
	. = ..()
	if(!song_inside)
		CRASH("We spawned a tape deck without any looping audio inside.")

/obj/item/tape/music/examine(mob/user)
	. = ..()
	. += span_notice("The track is labled [span_boldnotice(song_name)].")

/obj/item/tape/music/rock
	icon_state = "tape_red"
	song_inside = /datum/looping_sound/boombox/rock
	song_name = "Bainmack"

/obj/item/tape/music/hiphop
	icon_state = "tape_purple"
	song_inside = /datum/looping_sound/boombox/hiphop
	song_name = "Groovepad"

/obj/item/tape/music/jazz
	desc = "A special tape that holds music. Wait, this one has jazz on it? You don't see that much anymore..."
	icon_state = "tape_yellow"
	song_inside = /datum/looping_sound/boombox/jazz
	song_name = "Franky's Gonna Boom"

/obj/item/tape/music/jazz/Initialize(mapload)
	. = ..()
	add_deep_lore()

/obj/item/tape/music/jazz/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore_hint = span_notice("You can [EXAMINE_HINT("look closer")] to learn a little more about [src]."), \
		lore = "Jazz is, by technicality, completely legal in the spinward sector. After all, sounds\
			tend not to be the sort of thing that a major corporation can police particularly effectively.\
			Freeform Jazz, on the other hand, had taken on a scandalous identity in the late 2590s, following\
			a legendary crime spree by freeform jazz musician and criminal mastermind [span_bold("Rezz 'The Tips' C'thoni")].\
			In an attempt to prevent a repeat of what happened on Rhozz Alpha, which we ALL remember,\
			TerraGov and a multinational coalition of planets deemed Freeform Jazz to be an active threat to public safety.\
			The more free the jazz, the more serious the crime."
	)

// This exists mostly for testing
/obj/item/storage/box/music_tapes
	name = "box of music tapes"
	desc = "Contains several proprietary, company approved songs for waving above your head on your own jukebox."
	illustration = "music"

/obj/item/storage/box/music_tapes/PopulateContents()
	var/list/items_inside = list(
		/obj/item/tape/music = 1,
		/obj/item/tape/music/rock = 1,
		/obj/item/tape/music/hiphop = 1,
	)
	generate_items_inside(items_inside, src)
