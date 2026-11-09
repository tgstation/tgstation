/datum/mood_event/it_was_on_the_mouse
	description = "Heh heh. \"It's on the mouse\". What a play on words."
	mood_change = 1
	timeout = 2 MINUTES
	event_flags = MOOD_EVENT_WHIMSY

/datum/mood_event/gondola_serenity
	description = "There's a lot that could be on your mind right now. But this feeling of contentedness, a universal calling to simply sit back and observe is washing over you..."
	mood_change = 10
	special_screen_obj = "mood_gondola"

/datum/mood_event/fish_waterless
	mood_change = -3
	description = "It sucks to be dry. I feel like a fish out of water."

/datum/mood_event/fish_water
	mood_change = 1
	description = "Glug glug!"
