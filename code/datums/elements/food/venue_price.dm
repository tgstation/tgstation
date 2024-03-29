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

	if(isitem(target))
		RegisterSignal(target, COMSIG_ITEM_SOLD_TO_CUSTOMER, PROC_REF(item_sold))
	if(istype(target, /datum/reagent))
		RegisterSignal(target, COMSIG_REAGENT_SOLD_TO_CUSTOMER, PROC_REF(reagent_sold))

/datum/element/venue_price/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ITEM_SOLD_TO_CUSTOMER)
	UnregisterSignal(target, COMSIG_REAGENT_SOLD_TO_CUSTOMER)

/datum/element/venue_price/proc/item_sold(obj/item/thing_sold, mob/living/basic/robot_customer/sold_to)
	SIGNAL_HANDLER

	produce_cash(sold_to, thing_sold)
	return TRANSACTION_SUCCESS

/datum/element/venue_price/proc/reagent_sold(datum/reagent/reagent_sold, mob/living/basic/robot_customer/sold_to, obj/item/container)
	SIGNAL_HANDLER

	produce_cash(sold_to, container)
	return TRANSACTION_SUCCESS

/datum/element/venue_price/proc/produce_cash(mob/living/basic/robot_customer/sold_to, obj/item/container)
	new /obj/item/holochip(get_turf(container), venue_price)
	playsound(container, 'sound/effects/cashregister.ogg', 60, TRUE)

	var/datum/venue/venue_to_pay = sold_to.ai_controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE]
	venue_to_pay.total_income += venue_price
