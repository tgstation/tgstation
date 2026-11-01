/// Whether the Ratwood farming runs: on medieval maps, as the rest of the rogue mechanics. It decides whether soil, saplings and
/// composters work by themselves and whether TG seed packs take the Ratwood look; the soil itself is only ever on medieval maps.
/proc/rogue_farming_enabled()
	return rogue_combat_enabled()

/// Ratwood get_farming_effort_multiplier(): how much a farmer's work tells, 1 unskilled and more for every farming rank.
/mob/living/proc/rogue_farming_effort()
	return 1 + rogue_learned_rank(ROGUE_FARMING_SKILL) * rogue_value("farm_effort_rank")

/// Ratwood get_farming_do_time(): how long a farm task of this length takes this farmer, shorter for every farming rank.
/mob/living/proc/rogue_farming_time(time)
	return time / (1 + rogue_learned_rank(ROGUE_FARMING_SKILL) * rogue_value("farm_speed_rank"))

/// Ratwood apply_farming_fatigue(): the stamina farm work costs, less for a better farmer.
/mob/living/proc/rogue_farming_fatigue(amount)
	adjust_stamina_loss(amount / rogue_farming_effort())

/// Ratwood add_sleep_experience(user, farming, STAINT * share): farming experience by intelligence (dreamt from Apprentice on).
/mob/living/proc/rogue_farming_experience(share)
	return rogue_craft_experience(ROGUE_FARMING_SKILL, rogue_stat(ROGUE_STAT_INTELLIGENCE) * share)

/// Whether this one tells seeds apart (Ratwood seeds and herb seeds examine()): seed knowers and farmers from Apprentice on; herb
/// seeds also expert herb finders and alchemists from Apprentice on. Ghosts know them all.
/proc/rogue_knows_seeds(mob/user, herbs = FALSE)
	if(!isliving(user))
		return TRUE
	var/mob/living/viewer = user
	if(HAS_TRAIT(viewer, TRAIT_SEEDKNOW))
		return TRUE
	var/rank = rogue_value("farm_seed_know_rank")
	if(viewer.rogue_learned_rank(ROGUE_FARMING_SKILL) >= rank)
		return TRUE
	return herbs && (HAS_TRAIT(viewer, TRAIT_LEGENDARY_ALCHEMIST) || viewer.rogue_learned_rank(/datum/attribute/skill/craft/alchemy) >= rank)

/// Whether rain falls on this spot (Ratwood soil process(): the running weather is rain and the soil is under the open sky). The
/// Rockhill sky is its sunlit areas, the ones its weather falls on.
/proc/rogue_rain_falls_on(atom/spot)
	var/area/rogue/place = get_area(spot)
	if(!istype(place) || !place.rockhill_sunlit)
		return FALSE
	var/datum/weather/particle/rockhill/weather = SSrockhill_weather.active_weather()
	if(!istype(weather, /datum/weather/particle/rockhill/rain_gentle) && !istype(weather, /datum/weather/particle/rockhill/rain_storm))
		return FALSE
	return weather.stage == MAIN_STAGE && (place in weather.impacted_areas)

/// Whether a spot sees the sky, so that crops grow there (Ratwood can_see_sky): on the Rockhill map its sunlit areas; elsewhere
/// (an admin's soil on another map) everywhere.
/proc/rogue_under_open_sky(atom/spot)
	var/area/rogue/place = get_area(spot)
	return !istype(place) || place.rockhill_sunlit
