/// Subtype which uses particle systems instead of overlays to display its effects
/datum/weather/particle
	abstract_type = /datum/weather/particle
	/// Particles used to display the weather visuals
	var/particles/weather/particle_type = null
	/// Secondary (layered ontop) particle type which is rendered as emissive in case you want embers or whatever
	var/particles/weather/emissive_type = null
	/// Minimum possible severity for the weather, (0~100]
	var/min_severity = 1
	/// Maximum possible severity for the weather, (0~100]
	var/max_severity = MAXIMUM_WEATHER_SEVERITY
	/// Maximum variation in severity each weather frame
	var/severity_variation = 5
	/// Optimal point towards which severity will try to gravitate by influencing random values
	var/optimal_severity = 70
	/// How often can we change our severity?
	/// Don't set this too low or it'll look jank
	var/severity_cooldown = 5 SECONDS
	/// Alpha of the area overlay when the particle weather pref is enabled
	var/particle_weather_alpha = 255

	/// Current weather severity
	var/severity = 0
	/// Last tick during which we've changed our visual severity
	var/last_severity_tick = 0
	/// List of weather object lists (as we can have multiple if emissives are involved) by plane offset
	var/list/weather_objects = list()
	/// Direction of our wind
	var/wind_sign = 0

/datum/weather/particle/New(list/z_levels, list/weather_data)
	. = ..()
	if (isnull(particle_type) && isnull(emissive_type))
		CRASH("[src] ([type]) attempted to initialize without normal or emissive particle types!")

	for (var/offset in 0 to SSmapping.max_plane_offset)
		var/list/object_list = list()
		if (particle_type)
			var/obj/effect/abstract/weather_holder/holder = new()
			SET_PLANE_W_SCALAR(holder, RENDER_PLANE_PARTICLE_WEATHER, offset)
			holder.particles = new particle_type()
			object_list[holder] = impacted_z_levels

		if (emissive_type)
			var/obj/effect/abstract/weather_holder/holder = new()
			holder.particles = new emissive_type()
			SET_PLANE_W_SCALAR(holder, RENDER_PLANE_EMISSIVE_PARTICLE_WEATHER, offset)
			object_list[holder] = impacted_z_levels

		weather_objects += list(object_list)

	SSweather.add_weather_objects(weather_objects)

/datum/weather/particle/Destroy()
	SSweather.remove_weather_objects(weather_objects)
	for(var/list/object_list as anything in weather_objects)
		QDEL_LIST(object_list)
	weather_objects = null
	return ..()

/datum/weather/particle/telegraph(list/weather_data)
	. = ..()
	if (!.)
		return
	animate_severity(0)

/datum/weather/particle/end()
	. = ..()
	if (!.)
		return
	animate_severity(0)

/// Adjust our severity by a random number based on our stage
/datum/weather/particle/proc/process_particles()
	if (last_severity_tick + severity_cooldown > world.time)
		return

	last_severity_tick = world.time
	var/new_severity = severity
	switch (stage)
		if (STARTUP_STAGE)
			// Aims at minimum severity, and can only go up
			new_severity += rand() * severity_variation * (1 - severity / min_severity)
		if (MAIN_STAGE)
			// Tries to stay close to optimal severity
			new_severity += LERP(-severity_variation * clamp(INVERSE_LERP(min_severity, optimal_severity, severity), 0, 1), severity_variation * clamp(INVERSE_LERP(max_severity, optimal_severity, severity), 0, 1), rand())
			new_severity = clamp(new_severity, min(new_severity, min_severity), max_severity)
		if (WIND_DOWN_STAGE)
			// Slowly goes down to zero
			new_severity += rand() * -severity_variation * 4 * max(severity / min_severity, 1)

	animate_severity(new_severity)

/datum/weather/particle/proc/animate_severity(new_severity)
	if (!wind_sign)
		wind_sign = pick(-1, 1)

	severity = new_severity
	for (var/list/holder_list as anything in weather_objects)
		for (var/obj/effect/abstract/weather_holder/holder as anything in holder_list)
			var/particles/weather/particle_effect = holder.particles
			particle_effect.animate_severity(severity / MAXIMUM_WEATHER_SEVERITY, wind_sign)

/datum/weather/particle/generate_overlay_cache()
	. = ..()

	if (stage == END_STAGE)
		return

	// Change alpha of overlays on the particle weather plane
	for(var/mutable_appearance/overlay as anything in .)
		if (PLANE_TO_TRUE(overlay.plane) == PARTICLE_WEATHER_PLANE)
			overlay.alpha = particle_weather_alpha

	for (var/offset in 0 to SSmapping.max_plane_offset)
		. += mutable_appearance('icons/effects/weather_overlay.dmi', "weather_overlay", overlay_layer, null, WEATHER_MASK_PLANE, offset_const = offset)

/obj/effect/abstract/weather_holder
	icon = null
	appearance_flags = TILE_BOUND | PIXEL_SCALE
	blocks_emissive = EMISSIVE_BLOCK_NONE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/particles/weather
	spawning = 0
	// Wider than our view due to weird BYOND jank
	width = 800
	height = 800
	count = 8000

	lifespan = 30 SECONDS
	fade = 1 SECONDS
	fadein = 0.5 SECONDS

	/// Increase in speed per tick
	var/wind_strength = 0
	/// Minimum number of spawned particles per tick for easing
	var/min_spawn = 0
	/// Maximum amount of spawned particles at full strength
	var/max_spawn = 0

/// Changes the strength of the weather visual effect, severity should be between 0 and 1
/particles/weather/proc/animate_severity(severity, wind_sign)
	// Stop spawning if severity is zero or negative
	if (severity <= 0)
		spawning = 0
		return

	var/wind = wind_strength * severity * wind_sign
	spawning = LERP(min_spawn, max_spawn, severity)
	// Might already be set on init, in which case we preserve y and z components
	if (islist(gravity) && length(gravity))
		gravity[1] = wind
	else
		gravity = list(wind)

