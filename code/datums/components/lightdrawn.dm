
/**
  * Drawn to light component
  *
  * This component adds game mechanics to emulate the moth lamp meme
  */
/datum/component/lightdrawn
	var/next_move /// Next time we can move
	var/move_delay = 2 SECONDS /// How often we move
	var/next_message /// Limiter to stop LAMP spam
	var/light_mood = 100 /// current light mood
	var/light_mood_threshold = 50 /// threshold below which lamp memes happen
	var/light_level_threshold = 1 /// threshold to compare with [/atom/movable/lighting_object/var/cached_max]
	var/mesmerised = FALSE /// boolean to track druggy/mesmerised overlay add/remove

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

	var/tint_factor = 1

	if(iscarbon(parent))
		var/mob/living/carbon/C = parent
		if(C?.glasses?.tint)
			tint_factor = 1/(1 + C.glasses.tint)

	// update their mood
	var/change = (((T.lighting_object.cached_max * tint_factor) - light_level_threshold) ** 2)*10
	if((T.lighting_object.cached_max * tint_factor) < light_level_threshold)
		light_mood -= change
	else
		light_mood += change

	light_mood = clamp(light_mood, 0, 100)
	switch(light_mood)
		if(0 to light_mood_threshold/2)
			SEND_SIGNAL(parent, COMSIG_ADD_MOOD_EVENT, "missing_the_light", /datum/mood_event/missing_the_light_a_lot)
		if(light_mood_threshold/2 to light_mood_threshold)
			SEND_SIGNAL(parent, COMSIG_ADD_MOOD_EVENT, "missing_the_light", /datum/mood_event/missing_the_light)

	var/mob/living/living_parent = parent
	if(light_mood >= light_mood_threshold)
		if(mesmerised)
			living_parent.clear_fullscreen("mesmerised")
			SEND_SIGNAL(living_parent, COMSIG_CLEAR_MOOD_EVENT, "missing_the_light")
			mesmerised = FALSE
		return	// mood is okay, done here

	if((T.lighting_object.cached_max * tint_factor) < light_level_threshold)
		return  // not bright enough, done here

	living_parent.Stun(2 SECONDS)

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
		var/brightness = light.light_power * light.light_range
		var/distance = max(1, get_dist(living_parent, light.source_turf))
		var/thislightsrelativebrightness = brightness/brightness*sqrt(distance)^2/distance
		if(thislightsrelativebrightness > brightestest)
			brightest = light
			brightestest = thislightsrelativebrightness

	if(!brightest)
		return // no valid light to go to but their mood is still rising

	step_to(living_parent, brightest.source_turf)

	if(next_message < world.time)
		to_chat(living_parent, "<span class='narsie'>...LÄMP...</span>")
		next_message = world.time + 8 SECONDS

	next_move = world.time + move_delay

/datum/mood_event/missing_the_light
	description = "<span class='warning'>I miss the light.</span>\n"
	mood_change = -2
	timeout = 5 MINUTES

/datum/mood_event/missing_the_light_a_lot
	description = "<span class='warning'>I miss the light A LOT.</span>\n"
	mood_change = -4
	timeout = 5 MINUTES

/datum/mood_event/mesmerised
	description = "<span class='warning'>...LÄMP...</span>"
	mood_change = 10
	special_screen_obj = "mood_lamp"
	timeout = 2 MINUTES
