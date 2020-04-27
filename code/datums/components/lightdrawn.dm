
/**
  * Drawn to light component
  *
  * This component adds game mechanics to emulate the moth chasing a lamp meme
  */
/datum/component/lightdrawn
	/// Next time we can move
	var/next_move
	/// How often we move
	var/move_delay = 2 SECONDS
	/// Limiter to stop LAMP spam
	var/next_message
	/// current light mood
	var/light_mood = 100
	/// threshold below which lamp memes happen
	var/light_mood_threshold = 50
	/// threshold to compare with [/atom/movable/lighting_object/var/cached_max]
	var/light_level_threshold = 1
	/// boolean to track druggy/mesmerised overlay add/remove
	var/mesmerised = FALSE

/datum/component/lightdrawn/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()

	START_PROCESSING(SSprocessing, src)

/datum/component/lightdrawn/Destroy(force, silent)
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/component/lightdrawn/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_LIVING_FLASH_ACT, VARSET_CALLBACK(src, light_mood, 100))

/datum/component/lightdrawn/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_LIVING_FLASH_ACT)

/datum/component/lightdrawn/process()
	var/turf/T = get_turf(parent)
	if(!T)
		return

	var/mob/living/living_parent = parent

	///The amount our ssight is tinted by, such as glasses
	var/tint_factor = 1
	///The brightness multplier for the seen brightness
	var/brightness_mult = 1

	if(iscarbon(parent))
		var/mob/living/carbon/C = parent
		var/totaltint = 0
		totaltint = C.get_total_tint()
		tint_factor = 1/(1 + totaltint)

	///The actual brightness we "see"
	var/apparent_brightness = T.lighting_object.cached_max * tint_factor * brightness_mult

	// update their mood
	if(living_parent.loc != T) // inside something
		apparent_brightness = 0 // its dark inside things
		light_mood -= 4
	else
		var/change = ((apparent_brightness - light_level_threshold) ** 2)*10

		if(apparent_brightness < light_level_threshold)
			light_mood -= change
		else
			change *= 1.5	//Regen lightmood faster than we lose it so we dont spend 5 minutes running at a lamp
			light_mood += change

	light_mood = clamp(light_mood, 0, 100)
	switch(light_mood)
		if(0 to light_mood_threshold * 0.5)
			SEND_SIGNAL(parent, COMSIG_ADD_MOOD_EVENT, "missing_the_light", /datum/mood_event/missing_the_light_a_lot)
		if((light_mood_threshold * 0.5) to light_mood_threshold)

			SEND_SIGNAL(parent, COMSIG_ADD_MOOD_EVENT, "missing_the_light", /datum/mood_event/missing_the_light)

	if(light_mood >= light_mood_threshold)
		if(mesmerised)
			living_parent.clear_fullscreen("mesmerised")
			SEND_SIGNAL(living_parent, COMSIG_CLEAR_MOOD_EVENT, "missing_the_light")
			mesmerised = FALSE
		return	// mood is okay, done here

	if(apparent_brightness < light_level_threshold)
		return  // not bright enough, done here

	living_parent.Stun(1 SECONDS)

	if(!mesmerised)
		living_parent.overlay_fullscreen("mesmerised", /obj/screen/fullscreen/high)
		SEND_SIGNAL(living_parent, COMSIG_ADD_MOOD_EVENT, "missing_the_light", /datum/mood_event/mesmerised)
		mesmerised = TRUE

	if(next_move > world.time)
		return

	var/datum/light_source/brightest
	var/brightestest = -1
	for(var/l in T.affecting_lights)
		var/datum/light_source/light = l
		if(light.source_atom == living_parent)
			continue
		///How bright a certain light is
		var/brightness = light.light_power * light.light_range
		///distance to a certain light
		var/distance = max(1, get_dist(living_parent, light.source_turf))
		///relative brightness of the light, factoring in distance from the mob being affected
		var/thislightsrelativebrightness = brightness/brightness*sqrt(distance)**2/distance

		if(thislightsrelativebrightness > brightestest)
			brightest = light
			brightestest = thislightsrelativebrightness

	if(!brightest)
		return // no valid light to go to but their mood is still rising
	if(living_parent.client)
		living_parent.client.Move(living_parent, brightest.source_turf)

	if(next_message < world.time)
		to_chat(living_parent, "<span class='hypnophrase'>...LÄMP...</span>")
		next_message = world.time + 8 SECONDS
		if(prob(50))
			living_parent.say("So pretty...", forced = "mesmerised")

	next_move = world.time + move_delay
