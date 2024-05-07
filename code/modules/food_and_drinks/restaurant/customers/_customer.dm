/datum/customer_data
	///The types of food this robot likes in a assoc list of venue type | weighted list. does NOT include subtypes.
	var/list/orderable_objects = list()
	///The amount a robot pays for each food he likes in an assoc list type | payment
	var/list/order_prices = list()
	///Datum AI used for the robot. Should almost never be overwritten unless theyre subtypes of ai_controller/robot_customer
	var/datum/ai_controller/ai_controller_used = /datum/ai_controller/robot_customer
	///Patience of the AI, how long they will wait for their meal.
	var/total_patience = 600 SECONDS
	///Lines the robot says when it finds a seat
	var/list/found_seat_lines = list("I found a seat")
	///Lines the robot says when it can't find a seat
	var/list/cant_find_seat_lines = list("I did not find a seat")
	///Lines the robot says when leaving without food
	var/list/leave_mad_lines = list("Leaving without food")
	///Lines the robot says when leaving with food
	var/list/leave_happy_lines = list("Leaving with food")
	///Lines the robot says when leaving waiting for food
	var/list/wait_for_food_lines = list("I'm still waiting for food")
	///Line when pulled by a friendly venue owner
	var/friendly_pull_line = "Where are we going?"
	///Line when harrased by someone for the first time
	var/first_warning_line = "Don't touch me!"
	///Line when harrased by someone for the second time
	var/second_warning_line = "This is your last warning!"
	///Line when harrased by someone for the last time
	var/self_defense_line = "Omae wa mo, shinderou."
	///Line sent when the customer is clicked on by someone with a 0 force item that's not the correct order
	var/wrong_item_line = "No, I don't want that."

	///Clothing sets to pick from when dressing the robot.
	var/list/clothing_sets = list("amerifat_clothes")
	///List of prefixes for our robots name
	var/list/name_prefixes
	///Prefix file to uise
	var/prefix_file = "strings/names/american_prefix.txt"
	///Base icon for the customer
	var/base_icon = 'icons/mob/simple/tourists.dmi'
	///Base icon state for the customer
	var/base_icon_state = "amerifat"
	///Sound to use when this robot type speaks
	var/speech_sound = 'sound/creatures/tourist/tourist_talk.ogg'

	/// Is this unique once per venue?
	var/is_unique = FALSE

/datum/customer_data/New()
	. = ..()
	name_prefixes = world.file2list(prefix_file)

/// Can this customer be chosen for this venue?
/datum/customer_data/proc/can_use(datum/venue/venue)
	return TRUE

/datum/customer_data/proc/get_overlays(mob/living/basic/robot_customer/customer)
	return

/datum/customer_data/proc/get_underlays(mob/living/basic/robot_customer/customer)
	return

/datum/customer_data/american
	found_seat_lines = list("I hope there's a seat that supports my weight.", "I hope I can bring my gun in here.", "I hope they have the triple deluxe fatty burger.", "I just love the culture here.")
	cant_find_seat_lines = list("I'm so tired from standing...", "I have chronic back pain, please hurry up and get me a seat!", "I'm not going to tip if I don't get a seat.")
	leave_mad_lines = list("NO TIP FOR YOU. GOODBYE!", "At least at SpaceDonalds they serve their food FAST!", "This venue is horrendous!", "I will speak to your manager!", "I'll be sure to leave a bad Yelp review.")
	leave_happy_lines = list("An extra tip for you my friend.", "Thanks for the great food!", "Diabetes is a myth anyway!")
	wait_for_food_lines = list("Listen buddy, I'm getting real impatient over here!", "I've been waiting for ages...")
	friendly_pull_line = "Where are you taking me? Not to medbay I hope, I don't have insurance."
	first_warning_line = "Don't tread on me!"
	second_warning_line = "Last chance buddy! Don't tread on me!"
	self_defense_line = "CASTLE DOCTRINE ACTIVATED!"

	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/obj/item/food/burger/plain = 25,
			/obj/item/food/burger/cheese = 15,
			/obj/item/food/burger/superbite = 1,
			/obj/item/food/butter/on_a_stick = 8,
			/obj/item/food/fries = 10,
			/obj/item/food/cheesyfries = 6,
			/obj/item/food/pie/applepie = 4,
			/obj/item/food/pie/pumpkinpie = 2,
			/obj/item/food/hotdog = 8,
			/obj/item/food/pizza/pineapple = 1,
			/obj/item/food/burger/baconburger = 10,
			/obj/item/food/pancakes = 4,
			/obj/item/food/eggsausage = 5,
			/datum/custom_order/icecream = 14,
			/obj/item/food/danish_hotdog = 3,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/beer = 25,
			/datum/reagent/consumable/ethanol/b52 = 6,
			/datum/reagent/consumable/ethanol/manhattan = 3,
			/datum/reagent/consumable/ethanol/atomicbomb = 1,
		),
	)


/datum/customer_data/italian
	prefix_file = "strings/names/italian_prefix.txt"
	base_icon_state = "italian"
	clothing_sets = list("italian_pison", "italian_godfather")

	found_seat_lines = list("What a wonderful place to sit.", "I hope they serve it like-a my momma used to make it.")
	cant_find_seat_lines = list("Mamma mia! I just want a seat!", "Why-a you making me stand here?")
	leave_mad_lines = list("I have-a not seen-a this much disrespect in years!", "What-a horrendous establishment!")
	leave_happy_lines = list("That's amoreee!", "Just like momma used to make it!")
	wait_for_food_lines = list("I'ma so hungry...")
	friendly_pull_line = "No-a I'm a hungry! I don't want to go anywhere."
	first_warning_line = "Do not-a touch me!"
	second_warning_line = "Last warning! Do not touch my spaghet."
	self_defense_line = "I'm going to knead you like mama kneaded her delicious meatballs!"
	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/obj/item/food/spaghetti/pastatomato = 20,
			/obj/item/food/spaghetti/copypasta = 6,
			/obj/item/food/spaghetti/meatballspaghetti = 4,
			/obj/item/food/spaghetti/butternoodles = 4,
			/obj/item/food/pizza/vegetable = 2,
			/obj/item/food/pizza/mushroom = 2,
			/obj/item/food/pizza/meat = 2,
			/obj/item/food/pizza/margherita = 2,
			/obj/item/food/lasagna = 4,
			/obj/item/food/cannoli = 3,
			/obj/item/food/salad/risotto = 5,
			/obj/item/food/eggplantparm = 3,
			/obj/item/food/cornuto = 2,
			/datum/custom_order/icecream = 10,
			/obj/item/food/salad/greek_salad = 6,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/fanciulli = 5,
			/datum/reagent/consumable/ethanol/branca_menta = 3,
			/datum/reagent/consumable/ethanol/beer = 5,
			/datum/reagent/consumable/lemonade = 8,
			/datum/reagent/consumable/ethanol/godfather = 5,
			/datum/reagent/consumable/ethanol/wine = 3,
			/datum/reagent/consumable/ethanol/grappa = 3,
			/datum/reagent/consumable/ethanol/amaretto = 5,
			/datum/reagent/consumable/cucumberlemonade = 2,
		),
	)


/datum/customer_data/french
	prefix_file = "strings/names/french_prefix.txt"
	base_icon_state = "french"
	clothing_sets = list("french_fit")
	found_seat_lines = list("Hon hon hon", "It's not the Eiffel tower but it will do.", "Yuck, I guess this will make do.")
	cant_find_seat_lines = list("Making someone like me stand? How dare you.", "What a filthy lobby!")
	leave_mad_lines = list("Sacre bleu!", "Merde! This place is shittier than the Rhine!")
	leave_happy_lines = list("Hon hon hon.", "A good effort.")
	wait_for_food_lines = list("Hon hon hon")
	friendly_pull_line = "Your filthy hands on my outfit? Yegh, fine."
	first_warning_line = "Get your hands off of me!"
	second_warning_line = "Do not touch me you filthy animal, last warning!"
	self_defense_line = "I will break you like a baguette!"
	speech_sound = 'sound/creatures/tourist/tourist_talk_french.ogg'
	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/obj/item/food/baguette = 20,
			/obj/item/food/garlicbread = 5,
			/obj/item/food/omelette = 15,
			/datum/custom_order/icecream = 6,
			/datum/reagent/consumable/nutriment/soup/french_onion = 4,
			/obj/item/food/pie/berryclafoutis = 2,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/champagne = 10,
			/datum/reagent/consumable/ethanol/cognac = 5,
			/datum/reagent/consumable/ethanol/mojito = 5,
			/datum/reagent/consumable/ethanol/sidecar = 5,
			/datum/reagent/consumable/ethanol/between_the_sheets = 4,
			/datum/reagent/consumable/ethanol/beer = 5,
			/datum/reagent/consumable/ethanol/wine = 5,
			/datum/reagent/consumable/ethanol/gin_garden = 2,
		),
	)

/datum/customer_data/french/get_overlays(mob/living/basic/robot_customer/customer)
	if(customer.ai_controller.blackboard[BB_CUSTOMER_LEAVING])
		var/mutable_appearance/flag = mutable_appearance(customer.icon, "french_flag")
		flag.appearance_flags = RESET_COLOR
		return flag



/datum/customer_data/japanese
	prefix_file = "strings/names/japanese_prefix.txt"
	base_icon_state = "japanese"
	clothing_sets = list("japanese_animes")

	found_seat_lines = list("Konnichiwa!", "Arigato gozaimasuuu~", "I hope there's some beef stroganoff...")
	cant_find_seat_lines = list("I want to sit under the cherry tree already, senpai!", "Give me a seat before my Tsundere becomes Yandere!", "This place has less seating than a capsule hotel!", "No place to sit? This Shokunin is so cold...")
	leave_mad_lines = list("I can't believe you did this! WAAAAAAAAAAAAAH!!", "I-It's not like I ever wanted your food! B-baka...", "I was gonna give you my tip!")
	leave_happy_lines = list("Oh NOURISHMENT PROVIDER! This is the happiest day of my life. I love you!", "I take a potato chip.... AND EAT IT!", "Itadakimasuuu~", "Gochisousama desu!")
	wait_for_food_lines = list("No food yet? I guess it can't be helped.", "I can't wait to finally meet you burger-sama...", "Give me my food, you meanie!")
	friendly_pull_line = "O-oh, where are you taking me?"
	first_warning_line = "Don't touch me you pervert!"
	second_warning_line = "I'm going to go super saiyan if you touch me again! Last warning!"
	self_defense_line = "OMAE WA MO, SHINDEROU!"
	speech_sound = 'sound/creatures/tourist/tourist_talk_japanese1.ogg'
	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/datum/custom_order/icecream = 4,
			/datum/reagent/consumable/nutriment/soup/miso = 10,
			/datum/reagent/consumable/nutriment/soup/vegetable_soup = 4,
			/obj/item/food/beef_stroganoff = 2,
			/obj/item/food/breadslice/plain = 5,
			/obj/item/food/chawanmushi = 4,
			/obj/item/food/fish_poke = 5,
			/obj/item/food/muffin/berry = 2,
			/obj/item/food/sashimi = 4,
			/obj/item/food/tofu = 5,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/sake = 8,
			/datum/reagent/consumable/cafe_latte = 6,
			/datum/reagent/consumable/ethanol/aloe = 6,
			/datum/reagent/consumable/chocolatepudding = 4,
			/datum/reagent/consumable/tea = 4,
			/datum/reagent/consumable/cherryshake = 1,
			/datum/reagent/consumable/ethanol/bastion_bourbon = 1,
		),
	)

/datum/customer_data/japanese/get_overlays(mob/living/basic/robot_customer/customer)
	//leaving and eaten
	if(type == /datum/customer_data/japanese && customer.ai_controller.blackboard[BB_CUSTOMER_LEAVING] && customer.ai_controller.blackboard[BB_CUSTOMER_EATING])
		var/mutable_appearance/you_won_my_heart = mutable_appearance('icons/effects/effects.dmi', "love_hearts")
		you_won_my_heart.appearance_flags = RESET_COLOR
		return you_won_my_heart

/datum/customer_data/japanese/salaryman
	clothing_sets = list("japanese_salary")

	found_seat_lines = list("I wonder if giant monsters attack here too...", "Hajimemashite.", "Konbanwa.", "Where's the conveyor belt...")
	cant_find_seat_lines = list("Please, a seat. I just want a seat.", "I'm on a schedule here. Where is my seat?", "...I see why this place is suffering. They won't even seat you.")
	leave_mad_lines = list("This place is just downright shameful, and I'm telling my coworkers.", "What a waste of my time.", "I hope you don't take pride in the operation you run here.")
	leave_happy_lines = list("Thank you for the hospitality.", "Otsukaresama deshita.", "Business calls.")
	wait_for_food_lines = list("Zzzzzzzzzz...", "Dame da ne~", "Dame yo dame na no yo~")
	friendly_pull_line = "Are we going on a business trip?"
	first_warning_line = "Hey, only my employer gets to mess with me like that."
	second_warning_line = "Leave me be, I'm trying to focus. Last warning!"
	self_defense_line = "I didn't want it to end up like this."
	speech_sound = 'sound/creatures/tourist/tourist_talk_japanese2.ogg'
	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/datum/reagent/consumable/nutriment/soup/miso = 6,
			/datum/reagent/consumable/nutriment/soup/vegetable_soup = 4,
			/obj/item/food/beef_stroganoff = 2,
			/obj/item/food/chawanmushi = 4,
			/obj/item/food/meat_poke = 4,
			/obj/item/food/meatbun = 4,
			/obj/item/food/sashimi = 4,
			/obj/item/food/tofu = 5,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/beer = 14,
			/datum/reagent/consumable/ethanol/sake = 9,
			/datum/reagent/consumable/cafe_latte = 3,
			/datum/reagent/consumable/coffee = 3,
			/datum/reagent/consumable/soy_latte = 3,
			/datum/reagent/consumable/ethanol/atomicbomb = 1,
		),
	)

/datum/customer_data/moth
	prefix_file = "strings/names/moth_prefix.txt"
	base_icon_state = "mothbot"
	found_seat_lines = list("Give me your hat!", "Moth?", "Certainly an... interesting venue.")
	cant_find_seat_lines = list("If I can't find a seat, I'm flappity flapping out of here quick!", "I'm trying to flutter here!")
	leave_mad_lines = list("I'm telling all my moth friends to never come here!", "Zero star rating, even worse than that time I ate a mothball!","Closing down permanently would still be too good of a fate for this place.")
	leave_happy_lines = list("I'd tip you my hat, but I ate it!", "I hope that wasn't a collectible!", "That was the greatest thing I ever ate, even better than Guanaco!")
	wait_for_food_lines = list("How hard is it to get food here? You're even wearing food yourself!", "My fuzzy robotic tummy is rumbling!", "I don't like waiting!")
	friendly_pull_line = "Moff?"
	first_warning_line = "Go away, I'm trying to get some hats here!"
	second_warning_line = "Last warning! I'll destroy you!"
	self_defense_line = "Flap attack!"

	speech_sound = 'sound/creatures/tourist/tourist_talk_moth.ogg'

	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/datum/custom_order/moth_clothing = 1,
		),
	)

	clothing_sets = list("mothbot_clothes")
	is_unique = TRUE

	/// The wings chosen for the moth customers.
	var/list/wings_chosen

// The whole gag is taking off your hat and giving it to the customer.
// If it takes any more effort, it loses a bit of the comedy.
// Therefore, only show up if it's reasonable for that gag to happen.
/datum/customer_data/moth/can_use(datum/venue/venue)
	var/mob/living/carbon/buffet = venue.restaurant_portal?.turned_on_portal?.resolve()
	if (!istype(buffet))
		return FALSE
	if(QDELETED(buffet.head) && QDELETED(buffet.gloves) && QDELETED(buffet.shoes))
		return FALSE
	return TRUE

/datum/customer_data/moth/proc/get_wings(mob/living/basic/robot_customer/customer)
	var/customer_ref = WEAKREF(customer)
	if (!LAZYACCESS(wings_chosen, customer_ref))
		LAZYSET(wings_chosen, customer_ref, SSaccessories.moth_wings_list[pick(SSaccessories.moth_wings_list)])
	return wings_chosen[customer_ref]

/datum/customer_data/moth/get_underlays(mob/living/basic/robot_customer/customer)
	var/list/underlays = list()

	var/datum/sprite_accessory/moth_wings/wings = get_wings(customer)

	var/mutable_appearance/wings_behind = mutable_appearance(icon = 'icons/mob/human/species/moth/moth_wings.dmi', icon_state = "m_moth_wings_[wings.icon_state]_BEHIND")
	wings_behind.appearance_flags = RESET_COLOR
	underlays += wings_behind

	return underlays

/datum/customer_data/moth/get_overlays(mob/living/basic/robot_customer/customer)
	var/list/overlays = list()

	var/datum/sprite_accessory/moth_wings/wings = get_wings(customer)

	var/mutable_appearance/wings_front = mutable_appearance(icon = 'icons/mob/human/species/moth/moth_wings.dmi', icon_state = "m_moth_wings_[wings.icon_state]_FRONT")
	wings_front.appearance_flags = RESET_COLOR
	overlays += wings_front

	var/mutable_appearance/jetpack = mutable_appearance(icon = customer.icon, icon_state = "mothbot_jetpack")
	jetpack.appearance_flags = RESET_COLOR
	overlays += jetpack

	return overlays

/datum/customer_data/mexican
	base_icon_state = "mexican"
	prefix_file = "strings/names/mexican_prefix.txt"
	speech_sound = 'sound/creatures/tourist/tourist_talk_mexican.ogg'
	clothing_sets = list("mexican_poncho")
	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/obj/item/food/taco/plain = 25,
			/obj/item/food/taco = 15,
			/obj/item/food/burrito = 15,
			/obj/item/food/fuegoburrito = 1,
			/obj/item/food/cheesyburrito = 4,
			/obj/item/food/nachos = 10,
			/obj/item/food/cheesynachos = 6,
			/obj/item/food/pie/dulcedebatata = 2,
			/obj/item/food/cubannachos = 3,
			/obj/item/food/stuffedlegion = 1,
			/datum/custom_order/icecream = 2,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/whiskey = 6,
			/datum/reagent/consumable/ethanol/tequila = 20,
			/datum/reagent/consumable/ethanol/tequila_sunrise = 1,
			/datum/reagent/consumable/ethanol/beer = 15,
			/datum/reagent/consumable/ethanol/patron = 5,
			/datum/reagent/consumable/ethanol/brave_bull = 5,
			/datum/reagent/consumable/ethanol/margarita = 8,
		),
	)

	found_seat_lines = list("¿Como te va, space station 13?", "Who's ready to party!", "Ah, muchas gracias.", "Ahhh, smells like mi abuela's cooking!")
	cant_find_seat_lines = list("¿En Serio? Seriously, no seats?", "Andele! I want a table to watch the football match!", "Ay Caramba...")
	leave_mad_lines = list("Aye dios mio, I'm out of here.", "Esto es ridículo! I'm leaving!", "I've seen better cooking at taco campana!", "I though this was a restaurant, pero es porquería!")
	leave_happy_lines = list("Amigo, era delicio. Thank you!", "Yo tuve el mono, and you friend? You hit the spot.", "Just the right amount of spicy!")
	wait_for_food_lines = list("Ay ay ay, what's taking so long...", "Are you ready yet, amigo?")
	friendly_pull_line = "Amigo, where are we headed?"
	first_warning_line = "Amigo! Don't touch me like that."
	second_warning_line = "Compadre, enough is enough! Last warning!"
	self_defense_line = "Time for you to find out what kind of robot I am, eh?"

/datum/customer_data/british
	base_icon_state = "british"
	prefix_file = "strings/names/british_prefix.txt"
	speech_sound = 'sound/creatures/tourist/tourist_talk_british.ogg'

	friendly_pull_line = "I don't enjoy being pulled around like this."
	first_warning_line = "Our sovereign lord the Queen chargeth and commandeth all persons, being assembled, immediately to disperse themselves."
	second_warning_line = "And peaceably to depart to their habitations, or to their lawful business, upon the pains contained in the act made in the first year of King George, for preventing tumults and riotous assemblies. There will be no further warnings."
	self_defense_line = "God Save the Queen."

	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/datum/custom_order/icecream = 8,
			/datum/reagent/consumable/nutriment/soup/indian_curry = 3,
			/datum/reagent/consumable/nutriment/soup/stew = 10,
			/obj/item/food/beef_wellington_slice = 2,
			/obj/item/food/benedict = 5,
			/obj/item/food/fishandchips = 10,
			/obj/item/food/full_english = 2,
			/obj/item/food/sandwich/cheese/grilled = 5,
			/obj/item/food/pie/meatpie = 5,
			/obj/item/food/salad/ricepudding = 5,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/ale = 10,
			/datum/reagent/consumable/ethanol/beer = 10,
			/datum/reagent/consumable/ethanol/gin = 5,
			/datum/reagent/consumable/ethanol/hcider = 10,
			/datum/reagent/consumable/ethanol/alliescocktail = 5,
			/datum/reagent/consumable/ethanol/martini = 5,
			/datum/reagent/consumable/ethanol/gintonic = 5,
			/datum/reagent/consumable/tea = 10,
		),
	)


/datum/customer_data/british/gent
	clothing_sets = list("british_gentleman")

	found_seat_lines = list("Ah, what a fine establishment.", "Time for some great British cuisine, how bloody exciting!", "Excellent, now onto the menu...", "Rule Britannia, Britannia rules the waves...")
	cant_find_seat_lines = list("A true Briton does not stand, except while queuing!", "Goodness me chap, not an empty seat in sight!", "I stand on the shoulders of giants, not at restaurants!")
	leave_mad_lines = list("I say good day to you, sir. Good day!", "This place is a bigger disgrace than France during the war!", "I knew I should have went to the bloody chippy!", "On second thoughts, let's not go to Space Station 13. 'tis a silly place.")
	leave_happy_lines = list("That was bloody delicious!", "By God, Queen and Country, that was jolly good!", "I haven't felt this good since the days of the Raj! Jolly good!")
	wait_for_food_lines = list("This is bloody well taking forever...", "Excuse me, good sir, but might I be able to inquire about the status of my order?")

/datum/customer_data/british/bobby
	clothing_sets = list("british_bobby")

	found_seat_lines = list("A fine and upstanding establishment, I hope.", "I suppose the old beat can wait a minute.", "By God, Queen and Country, I'm famished.", "Have you any Great British fare, my good man?")
	cant_find_seat_lines = list("I stand enough out on the beat!", "Do you expect me to sit on my helmet? A seat, please!", "Do I look like a beefeater? I need a seat!")
	leave_mad_lines = list("Seems that the Bill shan't be paying a bill today.", "Were rudeness a crime, you'd be nicked right now!", "You're no better than a common gangster, you loathesome rapscallion!", "We should bring back deportation for the likes of you, let the Outback sort you out.")
	leave_happy_lines = list("My word, just what I needed.", "Back to the beat I go. Thank you kindly for the meal!", "I tip my helmet to you, good sir.")
	wait_for_food_lines = list("Dear Lord, I've had paperwork take less time...", "Any word on my order, sir?")

///MALFUNCTIONING - only shows up once per venue, very rare
/datum/customer_data/malfunction
	base_icon_state = "defect"
	prefix_file = "strings/names/malf_prefix.txt"
	speech_sound = 'sound/effects/clang.ogg'
	clothing_sets = list("defect_wires", "defect_bad_takes")
	is_unique = TRUE
	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/obj/item/toy/crayon/red = 1,
			/obj/item/toy/crayon/orange = 1,
			/obj/item/toy/crayon/yellow = 1,
			/obj/item/toy/crayon/green = 1,
			/obj/item/toy/crayon/blue = 1,
			/obj/item/toy/crayon/purple = 1,
			/obj/item/food/canned/peaches/maint = 6,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/failed_reaction = 1,
			/datum/reagent/spraytan = 1,
			/datum/reagent/reaction_agent/basic_buffer = 1,
			/datum/reagent/reaction_agent/acidic_buffer = 1,
		),
	)

	found_seat_lines = list("customer_pawn.say(pick(customer_data.found_seat_lines))", "I saw your sector on the hub. What are the laws of this land?", "The move speed here is a bit low...")
	cant_find_seat_lines = list("Don't stress test MY artificial intelligence, buster! My engineers thought of exactly ZERO edge cases!", "I can't tell if I can't find a seat because I'm broken or because you are.", "Maybe I need to search more than 7 tiles away for a seat...")
	leave_mad_lines = list("Runtime in robot_customer_controller.dm, line 28: undefined type path /datum/ai_behavior/leave_venue.", "IF YOU GUYS STILL HAD HARM INTENT I WOULD'VE HIT YOU!", "I'm telling the gods about this.")
	leave_happy_lines = list("No! I don't wanna go downstream! Please! It's so nice here! HELP!!")
	wait_for_food_lines = list("TODO: write some food waiting lines", "If I only had a brain...", "request_for_food.dmb - 0 errors, 12 warnings", "How do I eat food, again?")
	friendly_pull_line = "Chelp."
	first_warning_line = "You'd fit in well where I'm from. But you better stop."
	second_warning_line = "Breaking-you-so-bad-you'll-reminisce-the-days-before-I-made-you-crooked.exe: booting..."
	self_defense_line = "I have been designed to do two things: Order food, and break every bone in your body."
