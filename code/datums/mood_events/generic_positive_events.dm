/datum/mood_event/hug
	description = "Hugs are nice.\n"
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/betterhug
	description = "Someone was very nice to me.\n"
	mood_change = 3
	timeout = 4 MINUTES

/datum/mood_event/betterhug/add_effects(mob/friend)
	description = "[friend.name] was very nice to me.\n"

/datum/mood_event/besthug
	description = "Someone is great to be around, they make me feel so happy!\n"
	mood_change = 5
	timeout = 4 MINUTES

/datum/mood_event/besthug/add_effects(mob/friend)
	description = "[friend.name] is great to be around, [friend.p_they()] makes me feel so happy!\n"

/datum/mood_event/warmhug
	description = "Warm cozy hugs are the best!\n"
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/arcade
	description = "I beat the arcade game!\n"
	mood_change = 3
	timeout = 8 MINUTES

/datum/mood_event/blessing
	description = "I've been blessed.\n"
	mood_change = 3
	timeout = 8 MINUTES

/datum/mood_event/maintenance_adaptation
	mood_change = 8

/datum/mood_event/maintenance_adaptation/add_effects()
	description = "[GLOB.deity] has helped me adapt to the maintenance shafts!\n"

/datum/mood_event/book_nerd
	description = "I have recently read a book.\n"
	mood_change = 1
	timeout = 5 MINUTES

/datum/mood_event/exercise
	description = "Working out releases those endorphins!\n"
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/pet_animal
	description = "Animals are adorable! I can't stop petting them!\n"
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/pet_animal/add_effects(mob/animal)
	description = "\The [animal.name] is adorable! I can't stop petting [animal.p_them()]!\n"

/datum/mood_event/honk
	description = "I've been honked!\n"
	mood_change = 2
	timeout = 4 MINUTES
	special_screen_obj = "honked_nose"
	special_screen_replace = FALSE

/datum/mood_event/saved_life
	description = "It feels good to save a life.\n"
	mood_change = 6
	timeout = 8 MINUTES

/datum/mood_event/oblivious
	description = "What a lovely day.\n"
	mood_change = 3

/datum/mood_event/jolly
	description = "I feel happy for no particular reason.\n"
	mood_change = 6
	timeout = 2 MINUTES

/datum/mood_event/focused
	description = "I have a goal, and I will reach it, whatever it takes!\n" //Used for syndies, nukeops etc so they can focus on their goals
	mood_change = 4
	hidden = TRUE

/datum/mood_event/badass_antag
	description = "<span class='greentext'>I'm a fucking badass and everyone around me knows it. Just look at them; they're all fucking shaking at the mere thought of having me around.\n"
	mood_change = 7
	hidden = TRUE
	special_screen_obj = "badass_sun"
	special_screen_replace = FALSE

/datum/mood_event/creeping
	description = "<span class='greentext'>The voices have released their hooks on my mind! I feel free again!\n" //creeps get it when they are around their obsession
	mood_change = 18
	timeout = 3 SECONDS
	hidden = TRUE

/datum/mood_event/revolution
	description = "VIVA LA REVOLUTION!\n"
	mood_change = 3
	hidden = TRUE

/datum/mood_event/cult
	description = "I have seen the truth, praise the almighty one!\n"
	mood_change = 10 //maybe being a cultist isn't that bad after all
	hidden = TRUE

/datum/mood_event/heretics
	description = "THE HIGHER I RISE, THE MORE I SEE.\n"
	mood_change = 10 //maybe being a cultist isnt that bad after all
	hidden = TRUE

/datum/mood_event/family_heirloom
	description = "My family heirloom is safe with me.\n"
	mood_change = 1

/datum/mood_event/fan_clown_pin
	description = "I love showing off my clown pin!\n"
	mood_change = 1

/datum/mood_event/fan_mime_pin
	description = "I love showing off my mime pin!\n"
	mood_change = 1

/datum/mood_event/goodmusic
	description = "There is something soothing about this music.\n"
	mood_change = 3
	timeout = 60 SECONDS

/datum/mood_event/chemical_euphoria
	description = "Heh...hehehe...hehe...\n"
	mood_change = 4

/datum/mood_event/chemical_laughter
	description = "Laughter really is the best medicine! Or is it?\n"
	mood_change = 4
	timeout = 3 MINUTES

/datum/mood_event/chemical_superlaughter
	description = "*WHEEZE*\n"
	mood_change = 12
	timeout = 3 MINUTES

/datum/mood_event/religiously_comforted
	description = "I feel comforted by the presence of a holy person.\n"
	mood_change = 3
	timeout = 5 MINUTES

/datum/mood_event/clownshoes
	description = "The shoes are a clown's legacy, I never want to take them off!\n"
	mood_change = 5

/datum/mood_event/sacrifice_good
	description = "The gods are pleased with this offering!\n"
	mood_change = 5
	timeout = 3 MINUTES

/datum/mood_event/artok
	description = "It's nice to see people are making art around here.\n"
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/artgood
	description = "What a thought-provoking piece of art. I'll remember that for a while.\n"
	mood_change = 4
	timeout = 5 MINUTES

/datum/mood_event/artgreat
	description = "That work of art was so great it made me believe in the goodness of humanity. Says a lot in a place like this.\n"
	mood_change = 6
	timeout = 5 MINUTES

/datum/mood_event/pet_borg
	description = "I just love my robotic friends!\n"
	mood_change = 3
	timeout = 5 MINUTES

/datum/mood_event/bottle_flip
	description = "The bottle landing like that was satisfying.\n"
	mood_change = 2
	timeout = 3 MINUTES

/datum/mood_event/hope_lavaland
	description = "What a peculiar emblem.  It makes me feel hopeful for my future.\n"
	mood_change = 10

/datum/mood_event/area
	description = "" //Fill this out in the area
	mood_change = 0

/datum/mood_event/area/add_effects(_mood_change, _description)
	mood_change = _mood_change
	description = _description

/datum/mood_event/confident_mane
	description = "I'm feeling confident with a head full of hair.\n"
	mood_change = 2

/datum/mood_event/holy_consumption
	description = "Truly, that was the food of the Divine!\n"
	mood_change = 5
	timeout = 3 MINUTES

/datum/mood_event/high_five
	description = "I love getting high fives!\n"
	mood_change = 2
	timeout = 45 SECONDS

/datum/mood_event/high_ten
	description = "AMAZING! A HIGH-TEN!\n"
	mood_change = 3
	timeout = 45 SECONDS

/datum/mood_event/down_low
	description = "HA! What a rube, they never stood a chance...\n"
	mood_change = 4
	timeout = 90 SECONDS

/datum/mood_event/aquarium_positive
	description = "Watching fish in an aquarium is calming.\n"
	mood_change = 3
	timeout = 90 SECONDS

/datum/mood_event/gondola
	description = "I feel at peace and feel no need to make any sudden or rash actions.\n"
	mood_change = 6

/datum/mood_event/kiss
	description = "Someone blew a kiss at me, I must be a real catch!\n"
	mood_change = 1.5
	timeout = 2 MINUTES

/datum/mood_event/kiss/add_effects(mob/beau)
	if(beau)
		description = "[beau.name] blew a kiss at me, I must be a real catch!\n"

/datum/mood_event/honorbound
	description = "Following my honorbound code is fulfilling!\n"
	mood_change = 4

/datum/mood_event/et_pieces
	description = "<span class='abductor'>Mmm... I love peanut butter...\n"
	mood_change = 50
	timeout = 10 MINUTES

/datum/mood_event/memories_of_home
	description = "This taste seems oddly nostalgic...\n"
	mood_change = 3
	timeout = 5 MINUTES
