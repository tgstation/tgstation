///Represents the abstract concept of a food venue in the code.
/datum/venue
	///Name of the venue
	var/name = "unnamed venue"
	///Max amount of guests at any time
	var/max_guests = 5
	///Weighted list of customer types
	var/list/customer_types
	///Is the venue open at the moment?
	var/open
	///Portal linked to this venue at the moment
	var//obj/structure/restaurant_portal

/datum/venue/toggle_open()
	if(open)
		closed()
	else
		open()

/datum/venue/open()
	open = TRUE

/datum/venue/close()
	open = FALSE

/obj/structure/machinery/restaurant_portal
	name = "restaurant portal"
	desc = "A robot-only gate into the wonders of Space Station cuisine!"
	icon = 'icons/obj/machines/restaurant_portal.dmi'
	icon_state = "portal"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/sheetifier
	layer = BELOW_OBJ_LAYER
	density = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	///What venue is this portal for? Uses a typepath which is turned into an instance on Initialize
	var/datum/venue/linked_venue = /datum/venue

/obj/structure/restaurant_portal/Initialize()
	. = ..()
	linked_venue = SSrestaurant.all_venues[linked_venue]
	linked_venue.portal = src

/obj/structure/restaurant_portal/Destroy()
	. = ..()

/obj/structure/restaurant_portal/update_icon_state()
	. = ..()
	if(linked_venue.open) //Any open venues
		icon = "portal_on"
	else
		icon = "portal_off"

/obj/structure/restaurant_sign
	name = "restaurant sign"
	desc = "Flip it to show you're open or not."
	icon = 'icons/obj/machines/restaurant_portal.dmi'
	icon_state = "sign_open"
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | UNACIDABLE | ACID_PROOF //fuck it
	///What venue is this sign for? Uses a typepath which is turned into an instance on Initialize
	var/datum/venue/linked_venue = /datum/venue

/obj/structure/restaurant_sign/Initialize()
	. = ..()
	linked_venue = SSrestaurant.all_venues[linked_venue]

/obj/structure/restaurant_sign/attack_hand(mob/user)
	. = ..()
	linked_venue.toggle_open()
	update_icon()

/obj/structure/restaurant_sign/update_icon_state()
	. = ..()
	if(linked_venue.open)
		icon = "sign_open"
	else
		icon = "sign_closed"
