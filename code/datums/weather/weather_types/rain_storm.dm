/datum/weather/rain_storm
	name = "rain"
	desc = "Heavy thunderstorms rain down below, drenching anyone caught in it."

	telegraph_message = span_danger("Thunder rumbles far above. You hear droplets drumming against the canopy.")
	telegraph_overlay = "rain_low"
	telegraph_duration = 30 SECONDS

	weather_message = span_userdanger("<i>Rain pours down around you!</i>")
	weather_overlay = "rain_high"

	end_message = span_bolddanger("The downpour gradually slows to a light shower.")
	end_overlay = "rain_low"
	end_duration = 30 SECONDS

	weather_duration_lower = 3 MINUTES
	weather_duration_upper = 5 MINUTES

	weather_color = null
	thunder_color = null

	area_type = /area
	target_trait = ZTRAIT_RAINSTORM
	immunity_type = TRAIT_RAINSTORM_IMMUNE
	probability = 90

	weather_flags = (WEATHER_TURFS | WEATHER_MOBS | WEATHER_THUNDER | WEATHER_BAROMETER)
	whitelist_weather_reagents = list(/datum/reagent/water)

/datum/weather/rain_storm/telegraph()
	GLOB.rain_storm_sounds.Cut()
	for(var/area/impacted_area as anything in impacted_areas)
		GLOB.rain_storm_sounds[impacted_area] = /datum/looping_sound/rain/start
	return ..()

/datum/weather/rain_storm/start()
	GLOB.rain_storm_sounds.Cut()
	for(var/area/impacted_area as anything in impacted_areas)
		GLOB.rain_storm_sounds[impacted_area] = /datum/looping_sound/rain/middle
	return ..()

/datum/weather/rain_storm/wind_down()
	GLOB.rain_storm_sounds.Cut()
	for(var/area/impacted_area as anything in impacted_areas)
		GLOB.rain_storm_sounds[impacted_area] = /datum/looping_sound/rain/end
	return ..()

/datum/weather/rain_storm/end()
	GLOB.rain_storm_sounds.Cut()
	return ..()

/datum/weather/rain_storm/blood
	whitelist_weather_reagents = list(/datum/reagent/blood)
	probability = 0 // admeme event

// Fun fact - if you increase the weather_temperature higher than LIQUID_PLASMA_BP
// the plasma rain will vaporize into a gas on whichever turf it lands on
/datum/weather/rain_storm/plasma
	whitelist_weather_reagents = list(/datum/reagent/toxin/plasma)
	probability = 0 // maybe for icebox maps one day?

/datum/weather/rain_storm/deep_fried
	weather_temperature = 455 // just hot enough to apply the fried effect
	whitelist_weather_reagents = list(/datum/reagent/consumable/nutriment/fat/oil)
	weather_flags = (WEATHER_TURFS | WEATHER_INDOORS)
	probability = 0 // admeme event

/datum/weather/rain_storm/acid
	desc = "The planet's thunderstorms are by nature acidic, and will incinerate anyone standing beneath them without protection."

	telegraph_duration = 40 SECONDS
	telegraph_message = span_warning("Thunder rumbles far above. You hear acidic droplets hissing against the canopy. Seek shelter!")
	telegraph_sound = 'sound/effects/siren.ogg'

	weather_message = span_userdanger("<i>Acidic rain pours down around you! Get inside!</i>")
	weather_duration_lower = 1 MINUTES
	weather_duration_upper = 2 MINUTES

	end_duration = 10 SECONDS
	end_message = span_bolddanger("The downpour gradually slows to a light shower. It should be safe outside now.")

	// these are weighted by acidpwr which causes more damage the higher it is
	whitelist_weather_reagents = list(
		/datum/reagent/toxin/acid/nitracid = 3,
		/datum/reagent/toxin/acid = 2,
		/datum/reagent/toxin/acid/fluacid = 1,
	)
	probability = 0

/datum/weather/rain_storm/wizard
	name = "magical rain"
	desc = "A magical thunderstorm rains down below, drenching anyone caught in it with mysterious rain."

	telegraph_message = span_danger("A magical rain cloud appears above. You hear droplets falling down.")
	protected_areas = list(
		/area/station/maintenance, /area/station/ai_monitored/turret_protected/ai_upload,
		/area/station/ai_monitored/turret_protected/ai_upload_foyer, /area/station/ai_monitored/turret_protected/aisat/maint,
		/area/station/ai_monitored/command/storage/satellite, /area/station/ai_monitored/turret_protected/ai,
		/area/station/commons/storage/emergency/starboard, /area/station/commons/storage/emergency/port,
		/area/shuttle, /area/station/security/prison/safe, /area/station/security/prison/toilet, /area/mine/maintenance,
		/area/icemoon/underground, /area/ruin/comms_agent/maint
	)

	// same time durations as floor_is_lava event
	telegraph_duration = 15 SECONDS
	weather_duration_lower = 30 SECONDS
	weather_duration_upper = 1 MINUTES
	end_duration = 0 SECONDS
	target_trait = ZTRAIT_STATION

	turf_weather_chance = 0.02 // double the turf chance
	whitelist_weather_reagents = list()
	probability = 0 // shouldn't spawn normally
	weather_flags = (WEATHER_TURFS | WEATHER_MOBS | WEATHER_INDOORS | WEATHER_BAROMETER)

/datum/weather/rain_storm/wizard/New(z_levels, list/weather_data)
	if(length(GLOB.wizard_rain_reagents)) // the wizard event has already been run once and setup the whitelist
		whitelist_weather_reagents = GLOB.wizard_rain_reagents
		return ..()

	// most medicine do nothing when it comes into contact with turfs or mobs (via TOUCH) except for a few
	var/list/allowed_medicine = list(
		/datum/reagent/medicine/c2/synthflesh,
		/datum/reagent/medicine/adminordrazine,
		/datum/reagent/medicine/strange_reagent,
		// include a random medicine
		pick(subtypesof(/datum/reagent/medicine)),
	)
	GLOB.wizard_rain_reagents |= allowed_medicine

	// One randomized type is allowed so the whitelist isn't spammed with subtypes
	GLOB.wizard_rain_reagents |= pick(subtypesof(/datum/reagent/glitter))
	GLOB.wizard_rain_reagents |= pick(subtypesof(/datum/reagent/mutationtoxin))
	GLOB.wizard_rain_reagents |= pick(subtypesof(/datum/reagent/plantnutriment))
	GLOB.wizard_rain_reagents |= pick(subtypesof(/datum/reagent/impurity))
	GLOB.wizard_rain_reagents |= pick(subtypesof(/datum/reagent/drug))
	GLOB.wizard_rain_reagents |= pick(typesof(/datum/reagent/uranium))
	GLOB.wizard_rain_reagents |= pick(typesof(/datum/reagent/luminescent_fluid))
	GLOB.wizard_rain_reagents |= pick(typesof(/datum/reagent/carpet))
	GLOB.wizard_rain_reagents |= pick(typesof(/datum/reagent/water))
	GLOB.wizard_rain_reagents |= pick(typesof(/datum/reagent/fuel))
	GLOB.wizard_rain_reagents |= pick(typesof(/datum/reagent/colorful_reagent))
	GLOB.wizard_rain_reagents |= pick(typesof(/datum/reagent/ants))
	GLOB.wizard_rain_reagents |= pick(typesof(/datum/reagent/lube))
	GLOB.wizard_rain_reagents |= pick(typesof(/datum/reagent/space_cleaner))

	// lots of toxins do nothing so we need to be picky
	var/list/allowed_toxins = list(
		/datum/reagent/toxin/itching_powder,
		/datum/reagent/toxin/polonium, // radiation
		/datum/reagent/toxin/mutagen,
		// all the acids
		/datum/reagent/toxin/acid,
		/datum/reagent/toxin/acid/fluacid,
		/datum/reagent/toxin/acid/nitracid,
		// include a random toxin
		pick(subtypesof(/datum/reagent/toxin)),
	)
	GLOB.wizard_rain_reagents |= allowed_toxins

	// too many food & drinks so blacklist most of them
	var/list/allowed_food_drinks = list(
		/datum/reagent/consumable/ethanol/wizz_fizz,
		/datum/reagent/consumable/condensedcapsaicin,
		/datum/reagent/consumable/frostoil,
		// include a random food or drink
		pick(subtypesof(/datum/reagent/consumable)),
		// include a random regular drink (vodka, wine, beer, etc.)
		pick(/obj/machinery/chem_dispenser/drinks/beer::beer_dispensable_reagents),
	)
	GLOB.wizard_rain_reagents |= allowed_food_drinks

	var/list/allowed_exotic_reagents = list(
		// fire
		/datum/reagent/clf3,
		/datum/reagent/phlogiston,
		/datum/reagent/napalm,
		// cosmetic
		/datum/reagent/hair_dye,
		/datum/reagent/barbers_aid,
		/datum/reagent/baldium,
		/datum/reagent/mulligan,
		/datum/reagent/growthserum,
		// op shit
		/datum/reagent/romerol,
		/datum/reagent/gondola_mutation_toxin,
		/datum/reagent/metalgen,
		/datum/reagent/flightpotion,
		/datum/reagent/eigenstate,
		/datum/reagent/magillitis,
		/datum/reagent/pax,
		/datum/reagent/gluttonytoxin,
		/datum/reagent/aslimetoxin,
		// misc
		/datum/reagent/blood,
		/datum/reagent/hauntium,
		/datum/reagent/copper,
	)
	GLOB.wizard_rain_reagents |= allowed_exotic_reagents

	// add a few randomized reagents not listed above so they at least have a chance
	GLOB.wizard_rain_reagents |= pick(subtypesof(/datum/reagent))
	GLOB.wizard_rain_reagents |= pick(subtypesof(/datum/reagent))
	GLOB.wizard_rain_reagents |= pick(subtypesof(/datum/reagent))

	whitelist_weather_reagents = GLOB.wizard_rain_reagents
	return ..()
