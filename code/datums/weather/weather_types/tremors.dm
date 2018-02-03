//Tremors happen frequently on lavaland. They're fairly harmless aside from some shaking, but they trigger acid geysers.
/datum/weather/tremors
	name = "tremors"
	desc = "Tremors deep beneath the surface, that rouse dormant acid geysers."

	telegraph_message = "<span class='warning'>You feel a faint rumble under your feet...</span>"
	telegraph_sound = 'sound/weather/rumble.ogg'
	telegraph_duration = 100

	weather_message = "<span class='boldwarning'><i>The ground shakes!</i></span>"
	weather_duration_lower = 100
	weather_duration_upper = 100
	weather_sound = 'sound/weather/tremors.ogg'

	end_message = ""
	end_duration = 0

	area_type = /area
	target_trait = ZTRAIT_MINING

/datum/weather/tremors/start()
	. = ..()
	for(var/obj/structure/terrain/geyser/G in GLOB.acid_geysers)
		G.tremors()

/datum/weather/tremors/weather_act(mob/living/L)
	shake_camera(L, 30, 1)
	L.confused++

/datum/weather/tremors/update_areas()
	return

/datum/weather/tremors/earthquake
	name = "earthquake"
	desc = "A violent earthquake, strong enough to knock unwary travelers off their feet."

	weather_message = "<span class='userdanger'><i>The ground shakes violently!</i></span>"
	weather_duration_lower = 100
	weather_duration_upper = 100
	weather_sound = 'sound/weather/earthquake.ogg'

/datum/weather/tremors/earthquake/weather_act(mob/living/L)
	shake_camera(L, 30, 2)
	L.confused += 2
	if(isturf(L.loc))
		if(prob(15))
			L.Knockdown(50)