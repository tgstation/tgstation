/datum/weather/void_storm
	name = "void storm"
	desc = "Крайне редкое и аномальное событие, вызываемое неизвестными сущностями, разрывающими ткань пространства-времени. Лучшим советом, который мы вам можем дать, является немедленный побег."

	telegraph_duration = 2 SECONDS
	telegraph_overlay = "light_snow"

	weather_message = span_hypnophrase("Вы чувствуете, как воздух становится холоднее... и как вас окутывает пустота...")
	weather_overlay = "light_snow"
	weather_color = COLOR_BLACK
	weather_duration_lower = 1 MINUTES
	weather_duration_upper = 2 MINUTES

	use_glow = FALSE

	end_duration = 10 SECONDS

	area_type = /area
	target_trait = ZTRAIT_VOIDSTORM

	weather_flags = (WEATHER_INDOORS | WEATHER_BAROMETER | WEATHER_ENDLESS)
