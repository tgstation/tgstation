/// Drink recipe base
/datum/chemical_reaction/drink
	optimal_temp = 250
	temp_exponent_factor = 1
	optimal_ph_min = 2
	optimal_ph_max = 10
	thermic_constant = 0
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

// Cocktails

/datum/chemical_reaction/drink/goldschlager
	results = list(/datum/reagent/consumable/ethanol/goldschlager = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = GOLDSCHLAGER_VODKA, /datum/reagent/gold = GOLDSCHLAGER_GOLD)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/drink/patron
	results = list(/datum/reagent/consumable/ethanol/patron = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 10, /datum/reagent/silver = 1)

/datum/chemical_reaction/drink/bilk
	results = list(/datum/reagent/consumable/ethanol/bilk = 2)
	required_reagents = list(/datum/reagent/consumable/milk = 1, /datum/reagent/consumable/ethanol/beer = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_BRUTE

/datum/chemical_reaction/drink/moonshine
	results = list(/datum/reagent/consumable/ethanol/moonshine = 10)
	required_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/sugar = 5)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/drink/spacebeer
	results = list(/datum/reagent/consumable/ethanol/beer = 10)
	required_reagents = list(/datum/reagent/consumable/flour = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/drink/vodka
	results = list(/datum/reagent/consumable/ethanol/vodka = 10)
	required_reagents = list(/datum/reagent/consumable/potato_juice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/kahlua
	results = list(/datum/reagent/consumable/ethanol/kahlua = 5)
	required_reagents = list(/datum/reagent/consumable/coffee = 5, /datum/reagent/consumable/sugar = 5)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/gin_tonic
	results = list(/datum/reagent/consumable/ethanol/gintonic = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 2, /datum/reagent/consumable/tonic = 1)

/datum/chemical_reaction/drink/rum_coke
	results = list(/datum/reagent/consumable/ethanol/rum_coke = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/space_cola = 1)

/datum/chemical_reaction/drink/cuba_libre
	results = list(/datum/reagent/consumable/ethanol/cuba_libre = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum_coke = 3, /datum/reagent/consumable/limejuice = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/martini
	results = list(/datum/reagent/consumable/ethanol/martini = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 2, /datum/reagent/consumable/ethanol/vermouth = 1)

/datum/chemical_reaction/drink/vodkamartini
	results = list(/datum/reagent/consumable/ethanol/vodkamartini = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, /datum/reagent/consumable/ethanol/vermouth = 1)

/datum/chemical_reaction/drink/white_russian
	results = list(/datum/reagent/consumable/ethanol/white_russian = 8)
	required_reagents = list(/datum/reagent/consumable/ethanol/black_russian = 5, /datum/reagent/consumable/cream = 3)

/datum/chemical_reaction/drink/whiskey_cola
	results = list(/datum/reagent/consumable/ethanol/whiskey_cola = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/consumable/space_cola = 1)

/datum/chemical_reaction/drink/screwdriver
	results = list(/datum/reagent/consumable/ethanol/screwdrivercocktail = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, /datum/reagent/consumable/orangejuice = 1)

/datum/chemical_reaction/drink/bloody_mary
	results = list(/datum/reagent/consumable/ethanol/bloody_mary = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/tomatojuice = 2, /datum/reagent/consumable/limejuice = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/gargle_blaster
	results = list(/datum/reagent/consumable/ethanol/gargle_blaster = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/ethanol/gin = 1, /datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/ethanol/cognac = 1, /datum/reagent/consumable/lemonjuice = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/brave_bull
	results = list(/datum/reagent/consumable/ethanol/brave_bull = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 2, /datum/reagent/consumable/ethanol/kahlua = 1)

/datum/chemical_reaction/drink/tequila_sunrise
	results = list(/datum/reagent/consumable/ethanol/tequila_sunrise = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 2, /datum/reagent/consumable/orangejuice = 2, /datum/reagent/consumable/grenadine = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/toxins_special
	results = list(/datum/reagent/consumable/ethanol/toxins_special = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/ethanol/vermouth = 1, /datum/reagent/toxin/plasma = 2)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/beepsky_smash
	results = list(/datum/reagent/consumable/ethanol/beepsky_smash = 5)
	required_reagents = list(/datum/reagent/consumable/limejuice = 2, /datum/reagent/consumable/ethanol/quadruple_sec = 2, /datum/reagent/iron = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/irish_cream
	results = list(/datum/reagent/consumable/ethanol/irish_cream = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/drink/manly_dorf
	results = list(/datum/reagent/consumable/ethanol/manly_dorf = 3)
	required_reagents = list (/datum/reagent/consumable/ethanol/beer = 1, /datum/reagent/consumable/ethanol/ale = 2)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/greenbeer
	results = list(/datum/reagent/consumable/ethanol/beer/green = 10)
	required_reagents = list(/datum/reagent/colorful_reagent/powder/green = 1, /datum/reagent/consumable/ethanol/beer = 10)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/greenbeer2 //apparently there's no other way to do this
	results = list(/datum/reagent/consumable/ethanol/beer/green = 10)
	required_reagents = list(/datum/reagent/colorful_reagent/powder/green/crayon = 1, /datum/reagent/consumable/ethanol/beer = 10)

/datum/chemical_reaction/drink/hooch
	results = list(/datum/reagent/consumable/ethanol/hooch = 3)
	required_reagents = list (/datum/reagent/consumable/ethanol = 2, /datum/reagent/fuel = 1)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 1)

/datum/chemical_reaction/drink/irish_coffee
	results = list(/datum/reagent/consumable/ethanol/irishcoffee = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/irish_cream = 1, /datum/reagent/consumable/coffee = 1)

/datum/chemical_reaction/drink/b52
	results = list(/datum/reagent/consumable/ethanol/b52 = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/irish_cream = 1, /datum/reagent/consumable/ethanol/kahlua = 1, /datum/reagent/consumable/ethanol/cognac = 1)

/datum/chemical_reaction/drink/atomicbomb
	results = list(/datum/reagent/consumable/ethanol/atomicbomb = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/b52 = 10, /datum/reagent/uranium = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/margarita
	results = list(/datum/reagent/consumable/ethanol/margarita = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 2, /datum/reagent/consumable/limejuice = 1, /datum/reagent/consumable/ethanol/triple_sec = 1)

/datum/chemical_reaction/drink/longislandicedtea
	results = list(/datum/reagent/consumable/ethanol/longislandicedtea = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/ethanol/gin = 1, /datum/reagent/consumable/ethanol/tequila = 1, /datum/reagent/consumable/ethanol/cuba_libre = 1)

/datum/chemical_reaction/drink/threemileisland
	results = list(/datum/reagent/consumable/ethanol/threemileisland = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/longislandicedtea = 10, /datum/reagent/uranium = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/whiskeysoda
	results = list(/datum/reagent/consumable/ethanol/whiskeysoda = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/consumable/sodawater = 1)

/datum/chemical_reaction/drink/wellcheers
	results = list(/datum/reagent/consumable/wellcheers = 5)
	required_reagents = list(/datum/reagent/consumable/berryjuice = 1, /datum/reagent/consumable/watermelonjuice = 1, /datum/reagent/consumable/sodawater = 1, /datum/reagent/consumable/salt = 1, /datum/reagent/consumable/ethanol/absinthe = 1)

/datum/chemical_reaction/drink/black_russian
	results = list(/datum/reagent/consumable/ethanol/black_russian = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 3, /datum/reagent/consumable/ethanol/kahlua = 2)

/datum/chemical_reaction/drink/hiveminderaser
	results = list(/datum/reagent/consumable/ethanol/hiveminderaser = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/black_russian = 2, /datum/reagent/consumable/ethanol/thirteenloko = 1, /datum/reagent/consumable/grenadine = 1)

/datum/chemical_reaction/drink/manhattan
	results = list(/datum/reagent/consumable/ethanol/manhattan = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/consumable/ethanol/vermouth = 1)

/datum/chemical_reaction/drink/manhattan_proj
	results = list(/datum/reagent/consumable/ethanol/manhattan_proj = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/manhattan = 10, /datum/reagent/uranium = 1)

/datum/chemical_reaction/drink/vodka_tonic
	results = list(/datum/reagent/consumable/ethanol/vodkatonic = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, /datum/reagent/consumable/tonic = 1)

/datum/chemical_reaction/drink/gin_fizz
	results = list(/datum/reagent/consumable/ethanol/ginfizz = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 2, /datum/reagent/consumable/sodawater = 1, /datum/reagent/consumable/limejuice = 1)

/datum/chemical_reaction/drink/bahama_mama
	results = list(/datum/reagent/consumable/ethanol/bahama_mama = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/creme_de_coconut = 1, /datum/reagent/consumable/ethanol/kahlua = 1, /datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/pineapplejuice = 1)

/datum/chemical_reaction/drink/singulo
	results = list(/datum/reagent/consumable/ethanol/singulo = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 5, /datum/reagent/liquid_dark_matter = 1, /datum/reagent/consumable/ethanol/wine = 5)

/datum/chemical_reaction/drink/alliescocktail
	results = list(/datum/reagent/consumable/ethanol/alliescocktail = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/martini = 1, /datum/reagent/consumable/ethanol/vodka = 1)

/datum/chemical_reaction/drink/demonsblood
	results = list(/datum/reagent/consumable/ethanol/demonsblood = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/spacemountainwind = 1, /datum/reagent/blood = 1, /datum/reagent/consumable/dr_gibb = 1)

/datum/chemical_reaction/drink/booger
	results = list(/datum/reagent/consumable/ethanol/booger = 4)
	required_reagents = list(/datum/reagent/consumable/cream = 1, /datum/reagent/consumable/banana = 1, /datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/watermelonjuice = 1)

/datum/chemical_reaction/drink/antifreeze
	results = list(/datum/reagent/consumable/ethanol/antifreeze = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, /datum/reagent/consumable/cream = 1, /datum/reagent/consumable/ice = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/barefoot
	results = list(/datum/reagent/consumable/ethanol/barefoot = 3)
	required_reagents = list(/datum/reagent/consumable/berryjuice = 1, /datum/reagent/consumable/cream = 1, /datum/reagent/consumable/ethanol/vermouth = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/moscow_mule
	results = list(/datum/reagent/consumable/ethanol/moscow_mule = 10)
	required_reagents = list(/datum/reagent/consumable/sol_dry = 5, /datum/reagent/consumable/ethanol/vodka = 5, /datum/reagent/consumable/limejuice = 1, /datum/reagent/consumable/ice = 1)
	mix_sound = 'sound/effects/bubbles/bubbles2.ogg'

/datum/chemical_reaction/drink/painkiller
	results = list(/datum/reagent/consumable/ethanol/painkiller = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/creme_de_coconut = 5, /datum/reagent/consumable/pineapplejuice = 4, /datum/reagent/consumable/orangejuice = 1)

/datum/chemical_reaction/drink/pina_colada
	results = list(/datum/reagent/consumable/ethanol/pina_colada = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/creme_de_coconut = 1, /datum/reagent/consumable/pineapplejuice = 3, /datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/limejuice = 1)

/datum/chemical_reaction/drink/pina_olivada
	results = list(/datum/reagent/consumable/ethanol/pina_olivada = 5)
	required_reagents = list(/datum/reagent/consumable/pineapplejuice = 3, /datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/nutriment/fat/oil/olive = 1)

/datum/chemical_reaction/drink/sbiten
	results = list(/datum/reagent/consumable/ethanol/sbiten = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 10, /datum/reagent/consumable/capsaicin = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/red_mead
	results = list(/datum/reagent/consumable/ethanol/red_mead = 2)
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/consumable/ethanol/mead = 1)

/datum/chemical_reaction/drink/mead
	results = list(/datum/reagent/consumable/ethanol/mead = 2)
	required_reagents = list(/datum/reagent/consumable/honey = 2)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/drink/iced_beer
	results = list(/datum/reagent/consumable/ethanol/iced_beer = 6)
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 5, /datum/reagent/consumable/ice = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/grog
	results = list(/datum/reagent/consumable/ethanol/grog = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/water = 1)

/datum/chemical_reaction/drink/acidspit
	results = list(/datum/reagent/consumable/ethanol/acid_spit = 6)
	required_reagents = list(/datum/reagent/toxin/acid = 1, /datum/reagent/consumable/ethanol/wine = 5)
	optimal_ph_min = 0 //Our reaction is very acidic, so lets shift our range

/datum/chemical_reaction/drink/amasec
	results = list(/datum/reagent/consumable/ethanol/amasec = 10)
	required_reagents = list(/datum/reagent/iron = 1, /datum/reagent/consumable/ethanol/wine = 5, /datum/reagent/consumable/ethanol/vodka = 5)

/datum/chemical_reaction/drink/changelingsting
	results = list(/datum/reagent/consumable/ethanol/changelingsting = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/screwdrivercocktail = 1, /datum/reagent/consumable/lemon_lime = 2)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/aloe
	results = list(/datum/reagent/consumable/ethanol/aloe = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/irish_cream = 1, /datum/reagent/consumable/watermelonjuice = 1)

/datum/chemical_reaction/drink/andalusia
	results = list(/datum/reagent/consumable/ethanol/andalusia = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/lemonjuice = 1)

/datum/chemical_reaction/drink/neurotoxin
	results = list(/datum/reagent/consumable/ethanol/neurotoxin = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/gargle_blaster = 1, /datum/reagent/medicine/morphine = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/snowwhite
	results = list(/datum/reagent/consumable/ethanol/snowwhite = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 1, /datum/reagent/consumable/lemon_lime = 1)

/datum/chemical_reaction/drink/irishcarbomb
	results = list(/datum/reagent/consumable/ethanol/irishcarbomb = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/ale = 1, /datum/reagent/consumable/ethanol/irish_cream = 1)

/datum/chemical_reaction/drink/syndicatebomb
	results = list(/datum/reagent/consumable/ethanol/syndicatebomb = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 1, /datum/reagent/consumable/ethanol/whiskey_cola = 1)

/datum/chemical_reaction/drink/erikasurprise
	results = list(/datum/reagent/consumable/ethanol/erikasurprise = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/ale = 1, /datum/reagent/consumable/limejuice = 1, /datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/banana = 1, /datum/reagent/consumable/ice = 1)

/datum/chemical_reaction/drink/devilskiss
	results = list(/datum/reagent/consumable/ethanol/devilskiss = 3)
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/consumable/ethanol/kahlua = 1, /datum/reagent/consumable/ethanol/rum = 1)

/datum/chemical_reaction/drink/hippiesdelight
	results = list(/datum/reagent/consumable/ethanol/hippies_delight = 2)
	required_reagents = list(/datum/reagent/drug/mushroomhallucinogen = 1, /datum/reagent/consumable/ethanol/gargle_blaster = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/bananahonk
	results = list(/datum/reagent/consumable/ethanol/bananahonk = 2)
	required_reagents = list(/datum/reagent/consumable/laughter = 1, /datum/reagent/consumable/cream = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/silencer
	results = list(/datum/reagent/consumable/ethanol/silencer = 3)
	required_reagents = list(/datum/reagent/consumable/nothing = 1, /datum/reagent/consumable/cream = 1, /datum/reagent/consumable/sugar = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/driestmartini
	results = list(/datum/reagent/consumable/ethanol/driestmartini = 2)
	required_reagents = list(/datum/reagent/consumable/nothing = 1, /datum/reagent/consumable/ethanol/gin = 1)

/datum/chemical_reaction/drink/thirteenloko
	results = list(/datum/reagent/consumable/ethanol/thirteenloko = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/coffee = 1, /datum/reagent/consumable/limejuice = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/drunkenblumpkin
	results = list(/datum/reagent/consumable/ethanol/drunkenblumpkin = 4)
	required_reagents = list(/datum/reagent/consumable/blumpkinjuice = 1, /datum/reagent/consumable/ethanol/irish_cream = 2, /datum/reagent/consumable/ice = 1)

/datum/chemical_reaction/drink/grappa
	results = list(/datum/reagent/consumable/ethanol/grappa = 10)
	required_reagents = list (/datum/reagent/consumable/ethanol/wine = 10)
	required_catalysts = list (/datum/reagent/consumable/enzyme = 10)

/datum/chemical_reaction/drink/whiskey_sour
	results = list(/datum/reagent/consumable/ethanol/whiskey_sour = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/lemonjuice = 1, /datum/reagent/consumable/sugar = 1)
	mix_message = "The mixture darkens to a rich gold hue."

/datum/chemical_reaction/drink/fetching_fizz
	results = list(/datum/reagent/consumable/ethanol/fetching_fizz = 3)
	required_reagents = list(/datum/reagent/consumable/nuka_cola = 1, /datum/reagent/iron = 1) //Manufacturable from only the mining station
	mix_message = "The mixture slightly vibrates before settling."

/datum/chemical_reaction/drink/hearty_punch
	results = list(/datum/reagent/consumable/ethanol/hearty_punch = 1)  //Very little, for balance reasons
	required_reagents = list(/datum/reagent/consumable/ethanol/brave_bull = 5, /datum/reagent/consumable/ethanol/syndicatebomb = 5, /datum/reagent/consumable/ethanol/absinthe = 5)
	mix_message = "The mixture darkens to a healthy crimson."
	required_temp = 315 //Piping hot!
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_BRUTE | REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY

/datum/chemical_reaction/drink/bacchus_blessing
	results = list(/datum/reagent/consumable/ethanol/bacchus_blessing = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/hooch = 1, /datum/reagent/consumable/ethanol/absinthe = 1, /datum/reagent/consumable/ethanol/manly_dorf = 1, /datum/reagent/consumable/ethanol/syndicatebomb = 1)
	mix_message = span_warning("The mixture turns to a sickening froth.")

/datum/chemical_reaction/drink/eggnog
	results = list(/datum/reagent/consumable/ethanol/eggnog = 15)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 5, /datum/reagent/consumable/cream = 5, /datum/reagent/consumable/eggyolk = 2)

/datum/chemical_reaction/drink/narsour
	results = list(/datum/reagent/consumable/ethanol/narsour = 1)
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/consumable/lemonjuice = 1, /datum/reagent/consumable/ethanol/demonsblood = 1)
	mix_message = "The mixture develops a sinister glow."
	mix_sound = 'sound/effects/singlebeat.ogg'
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/quadruplesec
	results = list(/datum/reagent/consumable/ethanol/quadruple_sec = 15)
	required_reagents = list(/datum/reagent/consumable/ethanol/triple_sec = 5, /datum/reagent/consumable/triple_citrus = 5, /datum/reagent/consumable/grenadine = 5)
	mix_message = "The snap of a taser emanates clearly from the mixture as it settles."
	mix_sound = 'sound/items/weapons/taser.ogg'
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/grasshopper
	results = list(/datum/reagent/consumable/ethanol/grasshopper = 15)
	required_reagents = list(/datum/reagent/consumable/cream = 5, /datum/reagent/consumable/ethanol/creme_de_menthe = 5, /datum/reagent/consumable/ethanol/creme_de_cacao = 5)
	mix_message = "A vibrant green bubbles forth as the mixture emulsifies."

/datum/chemical_reaction/drink/stinger
	results = list(/datum/reagent/consumable/ethanol/stinger = 15)
	required_reagents = list(/datum/reagent/consumable/ethanol/cognac = 10, /datum/reagent/consumable/ethanol/creme_de_menthe = 5 )

/datum/chemical_reaction/drink/quintuplesec
	results = list(/datum/reagent/consumable/ethanol/quintuple_sec = 15)
	required_reagents = list(/datum/reagent/consumable/ethanol/quadruple_sec = 5, /datum/reagent/consumable/nutriment/soup/clown_tears = 5, /datum/reagent/consumable/ethanol/syndicatebomb = 5)
	mix_message = "Judgement is upon you."
	mix_sound = 'sound/items/airhorn/airhorn2.ogg'
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/bastion_bourbon
	results = list(/datum/reagent/consumable/ethanol/bastion_bourbon = 2)
	required_reagents = list(/datum/reagent/consumable/tea = 1, /datum/reagent/consumable/ethanol/creme_de_menthe = 1, /datum/reagent/consumable/triple_citrus = 1, /datum/reagent/consumable/berryjuice = 1) //herbal and minty, with a hint of citrus and berry
	mix_message = "You catch an aroma of hot tea and fruits as the mix blends into a blue-green color."
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_BRUTE | REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY

/datum/chemical_reaction/drink/squirt_cider
	results = list(/datum/reagent/consumable/ethanol/squirt_cider = 4)
	required_reagents = list(/datum/reagent/water/salt = 2, /datum/reagent/consumable/tomatojuice = 2, /datum/reagent/consumable/nutriment = 1)
	mix_message = "The mix swirls and turns a bright red that reminds you of an apple's skin."
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/fringe_weaver
	results = list(/datum/reagent/consumable/ethanol/fringe_weaver = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol = 9, /datum/reagent/consumable/sugar = 1) //9 karmotrine, 1 adelhyde
	mix_message = "The mix turns a pleasant cream color and foams up."

/datum/chemical_reaction/drink/sugar_rush
	results = list(/datum/reagent/consumable/ethanol/sugar_rush = 4)
	required_reagents = list(/datum/reagent/consumable/sugar = 2, /datum/reagent/consumable/lemonjuice = 1, /datum/reagent/consumable/ethanol/wine = 1) //2 adelhyde (sweet), 1 powdered delta (sour), 1 karmotrine (alcohol)
	mix_message = "The mixture bubbles and brightens into a girly pink."
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/crevice_spike
	results = list(/datum/reagent/consumable/ethanol/crevice_spike = 6)
	required_reagents = list(/datum/reagent/consumable/limejuice = 2, /datum/reagent/consumable/capsaicin = 4) //2 powdered delta (sour), 4 flanergide (spicy)
	mix_message = "The mixture stings your eyes as it settles."
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/sake
	results = list(/datum/reagent/consumable/ethanol/sake = 10)
	required_reagents = list(/datum/reagent/consumable/rice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	mix_message = "The rice grains ferment into a clear, sweet-smelling liquid."

/datum/chemical_reaction/drink/peppermint_patty
	results = list(/datum/reagent/consumable/ethanol/peppermint_patty = 10)
	required_reagents = list(/datum/reagent/consumable/hot_coco = 6, /datum/reagent/consumable/ethanol/creme_de_cacao = 1, /datum/reagent/consumable/ethanol/creme_de_menthe = 1, /datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/menthol = 1)
	mix_message = "The coco turns mint green just as the strong scent hits your nose."
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/alexander
	results = list(/datum/reagent/consumable/ethanol/alexander = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/cognac = 1, /datum/reagent/consumable/ethanol/creme_de_cacao = 1, /datum/reagent/consumable/cream = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/sidecar
	results = list(/datum/reagent/consumable/ethanol/sidecar = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/cognac = 2, /datum/reagent/consumable/ethanol/triple_sec = 1, /datum/reagent/consumable/lemonjuice = 1)

/datum/chemical_reaction/drink/between_the_sheets
	results = list(/datum/reagent/consumable/ethanol/between_the_sheets = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/ethanol/sidecar = 4)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/kamikaze
	results = list(/datum/reagent/consumable/ethanol/kamikaze = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/ethanol/triple_sec = 1, /datum/reagent/consumable/limejuice = 1)

/datum/chemical_reaction/drink/mojito
	results = list(/datum/reagent/consumable/ethanol/mojito = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/limejuice = 1, /datum/reagent/consumable/sodawater = 1, /datum/reagent/consumable/menthol = 1)

/datum/chemical_reaction/drink/fernet_cola
	results = list(/datum/reagent/consumable/ethanol/fernet_cola = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/fernet = 1, /datum/reagent/consumable/space_cola = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_TOXIN

/datum/chemical_reaction/drink/fanciulli
	results = list(/datum/reagent/consumable/ethanol/fanciulli = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/manhattan = 1, /datum/reagent/consumable/ethanol/fernet = 1)

/datum/chemical_reaction/drink/branca_menta
	results = list(/datum/reagent/consumable/ethanol/branca_menta = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/fernet = 1, /datum/reagent/consumable/ethanol/creme_de_menthe = 1, /datum/reagent/consumable/ice = 1)

/datum/chemical_reaction/drink/blank_paper
	results = list(/datum/reagent/consumable/ethanol/blank_paper = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/silencer = 1, /datum/reagent/consumable/nothing = 1, /datum/reagent/consumable/nuka_cola = 1)

/datum/chemical_reaction/drink/wizz_fizz
	results = list(/datum/reagent/consumable/ethanol/wizz_fizz = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/triple_sec = 1, /datum/reagent/consumable/sodawater = 1, /datum/reagent/consumable/ethanol/champagne = 1)
	mix_message = "The beverage starts to froth with an almost mystical zeal!"
	mix_sound = 'sound/effects/bubbles/bubbles2.ogg'
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/bug_spray
	results = list(/datum/reagent/consumable/ethanol/bug_spray = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/triple_sec = 2, /datum/reagent/consumable/lemon_lime = 1, /datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/ethanol/vodka = 1)
	mix_message = "The faint aroma of summer camping trips wafts through the air; but what's that buzzing noise?"
	mix_sound = 'sound/mobs/non-humanoids/bee/bee.ogg'
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/jack_rose
	results = list(/datum/reagent/consumable/ethanol/jack_rose = 4)
	required_reagents = list(/datum/reagent/consumable/grenadine = 1, /datum/reagent/consumable/ethanol/applejack = 2, /datum/reagent/consumable/limejuice = 1)
	mix_message = "As the grenadine incorporates, the beverage takes on a mellow, red-orange glow."

/datum/chemical_reaction/drink/turbo
	results = list(/datum/reagent/consumable/ethanol/turbo = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/moonshine = 2, /datum/reagent/nitrous_oxide = 1, /datum/reagent/consumable/ethanol/sugar_rush = 1, /datum/reagent/consumable/pwr_game = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/old_timer
	results = list(/datum/reagent/consumable/ethanol/old_timer = 6)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskeysoda = 3, /datum/reagent/consumable/parsnipjuice = 2, /datum/reagent/consumable/ethanol/alexander = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/rubberneck
	results = list(/datum/reagent/consumable/ethanol/rubberneck = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol = 4, /datum/reagent/consumable/grey_bull = 5, /datum/reagent/consumable/astrotame = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/duplex
	results = list(/datum/reagent/consumable/ethanol/duplex = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/hcider = 2, /datum/reagent/consumable/applejuice = 1, /datum/reagent/consumable/berryjuice = 1)

/datum/chemical_reaction/drink/trappist
	results = list(/datum/reagent/consumable/ethanol/trappist = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/ale = 2, /datum/reagent/water/holywater = 2, /datum/reagent/consumable/sugar = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/blazaam
	results = list(/datum/reagent/consumable/ethanol/blazaam = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 2, /datum/reagent/consumable/peachjuice = 1, /datum/reagent/bluespace = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/planet_cracker
	results = list(/datum/reagent/consumable/ethanol/planet_cracker = 20)
	required_reagents = list(/datum/reagent/consumable/ethanol/champagne = 10, /datum/reagent/consumable/ethanol/lizardwine = 10, /datum/reagent/consumable/eggyolk = 2, /datum/reagent/gold = 5)
	mix_message = "The liquid's color starts shifting as the nanogold is alternately corroded and redeposited."

/datum/chemical_reaction/drink/mauna_loa
	results = list(/datum/reagent/consumable/ethanol/mauna_loa = 5)
	required_reagents = list(/datum/reagent/consumable/capsaicin = 2, /datum/reagent/consumable/ethanol/kahlua = 1, /datum/reagent/consumable/ethanol/bahama_mama = 2)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/godfather
	results = list(/datum/reagent/consumable/ethanol/godfather = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/amaretto = 1, /datum/reagent/consumable/ethanol/whiskey = 1)

/datum/chemical_reaction/drink/godmother
	results = list(/datum/reagent/consumable/ethanol/godmother = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/amaretto = 1, /datum/reagent/consumable/ethanol/vodka = 1)

/datum/chemical_reaction/drink/amaretto_alexander
	results = list(/datum/reagent/consumable/ethanol/amaretto_alexander = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/amaretto = 1, /datum/reagent/consumable/ethanol/creme_de_cacao = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/drink/ginger_amaretto
	results = list(/datum/reagent/consumable/ethanol/ginger_amaretto = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/amaretto = 1, /datum/reagent/consumable/sol_dry = 1, /datum/reagent/consumable/ice = 1, /datum/reagent/consumable/lemonjuice = 1)

/datum/chemical_reaction/drink/the_juice
	results = list(/datum/reagent/consumable/ethanol/the_juice = 5)
	required_reagents = list(/datum/reagent/consumable/mushroom_tea = 1, /datum/reagent/bluespace = 1, /datum/reagent/toxin/mindbreaker = 1, /datum/reagent/consumable/ethanol/neurotoxin = 1, /datum/reagent/medicine/morphine = 1)
	mix_message = "The liquids all swirl together into a deep purple."

/datum/chemical_reaction/drink/helianthus
	results = list(/datum/reagent/consumable/ethanol/helianthus = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/absinthe = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/toxin/mindbreaker = 1)
	mix_message = "The drink lets out a soft enlightening laughter..."

/datum/chemical_reaction/drink/the_hat
	results = list(/datum/reagent/consumable/ethanol/the_hat = 1)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/water = 1, /datum/reagent/consumable/ethanol/plumwine = 1)
	mix_message = "The drink starts to smell perfumy..."

/datum/chemical_reaction/drink/gin_garden
	results = list(/datum/reagent/consumable/ethanol/gin_garden = 15)
	required_reagents = list(/datum/reagent/consumable/limejuice = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/ethanol/gin = 3, /datum/reagent/consumable/cucumberjuice = 3, /datum/reagent/consumable/sol_dry = 5, /datum/reagent/consumable/ice = 2)

/datum/chemical_reaction/drink/telepole
	results = list(/datum/reagent/consumable/ethanol/telepole = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/wine_voltaic = 1, /datum/reagent/consumable/ethanol/dark_and_stormy = 2, /datum/reagent/consumable/ethanol/sake = 1)
	mix_message = "You swear you saw a spark fly from the glass..."

/datum/chemical_reaction/drink/pod_tesla
	results = list(/datum/reagent/consumable/ethanol/pod_tesla = 15)
	required_reagents = list(/datum/reagent/consumable/ethanol/telepole = 5, /datum/reagent/consumable/ethanol/brave_bull = 3, /datum/reagent/consumable/ethanol/admiralty = 5)
	mix_message = "Arcs of lightning fly from the mixture."
	mix_sound = 'sound/items/weapons/zapbang.ogg'

/datum/chemical_reaction/drink/yuyakita
	results = list(/datum/reagent/consumable/ethanol/yuyakita = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 2, /datum/reagent/consumable/limejuice = 1, /datum/reagent/consumable/ethanol/yuyake = 1)

/datum/chemical_reaction/drink/saibasan
	results = list(/datum/reagent/consumable/ethanol/saibasan = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/shochu = 2, /datum/reagent/consumable/ethanol/yuyake = 2, /datum/reagent/consumable/triple_citrus = 3, /datum/reagent/consumable/cherryjelly = 3)

/datum/chemical_reaction/drink/banzai_ti
	results = list(/datum/reagent/consumable/ethanol/banzai_ti = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/yuyake = 1, /datum/reagent/consumable/ethanol/triple_sec = 1, /datum/reagent/consumable/ethanol/gin = 1, /datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/ethanol/tequila = 1, /datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/triple_citrus = 2, /datum/reagent/consumable/sodawater = 2)

/datum/chemical_reaction/drink/sanraizusoda
	results = list(/datum/reagent/consumable/ethanol/sanraizusoda = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/yuyake = 1, /datum/reagent/consumable/sodawater = 2, /datum/reagent/consumable/ice = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/drink/kumicho
	results = list(/datum/reagent/consumable/ethanol/kumicho = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/godfather = 2, /datum/reagent/consumable/ethanol/shochu = 1, /datum/reagent/consumable/ethanol/bitters = 1)

/datum/chemical_reaction/drink/red_planet
	results = list(/datum/reagent/consumable/ethanol/red_planet = 8)
	required_reagents = list(/datum/reagent/consumable/ethanol/shochu = 2, /datum/reagent/consumable/ethanol/triple_sec = 2, /datum/reagent/consumable/ethanol/vermouth = 2, /datum/reagent/consumable/grenadine = 1, /datum/reagent/consumable/ethanol/bitters = 1)

/datum/chemical_reaction/drink/amaterasu
	results = list(/datum/reagent/consumable/ethanol/amaterasu = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/shochu = 1, /datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/grenadine = 1, /datum/reagent/consumable/berryjuice = 2, /datum/reagent/consumable/sodawater = 5)

/datum/chemical_reaction/drink/nekomimosa
	results = list(/datum/reagent/consumable/ethanol/nekomimosa = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/yuyake = 2, /datum/reagent/consumable/watermelonjuice = 2, /datum/reagent/consumable/ethanol/champagne = 1)

/datum/chemical_reaction/drink/sentai_quencha
	results = list(/datum/reagent/consumable/ethanol/sentai_quencha = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/shochu = 1, /datum/reagent/consumable/ethanol/curacao = 1, /datum/reagent/consumable/triple_citrus = 1, /datum/reagent/consumable/melon_soda = 2)

/datum/chemical_reaction/drink/bosozoku
	results = list(/datum/reagent/consumable/ethanol/bosozoku = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/rice_beer = 1, /datum/reagent/consumable/lemonade = 1)

/datum/chemical_reaction/drink/ersatzche
	results = list(/datum/reagent/consumable/ethanol/ersatzche = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/rice_beer = 5, /datum/reagent/consumable/pineapplejuice = 3, /datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/drink/red_city_am
	results = list(/datum/reagent/consumable/ethanol/red_city_am = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/rice_beer = 5, /datum/reagent/consumable/limejuice = 1, /datum/reagent/consumable/red_bay = 1, /datum/reagent/consumable/soysauce = 1, /datum/reagent/consumable/tomatojuice = 2)

/datum/chemical_reaction/drink/kings_ransom
	results = list(/datum/reagent/consumable/ethanol/kings_ransom = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/rice_beer = 5, /datum/reagent/consumable/ethanol/gin = 2, /datum/reagent/consumable/berryjuice = 2, /datum/reagent/consumable/ethanol/bitters = 1)

/datum/chemical_reaction/drink/four_bit
	results = list(/datum/reagent/consumable/ethanol/four_bit = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/hakka_mate = 2, /datum/reagent/consumable/limejuice = 1)

/datum/chemical_reaction/drink/white_hawaiian
	results = list(/datum/reagent/consumable/ethanol/white_hawaiian = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/kahlua = 1, /datum/reagent/consumable/ethanol/coconut_rum = 1, /datum/reagent/consumable/coconut_milk = 2)

/datum/chemical_reaction/drink/maui_sunrise
	results = list(/datum/reagent/consumable/ethanol/maui_sunrise = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/coconut_rum = 2, /datum/reagent/consumable/pineapplejuice = 2, /datum/reagent/consumable/ethanol/yuyake = 1, /datum/reagent/consumable/triple_citrus = 1, /datum/reagent/consumable/lemon_lime = 4)

/datum/chemical_reaction/drink/imperial_mai_tai
	results = list(/datum/reagent/consumable/ethanol/imperial_mai_tai = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/navy_rum = 1, /datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/ethanol/triple_sec = 1, /datum/reagent/consumable/limejuice = 1, /datum/reagent/consumable/korta_nectar = 1)

/datum/chemical_reaction/drink/konococo_rumtini
	results = list(/datum/reagent/consumable/ethanol/konococo_rumtini = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/coconut_rum = 2, /datum/reagent/consumable/ethanol/kahlua = 3, /datum/reagent/consumable/coffee = 3, /datum/reagent/consumable/sugar = 2)

/datum/chemical_reaction/drink/blue_hawaiian
	results = list(/datum/reagent/consumable/ethanol/blue_hawaiian = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/coconut_rum = 2, /datum/reagent/consumable/pineapplejuice = 1, /datum/reagent/consumable/lemonjuice = 1, /datum/reagent/consumable/ethanol/curacao = 1)

/datum/chemical_reaction/drink/boston_sour
	results = list(/datum/reagent/consumable/ethanol/boston_sour = 15)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey_sour = 15, /datum/reagent/consumable/eggwhite = 2, /datum/reagent/consumable/ethanol/bitters = 1)
	mix_message = "A frothy head forms over the mixture."

/datum/chemical_reaction/drink/star
	results = list(/datum/reagent/consumable/ethanol/star = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/applejack = 5, /datum/reagent/consumable/ethanol/vermouth = 5, /datum/reagent/consumable/ethanol/bitters = 1)

/datum/chemical_reaction/drink/old_fashioned
	results = list(/datum/reagent/consumable/ethanol/old_fashioned = 30)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 25, /datum/reagent/consumable/sugar = 5, /datum/reagent/consumable/ethanol/bitters = 2)
	mix_message = "The sugar dissolves into the bitters and whiskey."

/datum/chemical_reaction/drink/sazerac
	results = list(/datum/reagent/consumable/ethanol/sazerac = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/old_fashioned = 10, /datum/reagent/consumable/ethanol/absinthe = 1)
	mix_message = "The mixture takes on a pleasing pink hue."

/datum/chemical_reaction/drink/amaretto_sour
	results = list(/datum/reagent/consumable/ethanol/amaretto_sour = 15)
	required_reagents = list(/datum/reagent/consumable/ethanol/amaretto = 10, /datum/reagent/consumable/lemonjuice = 5, /datum/reagent/consumable/eggwhite = 2)
	mix_message = "A frothy head forms over the mixture."
	
/datum/chemical_reaction/drink/ramos_gin_fizz
	results = list(/datum/reagent/consumable/ethanol/ramos_gin_fizz = 25)
	//yes, this is intentionally a pain in the ass
	required_reagents = list(/datum/reagent/consumable/ethanol/ginfizz = 12, /datum/reagent/consumable/lemonjuice = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/eggwhite = 3, /datum/reagent/consumable/cream = 3, /datum/reagent/consumable/ethanol/triple_sec = 1) 
	mix_message = "The drink forms a rising head of foam that begins to creep out of the top of the glass."

/datum/chemical_reaction/drink/french_75
	results = list(/datum/reagent/consumable/ethanol/french_75 = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/champagne = 5, /datum/reagent/consumable/ethanol/gin = 3, /datum/reagent/consumable/lemonjuice = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/drink/sangria
	results = list(/datum/reagent/consumable/ethanol/sangria = 20)
	required_reagents = list(/datum/reagent/consumable/ethanol/wine = 10, /datum/reagent/consumable/ethanol/cognac = 3, /datum/reagent/consumable/triple_citrus = 3, /datum/reagent/consumable/sodawater = 3, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/drink/suffering_bastard
	results = list(/datum/reagent/consumable/ethanol/suffering_bastard = 20)
	required_reagents = list(/datum/reagent/consumable/sol_dry = 10, /datum/reagent/consumable/ethanol/cognac = 3, /datum/reagent/consumable/ethanol/gin = 3, /datum/reagent/consumable/limejuice = 2, /datum/reagent/consumable/ethanol/bitters = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/drink/hot_toddy
	results = list(/datum/reagent/consumable/ethanol/hot_toddy = 10)
	required_reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/ethanol/cognac = 3, /datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/lemonjuice = 1)
	mix_message = "The scent of warm cognac fills the air."
	required_temp = 320 //Pour 100c water into other ingredients

/datum/chemical_reaction/drink/tizirian_sour
	results = list(/datum/reagent/consumable/ethanol/tizirian_sour = 8)
	required_reagents = list(/datum/reagent/consumable/ethanol/bitters = 3, /datum/reagent/consumable/lemonjuice = 2, /datum/reagent/consumable/korta_nectar = 2, /datum/reagent/consumable/sugar = 1)	

/datum/chemical_reaction/drink/daiquiri
	results = list(/datum/reagent/consumable/ethanol/daiquiri = 6)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 3, /datum/reagent/consumable/limejuice = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/ice = 1)

/datum/chemical_reaction/drink/flip_cocktail
	results=list(/datum/reagent/consumable/ethanol/flip_cocktail = 25)
	required_reagents = list(/datum/reagent/consumable/ethanol/cognac = 15, /datum/reagent/consumable/sugar = 5, /datum/reagent/consumable/eggwhite = 4, /datum/reagent/consumable/eggyolk = 2)
	mix_message = "The egg emulsifies into a smooth mixture."

/datum/chemical_reaction/drink/blue_blazer
	results=list(/datum/reagent/consumable/ethanol/blue_blazer = 9)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 4, /datum/reagent/water = 4, /datum/reagent/consumable/sugar = 1)
	mix_message = "The whiskey ignites in a brilliant blue flame!"
	required_temp = 365 //autoignition temp of ethanol
