////////////////////////////////////////// COCKTAILS //////////////////////////////////////


/datum/chemical_reaction/goldschlager
	name = "Goldschlager"
	id = /datum/reagent/consumable/ethanol/goldschlager
	results = list(/datum/reagent/consumable/ethanol/goldschlager = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 10, "gold" = 1)

/datum/chemical_reaction/patron
	name = "Patron"
	id = /datum/reagent/consumable/ethanol/patron
	results = list(/datum/reagent/consumable/ethanol/patron = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 10, "silver" = 1)

/datum/chemical_reaction/bilk
	name = "Bilk"
	id = /datum/reagent/consumable/ethanol/bilk
	results = list(/datum/reagent/consumable/ethanol/bilk = 2)
	required_reagents = list("milk" = 1, /datum/reagent/consumable/ethanol/beer = 1)

/datum/chemical_reaction/icetea
	name = "Iced Tea"
	id = "icetea"
	results = list("icetea" = 4)
	required_reagents = list("ice" = 1, "tea" = 3)

/datum/chemical_reaction/icecoffee
	name = "Iced Coffee"
	id = "icecoffee"
	results = list("icecoffee" = 4)
	required_reagents = list("ice" = 1, "coffee" = 3)

/datum/chemical_reaction/nuka_cola
	name = "Nuka Cola"
	id = "nuka_cola"
	results = list("nuka_cola" = 6)
	required_reagents = list("uranium" = 1, "cola" = 6)

/datum/chemical_reaction/moonshine
	name = "Moonshine"
	id = /datum/reagent/consumable/ethanol/moonshine
	results = list(/datum/reagent/consumable/ethanol/moonshine = 10)
	required_reagents = list("nutriment" = 5, "sugar" = 5)
	required_catalysts = list("enzyme" = 5)

/datum/chemical_reaction/wine
	name = "Wine"
	id = /datum/reagent/consumable/ethanol/wine
	results = list(/datum/reagent/consumable/ethanol/wine = 10)
	required_reagents = list("grapejuice" = 10)
	required_catalysts = list("enzyme" = 5)

/datum/chemical_reaction/spacebeer
	name = "Space Beer"
	id = "spacebeer"
	results = list(/datum/reagent/consumable/ethanol/beer = 10)
	required_reagents = list("flour" = 10)
	required_catalysts = list("enzyme" = 5)

/datum/chemical_reaction/vodka
	name = "Vodka"
	id = /datum/reagent/consumable/ethanol/vodka
	results = list(/datum/reagent/consumable/ethanol/vodka = 10)
	required_reagents = list("potato" = 10)
	required_catalysts = list("enzyme" = 5)

/datum/chemical_reaction/kahlua
	name = "Kahlua"
	id = /datum/reagent/consumable/ethanol/kahlua
	results = list(/datum/reagent/consumable/ethanol/kahlua = 5)
	required_reagents = list("coffee" = 5, "sugar" = 5)
	required_catalysts = list("enzyme" = 5)

/datum/chemical_reaction/gin_tonic
	name = "Gin and Tonic"
	id = /datum/reagent/consumable/ethanol/gintonic
	results = list(/datum/reagent/consumable/ethanol/gintonic = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 2, "tonic" = 1)

/datum/chemical_reaction/rum_coke
	name = "Rum and Coke"
	id = /datum/reagent/consumable/ethanol/rum_coke
	results = list(/datum/reagent/consumable/ethanol/rum_coke = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 2, "cola" = 1)

/datum/chemical_reaction/cuba_libre
	name = "Cuba Libre"
	id = /datum/reagent/consumable/ethanol/cuba_libre
	results = list(/datum/reagent/consumable/ethanol/cuba_libre = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum_coke = 3, "limejuice" = 1)

/datum/chemical_reaction/martini
	name = "Classic Martini"
	id = /datum/reagent/consumable/ethanol/martini
	results = list(/datum/reagent/consumable/ethanol/martini = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 2, /datum/reagent/consumable/ethanol/vermouth = 1)

/datum/chemical_reaction/vodkamartini
	name = "Vodka Martini"
	id = /datum/reagent/consumable/ethanol/vodkamartini
	results = list(/datum/reagent/consumable/ethanol/vodkamartini = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, /datum/reagent/consumable/ethanol/vermouth = 1)

/datum/chemical_reaction/white_russian
	name = "White Russian"
	id = /datum/reagent/consumable/ethanol/white_russian
	results = list(/datum/reagent/consumable/ethanol/white_russian = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/blackrussian = 3, "cream" = 2)

/datum/chemical_reaction/whiskey_cola
	name = "Whiskey Cola"
	id = /datum/reagent/consumable/ethanol/whiskey_cola
	results = list(/datum/reagent/consumable/ethanol/whiskey_cola = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, "cola" = 1)

/datum/chemical_reaction/screwdriver
	name = "Screwdriver"
	id = /datum/reagent/consumable/ethanol/screwdrivercocktail
	results = list(/datum/reagent/consumable/ethanol/screwdrivercocktail = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, "orangejuice" = 1)

/datum/chemical_reaction/bloody_mary
	name = "Bloody Mary"
	id = /datum/reagent/consumable/ethanol/bloody_mary
	results = list(/datum/reagent/consumable/ethanol/bloody_mary = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, "tomatojuice" = 2, "limejuice" = 1)

/datum/chemical_reaction/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = "gargleblaster"
	results = list("gargleblaster" = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/ethanol/gin = 1, /datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/ethanol/cognac = 1, "limejuice" = 1)

/datum/chemical_reaction/brave_bull
	name = "Brave Bull"
	id = /datum/reagent/consumable/ethanol/brave_bull
	results = list(/datum/reagent/consumable/ethanol/brave_bull = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 2, /datum/reagent/consumable/ethanol/kahlua = 1)

/datum/chemical_reaction/tequila_sunrise
	name = "Tequila Sunrise"
	id = /datum/reagent/consumable/ethanol/tequila_sunrise
	results = list(/datum/reagent/consumable/ethanol/tequila_sunrise = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 2, "orangejuice" = 2, "grenadine" = 1)

/datum/chemical_reaction/toxins_special
	name = "Toxins Special"
	id = "toxinsspecial"
	results = list("toxinsspecial" = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/ethanol/vermouth = 1, "plasma" = 2)

/datum/chemical_reaction/beepsky_smash
	name = "Beepksy Smash"
	id = "beepksysmash"
	results = list(/datum/reagent/consumable/ethanol/beepsky_smash = 5)
	required_reagents = list("limejuice" = 2, "quadruple_sec" = 2, /datum/reagent/iron = 1)

/datum/chemical_reaction/doctor_delight
	name = "The Doctor's Delight"
	id = "doctordelight"
	results = list("doctorsdelight" = 5)
	required_reagents = list("limejuice" = 1, "tomatojuice" = 1, "orangejuice" = 1, "cream" = 1, "cryoxadone" = 1)

/datum/chemical_reaction/irish_cream
	name = "Irish Cream"
	id = /datum/reagent/consumable/ethanol/irish_cream
	results = list(/datum/reagent/consumable/ethanol/irish_cream = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, "cream" = 1)

/datum/chemical_reaction/manly_dorf
	name = "The Manly Dorf"
	id = /datum/reagent/consumable/ethanol/manly_dorf
	results = list(/datum/reagent/consumable/ethanol/manly_dorf = 3)
	required_reagents = list (/datum/reagent/consumable/ethanol/beer = 1, /datum/reagent/consumable/ethanol/ale = 2)

/datum/chemical_reaction/greenbeer
	name = "Green Beer"
	id = /datum/reagent/consumable/ethanol/beer/green
	results = list(/datum/reagent/consumable/ethanol/beer/green = 10)
	required_reagents = list(/datum/reagent/colorful_reagent/crayonpowder/green = 1, /datum/reagent/consumable/ethanol/beer = 10)

/datum/chemical_reaction/hooch
	name = "Hooch"
	id = /datum/reagent/consumable/ethanol/hooch
	results = list(/datum/reagent/consumable/ethanol/hooch = 3)
	required_reagents = list ("ethanol" = 2, /datum/reagent/fuel = 1)
	required_catalysts = list("enzyme" = 1)

/datum/chemical_reaction/irish_coffee
	name = "Irish Coffee"
	id = /datum/reagent/consumable/ethanol/irishcoffee
	results = list(/datum/reagent/consumable/ethanol/irishcoffee = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/irish_cream = 1, "coffee" = 1)

/datum/chemical_reaction/b52
	name = "B-52"
	id = /datum/reagent/consumable/ethanol/b52
	results = list(/datum/reagent/consumable/ethanol/b52 = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/irish_cream = 1, /datum/reagent/consumable/ethanol/kahlua = 1, /datum/reagent/consumable/ethanol/cognac = 1)

/datum/chemical_reaction/atomicbomb
	name = "Atomic Bomb"
	id = "atomicbomb"
	results = list("atomicbomb" = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/b52 = 10, "uranium" = 1)

/datum/chemical_reaction/margarita
	name = "Margarita"
	id = /datum/reagent/consumable/ethanol/margarita
	results = list(/datum/reagent/consumable/ethanol/margarita = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 2, "limejuice" = 1)

/datum/chemical_reaction/longislandicedtea
	name = "Long Island Iced Tea"
	id = /datum/reagent/consumable/ethanol/longislandicedtea
	results = list(/datum/reagent/consumable/ethanol/longislandicedtea = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/ethanol/gin = 1, /datum/reagent/consumable/ethanol/tequila = 1, /datum/reagent/consumable/ethanol/cuba_libre = 1)

/datum/chemical_reaction/threemileisland
	name = "Three Mile Island Iced Tea"
	id = /datum/reagent/consumable/ethanol/threemileisland
	results = list(/datum/reagent/consumable/ethanol/threemileisland = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/longislandicedtea = 10, "uranium" = 1)

/datum/chemical_reaction/whiskeysoda
	name = "Whiskey Soda"
	id = /datum/reagent/consumable/ethanol/whiskeysoda
	results = list(/datum/reagent/consumable/ethanol/whiskeysoda = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, "sodawater" = 1)

/datum/chemical_reaction/black_russian
	name = "Black Russian"
	id = /datum/reagent/consumable/ethanol/blackrussian
	results = list(/datum/reagent/consumable/ethanol/blackrussian = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 3, /datum/reagent/consumable/ethanol/kahlua = 2)

/datum/chemical_reaction/manhattan
	name = "Manhattan"
	id = /datum/reagent/consumable/ethanol/manhattan
	results = list(/datum/reagent/consumable/ethanol/manhattan = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/consumable/ethanol/vermouth = 1)

/datum/chemical_reaction/manhattan_proj
	name = "Manhattan Project"
	id = /datum/reagent/consumable/ethanol/manhattan_proj
	results = list(/datum/reagent/consumable/ethanol/manhattan_proj = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/manhattan = 10, "uranium" = 1)

/datum/chemical_reaction/vodka_tonic
	name = "Vodka and Tonic"
	id = /datum/reagent/consumable/ethanol/vodkatonic
	results = list(/datum/reagent/consumable/ethanol/vodkatonic = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, "tonic" = 1)

/datum/chemical_reaction/gin_fizz
	name = "Gin Fizz"
	id = /datum/reagent/consumable/ethanol/ginfizz
	results = list(/datum/reagent/consumable/ethanol/ginfizz = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 2, "sodawater" = 1, "limejuice" = 1)

/datum/chemical_reaction/bahama_mama
	name = "Bahama mama"
	id = /datum/reagent/consumable/ethanol/bahama_mama
	results = list(/datum/reagent/consumable/ethanol/bahama_mama = 6)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 2, "orangejuice" = 2, "limejuice" = 1, "ice" = 1)

/datum/chemical_reaction/singulo
	name = "Singulo"
	id = /datum/reagent/consumable/ethanol/singulo
	results = list(/datum/reagent/consumable/ethanol/singulo = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 5, /datum/reagent/uranium/radium = 1, /datum/reagent/consumable/ethanol/wine = 5)

/datum/chemical_reaction/alliescocktail
	name = "Allies Cocktail"
	id = "alliescocktail"
	results = list("alliescocktail" = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/martini = 1, /datum/reagent/consumable/ethanol/vodka = 1)

/datum/chemical_reaction/demonsblood
	name = "Demons Blood"
	id = /datum/reagent/consumable/ethanol/demonsblood
	results = list(/datum/reagent/consumable/ethanol/demonsblood = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, "spacemountainwind" = 1, /datum/reagent/blood = 1, "dr_gibb" = 1)

/datum/chemical_reaction/booger
	name = "Booger"
	id = /datum/reagent/consumable/ethanol/booger
	results = list(/datum/reagent/consumable/ethanol/booger = 4)
	required_reagents = list("cream" = 1, "banana" = 1, /datum/reagent/consumable/ethanol/rum = 1, "watermelonjuice" = 1)

/datum/chemical_reaction/antifreeze
	name = "Anti-freeze"
	id = /datum/reagent/consumable/ethanol/antifreeze
	results = list(/datum/reagent/consumable/ethanol/antifreeze = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, "cream" = 1, "ice" = 1)

/datum/chemical_reaction/barefoot
	name = "Barefoot"
	id = /datum/reagent/consumable/ethanol/barefoot
	results = list(/datum/reagent/consumable/ethanol/barefoot = 3)
	required_reagents = list("berryjuice" = 1, "cream" = 1, /datum/reagent/consumable/ethanol/vermouth = 1)


////DRINKS THAT REQUIRED IMPROVED SPRITES BELOW:: -Agouri/////

/datum/chemical_reaction/sbiten
	name = "Sbiten"
	id = /datum/reagent/consumable/ethanol/sbiten
	results = list(/datum/reagent/consumable/ethanol/sbiten = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 10, "capsaicin" = 1)

/datum/chemical_reaction/red_mead
	name = "Red Mead"
	id = /datum/reagent/consumable/ethanol/red_mead
	results = list(/datum/reagent/consumable/ethanol/red_mead = 2)
	required_reagents = list(/datum/reagent/blood = 1, "mead" = 1)

/datum/chemical_reaction/mead
	name = "Mead"
	id = "mead"
	results = list("mead" = 2)
	required_reagents = list("honey" = 2)
	required_catalysts = list("enzyme" = 5)

/datum/chemical_reaction/iced_beer
	name = "Iced Beer"
	id = /datum/reagent/consumable/ethanol/iced_beer
	results = list(/datum/reagent/consumable/ethanol/iced_beer = 6)
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 5, "ice" = 1)

/datum/chemical_reaction/grog
	name = "Grog"
	id = /datum/reagent/consumable/ethanol/grog
	results = list(/datum/reagent/consumable/ethanol/grog = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/water = 1)

/datum/chemical_reaction/soy_latte
	name = "Soy Latte"
	id = "soy_latte"
	results = list("soy_latte" = 2)
	required_reagents = list("coffee" = 1, "soymilk" = 1)

/datum/chemical_reaction/cafe_latte
	name = "Cafe Latte"
	id = "cafe_latte"
	results = list("cafe_latte" = 2)
	required_reagents = list("coffee" = 1, "milk" = 1)

/datum/chemical_reaction/acidspit
	name = "Acid Spit"
	id = "acidspit"
	results = list("acidspit" = 6)
	required_reagents = list(/datum/reagent/toxin/acid = 1, /datum/reagent/consumable/ethanol/wine = 5)

/datum/chemical_reaction/amasec
	name = "Amasec"
	id = "amasec"
	results = list("amasec" = 10)
	required_reagents = list(/datum/reagent/iron = 1, /datum/reagent/consumable/ethanol/wine = 5, /datum/reagent/consumable/ethanol/vodka = 5)

/datum/chemical_reaction/changelingsting
	name = "Changeling Sting"
	id = "changelingsting"
	results = list("changelingsting" = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/screwdrivercocktail = 1, "lemon_lime" = 2)

/datum/chemical_reaction/aloe
	name = "Aloe"
	id = /datum/reagent/consumable/ethanol/aloe
	results = list(/datum/reagent/consumable/ethanol/aloe = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/irish_cream = 1, "watermelonjuice" = 1)

/datum/chemical_reaction/andalusia
	name = "Andalusia"
	id = /datum/reagent/consumable/ethanol/andalusia
	results = list(/datum/reagent/consumable/ethanol/andalusia = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/ethanol/whiskey = 1, "lemonjuice" = 1)

/datum/chemical_reaction/neurotoxin
	name = "Neurotoxin"
	id = "neurotoxin"
	results = list("neurotoxin" = 2)
	required_reagents = list("gargleblaster" = 1, "morphine" = 1)

/datum/chemical_reaction/snowwhite
	name = "Snow White"
	id = /datum/reagent/consumable/ethanol/snowwhite
	results = list(/datum/reagent/consumable/ethanol/snowwhite = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 1, "lemon_lime" = 1)

/datum/chemical_reaction/irishcarbomb
	name = "Irish Car Bomb"
	id = "irishcarbomb"
	results = list("irishcarbomb" = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/ale = 1, /datum/reagent/consumable/ethanol/irish_cream = 1)

/datum/chemical_reaction/syndicatebomb
	name = "Syndicate Bomb"
	id = "syndicatebomb"
	results = list("syndicatebomb" = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 1, /datum/reagent/consumable/ethanol/whiskey_cola = 1)

/datum/chemical_reaction/erikasurprise
	name = "Erika Surprise"
	id = "erikasurprise"
	results = list("erikasurprise" = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/ale = 1, "limejuice" = 1, /datum/reagent/consumable/ethanol/whiskey = 1, "banana" = 1, "ice" = 1)

/datum/chemical_reaction/devilskiss
	name = "Devils Kiss"
	id = /datum/reagent/consumable/ethanol/devilskiss
	results = list(/datum/reagent/consumable/ethanol/devilskiss = 3)
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/consumable/ethanol/kahlua = 1, /datum/reagent/consumable/ethanol/rum = 1)

/datum/chemical_reaction/hippiesdelight
	name = "Hippies Delight"
	id = "hippiesdelight"
	results = list("hippiesdelight" = 2)
	required_reagents = list("mushroomhallucinogen" = 1, "gargleblaster" = 1)

/datum/chemical_reaction/bananahonk
	name = "Banana Honk"
	id = "bananahonk"
	results = list("bananahonk" = 2)
	required_reagents = list("laughter" = 1, "cream" = 1)

/datum/chemical_reaction/silencer
	name = "Silencer"
	id = "silencer"
	results = list("silencer" = 3)
	required_reagents = list("nothing" = 1, "cream" = 1, "sugar" = 1)

/datum/chemical_reaction/driestmartini
	name = "Driest Martini"
	id = "driestmartini"
	results = list("driestmartini" = 2)
	required_reagents = list("nothing" = 1, /datum/reagent/consumable/ethanol/gin = 1)

/datum/chemical_reaction/thirteenloko
	name = "Thirteen Loko"
	id = /datum/reagent/consumable/ethanol/thirteenloko
	results = list(/datum/reagent/consumable/ethanol/thirteenloko = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, "coffee" = 1, "limejuice" = 1)

/datum/chemical_reaction/chocolatepudding
	name = "Chocolate Pudding"
	id = "chocolatepudding"
	results = list("chocolatepudding" = 20)
	required_reagents = list("chocolate_milk" = 10, "eggyolk" = 5)

/datum/chemical_reaction/vanillapudding
	name = "Vanilla Pudding"
	id = "vanillapudding"
	results = list("vanillapudding" = 20)
	required_reagents = list("vanilla" = 5, "milk" = 5, "eggyolk" = 5)

/datum/chemical_reaction/cherryshake
	name = "Cherry Shake"
	id = "cherryshake"
	results = list("cherryshake" = 3)
	required_reagents = list("cherryjelly" = 1, "ice" = 1, "cream" = 1)

/datum/chemical_reaction/bluecherryshake
	name = "Blue Cherry Shake"
	id = "bluecherryshake"
	results = list("bluecherryshake" = 3)
	required_reagents = list("bluecherryjelly" = 1, "ice" = 1, "cream" = 1)

/datum/chemical_reaction/drunkenblumpkin
	name = "Drunken Blumpkin"
	id = "drunkenblumpkin"
	results = list("drunkenblumpkin" = 4)
	required_reagents = list("blumpkinjuice" = 1, /datum/reagent/consumable/ethanol/irish_cream = 2, "ice" = 1)

/datum/chemical_reaction/pumpkin_latte
	name = "Pumpkin space latte"
	id = "pumpkin_latte"
	results = list("pumpkin_latte" = 15)
	required_reagents = list("pumpkinjuice" = 5, "coffee" = 5, "cream" = 5)

/datum/chemical_reaction/gibbfloats
	name = "Gibb Floats"
	id = "gibbfloats"
	results = list("gibbfloats" = 15)
	required_reagents = list("dr_gibb" = 5, "ice" = 5, "cream" = 5)

/datum/chemical_reaction/triple_citrus
	name = "triple_citrus"
	id = "triple_citrus"
	results = list("triple_citrus" = 5)
	required_reagents = list("lemonjuice" = 1, "limejuice" = 1, "orangejuice" = 1)

/datum/chemical_reaction/grape_soda
	name = "grape soda"
	id = "grapesoda"
	results = list("grapesoda" = 2)
	required_reagents = list("grapejuice" = 1, "sodawater" = 1)

/datum/chemical_reaction/grappa
	name = /datum/reagent/consumable/ethanol/grappa
	id = /datum/reagent/consumable/ethanol/grappa
	results = list(/datum/reagent/consumable/ethanol/grappa = 10)
	required_reagents = list (/datum/reagent/consumable/ethanol/wine = 10)
	required_catalysts = list ("enzyme" = 5)

/datum/chemical_reaction/whiskey_sour
	name = "Whiskey Sour"
	id = "whiskey_sour"
	results = list("whiskey_sour" = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 1, "lemonjuice" = 1, "sugar" = 1)
	mix_message = "The mixture darkens to a rich gold hue."

/datum/chemical_reaction/fetching_fizz
	name = "Fetching Fizz"
	id = "fetching_fizz"
	results = list("fetching_fizz" = 3)
	required_reagents = list("nuka_cola" = 1, /datum/reagent/iron = 1) //Manufacturable from only the mining station
	mix_message = "The mixture slightly vibrates before settling."

/datum/chemical_reaction/hearty_punch
	name = "Hearty Punch"
	id = "hearty_punch"
	results = list("hearty_punch" = 1)  //Very little, for balance reasons
	required_reagents = list(/datum/reagent/consumable/ethanol/brave_bull = 5, "syndicatebomb" = 5, /datum/reagent/consumable/ethanol/absinthe = 5)
	mix_message = "The mixture darkens to a healthy crimson."
	required_temp = 315 //Piping hot!

/datum/chemical_reaction/bacchus_blessing
	name = "Bacchus' Blessing"
	id = "bacchus_blessing"
	results = list("bacchus_blessing" = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/hooch = 1, /datum/reagent/consumable/ethanol/absinthe = 1, /datum/reagent/consumable/ethanol/manly_dorf = 1, "syndicatebomb" = 1)
	mix_message = "<span class='warning'>The mixture turns to a sickening froth.</span>"

/datum/chemical_reaction/lemonade
	name = "Lemonade"
	id = "lemonade"
	results = list("lemonade" = 5)
	required_reagents = list("lemonjuice" = 2, /datum/reagent/water = 2, "sugar" = 1, "ice" = 1)
	mix_message = "You're suddenly reminded of home."

/datum/chemical_reaction/arnold_palmer
	name = "Arnold Palmer"
	id = "arnold_palmer"
	results = list("arnold_palmer" = 2)
	required_reagents = list("tea" = 1, "lemonade" = 1)
	mix_message = "The smells of fresh green grass and sand traps waft through the air as the mixture turns a friendly yellow-orange."

/datum/chemical_reaction/chocolate_milk
	name = "chocolate milk"
	id = "chocolate_milk"
	results = list("chocolate_milk" = 2)
	required_reagents = list("milk" = 1, "cocoa" = 1)
	mix_message = "The color changes as the mixture blends smoothly."

/datum/chemical_reaction/eggnog
	name = "eggnog"
	id = "eggnog"
	results = list("eggnog" = 15)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 5, "cream" = 5, "eggyolk" = 5)

/datum/chemical_reaction/narsour
	name = "Nar'sour"
	id = "narsour"
	results = list("narsour" = 1)
	required_reagents = list(/datum/reagent/blood = 1, "lemonjuice" = 1, /datum/reagent/consumable/ethanol/demonsblood = 1)
	mix_message = "The mixture develops a sinister glow."
	mix_sound = 'sound/effects/singlebeat.ogg'

/datum/chemical_reaction/quadruplesec
	name = "Quadruple Sec"
	id = "quadruple_sec"
	results = list("quadruple_sec" = 15)
	required_reagents = list("triple_sec" = 5, "triple_citrus" = 5, "creme_de_menthe" = 5)
	mix_message = "The snap of a taser emanates clearly from the mixture as it settles."
	mix_sound = 'sound/weapons/taser.ogg'

/datum/chemical_reaction/grasshopper
	name = "Grasshopper"
	id = "grasshopper"
	results = list("grasshopper" = 15)
	required_reagents = list("cream" = 5, "creme_de_menthe" = 5, "creme_de_cacao" = 5)
	mix_message = "A vibrant green bubbles forth as the mixture emulsifies."

/datum/chemical_reaction/stinger
	name = "Stinger"
	id = "stinger"
	results = list("stinger" = 15)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 10, "creme_de_menthe" = 5 )

/datum/chemical_reaction/quintuplesec
	name = "Quintuple Sec"
	id = "quintuple_sec"
	results = list("quintuple_sec" = 15)
	required_reagents = list("quadruple_sec" = 5, "clownstears" = 5, "syndicatebomb" = 5)
	mix_message = "Judgement is upon you."
	mix_sound = 'sound/items/airhorn2.ogg'

/datum/chemical_reaction/bastion_bourbon
	name = "Bastion Bourbon"
	id = "bastion_bourbon"
	results = list("bastion_bourbon" = 2)
	required_reagents = list("tea" = 1, "creme_de_menthe" = 1, "triple_citrus" = 1, "berryjuice" = 1) //herbal and minty, with a hint of citrus and berry
	mix_message = "You catch an aroma of hot tea and fruits as the mix blends into a blue-green color."

/datum/chemical_reaction/squirt_cider
	name = "Squirt Cider"
	id = "squirt_cider"
	results = list("squirt_cider" = 1)
	required_reagents = list(/datum/reagent/water = 1, "tomatojuice" = 1, "nutriment" = 1)
	mix_message = "The mix swirls and turns a bright red that reminds you of an apple's skin."

/datum/chemical_reaction/fringe_weaver
	name = "Fringe Weaver"
	id = "fringe_weaver"
	results = list("fringe_weaver" = 10)
	required_reagents = list("ethanol" = 9, "sugar" = 1) //9 karmotrine, 1 adelhyde
	mix_message = "The mix turns a pleasant cream color and foams up."

/datum/chemical_reaction/sugar_rush
	name = "Sugar Rush"
	id = "sugar_rush"
	results = list("sugar_rush" = 4)
	required_reagents = list("sugar" = 2, "lemonjuice" = 1, /datum/reagent/consumable/ethanol/wine = 1) //2 adelhyde (sweet), 1 powdered delta (sour), 1 karmotrine (alcohol)
	mix_message = "The mixture bubbles and brightens into a girly pink."

/datum/chemical_reaction/crevice_spike
	name = "Crevice Spike"
	id = "crevice_spike"
	results = list("crevice_spike" = 6)
	required_reagents = list("limejuice" = 2, "capsaicin" = 4) //2 powdered delta (sour), 4 flanergide (spicy)
	mix_message = "The mixture stings your eyes as it settles."

/datum/chemical_reaction/sake
	name = "sake"
	id = "sake"
	results = list("sake" = 10)
	required_reagents = list("rice" = 10)
	required_catalysts = list("enzyme" = 5)
	mix_message = "The rice grains ferment into a clear, sweet-smelling liquid."

/datum/chemical_reaction/peppermint_patty
	name = "Peppermint Patty"
	id = "peppermint_patty"
	results = list("peppermint_patty" = 10)
	required_reagents = list("hot_coco" = 6, "creme_de_cacao" = 1, "creme_de_menthe" = 1, /datum/reagent/consumable/ethanol/vodka = 1, "menthol" = 1)
	mix_message = "The coco turns mint green just as the strong scent hits your nose."

/datum/chemical_reaction/alexander
	name = "Alexander"
	id = "alexander"
	results = list("alexander" = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/cognac = 1, "creme_de_cacao" = 1, "cream" = 1)

/datum/chemical_reaction/sidecar
	name = "Sidecar"
	id = "sidecar"
	results = list("sidecar" = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/cognac = 2, "triple_sec" = 1, "lemonjuice" = 1)

/datum/chemical_reaction/between_the_sheets
	name = "Between the Sheets"
	id = "between_the_sheets"
	results = list("between_the_sheets" = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, "sidecar" = 4)

/datum/chemical_reaction/kamikaze
	name = "Kamikaze"
	id = "kamikaze"
	results = list("kamikaze" = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, "triple_sec" = 1, "limejuice" = 1)

/datum/chemical_reaction/mojito
	name = "Mojito"
	id = "mojito"
	results = list("mojito" = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, "sugar" = 1, "limejuice" = 1, "sodawater" = 1, "menthol" = 1)

/datum/chemical_reaction/fernet_cola
	name = "Fernet Cola"
	id = "fernet_cola"
	results = list("fernet_cola" = 2)
	required_reagents = list("fernet" = 1, "cola" = 1)


/datum/chemical_reaction/fanciulli
	name = "Fanciulli"
	id = "fanciulli"
	results = list("fanciulli" = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/manhattan = 1, "fernet" = 1)

/datum/chemical_reaction/branca_menta
	name = "Branca Menta"
	id = "branca_menta"
	results = list("branca_menta" = 3)
	required_reagents = list("fernet" = 1, "creme_de_menthe" = 1, "ice" = 1)

/datum/chemical_reaction/blank_paper
	name = "Blank Paper"
	id = "blank_paper"
	results = list("blank_paper" = 3)
	required_reagents = list("silencer" = 1, "nothing" = 1, "nuka_cola" = 1)


/datum/chemical_reaction/wizz_fizz
	name = "Wizz Fizz"
	id = "wizz_fizz"
	results = list("wizz_fizz" = 3)
	required_reagents = list("triple_sec" = 1, "sodawater" = 1, "champagne" = 1)
	mix_message = "The beverage starts to froth with an almost mystical zeal!"
	mix_sound = 'sound/effects/bubbles2.ogg'


/datum/chemical_reaction/bug_spray
	name = "Bug Spray"
	id = "bug_spray"
	results = list("bug_spray" = 5)
	required_reagents = list("triple_sec" = 2, "lemon_lime" = 1, /datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/ethanol/vodka = 1)
	mix_message = "The faint aroma of summer camping trips wafts through the air; but what's that buzzing noise?"
	mix_sound = 'sound/creatures/bee.ogg'

/datum/chemical_reaction/jack_rose
	name = "Jack Rose"
	id = "jack_rose"
	results = list("jack_rose" = 4)
	required_reagents = list("grenadine" = 1, "applejack" = 2, "limejuice" = 1)
	mix_message = "As the grenadine incorporates, the beverage takes on a mellow, red-orange glow."

/datum/chemical_reaction/turbo
	name = "Turbo"
	id = "turbo"
	results = list("turbo" = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/moonshine = 2, /datum/reagent/nitrous_oxide = 1, "sugar_rush" = 1, "pwr_game" = 1)

/datum/chemical_reaction/old_timer
	name = "Old Timer"
	id = "old_timer"
	results = list("old_timer" = 6)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskeysoda = 3, "parsnipjuice" = 2, "alexander" = 1)

/datum/chemical_reaction/rubberneck
	name = "Rubberneck"
	id = "rubberneck"
	results = list("rubberneck" = 10)
	required_reagents = list("ethanol" = 4, "grey_bull" = 5, "astrotame" = 1)

/datum/chemical_reaction/duplex
	name = "Duplex"
	id = "duplex"
	results = list("duplex" = 4)
	required_reagents = list("hcider" = 2, "applejuice" = 1, "berryjuice" = 1)

/datum/chemical_reaction/trappist
	name = "Trappist"
	id = "trappist"
	results = list("trappist" = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/ale = 2, /datum/reagent/water/holywater = 2, "sugar" = 1)

/datum/chemical_reaction/cream_soda
	name = "Cream Soda"
	id = "cream_soda"
	results = list("cream_soda" = 4)
	required_reagents = list("sugar" = 2, "sodawater" = 2, "vanilla" = 1)

/datum/chemical_reaction/blazaam
	name = "Blazaam"
	id = "blazaam"
	results = list("blazaam" = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 2, "peachjuice" = 1, /datum/reagent/bluespace = 1)

/datum/chemical_reaction/planet_cracker
	name = "Planet Cracker"
	id = "planet_cracker"
	results = list("planet_cracker" = 4)
	required_reagents = list("champagne" = 2, /datum/reagent/consumable/ethanol/lizardwine = 2, "eggyolk" = 1, "gold" = 1)
	mix_message = "The liquid's color starts shifting as the nanogold is alternately corroded and redeposited."

/datum/chemical_reaction/red_queen
	name = "Red Queen"
	id = "red_queen"
	results = list("red_queen" = 10)
	required_reagents = list("tea" = 6, /datum/reagent/mercury = 2, "blackpepper" = 1, /datum/reagent/growthserum = 1)
