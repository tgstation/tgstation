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
	var/obj/machinery/restaurant_portal
	///Lists the current visitors of a venue
	var/list/current_visitors = list()
	///Cooldown for next guest to arrive
	COOLDOWN_DECLARE(visit_cooldown)
	///Min time between new visits
	var/min_time_between_visitor = 20 SECONDS
	///Max time between new visits
	var/max_time_between_visitor = 2 MINUTES

/datum/venue/process(delta_time)
	if(!COOLDOWN_FINISHED(src, visit_cooldown))
		return
	COOLDOWN_START(src, visit_cooldown, rand(min_time_between_visitor, max_time_between_visitor))
	if(current_visitors.len < max_guests)
		create_new_customer()

///Spawns a new customer at the portal
/datum/venue/proc/create_new_customer()
	var/mob/living/simple_animal/robot_customer/new_customer = new /mob/living/simple_animal/robot_customer(get_turf(restaurant_portal), pickweight(customer_types), src)
	current_visitors += new_customer

/datum/venue/proc/order_food(mob/living/simple_animal/robot_customer/customer_pawn, datum/customer_data/customer_data)
	return

///Checks if the object used is correct for the venue
/datum/venue/proc/is_correct_order(atom/movable/object_used, wanted_item)
	return FALSE

///The line the robot says when ordering
/datum/venue/proc/order_food_line(order)
	return "broken venue pls call a coder"

///Effects for when a customer receives their order at this venue
/datum/venue/proc/on_get_order(mob/living/simple_animal/robot_customer/customer_pawn, obj/item/order_item)
	var/datum/customer_data/customer_info = customer_pawn.ai_controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]
	new /obj/item/holochip(get_step(customer_pawn, customer_pawn.dir), customer_info.order_prices[customer_pawn.ai_controller.blackboard[BB_CUSTOMER_CURRENT_ORDER]])

///Toggles whether the venue is open or not
/datum/venue/proc/toggle_open()
	if(open)
		close()
	else
		open()

/datum/venue/proc/open()
	open = TRUE
	restaurant_portal.update_icon()
	COOLDOWN_START(src, visit_cooldown, rand(min_time_between_visitor, max_time_between_visitor))
	START_PROCESSING(SSobj, src)

/datum/venue/proc/close()
	open = FALSE
	restaurant_portal.update_icon()
	STOP_PROCESSING(SSobj, src)
	for(var/mob/living/simple_animal/robot_customer as anything in current_visitors)
		robot_customer.ai_controller.blackboard[BB_BLACKBOARD_CUSTOMER_LEAVING] = TRUE //LEAVEEEEEE

/obj/machinery/restaurant_portal
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


/obj/machinery/restaurant_portal/Initialize()
	. = ..()
	linked_venue = SSrestaurant.all_venues[linked_venue]
	linked_venue.restaurant_portal = src

/obj/machinery/restaurant_portal/Destroy()
	. = ..()

/obj/machinery/restaurant_portal/update_icon_state()
	. = ..()
	if(linked_venue.open) //Any open venues
		icon_state = "portal_on"
	else
		icon_state = "portal"

/obj/structure/restaurant_sign
	name = "restaurant sign"
	desc = "Flip it to show you're open or not."
	icon = 'icons/obj/machines/restaurant_portal.dmi'
	icon_state = "sign_closed"
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
		icon_state = "sign_open"
	else
		icon_state = "sign_closed"


/obj/item/holosign_creator/robot_seat
	name = "seating indicator placer"
	creation_time = 1 SECONDS
	holosign_type = /obj/structure/holosign/robot_seat
	desc = "Use this to place seats for your restaurant guests!"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/holosign_creator/robot_seat/attack_self(mob/user)
	return


/obj/structure/holosign/robot_seat
	density = FALSE
	icon = 'icons/effects/effects.dmi'
	icon_state = "holosign"
	layer = BELOW_MOB_LAYER
	use_vis_overlay = FALSE
	var/datum/venue/linked_venue = /datum/venue

/obj/structure/holosign/robot_seat/Initialize(loc, source_projector)
	. = ..()
	linked_venue = SSrestaurant.all_venues[linked_venue]

/obj/structure/holosign/robot_seat/attack_holosign(mob/living/user, list/modifiers)
	return

/obj/structure/holosign/robot_seat/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(I.type == projector?.type && !SSrestaurant.claimed_seats[src])
		qdel(src)
