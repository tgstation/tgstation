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
	icon_state = "tape_yellow"
	song_inside = /datum/looping_sound/boombox/jazz
	song_name = "Franky's Gonna Boom"

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
