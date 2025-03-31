/datum/mood_event/favorite_food
	description = "I really enjoyed eating that."
	mood_change = 5
	timeout = 4 MINUTES

/datum/mood_event/gross_food
	description = "I really didn't like that food."
	mood_change = -2
	timeout = 4 MINUTES

/datum/mood_event/disgusting_food
	description = "That food was disgusting!"
	mood_change = -6
	timeout = 4 MINUTES

/datum/mood_event/allergic_food
	description = "My throat itches."
	mood_change = -2
	timeout = 4 MINUTES

/datum/mood_event/breakfast
	description = "Nothing like a hearty breakfast to start the shift."
	mood_change = 2
	timeout = 10 MINUTES

/datum/mood_event/food
	timeout = 5 MINUTES
	var/quality = FOOD_QUALITY_NORMAL

/datum/mood_event/food/New(mob/M, ...)
	. = ..()
	mood_change = 2 + 2 * quality
	description = "That food was [GLOB.food_quality_description[quality]]."

/datum/mood_event/food/nice
	quality = FOOD_QUALITY_NICE

/datum/mood_event/food/good
	quality = FOOD_QUALITY_GOOD

/datum/mood_event/food/verygood
	quality = FOOD_QUALITY_VERYGOOD

/datum/mood_event/food/fantastic
	quality = FOOD_QUALITY_FANTASTIC

/datum/mood_event/food/amazing
	quality = FOOD_QUALITY_AMAZING

/datum/mood_event/food/top
	quality = FOOD_QUALITY_TOP

/datum/mood_event/pacifist_eating_fish_item
	description = "I shouldn't be eating living creatures..."
	mood_change = -1 //The disgusting food moodlet already has a pretty big negative value, this is just for context.
	timeout = 4 MINUTES


/datum/mood_event/full_dinner
	description = "I had a good lunch and now I'm full of energy for work."
	mood_change = 6
	timeout = 10 MINUTES

/datum/mood_event/came_late_dinner
	description = "I was a little late, but I still managed to have lunch."
	mood_change = 4
	timeout = 10 MINUTES

/datum/mood_event/dinner_left_early
	description = "I've eaten, and that's enough. Work is more important."
	mood_change = 0
	timeout = 10 MINUTES

/datum/mood_event/introvert_on_dinner
	description = "I don't like dining in crowded places."
	mood_change = -2
	timeout = 10 MINUTES

/datum/mood_event/out_dinner_room_eating
	description = "I don't like eating outside the cafeteria, but work is more important."
	mood_change = -2
	timeout = 10 MINUTES

/datum/mood_event/out_dinner_room_eating_introvert
	description = "I like to have lunch alone."
	mood_change = 6
	timeout = 10 MINUTES

/datum/mood_event/dont_eat_on_dinner
	description = "Lunch is over, and I haven't eaten anything!"
	mood_change = -4
	timeout = 10 MINUTES
