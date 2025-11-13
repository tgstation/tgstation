//Radiation storms occur when the station passes through an irradiated area, and irradiate anyone not standing in protected areas (maintenance, emergency storage, etc.)
/datum/weather/rad_storm
	name = "radiation storm"
	desc = "A cloud of intense radiation passes through the area dealing rad damage to those who are unprotected."

	telegraph_duration = 40 SECONDS
	telegraph_message = span_danger("The air begins to grow warm.")

	weather_message = span_userdanger("<i>You feel waves of heat wash over you! Find shelter!</i>")
	weather_overlay = "ash_storm"
	weather_duration_lower = 1 MINUTES
	weather_duration_upper = 2.5 MINUTES
	weather_color = "green"
	weather_sound = 'sound/announcer/alarm/bloblarm.ogg'

	end_duration = 10 SECONDS
	end_message = span_notice("The air seems to be cooling off again.")

	area_type = /area
	protected_areas = list(
		// General areas
		/area/station/maintenance, // This is where we tell people to go
		/area/shuttle, // Would be quite rude

		// AI
		/area/station/ai/satellite/maintenance, // Duh...
		/area/station/ai/upload,
		/area/station/ai/satellite/chamber,

		// Rad shelters
		/area/station/commons/storage/emergency/starboard,
		/area/station/commons/storage/emergency/port,

		// Prison
		/area/station/security/prison/safe,
		/area/station/security/prison/toilet,

		// Off-station
		/area/mine/maintenance,
		/area/ruin/comms_agent/maint,
		/area/icemoon/underground,
	)
	target_trait = ZTRAIT_STATION

	immunity_type = TRAIT_RADSTORM_IMMUNE
	weather_flags = (WEATHER_MOBS | WEATHER_INDOORS)
	/// Chance we get a negative mutation, if we fail we get a positive one
	var/negative_mutation_chance = 90
	/// Chance we irradiate
	var/irradiate_chance = 40

/datum/weather/rad_storm/telegraph()
	..()
	status_alarm(TRUE)


/datum/weather/rad_storm/weather_act_mob(mob/living/living)
	if(!prob(irradiate_chance))
		return

	if(!ishuman(living) || HAS_TRAIT(living, TRAIT_GODMODE))
		return

	var/mob/living/carbon/human/human = living

	if (SSradiation.wearing_rad_protected_clothing(human))
		return

	if(human.can_mutate())
		human.random_mutate_unique_identity()
		human.random_mutate_unique_features()

	if(!HAS_TRAIT(human, TRAIT_RADIMMUNE))
		human.takeRadiation(1, 20) // Very high maximum, radiation storms are evil and this is still far nicer than random mutations

	return ..()

/datum/weather/rad_storm/end()
	if(..())
		return
	priority_announce("The radiation threat has passed. Please return to your workplaces.", "Anomaly Alert")
	status_alarm(FALSE)

/datum/weather/rad_storm/proc/status_alarm(active) //Makes the status displays show the radiation warning for those who missed the announcement.
	if (active)
		send_status_display_radiation_alert()
	else
		clear_status_display_radiation()

/// Used by the radioactive nebula when the station doesnt have enough shielding
/datum/weather/rad_storm/nebula
	protected_areas = list(/area/shuttle, /area/station/maintenance/radshelter)

	weather_overlay = "nebula_radstorm"
	end_message = null
	weather_flags = parent_type::weather_flags | WEATHER_ENDLESS

	irradiate_chance = 0.1
	///Chance we pulse a living during the storm
	var/pulse_chance = 5

/datum/weather/rad_storm/nebula/weather_act_mob(mob/living/living)
	..()

	if(!prob(pulse_chance))
		return

	if(!SSradiation.can_irradiate_basic(living) || SSradiation.wearing_rad_protected_clothing(living))
		return

	radiation_pulse(
		source = living,
		max_range = 0,
		threshold = RAD_LIGHT_INSULATION,
		chance = URANIUM_IRRADIATION_CHANCE,
		power = 1,
		max_power = RAD_STAGE_REQUIREMENTS[3],
	)

/datum/weather/rad_storm/nebula/status_alarm(active)
	if(!active) //we stay on
		return
	..()
