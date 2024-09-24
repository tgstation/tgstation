/datum/mood_event/hemophage_feed_human
	description = "I slaked my hunger on fresh, vital blood. That felt good!"
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/disgust/hemophage_feed_monkey
	description = "I had to feed off a gibbering monkey... what have I become?"
	mood_change = -4
	timeout = 5 MINUTES

/datum/mood_event/disgust/hemophage_feed_humonkey
	description = "Somehow I know deep down that humonkey blood is no substitute for the real thing..."
	mood_change = -1
	timeout = 5 MINUTES

/datum/mood_event/disgust/hemophage_feed_synthesized_blood
	description = "My last blood meal was artificial and tasted... wrong."
	mood_change = -2
	timeout = 5 MINUTES

// Killing someone via hemophage exsanguination gives you a mood buff for the rest of the round.
/datum/mood_event/hemophage_exsanguinate
	description = "I drained someone of all their blood... why do I feel so giddy?"
	mood_change = 4
