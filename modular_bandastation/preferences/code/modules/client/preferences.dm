#define BASE_LOADOUT_POINTS 5
#define LOADOUT_POINTS_PER_DONATION_LEVEL 3
#define BASE_SAVE_SLOTS 5
#define MAX_SAVE_SLOTS 9
#define SAVE_SLOTS_PER_DONATOR_LEVEL 1

/datum/preferences
	max_save_slots = BASE_SAVE_SLOTS
	var/loadout_points_spent = 0
	var/is_byond_member = FALSE

/datum/preferences/New(client/parent)
	. = ..()
	max_save_slots = clamp(BASE_SAVE_SLOTS + parent.get_donator_level() * SAVE_SLOTS_PER_DONATOR_LEVEL, BASE_SAVE_SLOTS, MAX_SAVE_SLOTS)

/datum/preferences/refresh_membership()
	. = ..()
	is_byond_member = unlock_content

	if(parent.get_donator_level() >= DONATOR_TIER_2)
		unlock_content = TRUE

/datum/preferences/proc/get_loadout_max_points()
	return BASE_LOADOUT_POINTS + parent.get_donator_level() * LOADOUT_POINTS_PER_DONATION_LEVEL

/datum/preference/choiced/ghost_orbit/create_default_value()
	return GHOST_ORBIT_CIRCLE

#undef BASE_LOADOUT_POINTS
#undef LOADOUT_POINTS_PER_DONATION_LEVEL
#undef BASE_SAVE_SLOTS
#undef MAX_SAVE_SLOTS
#undef SAVE_SLOTS_PER_DONATOR_LEVEL
