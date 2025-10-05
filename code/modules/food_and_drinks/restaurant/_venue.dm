///Represents the abstract concept of a food venue in the code.
/datum/venue
	///Name of the venue, also used for the icon state of any radials it can be selected in
	var/name = "unnamed venue"
	///What kind of Venue are we
	var/venue_type = VENUE_RESTAURANT
	///Max amount of guests at any time
	var/max_guests = 6
	///Weighted list of customer types
	var/list/customer_types
	///Is the venue open at the moment?
	var/open
	///List of portals linked to this venue at the moment
	var/list/obj/machinery/restaurant_portal/restaurant_portals = list()
	///Lists the current visitors of a venue
	var/list/current_visitors = list()
	///Cooldown for next guest to arrive
	COOLDOWN_DECLARE(visit_cooldown)
	///Min time between new visits
	var/min_time_between_visitor = 60 SECONDS
	///Max time between new visits
	var/max_time_between_visitor = 90 SECONDS
	///Required access to mess with the venue
	var/req_access = ACCESS_KITCHEN
	///how many robots got their wanted thing
	var/customers_served = 0
	///Total income of those venue
	var/total_income = 0
	///Blacklist for idiots that attack bots. Key is the mob that did it, and the value is the amount of warnings they've received.
	var/list/mob_blacklist = list()
	///Seats linked to this venue, assoc list of key holosign of seat position, and value of robot assigned to it, if any.
	var/list/linked_seats = list()

/datum/venue/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, visit_cooldown))
		return
	COOLDOWN_START(src, visit_cooldown, rand(min_time_between_visitor, max_time_between_visitor))
	if(current_visitors.len < max_guests && current_visitors.len < linked_seats.len + 1) //Not above max guests, and not more than one waiting customer.
		create_new_customer()

///Spawns a new customer at the portal
/datum/venue/proc/create_new_customer()
	var/list/customer_types_to_choose = customer_types
	var/datum/customer_data/customer_type
	var/obj/machinery/restaurant_portal/chosen_portal = pick(restaurant_portals)

	// In practice, the list will never run out, but this is for sanity.
	while (customer_types_to_choose.len)
		customer_type = pick_weight(customer_types_to_choose)

		var/datum/customer_data/customer = SSrestaurant.all_customers[customer_type]
		if (customer.can_use(src, chosen_portal))
			break

		// Only copy the list once, so that we're not mutating ourselves.
		if (customer_types_to_choose == customer_types)
			customer_types_to_choose = customer_types.Copy()

		customer_types_to_choose -= customer_type

	if (initial(customer_type.is_unique))
		customer_types -= customer_type

	var/mob/living/basic/robot_customer/new_customer = new /mob/living/basic/robot_customer(get_turf(chosen_portal), customer_type, src)
	current_visitors[new_customer] = WEAKREF(chosen_portal)

/datum/venue/proc/order_food(mob/living/basic/robot_customer/customer_pawn, datum/customer_data/customer_data)
	var/order = pick_weight(customer_data.orderable_objects[venue_type])
	var/list/order_args // Only for custom orders - arguments passed into New
	var/image/food_image
	var/food_line

	if(ispath(order, /datum/reagent))
		// This is pain
		var/datum/reagent/reagent_order = order
		order_args = list("reagent_type" = reagent_order)
		order = initial(reagent_order.restaurant_order)

	if(ispath(order, /datum/custom_order)) // generate the special order
		var/datum/custom_order/custom_order = new order(arglist(list("customer" = customer_pawn) + (order_args || list())))
		food_image = custom_order.get_order_appearance(src)
		food_line = custom_order.get_order_line(src)
		order = custom_order.dispense_order()
	else
		food_image = get_food_appearance(order)
		food_line = order_food_line(order)

	customer_pawn.say(food_line)

	// common code for the food thoughts appearance
	food_image.loc = customer_pawn
	food_image.pixel_w = 16
	food_image.pixel_z = 32
	SET_PLANE_EXPLICIT(food_image, HUD_PLANE, customer_pawn)
	food_image.plane = HUD_PLANE
	food_image.appearance_flags = RESET_COLOR|KEEP_APART
	customer_pawn.hud_to_show_on_hover = customer_pawn.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/food_demands, "food_thoughts", food_image)

	return order

///Checks if the object used is correct for the venue
/datum/venue/proc/is_correct_order(atom/movable/object_used, wanted_item)
	if(istype(wanted_item, /datum/custom_order))
		var/datum/custom_order/custom_order = wanted_item
		return custom_order.is_correct_order(object_used)
	return FALSE

///gets the appearance of the ordered object that shows up when hovering your cursor over the customer mob.
/datum/venue/proc/get_food_appearance(order)
	return

///The line the robot says when ordering
/datum/venue/proc/order_food_line(order)
	return "broken venue pls call a coder"

///Effects for when a customer receives their order at this venue
/datum/venue/proc/on_get_order(mob/living/basic/robot_customer/customer_pawn, obj/item/order_item)
	SHOULD_CALL_PARENT(TRUE)

	// This is an item typepath, a reagent typepath, or a custom order datum instance.
	var/order = customer_pawn.ai_controller.blackboard[BB_CUSTOMER_CURRENT_ORDER]

	. = SEND_SIGNAL(order_item, COMSIG_ITEM_SOLD_TO_CUSTOMER, customer_pawn)

	for(var/datum/reagent/reagent as anything in order_item.reagents?.reagent_list)
		// Our order can be a reagent within the item we're receiving
		if(reagent.type == order)
			. |= SEND_SIGNAL(reagent, COMSIG_REAGENT_SOLD_TO_CUSTOMER, customer_pawn, order_item)
			break

	// Order can be a /datum/custom_order instance
	if(istype(order, /datum/custom_order))
		var/datum/custom_order/special_order = order
		. |= special_order.handle_get_order(customer_pawn, order_item)

	if(. & TRANSACTION_SUCCESS)
		customers_served++

///Toggles whether the venue is open or not
/datum/venue/proc/toggle_open()
	if(open)
		close()
	else
		open()

/datum/venue/proc/open()
	open = TRUE
	for (var/obj/machinery/restaurant_portal/portal as anything in restaurant_portals)
		portal.update_icon()
	COOLDOWN_START(src, visit_cooldown, 4 SECONDS) //First one comes faster
	START_PROCESSING(SSobj, src)

/datum/venue/proc/close()
	open = FALSE
	for (var/obj/machinery/restaurant_portal/portal as anything in restaurant_portals)
		portal.update_icon()
	STOP_PROCESSING(SSobj, src)
	for(var/mob/living/basic/robot_customer as anything in current_visitors)
		robot_customer.ai_controller.set_blackboard_key(BB_CUSTOMER_LEAVING, TRUE) //LEAVEEEEEE

/obj/machinery/restaurant_portal
	name = "restaurant portal"
	desc = "A robot-only gate into the wonders of Space Station cuisine!"
	icon = 'icons/obj/machines/restaurant_portal.dmi'
	icon_state = "portal"
	base_icon_state = "portal"
	anchored = TRUE
	density = FALSE
	circuit = /obj/item/circuitboard/machine/restaurant_portal
	layer = BELOW_OBJ_LAYER
	armor_type = /datum/armor/restaurant_portal
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	///What venue is this portal for? Uses a typepath which is turned into an instance on Initialize
	var/datum/venue/linked_venue

	/// A weak reference to the mob who turned on the portal
	var/datum/weakref/turned_on_portal

/datum/armor/restaurant_portal
	melee = 50
	bullet = 30
	laser = 50
	energy = 20
	bomb = 20
	fire = 100
	acid = 100

/obj/machinery/restaurant_portal/Initialize(mapload)
	. = ..()
	register_context()
	if (!linked_venue)
		return
	var/obj/item/circuitboard/machine/restaurant_portal/board = circuit
	board.venue_type = linked_venue
	linked_venue = SSrestaurant.all_venues[linked_venue]
	linked_venue.restaurant_portals += src

/obj/machinery/restaurant_portal/Destroy()
	turned_on_portal = null
	linked_venue.restaurant_portals -= src
	linked_venue = null
	return ..()

/obj/machinery/restaurant_portal/on_construction(mob/user)
	. = ..()
	circuit.configure_machine(src)

/obj/machinery/restaurant_portal/update_overlays()
	. = ..()
	if(!linked_venue?.open) //Any open venues
		. += mutable_appearance(icon, "portal_door")

/obj/machinery/restaurant_portal/attack_hand(mob/living/user)
	var/obj/item/card/id/used_id = user.get_idcard(TRUE)

	if(!used_id)
		return ..()

	if(!(linked_venue.req_access in used_id.GetAccess()))
		to_chat(user, span_warning("This card lacks the access to change this venues status."))
		return

	linked_venue.toggle_open()
	update_icon()

/obj/machinery/restaurant_portal/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	var/obj/item/card/id/used_id = tool.GetID()
	if(!istype(used_id))
		return NONE

	if(!check_access(used_id))
		balloon_alert(user, "insufficient access!")
		return ITEM_INTERACT_BLOCKING

	var/list/radial_items = list()
	var/list/radial_results = list()

	for(var/type_key in SSrestaurant.all_venues)
		var/datum/venue/venue = SSrestaurant.all_venues[type_key]
		radial_items[venue.name] = image('icons/obj/machines/restaurant_portal.dmi', venue.name)
		radial_results[venue.name] = type_key

	var/choice = show_radial_menu(user, src, radial_items, null, require_near = TRUE)

	if(!choice)
		return ITEM_INTERACT_BLOCKING

	var/venue_type = radial_results[choice]
	var/obj/item/circuitboard/machine/restaurant_portal/board = circuit
	board.venue_type = venue_type
	var/datum/venue/chosen_venue = SSrestaurant.all_venues[venue_type]

	turned_on_portal = WEAKREF(user)

	balloon_alert(user, "venue changed to [chosen_venue.name]")

	if(linked_venue && (src in linked_venue.restaurant_portals)) //We're already linked, unlink us.
		linked_venue.restaurant_portals -= src
		if(linked_venue.open && !length(linked_venue.restaurant_portals))
			linked_venue.close()
		linked_venue = null

	linked_venue = chosen_venue
	linked_venue.restaurant_portals += src
	return ITEM_INTERACT_SUCCESS

/obj/machinery/restaurant_portal/screwdriver_act(mob/user, obj/item/tool)
	if (default_deconstruction_screwdriver(user, "[base_icon_state]-open", base_icon_state, tool))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/restaurant_portal/crowbar_act(mob/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/restaurant_portal/wrench_act(mob/living/user, obj/item/tool)
	if(!panel_open)
		balloon_alert(user, "open the panel first!")
		return ITEM_INTERACT_BLOCKING

	if (default_unfasten_wrench(user, tool))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/restaurant_portal/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(isnull(held_item))
		return

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] Panel"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = anchored ? "Unsecure" : "Secure"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_CROWBAR && panel_open)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

	if(isidcard(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Change Venue"
		return CONTEXTUAL_SCREENTIP_SET

/obj/item/holosign_creator/robot_seat
	name = "seating indicator placer"
	icon_state = "signmaker_service"
	creation_time = 1 SECONDS
	holosign_type = /obj/structure/holosign/robot_seat
	desc = "Use this to place seats for your restaurant guests!"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/holosign_creator/robot_seat/attack_self(mob/user)
	return
/obj/structure/holosign/robot_seat
	density = FALSE
	desc = "Used to indicate a place to sit for a robot tourist. I better be careful."
	icon = 'icons/effects/effects.dmi'
	icon_state = "eating_zone"
	layer = BELOW_MOB_LAYER
	use_vis_overlay = FALSE
	var/datum/venue/linked_venue = /datum/venue

/obj/structure/holosign/robot_seat/Initialize(mapload, loc, source_projector)
	. = ..()
	linked_venue = SSrestaurant.all_venues[linked_venue]
	linked_venue.linked_seats[src] += null

/obj/structure/holosign/robot_seat/attack_holosign(mob/living/user, list/modifiers)
	return

/obj/structure/holosign/robot_seat/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(tool.type == projector?.type && !linked_venue.linked_seats[src])
		qdel(src)
		return ITEM_INTERACT_SUCCESS

/obj/structure/holosign/robot_seat/Destroy()
	linked_venue.linked_seats -= src
	return ..()
