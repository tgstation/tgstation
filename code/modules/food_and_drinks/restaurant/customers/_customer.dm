/datum/customer_data
	///Name of the robot's origin
	var/nationality = "Generic"
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
	///Clothing sets to pick from when dressing the robot.
	var/list/clothing_sets = list("amerifat_clothes")
	///List of prefixes for our robots name
	var/list/name_prefixes
	///Prefix file to uise
	var/prefix_file = "strings/names/american_prefix.txt"
	///Base icon for the customer
	var/base_icon = "amerifat"
	///Sound to use when this robot type speaks
	var/speech_sound = 'sound/creatures/tourist/tourist_talk.ogg'

/datum/customer_data/New()
	. = ..()
	name_prefixes = world.file2list(prefix_file)

/datum/customer_data/proc/get_overlays(mob/living/simple_animal/robot_customer/customer)
	return

/datum/customer_data/american
	nationality = "Space-American"
	orderable_objects = list(
	/datum/venue/restaurant = list(/obj/item/food/burger/plain = 25, /obj/item/food/burger/cheese = 15, /obj/item/food/burger/superbite = 1, /obj/item/food/fries = 10, /obj/item/food/cheesyfries = 6, /obj/item/food/pie/applepie = 4, /obj/item/food/pie/pumpkinpie = 2, /obj/item/food/hotdog = 8, /obj/item/food/pizza/pineapple = 1, /obj/item/food/burger/baconburger = 10, /obj/item/food/pancakes = 4),
	/datum/venue/bar = list(/datum/reagent/consumable/ethanol/b52 = 6, /datum/reagent/consumable/ethanol/manhattan = 3, /datum/reagent/consumable/ethanol/atomicbomb = 1, /datum/reagent/consumable/ethanol/beer = 25))


	found_seat_lines = list("I hope there's a seat that supports my weight.", "I hope I can bring my gun in here.", "I hope they have the triple deluxe fatty burger.", "I just love the culture here.")
	cant_find_seat_lines = list("I'm so tired from standing...", "I have chronic back pain, please hurry up and get me a seat!", "I'm not going to tip if I don't get a seat.")
	leave_mad_lines = list("NO TIP FOR YOU. GOODBYE!", "At least at SpaceDonalds they serve their food FAST!", "This venue is horrendous!", "I will speak to your manager!", "I'll be sure to leave a bad Yelp review.")
	leave_happy_lines = list("An extra tip for you my friend.", "Thanks for the great food!", "Diabetes is a myth anyway!")
	wait_for_food_lines = list("Listen buddy, I'm getting real impatient over here!", "I've been waiting for ages...")


/datum/customer_data/italian
	nationality = "Space-Italian"
	prefix_file = "strings/names/italian_prefix.txt"
	base_icon = "italian"
	clothing_sets = list("italian_pison", "italian_godfather")

	found_seat_lines = list("What a wonderful place to sit.", "I hope they serve it like-a my momma used to make it.")
	cant_find_seat_lines = list("Mamma mia! I just want a seat!", "Why-a you making me stand here?")
	leave_mad_lines = list("I have-a not seen-a this much disrespect in years!", "What-a horrendous establishment!")
	leave_happy_lines = list("That's amoreee!", "Just like momma used to make it!")
	wait_for_food_lines = list("I'ma so hungry...")
	orderable_objects = list(
	/datum/venue/restaurant = list(/obj/item/food/spaghetti/pastatomato = 20, /obj/item/food/spaghetti/copypasta = 6, /obj/item/food/spaghetti/meatballspaghetti = 4, /obj/item/food/pizza/vegetable = 2, /obj/item/food/pizza/mushroom = 2, /obj/item/food/pizza/meat = 2, /obj/item/food/pizza/margherita = 2),
	/datum/venue/bar = list(/datum/reagent/consumable/ethanol/fanciulli = 5, /datum/reagent/consumable/ethanol/branca_menta = 3, /datum/reagent/consumable/ethanol/beer = 10, /datum/reagent/consumable/lemonade = 8, /datum/reagent/consumable/ethanol/godfather = 5))


/datum/customer_data/french
	nationality = "Space-French"
	prefix_file = "strings/names/french_prefix.txt"
	base_icon = "french"
	clothing_sets = list("french_fit")
	found_seat_lines = list("Hon hon hon", "It's not the Eiffel tower but it will do.", "Yuck, I guess this will make do.")
	cant_find_seat_lines = list("Making someone like me stand? How dare you.", "What a filthy lobby!")
	leave_mad_lines = list("Sacre bleu!", "Merde! This place is shittier than the Rhine!")
	leave_happy_lines = list("Hon hon hon.", "A good effort.")
	wait_for_food_lines = list("Hon hon hon")
	speech_sound = 'sound/creatures/tourist/tourist_talk_french.ogg'
	orderable_objects = list(
	/datum/venue/restaurant = list(/obj/item/food/baguette = 20, /obj/item/food/garlicbread = 5, /obj/item/food/soup/onion = 4, /obj/item/food/pie/berryclafoutis = 2, /obj/item/food/omelette = 15),
	/datum/venue/bar = list(/datum/reagent/consumable/ethanol/champagne = 15, /datum/reagent/consumable/ethanol/mojito = 5, /datum/reagent/consumable/ethanol/sidecar = 5, /datum/reagent/consumable/ethanol/between_the_sheets = 4, /datum/reagent/consumable/ethanol/beer = 10))

/datum/customer_data/french/get_overlays(mob/living/simple_animal/robot_customer/customer)
	if(customer.ai_controller.blackboard[BB_CUSTOMER_LEAVING])
		var/mutable_appearance/flag = mutable_appearance(customer.icon, "french_flag")
		flag.appearance_flags = RESET_COLOR
		return flag



/datum/customer_data/japanese
	nationality = "Space-Japanese"
	prefix_file = "strings/names/japanese_prefix.txt"
	base_icon = "japanese"
	clothing_sets = list("japanese_animes")

	found_seat_lines = list("Konnichiwa!", "Arigato gozaimasuuu~", "I hope there's some beef stroganoff...")
	cant_find_seat_lines = list("I want to sit under the cherry tree already, senpai!", "Give me a seat before my Tsundere becomes Yandere!", "This place has less seating than a capsule hotel!", "No place to sit? This Shokunin is so cold...")
	leave_mad_lines = list("I can't believe you did this! WAAAAAAAAAAAAAH!!", "I-It's not like I ever wanted your food! B-baka...", "I was gonna give you my tip!")
	leave_happy_lines = list("Oh NOURISHMENT PROVIDER! This is the happiest day of my life. I love you!", "I take a potato chip.... AND EAT IT!", "Itadakimasuuu~", "Gochisousama desu!")
	wait_for_food_lines = list("No food yet? I guess it can't be helped.", "I can't wait to finally meet you burger-sama...", "Give me my food, you meanie!")
	speech_sound = 'sound/creatures/tourist/tourist_talk_japanese1.ogg'
	orderable_objects = list(
	/datum/venue/restaurant = list(/obj/item/food/tofu = 5, /obj/item/food/breadslice/plain = 5, /obj/item/food/soup/milo = 10, /obj/item/food/soup/vegetable = 4, /obj/item/food/sashimi = 4, /obj/item/food/chawanmushi = 4, /obj/item/food/muffin/berry = 2, /obj/item/food/beef_stroganoff = 2),
	/datum/venue/bar = list(/datum/reagent/consumable/ethanol/sake = 8, /datum/reagent/consumable/cafe_latte = 6, /datum/reagent/consumable/ethanol/aloe = 6, /datum/reagent/consumable/chocolatepudding = 4, /datum/reagent/consumable/tea = 4, /datum/reagent/consumable/cherryshake = 1, /datum/reagent/consumable/ethanol/bastion_bourbon = 1))

/datum/customer_data/japanese/get_overlays(mob/living/simple_animal/robot_customer/customer)
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
	speech_sound = 'sound/creatures/tourist/tourist_talk_japanese2.ogg'
	orderable_objects = list(
	/datum/venue/restaurant = list(/obj/item/food/tofu = 5, /obj/item/food/soup/milo = 6, /obj/item/food/soup/vegetable = 4, /obj/item/food/sashimi = 4, /obj/item/food/chawanmushi = 4, /obj/item/food/meatbun = 4, /obj/item/food/beef_stroganoff = 2),
	/datum/venue/bar = list(/datum/reagent/consumable/ethanol/beer = 14, /datum/reagent/consumable/ethanol/sake = 9, /datum/reagent/consumable/cafe_latte = 3, /datum/reagent/consumable/coffee = 3, /datum/reagent/consumable/soy_latte = 3, /datum/reagent/consumable/ethanol/atomicbomb = 1))

/datum/customer_data/mexican
	nationality = "Space-Mexican"
	base_icon = "mexican"
	prefix_file = "strings/names/mexican_prefix.txt"
	speech_sound = 'sound/creatures/tourist/tourist_talk_mexican.ogg'
	clothing_sets = list("mexican_poncho")
	orderable_objects = list(
	/datum/venue/restaurant = list(/obj/item/food/taco/plain = 25, /obj/item/food/taco = 15 , /obj/item/food/burrito = 15, /obj/item/food/fuegoburrito = 1, /obj/item/food/cheesyburrito = 4, /obj/item/food/nachos = 10, /obj/item/food/cheesynachos = 6, /obj/item/food/pie/dulcedebatata = 2, /obj/item/food/cubannachos = 3, /obj/item/food/stuffedlegion = 1),
	/datum/venue/bar = list(/datum/reagent/consumable/ethanol/whiskey = 6, /datum/reagent/consumable/ethanol/tequila = 20, /datum/reagent/consumable/ethanol/tequila_sunrise = 1, /datum/reagent/consumable/ethanol/beer = 15, /datum/reagent/consumable/ethanol/patron = 5, /datum/reagent/consumable/ethanol/brave_bull = 5, /datum/reagent/consumable/ethanol/margarita = 8))


	found_seat_lines = list("¿Como te va, space station 13?", "Who's ready to party!", "Ah, muchas gracias.", "Ahhh, smells like mi abuela's cooking!")
	cant_find_seat_lines = list("¿En Serio? Seriously, no seats?", "Andele! I want a table to watch the football match!", "Ay Caramba...")
	leave_mad_lines = list("Aye dios mio, I'm out of here.", "Esto es ridículo! I'm leaving!", "I've seen better cooking at taco campana!", "I though this was a restaurant, pero es porquería!")
	leave_happy_lines = list("Amigo, era delicio. Thank you!", "Yo tuve el mono, and you friend? You hit the spot.", "Just the right amount of spicy!")
	wait_for_food_lines = list("Ay ay ay, what's taking so long...", "Are you ready yet, amigo?")
