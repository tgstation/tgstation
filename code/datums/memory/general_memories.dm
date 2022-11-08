/// A doctor successfuly completed a surgery on someone.
/datum/memory/surgery
	story_value = STORY_VALUE_OKAY
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
	var/bomb_type

/datum/memory/bomb_planted/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	obj/bomb_type,
)
	src.bomb_type = build_story_character(bomb_type)
	return ..()

/datum/memory/bomb_planted/get_names()
	return list("The arming of [bomb_type] by [protagonist_name].")

/datum/memory/bomb_planted/get_starts()
	return list(
		"[protagonist_name] pressing an ominous button, causing [bomb_type] to begin beeping",
		"[protagonist_name] slapping down a [bomb_type]",
		"[bomb_type] being armed by [protagonist_name]",
	)

/datum/memory/bomb_planted/get_moods()
	return list(
		"[protagonist_name] [mood_verb] and begins to walk away from [bomb_type].",
		"[protagonist_name] [mood_verb] as [bomb_type] begins to tick.",
		"[protagonist_name] [mood_verb] with [bomb_type] winding down.",
		"beep... beep... [protagonist_name] [mood_verb]."
	)

/datum/memory/bomb_planted/get_happy_moods()
	return list("feels too cool to look at [bomb_type]")

/// Planted a SYNDICATE bomb.
/datum/memory/bomb_planted/syndicate
	story_value = STORY_VALUE_AMAZING

/// Got a sweet high five.
/datum/memory/high_five
	var/high_five_type

/datum/memory/high_five/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	high_five_type,
)
	src.high_five_type = high_five_type
	story_value = high_five_type == "high ten" ? STORY_VALUE_OKAY : STORY_VALUE_MEH
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

/datum/memory/was_slipped/get_names()
	return list("The slipping of [protagonist_name].")

/datum/memory/was_slipped/get_starts()
	return list(
		"[protagonist_name] not being able to keep standing when faced with a [antagonist_name]",
		"[protagonist_name] tumbling right over a [antagonist_name]",
		"the perilous [antagonist_name] which took [protagonist_name] down a notch",
	)

/datum/memory/was_slipped/get_moods()
	return list(
		"[protagonist_name] [mood_verb] as they crawl up from the ground.",
		"[protagonist_name] [mood_verb] while on the ground.",
	)

/datum/memory/was_slipped/get_sad_moods()
	return list("doesn't even want to get up and looks depressed")

/// Had spaghetti fall from their pockets.
/datum/memory/lost_spaghetti
	story_value = STORY_VALUE_AMAZING // This doesn't happen very often
	memory_flags = MEMORY_CHECK_BLINDNESS

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
	var/medal_type
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

/datum/memory/held_at_gunpoint/get_names()
	return list("[protagonist_name] being held at gunpoint.")

/datum/memory/held_at_gunpoint/get_starts()
	return list(
		"[protagonist_name] with a [antagonist_name] pressed to their skull by [deuteragonist_name]",
		"[deuteragonist_name] whipping out a [antagonist_name] and pointing it at [protagonist_name]",
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

/datum/memory/witness_vendor_crush/get_names()
	return list("[protagonist_name] being crushed by a [antagonist_name].")

/datum/memory/witness_vendor_crush/get_starts()
	return list(
		"[protagonist_name] being crushed by the a [antagonist_name]",
		"the [antagonist_name] that crashed on top of [protagonist_name]",
		"the fall of a [antagonist_name] onto [protagonist_name]",
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
	var/game
	var/protagonist_held_card
	var/dealer
	var/formatted_players_list

/datum/memory/playing_cards/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	game,
	mob/living/dealer,
	list/mob/living/other_players,
	obj/item/protagonist_held_card,
)
	src.game = game
	src.protagonist_held_card = protagonist_held_card.name
	src.dealer = dealer.name
	src.formatted_players_list = english_list(other_players, nothing_text = "no-one")
	return ..()

/datum/memory/playing_cards/get_names()
	return list("The [game] of [protagonist_name] with [formatted_players_list].")

/datum/memory/playing_cards/get_starts()
	return list(
		"[formatted_players_list] are waiting for [protagonist_name] to start the [game]",
		"The [game] has been setup by [dealer]",
		"[dealer] starts shuffling the deck for the [game]",
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

/datum/memory/playing_card_pickup/get_names()
	return list("[protagonist_name] tricking [deuteragonist_name] into playing 52 pickup with [antagonist_name].")

/datum/memory/playing_card_pickup/get_starts()
	return list(
		"[protagonist_name] tosses the [antagonist_name] at [deuteragonist_name] spilling cards all over the floor",
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
	var/aimed_at
	var/rounds_loaded
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
/datum/memory/heretic_knowlege_ritual

/datum/memory/heretic_knowlege_ritual/get_names()
	return list("[protagonist_name] absorbing boundless knowledge through eldritch research.")

/datum/memory/heretic_knowlege_ritual/get_starts()
	return list(
		"[protagonist_name] laying out a circle of green tar and candles",
		"multiple books around [protagonist_name] flipping open",
		"green and purple energy surrounding [protagonist_name]",
		"[protagonist_name], eyes wide open and unblinking, reading a strange book",
		"a pile of gore and viscera on a complex looking rune",
		"a wide, strange looking circle, with [protagonist_name] sketching it"
	)

/datum/memory/heretic_knowlege_ritual/get_moods()
	return list("[protagonist_name] [mood_verb] as their hand glows with power.")

/datum/memory/heretic_knowlege_ritual/get_happy_moods()
	return list("cackling madly")

/datum/memory/heretic_knowlege_ritual/get_neutral_moods()
	return list("staring blankly with a wide grin")

/datum/memory/heretic_knowlege_ritual/get_sad_moods()
	return list("cackling insanely")
