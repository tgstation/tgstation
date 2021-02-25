///This component can be used to give something value for venues
/datum/element/venue_price
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	var/venue_price

/datum/element/venue_price/Attach(datum/target, venue_price)
	. = ..()
	src.venue_price = venue_price
	RegisterSignal(target, COMSIG_ITEM_SOLD_TO_CUSTOMER, .proc/item_sold)

/datum/element/venue_price/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ITEM_SOLD_TO_CUSTOMER)

/datum/element/venue_price/proc/item_sold(datum/source, obj/item/container)
	SIGNAL_HANDLER

	if(!venue_price)
		CRASH("[container] was sold, but had no price assigned to it! (Or its contents)")
	new /obj/item/holochip(get_turf(container), venue_price)
	playsound(get_turf(container), 'sound/effects/cashregister.ogg', 60, TRUE)
