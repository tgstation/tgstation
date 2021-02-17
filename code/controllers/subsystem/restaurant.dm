/*!
This subsystem exists to serve as a holder for important info for the restaurant system for chef and bartender.
*/

SUBSYSTEM_DEF(restaurant)
	name = "Restaurant"
	wait = 20 SECONDS //Roll for new guests but don't do it too fast.
	init_order = INIT_ORDER_RESTAURANT
	///Current line of guests. This keeps track of the robots that still need to enter, but want to.
	var/list/current_line = list()
	///List of all guests currently visiting
	var/list/current_guests = list()
	///All venues that exist, assoc list of type - reference
	var/list/all_venues = list()
	///All customers that exist, assoc list of type - reference
	var/list/all_customers = list()


/datum/controller/subsystem/restaurant/Initialize(timeofday)
	. = ..()
	for(var/key in subtypesof(/datum/venue))
		all_venues[key] = new key()
	for(var/key in subtypesof(/datum/venue_customer))
		all_customers[key] = new key()
