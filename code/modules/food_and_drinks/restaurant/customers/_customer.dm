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
	orderable_objects = list(
	/datum/venue/restaurant = list(/obj/item/food/baguette = 20, /obj/item/food/garlicbread = 5, /obj/item/food/soup/onion = 4, /obj/item/food/pie/berryclafoutis = 2, /obj/item/food/omelette = 15),
	/datum/venue/bar = list(/datum/reagent/consumable/ethanol/champagne = 15, /datum/reagent/consumable/ethanol/mojito = 5, /datum/reagent/consumable/ethanol/sidecar = 5, /datum/reagent/consumable/ethanol/between_the_sheets = 4, /datum/reagent/consumable/ethanol/beer = 10))

/datum/customer_data/french/get_overlays(mob/living/simple_animal/robot_customer/customer)
	if(customer.ai_controller.blackboard[BB_CUSTOMER_LEAVING])
		var/mutable_appearance/flag = mutable_appearance(customer.icon, "french_flag")
		flag.appearance_flags = RESET_COLOR
		return flag
