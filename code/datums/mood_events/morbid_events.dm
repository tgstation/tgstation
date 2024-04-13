/* Morbid Mood Events -
Any mood events related to TRAIT_MORBID.
Ususally this is an inverse of a typically good, alturistic action (such as saving someones life), punishing it with a negative mood event,
and rewards typically antisocial/unsavory actions (such as graverobbing) with a positive mood event.
Intended to push a creepy, mad scientist/doctor vibe, or someone who is downright monstrous in nature.
*/

// Positive Events - We did something unsavory in the name of mad science

/datum/mood_event/morbid_dismemberment
	description = "Nothing quite as satisfying as a clean dismemberment!"
	mood_change = 2
	timeout = 2 MINUTES

/datum/mood_event/morbid_dissection_success
	description = "I take pride in my work. Nobody can dissect a body quite like I can."
	mood_change = 2
	timeout = 2 MINUTES

/datum/mood_event/morbid_abominable_surgery_success
	description = "Picasso himself would struggle to match with a brush what I can do with a knife."
	mood_change = 2
	timeout = 2 MINUTES

/datum/mood_event/morbid_revival_success
	description = "IT LIVES! AH HA HA HA HA!!"
	mood_change = 6
	timeout = 8 MINUTES

/datum/mood_event/morbid_graverobbing
	description = "The dead have no need for possessions. I, on the other hand, am very much alive and very much in need."
	mood_change = 2
	timeout = 2 MINUTES

/datum/mood_event/morbid_hauntium
	description = "I feel a better connection with the spirits, I love this!"
	mood_change = 3
	timeout = 6 MINUTES

// Negative Events - We helped someone stay alive.

/datum/mood_event/morbid_tend_wounds
	description = "Why must I waste my talents on this trivial nonsense? Tending to breathers is a waste of effort."
	mood_change = -2
	timeout = 2 MINUTES

/datum/mood_event/morbid_saved_life
	description = "I could have done so much more with their corpse than I could have saving their useless life. Dreadful."
	mood_change = -6
	timeout = 2 MINUTES

