

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass
	name = "drinking glass"
	desc = "Your standard drinking glass."
	icon_state = "glass_empty"
	isGlass = 1
	amount_per_transfer_from_this = 10
	volume = 50
	starting_materials = list(MAT_GLASS = 500)
	force = 5
	smashtext = ""  //due to inconsistencies in the names of the drinks just don't say anything
	smashname = "broken glass"
	melt_temperature = MELTPOINT_GLASS
	w_type=RECYK_GLASS

//removed smashing - now uses smashing proc from drinks.dm - Hinaichigo
//also now produces a broken glass when smashed instead of just a shard

	on_reagent_change()
		..()
		/*if(reagents.reagent_list.len > 1 )
			icon_state = "glass_brown"
			name = "Glass of Hooch"
			desc = "Two or more drinks, mixed together."*/
		/*else if(reagents.reagent_list.len == 1)
			for(var/datum/reagent/R in reagents.reagent_list)
				switch(R.id)*/
		viewcontents = 1
		overlays.len = 0
		if (reagents.reagent_list.len > 0)
			//mrid = R.get_master_reagent_id()
			flammable = 0
			if(!molotov)
				lit = 0
			light_color = null
			set_light(0)
			isGlass = 1
			switch(reagents.get_master_reagent_id())
				if(BEER)
					icon_state = "beerglass"
					name = "beer glass"
					desc = "A freezing pint of beer."
				if(BEER2)
					icon_state = "beerglass"
					name = "beer glass"
					desc = "A freezing pint of beer."
				if(ALE)
					icon_state = "aleglass"
					name = "ale glass"
					desc = "A freezing pint of delicious ale."
				if(MILK)
					icon_state = "glass_white"
					name = "glass of milk"
					desc = "White and nutritious goodness!"
				if(CREAM)
					icon_state  = "glass_white"
					name = "glass of cream"
					desc = "Ewwww..."
				if("chocolate")
					icon_state  = "chocolateglass"
					name = "glass of chocolate"
					desc = "Tasty."
				if(LEMONJUICE)
					icon_state  = "lemonglass"
					name = "glass of lemonjuice"
					desc = "Sour..."
				if(COLA)
					icon_state  = "glass_brown"
					name = "glass of Space Cola"
					desc = "A glass of refreshing Space Cola."
				if(NUKA_COLA)
					icon_state = "nuka_colaglass"
					name = "\improper Nuka Cola"
					desc = "Don't cry, Don't raise your eye, It's only nuclear wasteland"
				if(ORANGEJUICE)
					icon_state = "glass_orange"
					name = "glass of orange juice"
					desc = "Vitamins! Yay!"
				if(TOMATOJUICE)
					icon_state = "glass_red"
					name = "glass of tomato juice"
					desc = "Are you sure this is tomato juice?"
				if(BLOOD)
					icon_state = "glass_red"
					name = "glass of tomato juice"
					desc = "Are you sure this is tomato juice?"
				if(LIMEJUICE)
					icon_state = "glass_green"
					name = "glass of lime juice"
					desc = "A glass of sweet-sour lime juice."
				if(WHISKEY)
					icon_state = "whiskeyglass"
					name = "glass of whiskey"
					desc = "The silky, smokey whiskey goodness inside the glass makes the drink look very classy."
				if(GIN)
					icon_state = "ginvodkaglass"
					name = "glass of gin"
					desc = "A crystal clear glass of Griffeater gin."
				if(VODKA)
					icon_state = "ginvodkaglass"
					name = "glass of vodka"
					desc = "The glass contain wodka. Xynta."
				if(SAKE)
					icon_state = "ginvodkaglass"
					name = "glass of sake"
					desc = "A glass of Sake."
				if(GOLDSCHLAGER)
					icon_state = "ginvodkaglass"
					name = "glass of Goldschlager"
					desc = "100 proof that teen girls will drink anything with gold in it."
				if(WINE)
					icon_state = "wineglass"
					name = "glass of wine"
					desc = "A very classy looking drink."
				if(COGNAC)
					icon_state = "cognacglass"
					name = "glass of cognac"
					desc = "Damn, you feel like some kind of French aristocrat just by holding this."
				if (KAHLUA)
					icon_state = "kahluaglass"
					name = "glass of RR coffee liquor"
					desc = "DAMN, THIS THING LOOKS ROBUST"
				if(VERMOUTH)
					icon_state = "vermouthglass"
					name = "glass of vermouth"
					desc = "You wonder why you're even drinking this straight."
				if(TEQUILA)
					icon_state = "tequilaglass"
					name = "glass of tequila"
					desc = "Now all that's missing is the weird colored shades!"
				if(PATRON)
					icon_state = "patronglass"
					name = "glass of Patron"
					desc = "Drinking Patron in the bar, with all the subpar ladies."
				if(RUM)
					icon_state = "rumglass"
					name = "glass of rum"
					desc = "Now you want to Pray for a pirate suit, don't you?"
				if(GINTONIC)
					icon_state = "gintonicglass"
					name = "gin and tonic"
					desc = "A mild but still great cocktail. Drink up, like a true Englishman."
				if(WHISKEYCOLA)
					icon_state = "whiskeycolaglass"
					name = "whiskey cola"
					desc = "An innocent-looking mixture of cola and Whiskey. Delicious."
				if(WHITERUSSIAN)
					icon_state = "whiterussianglass"
					name = "\improper White Russian"
					desc = "A very nice looking drink. But that's just, like, your opinion, man."
				if(SCREWDRIVERCOCKTAIL)
					icon_state = "screwdriverglass"
					name = "\improper Screwdriver"
					desc = "A simple, yet superb mixture of Vodka and orange juice. Just the thing for the tired engineer."
				if(BLOODYMARY)
					icon_state = "bloodymaryglass"
					name = "\improper Bloody Mary"
					desc = "Tomato juice, mixed with Vodka and a lil' bit of lime. Tastes like liquid murder."
				if(MARTINI)
					icon_state = "martiniglass"
					name = "classic martini"
					desc = "Damn, the bartender even stirred it, not shook it."
				if(VODKAMARTINI)
					icon_state = "martiniglass"
					name = "vodka martini"
					desc ="A bastardisation of the classic martini. Still great."
				if(GARGLEBLASTER)
					icon_state = "gargleblasterglass"
					name = "\improper Pan-Galactic Gargle Blaster"
					desc = "Does... does this mean that Arthur and Ford are on the station? Oh joy."
				if(BRAVEBULL)
					icon_state = "bravebullglass"
					name = "\improper Brave Bull"
					desc = "Tequila and coffee liquor, brought together in a mouthwatering mixture. Drink up."
				if(TEQUILASUNRISE)
					icon_state = "tequilasunriseglass"
					name = "\improper Tequila Sunrise"
					desc = "Oh great, now you feel nostalgic about sunrises back on Terra..."
				if(TOXINSSPECIAL)
					icon_state = "toxinsspecialglass"
					name = "\improper Toxins Special"
					desc = "Whoah, this thing is on FIRE!"
				if(BEEPSKYSMASH)
					icon_state = "beepskysmashglass"
					name = "\improper Beepsky Smash"
					desc = "Heavy, hot and strong. Just like the Iron fist of the LAW."
				if(DOCTORSDELIGHT)
					icon_state = "doctorsdelightglass"
					name = "\improper Doctor's Delight"
					desc = "A healthy mixture of juices, guaranteed to keep you healthy until the next toolboxing takes place."
				if(MANLYDORF)
					icon_state = "manlydorfglass"
					name = "The Manly Dorf"
					desc = "A manly concotion made from Ale and Beer. Intended for true men only."
				if(IRISHCREAM)
					icon_state = "irishcreamglass"
					name = "\improper Irish Cream"
					desc = "It's cream, mixed with whiskey. What else would you expect from the Irish?"
				if(CUBALIBRE)
					icon_state = "cubalibreglass"
					name = "\improper Cuba Libre"
					desc = "A classic mix of rum and cola."
				if(B52)
					icon_state = "b52glass"
					name = "\improper B-52"
					desc = "Kahlua, Irish Cream, and congac. You will get bombed."
					light_color = "#000080"
					if(!lit)
						flammable = 1
				if(ATOMICBOMB)
					icon_state = "atomicbombglass"
					name = "\improper Atomic Bomb"
					desc = "Nanotrasen cannot take legal responsibility for your actions after imbibing."
				if(LONGISLANDICEDTEA)
					icon_state = "longislandicedteaglass"
					name = "\improper Long Island Iced Tea"
					desc = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
				if(THREEMILEISLAND)
					icon_state = "threemileislandglass"
					name = "\improper Three Mile Island Ice Tea"
					desc = "A glass of this is sure to prevent a meltdown."
				if(MARGARITA)
					icon_state = "margaritaglass"
					name = "\improper Margarita"
					desc = "On the rocks with salt on the rim. Arriba~!"
				if(BLACKRUSSIAN)
					icon_state = "blackrussianglass"
					name = "\improper Black Russian"
					desc = "For the lactose-intolerant. Still as classy as a White Russian."
				if(VODKATONIC)
					icon_state = "vodkatonicglass"
					name = "vodka and tonic"
					desc = "For when a gin and tonic isn't Russian enough."
				if(MANHATTAN)
					icon_state = "manhattanglass"
					name = "\improper Manhattan"
					desc = "The Detective's undercover drink of choice. He never could stomach gin..."
				if("manhattan_proj")
					icon_state = "proj_manhattanglass"
					name = "\improper Manhattan Project"
					desc = "A scienitst drink of choice, for thinking how to blow up the station."
				if(GINFIZZ)
					icon_state = "ginfizzglass"
					name = "\improper Gin Fizz"
					desc = "Refreshingly lemony, deliciously dry."
				if(IRISHCOFFEE)
					icon_state = "irishcoffeeglass"
					name = "\improper Irish Coffee"
					desc = "Coffee and alcohol. More fun than a Mimosa to drink in the morning."
				if(HOOCH)
					icon_state = "glass_brown2"
					name = "\improper Hooch"
					desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
				if(WHISKEYSODA)
					icon_state = "whiskeysodaglass2"
					name = "whiskey soda"
					desc = "Ultimate refreshment."
				if(TONIC)
					icon_state = "glass_clear"
					name = "glass of tonic water"
					desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
				if(SODAWATER)
					icon_state = "glass_clear"
					name = "glass of soda water"
					desc = "Soda water. Why not make a scotch and soda?"
				if(WATER)
					icon_state = "glass_clear"
					name = "glass of water"
					desc = "The father of all refreshments."
				if(SPACEMOUNTAINWIND)
					icon_state = "Space_mountain_wind_glass"
					name = "glass of Space Mountain Wind"
					desc = "Space Mountain Wind. As you know, there are no mountains in space, only wind."
				if(THIRTEENLOKO)
					icon_state = "thirteen_loko_glass"
					name = "glass of Thirteen Loko"
					desc = "This is a glass of Thirteen Loko, it appears to be of the highest quality. The drink, not the glass."
				if(DR_GIBB)
					icon_state = "dr_gibb_glass"
					name = "glass of Dr. Gibb"
					desc = "Dr. Gibb. Not as dangerous as the name might imply."
				if(SPACE_UP)
					icon_state = "space-up_glass"
					name = "glass of Space-up"
					desc = "Space-up. It helps keep your cool."
				if(MOONSHINE)
					icon_state = "glass_clear"
					name = "\improper Moonshine"
					desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
				if(SOYMILK)
					icon_state = "glass_white"
					name = "glass of soy milk"
					desc = "White and nutritious soy goodness!"
				if(BERRYJUICE)
					icon_state = BERRYJUICE
					name = "glass of berry juice"
					desc = "Berry juice. Or maybe its jam. Who cares?"
				if(POISONBERRYJUICE)
					icon_state = POISONBERRYJUICE
					name = "glass of poison berry juice"
					desc = "A glass of deadly juice."
				if(CARROTJUICE)
					icon_state = CARROTJUICE
					name = "glass of  carrot juice"
					desc = "It is just like a carrot but without crunching."
				if(BANANA)
					icon_state = BANANA
					name = "glass of banana juice"
					desc = "The raw essence of a banana. HONK"
				if(BAHAMA_MAMA)
					icon_state = BAHAMA_MAMA
					name = "\improper Bahama Mama"
					desc = "Tropic cocktail."
				if(SINGULO)
					icon_state = SINGULO
					name = "\improper Singulo"
					desc = "A blue-space beverage."
				if(ALLIESCOCKTAIL)
					icon_state = ALLIESCOCKTAIL
					name = "\improper Allies Cocktail"
					desc = "A drink made from your allies."
				if(ANTIFREEZE)
					icon_state = ANTIFREEZE
					name = "\improper Anti-freeze"
					desc = "The ultimate refreshment."
				if(BAREFOOT)
					icon_state = "b&p"
					name = "\improper Barefoot"
					desc = "Barefoot and pregnant."
				if(DEMONSBLOOD)
					icon_state = DEMONSBLOOD
					name = "\improper Demon's Blood"
					desc = "Just looking at this thing makes the hair at the back of your neck stand up."
				if(BOOGER)
					icon_state = BOOGER
					name = "\improper Booger"
					desc = "Ewww..."
				if(SNOWWHITE)
					icon_state = SNOWWHITE
					name = "\improper Snow White"
					desc = "A cold refreshment."
				if(ALOE)
					icon_state = ALOE
					name = ALOE
					desc = "Very, very, very good."
				if(ANDALUSIA)
					icon_state = ANDALUSIA
					name = "\improper Andalusia"
					desc = "A nice, strange named drink."
				if(SBITEN)
					icon_state = "sbitenglass"
					name = "\improper Sbiten"
					desc = "A spicy mix of vodka and spice. Very hot."
				if(RED_MEAD)
					icon_state = "red_meadglass"
					name = "red mead"
					desc = "A True Vikings Beverage, though its color is strange."
				if(MEAD)
					icon_state = "meadglass"
					name = MEAD
					desc = "A Vikings Beverage, though a cheap one."
				if(ICED_BEER)
					icon_state = "iced_beerglass"
					name = "iced Beer"
					desc = "A beer so frosty, the air around it freezes."
				if(GROG)
					icon_state = "grogglass"
					name = GROG
					desc = "A fine and cepa drink for Space."
				if(SOY_LATTE)
					icon_state = SOY_LATTE
					name = "soy latte"
					desc = "A nice and refrshing beverage while you are reading."
				if(CAFE_LATTE)
					icon_state = CAFE_LATTE
					name = "cafe latte"
					desc = "A nice, strong and refreshing beverage while you are reading."
				if(ACIDSPIT)
					icon_state = "acidspitglass"
					name = "\improper Acid Spit"
					desc = "A drink from Nanotrasen. Made from live aliens."
				if(AMASEC)
					icon_state = "amasecglass"
					name = "\improper Amasec"
					desc = "Always handy before COMBAT!!!"
				if(NEUROTOXIN)
					icon_state = "neurotoxinglass"
					name = "\improper Neurotoxin"
					desc = "A drink that is guaranteed to knock you silly."
				if(HIPPIESDELIGHT)
					icon_state = "hippiesdelightglass"
					name = "\improper Hippie's Delight"
					desc = "A drink enjoyed by people during the 1960's."
				if(BANANAHONK)
					icon_state = "bananahonkglass"
					name = "\improper Banana Honk"
					desc = "A drink from banana heaven."
				if(SILENCER)
					icon_state = "silencerglass"
					name = "\improper Silencer"
					desc = "A drink from mime heaven."
				if(NOTHING)
					icon_state = NOTHING
					name = NOTHING
					desc = "Absolutely nothing."
				if(DEVILSKISS)
					icon_state = DEVILSKISS
					name = "\improper Devils Kiss"
					desc = "Creepy time!"
				if(CHANGELINGSTING)
					icon_state = CHANGELINGSTING
					name = "\improper Changeling Sting"
					desc = "A stingy drink."
				if(IRISHCARBOMB)
					icon_state = IRISHCARBOMB
					name = "\improper Irish Car Bomb"
					desc = "An irish car bomb."
				if(SYNDICATEBOMB)
					icon_state = SYNDICATEBOMB
					name = "\improper Syndicate Bomb"
					desc = "A syndicate bomb."
					isGlass = 0//blablabla hidden features, blablabla joke material
				if(ERIKASURPRISE)
					icon_state = ERIKASURPRISE
					name = "\improper Erika Surprise"
					desc = "The surprise is, it's green!"
				if(DRIESTMARTINI)
					icon_state = "driestmartiniglass"
					name = "\improper Driest Martini"
					desc = "Only for the experienced. You think you see sand floating in the glass."
				if(ICE)
					icon_state = "iceglass"
					name = "glass of ice"
					desc = "Generally, you're supposed to put something else in there too..."
				if(ICECOFFEE)
					icon_state = "icedcoffeeglass"
					name = "iced Coffee"
					desc = "A drink to perk you up and refresh you!"
				if(COFFEE)
					icon_state = "glass_brown"
					name = "glass of coffee"
					desc = "Don't drop it, or you'll send scalding liquid and glass shards everywhere."
				if(BILK)
					icon_state = "glass_brown"
					name = "glass of bilk"
					desc = "A brew of milk and beer. For those alcoholics who fear osteoporosis."
				if(FUEL)
					icon_state = "dr_gibb_glass"
					name = "glass of welder fuel"
					desc = "Unless you are an industrial tool, this is probably not safe for consumption."
				if(BROWNSTAR)
					icon_state = BROWNSTAR
					name = "\improper Brown Star"
					desc = "Its not what it sounds like..."
				if(ICETEA)
					icon_state = ICETEA
					name = "iced tea"
					desc = "No relation to a certain rap artist/ actor."
				if(ARNOLDPALMER)
					icon_state = ARNOLDPALMER
					name = "Arnold Palmer"
					desc = "Known as half and half to some.  A mix of ice tea and lemonade"
				if(MILKSHAKE)
					icon_state = MILKSHAKE
					name = MILKSHAKE
					desc = "Glorious brainfreezing mixture."
				if(LEMONADE)
					icon_state = LEMONADE
					name = LEMONADE
					desc = "Oh the nostalgia..."
				if(KIRASPECIAL)
					icon_state = KIRASPECIAL
					name = "\improper Kira Special"
					desc = "Long live the guy who everyone had mistaken for a girl. Baka!"
				if(REWRITER)
					icon_state = REWRITER
					name = "\improper Rewriter"
					desc = "The secert of the sanctuary of the Libarian..."
				if(PINACOLADA)
					icon_state = PINACOLADA
					name = "\improper Pina Colada"
					desc = "If you like this and getting caught in the rain, come with me and escape."
				else
					icon_state ="glass_colour"
					get_reagent_name(src)
					var/image/filling = image('icons/obj/reagentfillings.dmi', src, "glass")
					filling.icon += mix_color_from_reagents(reagents.reagent_list)
					filling.alpha = mix_alpha_from_reagents(reagents.reagent_list)
					overlays += filling



			if(reagents.has_reagent(BLACKCOLOR))
				icon_state ="blackglass"
				name = "international drink of mystery"
				desc = "The identity of this drink has been concealed for its protection."
				viewcontents = 0
		else
			icon_state = "glass_empty"
			name = "drinking glass"
			desc = "Your standard drinking glass."
			return

// for /obj/machinery/vending/sovietsoda
/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/soda
	New()
		..()
		reagents.add_reagent(SODAWATER, 50)
		on_reagent_change()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/cola
	New()
		..()
		reagents.add_reagent(COLA, 50)
		on_reagent_change()

// Cafe Stuff. Mugs act the same as drinking glasses, but they don't break when thrown.

/obj/item/weapon/reagent_containers/food/drinks/mug
	name = "mug"
	desc = "A simple mug."
	icon = 'icons/obj/cafe.dmi'
	icon_state = "mug_empty"
	isGlass = 0
	amount_per_transfer_from_this = 10
	volume = 30
	starting_materials = list(MAT_IRON = 500)

	on_reagent_change()

		if (reagents.reagent_list.len > 0)

			switch(reagents.get_master_reagent_id())
				if(TEA)
					icon_state = TEA
					name = "Tea"
					desc = "A warm mug of tea."
				if(GREENTEA)
					icon_state = GREENTEA
					name = "Green Tea"
					desc = "Green Tea served in a traditional Japanese tea cup, just like in your Chinese cartoons!"
				if(REDTEA)
					icon_state = REDTEA
					name = "Red Tea"
					desc = "Red Tea served in a traditional Chinese tea cup, just like in your Malaysian movies!"
				if(ACIDTEA)
					icon_state = ACIDTEA
					name = "Earl's Grey Tea"
					desc = "A sizzling mug of tea made just for Greys."
				if(YINYANG)
					icon_state = YINYANG
					name = "Zen Tea"
					desc = "Enjoy inner peace and ignore the watered down taste"
				if(DANTEA)
					icon_state = DANTEA
					name = "Discount Dans Green Flavor Tea"
					desc = "Tea probably shouldn't be sizzling like that..."
				if(SINGULARITEA)
					icon_state = SINGULARITEA
					name = "Singularitea"
					desc = "Brewed under intense radiation to be extra flavorful!"
				if(MINT)
					icon_state = MINT
					name = "Groans Tea: Minty Delight Flavor"
					desc = "Groans knows mint might not be the kind of flavor our fans expect from us, but we've made sure to give it that patented Groans zing."
				if(CHAMOMILE)
					icon_state = CHAMOMILE
					name = "Groans Tea: Chamomile Flavor"
					desc = "Groans presents the perfect cure for insomnia; Chamomile!"
				if(EXCHAMOMILE)
					icon_state = EXCHAMOMILE
					name = "Groans Banned Tea: EXTREME Chamomile Flavor"
					desc = "Banned literally everywhere."
				if(FANCYDAN)
					icon_state = FANCYDAN
					name = "Groans Banned Tea: Fancy Dan Flavor"
					desc = "Banned literally everywhere."
				if(GYRO)
					icon_state = GYRO
					name = "Gyro"
					desc = "Nyo ho ho~"
				if(CHIFIR)
					icon_state = CHIFIR
					name = "Chifir"
					desc = "Russian style of tea, not for those with weak stomachs."
				if(PLASMATEA)
					icon_state = PLASMATEA
					name = "Plasma Pekoe"
					desc = "You can practically taste the science, or maybe that's just the horrible plasma burns."
				if(COFFEE)
					icon_state = COFFEE
					name = "Coffee"
					desc = "A warm mug of coffee."
				if(CAFE_LATTE)
					icon_state = "latte"
					name = "Latte"
					desc = "Coffee made with espresso and milk."
				if(SOY_LATTE)
					icon_state = "soylatte"
					name = "Soy Latte"
					desc = "Latte made with soy milk."
				if(ESPRESSO)
					icon_state = ESPRESSO
					name = "Espresso"
					desc = "Coffee made with water."
				if(CAPPUCCINO)
					icon_state = CAPPUCCINO
					name = "Cappuccino"
					desc = "coffee made with espresso, milk, and steamed milk."
				if(DOPPIO)
					icon_state = DOPPIO
					name = "Doppio"
					desc = "Ring ring ring"
				if(TONIO)
					icon_state = TONIO
					name = "Tonio"
					desc = "Delicious, and it'll help you out if you get in a Jam."
				if(PASSIONE)
					icon_state = PASSIONE
					name = "Passione"
					desc = "Sometimes referred to as a 'Venti Aureo'"
				if(SECCOFFEE)
					icon_state = SECCOFFEE
					name = "Wake up call"
					desc = "The perfect start for any Sec officer's day."
				if(MEDCOFFEE)
					icon_state = MEDCOFFEE
					name = "Lifeline"
					desc = "Some days, the only thing that keeps you going is cryo and caffeine."
				if(DETCOFFEE)
					icon_state = DETCOFFEE
					name = "Joe"
					desc = "The lights, the smoke, the grime, the station itself felt alive that day as I stepped into my office, mug in hand. It was another one of those days. Some Nurse got smoked in one of the tunnels, and it came down to me to catch the guy did it. I got up to close the blinds of my office, when an officer burst through my door. There had been another one offed in the tunnels, this time an assistant. I grumbled and downed some of my joe. It was bitter, tasteless, but it was what kept me going. I remember back when I was a rookie, this stuff used to taste so great to me. I guess that's just another sign of how this station changes people. I put my mug back down on my desk, dusted off my jacket, and lit my last cigar. I checked to make sure my faithful revolver was loaded, and stepped out, back into the cold halls of the station."
				if(ETANK)
					icon_state = ETANK
					name = "Recharger"
					desc = "Helps you get back on your feet after a long day of robot maintenance. Can also be used as a substitute for motor oil."
				if(GREYTEA)
					icon_state = GREYTEA
					name = "Tide"
					desc = "This probably shouldn't be considered tea..."





				else
					icon_state ="mug_what"
					name = "mug of ..something?"
					desc = "You aren't really sure what this is."
		else
			icon_state = "mug_empty"
			name = "mug"
			desc = "A simple mug."
			return