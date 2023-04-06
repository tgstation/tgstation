///This component can be used to give something value for venues
/datum/element/venue_price
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/venue_price

/datum/element/venue_price/Attach(datum/target, venue_price)
	. = ..()
	if(!venue_price)
		stack_trace("A venue_price element was attached to something without specifying an actual price.")
		return ELEMENT_INCOMPATIBLE
	src.venue_price = venue_price
	RegisterSignal(target, COMSIG_ITEM_SOLD_TO_CUSTOMER, PROC_REF(item_sold))

/datum/element/venue_price/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ITEM_SOLD_TO_CUSTOMER)

/datum/element/venue_price/proc/item_sold(datum/thing_sold, mob/living/simple_animal/robot_customer/sold_to, obj/item/container)
	SIGNAL_HANDLER

	var/datum/venue/venue_to_pay = sold_to.ai_controller?.blackboard[BB_CUSTOMER_ATTENDING_VENUE]

	new /obj/item/holochip(get_turf(container), venue_price)
	venue_to_pay.total_income += venue_price
	playsound(get_turf(container), 'sound/effects/cashregister.ogg', 60, TRUE)
