//How I'm laying this out is in a much more painless way than giving every single food and drink it's own export datum.
//At the time of writing, we have some 200-300 food items overall, not counting custom foods. Let's not think about custom foods.
//6 Tiers to start with, working from cheapest (Available roundstart) to most expensive (Has to be made with considerable luck and preperation.)

/datum/export/food
	cost = 10 // Default cost, Because something WILL get missed somewhere. Perhaps out of active ignorance or not.
	unit_name = ""
	message = ""
	export_types = list(/obj/item/reagent_containers/food/snacks)
	include_subtypes = TRUE
	exclude_types = list(/obj/item/reagent_containers/food/snacks/grown)


//Untiered: All the stuff you can make infinite amounts of.
/datum/export/food/none
	cost = 0 // Not worth the time to mass-produce.
	message = "of processed food"
	export_types = list(/obj/item/reagent_containers/food/snacks/lollipop,
	/obj/item/reagent_containers/food/snacks/gumball,
	/obj/item/reagent_containers/food/snacks/cookie,
	/obj/item/reagent_containers/food/snacks/grown)//No fields of money trees.
	include_subtypes = TRUE

//Tier 1: Junk Food.
//If the chef can just mass-purchase these for sale, then NT's not going to pay anywhere need retail for these.
/datum/export/food/junk
	cost = 6 // Default cost, just in case something gets missed somewhere.
	message = "of junk food"
	export_types = list(/obj/item/reagent_containers/food/snacks/candy,
		/obj/item/reagent_containers/food/snacks/sosjerky,
		/obj/item/reagent_containers/food/snacks/chips,
		/obj/item/reagent_containers/food/snacks/no_raisin,
		/obj/item/reagent_containers/food/snacks/spacetwinkie,
		/obj/item/reagent_containers/food/snacks/cheesiehonkers,
		/obj/item/reagent_containers/food/snacks/energybar,
		/obj/item/reagent_containers/food/snacks/cornchips,
		/obj/item/reagent_containers/food/snacks/donut/plain,
		/obj/item/reagent_containers/food/snacks/donut/jelly/plain,
		/obj/item/reagent_containers/food/snacks/donkpocket,
		/obj/item/reagent_containers/food/snacks/cookie,
		/obj/item/reagent_containers/food/snacks/popcorn,
		/obj/item/reagent_containers/food/snacks/breadslice,	//same reasoning as cake slices, but breads are cheaper.
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/spiderleg,
		/obj/item/reagent_containers/food/snacks/boiledspiderleg,
		/obj/item/reagent_containers/food/snacks/spidereggs,
		/obj/item/reagent_containers/food/snacks/spiderling,
		/obj/item/reagent_containers/food/snacks/butter,
		/obj/item/reagent_containers/food/snacks/salami,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/watermelonslice,
		/obj/item/reagent_containers/food/snacks/candy_corn,
		/obj/item/reagent_containers/food/snacks/hugemushroomslice,
		/obj/item/reagent_containers/food/snacks/badrecipe,
		/obj/item/reagent_containers/food/snacks/tortilla,
		/obj/item/reagent_containers/food/snacks/pineappleslice,
		/obj/item/reagent_containers/food/snacks/tinychocolate,
		/obj/item/reagent_containers/food/snacks/fortunecookie,
		/obj/item/reagent_containers/food/snacks/pie/plain,
		/obj/item/reagent_containers/food/snacks/salad/ricebowl,
		/obj/item/reagent_containers/food/snacks/salad/boiledrice,
		/obj/item/reagent_containers/food/snacks/twobread,
		/obj/item/reagent_containers/food/snacks/soup/wish,
		/obj/item/reagent_containers/food/snacks/fries,
		/obj/item/reagent_containers/food/snacks/carrotfries,
		/obj/item/reagent_containers/food/snacks/tatortot,
		/obj/item/reagent_containers/food/snacks/boiledegg,
		/obj/item/reagent_containers/food/snacks/onionrings,
		/obj/item/reagent_containers/food/snacks/yakiimo,
		/obj/item/reagent_containers/food/snacks/spaghetti/boiledspaghetti,
		/obj/item/reagent_containers/food/snacks/faggot)
	include_subtypes = TRUE

//Tier 2: Fast Food.
//Most typically, 1-2 ingredients from a roundstart kitchen.
//Cost is pretty decent considering this is what most chefs will wind up cooking for the crew on a good day.
/datum/export/food/fast
	cost = 25
	message = "of average food"
	export_types = list(/obj/item/reagent_containers/food/snacks/store/bread/plain,
		/obj/item/reagent_containers/food/snacks/store/bread/meat,
		/obj/item/reagent_containers/food/snacks/store/bread/tofu,
		/obj/item/reagent_containers/food/snacks/baguette,
		/obj/item/reagent_containers/food/snacks/butterbiscuit,
		/obj/item/reagent_containers/food/snacks/burger/plain,
		/obj/item/reagent_containers/food/snacks/burger/human,
		/obj/item/reagent_containers/food/snacks/burger/tofu,
		/obj/item/reagent_containers/food/snacks/burger/brain,
		/obj/item/reagent_containers/food/snacks/burger/rat,
		/obj/item/reagent_containers/food/snacks/burger/empoweredburger,
		/obj/item/reagent_containers/food/snacks/burger/cheese,
		/obj/item/reagent_containers/food/snacks/sausage,
		/obj/item/reagent_containers/food/snacks/nugget,
		/obj/item/reagent_containers/food/snacks/canned/peaches/maint,
		/obj/item/reagent_containers/food/snacks/canned/beans,
		/obj/item/reagent_containers/food/snacks/kebab/human,
		/obj/item/reagent_containers/food/snacks/kebab/tofu,
		/obj/item/reagent_containers/food/snacks/kebab/rat,
		/obj/item/reagent_containers/food/snacks/kebab/monkey,
		/obj/item/reagent_containers/food/snacks/butter/on_a_stick,
		/obj/item/reagent_containers/food/snacks/friedegg,
		/obj/item/reagent_containers/food/snacks/icecreamsandwich,
		/obj/item/reagent_containers/food/snacks/spidereggsham,
		/obj/item/reagent_containers/food/snacks/pigblanket,
		/obj/item/reagent_containers/food/snacks/loadedbakedpotato,
		/obj/item/reagent_containers/food/snacks/pancakes,
		/obj/item/reagent_containers/food/snacks/store/cheesewheel,
		/obj/item/reagent_containers/food/snacks/cheesyfries,
		/obj/item/reagent_containers/food/snacks/eggplantparm,
		/obj/item/reagent_containers/food/snacks/roastparsnip,
		/obj/item/reagent_containers/food/snacks/nachos,
		/obj/item/reagent_containers/food/snacks/branrequests,
		/obj/item/reagent_containers/food/snacks/donut/meat,
		/obj/item/reagent_containers/food/snacks/donut/berry,
		/obj/item/reagent_containers/food/snacks/donut/jelly/berry,
		/obj/item/reagent_containers/food/snacks/donut/apple,
		/obj/item/reagent_containers/food/snacks/donut/jelly/apple,
		/obj/item/reagent_containers/food/snacks/waffles,
		/obj/item/reagent_containers/food/snacks/dankpocket,
		/obj/item/reagent_containers/food/snacks/pancakes,
		/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit,
		/obj/item/reagent_containers/food/snacks/cracker,
		/obj/item/reagent_containers/food/snacks/sugarcookie,
		/obj/item/reagent_containers/food/snacks/cherrycupcake,
		/obj/item/reagent_containers/food/snacks/candiedapple,
		/obj/item/reagent_containers/food/snacks/pie/cream,
		/obj/item/reagent_containers/food/snacks/pie/berryclafoutis,
		/obj/item/reagent_containers/food/snacks/pie/tofupie,
		/obj/item/reagent_containers/food/snacks/pizza/margherita,
		/obj/item/reagent_containers/food/snacks/pizza/meat,
		/obj/item/reagent_containers/food/snacks/pizza/mushroom,
		/obj/item/reagent_containers/food/snacks/salad/ricepudding,
		/obj/item/reagent_containers/food/snacks/salad/ricepork,
		/obj/item/reagent_containers/food/snacks/sandwich,
		/obj/item/reagent_containers/food/snacks/toastedsandwich,
		/obj/item/reagent_containers/food/snacks/grilledcheese,
		/obj/item/reagent_containers/food/snacks/butteredtoast,
		/obj/item/reagent_containers/food/snacks/spaghetti/pastatomato,
		/obj/item/reagent_containers/food/snacks/spaghetti/butternoodles,
		/obj/item/reagent_containers/food/snacks/spaghetti/meatballspaghetti,
		/obj/item/reagent_containers/food/snacks/soup/tomato,
		/obj/item/reagent_containers/food/snacks/soup/milo,
		/obj/item/reagent_containers/food/snacks/soup/mushroom,
		/obj/item/reagent_containers/food/snacks/soup/beet,
		/obj/item/reagent_containers/food/snacks/soup/sweetpotato,
		/obj/item/reagent_containers/food/snacks/soup/amanitajelly,
		/obj/item/reagent_containers/food/snacks/soup/onion,
		/obj/item/reagent_containers/food/snacks/cakeslice,			//A cake is worth more whole, not cut up.
		/obj/item/reagent_containers/food/snacks/store/cake/brain)

	include_subtypes = TRUE

//Tier 3:Rare Foods.
//May still be only a few ingredients, but may require some cooperation or prep-work to aquire.
//Each one sold should be a nice little profit.
/datum/export/food/rare
	cost = 50
	message = "of nice food"
	export_types = list(
		/obj/item/reagent_containers/food/snacks/syndicake,
		/obj/item/reagent_containers/food/snacks/store/bread/banana,
		/obj/item/reagent_containers/food/snacks/store/bread/spidermeat, //spiders show up often enough to warrent being here.
		/obj/item/reagent_containers/food/snacks/garlicbread,
		/obj/item/reagent_containers/food/snacks/butterdog,
		/obj/item/reagent_containers/food/snacks/burger/appendix,
		/obj/item/reagent_containers/food/snacks/burger/clown,
		/obj/item/reagent_containers/food/snacks/burger/mime,
		/obj/item/reagent_containers/food/snacks/burger/spell,
		/obj/item/reagent_containers/food/snacks/burger/bigbite,
		/obj/item/reagent_containers/food/snacks/burger/fivealarm,
		/obj/item/reagent_containers/food/snacks/burger/baseball,
		/obj/item/reagent_containers/food/snacks/burger/baconburger,
		/obj/item/reagent_containers/food/snacks/burger/crab,
		/obj/item/reagent_containers/food/snacks/burger/rib,
		/obj/item/reagent_containers/food/snacks/burger/mcguffin,
		/obj/item/reagent_containers/food/snacks/burger/chicken,
		/obj/item/reagent_containers/food/snacks/store/cake/cheese,
		/obj/item/reagent_containers/food/snacks/store/cake/carrot,
		/obj/item/reagent_containers/food/snacks/store/cake/apple,
		/obj/item/reagent_containers/food/snacks/store/cake/orange,
		/obj/item/reagent_containers/food/snacks/store/cake/lime,
		/obj/item/reagent_containers/food/snacks/store/cake/lemon,
		/obj/item/reagent_containers/food/snacks/store/cake/chocolate,
		/obj/item/reagent_containers/food/snacks/store/cake/pumpkinspice,
		/obj/item/reagent_containers/food/snacks/store/cake/pound_cake,
		/obj/item/reagent_containers/food/snacks/omelette,
		/obj/item/reagent_containers/food/snacks/spacefreezy,
		/obj/item/reagent_containers/food/snacks/sundae,
		/obj/item/reagent_containers/food/snacks/snowcones,
		/obj/item/reagent_containers/food/snacks/cornedbeef,
		/obj/item/reagent_containers/food/snacks/khinkali,
		/obj/item/reagent_containers/food/snacks/stewedsoymeat,
		/obj/item/reagent_containers/food/snacks/spiderlollipop,
		/obj/item/reagent_containers/food/snacks/chococoin,
		/obj/item/reagent_containers/food/snacks/fudgedice,
		/obj/item/reagent_containers/food/snacks/chocoorange,
		/obj/item/reagent_containers/food/snacks/burrito,
		/obj/item/reagent_containers/food/snacks/cheesynachos,
		/obj/item/reagent_containers/food/snacks/taco,
		/obj/item/reagent_containers/food/snacks/crab_rangoon,
		/obj/item/reagent_containers/food/snacks/donut/caramel,
		/obj/item/reagent_containers/food/snacks/donut/jelly/caramel,
		/obj/item/reagent_containers/food/snacks/donut/trumpet,
		/obj/item/reagent_containers/food/snacks/donut/jelly/trumpet,
		/obj/item/reagent_containers/food/snacks/donut/choco,
		/obj/item/reagent_containers/food/snacks/donut/jelly/choco,
		/obj/item/reagent_containers/food/snacks/muffin/berry,
		/obj/item/reagent_containers/food/snacks/soylentgreen,
		/obj/item/reagent_containers/food/snacks/soylenviridians,
		/obj/item/reagent_containers/food/snacks/poppypretzel,
		/obj/item/reagent_containers/food/snacks/hotdog,
		/obj/item/reagent_containers/food/snacks/khachapuri,
		/obj/item/reagent_containers/food/snacks/chococornet,
		/obj/item/reagent_containers/food/snacks/oatmealcookie,
		/obj/item/reagent_containers/food/snacks/raisincookie,
		/obj/item/reagent_containers/food/snacks/bluecherrycupcake,
		/obj/item/reagent_containers/food/snacks/honeybun,
		/obj/item/reagent_containers/food/snacks/pie/berryclafoutis,
		/obj/item/reagent_containers/food/snacks/pie/meatpie,
		/obj/item/reagent_containers/food/snacks/pie/amanita_pie,
		/obj/item/reagent_containers/food/snacks/pie/plump_pie,
		/obj/item/reagent_containers/food/snacks/pie/applepie,
		/obj/item/reagent_containers/food/snacks/pie/cherrypie,
		/obj/item/reagent_containers/food/snacks/pie/pumpkinpie,
		/obj/item/reagent_containers/food/snacks/pie/grapetart,
		/obj/item/reagent_containers/food/snacks/pie/berrytart,
		/obj/item/reagent_containers/food/snacks/pie/frostypie,
		/obj/item/reagent_containers/food/snacks/pizza/vegetable,
		/obj/item/reagent_containers/food/snacks/pizza/donkpocket,
		/obj/item/reagent_containers/food/snacks/pizza/dank,
		/obj/item/reagent_containers/food/snacks/pizza/pineapple,
		/obj/item/reagent_containers/food/snacks/salad/herbsalad,
		/obj/item/reagent_containers/food/snacks/salad/validsalad,
		/obj/item/reagent_containers/food/snacks/salad/oatmeal,
		/obj/item/reagent_containers/food/snacks/salad/fruit,
		/obj/item/reagent_containers/food/snacks/salad/jungle,
		/obj/item/reagent_containers/food/snacks/salad/citrusdelight,
		/obj/item/reagent_containers/food/snacks/salad/eggbowl,
		/obj/item/reagent_containers/food/snacks/jellysandwich,
		/obj/item/reagent_containers/food/snacks/notasandwich,
		/obj/item/reagent_containers/food/snacks/jelliedtoast,
		/obj/item/reagent_containers/food/snacks/soup/meatball,
		/obj/item/reagent_containers/food/snacks/soup/slime,
		/obj/item/reagent_containers/food/snacks/soup/vegetable,
		/obj/item/reagent_containers/food/snacks/soup/nettle,
		/obj/item/reagent_containers/food/snacks/soup/hotchili,
		/obj/item/reagent_containers/food/snacks/soup/monkeysdelight,
		/obj/item/reagent_containers/food/snacks/soup/spacylibertyduff,
		/obj/item/reagent_containers/food/snacks/soup/amanitajelly,
		/obj/item/reagent_containers/food/snacks/soup/sweetpotato,
		/obj/item/reagent_containers/food/snacks/spaghetti/copypasta,
		/obj/item/reagent_containers/food/snacks/spaghetti/spesslaw,
		/obj/item/reagent_containers/food/snacks/spaghetti/chowmein,
		/obj/item/reagent_containers/food/snacks/spaghetti/beefnoodle)
	include_subtypes = TRUE



//Tier 4:Exotic Foods.
//Themed foods that in most rounds requires botany or another department to go out on a limb for you. Contains most seafoods/exotic meats/unpopular foods.
//Each one sold should get you closer to buying something expensive.
/datum/export/food/exotic
	cost = 100
	message = "of exotic food"
	export_types = list(
		/obj/item/reagent_containers/food/snacks/store/bread/xenomeat,
		/obj/item/reagent_containers/food/snacks/store/bread/mimana,
		/obj/item/reagent_containers/food/snacks/burger/corgi,
		/obj/item/reagent_containers/food/snacks/burger/fish,
		/obj/item/reagent_containers/food/snacks/burger/roburger,
		/obj/item/reagent_containers/food/snacks/burger/xeno,
		/obj/item/reagent_containers/food/snacks/burger/bearger,
		/obj/item/reagent_containers/food/snacks/burger/ghost,
		/obj/item/reagent_containers/food/snacks/burger/jelly,
		/obj/item/reagent_containers/food/snacks/burger/superbite,
		/obj/item/reagent_containers/food/snacks/burger/soylent,
		/obj/item/reagent_containers/food/snacks/store/cake/birthday,
		/obj/item/reagent_containers/food/snacks/store/cake/slimecake,
		/obj/item/reagent_containers/food/snacks/store/cake/bsvc,
		/obj/item/reagent_containers/food/snacks/store/cake/bscc,
		/obj/item/reagent_containers/food/snacks/store/cake/holy_cake,
		/obj/item/reagent_containers/food/snacks/store/cake/vanilla_cake,
		/obj/item/reagent_containers/food/snacks/store/cake/clown_cake,
		/obj/item/reagent_containers/food/snacks/store/cake/trumpet,
		/obj/item/reagent_containers/food/snacks/store/cake/hardware_cake,
		/obj/item/reagent_containers/food/snacks/benedict,
		/obj/item/reagent_containers/food/snacks/honkdae,
		/obj/item/reagent_containers/food/snacks/cubancarp,
		/obj/item/reagent_containers/food/snacks/fishfingers,
		/obj/item/reagent_containers/food/snacks/fishandchips,
		/obj/item/reagent_containers/food/snacks/sashimi,
		/obj/item/reagent_containers/food/snacks/bearsteak,
		/obj/item/reagent_containers/food/snacks/enchiladas,
		/obj/item/reagent_containers/food/snacks/bbqribs,
		/obj/item/reagent_containers/food/snacks/kebab/fiesta,
		/obj/item/reagent_containers/food/snacks/mint, //Only one exists on every map.
		/obj/item/reagent_containers/food/snacks/eggwrap,
		/obj/item/reagent_containers/food/snacks/cheesyburrito,
		/obj/item/reagent_containers/food/snacks/carneburrito,
		/obj/item/reagent_containers/food/snacks/fuegoburrito,
		/obj/item/reagent_containers/food/snacks/melonfruitbowl,
		/obj/item/reagent_containers/food/snacks/cubannachos,
		/obj/item/reagent_containers/food/snacks/melonkeg,
		/obj/item/reagent_containers/food/snacks/honeybar,
		/obj/item/reagent_containers/food/snacks/donut/chaos,
		/obj/item/reagent_containers/food/snacks/donut/blumpkin,
		/obj/item/reagent_containers/food/snacks/donut/jelly/blumpkin,
		/obj/item/reagent_containers/food/snacks/donut/bungo,
		/obj/item/reagent_containers/food/snacks/donut/jelly/bungo,
		/obj/item/reagent_containers/food/snacks/donut/matcha,
		/obj/item/reagent_containers/food/snacks/donut/jelly/matcha,
		/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly, //Because honestly, if you're even making slime jelly, that's impressive
		/obj/item/reagent_containers/food/snacks/muffin/booberry,
		/obj/item/reagent_containers/food/snacks/chawanmushi,
		/obj/item/reagent_containers/food/snacks/rofflewaffles,
		/obj/item/reagent_containers/food/snacks/meatbun,
		/obj/item/reagent_containers/food/snacks/pie/bearypie,
		/obj/item/reagent_containers/food/snacks/pie/xemeatpie,
		/obj/item/reagent_containers/food/snacks/pie/appletart,
		/obj/item/reagent_containers/food/snacks/pie/mimetart,
		/obj/item/reagent_containers/food/snacks/pie/cocolavatart,
		/obj/item/reagent_containers/food/snacks/pie/blumpkinpie,
		/obj/item/reagent_containers/food/snacks/pie/dulcedebatata,
		/obj/item/reagent_containers/food/snacks/pie/baklava,
		/obj/item/reagent_containers/food/snacks/pizza/sassysage,
		/obj/item/reagent_containers/food/snacks/salad/aesirsalad,
		/obj/item/reagent_containers/food/snacks/soup/blood,
		/obj/item/reagent_containers/food/snacks/soup/wingfangchu,
		/obj/item/reagent_containers/food/snacks/soup/mystery,
		/obj/item/reagent_containers/food/snacks/soup/coldchili,
		/obj/item/reagent_containers/food/snacks/soup/clownchili,
		/obj/item/reagent_containers/food/snacks/soup/stew,
		/obj/item/reagent_containers/food/snacks/soup/bisque,
		/obj/item/reagent_containers/food/snacks/soup/electron,
		/obj/item/reagent_containers/food/snacks/soup/bungocurry)
	include_subtypes = TRUE

//Tier 5:Legendary Foods.
//If you can make one of these in an hour long round, without any help, then you'll surely be awarded.
//Each one sold should be basically a payday and a half.
/datum/export/food/legendary
	cost = 500
	message = "of breathtaking food"
	export_types = list(
		/obj/item/reagent_containers/food/snacks/burger/roburgerbig,
		/obj/item/reagent_containers/food/snacks/powercrepe,
		/obj/item/reagent_containers/food/snacks/stuffedlegion,
		/obj/item/reagent_containers/food/snacks/soup/clownstears)
	include_subtypes = TRUE

//Tier 0: Illegal Foods.
//Yeah... centcom's not gonna buy these. Whatsoever.
//But, if you know a guy, who knows a guy, he might just take it off your hands for ya, for a pretty good price, too.
/datum/export/food/illegal
	cost = 500
	message = "of quote-unquote 'food'"
	export_category = EXPORT_CONTRABAND
	export_types = list(
		/obj/item/reagent_containers/food/snacks/store/cake/birthday/energy,
		/obj/item/reagent_containers/food/snacks/pizza/arnold)
	include_subtypes = TRUE
