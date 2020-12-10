/datum/language/oldworld
	name = "Old World English"
	desc = "A language lost to time. It doesn't make any sense, unless you lived more than 1200 years ago."
	key = "2"
	syllables = list("Our King? Well I didn't vote for you!", "Now go away or I will taunt you a second time!",\
		"First we kill him, then we have biscuts and tea!", "I seek the Holy Grail!", "I am invincible!",\
		"Help, I'm being oppressed. Come and see the violence inherent in the system!", "It's just a scratch. I've had worse.",\
		"Just a flesh wound.", "What knight lives in that castle over there?", "We're an anarcho-syndicalist commune!",\
		"I fart in your general direction!", "Your mother was a hampster!", "Your father smelt of elderberries!",\
		"Go and boil your bottoms, you sons of silly persons!")
	default_priority = 80

	icon_state = "oldworld"

/datum/language/oldworld/scramble(input)
	. = ..()
	return pick(syllables)
