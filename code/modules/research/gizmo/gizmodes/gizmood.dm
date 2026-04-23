/// Send out mood pulses, good or bad
/datum/gizmodes/mood_pulser
	guaranteed_active_gizmodes = list(/datum/gizpulse/mood_pulser/positive, /datum/gizpulse/mood_pulser/negative)

/// Send out a mood pulse
/datum/gizpulse/mood_pulser
	/// Mood event to give out
	var/datum/mood_event/mood
	/// Color of the ring effect (god i love the ring effect)
	var/ring_color
	/// Range of the mood pulse
	var/range = 14

/datum/gizpulse/mood_pulser/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	mood_pulse(holder)

/// Send a mood pulse to a range
/datum/gizpulse/mood_pulser/proc/mood_pulse(atom/movable/holder)
	new /obj/effect/temp_visual/circle_wave(get_turf(holder), ring_color)
	for(var/mob/living/carbon/human/human in orange(range, holder))
		human.add_mood_event("gizmo_mood_pulse", mood)

/// Make a positive mood pulse
/datum/gizpulse/mood_pulser/positive
	mood = /datum/mood_event/gizmo_positive
	ring_color = COLOR_GREEN

/// Make a negative mood pulse
/datum/gizpulse/mood_pulser/negative
	mood = /datum/mood_event/gizmo_negative
	ring_color = COLOR_RED
