/**
 * Atmospheric Sanity Landmark - base
 *
 * This is the base type for all atmospheric sanity landmarks and are used to ensure atmos connectivity is maintained to how the map designer intended.
 */
/obj/effect/landmark/atmospheric_sanity
	name = "Atmospheric Sanity Landmark (broken?)"

/**
 * Marks ALL station areas as a goal, ignoring any other goals.
 */
/obj/effect/landmark/atmospheric_sanity/mark_all_station_areas_as_goal
	name = "Atmospheric Sanity Mark All Station Areas as a Goal"
	icon_state = "atmos_sanity_station_goal"

/**
 * Marks an area as a starting point for crawling atmospheric connectivity.
 */
/obj/effect/landmark/atmospheric_sanity/start_area
	name = "Atmospheric Sanity Start"
	icon_state = "atmos_sanity_start"

/**
 * Marks an area as a goal for atmospheric connectivity; ignored if the map contains the mark all station areas landmark!
 */
/obj/effect/landmark/atmospheric_sanity/goal_area
	name = "Atmospheric Sanity Goal"
	icon_state = "atmos_sanity_goal"

/**
 * Marks an area as ignored for purposes of default station connectivity.
 */
/obj/effect/landmark/atmospheric_sanity/ignore_area
	name = "Atmospheric Sanity Ignore"
	icon_state = "atmos_sanity_ignore"
