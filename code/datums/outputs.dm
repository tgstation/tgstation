GLOBAL_LIST_EMPTY(outputs_list)

/datum/outputs
	var/text = ""
	var/list/sounds = list('sound/items/airhorn.ogg'=1) //weighted, put multiple for random selection between sounds
	var/list/icon = list('icons/sound_icon.dmi',"circle", HUD_LAYER) //syntax: icon, icon_state, layer

/datum/outputs/New()
	GLOB.outputs_list[src.type] = src

/datum/outputs/proc/send_info(mob/receiver, turf/turf_source, vol as num, vary, frequency, falloff, channel = 0, pressure_affected = TRUE)
	var/sound/S
	if(receiver.client)
		//Pick sound
		if(sounds.len)
			var/soundin = pickweight(sounds)
			S = sound(get_sfx(soundin))
		receiver.display_output(S, icon, text, turf_source, vol, vary, frequency, falloff, channel, pressure_affected)

/datum/outputs/bikehorn
	text = "You hear a HONK."
	sounds = list('sound/items/bikehorn.ogg'=1)

/datum/outputs/airhorn
	text = "You hear the violent blaring of an airhorn."
	sounds = list('sound/items/airhorn2.ogg'=1)

/datum/outputs/alarm
	text = "You hear a blaring alarm."
	sounds = list('sound/machines/alarm.ogg'=1)

