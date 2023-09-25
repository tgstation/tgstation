/mob/living/basic/aquatic/fish
	icon = 'monkestation/code/modules/ocean_content/icons/fish.dmi'
	icon_state = "fish"
	icon_living = "fish"
	icon_dead = "fish_dead"
	icon_gib = "fish_dead"

	mob_size = MOB_SIZE_SMALL
	faction = list(FACTION_CARP)
	speak_emote = list("glubs")

	habitable_atmos = list("min_oxy" = 2, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1200

	ai_controller = /datum/ai_controller/basic_controller/fish


