/obj/item/tape/old_recording
	name = "a recording to my successor"
	desc = "A dusty old tape."
	storedinfo = list(
		"\[00:04\] Three. years.",
		"\[00:07\] Three FUCKING years in this frozen hellhole",
		"\[00:04\]
	)

/obj/item/tape/old_recording/Initialize(mapload)
	. = ..()
	unspool() // the tape spawns damaged
