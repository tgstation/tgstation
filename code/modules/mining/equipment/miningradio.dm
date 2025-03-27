/// Portable mining radio purchasable by miners
/obj/item/radio/weather_monitor
	icon = 'icons/obj/devices/miningradio.dmi'
	name = "mining weather radio"
	icon_state = "miningradio"
	desc = "A weather radio designed for use in inhospitable environments. Gives audible warnings when storms approach. Has access to cargo channel."
	freqlock = RADIO_FREQENCY_LOCKED
	light_power = 1
	light_range = 1.6

/obj/item/radio/weather_monitor/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "small_emissive", src, alpha = src.alpha)

/obj/item/radio/weather_monitor/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/weather_announcer, \
		state_normal = "weatherwarning", \
		state_warning = "urgentwarning", \
		state_danger = "direwarning", \
	)
	set_frequency(FREQ_SUPPLY)
