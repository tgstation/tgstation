/// A doctor successfuly completed a surgery on someone.
/datum/memory/surgery
	story_value = STORY_VALUE_OKAY
	// Protagonist - The surgeon, completing the surgery
	// Deuteragonist - The mob being operated on
	/// What type of surgery it was
	var/surgery_type

/datum/memory/surgery/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	surgery_type,
)
	src.surgery_type = surgery_type
	return ..()

/datum/memory/surgery/get_names()
	return list("The [surgery_type] of [deuteragonist_name] by [protagonist_name].")

/datum/memory/surgery/get_starts()
	return list(
		"[protagonist_name] carefully performing [surgery_type] on [deuteragonist_name]",
		"[protagonist_name] using a bone saw on [deuteragonist_name]",
		"[deuteragonist_name] being operated on by [protagonist_name]",
	)

/datum/memory/surgery/get_moods()
	return list(
		"[protagonist_name] [mood_verb] after finishing [surgery_type].",
		"[protagonist_name] [mood_verb] as a blood splatter lands on [protagonist_name]'s face.",
		"[protagonist_name] [mood_verb] as the [surgery_type] continues.",
		"[protagonist_name] [mood_verb] as they pick apart [deuteragonist_name].",
		"[protagonist_name] [mood_verb] as they tear into [deuteragonist_name].",
	)

/// Planted a bomb.
/datum/memory/bomb_planted
	story_value = STORY_VALUE_MEH
	// Protagonist - Whoever armed the bomb
	// Antaognist - The bomb that was armed

/datum/memory/bomb_planted/get_names()
	return list("The arming of [antagonist_name] by [protagonist_name].")

/datum/memory/bomb_planted/get_starts()
	return list(
		"[protagonist_name] pressing an ominous button, causing [antagonist_name] to begin beeping",
		"[protagonist_name] slapping down [antagonist_name]",
		"[antagonist_name] being armed by [protagonist_name]",
	)

/datum/memory/bomb_planted/get_moods()
	return list(
		"[protagonist_name] [mood_verb] and begins to walk away from it.",
		"[protagonist_name] [mood_verb] as it begins to tick.",
		"[protagonist_name] [mood_verb] with it winding down.",
		"beep... beep... [protagonist_name] [mood_verb]."
	)

/datum/memory/bomb_planted/get_happy_moods()
	return list("feels too cool to look at [antagonist_name]")

/// Planted a SYNDICATE bomb.
/datum/memory/bomb_planted/syndicate
	story_value = STORY_VALUE_AMAZING

/// Planted a NUKE!
/datum/memory/bomb_planted/nuke
	story_value = STORY_VALUE_LEGENDARY

/// Got a sweet high five.
/datum/memory/high_five
	story_value = STORY_VALUE_MEH
	// Protagonist - One of the high-fivers
	// Deuteragonist - The other high fiver
	/// What type of high five it was - A "high five" or a "high ten"
	var/high_five_type

/datum/memory/high_five/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	high_five_type,
	high_ten = FALSE,
)
	src.high_five_type = high_five_type
	src.story_value = high_ten ? STORY_VALUE_OKAY : STORY_VALUE_MEH
	return ..()

/datum/memory/high_five/get_names()
	return list("The [high_five_type] between [protagonist_name] and [deuteragonist_name].")

/datum/memory/high_five/get_starts()
	return list(
		"[protagonist_name] and [deuteragonist_name] having a a legendary [high_five_type]",
		"[protagonist_name] giving [deuteragonist_name] a [high_five_type]",
		"[protagonist_name] and [deuteragonist_name] giving each other a [high_five_type]",
	)

/datum/memory/high_five/get_moods()
	return list(
		"[protagonist_name] [mood_verb] as the [high_five_type] connects.",
		"[protagonist_name] [mood_verb] at all the compatriotism going on.",
		"What a [high_five_type]! [protagonist_name] [mood_verb].",
		"Wow! [protagonist_name] [mood_verb]!",
	)

/// Was cyborgized.
/datum/memory/was_cyborged
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_FLAG_NOMOOD|MEMORY_SKIP_UNCONSCIOUS
	// Protagonist - The mind of who was just cyborgized

/datum/memory/was_cyborged/get_names()
	return list("The borging of [protagonist_name].")

/datum/memory/was_cyborged/get_starts()
	return list(
		"[protagonist_name] having their brain put into a robot",
		"[protagonist_name] getting turned into a bucket of bolts",
	)

/// Witnessed someone die nearby.
/datum/memory/witnessed_death
	story_value = STORY_VALUE_MEH // this is pretty common on this hellhole
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS|MEMORY_FLAG_NOMOOD
	// Protagonist - Who died

/datum/memory/witnessed_death/get_names()
	return list("The death of [protagonist_name].")

/datum/memory/witnessed_death/get_starts()
	return list(
		"[protagonist_name] having perished",
		"[protagonist_name] seizing up and falling limp, their eyes appearing dead and lifeless",
		"[protagonist_name]'s heart stopping",
		"the death of [protagonist_name]",
	)

/// Witnessed someone get creampied nearby.
/datum/memory/witnessed_creampie
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist - The mob that got pied

/datum/memory/witnessed_creampie/get_names()
	return list("The creaming of [protagonist_name].")

/datum/memory/witnessed_creampie/get_starts()
	return list(
		"[protagonist_name]'s face being covered in cream",
		"[protagonist_name] getting cream-pied",
	)

/datum/memory/witnessed_creampie/get_moods()
	return list(
		"[protagonist_name] [mood_verb] as the cream drips off their face",
		"[protagonist_name] [mood_verb] because of their now expanded laundry task.",
		"[protagonist_name] [mood_verb] as they lick off some of the pie",
	)

/// Got slipped by something.
/datum/memory/was_slipped
	story_value = STORY_VALUE_MEH
	// Protagonist - The mob that got slipped
	// Antagonist - The thing that did the slipping (banana peel, etc)

/datum/memory/was_slipped/get_names()
	return list("The slipping of [protagonist_name].")

/datum/memory/was_slipped/get_starts()
	return list(
		"[protagonist_name] not being able to keep standing when faced with [antagonist_name]",
		"[protagonist_name] tumbling right over [antagonist_name]",
		"[antagonist_name] which took [protagonist_name] down a notch",
	)

/datum/memory/was_slipped/get_moods()
	return list(
		"[protagonist_name] [mood_verb] as they crawl up from the ground.",
		"[protagonist_name] [mood_verb] while on the ground.",
	)

/datum/memory/was_slipped/get_sad_moods()
	return list("doesn't even want to get up and looks depressed")

/datum/memory/was_slipped/build_story_character(character)
	// We can slip on turfs, so we should account for it
	if(isturf(character))
		var/turf/place = character
		return "the [prob(50) ? "perilous " : ""][pick("wet", "lubed", "slippery", "cold")] [place.name]"

	return ..()

/// Had spaghetti fall from their pockets.
/datum/memory/lost_spaghetti
	story_value = STORY_VALUE_AMAZING // This doesn't happen very often
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist - The mob losing their spaghet

/datum/memory/lost_spaghetti/get_names()
	return list("[protagonist_name]'s spaghetti blunder.")

/datum/memory/lost_spaghetti/get_starts()
	return list(
		"[protagonist_name]'s spaghetti pouring out of their pockets",
		"[protagonist_name]'s pockets not being able to contain their spaghetti",
	)

/datum/memory/lost_spaghetti/get_moods()
	return list(
		"[protagonist_name] [mood_verb] as the spaghetti poured out.",
		"[protagonist_name] [mood_verb] as they try to pick up the scraps.",
	)

/// Got kissed! AHHHHH!
/datum/memory/kissed
	story_value = STORY_VALUE_MEH
	// Sorry but blind people can't feel kisses...
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist - The mob being kissed
	// Deuteragonist - The mob doing the kissing

/datum/memory/kissed/get_names()
	return list("the kiss blown to [protagonist_name]")

/datum/memory/kissed/get_starts()
	return list(
		"[protagonist_name]'s receiving a blown kiss from [deuteragonist_name]",
		"[deuteragonist_name] blowing a kiss to [protagonist_name]",
	)

/datum/memory/kissed/get_moods()
	return list(
		"[protagonist_name] [mood_verb] as the kiss lands on their cheek.",
		"[protagonist_name] [mood_verb] as it happen.",
	)

/// Had some good food.
/datum/memory/good_food
	story_value = STORY_VALUE_MEH
	// Protagonist - The mob consuming the food
	/// The name of the food item being consumed
	var/food

/datum/memory/good_food/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	obj/item/food,
)
	src.food = food.name
	return ..()

/datum/memory/good_food/get_names()
	return list("A delicious [food] [protagonist_name] ate")

/datum/memory/good_food/get_starts()
	return list(
		"[food] changing [protagonist_name]'s outlook on food",
		"[food] is leaving [protagonist_name] round and full",
		"[food] leaving a long lasting impression on [protagonist_name]",
		"[protagonist_name] enjoying an incredibly good [food]",
		"[protagonist_name] producing a slice of life anime reaction to eating [food]",
	)

/datum/memory/good_food/get_moods()
	return list("[protagonist_name] [mood_verb] as they take another bite.")

/// Had a good drink.
/datum/memory/good_drink
	story_value = STORY_VALUE_MEH
	// Protagonist - The mob consuming the drink
	/// The name of the nice drink reagent
	var/drink

/datum/memory/good_drink/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	datum/reagent/drink,
)
	src.drink = drink.name
	return ..()

/datum/memory/good_drink/get_names()
	return list("a delicious [drink] [protagonist_name] consumed")

/datum/memory/good_drink/get_starts()
	return list(
		"[drink] changing [protagonist_name]'s outlook on classy drinking",
		"[drink] leaving a long lasting impression on [protagonist_name]",
		"[protagonist_name] enjoying an incredibly good [drink]",
		"[protagonist_name] slurping some tasty [drink]",
	)

/datum/memory/good_drink/get_moods()
	return list("[protagonist_name] [mood_verb] as they take another sip.")

/// Was set on fire and started to burn.
/datum/memory/was_burning
	story_value = STORY_VALUE_MEH
	// Protagonist - The mob burning

/datum/memory/was_burning/get_names()
	return list("The burning of [protagonist_name].")

/datum/memory/was_burning/get_starts()
	return list(
		"[protagonist_name] bursting into flames",
		"[protagonist_name] turning into a human torch",
		"the fire that engulfed [protagonist_name]",
	)

/datum/memory/was_burning/get_moods()
	return list("[protagonist_name] [mood_verb] as their skin melts.")

/// Got a limb removed by force.
/datum/memory/was_dismembered
	story_value = STORY_VALUE_AMAZING
	// Protagonist - The mob who lost a limb
	/// The limb (in plaintext) that got lost (ends up being "left arm" or "right leg")
	var/lost_limb

/datum/memory/was_dismembered/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	obj/item/bodypart/lost_limb,
)
	src.lost_limb = lost_limb.plaintext_zone
	return ..()

/datum/memory/was_dismembered/get_names()
	return list("The loss of [protagonist_name]'s [lost_limb].")

/datum/memory/was_dismembered/get_starts()
	return list(
		"[protagonist_name] becoming eligible for handicapped parking",
		"[protagonist_name]'s [lost_limb] being shot into the abyss",
		"[protagonist_name]'s [lost_limb] flinging away",
	)

/datum/memory/was_dismembered/get_moods()
	return list(
		"[protagonist_name] [mood_verb] after losing [lost_limb].",
		"Without [lost_limb], [protagonist_name] [mood_verb].",
	)

/// Our pet died...
/datum/memory/pet_died
	story_value = STORY_VALUE_AMAZING
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	// Protagonist - The mob who saw the pet die
	// Deuteragonist - The pet which died

/datum/memory/pet_died/get_names()
	return list("The death of [deuteragonist_name].")

/datum/memory/pet_died/get_starts()
	return list(
		"honoring [deuteragonist_name], the station's pet",
		"[deuteragonist_name]'s funeral, which is attended by a group of crew members",
		"a shallow hole, with [deuteragonist_name] inside",
	)

/datum/memory/pet_died/get_moods()
	return list(
		"[protagonist_name] [mood_verb] without [deuteragonist_name].",
		"Without [deuteragonist_name], [protagonist_name] [mood_verb].",
	)

/// The revolution was triumphant!
/// Given to head revs and those nearby when the revs win a revolution.
/datum/memory/revolution_rev_victory
	story_value = STORY_VALUE_LEGENDARY
	memory_flags = MEMORY_FLAG_NOSTATIONNAME|MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	// Protagonist - The head revolutionary that won the revolution

/datum/memory/revolution_rev_victory/get_names()
	return list("The revolution of [station_name()] by [protagonist_name].")

/datum/memory/revolution_rev_victory/get_starts()
	return list(
		"[protagonist_name] raising the flag of the revolution over the corpses of the former dictators",
		"a flag waving above a pile of corpses with [protagonist_name] standing over it",
		"a poster that says [station_name()] with a cross in it, hailing in a new era",
		"a statue of the former captain toppled over, with [protagonist_name] next to it",
	)

/datum/memory/revolution_rev_victory/get_moods()
	return list(
		"[protagonist_name] [mood_verb] at the fall of [station_name()].",
		"[protagonist_name] [mood_verb] at the idea of the new era.",
	)

/// Given to heads of staff if they lose a revolution and are alive still.
/datum/memory/revolution_heads_defeated
	story_value = STORY_VALUE_NONE
	memory_flags = MEMORY_FLAG_NOSTATIONNAME|MEMORY_SKIP_UNCONSCIOUS
	// Protagonist - The head of staff that lost the revolution

/datum/memory/revolution_heads_defeated/get_names()
	return list("The defeat of [protagonist_name] at the hands of the revolution")

/datum/memory/revolution_heads_defeated/get_starts()
	return list(
		"[protagonist_name] fleeing [station_name()] in shame due to the success of the revolution",
		"[protagonist_name] looking at a camera feed of rampaging revolutionaries",
		"a poster with [protagonist_name]'s face stratched out",
	)

/datum/memory/revolution_heads_defeated/get_moods()
	return list(
		"[protagonist_name] [mood_verb] at the fall of [station_name()].",
		"[protagonist_name] [mood_verb] at their defeat.",
	)

/// Given to head revs for failing the revolution!
/datum/memory/revolution_rev_defeat
	story_value = STORY_VALUE_NONE
	memory_flags = MEMORY_FLAG_NOSTATIONNAME|MEMORY_SKIP_UNCONSCIOUS
	// Protagonist - The head revolutionary that lost the revolution

/datum/memory/revolution_rev_defeat/get_names()
	return list(
		"The defeat of [protagonist_name] at the hands of the Nanotrasen",
		"The end of [protagonist_name]'s glorious revolution",
	)

/datum/memory/revolution_rev_defeat/get_starts()
	return list("[protagonist_name] fleeing [station_name()] in shame due to the failure of their revolution")

/datum/memory/revolution_rev_defeat/get_moods()
	return list("[protagonist_name] [mood_verb] at their defeat.")

/// Given to heads of staff, and those around them, upon defeating the revolutionaries.
/datum/memory/revolution_heads_victory
	story_value = STORY_VALUE_AMAZING // Not as cool as a rev victory. Everyone loves underdog stories
	memory_flags = MEMORY_FLAG_NOSTATIONNAME|MEMORY_SKIP_UNCONSCIOUS
	// Protagonist - The head of staff that won the revolution

/datum/memory/revolution_heads_victory/get_names()
	return list("The success of [protagonist_name] and Nanotrasen over the hateful revolution")

/datum/memory/revolution_heads_victory/get_starts()
	return list(
		"[protagonist_name] dusting off their hands in victory over the revoution",
		"the banner of Nanotrasen flying on the bridge of [station_name()] with [protagonist_name] proudly beside it",
	)

/datum/memory/revolution_rev_defeat/get_moods()
	return list("[protagonist_name] [mood_verb] over the defeat of the revolution by the hands of Nanotrasen.")

/// Watched someone receive a commendation medal
/datum/memory/received_medal
	story_value = STORY_VALUE_AMAZING
	memory_flags = MEMORY_FLAG_NOSTATIONNAME|MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	// Protagonist - The person being given a medal
	// Deuteragonist - The mob awarding a medal
	/// The name of the medal being rewarded
	var/medal_type
	/// The text on the medal / the commendation / the input
	var/medal_text

/datum/memory/received_medal/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	obj/item/medal_type,
	medal_text,
)
	src.medal_type = medal_type.name
	src.medal_text = medal_text
	return ..()

/datum/memory/received_medal/get_names()
	return list("The award ceremony of [medal_type] to [protagonist_name].")

/datum/memory/received_medal/get_starts()
	return list(
		"[protagonist_name] accepting a [medal_type] inscribed with \"[medal_text]\" from [deuteragonist_name]",
		"[protagonist_name] receiving a [medal_type] with the inscription \"[medal_text]\"",
		"a [medal_type] with the inscription \"[medal_text]\" being awarded to [protagonist_name] by [deuteragonist_name]",
	)

/datum/memory/received_medal/get_moods()
	return list(
		"[protagonist_name] [mood_verb] as they receive their medal.",
		"[protagonist_name] [mood_verb] with their newly received award.",
	)

/// Killed a Megafauna
/datum/memory/megafauna_slayer
	story_value = STORY_VALUE_LEGENDARY
	// Protagonist - The person who killed the megafauna
	// Antagonist - The megafauna

/datum/memory/megafauna_slayer/get_names()
	return list("The slaughter of [antagonist_name].")

/datum/memory/megafauna_slayer/get_starts()
	return list(
		"[protagonist_name] performing the final strike on [antagonist_name], taking it down",
		"[protagonist_name] standing with the head of [antagonist_name] in their hand",
		"the killing of [antagonist_name], the dangerous megafauna, by [protagonist_name]",
	)

/datum/memory/megafauna_slayer/get_moods()
	return list(
		"[protagonist_name] [mood_verb] as the blood lust fades from their eyes.",
		"[protagonist_name] [mood_verb] as they search the corpse for valuables.",
	)

/// Got held at gunpoint by someone!
/datum/memory/held_at_gunpoint
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist - Who was held at gunpoint
	// Deuteragonist - Who held them at gunpoint
	// Antagonist - The gun

/datum/memory/held_at_gunpoint/get_names()
	return list("[protagonist_name] being held at gunpoint.")

/datum/memory/held_at_gunpoint/get_starts()
	return list(
		"[protagonist_name] with [antagonist_name] pressed to their skull by [deuteragonist_name]",
		"[deuteragonist_name] whipping out [antagonist_name] and pointing it at [protagonist_name]",
	)

/datum/memory/held_at_gunpoint/get_moods()
	return list(
		"[protagonist_name] [mood_verb] as they are faced with the situation.",
		"[protagonist_name] [mood_verb] as they stare down [antagonist_name]'s barrel.",
	)

/// Saw someone get gibbed.
/datum/memory/witness_gib
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_FLAG_NOMOOD
	// Protagonist - Who got gibbed

/datum/memory/witness_gib/get_names()
	return list("[protagonist_name] exploding into bits.")

/datum/memory/witness_gib/get_starts()
	return list(
		"[protagonist_name] exploding into little fleshy bits",
		"[protagonist_name] becoming flesh paste in the blink of an eye",
	)

/// Saw someone get crushed by a vending machine.
/datum/memory/witness_vendor_crush
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_SKIP_UNCONSCIOUS
	// Protagonist - Who got crushed
	// Antagonist - The vendor that crushed them

/datum/memory/witness_vendor_crush/get_names()
	return list("[protagonist_name] being crushed by [antagonist_name].")

/datum/memory/witness_vendor_crush/get_starts()
	return list(
		"[protagonist_name] being crushed by the [antagonist_name]",
		"the [antagonist_name] that crashed on top of [protagonist_name]",
		"the fall of [antagonist_name] onto [protagonist_name]",
	)

/datum/memory/witness_vendor_crush/get_moods()
	return list(
		"[protagonist_name] [mood_verb] as they lie under the machine.",
		"[protagonist_name] [mood_verb] as a goodie falls out of the [antagonist_name]."
	)

/// Saw someone get dusted by the supermatter.
/datum/memory/witness_supermatter_dusting
	story_value = STORY_VALUE_AMAZING
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist - Who got dusted
	// Antagonist - The supermatter

/datum/memory/witness_supermatter_dusting/get_names()
	return list("The dusting of [protagonist_name] by the [antagonist_name].")

/datum/memory/witness_supermatter_dusting/get_starts()
	return list(
		"[protagonist_name] turning into a pile of bones after touching the [antagonist_name]",
		"The [antagonist_name] turning [protagonist_name] into ash",
		"The dusting of [protagonist_name] after they got too close to the [antagonist_name]",
	)

/datum/memory/witness_supermatter_dusting/get_moods()
	return list(
		"[protagonist_name] [mood_verb] as they faded way.",
		"[protagonist_name] [mood_verb] as they are reduced to atoms.",
	)

/// Played cards with another person.
/datum/memory/playing_cards
	story_value = STORY_VALUE_MEH
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist - The player
	// Deuteragonist - The game dealer (which may be a player OR in the players list)
	/// What card game is being played
	var/game
	/// The card the protagonist is holding
	var/protagonist_held_card
	/// A string (english list) of all the mobs playing the game
	var/formatted_players_list

/datum/memory/playing_cards/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	game,
	obj/item/protagonist_held_card,
	list/mob/living/other_players,
)
	src.game = game
	src.protagonist_held_card = protagonist_held_card.name

	var/list/story_players = list()
	for(var/mob/living/player as anything in other_players)
		// This will result in some strange structure sometimes -
		// "The assistant, the assistant, and the assistant playing a game",
		// but meh. Someone can improve upon it in the future
		story_players += build_story_character(player)

	src.formatted_players_list = english_list(story_players, nothing_text = "no-one")
	return ..()

/datum/memory/playing_cards/get_names()
	return list("The [game] of [protagonist_name] with [formatted_players_list].")

/datum/memory/playing_cards/get_starts()
	return list(
		"[formatted_players_list] waiting for [protagonist_name] to start the [game]",
		"The [game] has been setup by [deuteragonist_name]",
		"[deuteragonist_name] starts shuffling the deck for the [game]",
	)

/datum/memory/playing_cards/get_moods()
	return list(
		"[protagonist_name] [mood_verb] as they hold the [protagonist_held_card] for the [game].",
		"[protagonist_name] [mood_verb] as they pickup the [protagonist_held_card].",
		"[protagonist_name] [mood_verb] as they put down the [protagonist_held_card].",
	)

/// Played 52 card pickup with another person.
/datum/memory/playing_card_pickup
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist - The guy who initiated the game
	// Deuteragonist - The guy who got the cards thrown in their face
	// Antagonist - The deck of cards

/datum/memory/playing_card_pickup/get_names()
	return list("[protagonist_name] tricking [deuteragonist_name] into playing 52 pickup with [antagonist_name].")

/datum/memory/playing_card_pickup/get_starts()
	return list(
		"[protagonist_name] tossing the [antagonist_name] at [deuteragonist_name] spilling cards all over the floor",
		"A [antagonist_name] thrown by [protagonist_name] splatters across [deuteragonist_name] face",
	)

/datum/memory/playing_card_pickup/get_moods()
	return list(
		"[protagonist_name] [mood_verb] as they taunt [deuteragonist_name].",
		"[deuteragonist_name] [mood_verb] as they shamefully pickup the cards.",
	)

/// Saw someone play Russian Roulette.
/datum/memory/witnessed_russian_roulette
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist = The guy who played roulette
	// Antagonist = The revolver
	/// The bodypart the protagonist was aiming at
	var/aimed_at
	/// How many rounds were loaded in the revolver
	var/rounds_loaded
	/// The result of the game ("won"(survived) or "lost"(shot themselves))
	var/result

/datum/memory/witnessed_russian_roulette/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	aimed_at,
	rounds_loaded = 0,
	result,
)
	src.aimed_at = aimed_at
	src.rounds_loaded = rounds_loaded
	src.result = result

	if(result == "won")
		// The more bullets, the better the story.
		story_value = max(STORY_VALUE_NONE, rounds_loaded)
	else
		story_value = STORY_VALUE_SHIT

	return ..()

/datum/memory/witnessed_russian_roulette/get_names()
	return list("[protagonist_name] playing a game of russian roulette.")

/datum/memory/witnessed_russian_roulette/get_starts()
	return list(
		"[protagonist_name] aiming at their [aimed_at] right before they pull the trigger.",
		"The revolver has [rounds_loaded] rounds loaded in the chamber.",
		"[protagonist_name] is gambling their life as they spin the revolver.",
	)

/datum/memory/witnessed_russian_roulette/get_moods()
	return list("[protagonist_name] [mood_verb] as they [result] the deadly game of roulette.")

/// When a heretic finishes their ritual of knowledge
/datum/memory/heretic_knowledge_ritual
	story_value = STORY_VALUE_AMAZING
	// Protagonist = heretic

/datum/memory/heretic_knowledge_ritual/get_names()
	return list("[protagonist_name] absorbing boundless knowledge through eldritch research.")

/datum/memory/heretic_knowledge_ritual/get_starts()
	return list(
		"[protagonist_name] laying out a circle of green tar and candles",
		"multiple books around [protagonist_name] flipping open",
		"green and purple energy surrounding [protagonist_name]",
		"[protagonist_name], eyes wide open and unblinking, reading a strange book",
		"a pile of gore and viscera on a complex looking rune",
		"a wide, strange looking circle, with [protagonist_name] sketching it"
	)

/datum/memory/heretic_knowledge_ritual/get_moods()
	return list("[protagonist_name] [mood_verb] as their hand glows with power.")

/datum/memory/heretic_knowledge_ritual/get_happy_moods()
	return list("cackling madly")

/datum/memory/heretic_knowledge_ritual/get_neutral_moods()
	return list("staring blankly with a wide grin")

/datum/memory/heretic_knowledge_ritual/get_sad_moods()
	return list("cackling insanely")

/// Failed to defuse a bomb, by triggering it early.
/datum/memory/bomb_defuse_failure
	story_value = STORY_VALUE_NONE // Anyone who gets this is probably dead
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	// Protagonist = (failed) defuser
	// Antagonist = bomb

/datum/memory/bomb_defuse_failure/get_names()
	return list("[protagonist_name] failing to defuse [antagonist_name].")

/datum/memory/bomb_defuse_failure/get_starts()
	return list(
		"[protagonist_name] cutting the wrong wire on [antagonist_name]",
		"[protagonist_name] sweating nervously and shielding their face as [antagonist_name] makes a loud noise",
		"The clock on [antagonist_name] suddenly jumping to 0 seconds"
	)

/datum/memory/bomb_defuse_failure/get_moods()
	return list("[protagonist_name] [mood_verb] as they snip a wire on [antagonist_name].")

/// Succeeded in defusing a bomb!
/datum/memory/bomb_defuse_success
	story_value = STORY_VALUE_LEGENDARY // Very sick, and can't be gotten from training bombs
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	// Protagonist = defuser
	// Antagonist = bomb
	/// This is the time left (in seconds) of the bomb at defusal
	var/bomb_time_left

/datum/memory/bomb_defuse_success/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	bomb_time_left = -1,
)
	src.bomb_time_left = bomb_time_left
	return ..()

/datum/memory/bomb_defuse_success/get_names()
	return list("[protagonist_name] successfully defusing [antagonist_name].")

/datum/memory/bomb_defuse_success/get_starts()
	return list(
		"[protagonist_name] cutting the right wire on [antagonist_name]",
		"[protagonist_name] sweating nervously and shielding their face as [antagonist_name] makes a shrill beep",
		"The clock on [antagonist_name] stopping at [bomb_time_left]"
	)

/datum/memory/bomb_defuse_success/get_moods()
	return list("[protagonist_name] [mood_verb] as they snip a wire on [antagonist_name].")


/datum/memory/helped_up
	story_value = STORY_VALUE_OKAY

/datum/memory/helped_up/get_names()
	return list("[protagonist_name] gentlemanly helping up [deuteragonist_name].")

/datum/memory/helped_up/get_starts()
	return list(
		"[protagonist_name] helping up [deuteragonist_name]",
		"[deuteragonist_name] taking the hand offered graciously by [protagonist_name] to get up",
	)

/// Catching a fish
/datum/memory/caught_fish
	story_value = STORY_VALUE_OKAY

/datum/memory/caught_fish/get_names()
	return list(
		"[protagonist_name] catching an absolute honker.",
		"[protagonist_name] caught a [deuteragonist_name].",
	)

/datum/memory/caught_fish/get_starts()
	return list(
		"[protagonist_name] reels in the line",
		"[protagonist_name]'s eye glints, and they begin reeling",
		"in a fishing trance, [protagonist_name] catches something",
		"[protagonist_name] begins battle with a fish",
		"a whole lot of fishing going on",
	)

/datum/memory/caught_fish/get_moods()
	return list(
		"[protagonist_name] [mood_verb] as a [deuteragonist_name] flies out of the water!",
		"[protagonist_name] [mood_verb] as they catch a [deuteragonist_name]!",
		"[protagonist_name] [mood_verb] as they pose holding a [deuteragonist_name]!",
	)

/datum/memory/caught_fish/get_sad_moods()
	return list("partakes in therapy fishing")

/// Becoming a mutant via infusion
/datum/memory/dna_infusion
	story_value = STORY_VALUE_MEH
	///describing what they turn into, "skittish", "nomadic", etc
	var/mutantlike

/datum/memory/dna_infusion/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	mutantlike,
)
	src.mutantlike = mutantlike
	return ..()

/datum/memory/dna_infusion/get_names()
	return list(
		"[protagonist_name] infusing with a [deuteragonist_name].",
		"[protagonist_name] infusing a [deuteragonist_name] into themselves.",
	)

/datum/memory/dna_infusion/get_starts()
	return list(
		"[protagonist_name] enters a creepy DNA machine",
		"[protagonist_name]'s partakes in some mad science",
		"the DNA infuser closes with [protagonist_name] inside",
		"a [deuteragonist_name] is in the infusion slot"
	)

/datum/memory/dna_infusion/get_moods()
	return list(
		"[protagonist_name] [mood_verb] as they infuse with a [deuteragonist_name]!",
		"[protagonist_name] [mood_verb] as they become one the [deuteragonist_name].",
		"[protagonist_name] [mood_verb] as their DNA has [deuteragonist_name] folded into it.",
		"[protagonist_name] becomes more [mutantlike] as they infuse with a [deuteragonist_name]!",
		"[protagonist_name] becomes more [mutantlike] as they become one the [deuteragonist_name].",
		"[protagonist_name] becomes more [mutantlike] as their DNA has [deuteragonist_name] folded into it.",
	)

/datum/memory/dna_infusion/get_happy_moods()
	return list(
		"endures the pain for science",
		"confidently winces through the pain"
	)

/datum/memory/dna_infusion/get_neutral_moods()
	return list(
		"screams with pain",
		"begins to have second thoughts"
	)

/datum/memory/dna_infusion/get_sad_moods()
	return list("bitterly rejects their humanity")

/// Who rev'd me, so if a mindreader reads a rev, they have a clue on who to hunt down
/datum/memory/recruited_by_headrev

/datum/memory/recruited_by_headrev/get_names()
	return list("[protagonist_name] is converted into a revolutionary by [antagonist_name]")

/datum/memory/recruited_by_headrev/get_starts()
	return list(
		"[protagonist_name]'s mind sets itself on a singular, violent purpose as they're flashed by [antagonist_name]: Kill the heads.",
		"[antagonist_name] lifts an odd device to [protagonist_name]'s eyes and flashes him, imprinting murderous instructions.",
	)

/// Who converted into a blood brother
/datum/memory/recruited_by_blood_brother

/datum/memory/recruited_by_blood_brother/get_names()
	return list("[protagonist_name] is converted into a blood brother by [antagonist_name]")

/datum/memory/recruited_by_blood_brother/get_starts()
	return list(
		"[antagonist_name] acts just a bit too friendly with [protagonist_name], moments away from converting them into a blood brother.",
		"[protagonist_name] is brought into [antagonist_name]'s life of crime and espionage.",
	)

/// Saw someone play Russian Roulette.
/datum/memory/witnessed_gods_wrath
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_SKIP_UNCONSCIOUS
	story_value = STORY_VALUE_AMAZING

/datum/memory/witnessed_gods_wrath/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
)

/datum/memory/witnessed_gods_wrath/get_names()
	return list("[protagonist_name] suffering the wrath of [antagonist_name].")

/datum/memory/witnessed_gods_wrath/get_starts()
	return list(
		"[protagonist_name] burns [deuteragonist_name], and [antagonist_name] turns [protagonist_name] into a fine red mist.",
		"[antagonist_name] explodes [protagonist_name] into a million pieces for defiling [deuteragonist_name].",
		"[protagonist_name] angers [antagonist_name] by defiling [deuteragonist_name], and gets obliterated.",
	)

/datum/memory/witnessed_gods_wrath/get_moods()
	return list("[protagonist_name] [mood_verb] as they get annihilated by [antagonist_name].")

/datum/memory/witnessed_gods_wrath/get_happy_moods()
	return list(
		"cackles hysterically",
		"laughs maniacally",
		"grins widely",
	)

/datum/memory/witnessed_gods_wrath/get_neutral_moods()
	return list(
		"appears concerned",
		"reconsiders their life decisions",
		"has a blank expression",
	)

/datum/memory/witnessed_gods_wrath/get_sad_moods()
	return list(
		"appears dejected",
		"is filled with regret",
		"winces in despair"
	)
