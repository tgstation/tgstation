//nutrition
/datum/mood_event/fat
	description = "<B>I'm so fat...</B>" //muh fatshaming
	mood_change = -6

/datum/mood_event/wellfed
	description = "I'm stuffed!"
	mood_change = 8

/datum/mood_event/fed
	description = "I have recently had some food."
	mood_change = 5

/datum/mood_event/hungry
	description = "I'm getting a bit hungry."
	mood_change = -6

/datum/mood_event/starving
	description = "I'm starving!"
	mood_change = -10

//charge
/datum/mood_event/supercharged
	description = "I can't possibly keep all this power inside, I need to release some quick!"
	mood_change = -10

/datum/mood_event/overcharged
	description = "I feel dangerously overcharged, perhaps I should release some power."
	mood_change = -4

/datum/mood_event/charged
	description = "I feel the power in my veins!"
	mood_change = 6

/datum/mood_event/lowpower
	description = "My power is running low, I should go charge up somewhere."
	mood_change = -6

/datum/mood_event/decharged
	description = "I'm in desperate need of some electricity!"
	mood_change = -10

//Disgust
/datum/mood_event/gross
	description = "I saw something gross."
	mood_change = -4

/datum/mood_event/verygross
	description = "I think I'm going to puke..."
	mood_change = -6

/datum/mood_event/disgusted
	description = "Oh god, that's disgusting..."
	mood_change = -8

/datum/mood_event/disgust/bad_smell
	description = "I can smell something horribly decayed inside this room."
	mood_change = -6

/datum/mood_event/disgust/nauseating_stench
	description = "The stench of rotting carcasses is unbearable!"
	mood_change = -12

//Generic needs events
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

/datum/mood_event/breakfast
	description = "Nothing like a hearty breakfast to start the shift."
	mood_change = 2
	timeout = 10 MINUTES

/datum/mood_event/nice_shower
	description = "I have recently had a nice shower."
	mood_change = 4
	timeout = 5 MINUTES

/datum/mood_event/fresh_laundry
	description = "There's nothing like the feeling of a freshly laundered jumpsuit."
	mood_change = 2
	timeout = 10 MINUTES


//nutrition
/datum/mood_event/ate_event
	timeout = 10 MINUTES

/datum/mood_event/ate_event/nutriment_paste
	description = "I hate nutrient paste! It's gross!"
	mood_change = -4

/datum/mood_event/ate_event/not_nutriment_paste
	description = "<b>This isn't nutrient paste, what the fuck!? I hate this, I want my NUTRIENT PASTE!!!</b>"
	mood_change = -10

/datum/mood_event/ate_event/no_table
	description = span_warning("I had to eat a meal off the ground. Can't we get a table around here?")
	mood_change = 0

/datum/mood_event/ate_event/no_chair
	description = span_warning("I had to eat a meal while standing. Can't we get some chairs around here?")
	mood_change = 0

/datum/mood_event/ate_event/no_service
	description = span_warning("I had to eat a meal in a place like this. I wish I was eating at the bar or diner!")
	mood_change = 0

/datum/mood_event/ate_event/no_utensils
	description = span_warning("I had to eat a meal with my bare hands. Can't we get some forks around here?")
	mood_change = 0

/datum/mood_event/ate_event/table
	description = "I ate at a nice table. It's so good to have something to set my food on while eating!"
	mood_change = 2

/datum/mood_event/ate_event/chair
	description = "I ate while sitting in a nice chair. It's so good to not have to stand while eating!"
	mood_change = 2

/datum/mood_event/ate_event/service
	description = "I ate my meal in a wonderful dining room. I could stay there forever."
	mood_change = 2

/datum/mood_event/ate_event/utensils
	description = "I ate with utensils. It's so nice not having to eat with my hands!"
	mood_change = 2
