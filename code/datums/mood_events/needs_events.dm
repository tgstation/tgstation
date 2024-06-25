//nutrition
/datum/mood_event/fat
	description = "<B>I'm so fat...</B>" //muh fatshaming
	mood_change = -6

/datum/mood_event/too_wellfed
	description = "I think I've eaten too much."
	mood_change = 0

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

/datum/mood_event/disgust/dirty_food
	description = "That was too dirty to eat..."
	mood_change = -6
	timeout = 4 MINUTES

//Generic needs events
/datum/mood_event/nice_shower
	description = "I have recently had a nice shower."
	mood_change = 4
	timeout = 5 MINUTES

/datum/mood_event/fresh_laundry
	description = "There's nothing like the feeling of a freshly laundered jumpsuit."
	mood_change = 2
	timeout = 10 MINUTES

/datum/mood_event/surrounded_by_silicon
	description = "I'm surrounded by perfect lifeforms!!"
	mood_change = 8

/datum/mood_event/around_many_silicon
	description = "So many silicon lifeforms near me!"
	mood_change = 4

/datum/mood_event/around_silicon
	description = "The silicon lifeforms near me are absolutely perfect."
	mood_change = 2

/datum/mood_event/around_organic
	description = "The organics near me remind me of the inferiority of flesh."
	mood_change = -2

/datum/mood_event/around_many_organic
	description = "So many disgusting organics!"
	mood_change = -4

/datum/mood_event/surrounded_by_organic
	description = "I'm surrounded by disgusting organics!!"
	mood_change = -8

/datum/mood_event/completely_robotic
	description = "I've abandoned my feeble flesh, my form is perfect!!"
	mood_change = 8

/datum/mood_event/very_robotic
	description = "I'm more robot than organic!"
	mood_change = 4

/datum/mood_event/balanced_robotic
	description = "I'm part machine, part organic."
	mood_change = 0

/datum/mood_event/very_organic
	description = "I hate this feeble and weak flesh!"
	mood_change = -4

/datum/mood_event/completely_organic
	description = "I'm completely organic, this is miserable!!"
	mood_change = -8
