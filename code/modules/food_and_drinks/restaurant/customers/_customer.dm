/datum/customer_data
	///Name of the robot by default. Can be overriden at runtime
	var/list/name = "Generic Robot"
	///The types of food this robot likes in a weighted list. does NOT include subtypes.
	var/list/liked_objects = list()
	///The amount a robot pays for each food he likes in an assoc list type | payment
	var/list/object_prices = list()
	///Datum AI used for the robot. Should almost never be overwritten unless theyre subtypes of ai_controller/robot_customer
	var/datum/ai_controller/ai_controller_used = /datum/ai_controller/robot_customer
	///Patience of the AI, how long they will wait for their meal.
	var/total_patience = 600 SECONDS
	///Lines the robot says when it finds a seat
	var/list/found_seat_lines = list()
	///Lines the robot says when it can't find a seat
	var/list/cant_find_seat_lines = list()
	///Lines the robot says when leaving without food
	var/list/leave_mad_lines = list()
	///Lines the robot says when leaving with food
	var/list/leave_happy_lines = list()
	///Lines the robot says when leaving waiting for food
	var/list/wait_for_food_lines = list()

/datum/customer_data/proc/order_food_line(obj/item/object_to_order)
	return "I'd like a [initial(object_to_order.name)]"

/datum/customer_data/american
	name = "American Robot"
	liked_objects = list(/obj/item/food/burger/plain = 1)
	found_seat_lines = list("I hope there's a seat that supports my weight.", "I hope I can bring my gun in here.", "I hope they have the triple deluxe fatty burger.", "I just love the culture here.")
	cant_find_seat_lines = list("I'm so tired from standing...", "I have chronic backpain please hurry up and get me a seat!", "I'm not going to tip if I don't get a seat.")
	leave_mad_lines = list("NO TIP FOR YOU. GOODBYE!", "Atleast at SpaceDonalds they serve their burgers FAST!", "This venue is horrendous!", "I will speak to your manager.")
	leave_happy_lines = list("An extra tip for you my friend.")
	wait_for_food_lines = list("Listen buddy I'm getting real hungry over here!", "I could eat an entire triple stacked burger right now...")

/datum/customer_data/american/order_food_line(obj/item/object_to_order)
	object_to_order = new object_to_order()
	. = pick("I'll take the biggest [object_to_order] you have")
	qdel(object_to_order)

/datum/customer_data/italian
	name = "Italian Robot"
	liked_objects = list(/obj/item/food/burger/plain = 1)

/datum/customer_data/french
	name = "French Robot"
	liked_objects = list(/obj/item/food/burger/plain = 1)
