/// Tray Setters - The following macros adjust the hydroponics tray variables, and make sure that the stat doesn't go out of bounds.
/**
 * Adjust water.
 * Raises or lowers tray water values by a set value. Adding water will dillute toxicity from the tray.
 * * adjustamt - determines how much water the tray will be adjusted upwards or downwards.
 */
#define TRAY_ADJUST_WATER(tray, amt) tray.set_waterlevel(clamp(tray.waterlevel + amt, 0, tray.maxwater), FALSE)

/**
 * Adjust Health.
 * Raises the tray's plant_health stat by a given amount, with total health determined by the seed's endurance.
 * * adjustamt - Determines how much the plant_health will be adjusted upwards or downwards.
 */
#define TRAY_ADJUST_HEALTH(tray, amt) tray.set_plant_health(clamp(tray.plant_health + amt, 0, tray.myseed?.endurance), FALSE)

/**
 * Adjust toxicity.
 * Raises the plant's toxic stat by a given amount.
 * * adjustamt - Determines how much the toxic will be adjusted upwards or downwards.
 */
#define TRAY_ADJUST_TOXIC(tray, amt) tray.set_toxic(clamp(tray.toxic + amt, 0, MAX_TRAY_TOXINS), FALSE)

/**
 * Adjust Pests.
 * Raises the tray's pest level stat by a given amount.
 * * adjustamt - Determines how much the pest level will be adjusted upwards or downwards.
 */
#define TRAY_ADJUST_PESTS(tray, amt) tray.set_pestlevel(clamp(tray.pestlevel + amt, 0, MAX_TRAY_PESTS), FALSE)


/**
 * Adjust Weeds.
 * Raises the plant's weed level stat by a given amount.
 * * adjustamt - Determines how much the weed level will be adjusted upwards or downwards.
 */
#define TRAY_ADJUST_WEEDS(tray, amt) tray.set_weedlevel(clamp(tray.weedlevel + amt, 0, MAX_TRAY_WEEDS), FALSE)
