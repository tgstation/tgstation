/obj/machinery/door/puzzle/keycard/library
	name = "wooden door"
	desc = "A dusty, scratched door with a thick lock attached."
	icon = 'icons/obj/doors/puzzledoor/wood.dmi'
	puzzle_id = "library"
	open_message = "The door opens with a loud creak."

/obj/machinery/door/puzzle/keycard/library/animation_length(animation)
	switch(animation)
		if(DOOR_OPENING_ANIMATION)
			return 1.2 SECONDS

/obj/machinery/door/puzzle/keycard/library/animation_segment_delay(animation)
	switch(animation)
		if(DOOR_OPENING_PASSABLE)
			return 1.0 SECONDS
		if(DOOR_OPENING_FINISHED)
			return 1.2 SECONDS

/obj/item/keycard/library
	name = "golden key"
	desc = "A dull, golden key."
	icon_state = "golden_key"
	puzzle_id = "library"

/obj/item/paper/crumpled/bloody/fluff/stations/lavaland/library/warning
	name = "ancient note"
	default_raw_text = "<b>Here lies the vast collection of He Who Knows Ten Thousand Things. Damned be those who seek its knowledge for power.</b>"

/obj/item/paper/crumpled/fluff/stations/lavaland/library/diary
	name = "diary entry 13"
	default_raw_text = "It has been a week since the library was buried, and I haven't seen the owl since. I am so hungry that I can barely muster the energy to think, let alone write. The knowledge seekers seem unaffected."

/obj/item/paper/crumpled/fluff/stations/lavaland/library/diary2
	name = "diary entry 18"
	default_raw_text = "I've lost track of time. I lack the strength to even pick up books off the shelves. To think, after all this time spent searching for the library, I will die before I can so much as graze the depths of its knowledge."

/obj/item/feather
	name = "feather"
	desc = "A dark, wilting feather. It seems as old as time."
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "feather"
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
