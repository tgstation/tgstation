/obj/item/tape/old_recording
	name = "a recording to my successor"
	desc = "A dusty old tape."
	storedinfo =

/obj/item/tape/captains_log/Initialize(mapload)
	. = ..()
	unspool() // the tape spawns damaged
