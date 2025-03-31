// These mood events are related to /obj/structure/sign/painting/eldritch
// Names are based on the subtype of painting they belong to

// Mood applied for ripping the painting
/datum/mood_event/eldritch_painting
	description = "I've been hearing weird laughter since cutting down that painting..."
	mood_change = -6
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/weeping
	description = "He is here!"
	mood_change = -3
	timeout = 11 SECONDS

/datum/mood_event/eldritch_painting/weeping_heretic
	description = "His suffering inspires me!"
	mood_change = 5
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/weeping_withdrawal
	description = "My mind is clear. He is not here."
	mood_change = 1
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/desire_heretic
	description = "The void screams."
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/desire_examine
	description = "The hunger has been fed, for now..."
	mood_change = 3
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/heretic_vines
	description = "Oh what a lovely flower!"
	mood_change = 3
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/rust_examine
	description = "That painting really creeped me out."
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/rust_heretic_examine
	description = "Climb. Decay. Rust."
	mood_change = 6
	timeout = 3 MINUTES
