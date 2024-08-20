GLOBAL_LIST_EMPTY(siren_objects)

#define GLE_STAGE_NONE		FALSE
#define GLE_STAGE_FIRST		1
#define GLE_STAGE_SECOND	2
#define GLE_STAGE_THIRD		3
#define GLE_STAGE_FOUR		4
#define GLE_TAGE_FIVE		5
#define GLE_STAGE_SIX		6

//SPECIAL EVENTS
/datum/weather_event
	var/name = ""
	var/affecting_value
	var/duration = 0
	var/started_at = 0
	var/repeats = 0
	var/max_stages = 0
	var/stage = GLE_STAGE_NONE
	var/stage_processing = FALSE
	var/datum/particle_weather/initiator_ref

/datum/weather_event/New(datum/particle_weather/particle_weather)
	..()
	initiator_ref = particle_weather
	start_process()

/datum/weather_event/Destroy(force, ...)
	. = ..()
	if(initiator_ref)
		initiator_ref.weather_additional_ongoing_events -= src
		initiator_ref = null

/datum/weather_event/proc/start_process()
	return

/datum/weather_event/proc/stage_process()
	return

/datum/weather_event/thunder
	name = "Thunder"
	duration = 1.5 SECONDS
	affecting_value = list("#74DFF7", "#81A7DB", "#7997FC", "#5b73c3", "#2e5fff")
	max_stages = 3
	stage = GLE_STAGE_FIRST
	var/sound_effects = list(
		'monkestation/code/modules/outdoors/sound/weather/rain/thunder_1.ogg', 'monkestation/code/modules/outdoors/sound/weather/rain/thunder_2.ogg', 'monkestation/code/modules/outdoors/sound/weather/rain/thunder_3.ogg', 'monkestation/code/modules/outdoors/sound/weather/rain/thunder_4.ogg',
		'monkestation/code/modules/outdoors/sound/weather/rain/thunder_5.ogg', 'monkestation/code/modules/outdoors/sound/weather/rain/thunder_6.ogg', 'monkestation/code/modules/outdoors/sound/weather/rain/thunder_7.ogg',
	)

/datum/weather_event/thunder/start_process()
	repeats = rand(1, 3)
	duration = duration + rand(-duration*5, duration*10)/10
	stage_processing = TRUE
	stage_process()

/datum/weather_event/thunder/stage_process()
	var/color_animating
	var/animate_flags = CIRCULAR_EASING
	switch(stage)
		if(GLE_STAGE_FIRST)
			color_animating = pick(affecting_value)
			animate_flags = ELASTIC_EASING | EASE_IN | EASE_OUT
			spawn(duration - rand(0, duration*10)/10)
				if(initiator_ref.plane_type == "Default")
					playsound_z(SSmapping.levels_by_trait(ZTRAIT_STATION), pick(sound_effects), 50, _mixer_channel = CHANNEL_WEATHER)
				else
					playsound_z(SSmapping.levels_by_trait(ZTRAIT_ECLIPSE), pick(sound_effects), 50, _mixer_channel = CHANNEL_WEATHER)
		if(GLE_STAGE_THIRD)
			if(SSoutdoor_effects.enabled)
				color_animating = SSoutdoor_effects.current_color
			animate_flags = CIRCULAR_EASING | EASE_IN

	if(color_animating && SSoutdoor_effects.enabled)
		for(var/atom/movable/screen/fullscreen/lighting_backdrop/sunlight/plane in SSoutdoor_effects.sunlighting_planes)
			animate(plane, color = color_animating, easing = animate_flags, time = duration)

	sleep(duration)
	stage++
	if(repeats && stage > max_stages)
		repeats--
		stage = GLE_STAGE_FIRST
		sleep(duration)

	else if(stage > max_stages)
		if(SSoutdoor_effects.enabled)
			SSoutdoor_effects.weather_light_affecting_event = null
			for(var/atom/movable/screen/fullscreen/lighting_backdrop/sunlight/plane in SSoutdoor_effects.sunlighting_planes)
				SSoutdoor_effects.transition_sunlight_color(plane)
		qdel(src)
		return

	stage_process()

/datum/weather_event/wind
	name = "Wind"
	duration = 10 SECONDS
	affecting_value = list("min_value" = 20, "max_value" = 80)
	max_stages = 2
	stage = GLE_STAGE_FIRST

/datum/weather_event/wind/start_process()
	duration = duration + rand(-duration, duration)
	stage_processing = TRUE
	stage_process()

/datum/weather_event/wind/stage_process()
	switch(stage)
		if(GLE_STAGE_FIRST)
			initiator_ref.wind_severity = rand(affecting_value["min_value"], affecting_value["max_value"])
		if(GLE_STAGE_SECOND)
			initiator_ref.wind_severity = rand(0, affecting_value["max_value"])
		if(GLE_STAGE_THIRD)
			initiator_ref.wind_severity = rand(0, affecting_value["min_value"])

	initiator_ref.change_severity(FALSE)

	sleep(duration)
	stage++
	if(repeats)
		repeats--
		stage = initial(stage)
		start_process()
		return

	else if(stage > max_stages)
		initiator_ref.wind_severity = 0
		qdel(src)
		return

	stage_process()


/datum/weather_effect
	var/name = "effect"
	var/probability = 0
	var/datum/particle_weather/initiator_ref

/datum/weather_effect/proc/effect_affect(turf/target_turf)
	return FALSE

/datum/weather_effect/rain
	name = "rain effect"
	probability = 20

/datum/weather_effect/rain/effect_affect(turf/target_turf)
	for(var/obj/effect/decal/cleanable/decal in target_turf)
		qdel(decal)

/datum/particle_weather
	var/name = "set this"
	var/display_name = "set this"
	var/desc = "set this"

	var/list/weather_messages = list()
	var/list/weather_warnings = list("siren" = null, "message" = TRUE)
	var/list/weather_sounds = list()
	var/list/indoor_weather_sounds = list()
	var/list/wind_sounds = list(/datum/looping_sound/wind)
	var/scale_vol_with_severity = TRUE

	var/particles/weather/particle_effect_type = /particles/weather/rain

	var/weather_duration_lower = 5 MINUTES
	var/weather_duration_upper = 20 MINUTES

	var/damage_type = null
	var/damage_per_tick = 0
	var/wind_severity = 0
	var/min_severity = 1
	var/max_severity = 100
	var/max_severity_change = 20
	var/severity_steps = 5
	var/immunity_type = TRAIT_WEATHER_IMMUNE
	var/probability = 0

	var/target_trait = PARTICLEWEATHER_RAIN
	var/severity_steps_taken = 0
	var/running = FALSE
	var/severity = 0
	var/barometer_predictable = FALSE

	COOLDOWN_DECLARE(time_left)
	var/weather_duration = 0
	var/weather_start_time = 0

	var/weather_special_effect
	var/list/weather_additional_events = list()
	var/list/datum/weather_event/weather_additional_ongoing_events = list()
	var/list/messaged_mobs = list()
	var/list/current_sounds = list()
	var/list/current_wind_sounds = list()
	var/list/affected_zlevels = list()
	var/fire_smothering_strength = 0

	var/last_message = ""

	var/plane_type = "Default"
	var/eclipse = FALSE

/datum/particle_weather/New(plane_type)
	. = ..()
	if(plane_type)
		src.plane_type = plane_type

/datum/particle_weather/proc/severity_mod()
	return severity / max_severity

/datum/particle_weather/proc/tick()
	if(weather_additional_events)
		for(var/event in weather_additional_events)
			if(!prob(weather_additional_events[event][1]))
				continue
			var/str = weather_additional_events[event][2]
			weather_additional_ongoing_events += new str(src)

/datum/particle_weather/Destroy()
	messaged_mobs = null
	for(var/S in current_sounds)
		var/datum/looping_sound/looping_sound = current_sounds[S]
		looping_sound.stop()
		qdel(looping_sound)

	for(var/S in current_wind_sounds)
		var/datum/looping_sound/looping_sound = current_wind_sounds[S]
		looping_sound.stop()
		qdel(looping_sound)

	return ..()

/datum/particle_weather/proc/start()
	if(running)
		return
	weather_duration = rand(weather_duration_lower, weather_duration_upper)
	COOLDOWN_START(src, time_left, weather_duration)
	weather_start_time = world.time
	running = TRUE
	addtimer(CALLBACK(src, PROC_REF(wind_down)), weather_duration)
	weather_warnings()
	if(particle_effect_type)
		SSparticle_weather.set_particle_effect(new particle_effect_type, plane_type);

	if(weather_special_effect)
		if(plane_type == "Default")
			SSparticle_weather.weather_special_effect = new weather_special_effect(src)
		else if(plane_type == "Eclipse")
			SSparticle_weather.weather_special_effect_eclipse = new weather_special_effect(src)
	change_severity()


/datum/particle_weather/proc/change_severity(as_step = TRUE)
	if(!running)
		return
	if(as_step)
		severity_steps_taken++

	if(max_severity_change == 0)
		severity = rand(min_severity, max_severity)
	else
		var/new_severity = severity + rand(-max_severity_change, max_severity_change)
		new_severity = clamp(new_severity, min_severity, max_severity)
		severity = new_severity

	severity = clamp(severity + wind_severity, min_severity, max_severity)

	if(plane_type == "Default")
		if(SSparticle_weather.particle_effect)
			SSparticle_weather.particle_effect.animate_severity(severity_mod())
	else if(plane_type == "Eclipse")
		if(SSparticle_weather.particle_effect_eclipse)
			SSparticle_weather.particle_effect_eclipse.animate_severity(severity_mod())

	if(last_message != scale_range_pick(min_severity, max_severity, severity, weather_messages))
		messaged_mobs = list()

	if(severity_steps_taken < severity_steps && as_step)
		addtimer(CALLBACK(src, PROC_REF(change_severity)), weather_duration / severity_steps)

/datum/particle_weather/proc/wind_down()
	severity = 0
	if(plane_type == "Default")
		if(SSparticle_weather.particle_effect)
			SSparticle_weather.particle_effect.animate_severity(severity_mod())
	else if(plane_type == "Eclipse")
		if(SSparticle_weather.particle_effect_eclipse)
			SSparticle_weather.particle_effect_eclipse.animate_severity(severity_mod())

		//Wait for the last particle to fade, then qdel yourself
		addtimer(CALLBACK(src, PROC_REF(end)), SSparticle_weather.particle_effect.lifespan + SSparticle_weather.particle_effect.fade)

/datum/particle_weather/proc/end()
	running = FALSE
	SSparticle_weather.stop_weather(plane_type)

/datum/particle_weather/proc/can_weather(mob/living/mob_to_check)
	var/turf/mob_turf = get_turf(mob_to_check)
	var/area/mob_area = get_area(mob_turf)
	if(istype(mob_area, /area/shuttle))
		return
	if(!mob_turf)
		return

	if(mob_turf.turf_flags & TURF_WEATHER)
		return TRUE

	return FALSE

/datum/particle_weather/proc/can_weather_effect(mob/living/mob_to_check)

	//If mob is not in a turf
	var/turf/mob_turf = get_turf(mob_to_check)

	if((immunity_type && HAS_TRAIT(mob_to_check, immunity_type)) || HAS_TRAIT(mob_to_check, TRAIT_WEATHER_IMMUNE))
		return

	var/atom/loc_to_check = mob_to_check.loc
	while(loc_to_check != mob_turf)
		if((immunity_type && HAS_TRAIT(loc_to_check, immunity_type)) || HAS_TRAIT(loc_to_check, TRAIT_WEATHER_IMMUNE))
			return
		loc_to_check = loc_to_check.loc

	return TRUE

/datum/particle_weather/proc/process_mob_effect(mob/living/L, delta_time)
	if(!islist(messaged_mobs))
		messaged_mobs = list()
	messaged_mobs |= L
	weather_sound_effect(L)
	if(can_weather(L) && running)
		if(can_weather_effect(L))
			if((last_message || weather_messages) && (!messaged_mobs[L] || world.time > messaged_mobs[L]))
				weather_message(L)
			affect_mob_effect(L, delta_time)
	else
		var/turf/mob_turf = get_turf(L)
		if(plane_type == "Default" && !SSmapping.level_has_all_traits(mob_turf.z, list(ZTRAIT_STATION)))
			stop_weather_sound_effect(L)
		if(plane_type == "Eclipse" && !SSmapping.level_has_all_traits(mob_turf.z, list(ZTRAIT_ECLIPSE)))
			stop_weather_sound_effect(L)
		messaged_mobs[L] = 0

/datum/particle_weather/proc/affect_mob_effect(mob/living/L, delta_time, calculated_damage)
	if(damage_per_tick)
		calculated_damage = damage_per_tick * delta_time
		L.apply_damage(calculated_damage, damage_type)

/datum/particle_weather/proc/weather_sound_effect(mob/living/L)
	var/datum/looping_sound/current_sound = current_sounds[L]
	var/turf/mob_turf = get_turf(L)
	if(!mob_turf)
		return


	if(mob_turf.turf_flags & TURF_WEATHER)
		if(current_sound?.type in weather_sounds)
			if(scale_vol_with_severity)
				current_sound.volume = initial(current_sound.volume) * severity_mod()
			if(!current_sound.loop_started) //don't restart already playing sounds
				current_sound.start()
			return
		if(current_sound)
			current_sound.stop()
		var/temp_sound = scale_range_pick(min_severity, max_severity, severity, weather_sounds)
		if(temp_sound)
			current_sound = new temp_sound(L, FALSE, TRUE, FALSE, CHANNEL_WEATHER)
			current_sounds[L] = current_sound
			//SET VOLUME
			if(scale_vol_with_severity)
				current_sound.volume = initial(current_sound.volume) * severity_mod()
			current_sound.start()
	else
		if(current_sound?.type in indoor_weather_sounds)
			if(scale_vol_with_severity)
				current_sound.volume = initial(current_sound.volume) * severity_mod()
			if(!current_sound.loop_started) //don't restart already playing sounds
				current_sound.start()
			return
		if(current_sound)
			current_sound.stop()
		var/temp_sound = scale_range_pick(min_severity, max_severity, severity, indoor_weather_sounds)
		if(temp_sound)
			current_sound = new temp_sound(L, FALSE, TRUE, FALSE, CHANNEL_WEATHER)
			current_sounds[L] = current_sound
			//SET VOLUME
			if(scale_vol_with_severity)
				current_sound.volume = initial(current_sound.volume) * severity_mod()
			current_sound.start()

	if(wind_severity && weather_sounds)
		var/datum/looping_sound/current_wind_sound = current_wind_sounds[L]
		if(current_wind_sound)
			//SET VOLUME
			if(scale_vol_with_severity)
				current_wind_sound.volume = initial(current_wind_sound.volume) * severity_mod()
			if(!current_wind_sound.loop_started) //don't restart already playing sounds
				current_wind_sound.start()
			return

		var/temp_wind_sound = scale_range_pick(min_severity, max_severity, severity, wind_sounds)
		if(temp_wind_sound)
			current_wind_sound = new temp_wind_sound(L, FALSE, TRUE, FALSE, CHANNEL_WEATHER)
			current_wind_sounds[L] = current_wind_sound
			//SET VOLUME
			if(scale_vol_with_severity)
				current_wind_sound.volume = initial(current_wind_sound.volume) * severity_mod()
			current_wind_sound.start()


/datum/particle_weather/proc/stop_weather_sound_effect(mob/living/L)
	var/datum/looping_sound/current_sound = current_sounds[L]
	if(current_sound)
		current_sound.stop()
	var/datum/looping_sound/current_wind_sound = current_wind_sounds[L]
	if(current_wind_sound)
		current_wind_sound.stop()

/datum/particle_weather/proc/weather_message(mob/living/L)
	messaged_mobs[L] = world.time + WEATHER_MESSAGE_DELAY
	last_message = scale_range_pick(min_severity, max_severity, severity, weather_messages)
	if(last_message)
		to_chat(L, span_danger(last_message))

/datum/particle_weather/proc/weather_warnings()
	switch(weather_warnings)
		if("siren")
			for(var/obj/machinery/siren/weather/weather_siren in GLOB.siren_objects["weather"])
				if(weather_siren.z in affected_zlevels)
					weather_siren.siren_warning(weather_warnings["siren"])
		if("message")
			var/message = "Incoming [display_name]"
			if(length(weather_warnings["message"]))
				var/weather_message = weather_warnings["message"]
				message += weather_message
			for(var/mob/living/carbon/human/affected_human in GLOB.alive_mob_list)
				if(!affected_human.stat && affected_human.client && (affected_human.z in affected_zlevels))
					affected_human.playsound_local('monkestation/code/modules/outdoors/sound/effects/radiostatic.ogg', affected_human.loc, 25, FALSE, mixer_channel = CHANNEL_MACHINERY)
					affected_human.play_screen_text("<span class='langchat' style=font-size:16pt;text-align:center valign='top'><u>Weather Alert:</u></span><br>" + message["human"], /atom/movable/screen/text/screen_text/command_order, rgb(103, 214, 146))
    return FALSE

/datum/looping_sound/dust_storm
	mid_sounds = 'monkestation/code/modules/outdoors/sound/weather/dust/weather_dust.ogg'
	mid_length = 80
	volume = 150

/datum/looping_sound/rain
	mid_sounds = 'monkestation/code/modules/outdoors/sound/weather/rain/weather_rain.ogg'
	mid_length = 40 SECONDS
	volume = 200

/datum/looping_sound/indoor_rain
	mid_sounds = 'monkestation/code/modules/outdoors/sound/weather/rain/weather_rain_indoors.ogg'
	mid_length = 15 SECONDS
	volume = 200

/datum/looping_sound/storm
	mid_sounds = 'monkestation/code/modules/outdoors/sound/weather/rain/weather_storm.ogg'
	mid_length = 30 SECONDS
	volume = 150

/datum/looping_sound/snow
	mid_sounds = 'monkestation/code/modules/outdoors/sound/weather/snow/weather_snow.ogg'
	mid_length = 50 SECONDS
	volume = 150

/datum/looping_sound/wind
	mid_sounds = 'monkestation/code/modules/outdoors/sound/weather/rain/wind_1.ogg'
	mid_sounds = list(
		'monkestation/code/modules/outdoors/sound/weather/rain/wind_1.ogg'=1,
		'monkestation/code/modules/outdoors/sound/weather/rain/wind_2.ogg'=1,
		'monkestation/code/modules/outdoors/sound/weather/rain/wind_3.ogg'=1,
		'monkestation/code/modules/outdoors/sound/weather/rain/wind_4.ogg'=1,
		'monkestation/code/modules/outdoors/sound/weather/rain/wind_5.ogg'=1,
		'monkestation/code/modules/outdoors/sound/weather/rain/wind_6.ogg'=1
		)
	mid_length = 30 SECONDS
	volume = 150

//IDK WHERE SUPPOSED TO PUT
/obj/machinery/siren
	name = "Siren"
	desc = "A siren used to play warnings for the station."
	icon = 'monkestation/code/modules/outdoors/icons/obj/machines/loudspeaker.dmi'
	icon_state = "loudspeaker"
	density = 0
	anchored = 1
	use_power = 0
	machine_stat = NOPOWER
	var/message = "BLA BLA BLA"
	var/sound = 'monkestation/code/modules/outdoors/sound/effects/weather_warning.ogg'

/obj/machinery/siren/proc/siren_warning(var/msg = "WARNING, bla bla bla bluh.", var/sound_ch = 'monkestation/code/modules/outdoors/sound/effects/weather_warning.ogg')
	playsound(loc, sound_ch, 50, 0, mixer_channel = CHANNEL_MACHINERY)
	visible_message(span_danger("[src] makes a signal. [msg]."))

/obj/machinery/siren/proc/siren_warning_start(var/msg, var/sound_ch = 'monkestation/code/modules/outdoors/sound/effects/weather_warning.ogg')
	if(!msg)
		return
	message = msg
	sound = sound_ch
	START_PROCESSING(SSmachines, src)

/obj/machinery/siren/proc/siren_warning_stop()
	STOP_PROCESSING(SSmachines, src)

/obj/machinery/siren/process()
	if(prob(2))
		playsound(loc, sound, 80, 0, mixer_channel = CHANNEL_MACHINERY)
		visible_message(span_danger("[src] makes a signal. [message]."))


/obj/machinery/siren/weather
	name = "Weather Siren"
	desc = "A siren used to play weather warnings for the station."
