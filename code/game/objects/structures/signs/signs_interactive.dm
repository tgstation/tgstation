/obj/structure/sign/clock
	name = "wall clock"
	desc = "It's your run-of-the-mill wall clock showing both the local Coalition Standard Time and the galactic Treaty Coordinated Time. Perfect for staring at instead of working."
	icon_state = "clock"

#ifdef EXPERIMENT_WALLENING_SIGNS
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/clock, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/clock, 32)
#endif

/obj/structure/sign/clock/examine(mob/user)
	. = ..()
	. += span_info("The current CST (local) time is: [station_time_timestamp()].")
	. += span_info("The current TCT (galactic) time is: [time2text(world.realtime, "hh:mm:ss")].")

/obj/structure/sign/calendar
	name = "wall calendar"
	desc = "It's an old-school wall calendar. Sure, it might be obsolete with modern technology, but it's still hard to imagine an office without one."
	icon_state = "calendar"

#ifdef EXPERIMENT_WALLENING_SIGNS
MAPPING_DIRECTIONAL_HELPERS_VISIBLE_CARDINALS(/obj/structure/sign/calendar, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/calendar, 32)
#endif

/obj/structure/sign/calendar/examine(mob/user)
	. = ..()
	. += span_info("The current date is: [time2text(world.realtime, "DDD, MMM DD")], [CURRENT_STATION_YEAR].")
	if(length(GLOB.holidays))
		. += span_info("Events:")
		for(var/holidayname in GLOB.holidays)
			. += span_info("[holidayname]")
