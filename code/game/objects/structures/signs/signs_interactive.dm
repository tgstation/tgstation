#define COLLISION_HAZARD_THRESHOLD 11

/// Display days since last delam on incident sign
#define DISPLAY_DELAM (1<<0)
/// Display current number of tram hits on incident sign
#define DISPLAY_TRAM (1<<1)

DEFINE_BITFIELD(sign_features, list(
	"DISPLAY_DELAM" = DISPLAY_DELAM,
	"DISPLAY_TRAM" = DISPLAY_TRAM,
))

/obj/structure/sign/clock
	name = "wall clock"
	desc = "It's your run-of-the-mill wall clock showing both the local Coalition Standard Time and the galactic Treaty Coordinated Time. Perfect for staring at instead of working."
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
	. += span_info("The current date is: [time2text(world.realtime, "DDD, MMM DD")], [CURRENT_STATION_YEAR].")
	if(length(GLOB.holidays))
		. += span_info("Events:")
		for(var/holidayname in GLOB.holidays)
			. += span_info("[holidayname]")

/**
 * List of safety statistic signs on the map that have delam counting enabled.
 * Required as persistence subsystem loads after the ones present at mapload, and to reset to 0 upon explosion.
 */
GLOBAL_LIST_EMPTY(map_delamination_counters)
#define TREND_RISING "rising"
#define TREND_FALLING "falling"

/obj/structure/sign/incident
	name = "safety incident display"
	icon = 'icons/obj/stat_display.dmi'
	icon_preview = "stat_display_dual"
	icon_state = "stat_display_dual"
	is_editable = FALSE
	/// What statistics we want the sign to display
	var/sign_features = NONE
	var/hit_threshold = 0
	var/hit_count = 0
	var/last_delam = 0
	var/delam_record = 0

/obj/structure/sign/incident/delam
	icon_preview = "stat_display_delam"
	icon_state = "stat_display_delam"
	name = "delamination incident display"
	sign_features = DISPLAY_DELAM
	desc = "A signs describe how long it's been since the last delamination incident. Features an advert for SAFETY MOTH."

/obj/structure/sign/incident/dual
	desc = "A display that provides information on the station's safety record. Features an advert for SAFETY MOTH."
	sign_features = DISPLAY_DELAM | DISPLAY_TRAM

/obj/structure/sign/incident/tram
	icon_preview = "stat_display_tram"
	icon_state = "stat_display_tram"
	name = "tram incident display"
	desc = "A display that provides the number of tram related safety incidents this shift. Features an advert for SAFETY MOTH."
	sign_features = DISPLAY_TRAM

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/incident, 32)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/incident/delam, 32)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/incident/dual, 32)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/incident/tram, 32)

/obj/structure/sign/incident/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/sign/incident/Destroy()
	if(sign_features & DISPLAY_DELAM)
		GLOB.map_delamination_counters -= src
	return ..()

/obj/structure/sign/incident/proc/update_delam_count(new_count, record)
	delam_record = record
	last_delam = min(new_count, 99)
	update_appearance()

/obj/structure/sign/incident/LateInitialize()
	. = ..()
	if(sign_features & DISPLAY_DELAM)
		GLOB.map_delamination_counters += src
		update_delam_count(SSpersistence.rounds_since_engine_exploded, SSpersistence.highscore_since_engine_exploded)

	if(sign_features & DISPLAY_TRAM)
		for(var/obj/structure/industrial_lift/tram/tram as anything in GLOB.lifts)
			RegisterSignal(tram, COMSIG_TRAM_COLLISION, PROC_REF(tram_hit))

	update_appearance()

/obj/structure/sign/incident/proc/tram_hit(source, tram_collisions)
	SIGNAL_HANDLER

	hit_count = tram_collisions
	update_appearance()

/obj/structure/sign/incident/update_overlays()
	. = ..()
	if(sign_features & DISPLAY_DELAM)
		var/delam_display_color
		if(!last_delam)
			delam_display_color = "#FF0000"
		else
			delam_display_color = "#FBD641"
		var/delam_pos1 = last_delam % 10
		var/mutable_appearance/delam_pos1_overlay = mutable_appearance('icons/obj/stat_display.dmi', "num_[delam_pos1]")
		delam_pos1_overlay.color = delam_display_color
		delam_pos1_overlay.pixel_w = 9
		delam_pos1_overlay.pixel_z = 4
		. += delam_pos1_overlay

		var/delam_pos2 = (last_delam / 10) % 10
		var/mutable_appearance/delam_pos2_overlay = mutable_appearance('icons/obj/stat_display.dmi', "num_[delam_pos2]")
		delam_pos2_overlay.color = delam_display_color
		delam_pos2_overlay.pixel_w = 4
		delam_pos2_overlay.pixel_z = 4
		. += delam_pos2_overlay

		if(last_delam == delam_record)
			var/mutable_appearance/delam_trend_overlay = mutable_appearance('icons/obj/stat_display.dmi', TREND_RISING)
			delam_trend_overlay.color = "#00FF00"
			delam_trend_overlay.pixel_w = 1
			delam_trend_overlay.pixel_z = 6
			. += delam_trend_overlay
		else
			var/mutable_appearance/delam_trend_overlay = mutable_appearance('icons/obj/stat_display.dmi', TREND_FALLING)
			delam_trend_overlay.color = "#FF0000"
			delam_trend_overlay.pixel_w = 1
			delam_trend_overlay.pixel_z = 6
			. += delam_trend_overlay

	if(sign_features & DISPLAY_TRAM)
		var/tram_display_color = "#66CCFF"
		var/tram_pos1 = hit_count % 10
		var/mutable_appearance/tram_pos1_overlay = mutable_appearance('icons/obj/stat_display.dmi', "num_[tram_pos1]")
		tram_pos1_overlay.color = tram_display_color
		tram_pos1_overlay.pixel_w = 9
		tram_pos1_overlay.pixel_z = -6
		. += tram_pos1_overlay

		var/tram_pos2 = (hit_count / 10) % 10
		var/mutable_appearance/tram_pos2_overlay = mutable_appearance('icons/obj/stat_display.dmi', "num_[tram_pos2]")
		tram_pos2_overlay.color = tram_display_color
		tram_pos2_overlay.pixel_w = 4
		tram_pos2_overlay.pixel_z = -6
		. += tram_pos2_overlay

		if(hit_count > SSpersistence.tram_hits_last_round)
			var/mutable_appearance/tram_trend_overlay = mutable_appearance('icons/obj/stat_display.dmi', TREND_RISING)
			tram_trend_overlay.color = "#FF0000"
			tram_trend_overlay.pixel_w = 1
			tram_trend_overlay.pixel_z = -4
			. += tram_trend_overlay
		else
			var/mutable_appearance/tram_trend_overlay = mutable_appearance('icons/obj/stat_display.dmi', TREND_FALLING)
			tram_trend_overlay.color = "#00FF00"
			tram_trend_overlay.pixel_w = 1
			tram_trend_overlay.pixel_z = -4
			. += tram_trend_overlay

/obj/structure/sign/incident/examine(mob/user)
	. = ..()

	if(sign_features & DISPLAY_DELAM)
		. += span_info("It has been [last_delam] day\s since the last delamination event at this Nanotrasen facility.")
		switch (last_delam)
			if(0)
				. += span_info("In case you didn't notice.<br/>")
			if(1)
				. += span_info("Let's do better today.<br/>")
			if(2 to 5)
				. += span_info("There's room for improvement.<br/>")
			if(6 to 10)
				. += span_info("Good work!<br/>")
			if(69)
				. += span_info("Nice.<br/>")
			else
				. += span_info("Incredible!<br/>")

	if(sign_features & DISPLAY_TRAM)
		. += span_info("The station has had [hit_count] tram incident\s this shift.")
		switch (hit_count)
			if(0)
				. += span_info("Fantastic! Champions of safety.<br/>")
			if(1)
				. += span_info("Let's do better tomorrow.<br/>")
			if(2 to 5)
				. += span_info("There's room for improvement.<br/>")
			if(6 to 10)
				. += span_info("Good work! Nanotrasen's finest!<br/>")
			if(69)
				. += span_info("Nice.<br/>")
			else
				. += span_info("Incredible! You're probably reading this from medbay.<br/>")

#undef COLLISION_HAZARD_THRESHOLD
#undef DISPLAY_DELAM
#undef DISPLAY_TRAM
