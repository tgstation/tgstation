/datum/mood_event/hug
	description = "Hugs are nice."
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/bear_hug
	description = "I got squeezed very tightly, but it was quite nice."
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/betterhug
	description = "Someone was very nice to me."
	mood_change = 3
	timeout = 4 MINUTES

/datum/mood_event/betterhug/add_effects(mob/friend)
	description = "[friend.name] was very nice to me."

/datum/mood_event/besthug
	description = "Someone is great to be around, they make me feel so happy!"
	mood_change = 5
	timeout = 4 MINUTES

/datum/mood_event/besthug/add_effects(mob/friend)
	description = "[friend.name] is great to be around, [friend.p_they()] makes me feel so happy!"

/datum/mood_event/warmhug
	description = "Warm cozy hugs are the best!"
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/tailpulled
	description = "I love getting my tail pulled!"
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/arcade
	description = "I beat the arcade game!"
	mood_change = 3
	timeout = 8 MINUTES

/datum/mood_event/blessing
	description = "I've been blessed."
	mood_change = 3
	timeout = 8 MINUTES

/datum/mood_event/maintenance_adaptation
	mood_change = 8

/datum/mood_event/maintenance_adaptation/add_effects()
	description = "[GLOB.deity] has helped me adapt to the maintenance shafts!"

/datum/mood_event/book_nerd
	description = "I have recently read a book."
	mood_change = 1
	timeout = 5 MINUTES

/datum/mood_event/exercise
	description = "Working out releases those endorphins!"
	mood_change = 1

/datum/mood_event/exercise/add_effects(fitness_level)
	mood_change = fitness_level // the more fit you are, the more you like to work out
	return ..()

/datum/mood_event/pet_animal
	description = "Animals are adorable! I can't stop petting them!"
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/pet_animal/add_effects(mob/animal)
	description = "\The [animal.name] is adorable! I can't stop petting [animal.p_them()]!"

/datum/mood_event/honk
	description = "I've been honked!"
	mood_change = 2
	timeout = 4 MINUTES
	special_screen_obj = "honked_nose"
	special_screen_replace = FALSE

/datum/mood_event/saved_life
	description = "It feels good to save a life."
	mood_change = 6
	timeout = 8 MINUTES

/datum/mood_event/oblivious
	description = "What a lovely day."
	mood_change = 3

/datum/mood_event/jolly
	description = "I feel happy for no particular reason."
	mood_change = 6
	timeout = 2 MINUTES

/datum/mood_event/focused
	description = "I have a goal, and I will reach it, whatever it takes!" //Used for syndies, nukeops etc so they can focus on their goals
	mood_change = 4
	hidden = TRUE

/datum/mood_event/badass_antag
	description = "I'm a fucking badass and everyone around me knows it. Just look at them; they're all fucking shaking at the mere thought of having me around."
	mood_change = 7
	hidden = TRUE
	special_screen_obj = "badass_sun"
	special_screen_replace = FALSE

/datum/mood_event/creeping
	description = "The voices have released their hooks on my mind! I feel free again!" //creeps get it when they are around their obsession
	mood_change = 18
	timeout = 3 SECONDS
	hidden = TRUE

/datum/mood_event/revolution
	description = "VIVA LA REVOLUTION!"
	mood_change = 3
	hidden = TRUE

/datum/mood_event/cult
	description = "I have seen the truth, praise the almighty one!"
	mood_change = 10 //maybe being a cultist isn't that bad after all
	hidden = TRUE

/datum/mood_event/heretics
	description = "THE HIGHER I RISE, THE MORE I SEE."
	mood_change = 10 //maybe being a heretic isnt that bad after all
	hidden = TRUE

/datum/mood_event/rift_fishing
	description = "THE MORE I FISH, THE HIGHER I RISE."
	mood_change = 7
	timeout = 5 MINUTES

/datum/mood_event/family_heirloom
	description = "My family heirloom is safe with me."
	mood_change = 1

/datum/mood_event/clown_enjoyer_pin
	description = "I love showing off my clown pin!"
	mood_change = 1

/datum/mood_event/mime_fan_pin
	description = "I love showing off my mime pin!"
	mood_change = 1

/datum/mood_event/goodmusic
	description = "There is something soothing about this music."
	mood_change = 3
	timeout = 60 SECONDS

/datum/mood_event/chemical_euphoria
	description = "Heh...hehehe...hehe..."
	mood_change = 4

/datum/mood_event/chemical_laughter
	description = "Laughter really is the best medicine! Or is it?"
	mood_change = 4
	timeout = 3 MINUTES

/datum/mood_event/chemical_superlaughter
	description = "*WHEEZE*"
	mood_change = 12
	timeout = 3 MINUTES

/datum/mood_event/religiously_comforted
	description = "I feel comforted by the presence of a holy person."
	mood_change = 3
	timeout = 5 MINUTES

/datum/mood_event/clownshoes
	description = "The shoes are a clown's legacy, I never want to take them off!"
	mood_change = 5

/datum/mood_event/sacrifice_good
	description = "The gods are pleased with this offering!"
	mood_change = 5
	timeout = 3 MINUTES

/datum/mood_event/artok
	description = "It's nice to see people are making art around here."
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/artgood
	description = "What a thought-provoking piece of art. I'll remember that for a while."
	mood_change = 4
	timeout = 5 MINUTES

/datum/mood_event/artgreat
	description = "That work of art was so great it made me believe in the goodness of humanity. Says a lot in a place like this."
	mood_change = 6
	timeout = 5 MINUTES

/datum/mood_event/bottle_flip
	description = "The bottle landing like that was satisfying."
	mood_change = 2
	timeout = 3 MINUTES

/datum/mood_event/hope_lavaland
	description = "What a peculiar emblem. It makes me feel hopeful for my future."
	mood_change = 6

/datum/mood_event/confident_mane
	description = "I'm feeling confident with a head full of hair."
	mood_change = 2

/datum/mood_event/holy_consumption
	description = "Truly, that was the food of the Divine!"
	mood_change = 1 // 1 + 5 from it being liked food makes it as good as jolly
	timeout = 3 MINUTES

/datum/mood_event/high_five
	description = "I love getting high fives!"
	mood_change = 2
	timeout = 45 SECONDS

/datum/mood_event/helped_up
	description = "Helping them up felt good!"
	mood_change = 2
	timeout = 45 SECONDS

/datum/mood_event/helped_up/add_effects(mob/other_person, helper)
	if(!other_person)
		return

	if(helper)
		description = "Helping [other_person] up felt good!"
	else
		description = "[other_person] helped me up, how nice of [other_person.p_them()]!"

/datum/mood_event/high_ten
	description = "AMAZING! A HIGH-TEN!"
	mood_change = 3
	timeout = 45 SECONDS

/datum/mood_event/down_low
	description = "HA! What a rube, they never stood a chance..."
	mood_change = 4
	timeout = 90 SECONDS

/datum/mood_event/aquarium_positive
	description = "Watching fish in an aquarium is calming."
	mood_change = 3
	timeout = 90 SECONDS

/datum/mood_event/gondola
	description = "I feel at peace and feel no need to make any sudden or rash actions."
	mood_change = 6

/datum/mood_event/kiss
	description = "Someone blew a kiss at me, I must be a real catch!"
	mood_change = 1.5
	timeout = 2 MINUTES

/datum/mood_event/kiss/add_effects(mob/beau, direct)
	if(!beau)
		return
	if(direct)
		description = "[beau.name] gave me a kiss, ahh!!"
	else
		description = "[beau.name] blew a kiss at me, I must be a real catch!"

/datum/mood_event/honorbound
	description = "Following my honorbound code is fulfilling!"
	mood_change = 4

/datum/mood_event/et_pieces
	description = "Mmm... I love peanut butter..."
	mood_change = 50
	timeout = 10 MINUTES

/datum/mood_event/memories_of_home
	description = "This taste seems oddly nostalgic..."
	mood_change = 3
	timeout = 5 MINUTES

/datum/mood_event/observed_soda_spill
	description = "Ahaha! It's always funny to see someone get sprayed by a can of soda."
	mood_change = 2
	timeout = 30 SECONDS

/datum/mood_event/observed_soda_spill/add_effects(mob/spilled_mob, atom/soda_can)
	if(!spilled_mob)
		return

	description = "Ahaha! [spilled_mob] spilled [spilled_mob.p_their()] [soda_can ? soda_can.name : "soda"] all over [spilled_mob.p_them()]self! Classic."

/datum/mood_event/gaming
	description = "I'm enjoying a nice gaming session!"
	mood_change = 2
	timeout = 30 SECONDS

/datum/mood_event/gamer_won
	description = "I love winning video games!"
	mood_change = 10
	timeout = 5 MINUTES

/datum/mood_event/love_reagent
	description = "This food reminds me of the good ol' days."
	mood_change = 5

/datum/mood_event/love_reagent/add_effects(duration)
	if(isnum(duration))
		timeout = duration

/datum/mood_event/won_52_card_pickup
	description = "HA! That loser will be picking cards up for a long time!"
	mood_change = 3
	timeout = 3 MINUTES

/datum/mood_event/playing_cards
	description = "I'm enjoying playing cards with other people!"
	mood_change = 2
	timeout = 3 MINUTES

/datum/mood_event/playing_cards/add_effects(param)
	var/card_players = 1
	for(var/mob/living/carbon/player in viewers(COMBAT_MESSAGE_RANGE, owner))
		var/player_has_cards = player.is_holding(/obj/item/toy/singlecard) || player.is_holding_item_of_type(/obj/item/toy/cards)
		if(player_has_cards)
			card_players++
			if(card_players > 5)
				break

	mood_change *= card_players
	return ..()

/datum/mood_event/garland
	description = "These flowers are rather soothing."
	mood_change = 1

/datum/mood_event/russian_roulette_win
	description = "I gambled my life and won! I'm lucky to be alive..."
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/russian_roulette_win/add_effects(loaded_rounds)
	mood_change = 2 ** loaded_rounds

/datum/mood_event/fishing
	description = "Fishing is relaxing."
	mood_change = 4
	timeout = 3 MINUTES

/datum/mood_event/fish_released
	description = "Go, fish, swim and be free!"
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/fish_released/add_effects(morbid, obj/item/fish/fish)
	if(!morbid)
		description = "Go, [fish.name], swim and be free!"
		return
	if(fish.status == FISH_DEAD)
		description = "Some scavenger will surely find a use for the remains of [fish.name]. How pragmatic."
	else
		description = "Returned to the burden of the deep. But is this truly a mercy, [fish.name]? There will always be bigger fish..."

/datum/mood_event/fish_petting
	description = "It felt nice to pet the fish."
	mood_change = 2
	timeout = 2 MINUTES

/datum/mood_event/fish_petting/add_effects(obj/item/fish/fish, morbid)
	if(!morbid)
		description = "It felt nice to pet \the [fish]."
	else
		description = "I caress \the [fish] as [fish.p_they()] squirms under my touch, blissfully unaware of how cruel this world is."

/datum/mood_event/kobun
	description = "You are all loved by the Universe. I’m not alone, and you aren’t either."
	mood_change = 14
	timeout = 10 SECONDS

/datum/mood_event/sabrage_success
	description = "I pulled that sabrage stunt off! Feels good to be a show-off."
	mood_change = 2
	timeout = 4 MINUTES

/datum/mood_event/sabrage_witness
	description = "I saw someone pop the cork off a champagne bottle in quite a radical fashion."
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/birthday
	description = "It's my birthday!"
	mood_change = 2
	special_screen_obj = "birthday"
	special_screen_replace = FALSE

/datum/mood_event/basketball_score
	description = "Swish! Nothing but net."
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/basketball_dunk
	description = "Slam dunk! Boom, shakalaka!"
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/moon_smile
	description = "THE MOON SHOWS ME THE TRUTH AND ITS SMILE IS FACED TOWARDS ME!!!"
	mood_change = 10
	timeout = 2 MINUTES

///Wizard cheesy grand finale - what the wizard gets
/datum/mood_event/madness_elation
	description = "Madness truly is the greatest of blessings..."
	mood_change = 200

/datum/mood_event/prophat
	description = "This hat fills me with whimsical joy!"
	mood_change = 2
