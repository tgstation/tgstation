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

	/// Current weather severity
	var/severity = 0
	/// Last tick during which we've changed our visual severity
	var/last_severity_tick = 0
	/// List of weather object lists (as we can have multiple if emissives are involved) by plane offset
	var/list/weather_objects = list()

/datum/weather/particle/New(z_levels, list/weather_data)
	. = ..()
	if (isnull(particle_type) && isnull(emissive_type))
		CRASH("[src] ([type]) attempted to initialize without normal or emissive particle types!")

	for (var/offset in 0 to SSmapping.max_plane_offset)
		var/list/object_list = list()
		if (particle_type)
			var/obj/effect/abstract/weather_holder/holder = new()
			SET_PLANE_W_SCALAR(holder, PARTICLE_WEATHER_PLANE, offset)
			holder.particles = new particle_type()
			object_list += holder

		if (emissive_type)
			var/obj/effect/abstract/weather_holder/emissive/holder = new()
			holder.particles = new emissive_type()
			SET_PLANE_W_SCALAR(holder, EMISSIVE_PARTICLE_WEATHER_PLANE, offset)
			object_list += holder

		weather_objects += list(object_list)

	SSweather.add_weather_objects(weather_objects)

/datum/weather/particle/Destroy()
	SSweather.remove_weather_objects(weather_objects)
	QDEL_LIST(weather_objects)
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
			// Aims at half of optimal severity, and can only go up
			new_severity += rand() * severity_variation * (1 - severity / (optimal_severity / 2))
		if (MAIN_STAGE)
			// Tries to stay close to optimal severity
			new_severity += LERP(-severity_variation * clamp(INVERSE_LERP(min_severity, optimal_severity, severity), 0, 1), severity_variation * clamp(INVERSE_LERP(max_severity, optimal_severity, severity), 0, 1), rand())
			new_severity = clamp(new_severity, min(new_severity, min_severity), max_severity)
		if (WIND_DOWN_STAGE)
			// Slowly goes down to zero
			new_severity += rand() * -severity_variation * max(severity / min_severity, 1)

	animate_severity(new_severity)

/datum/weather/particle/proc/animate_severity(new_severity)
	severity = new_severity
	for (var/list/holder_list as anything in weather_objects)
		for (var/obj/effect/abstract/weather_holder/holder as anything in holder_list)
			var/particles/weather/particle_effect = holder.particles
			particle_effect.animate_severity(severity / MAXIMUM_WEATHER_SEVERITY)

/datum/weather/particle/generate_overlay_cache()
	var/list/gen_overlay_cache = list()
	for (var/offset in 0 to SSmapping.max_plane_offset)
		gen_overlay_cache += mutable_appearance('icons/effects/weather_overlay.dmi', "weather_overlay", overlay_layer, null, WEATHER_MASK_PLANE, offset_const = offset)
	return gen_overlay_cache

/obj/effect/abstract/weather_holder
	appearance_flags = TILE_BOUND | PIXEL_SCALE
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE // For particles to block tile emissives
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/abstract/weather_holder/emissive
	blocks_emissive = EMISSIVE_BLOCK_NONE

/particles/weather
	spawning = 0
	// Wider than our view due to weird BYOND jank
	width = 800
	height = 800
	count = 5000

	lifespan = 30 SECONDS
	fade = 1 SECONDS
	fadein = 0.5 SECONDS

	// Obnoxiously 3D -- INCREASE Z level to make them further away
	transform = list(
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0.25,
		0, 0, 0, 1,
	)

	/// Increase in speed per tick
	var/wind_strength = 0
	/// Minimum number of spawned particles per tick for easing
	var/min_spawn = 0
	/// Maximum amount of spawned particles at full strength
	var/max_spawn = 0

/// Changes the strength of the weather visual effect, severity should be between 0 and 1
/particles/weather/proc/animate_severity(severity)
	// Stop spawning if severity is zero or negative
	if (severity <= 0)
		spawning = 0
		return

	// If we already have gravity, keep the wind direction, otherwise pick randomly between east and west
	var/wind = wind_strength * severity * ((gravity && gravity[1]) ? gravity[1] : pick(-1, 1))
	spawning = LERP(min_spawn, max_spawn, severity)
	// Might already be set on init, in which case we preserve y and z components
	if (length(gravity))
		gravity[1] = wind
	else
		gravity = list(wind)

