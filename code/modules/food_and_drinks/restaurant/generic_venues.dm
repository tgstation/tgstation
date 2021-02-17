/datum/venue/restaurant
	name = "restaurant"
	max_guests = 5
	customer_types = list(/datum/venue_customer/american = 5, /datum/venue_customer/italian = 3, /datum/venue_customer/french = 3)

/obj/structure/machinery/restaurant_portal/restaurant
	linked_venue = /datum/venue/restaurant

/obj/structure/restaurant_sign/restaurant
	linked_venue = /datum/venue/restaurant

/datum/venue/bar
	name = "bar"
	max_guests = 4
	customer_types = list(/datum/venue_customer/american = 5, /datum/venue_customer/italian = 3, /datum/venue_customer/french = 3)

/obj/structure/machinery/restaurant_portal/bar
	linked_venue = /datum/venue/bar

/obj/structure/restaurant_sign/bar
	linked_venue = /datum/venue/bar
