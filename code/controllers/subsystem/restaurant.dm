/*!
This subsystem exists to serve as a holder for important info for the restaurant system for chef and bartender.
*/

SUBSYSTEM_DEF(restaurant)
	name = "Restaurant"
	wait = 20 SECONDS //Roll for new guests but don't do it too fast.
	init_order = INIT_ORDER_RESTAURANT
	flags = SS_NO_FIRE
	///All venues that exist, assoc list of type - reference
	var/list/all_venues = list()
	///All customer data datums that exist, assoc list of type - reference
	var/list/all_customers = list()
	///Seats claimed by robots. They want these. Don't be rude about it to them. assoc list of seat key and robot mob value
	var/list/claimed_seats = list()
	///Caches appearances of food, assoc list where key is the type of food, and value is the appearance. Used so we don't have to keep creating new food. Gets filled whenever a new food that hasn't been ordered gets ordered for the first time.
	var/list/food_appearance_cache = list()

/datum/controller/subsystem/restaurant/Initialize(timeofday)
	. = ..()
	for(var/key in subtypesof(/datum/venue))
		all_venues[key] = new key()
	for(var/key in subtypesof(/datum/customer_data))
		all_customers[key] = new key()
