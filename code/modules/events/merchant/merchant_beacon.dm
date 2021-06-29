/obj/machinery/satellite/merchant
	name = "trading satellite"
	desc = "A satellite broadcasting a trading signal, to indicate the station is open for business."
	icon = 'icons/obj/machines/satellite.dmi'
	icon_state = "sat_merchant_inactive"
	base_icon_state = "sat_merchant"

	mode = "BIGMONEYV.1"
	active = FALSE

	///minimum countdown ticks
	var/countdown_min = 1 MINUTES
	///maximum countdown ticks
	var/countdown_max = 4 MINUTES
	///the current countdown till the merchant event is triggered
	var/countdown
	///how much the countdown goes down per tick
	var/countdown_decrease = 2 SECONDS
	///looping beeping noise that satellites always be doing
	var/datum/looping_sound/satellite/soundloop

/obj/machinery/satellite/merchant/Initialize()
	. = ..()

	soundloop = new(list(src), FALSE)
	countdown = rand(countdown_min, countdown_max)

/obj/machinery/satellite/merchant/process()
	if(!active)
		return

	countdown -= countdown_decrease

	if(countdown <= 0)
		toggle() //toggle it off, maybe do something cool with this later

		SSevents.TriggerEvent(/datum/round_event_control/merchant)

/obj/machinery/satellite/merchant/toggle(mob/user)
	. = ..()

	if(anchored)
		soundloop.start()
	else
		soundloop.stop()

