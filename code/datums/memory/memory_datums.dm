/// A doctor successfuly completed a surgery on someone.
/datum/memory/surgery
	var/surgery_type

/datum/memory/surgery/New(
	datum/mind/memorizer_mind,
	memorizer,
	atom/protagonist_actual,
	atom/deuteragonist_actual,
	atom/antagonist_actual,
	surgery_type,
)
	src.surgery_type = surgery_type
	return ..()

/datum/memory/surgery/get_names()
	return list("The [surgery_type] of [deuteragonist] by [protagonist].")

/datum/memory/surgery/get_starts()
	return list(
		"[protagonist] carefully performing [surgery_type] on [deuteragonist]",
		"[protagonist] using a bone saw on [deuteragonist]",
		"[deuteragonist] being operated on by [protagonist]",
	)

/datum/memory/surgery/get_moods()
	return list(
		"[protagonist] [mood_verb] after finishing [surgery_type].",
		"[protagonist] [mood_verb] as a blood splatter lands on [protagonist]'s face.",
		"[protagonist] [mood_verb] as the [surgery_type] continues.",
		"[protagonist] [mood_verb] as they pick apart [deuteragonist].",
		"[protagonist] [mood_verb] as they tear into [deuteragonist].",
	)

/// Planted a Syndicate bomb.
/datum/memory/bomb_planted
	var/bomb_type

/datum/memory/bomb_planted/New(
	datum/mind/memorizer_mind,
	memorizer,
	atom/protagonist_actual,
	atom/deuteragonist_actual,
	atom/antagonist_actual,
	bomb_type,
)
	src.bomb_type = bomb_type
	return ..()

/datum/memory/bomb_planted/get_names()
	return list("The arming of [bomb_type] by [protagonist].")

/datum/memory/bomb_planted/get_starts()
	return list(
		"[protagonist] pressing an ominous button, causing [bomb_type] to begin beeping",
		"[protagonist] slapping down a [bomb_type]",
		"[bomb_type] being armed by [protagonist]",
	)

/datum/memory/bomb_planted/get_moods()
	return list(
		"[protagonist] [mood_verb] and begins to walk away from [bomb_type].",
		"[protagonist] [mood_verb] as [bomb_type] begins to tick.",
		"[protagonist] [mood_verb] with [bomb_type] winding down.",
		"beep... beep... [protagonist] [mood_verb]."
	)

/datum/memory/bomb_planted/get_happy_moods()
	return list("feels too cool to look at [bomb_type]")

/// Got a sweet high five.
/datum/memory/high_five
	var/high_five_type

/datum/memory/high_five/New(
	datum/mind/memorizer_mind,
	memorizer,
	atom/protagonist_actual,
	atom/deuteragonist_actual,
	atom/antagonist_actual,
	high_five_type,
)
	src.high_five_type = high_five_type
	return ..()

/datum/memory/high_five/get_names()
	return list("The [high_five_type] between [protagonist] and [deuteragonist].")

/datum/memory/high_five/get_starts()
	return list(
		"[protagonist] and [deuteragonist] having a a legendary [high_five_type]",
		"[protagonist] giving [deuteragonist] a [high_five_type]",
		"[protagonist] and [deuteragonist] giving each other a [high_five_type]",
	)

/datum/memory/high_five/get_moods()
	return list(
		"[protagonist] [mood_verb] as the [high_five_type] connects.",
		"[protagonist] [mood_verb] at all the compatriotism going on.",
		"What a [high_five_type]! [protagonist] [mood_verb].",
		"Wow! [protagonist] [mood_verb]!",
	)

/// Was cyborgized.
/datum/memory/was_cyborged

/datum/memory/was_cyborged/get_names()
	return list("The borging of [protagonist].")

/datum/memory/was_cyborged/get_starts()
	return list(
		"[protagonist] having their brain put into a robot",
		"[protagonist] getting turned into a bucket of bolts",
	)

/// Witnessed someone die nearby.
/datum/memory/witnessed_death

/datum/memory/witnessed_death/get_names()
	return list("The death of [protagonist].")

/datum/memory/witnessed_death/get_starts()
	return list(
		"[protagonist] having perished",
		"[protagonist] seizing up and falling limp, their eyes appearing dead and lifeless",
		"[protagonist]'s heart stopping",
		"the death of [protagonist]",
	)

/// Witnessed someone get creampied nearby.
/datum/memory/witnessed_creampie

/datum/memory/witnessed_creampie/get_names()
	return list("The creaming of [protagonist].")

/datum/memory/witnessed_creampie/get_starts()
	return list(
		"[protagonist]'s face being covered in cream",
		"[protagonist] getting cream-pied",
	)

/datum/memory/witnessed_creampie/get_moods()
	return list(
		"[protagonist] [mood_verb] as the cream drips off their face",
		"[protagonist] [mood_verb] because of their now expanded laundry task.",
		"[protagonist] [mood_verb] as they lick off some of the pie",
	)

/// Got slipped by something.
/datum/memory/was_slipped

/datum/memory/was_slipped/get_names()
	return list("The slipping of [protagonist].")

/datum/memory/was_slipped/get_starts()
	return list(
		"[protagonist] not being able to keep standing when faced with a [antagonist]",
		"[protagonist] tumbling right over a [antagonist]",
		"the perilous [antagonist] which took [protagonist] down a notch",
	)

/datum/memory/was_slipped/get_moods()
	return list(
		"[protagonist] [mood_verb] as they crawl up from the ground.",
		"[protagonist] [mood_verb] while on the ground.",
	)

/datum/memory/was_slipped/get_sad_moods()
	return list("doesn't even want to get up and looks depressed")

/// Had spaghetti fall from their pockets.
/datum/memory/lost_spaghetti

/datum/memory/lost_spaghetti/get_names()
	return list("[protagonist]'s spaghetti blunder.")

/datum/memory/lost_spaghetti/get_starts()
	return list(
		"[protagonist]'s spaghetti pouring out of their pockets",
		"[protagonist]'s pockets not being able to contain their spaghetti",
	)

/datum/memory/lost_spaghetti/get_moods()
	return list(
		"[protagonist] [mood_verb] as the spaghetti poured out.",
		"[protagonist] [mood_verb] as they try to pick up the scraps.",
	)

/// Got kissed! Ahhhhh!
/datum/memory/kissed

/datum/memory/kissed/get_names()
	return list("the kiss blown to [protagonist]")

/datum/memory/kissed/get_starts()
	return list(
		"[protagonist]'s receiving a blown kiss from [deuteragonist]",
		"[deuteragonist] blowing a kiss to [protagonist]",
	)

/datum/memory/kissed/get_moods()
	return list(
		"[protagonist] [mood_verb] as the kiss lands on their cheek.",
		"[protagonist] [mood_verb] as it happen.",
	)

/// Had some good food.
/datum/memory/good_food
	var/food

/datum/memory/good_food/New(
	datum/mind/memorizer_mind,
	memorizer,
	atom/protagonist_actual,
	atom/deuteragonist_actual,
	atom/antagonist_actual,
	obj/item/food,
)
	src.food = food.name
	return ..()

/datum/memory/good_food/get_names()
	return list("A delicious [food] [protagonist] ate")

/datum/memory/good_food/get_starts()
	return list(
		"[food] changing [protagonist]'s outlook on food",
		"[food] is leaving [protagonist] round and full",
		"[food] leaving a long lasting impression on [protagonist]",
		"[protagonist] enjoying an incredibly good [food]",
		"[protagonist] producing a slice of life anime reaction to eating [food]",
	)

/datum/memory/good_food/get_moods()
	return list("[protagonist] [mood_verb] as they take another bite.")

/// Had a good drink.
/datum/memory/good_drink
	var/drink

/datum/memory/good_drink/New(
	datum/mind/memorizer_mind,
	memorizer,
	atom/protagonist_actual,
	atom/deuteragonist_actual,
	atom/antagonist_actual,
	datum/reagent/drink,
)
	src.drink = drink.name
	return ..()

/datum/memory/good_drink/get_names()
	return list("a delicious [drink] [protagonist] consumed")

/datum/memory/good_drink/get_starts()
	return list(
		"[drink] changing [protagonist]'s outlook on classy drinking",
		"[drink] leaving a long lasting impression on [protagonist]",
		"[protagonist] enjoying an incredibly good [drink]",
		"[protagonist] slurping some tasty [drink]",
	)

/datum/memory/good_drink/get_moods()
	return list("[protagonist] [mood_verb] as they take another sip.")

/// Was set on fire and started to burn.
/datum/memory/was_burning

/datum/memory/was_burning/get_names()
	return list("The burning of [protagonist].")

/datum/memory/was_burning/get_starts()
	return list(
		"[protagonist] bursting into flames",
		"[protagonist] turning into a human torch",
		"the fire that engulfed [protagonist]",
	)

/datum/memory/was_burning/get_moods()
	return list("[protagonist] [mood_verb] as their skin melts.")

/// Got a limb removed by force.
/datum/memory/was_dismembered
	var/lost_limb

/datum/memory/was_dismembered/New(
	datum/mind/memorizer_mind,
	memorizer,
	atom/protagonist_actual,
	atom/deuteragonist_actual,
	atom/antagonist_actual,
	obj/item/lost_limb,
)
	src.lost_limb = lost_limb.name
	return ..()

/datum/memory/was_dismembered/get_names()
	return list("The loss of [protagonist]'s [lost_limb].")

/datum/memory/was_dismembered/get_starts()
	return list(
		"[protagonist] becoming eligible for handicapped parking",
		"[protagonist]'s [lost_limb] being shot into the abyss",
		"[protagonist]'s [lost_limb] flinging away",
	)

/datum/memory/was_dismembered/get_moods()
	return list(
		"[protagonist] [mood_verb] after losing [lost_limb].",
		"Without [lost_limb], [protagonist] [mood_verb].",
	)

/// Our pet died...
/datum/memory/pet_died

/datum/memory/pet_died/get_names()
	return list("The death of [deuteragonist].")

/datum/memory/pet_died/get_starts()
	return list(
		"honoring [deuteragonist], the station's pet",
		"[deuteragonist]'s funeral, which is attended by a group of crew members",
		"a shallow hole, with \proper [deuteragonist] inside",
	)

/datum/memory/pet_died/get_moods()
	return list(
		"[protagonist] [mood_verb] without [deuteragonist].",
		"Without [deuteragonist], [protagonist] [mood_verb].",
	)

/// The revolution was triumphant
/datum/memory/revolutionary_victory

/datum/memory/revolutionary_victory/get_names()
	return list("The revolution of [station_name()] by [protagonist].")

/datum/memory/revolutionary_victory/get_starts()
	return list(
		"[protagonist] raising the flag of the revolution over the corpses of the former dictators",
		"a flag waving above a pile of corpses with [protagonist] standing over it",
		"a poster that says [station_name()] with a cross in it, hailing in a new era",
		"a statue of the former captain toppled over, with [protagonist] next to it",
	)

/datum/memory/revolutionary_victory/get_moods()
	return list(
		"[protagonist] [mood_verb] at the fall of [station_name()].",
		"[protagonist] [mood_verb] at the idea of the new era.",
	)

/// Watched someone receive a commendation medal
/datum/memory/received_medal
	var/medal_type
	var/medal_text

/datum/memory/received_medal/New(
	datum/mind/memorizer_mind,
	memorizer,
	atom/protagonist_actual,
	atom/deuteragonist_actual,
	atom/antagonist_actual,
	obj/item/medal,
	medal_text

)
	src.medal_type = medal.name,
	src.medal_text = medal_text
	return ..()

/datum/memory/received_medal/get_names()
	return list("The award ceremony of [medal_type] to [protagonist].")

/datum/memory/received_medal/get_starts()
	return list(
		"[protagonist] accepting a [medal_type] inscribed with \"[medal_text]\" from [deuteragonist]",
		"[protagonist] receiving a [medal_type] with the inscription \"[medal_text]\"",
		"a [medal_type] with the inscription \"[medal_text]\" being awarded to [protagonist] by [deuteragonist]",
	)

/datum/memory/received_medal/get_moods()
	return list(
		"[protagonist] [mood_verb] as they receive their medal.",
		"[protagonist] [mood_verb] with their newly received award.",
	)

/// Killed a Megafauna
/datum/memory/megafauna_slayer

/datum/memory/megafauna_slayer/get_names()
	return list("The slaughter of [antagonist].")

/datum/memory/megafauna_slayer/get_starts()
	return list(
		"[protagonist] performing the final strike on [antagonist], taking it down",
		"[protagonist] standing with the head of [antagonist] in their hand",
		"the killing of [antagonist], the dangerous megafauna, by [protagonist]",
	)

/datum/memory/megafauna_slayer/get_moods()
	return list(
		"[protagonist] [mood_verb] as the blood lust fades from their eyes.",
		"[protagonist] [mood_verb] as they search the corpse for valuables.",
	)

/// Got held at gunpoint by someone!
/datum/memory/held_at_gunpoint

/datum/memory/held_at_gunpoint/get_names()
	return list("[protagonist] being held at gunpoint.")

/datum/memory/held_at_gunpoint/get_starts()
	return list(
		"[protagonist] with a [antagonist] pressed to their skull by [deuteragonist]",
		"[deuteragonist] whipping out a [antagonist] and pointing it at [protagonist]",
	)

/datum/memory/held_at_gunpoint/get_moods()
	return list(
		"[protagonist] [mood_verb] as they are faced with the situation.",
		"[protagonist] [mood_verb] as they stare down [antagonist]'s barrel.",
	)

/// Saw someone get gibbed.
/datum/memory/witness_gib

/datum/memory/witness_gib/get_names()
	return list("[protagonist] exploding into bits.")

/datum/memory/witness_gib/get_starts()
	return list(
		"[protagonist] exploding into little fleshy bits",
		"[protagonist] becoming flesh paste in the blink of an eye",
	)

/// Saw someone get crushed by a vending machine.
/datum/memory/witness_vendor_crush

/datum/memory/witness_vendor_crush/get_names()
	return list("[protagonist] being crushed by a [antagonist].")

/datum/memory/witness_vendor_crush/get_starts()
	return list(
		"[protagonist] being crushed by the a [antagonist]",
		"the [antagonist] that crashed on top of [protagonist]",
		"the fall of a [antagonist] onto [protagonist]",
	)

/datum/memory/witness_vendor_crush/get_moods()
	return list(
		"[protagonist] [mood_verb] as they lie under the machine.",
		"[protagonist] [mood_verb] as a goodie falls out of the [antagonist]."
	)

/// Saw someone get dusted by the supermatter.
/datum/memory/witness_supermatter_dusting

/datum/memory/witness_supermatter_dusting/get_names()
	return list("The dusting of [protagonist] by the [antagonist].")

/datum/memory/witness_supermatter_dusting/get_starts()
	return list(
		"[protagonist] turning into a pile of bones after touching the [antagonist]",
		"The [antagonist] turning [protagonist] into ash",
		"The dusting of [protagonist] after they got too close to the [antagonist]",
	)

/datum/memory/witness_supermatter_dusting/get_moods()
	return list(
		"[protagonist] [mood_verb] as they faded way.",
		"[protagonist] [mood_verb] as they are reduced to atoms.",
	)

/// Played cards with another person.
/datum/memory/playing_cards
	var/game
	var/protagonist_held_card
	var/dealer
	var/formatted_players_list

/datum/memory/playing_cards/New(
	datum/mind/memorizer_mind,
	memorizer,
	atom/protagonist_actual,
	atom/deuteragonist_actual,
	atom/antagonist_actual,
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
	return list("The [game] of [protagonist] with [formatted_players_list].")

/datum/memory/playing_cards/get_starts()
	return list(
		"[formatted_players_list] are waiting for [protagonist] to start the [game]",
		"The [game] has been setup by [dealer]",
		"[dealer] starts shuffling the deck for the [game]",
	)

/datum/memory/playing_cards/get_moods()
	return list(
		"[protagonist] [mood_verb] as they hold the [protagonist_held_card] for the [game].",
		"[protagonist] [mood_verb] as they pickup the [protagonist_held_card].",
		"[protagonist] [mood_verb] as they put down the [protagonist_held_card].",
	)

/// Played 52 card pickup with another person.
/datum/memory/playing_card_pickup

/datum/memory/playing_card_pickup/get_names()
	return list("[protagonist] tricking [deuteragonist] into playing 52 pickup with [antagonist].")

/datum/memory/playing_card_pickup/get_starts()
	return list(
		"[protagonist] tosses the [antagonist] at [deuteragonist] spilling cards all over the floor",
		"A [antagonist] thrown by [protagonist] splatters across [deuteragonist] face",
	)

/datum/memory/playing_card_pickup/get_moods()
	return list(
		"[protagonist] [mood_verb] as they taunt [deuteragonist].",
		"[deuteragonist] [mood_verb] as they shamefully pickup the cards.",
	)

/// Saw someone play Russian Roulette.
/datum/memory/witnessed_russian_roulette
	var/aimed_at
	var/rounds_loaded
	var/result

/datum/memory/witnessed_russian_roulette/New(
	datum/mind/memorizer_mind,
	memorizer,
	atom/protagonist_actual,
	atom/deuteragonist_actual,
	atom/antagonist_actual,
	aimed_at,
	rounds_loaded,
	result,
)
	src.aimed_at = aimed_at
	src.rounds_loaded = rounds_loaded
	src.result = result
	return ..()

/datum/memory/witnessed_russian_roulette/get_names()
	return list("[protagonist] playing a game of russian roulette.")

/datum/memory/witnessed_russian_roulette/get_starts()
	return list(
		"[protagonist] aiming at their [aimed_at] right before they pull the trigger.",
		"The revolver has [rounds_loaded] rounds loaded in the chamber.",
		"[protagonist] is gambling their life as they spin the revolver.",
	)

/datum/memory/witnessed_russian_roulette/get_moods()
	return list("[protagonist] [mood_verb] as they [result] the deadly game of roulette.")
