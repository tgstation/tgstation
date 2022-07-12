/obj/structure/sign/clock
	name = "wall clock"
	desc = "It's a bluespace-controlled wall clock showing both the local Coalition Standard Time and the galactic Treaty Coordinated Time. Perfect for staring at instead of working."
	icon_state = "clock"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/clock, 32)

/obj/structure/sign/clock/examine(mob/user)
	. = ..()
	. += span_info("The current CST (local) time is: [station_time_timestamp()].")
	. += span_info("The current TCT (galactic) time is: [time2text(world.realtime, "hh:mm:ss")].")

/obj/structure/sign/calendar
	name = "wall calendar"
	desc = "It's an old-school wall calendar. Sure, it might be obsolete with modern technology, but it's still hard to imagine an office without one."
	icon_state = "calendar"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/calendar, 32)

/obj/structure/sign/calendar/examine(mob/user)
	. = ..()
	. += span_info("The current date is: [time2text(world.realtime, "DDD, MMM DD")], [GLOB.year_integer+540].")
	if(SSevents.holidays)
		. += span_info("Events:")
		for(var/holidayname in SSevents.holidays)
			. += span_info("[holidayname]")
