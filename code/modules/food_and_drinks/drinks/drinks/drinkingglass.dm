

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass
	name = "drinking glass"
	desc = "Your standard drinking glass."
	icon_state = "glass_empty"
	amount_per_transfer_from_this = 10
	volume = 50
	materials = list(MAT_GLASS=500)
	obj_integrity = 20
	max_integrity = 20
	spillable = 1
	resistance_flags = ACID_PROOF
	unique_rename = 1

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/on_reagent_change()
	cut_overlays()
	if (reagents.reagent_list.len > 0)
		switch(reagents.get_master_reagent_id())
			if("beer")
				icon_state = "beerglass"
				name = "glass of beer"
				desc = "A freezing pint of beer."
			if("beer2")
				icon_state = "beerglass"
				name = "glass of beer"
				desc = "A freezing pint of beer."
			if("greenbeer")
				icon_state = "greenbeerglass"
				name = "glass of green beer"
				desc = "A freezing pint of green beer. Festive."
			if("ale")
				icon_state = "aleglass"
				name = "glass of ale"
				desc = "A freezing pint of delicious Ale."
			if("milk")
				icon_state = "glass_white"
				name = "glass of milk"
				desc = "White and nutritious goodness!"
			if("cream")
				icon_state  = "glass_white"
				name = "glass of cream"
				desc = "Ewwww..."
			if("hot_coco")
				icon_state  = "chocolateglass"
				name = "glass of chocolate"
				desc = "Tasty."
			if("lemonjuice")
				icon_state  = "lemonglass"
				name = "glass of lemon juice"
				desc = "Sour..."
			if("holywater")
				icon_state  = "glass_clear"
				name = "glass of Holy Water"
				desc = "A glass of holy water."
			if("potato")
				icon_state = "glass_brown"
				name = "glass of potato juice"
				desc = "Bleh..."
			if("watermelonjuice")
				icon_state = "glass_red"
				name = "glass of watermelon juice"
				desc = "A glass of watermelon juice."
			if("cola")
				icon_state  = "glass_brown"
				name = "glass of space Cola"
				desc = "A glass of refreshing Space Cola."
			if("nuka_cola")
				icon_state = "nuka_colaglass"
				name = "Nuka Cola"
				desc = "Don't cry, Don't raise your eye, It's only nuclear wasteland."
			if("orangejuice")
				icon_state = "glass_orange"
				name = "glass of orange juice"
				desc = "Vitamins! Yay!"
			if("tomatojuice")
				icon_state = "glass_red"
				name = "glass of tomato juice"
				desc = "Are you sure this is tomato juice?"
			if("blood")
				icon_state = "glass_red"
				name = "glass of tomato juice"
				desc = "Are you sure this is tomato juice?"
			if("limejuice")
				icon_state = "glass_green"
				name = "glass of lime juice"
				desc = "A glass of sweet-sour lime juice."
			if("whiskey")
				icon_state = "whiskeyglass"
				name = "glass of whiskey"
				desc = "The silky, smokey whiskey goodness inside the glass makes the drink look very classy."
			if("gin")
				icon_state = "ginvodkaglass"
				name = "glass of gin"
				desc = "A crystal clear glass of Griffeater gin."
			if("vodka")
				icon_state = "ginvodkaglass"
				name = "glass of vodka"
				desc = "The glass contain wodka. Xynta."
			if("goldschlager")
				icon_state = "goldschlagerglass"
				name = "glass of Goldschlager"
				desc = "100% proof that teen girls will drink anything with gold in it."
			if("wine")
				icon_state = "wineglass"
				name = "glass of wine"
				desc = "A very classy looking drink."
			if("cognac")
				icon_state = "cognacglass"
				name = "glass of cognac"
				desc = "Damn, you feel like some kind of French aristocrat just by holding this."
			if ("kahlua")
				icon_state = "kahluaglass"
				name = "glass of RR Coffee Liquor"
				desc = "DAMN, THIS THING LOOKS ROBUST!"
			if("vermouth")
				icon_state = "vermouthglass"
				name = "glass of vermouth"
				desc = "You wonder why you're even drinking this straight."
			if("tequila")
				icon_state = "tequilaglass"
				name = "glass of tequila"
				desc = "Now all that's missing is the weird colored shades!"
			if("patron")
				icon_state = "patronglass"
				name = "glass of patron"
				desc = "Drinking patron in the bar, with all the subpar ladies."
			if("rum")
				icon_state = "rumglass"
				name = "glass of rum"
				desc = "Now you want to Pray for a pirate suit, don't you?"
			if("gintonic")
				icon_state = "gintonicglass"
				name = "Gin and Tonic"
				desc = "A mild but still great cocktail. Drink up, like a true Englishman."
			if("whiskeycola")
				icon_state = "whiskeycolaglass"
				name = "Whiskey Cola"
				desc = "An innocent-looking mixture of cola and Whiskey. Delicious."
			if("whiterussian")
				icon_state = "whiterussianglass"
				name = "White Russian"
				desc = "A very nice looking drink. But that's just, like, your opinion, man."
			if("screwdrivercocktail")
				icon_state = "screwdriverglass"
				name = "Screwdriver"
				desc = "A simple, yet superb mixture of Vodka and orange juice. Just the thing for the tired engineer."
			if("bloodymary")
				icon_state = "bloodymaryglass"
				name = "Bloody Mary"
				desc = "Tomato juice, mixed with Vodka and a lil' bit of lime. Tastes like liquid murder."
			if("martini")
				icon_state = "martiniglass"
				name = "Classic Martini"
				desc = "Damn, the bartender even stirred it, not shook it."
			if("vodkamartini")
				icon_state = "martiniglass"
				name = "Vodka martini"
				desc ="A bastardisation of the classic martini. Still great."
			if("gargleblaster")
				icon_state = "gargleblasterglass"
				name = "Pan-Galactic Gargle Blaster"
				desc = "Like having your brain smashed out by a slice of lemon wrapped around a large gold brick."
			if("bravebull")
				icon_state = "bravebullglass"
				name = "Brave Bull"
				desc = "Tequila and Coffee liqueur, brought together in a mouthwatering mixture. Drink up."
			if("tequilasunrise")
				icon_state = "tequilasunriseglass"
				name = "tequila Sunrise"
				desc = "Oh great, now you feel nostalgic about sunrises back on Terra..."
			if("beepskysmash")
				icon_state = "beepskysmashglass"
				name = "Beepsky Smash"
				desc = "Heavy, hot and strong. Just like the Iron fist of the LAW."
			if("doctorsdelight")
				icon_state = "doctorsdelightglass"
				name = "Doctor's Delight"
				desc = "The space doctor's favorite. Guaranteed to restore bodily injury; side effects include cravings and hunger."
			if("manlydorf")
				icon_state = "manlydorfglass"
				name = "The Manly Dorf"
				desc = "A manly concoction made from Ale and Beer. Intended for true men only."
			if("irishcream")
				icon_state = "irishcreamglass"
				name = "Irish Cream"
				desc = "It's cream, mixed with whiskey. What else would you expect from the Irish?"
			if("cubalibre")
				icon_state = "cubalibreglass"
				name = "Cuba Libre"
				desc = "A classic mix of rum and cola."
			if("atomicbomb")
				icon_state = "atomicbombglass"
				name = "Atomic Bomb"
				desc = "Nanotrasen cannot take legal responsibility for your actions after imbibing."
			if("longislandicedtea")
				icon_state = "longislandicedteaglass"
				name = "Long Island Iced Tea"
				desc = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
			if("threemileisland")
				icon_state = "threemileislandglass"
				name = "Three Mile Island Ice Tea"
				desc = "A glass of this is sure to prevent a meltdown."
			if("margarita")
				icon_state = "margaritaglass"
				name = "Margarita"
				desc = "On the rocks with salt on the rim. Arriba~!"
			if("blackrussian")
				icon_state = "blackrussianglass"
				name = "Black Russian"
				desc = "For the lactose-intolerant. Still as classy as a White Russian."
			if("vodkatonic")
				icon_state = "vodkatonicglass"
				name = "Vodka and Tonic"
				desc = "For when a gin and tonic isn't Russian enough."
			if("manhattan")
				icon_state = "manhattanglass"
				name = "Manhattan"
				desc = "The Detective's undercover drink of choice. He never could stomach gin..."
			if("manhattan_proj")
				icon_state = "proj_manhattanglass"
				name = "Manhattan Project"
				desc = "A scientist's drink of choice, for thinking how to blow up the station."
			if("ginfizz")
				icon_state = "ginfizzglass"
				name = "Gin Fizz"
				desc = "Refreshingly lemony, deliciously dry."
			if("irishcoffee")
				icon_state = "irishcoffeeglass"
				name = "Irish Coffee"
				desc = "Coffee and alcohol. More fun than a Mimosa to drink in the morning."
			if("hooch")
				icon_state = "glass_brown2"
				name = "Hooch"
				desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
			if("whiskeysoda")
				icon_state = "whiskeysodaglass2"
				name = "Whiskey Soda"
				desc = "Ultimate refreshment."
			if("tonic")
				icon_state = "glass_clear"
				name = "glass of Tonic Water"
				desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
			if("sodawater")
				icon_state = "glass_clear"
				name = "glass of Soda Water"
				desc = "Soda water. Why not make a scotch and soda?"
			if("water")
				icon_state = "glass_clear"
				name = "glass of Water"
				desc = "The father of all refreshments."
			if("spacemountainwind")
				icon_state = "Space_mountain_wind_glass"
				name = "glass of Space Mountain Wind"
				desc = "Space Mountain Wind. As you know, there are no mountains in space, only wind."
			if("thirteenloko")
				icon_state = "thirteen_loko_glass"
				name = "glass of Thirteen Loko"
				desc = "This is a glass of Thirteen Loko, it appears to be of the highest quality. The drink, not the glass."
			if("dr_gibb")
				icon_state = "dr_gibb_glass"
				name = "glass of Dr. Gibb"
				desc = "Dr. Gibb. Not as dangerous as the name might imply."
			if("space_up")
				icon_state = "space-up_glass"
				name = "glass of Space-up"
				desc = "Space-up. It helps you keep your cool."
			if("lemon_lime")
				icon_state = "glass_yellow"
				name = "glass of Lemon-Lime"
				desc = "You're pretty certain a real fruit has never actually touched this."
			if("moonshine")
				icon_state = "glass_clear"
				name = "Moonshine"
				desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
			if("soymilk")
				icon_state = "glass_white"
				name = "glass of soy milk"
				desc = "White and nutritious soy goodness!"
			if("berryjuice")
				icon_state = "berryjuice"
				name = "glass of berry juice"
				desc = "Berry juice. Or maybe it's jam. Who cares?"
			if("poisonberryjuice")
				icon_state = "poisonberryjuice"
				name = "glass of berry juice"
				desc = "Berry juice. Or maybe it's poison. Who cares?"
			if("carrotjuice")
				icon_state = "carrotjuice"
				name = "glass of  carrot juice"
				desc = "It's just like a carrot but without crunching."
			if("banana")
				icon_state = "banana"
				name = "glass of banana juice"
				desc = "The raw essence of a banana. HONK."
			if("bahama_mama")
				icon_state = "bahama_mama"
				name = "Bahama Mama"
				desc = "Tropical cocktail."
			if("singulo")
				icon_state = "singulo"
				name = "Singulo"
				desc = "A blue-space beverage."
			if("alliescocktail")
				icon_state = "alliescocktail"
				name = "Allies cocktail"
				desc = "A drink made from your allies."
			if("antifreeze")
				icon_state = "antifreeze"
				name = "Anti-freeze"
				desc = "The ultimate refreshment."
			if("barefoot")
				icon_state = "b&p"
				name = "Barefoot"
				desc = "Barefoot and pregnant."
			if("demonsblood")
				icon_state = "demonsblood"
				name = "Demons Blood"
				desc = "Just looking at this thing makes the hair at the back of your neck stand up."
			if("booger")
				icon_state = "booger"
				name = "Booger"
				desc = "Ewww..."
			if("snowwhite")
				icon_state = "snowwhite"
				name = "Snow White"
				desc = "A cold refreshment."
			if("aloe")
				icon_state = "aloe"
				name = "Aloe"
				desc = "Very, very, very good."
			if("andalusia")
				icon_state = "andalusia"
				name = "Andalusia"
				desc = "A nice, strangely named drink."
			if("sbiten")
				icon_state = "sbitenglass"
				name = "Sbiten"
				desc = "A spicy mix of Vodka and Spice. Very hot."
			if("red_mead")
				icon_state = "red_meadglass"
				name = "Red Mead"
				desc = "A True Viking's Beverage, though its color is strange."
			if("mead")
				icon_state = "meadglass"
				name = "Mead"
				desc = "A Viking's Beverage, though a cheap one."
			if("iced_beer")
				icon_state = "iced_beerglass"
				name = "Iced Beer"
				desc = "A beer so frosty, the air around it freezes."
			if("grog")
				icon_state = "grogglass"
				name = "Grog"
				desc = "A fine and cepa drink for Space."
			if("soy_latte")
				icon_state = "soy_latte"
				name = "Soy Latte"
				desc = "A nice and refreshing beverage while you're reading."
			if("cafe_latte")
				icon_state = "cafe_latte"
				name = "Cafe Latte"
				desc = "A nice, strong and refreshing beverage while you're reading."
			if("acidspit")
				icon_state = "acidspitglass"
				name = "Acid Spit"
				desc = "A drink from Nanotrasen. Made from live aliens."
			if("amasec")
				icon_state = "amasecglass"
				name = "Amasec"
				desc = "Always handy before COMBAT!!!"
			if("neurotoxin")
				icon_state = "neurotoxinglass"
				name = "Neurotoxin"
				desc = "A drink that is guaranteed to knock you silly."
			if("hippiesdelight")
				icon_state = "hippiesdelightglass"
				name = "Hippie's Delight"
				desc = "A drink enjoyed by people during the 1960's."
			if("bananahonk")
				icon_state = "bananahonkglass"
				name = "Banana Honk"
				desc = "A drink from Clown Heaven."
			if("silencer")
				icon_state = "silencerglass"
				name = "Silencer"
				desc = "A drink from Mime Heaven."
			if("nothing")
				icon_state = "nothing"
				name = "Nothing"
				desc = "Absolutely nothing."
			if("devilskiss")
				icon_state = "devilskiss"
				name = "Devils Kiss"
				desc = "Creepy time!"
			if("changelingsting")
				icon_state = "changelingsting"
				name = "Changeling Sting"
				desc = "A stingy drink."
			if("irishcarbomb")
				icon_state = "irishcarbomb"
				name = "Irish Car Bomb"
				desc = "An Irish car bomb."
			if("syndicatebomb")
				icon_state = "syndicatebomb"
				name = "Syndicate Bomb"
				desc = "A syndicate bomb."
			if("erikasurprise")
				icon_state = "erikasurprise"
				name = "Erika Surprise"
				desc = "The surprise is, it's green!"
			if("driestmartini")
				icon_state = "driestmartiniglass"
				name = "Driest Martini"
				desc = "Only for the experienced. You think you see sand floating in the glass."
			if("ice")
				icon_state = "iceglass"
				name = "glass of ice"
				desc = "Generally, you're supposed to put something else in there too..."
			if("icecoffee")
				icon_state = "icedcoffeeglass"
				name = "Iced Coffee"
				desc = "A drink to perk you up and refresh you!"
			if("icetea")
				icon_state = "icedteaglass"
				name = "Iced Tea"
				desc = "All natural, antioxidant-rich flavour sensation."
			if("coffee")
				icon_state = "glass_brown"
				name = "glass of coffee"
				desc = "Don't drop it, or you'll send scalding liquid and glass shards everywhere."
			if("tea")
				icon_state = "teaglass"
				name = "glass of tea"
				desc = "Drinking it from here would not seem right."
			if("bilk")
				icon_state = "glass_brown"
				name = "glass of bilk"
				desc = "A brew of milk and beer. For those alcoholics who fear osteoporosis."
			if("welding_fuel")
				icon_state = "dr_gibb_glass"
				name = "glass of welder fuel"
				desc = "Unless you're an industrial tool, this is probably not safe for consumption."
			if("b52")
				icon_state = "b52glass"
				name = "B-52"
				desc = "Kahlua, Irish Cream, and cognac. You will get bombed."
			if("toxinsspecial")
				icon_state = "toxinsspecialglass"
				name = "Toxins Special"
				desc = "Whoah, this thing is on FIRE!"
			if("chocolatepudding")
				icon_state = "chocolatepudding"
				name = "Chocolate Pudding"
				desc = "Tasty."
			if("vanillapudding")
				icon_state = "vanillapudding"
				name = "Vanilla Pudding"
				desc = "Tasty."
			if("cherryshake")
				icon_state = "cherryshake"
				name = "Cherry Shake"
				desc = "A cherry flavored milkshake."
			if("bluecherryshake")
				icon_state = "bluecherryshake"
				name = "Blue Cherry Shake"
				desc = "An exotic blue milkshake."
			if("drunkenblumpkin")
				icon_state = "drunkenblumpkin"
				name = "Drunken Blumpkin"
				desc = "A drink for the drunks."
			if("pumpkin_latte")
				icon_state = "pumpkin_latte"
				name = "Pumpkin Latte"
				desc = "A mix of coffee and pumpkin juice."
			if("gibbfloats")
				icon_state = "gibbfloats"
				name = "Gibbfloat"
				desc = "Dr. Gibb with ice cream on top."
			if("whiskey_sour")
				icon_state = "whiskey_sour"
				name = "Whiskey Sour"
				desc = "Lemon juice mixed with whiskey and a dash of sugar. Surprisingly satisfying."
			if("fetching_fizz")
				icon_state = "fetching_fizz"
				name = "Fetching Fizz"
				desc = "Induces magnetism in the imbiber. Started as a barroom prank but evolved to become popular with miners and scrappers. Metallic aftertaste."
			if("hearty_punch")
				icon_state = "hearty_punch"
				name = "Hearty Punch"
				desc = "Aromatic beverage served piping hot. According to folk tales it can almost wake the dead."
			if("absinthe")
				icon_state = "absinthe"
				name = "glass of absinthe"
				desc = "It's as strong as it smells."
			if("bacchus_blessing")
				icon_state = "glass_brown2"
				name = "Bacchus' Blessing"
				desc = "You didn't think it was possible for a liquid to be so utterly revolting. Are you sure about this...?"
			if("arnold_palmer")
				icon_state = "arnold_palmer"
				name = "Arnold Palmer"
				desc = "You feel like taking a few golf swings after a few swigs of this."
			if("hcider")
				icon_state = "whiskeyglass"
				name = "Hard Cider"
				desc = "Tastes like autumn."
			if("triple_citrus")
				icon_state = "triplecitrus" //needs own sprite mine are trash
				name = "glass of triple citrus"
				desc = "A mixture of citrus juices. Tangy, yet smooth."
			if("grappa")
				icon_state = "grappa"
				name = "glass of grappa"
				desc = "A fine drink originally made to prevent waste by using the leftovers from winemaking."
			if("eggnog")
				icon_state = "glass_yellow"
				name = "Eggnog"
				desc = "For enjoying the most wonderful time of the year."
			else
				icon_state ="glass_brown"
				var/image/I = image(icon, "glassoverlay")
				I.color = mix_color_from_reagents(reagents.reagent_list)
				add_overlay(I)
				name = "glass of ..what?"
				desc = "You can't really tell what this is."
	else
		icon_state = "glass_empty"
		name = "drinking glass"
		desc = "Your standard drinking glass."
		return

//Shot glasses!//
//  This lets us add shots in here instead of lumping them in with drinks because >logic  //
//  The format for shots is the exact same as iconstates for the drinking glass, except you use a shot glass instead.  //
//  If it's a new drink, remember to add it to Chemistry-Reagents.dm  and Chemistry-Recipes.dm as well.  //
//  You can only mix the ported-over drinks in shot glasses for now (they'll mix in a shaker, but the sprite won't change for glasses). //
//  This is on a case-by-case basis, and you can even make a seperate sprite for shot glasses if you want. //

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass
	name = "shot glass"
	desc = "A shot glass - the universal symbol for bad decisions."
	icon_state = "shotglass"
	gulp_size = 15
	amount_per_transfer_from_this = 15
	possible_transfer_amounts = list()
	volume = 15
	materials = list(MAT_GLASS=100)

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass/on_reagent_change()
	if (gulp_size < 15)
		gulp_size = 15
	else
		gulp_size = max(round(reagents.total_volume / 15), 15)

	if (reagents.reagent_list.len > 0)
		switch(reagents.get_master_reagent_id())
			if("vodka")
				icon_state = "shotglassclear"
				name = "shot of vodka"
				desc = "Good for cold weather."
			if("water")
				icon_state = "shotglassclear"
				name = "shot of water"
				desc = "You're not sure why someone would drink this from a shot glass."
			if("whiskey")
				icon_state = "shotglassbrown"
				name = "shot of whiskey"
				desc = "Just like the old west."
			if("hcider")
				icon_state = "shotglassbrown"
				name = "shot of hard cider"
				desc = "Not meant to be drunk from a shot glass."
			if("rum")
				icon_state = "shotglassbrown"
				name = "shot of rum"
				desc = "You dirty pirate."
			if("b52")
				icon_state = "b52glass"
				name = "B-52"
				desc = "Kahlua, Irish Cream, and cognac. You will get bombed."
			if("toxinsspecial")
				icon_state = "toxinsspecialglass"
				name = "Toxins Special"
				desc = "Whoah, this thing is on FIRE!"
			if ("vermouth")
				icon_state = "shotglassclear"
				name = "shot of vermouth"
				desc = "This better be going in a martini."
			if ("tequila")
				icon_state = "shotglassgold"
				name = "shot of tequila"
				desc = "Bad decisions ahead!"
			if ("patron")
				icon_state = "shotglassclear"
				name = "shot of patron"
				desc = "The good stuff. Goes great with a lime wedge."
			if ("kahlua")
				icon_state = "shotglasscream"
				name = "shot of coffee liqueur"
				desc = "Doesn't look too appetizing..."
			if ("nothing")
				icon_state = "shotglass"
				name = "shot of nothing"
				desc = "The mime insists there's booze in the glass. You're not so sure."
			if ("goldschlager")
				icon_state = "shotglassgold"
				name = "shot of goldschlager"
				desc = "Yup. You're officially a college girl."
			if ("cognac")
				icon_state = "shotglassbrown"
				name = "shot of cognac"
				desc = "You get the feeling this would piss off a rich person somewhere."
			if ("wine")
				icon_state = "shotglassred"
				name = "shot of wine"
				desc = "What kind of craven oaf would drink wine from a shot glass?"
			if ("blood")
				icon_state = "shotglassred"
				name = "shot of blood"
				desc = "If you close your eyes it sort of tastes like wine..."
			if ("liquidgibs")
				icon_state = "shotglassred"
				name = "shot of gibs"
				desc = "...Let's not talk about this."
			if ("absinthe")
				icon_state = "shotglassgreen"
				name = "shot of absinthe"
				desc = "I am stuck in the cycles of my guilt..."
			else
				icon_state = "shotglassbrown"
				name = "shot of... what?"
				desc = "You can't really tell what's in the glass."
	else
		icon_state = "shotglass"
		name = "shot glass"
		desc = "A shot glass - the universal symbol for bad decisions."
		return

// for /obj/machinery/vending/sovietsoda
/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/filled/New()
	..()
	on_reagent_change()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/filled/soda
	list_reagents = list("sodawater" = 50)

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/filled/cola
	list_reagents = list("cola" = 50)

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/attackby(obj/item/I, mob/user, params)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/egg)) //breaking eggs
		var/obj/item/weapon/reagent_containers/food/snacks/egg/E = I
		if(reagents)
			if(reagents.total_volume >= reagents.maximum_volume)
				user << "<span class='notice'>[src] is full.</span>"
			else
				user << "<span class='notice'>You break [E] in [src].</span>"
				reagents.add_reagent("eggyolk", 5)
				qdel(E)
			return
	else
		..()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/attack(obj/target, mob/user)
	if(user.a_intent == INTENT_HARM && ismob(target) && target.reagents && reagents.total_volume)
		target.visible_message("<span class='danger'>[user] splashes the contents of [src] onto [target]!</span>", \
						"<span class='userdanger'>[user] splashes the contents of [src] onto [target]!</span>")
		add_logs(user, target, "splashed", src)
		reagents.reaction(target, TOUCH)
		reagents.clear_reagents()
		return
	..()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/afterattack(obj/target, mob/user, proximity)
	if((!proximity) || !check_allowed_items(target,target_self=1))
		return

	else if(reagents.total_volume && user.a_intent == INTENT_HARM)
		user.visible_message("<span class='danger'>[user] splashes the contents of [src] onto [target]!</span>", \
							"<span class='notice'>You splash the contents of [src] onto [target].</span>")
		reagents.reaction(target, TOUCH)
		reagents.clear_reagents()
		return
	..()

