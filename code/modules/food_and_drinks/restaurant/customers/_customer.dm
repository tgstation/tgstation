/datum/venue_customer
	///Name of the robot by default. Can be overriden at runtime
	var/list/name = "Generic Robot"
	///The types of food this robot likes in a weighted list. does NOT include subtypes.
	var/list/liked_foods = list()
	///The amount a robot pays for each food he likes in an assoc list type | payment
	var/list/food_prices = list()
	///Datum AI used for the robot. Should almost never be overwritten unless theyre subtypes of ai_controller/robot_customer
	var/datum/ai_controller/ai_controller_used
	///Patience of the AI, how long they will wait for their meal.
	var/patience = 600 SECONDS

/datum/venue_customer/american
	name = "American Robot"
	liked_foods = list(/obj/item/food/burger/plain)

/datum/venue_customer/italian
	name = "Italian Robot"
	liked_foods = list(/obj/item/food/burger/plain)

/datum/venue_customer/french
	name = "French Robot"
	liked_foods = list(/obj/item/food/burger/plain)
