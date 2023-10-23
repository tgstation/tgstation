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
