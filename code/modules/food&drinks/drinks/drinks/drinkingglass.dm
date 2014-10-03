

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass
	name = "glass"
	desc = "Your standard drinking glass."
	icon_state = "glass_empty"
	amount_per_transfer_from_this = 10
	volume = 50

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/on_reagent_change()
	if (reagents.reagent_list.len > 0)
		switch(reagents.get_master_reagent_id())
			if("beer")
				icon_state = "beerglass"
				name = "glass of beer"
				desc = "A freezing pint of beer"
			if("beer2")
				icon_state = "beerglass"
				name = "glass of beer"
				desc = "A freezing pint of beer"
			if("greenbeer")
				icon_state = "greenbeerglass"
				name = "glass of green beer"
				desc = "A freezing pint of green beer. Festive."
			if("ale")
				icon_state = "aleglass"
				name = "glass of ale"
				desc = "A freezing pint of delicious Ale"
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
				desc = "Tasty"
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
				desc = "A glass of refreshing Space Cola"
			if("nuka_cola")
				icon_state = "nuka_colaglass"
				name = "Nuka Cola"
				desc = "Don't cry, Don't raise your eye, It's only nuclear wasteland"
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
				desc = "100 proof that teen girls will drink anything with gold in it."
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
				desc = "DAMN, THIS THING LOOKS ROBUST"
			if("vermouth")
				icon_state = "vermouthglass"
				name = "glass of vermouth"
				desc = "You wonder why you're even drinking this straight."
			if("tequilla")
				icon_state = "tequillaglass"
				name = "glass of tequilla"
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
				desc = "Does... does this mean that Arthur and Ford are on the station? Oh joy."
			if("bravebull")
				icon_state = "bravebullglass"
				name = "Brave Bull"
				desc = "Tequilla and Coffee liquor, brought together in a mouthwatering mixture. Drink up."
			if("tequillasunrise")
				icon_state = "tequillasunriseglass"
				name = "Tequilla Sunrise"
				desc = "Oh great, now you feel nostalgic about sunrises back on Terra..."
			if("toxinsspecial")
				icon_state = "toxinsspecialglass"
				name = "Toxins Special"
				desc = "Whoah, this thing is on FIRE"
			if("beepskysmash")
				icon_state = "beepskysmashglass"
				name = "Beepsky Smash"
				desc = "Heavy, hot and strong. Just like the Iron fist of the LAW."
			if("doctorsdelight")
				icon_state = "doctorsdelightglass"
				name = "Doctor's Delight"
				desc = "A healthy mixture of juices, guaranteed to keep you healthy until the next toolboxing takes place."
			if("manlydorf")
				icon_state = "manlydorfglass"
				name = "The Manly Dorf"
				desc = "A manly concotion made from Ale and Beer. Intended for true men only."
			if("irishcream")
				icon_state = "irishcreamglass"
				name = "Irish Cream"
				desc = "It's cream, mixed with whiskey. What else would you expect from the Irish?"
			if("cubalibre")
				icon_state = "cubalibreglass"
				name = "Cuba Libre"
				desc = "A classic mix of rum and cola."
			if("b52")
				icon_state = "b52glass"
				name = "B-52"
				desc = "Kahlua, Irish Cream, and cognac. You will get bombed."
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
				desc = "A scientist drink of choice, for thinking how to blow up the station."
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
				name = "Glass of Tonic Water"
				desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
			if("sodawater")
				icon_state = "glass_clear"
				name = "Glass of Soda Water"
				desc = "Soda water. Why not make a scotch and soda?"
			if("water")
				icon_state = "glass_clear"
				name = "Glass of Water"
				desc = "The father of all refreshments."
			if("spacemountainwind")
				icon_state = "Space_mountain_wind_glass"
				name = "Glass of Space Mountain Wind"
				desc = "Space Mountain Wind. As you know, there are no mountains in space, only wind."
			if("thirteenloko")
				icon_state = "thirteen_loko_glass"
				name = "Glass of Thirteen Loko"
				desc = "This is a glass of Thirteen Loko, it appears to be of the highest quality. The drink, not the glass"
			if("dr_gibb")
				icon_state = "dr_gibb_glass"
				name = "Glass of Dr. Gibb"
				desc = "Dr. Gibb. Not as dangerous as the name might imply."
			if("space_up")
				icon_state = "space-up_glass"
				name = "Glass of Space-up"
				desc = "Space-up. It helps keep your cool."
			if("lemon_lime")
				icon_state = "glass_yellow"
				name = "Glass of Lemon-Lime"
				desc = "You're pretty certain a real fruit has never actually touched this."
			if("moonshine")
				icon_state = "glass_clear"
				name = "Moonshine"
				desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
			if("soymilk")
				icon_state = "glass_white"
				name = "Glass of soy milk"
				desc = "White and nutritious soy goodness!"
			if("berryjuice")
				icon_state = "berryjuice"
				name = "Glass of berry juice"
				desc = "Berry juice. Or maybe it's jam. Who cares?"
			if("poisonberryjuice")
				icon_state = "poisonberryjuice"
				name = "Glass of berry juice"
				desc = "Berry juice. Or maybe it's poison. Who cares?"
			if("carrotjuice")
				icon_state = "carrotjuice"
				name = "Glass of  carrot juice"
				desc = "It is just like a carrot but without crunching."
			if("banana")
				icon_state = "banana"
				name = "Glass of banana juice"
				desc = "The raw essence of a banana. HONK"
			if("bahama_mama")
				icon_state = "bahama_mama"
				name = "Bahama Mama"
				desc = "Tropic cocktail"
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
				desc = "Barefoot and pregnant"
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
				desc = "A nice, strange named drink."
			if("sbiten")
				icon_state = "sbitenglass"
				name = "Sbiten"
				desc = "A spicy mix of Vodka and Spice. Very hot."
			if("red_mead")
				icon_state = "red_meadglass"
				name = "Red Mead"
				desc = "A True Vikings Beverage, though its color is strange."
			if("mead")
				icon_state = "meadglass"
				name = "Mead"
				desc = "A Vikings Beverage, though a cheap one."
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
				desc = "A nice and refrshing beverage while you are reading."
			if("cafe_latte")
				icon_state = "cafe_latte"
				name = "Cafe Latte"
				desc = "A nice, strong and refreshing beverage while you are reading."
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
				desc = "A drink from mime Heaven."
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
				desc = "An irish car bomb."
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
				name = "Glass of ice"
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
				name = "Glass of coffee"
				desc = "Don't drop it, or you'll send scalding liquid and glass shards everywhere."
			if("tea")
				icon_state = "teaglass"
				name = "Glass of tea"
				desc = "Drinking it from here would not seem right."
			if("bilk")
				icon_state = "glass_brown"
				name = "Glass of bilk"
				desc = "A brew of milk and beer. For those alcoholics who fear osteoporosis."
			if("fuel")
				icon_state = "dr_gibb_glass"
				name = "Glass of welder fuel"
				desc = "Unless you are an industrial tool, this is probably not safe for consumption."
			else
				icon_state ="glass_brown"
				name = "Glass of ..what?"
				desc = "You can't really tell what this is."
	else
		icon_state = "glass_empty"
		name = "Drinking glass"
		desc = "Your standard drinking glass"
		return

// for /obj/machinery/vending/sovietsoda
/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/soda
	New()
		..()
		reagents.add_reagent("sodawater", 50)
		on_reagent_change()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/cola
	New()
		..()
		reagents.add_reagent("cola", 50)
		on_reagent_change()

/obj/item/weapon/reagent_containers/food/drinks/fancy
	name = "wine glass"
	desc = "Incredibly classy."
	icon_state = "wineglass"
	amount_per_transfer_from_this = 10
	volume = 50

/obj/item/weapon/reagent_containers/food/drinks/fancy/update_icon()
	overlays.Cut()

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)		filling.icon_state = "[icon_state]-10"
			if(10 to 24) 	filling.icon_state = "[icon_state]10"
			if(25 to 49)	filling.icon_state = "[icon_state]25"
			if(50 to 74)	filling.icon_state = "[icon_state]50"
			if(75 to 79)	filling.icon_state = "[icon_state]75"
			if(80 to 90)	filling.icon_state = "[icon_state]80"
			if(91 to INFINITY)	filling.icon_state = "[icon_state]100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling


/obj/item/weapon/reagent_containers/food/drinks/fancy/cocktail
	name = "cocktail glass"
	desc = "The olive isn't real, it's just wax!"
	icon_state = "cocktailglass"
	amount_per_transfer_from_this = 10
	volume = 40

/obj/item/weapon/reagent_containers/food/drinks/fancy/cocktail/update_icon()
	overlays.Cut()

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 29)		filling.icon_state = "[icon_state]-10"
			if(30 to 59) 	filling.icon_state = "[icon_state]30"
			if(60 to 99)	filling.icon_state = "[icon_state]60"
			if(100 to INFINITY)	filling.icon_state = "[icon_state]100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

/obj/item/weapon/reagent_containers/food/drinks/fancy/beer
	name = "beer mug"
	desc = "Chug it good!"
	icon_state = "beerglass"
	amount_per_transfer_from_this = 10
	volume = 50

/obj/item/weapon/reagent_containers/food/drinks/fancy/beer/junked
	icon_state = "beerglass-junked"

/obj/item/weapon/reagent_containers/food/drinks/fancy/beer/update_icon()
	overlays.Cut()

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)		filling.icon_state = "beerglass-10"
			if(10 to 19) 	filling.icon_state = "beerglass10"
			if(20 to 29)	filling.icon_state = "beerglass20"
			if(30 to 39)	filling.icon_state = "beerglass30"
			if(40 to 49)	filling.icon_state = "beerglass40"
			if(50 to 59)	filling.icon_state = "beerglass50"
			if(60 to 69) 	filling.icon_state = "beerglass60"
			if(70 to 79)	filling.icon_state = "beerglass70"
			if(80 to 89)	filling.icon_state = "beerglass80"
			if(90 to 94)	filling.icon_state = "beerglass90"
			if(95 to 99)	filling.icon_state = "beerglass95"
			if(100 to INFINITY)	filling.icon_state = "beerglass100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

/obj/item/weapon/reagent_containers/food/drinks/fancy/shot
	name = "shot glass"
	desc = "Another shot of whiskey!"
	icon_state = "shotglass"
	amount_per_transfer_from_this = 10
	volume = 10

/obj/item/weapon/reagent_containers/food/drinks/fancy/shot/junked
	icon_state = "shotglass-junked"

/obj/item/weapon/reagent_containers/food/drinks/fancy/shot/update_icon()
	overlays.Cut()

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)		filling.icon_state = "shotglass-10"
			if(10 to 19) 	filling.icon_state = "shotglass10"
			if(20 to 29)	filling.icon_state = "shotglass20"
			if(30 to 39)	filling.icon_state = "shotglass30"
			if(40 to 49)	filling.icon_state = "shotglass40"
			if(50 to 59)	filling.icon_state = "shotglass50"
			if(60 to 69) 	filling.icon_state = "shotglass60"
			if(70 to 79)	filling.icon_state = "shotglass70"
			if(80 to 89)	filling.icon_state = "shotglass80"
			if(90 to 94)	filling.icon_state = "shotglass90"
			if(95 to 99)	filling.icon_state = "shotglass95"
			if(100 to INFINITY)	filling.icon_state = "shotglass100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

/obj/item/weapon/reagent_containers/food/drinks/fancy/soda
	name = "soda bottle"
	desc = "A glass soda bottle."
	icon_state = "sodabottle"
	amount_per_transfer_from_this = 10
	volume = 60

/obj/item/weapon/reagent_containers/food/drinks/fancy/soda/junked
	icon_state = "sodabottle-junk"

/obj/item/weapon/reagent_containers/food/drinks/fancy/soda/update_icon()
	overlays.Cut()

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)		filling.icon_state = "sodabottle-10"
			if(10 to 19) 	filling.icon_state = "sodabottle10"
			if(20 to 49)	filling.icon_state = "sodabottle20"
			if(50 to 59)	filling.icon_state = "sodabottle50"
			if(60 to 69) 	filling.icon_state = "sodabottle60"
			if(70 to 79)	filling.icon_state = "sodabottle70"
			if(80 to 89)	filling.icon_state = "sodabottle80"
			if(90 to 94)	filling.icon_state = "sodabottle90"
			if(95 to 99)	filling.icon_state = "sodabottle95"
			if(100 to INFINITY)	filling.icon_state = "sodabottle100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

/obj/item/weapon/reagent_containers/food/drinks/fancy/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/fancy/pickup(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/fancy/dropped(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/fancy/attack_hand()
	..()
	update_icon()