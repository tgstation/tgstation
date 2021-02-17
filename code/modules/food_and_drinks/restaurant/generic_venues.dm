/datum/venue/restaurant
	name = "restaurant"
	max_guests = 5
	customer_types = list(/datum/customer_data/american = 5)//, /datum/customer_data/italian = 3, /datum/customer_data/french = 3)
/obj/machinery/restaurant_portal/restaurant
	linked_venue = /datum/venue/restaurant

/obj/structure/restaurant_sign/restaurant
	linked_venue = /datum/venue/restaurant

/datum/venue/bar
	name = "bar"
	max_guests = 4
	customer_types = list(/datum/customer_data/american = 5)//, /datum/customer_data/italian = 3, /datum/customer_data/french = 3)

/obj/machinery/restaurant_portal/bar
	linked_venue = /datum/venue/bar

/obj/structure/restaurant_sign/bar
	linked_venue = /datum/venue/bar
