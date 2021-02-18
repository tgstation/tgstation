/datum/customer_data
	///Name of the robot by default. Can be overriden at runtime
	var/list/name = "Generic Robot"
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

/datum/customer_data/american
	name = "American Robot"
	orderable_objects = list(
	/datum/venue/restaurant = list(/obj/item/food/burger/plain = 15, /obj/item/food/burger/cheese = 8, /obj/item/food/burger/superbite = 1),
	/datum/venue/bar = list(/datum/reagent/consumable/ethanol/b52 = 6, /datum/reagent/consumable/ethanol/manhattan = 3, /datum/reagent/consumable/ethanol/atomicbomb = 1, /datum/reagent/consumable/ethanol/beer/light = 15, /datum/reagent/consumable/ethanol/beer = 25))
	order_prices = list(/obj/item/food/burger/plain = 100, /obj/item/food/burger/cheese = 125, /obj/item/food/burger/superbite = 400, /datum/reagent/consumable/ethanol/b52 = 250, /datum/reagent/consumable/ethanol/manhattan = 250, /datum/reagent/consumable/ethanol/atomicbomb = 250, /datum/reagent/consumable/ethanol/beer/light = 50, /datum/reagent/consumable/ethanol/beer = 50)
	found_seat_lines = list("I hope there's a seat that supports my weight.", "I hope I can bring my gun in here.", "I hope they have the triple deluxe fatty burger.", "I just love the culture here.")
	cant_find_seat_lines = list("I'm so tired from standing...", "I have chronic backpain please hurry up and get me a seat!", "I'm not going to tip if I don't get a seat.")
	leave_mad_lines = list("NO TIP FOR YOU. GOODBYE!", "Atleast at SpaceDonalds they serve their food FAST!", "This venue is horrendous!", "I will speak to your manager.", "I'll be sure to leave a bad Yelp review.")
	leave_happy_lines = list("An extra tip for you my friend.", "Thanks for the great food!", "Diabetes is a myth anyways!")
	wait_for_food_lines = list("Listen buddy I'm getting real impatient over here!", "I've been waiting for ages...")

/datum/customer_data/italian
	name = "Italian Robot"
	orderable_objects = list(/datum/venue/restaurant = list(/obj/item/food/burger/plain = 1), /datum/venue/bar = list(/obj/item/food/burger/plain = 1))

/datum/customer_data/french
	name = "French Robot"
	orderable_objects = list(/datum/venue/restaurant = list(/obj/item/food/burger/plain = 1), /datum/venue/bar = list(/obj/item/food/burger/plain = 1))
