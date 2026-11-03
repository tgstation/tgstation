// Ratwood's alcohol (code/modules/reagents/chemistry/reagents/alcohol_reagents.dm, rt_alcohol_reagents.dm; the emberwine of
// code/datums/sexcon/sexcon_reagents.dm as a plain drink) as TG ethanol under Ratwood's paths, so the porter fills Ratwood's
// bottles, kegs and cups with them (rockhill/config.json, list_reagents) and the keg brews them (survival/brewing.dm).
// Drunkenness, its effects, the liver and the mood of a good drink are TG's (/datum/reagent/consumable/ethanol, the inebriated
// status effect, quality); what is Ratwood's is each brew's data, its pace and its own effects. Ratwood spends a brew half a
// unit a tick of two seconds and makes one drunker by sqrt(volume) x boozepwr x ALCOHOL_RATE a tick however fast it is spent;
// TG's gain grows with the share spent, so a Ratwood brew scales TG's gain to TG's own pace (on_mob_life() below). Six of the
// brews are TG's own reagents (ale, beer, gin, mead, rum, wine): on medieval maps they take Ratwood's data, on modern maps
// they stay TG's. Names TG or Ratwood already use got another (TG wants every reagent name once): small beer, festive green
// beer, Kazengun shochu, Kazengun umeshu, spider honey mead. Ratwood's glass names and its liver-free drinking are not
// ported: TG names its glasses by style and TG's liver takes its share. What drinks quench is in survival/thirst.dm.

/// Ratwood's brews are spent half a unit a Ratwood tick (Ratwood ethanol 0.5 x REAGENTS_METABOLISM).
#define ROGUE_BREW_RATE ROGUE_REAGENT_RATE(0.5)
/// How fast TG spends its own ethanol: TG's drunkenness grows with the share of a drink spent, as at this pace.
#define ROGUE_TG_ETHANOL_RATE (/datum/reagent/consumable/ethanol::metabolization_rate)
/// Drunkenness from which a Ratwood brew leaves one Drunk, and how long that lingers once sober (Ratwood handle_alcohol()).
#define ROGUE_DRUNK_BUFF_THRESHOLD rogue_value("drunk_buff_threshold")
#define ROGUE_DRUNK_BUFF_TIME rogue_value("drunk_buff_time")
/// The nap of the very drunk on medieval maps, in place of TG's blackout (Ratwood: drunkenness over 91).
#define ROGUE_DRUNK_NAP_CHANCE rogue_value("drunk_nap_chance")
#define ROGUE_DRUNK_NAP_TIME rogue_value("drunk_nap_time")

/datum/reagent/consumable/ethanol
	/// A Ratwood brew: spent at Ratwood's pace, it makes one as drunk as Ratwood does and leaves one Drunk.
	var/rogue_brew = FALSE

/// Ratwood has no addiction to drink (only its alcoholic flaw, not ported): a Ratwood brew takes none of TG's.
/datum/reagent/consumable/ethanol/New(list/data)
	. = ..()
	if(rogue_brew)
		addiction_types = null

/// Ratwood's drunkenness on TG's machinery: TG's gain (with its dilution by water, tolerance traits and cap) is scaled from the
/// share this brew spends to the share TG's own ethanol would, so a tick makes one as drunk as a Ratwood tick does. From
/// drunk_buff_threshold on the drinker is Drunk (Ratwood's buff of that name). A later block's drunken healing and hearty
/// drinking hook here, after ..(), on rogue_brew and boozepwr.
/datum/reagent/consumable/ethanol/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, metabolization_ratio)
	if(!rogue_brew)
		return ..()
	var/drunk_before = drinker.get_drunk_amount()
	. = ..()
	var/drunk_change = drinker.get_drunk_amount() - drunk_before
	if(drunk_change && metabolization_rate > 0)
		drinker.adjust_drunk_effect(drunk_change * (ROGUE_TG_ETHANOL_RATE / metabolization_rate - 1))
	if(drinker.get_drunk_amount() >= ROGUE_DRUNK_BUFF_THRESHOLD)
		drinker.apply_status_effect(/datum/status_effect/rogue_intoxicant/drunk)

/// Ratwood's drunkard naps where TG's blacks out (TG hands the body to a ghost): on medieval maps, over 91, one tick in five
/// "Just a quick nap..." and a sleep.
/datum/status_effect/inebriated/drunk/attempt_to_blackout()
	if(!rogue_survival_enabled())
		return ..()
	if(!prob(ROGUE_DRUNK_NAP_CHANCE))
		return
	to_chat(owner, span_warning("Just a quick nap..."))
	owner.Sleeping(ROGUE_DRUNK_NAP_TIME)

/// On a medieval map makes this one of TG's brews Ratwood's: its look, taste and strength, Ratwood's pace and drunkenness.
/// TG makes one of each reagent at start (GLOB.chemical_reagents_list); one made before the map is known stays TG's.
/datum/reagent/consumable/ethanol/proc/rogue_medieval_brew(new_description, new_color, new_taste, new_boozepwr, new_quality = 0, new_nutriment = 0)
	if(!SSmapping?.current_map || !rogue_survival_enabled())
		return
	description = new_description
	color = new_color
	taste_description = new_taste
	boozepwr = new_boozepwr
	quality = new_quality
	nutriment_factor = new_nutriment
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

// TG's brews that are Ratwood's too, by their exact type (TG's subtypes keep their own data).

/datum/reagent/consumable/ethanol/beer/New(list/data)
	if(type == /datum/reagent/consumable/ethanol/beer)
		rogue_medieval_brew("", "#a17c10", "ale", 25, new_nutriment = 0.1 * ROGUE_REAGENT_NUTRITION)
	return ..()

/datum/reagent/consumable/ethanol/rum/New(list/data)
	if(type == /datum/reagent/consumable/ethanol/rum)
		rogue_medieval_brew("Where has the rum gone?", "#5f3b23", "sweetness with hint of caramel and vanilla", 40)
	return ..()

/datum/reagent/consumable/ethanol/wine/New(list/data)
	if(type == /datum/reagent/consumable/ethanol/wine)
		rogue_medieval_brew(/datum/reagent/consumable/ethanol::description, "#8a0b0b", "wine", 30, DRINK_NICE)
	return ..()

/datum/reagent/consumable/ethanol/ale/New(list/data)
	if(type == /datum/reagent/consumable/ethanol/ale)
		rogue_medieval_brew("A dark alcoholic beverage made with malted barley and yeast.", "#664300", "hearty barley ale", 25)
	return ..()

/datum/reagent/consumable/ethanol/gin/New(list/data)
	if(type == /datum/reagent/consumable/ethanol/gin)
		rogue_medieval_brew(/datum/reagent/consumable/ethanol::description, "#809978", "strong, piney flavor", 65, DRINK_NICE)
	return ..()

/datum/reagent/consumable/ethanol/mead/New(list/data)
	if(type == /datum/reagent/consumable/ethanol/mead)
		rogue_medieval_brew("A warriors drink, though a cheap one.", "#664300", "sweet, sweet alcohol", 30, DRINK_NICE, 1 * ROGUE_REAGENT_NUTRITION)
	return ..()

// Ratwood's own brews. A brew without its own description has Ratwood's (and TG's) "A well-known alcohol with a variety of
// applications."

/datum/reagent/consumable/ethanol/cider
	name = "Apple Cider"
	color = "#6aa945"
	taste_description = "crisp freshness of apple"
	boozepwr = 40
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/// Ratwood's colour lacks its #.
/datum/reagent/consumable/ethanol/cider/pear
	name = "Pear Cider"
	color = "#fffc6c"
	taste_description = "sweet subtle delights of pear"

/datum/reagent/consumable/ethanol/cider/strawberry
	name = "Strawberry Cider"
	color = "#da4d4d"
	taste_description = "strawberry cider"

/// Distilled twice from cider, then brandy: for medicine more than for drinking.
/datum/reagent/consumable/ethanol/aqua_vitae
	name = "Aqua Vitae"
	color = "#6e6e6e"
	taste_description = "death"
	boozepwr = 150
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/brandy
	name = "Apple Brandy"
	color = "#6aa945"
	taste_description = "caramel oak brandy"
	boozepwr = 60
	quality = DRINK_VERYGOOD
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/// Ratwood's colour lacks its #.
/datum/reagent/consumable/ethanol/brandy/pear
	name = "Pear Brandy"
	color = "#b9b607"
	taste_description = "ripe pear with a hint of spice"

/datum/reagent/consumable/ethanol/brandy/strawberry
	name = "Strawberry Brandy"
	color = "#bb1a1a"
	taste_description = "overwhelming sweetness with a smooth finish"

/datum/reagent/consumable/ethanol/brandy/tangerine
	name = "Tangerine Brandy"
	color = "#bb751a"
	taste_description = "spice and a twist of citrus"

/datum/reagent/consumable/ethanol/brandy/plum
	name = "Plum Brandy"
	color = "#5c0449"
	taste_description = "purple sweetness and vanila"

/// Ratwood's "Light Beer" (TG has a light beer of its own).
/datum/reagent/consumable/ethanol/light
	name = "Small Beer"
	description = "An alcoholic beverage brewed since ancient times on Old Earth. This variety has reduced calorie and alcohol content."
	taste_description = "dish water"
	boozepwr = 5
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/// Ratwood's "Green Beer" (TG has a green beer of its own): it tints the drinker while it lasts.
/datum/reagent/consumable/ethanol/green
	name = "Festive Green Beer"
	description = "An alcoholic beverage brewed since ancient times on Old Earth. This variety is dyed a festive green."
	color = "#A8E61D"
	taste_description = "green piss water"
	boozepwr = 25
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/green/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(drinker.color != color)
		drinker.add_atom_colour(color, TEMPORARY_COLOUR_PRIORITY)

/datum/reagent/consumable/ethanol/green/on_mob_end_metabolize(mob/living/drinker)
	. = ..()
	drinker.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, color)

// Beers of the humen: underwhelming, but cheap.

/datum/reagent/consumable/ethanol/zagul
	name = "Zagul Brew"
	color = "#DBD77F"
	taste_description = "cheap pisswater"
	boozepwr = 15
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/spottedhen
	name = "Spotted Hen"
	color = "#DBD77F"
	taste_description = "cheap pisswater"
	boozepwr = 15
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/hagwoodbitter
	name = "Hagwood Bitter"
	color = "#BBB525"
	taste_description = "dull crispness"
	boozepwr = 25
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/blackgoat
	name = "Black Gote Kriek"
	color = "#401806"
	taste_description = "overwhelming sourness"
	boozepwr = 25
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/onion
	name = "Onion Cognac"
	color = "#683e00"
	taste_description = "spicy sweet malty overtones"
	boozepwr = 10
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

// Brews of the elves.

/datum/reagent/consumable/ethanol/aurorian
	name = "Aurorian"
	color = "#5D8A8A"
	taste_description = "subtle herbacious undertones"
	boozepwr = 5
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/// Brewed from cabbage.
/datum/reagent/consumable/ethanol/fireleaf
	name = "Fireleaf"
	color = "#475e45"
	taste_description = "awful liquor"
	boozepwr = 2
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

// Brews of the dwarves: best in the realms.

/datum/reagent/consumable/ethanol/butterhairs
	name = "Butterhairs"
	color = "#D4A020"
	taste_description = "buttery richness"
	boozepwr = 40
	quality = DRINK_GOOD
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/stonebeards
	name = "Stonebeard Reserve"
	color = "#5D8A8A"
	taste_description = "potent oatlike liquor"
	boozepwr = 60
	quality = DRINK_GOOD
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/voddena
	name = "Voddena"
	color = "#a1a1a1"
	taste_description = "clean liquor"
	boozepwr = 40
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/sazdistal
	name = "Saz Distal"
	color = "#2D1D1D"
	taste_description = "spicy chilis, ginger, and dirt"
	boozepwr = 55
	quality = DRINK_GOOD
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/limoncello
	name = "Limoncello"
	color = "#d2da63"
	taste_description = "burning and lemony"
	boozepwr = 45
	quality = DRINK_GOOD
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

// Rice.

/datum/reagent/consumable/ethanol/ricewine
	name = "Rice Wine"
	color = "#F5E6C4"
	taste_description = "floral sweetness with a subtle umami taste."
	boozepwr = 30
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/ricespirit
	name = "Rice Spirit"
	color = "#F8FDFC"
	taste_description = "clean heat and dry finish."
	boozepwr = 55
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

// Wines of the humen, fancy. A fruit wine ages in the keg: plain, aged after ten minutes, delectable after twenty.

/// Peasant grade.
/datum/reagent/consumable/ethanol/sourwine
	name = "Sour Wine"
	color = "#552b4b"
	taste_description = "sour wine"
	boozepwr = 20
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/whitewine
	name = "White Wine"
	color = "#F3ED91"
	taste_description = "sweet white wine"
	boozepwr = 30
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/redwine
	name = "Red Wine"
	color = "#571111"
	taste_description = "tannin-stricken wine"
	boozepwr = 30
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/jackberrywine
	name = "Jackberry Wine"
	color = "#3b2342"
	taste_description = "sickly sweet young wine"
	boozepwr = 15
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/jackberrywine/aged
	name = "Aged Jackberry Wine"
	color = "#402249"
	taste_description = "sweet aged wine"
	boozepwr = 30
	quality = DRINK_GOOD

/datum/reagent/consumable/ethanol/jackberrywine/delectable
	name = "Delectable Jackberry Wine"
	color = "#652679"
	taste_description = "sweet delectably aged wine"
	boozepwr = 30
	quality = DRINK_VERYGOOD

/datum/reagent/consumable/ethanol/plum_wine
	name = "Umeshu"
	color = "#c997d8"
	taste_description = "sickly sour young wine"
	boozepwr = 15
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/plum_wine/aged
	name = "Aged Umeshu"
	color = "#c27cd8"
	taste_description = "sweet slightly sour aged wine"
	boozepwr = 30
	quality = DRINK_GOOD

/datum/reagent/consumable/ethanol/plum_wine/delectable
	name = "Delectable Umeshu"
	color = "#a854c2"
	taste_description = "delectably aged sour sweet wine"
	boozepwr = 30
	quality = DRINK_VERYGOOD

/datum/reagent/consumable/ethanol/tangerine
	name = "Tangerine Wine"
	color = "#e7aa59"
	taste_description = "bittersweet, citrusy young wine"
	boozepwr = 15
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/tangerine/aged
	name = "Aged Tangerine Wine"
	color = "#d68d2d"
	taste_description = "bittersweet, citrusy aged wine"
	boozepwr = 30
	quality = DRINK_GOOD

/datum/reagent/consumable/ethanol/tangerine/delectable
	name = "Delectable Tangerine Wine"
	color = "#eb9321"
	taste_description = "bittersweet, citrusy delectably aged wine"
	boozepwr = 30
	quality = DRINK_VERYGOOD

/datum/reagent/consumable/ethanol/raspberry
	name = "Raspberry Wine"
	color = "#ee5ea6"
	taste_description = "tart sweet young wine"
	boozepwr = 15
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/raspberry/aged
	name = "Aged Raspberry Wine"
	color = "#d83788"
	taste_description = "tart sweet aged wine"
	boozepwr = 30
	quality = DRINK_GOOD

/datum/reagent/consumable/ethanol/raspberry/delectable
	name = "Delectable Raspberry Wine"
	color = "#db0d74"
	taste_description = "tart sweet delectably aged wine"
	boozepwr = 30
	quality = DRINK_VERYGOOD

/datum/reagent/consumable/ethanol/blackberry
	name = "Blackberry Wine"
	color = "#861491"
	taste_description = "bitter tart young wine"
	boozepwr = 15
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/blackberry/aged
	name = "Aged Blackberry Wine"
	color = "#58065f"
	taste_description = "bitter tart aged wine"
	boozepwr = 30
	quality = DRINK_GOOD

/datum/reagent/consumable/ethanol/blackberry/delectable
	name = "Delectable Blackberry Wine"
	color = "#330038"
	taste_description = "bitter tart delectably aged wine"
	boozepwr = 30
	quality = DRINK_VERYGOOD

// Wines of the elves: berries and herbs.

/datum/reagent/consumable/ethanol/elfred
	name = "Elven Red"
	color = "#6C0000"
	taste_description = "delectable fruity notes"
	boozepwr = 15
	quality = DRINK_GOOD
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/elfblue
	name = "Valmora Blue"
	color = "#2C9DAF"
	taste_description = "saintly sweetness"
	boozepwr = 50
	quality = DRINK_FANTASTIC
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

// Drinks of the Azure lands.

/datum/reagent/consumable/ethanol/jagdtrunk
	name = "Jagdtrunk"
	color = "#331f18"
	taste_description = "spicy herbal remedy"
	boozepwr = 55
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/apfelweinheim
	name = "Appelheimer"
	color = "#e0cb55"
	taste_description = "tart crispness and mellow sweetness"
	boozepwr = 45
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/rtoper
	name = "Rockhill Toper"
	color = "#e0a400"
	taste_description = "overwhelming tartness"
	boozepwr = 40
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/nred
	name = "Norwardine Red"
	color = "#543633"
	taste_description = "heavy caramel note and slight bitterness"
	boozepwr = 30
	quality = DRINK_GOOD
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/gronnmead
	name = "Ragnar's Brew"
	color = "#772C48"
	taste_description = "notes of honey and red berries"
	boozepwr = 35
	quality = DRINK_GOOD
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

// Drinks of Avar.

/datum/reagent/consumable/ethanol/avarmead
	name = "Zögiin bal"
	color = "#e0a400"
	taste_description = "spicy honey"
	boozepwr = 30
	quality = DRINK_GOOD
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/avarrice
	name = "Makkolir"
	color = "#ddcbc9"
	taste_description = "tangy sweetness"
	boozepwr = 30
	quality = DRINK_GOOD
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/// Brewed from the milk of a saiga and salt.
/datum/reagent/consumable/ethanol/saigamilk
	name = "Bökhiin Arkhi"
	color = "#dddddd"
	taste_description = "bubbly, sour salt"
	boozepwr = 15
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

// Drinks of Kazengun.

/datum/reagent/consumable/ethanol/kgunlager
	name = "Yamaguchi Pale"
	color = "#d7dbbc"
	taste_description = "mellow bitterness and a hint of green tea"
	boozepwr = 10
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/kgunsake
	name = "Junmai-ginjo"
	color = "#ccd7e0"
	taste_description = "dry sweetness"
	boozepwr = 50
	quality = DRINK_VERYGOOD
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/// Ratwood's "Shochu" (TG has a shochu of its own).
/datum/reagent/consumable/ethanol/kgunshochu
	name = "Kazengun Shochu"
	color = "#F8FDFC"
	taste_description = "dry, clean finish"
	boozepwr = 60
	quality = DRINK_VERYGOOD
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/// Ratwood's second "Umeshu" (the first is its plum wine).
/datum/reagent/consumable/ethanol/kgunplum
	name = "Kazengun Umeshu"
	color = "#ddb99b"
	taste_description = "a mix of sweet and sour"
	boozepwr = 30
	quality = DRINK_GOOD
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

// Drinks of Zhong.

/datum/reagent/consumable/ethanol/huangjiu
	name = "Huangjiu"
	color = "#d8b84c"
	taste_description = "a mix of sweet and sour"
	boozepwr = 30
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/baijiu
	name = "Baijiu"
	color = "#f8fdfc"
	taste_description = "fiery and pungent alcohol with a hint of sweetness"
	boozepwr = 60
	quality = DRINK_GOOD
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/yaojiu
	name = "Yaojiu"
	color = "#8C4B1F"
	taste_description = "bittersweet alcohol with deep herbal notes"
	boozepwr = 50
	quality = DRINK_VERYGOOD
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/shejiu
	name = "Shejiu"
	color = "#C49A6C"
	taste_description = "musky and strong alcohol with a hint of gameiness"
	boozepwr = 50
	quality = DRINK_VERYGOOD
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/// Ratwood's spider honey mead is TG's mead under Ratwood's data, with no name of its own; it is named after its recipe, and
/// TG's synthesis and random spawns of mead are not its.
/datum/reagent/consumable/ethanol/mead/spider
	name = "Spider Honey Mead"
	description = "A warriors drink, though a cheap one."
	color = "#660061"
	nutriment_factor = 1 * ROGUE_REAGENT_NUTRITION
	boozepwr = 30
	quality = DRINK_NICE
	taste_description = "sweet, sweet alcohol"
	chemical_flags = NONE
	randomized_spawns = REAGENT_SPAWN_NO_RANDOM
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

// Special brews.

/// Murkwater and pure ethanol: it sharpens the mind (Ratwood's Murk-Knowledge) and tires the body a little.
/datum/reagent/consumable/ethanol/murkwine
	name = "Mürkwine"
	color = "#4b1e00"
	taste_description = "hints of questionable choices--a bouqet of murkwater and pure ethanol"
	boozepwr = 50
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE
	/// Fatigue (TG stamina damage) per Ratwood tick.
	var/rogue_fatigue = 0.1

/datum/reagent/consumable/ethanol/murkwine/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, metabolization_ratio)
	. = ..()
	drinker.apply_status_effect(/datum/status_effect/rogue_intoxicant/murkwine)
	if(drinker.adjust_stamina_loss(rogue_fatigue * seconds_per_tick / ROGUE_REAGENT_TICK, updating_stamina = FALSE))
		. = UPDATE_MOB_HEALTH

/datum/reagent/consumable/ethanol/murkwine/on_mob_end_metabolize(mob/living/drinker)
	. = ..()
	drinker.remove_status_effect(/datum/status_effect/rogue_intoxicant/murkwine)

/// Moonshine: it strengthens the body (Ratwood's Noc-Shine Strength) and poisons it, the blessed of Baotha less.
/datum/reagent/consumable/ethanol/nocshine
	name = "Noc's Shine"
	color = "#d8fbfd63"
	taste_description = "what might be my throat melting and nose hair burning"
	boozepwr = 70
	quality = DRINK_NICE
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE
	/// Toxins per Ratwood tick, and for Baotha's blessed (TRAIT_CRACKHEAD).
	var/rogue_toxin = 0.75
	var/rogue_blessed_toxin = 0.1

/datum/reagent/consumable/ethanol/nocshine/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, metabolization_ratio)
	. = ..()
	drinker.apply_status_effect(/datum/status_effect/rogue_intoxicant/nocshine)
	var/toxin = HAS_TRAIT(drinker, TRAIT_CRACKHEAD) ? rogue_blessed_toxin : rogue_toxin
	if(drinker.adjust_tox_loss(toxin * seconds_per_tick / ROGUE_REAGENT_TICK, updating_health = FALSE))
		. = UPDATE_MOB_HEALTH

/datum/reagent/consumable/ethanol/nocshine/on_mob_end_metabolize(mob/living/drinker)
	. = ..()
	drinker.remove_status_effect(/datum/status_effect/rogue_intoxicant/nocshine)

/// Fermented lux: a grim, very strong wine that mends the flesh as a weak health potion does.
/datum/reagent/consumable/ethanol/luxwine
	name = "Luxintenebre"
	description = "A fermented form of vitae, highly alcoholic, and with a particularly grim taste. Often sought out by the daring, foolhardy, and heretical..."
	color = "#86cca3"
	taste_description = "a green numbness, then a burning vigor in the heart"
	boozepwr = 80
	quality = DRINK_VERYGOOD
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE
	/// Brute and burns healed per Ratwood tick.
	var/rogue_heal = 1 * ROGUE_REAGENT_EFFECT

/datum/reagent/consumable/ethanol/luxwine/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(volume < ROGUE_POTION_MIN_VOLUME)
		return
	var/ticks = seconds_per_tick / ROGUE_REAGENT_TICK
	if(drinker.adjust_brute_loss(-rogue_heal * ticks, updating_health = FALSE))
		. = UPDATE_MOB_HEALTH
	if(drinker.adjust_fire_loss(-rogue_heal * ticks, updating_health = FALSE))
		. = UPDATE_MOB_HEALTH

/datum/reagent/consumable/ethanol/whipwine
	name = "Magickal Whip Wine"
	description = "A recipe recently floated into these lands. Magickal Whip Wine is said to increase one's potence and stamina sevenfold."
	color = "#3a1d18"
	taste_description = "leather, bitter herbs, and regret"
	boozepwr = 10
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/datum/reagent/consumable/ethanol/komuchisake
	name = "Divine Snake Wine"
	description = "The True Form of the Whipwine. The Magickal Snake Wine was an exclusively produced medicinal wine from over three centures ago in the Kazengun Shogunate..."
	color = "#553837"
	taste_description = "bitterness, pain, iron, and ancient mistakes"
	boozepwr = 60
	metabolization_rate = ROGUE_BREW_RATE
	rogue_brew = TRUE

/// Ratwood's aphrodisiac wine, the cauldron's Aphrodisiac Wine, as a plain drink: it lies dormant for some forty seconds, then a
/// warm glow spreads, the body grows hot and clumsy (Ratwood's Aphrodesiac) and heavy armour chafes. It is spent very slowly;
/// too much of it shakes and stuns one and is then spent faster, but Baotha's followers take any amount. Ratwood's ties to its
/// adult content (arousal, its emotes, the opt-out, the addiction) are not ported. TG's synthesis and random spawns of beer
/// are not its.
/datum/reagent/consumable/ethanol/beer/emberwine
	name = "Emberwine"
	description = ""
	color = "#721a46"
	nutriment_factor = 0.1 * ROGUE_REAGENT_NUTRITION
	boozepwr = 20
	taste_description = "searing sweetness"
	taste_mult = 0.5
	quality = DRINK_VERYGOOD
	overdose_threshold = 18
	chemical_flags = NONE
	randomized_spawns = REAGENT_SPAWN_NO_RANDOM
	/// Dormant, it is not spent (Ratwood skips its parent then); it wakes at rogue_wake_cycle and works from rogue_heat_cycle.
	metabolization_rate = 0
	rogue_brew = TRUE
	var/rogue_wake_cycle = 20
	var/rogue_heat_cycle = 26
	/// Units spent a second once awake (Ratwood 0.02 x REAGENTS_METABOLISM a tick), and while overdosed (Ratwood 0.2).
	var/rogue_awake_rate = ROGUE_REAGENT_RATE(0.02)
	var/rogue_overdose_rate = ROGUE_REAGENT_RATE(0.2)
	/// Percent chance a Ratwood tick of a hot flush, when heavy and medium armour chafe: how long it holds one and blurs the eyes.
	var/rogue_flush_chance = 8
	var/rogue_heavy_chafe = 3 SECONDS
	var/rogue_heavy_chafe_blur = 10 SECONDS
	var/rogue_medium_chafe = 1.5 SECONDS
	var/rogue_medium_chafe_blur = 4 SECONDS
	/// The start of an overdose: jitters and a stun; then each Ratwood tick the chance of another stun with blurred eyes.
	var/rogue_overdose_jitter = 40 SECONDS
	var/rogue_overdose_stun = 1.5 SECONDS
	var/rogue_overdose_stun_chance = 5
	var/rogue_overdose_blur = 10 SECONDS
	var/static/list/rogue_flush_messages = list(
		"Your stomach feels hot.",
		"Your skin feels prickly to the touch.",
		"Your heart beats irregularly.",
		"You feel cold sweat running down your neck.",
	)

/datum/reagent/consumable/ethanol/beer/emberwine/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/drinker = affected_mob
		if(istype(drinker.rogue_patron, /datum/patron/inhumen/baotha))
			overdose_threshold = 0

/datum/reagent/consumable/ethanol/beer/emberwine/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(current_cycle < rogue_wake_cycle)
		return
	if(!metabolization_rate)
		metabolization_rate = overdosed ? rogue_overdose_rate : rogue_awake_rate
		to_chat(drinker, span_purple("You feel a warm glow spreading through your stomach."))
		return
	if(current_cycle < rogue_heat_cycle)
		return
	drinker.apply_status_effect(/datum/status_effect/rogue_intoxicant/emberwine)
	if(!prob(rogue_flush_chance * seconds_per_tick / ROGUE_REAGENT_TICK))
		return
	to_chat(drinker, span_purple(pick(rogue_flush_messages)))
	if(!ishuman(drinker))
		return
	var/mob/living/carbon/human/armoured = drinker
	switch(armoured.rogue_highest_armor_class())
		if(ARMOR_CLASS_HEAVY)
			armoured.Immobilize(rogue_heavy_chafe)
			armoured.set_eye_blur_if_lower(rogue_heavy_chafe_blur)
			to_chat(armoured, span_warning("Your armor chaffs uncomfortably against your skin and makes it difficult to breathe."))
		if(ARMOR_CLASS_MEDIUM)
			armoured.Immobilize(rogue_medium_chafe)
			armoured.set_eye_blur_if_lower(rogue_medium_chafe_blur)
			to_chat(armoured, span_warning("Your armor chaffs uncomfortably against your skin."))

/datum/reagent/consumable/ethanol/beer/emberwine/overdose_start(mob/living/affected_mob, metabolization_ratio)
	. = ..()
	if(current_cycle < rogue_wake_cycle)
		current_cycle = rogue_wake_cycle
		to_chat(affected_mob, span_purple("You feel a warm glow spreading through your stomach."))
	to_chat(affected_mob, span_purple("The glow in your stomach spreads, rushing to your head and warming your face."))
	metabolization_rate = rogue_overdose_rate
	affected_mob.set_jitter_if_lower(rogue_overdose_jitter)
	affected_mob.Stun(rogue_overdose_stun)

/datum/reagent/consumable/ethanol/beer/emberwine/overdose_process(mob/living/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(prob(rogue_overdose_stun_chance * seconds_per_tick / ROGUE_REAGENT_TICK))
		affected_mob.Stun(rogue_overdose_stun)
		affected_mob.set_eye_blur_if_lower(rogue_overdose_blur)

// The buffs of drinks and drugs (Ratwood's /datum/status_effect/buff and debuff): stats, mood, traits and the delay between
// clicks while they last; renewed while what gives them is in the blood.

/// A Ratwood buff of a drink or a drug: its stats (Ratwood effectedstats), its mood (Ratwood's stress event; cleared at the
/// end when Ratwood removes it), its traits and its delay between clicks (Ratwood nextmove_modifier()).
/datum/status_effect/rogue_intoxicant
	id = STATUS_EFFECT_ID_ABSTRACT
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/rogue_intoxicant
	var/list/stats
	var/datum/mood_event/mood
	var/clear_mood = FALSE
	var/list/traits
	var/click_delay = 1
	/// The alert's name, description and icon state (Ratwood's alert of the buff).
	var/alert_name = "High"
	var/alert_desc = ""
	var/alert_state = "acid"

/datum/status_effect/rogue_intoxicant/on_creation(mob/living/new_owner, ...)
	. = ..()
	if(linked_alert)
		linked_alert.name = alert_name
		linked_alert.desc = alert_desc
		linked_alert.icon_state = alert_state

/datum/status_effect/rogue_intoxicant/on_apply()
	if(length(stats))
		owner.attributes?.set_variable_attribute_modifier(id, stats.Copy())
	if(mood)
		owner.add_mood_event(id, mood)
	if(length(traits))
		owner.add_traits(traits, TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/rogue_intoxicant/on_remove()
	owner.attributes?.remove_attribute_modifier(id)
	REMOVE_TRAITS_IN(owner, TRAIT_STATUS_EFFECT(id))
	if(clear_mood)
		owner.clear_mood_event(id)
	return ..()

/datum/status_effect/rogue_intoxicant/nextmove_modifier()
	return click_delay

/atom/movable/screen/alert/status_effect/rogue_intoxicant
	name = "High"
	desc = ""
	icon = ROGUE_COMBAT_ALERTS_ICON
	icon_state = "acid"

/// Ratwood's Drunk: from drunk_buff_threshold on, and drunk_buff_time after one sobers below it. TG's own drunk alert and mood
/// stand for Ratwood's alert and "Alcohol eases the pain."
/datum/status_effect/rogue_intoxicant/drunk
	id = "rogue_drunk"
	duration = 5 MINUTES
	tick_interval = 2 SECONDS
	alert_type = null
	stats = list(ROGUE_STAT_INTELLIGENCE = -2, ROGUE_STAT_WILLPOWER = 1)

/datum/status_effect/rogue_intoxicant/drunk/on_creation(mob/living/new_owner, ...)
	duration = ROGUE_DRUNK_BUFF_TIME
	return ..()

/datum/status_effect/rogue_intoxicant/drunk/refresh(effect, ...)
	duration = max(duration, ROGUE_DRUNK_BUFF_TIME)

/datum/status_effect/rogue_intoxicant/drunk/tick(seconds_between_ticks)
	if(owner.get_drunk_amount() >= ROGUE_DRUNK_BUFF_THRESHOLD)
		refresh()

/datum/status_effect/rogue_intoxicant/murkwine
	id = "rogue_murkwine"
	duration = 2 MINUTES
	stats = list(ROGUE_STAT_INTELLIGENCE = 5)
	alert_name = "Murk-Knowledge"
	alert_state = "drunk"

/datum/status_effect/rogue_intoxicant/nocshine
	id = "rogue_nocshine"
	duration = 2 MINUTES
	stats = list(ROGUE_STAT_STRENGTH = 1, ROGUE_STAT_WILLPOWER = 1)
	alert_name = "Noc-Shine Strength"
	alert_state = "drunk"

/// Ratwood's debuff of emberwine.
/datum/status_effect/rogue_intoxicant/emberwine
	id = "rogue_emberwine"
	duration = 1 MINUTES
	stats = list(ROGUE_STAT_STRENGTH = -1, ROGUE_STAT_WILLPOWER = -2, ROGUE_STAT_SPEED = -2, ROGUE_STAT_INTELLIGENCE = -3)
	alert_name = "Aphrodesiac"
	alert_desc = "The warmth is spreading through my body..."
	alert_state = "debuff"

#undef ROGUE_BREW_RATE
#undef ROGUE_TG_ETHANOL_RATE
#undef ROGUE_DRUNK_BUFF_THRESHOLD
#undef ROGUE_DRUNK_BUFF_TIME
#undef ROGUE_DRUNK_NAP_CHANCE
#undef ROGUE_DRUNK_NAP_TIME
