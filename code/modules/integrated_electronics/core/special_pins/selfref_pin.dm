// This pin only contains its own weakref and can't be changed
/datum/integrated_io/selfref
	name = "selfref pin"

/datum/integrated_io/selfref/New()
	..()
	write_data_to_pin(src)

/datum/integrated_io/selfref/ask_for_pin_data(mob/user) // You can't clear it, it's self reference.


/datum/integrated_io/selfref/write_data_to_pin(var/new_data) // You can't write anything else but itself onto it
	if(data)
		return
	data = WEAKREF(holder)
	holder.on_data_written()

/datum/integrated_io/selfref/display_pin_type()
	return IC_FORMAT_REF

/datum/integrated_io/selfref/connect_pin(datum/integrated_io/pin)
	pin.write_data_to_pin(data)
	..(pin)

/datum/integrated_io/selfref/disconnect_pin(datum/integrated_io/pin)
	..(pin)
	pin.write_data_to_pin(null)
