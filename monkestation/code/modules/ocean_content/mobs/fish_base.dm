/mob/living/basic/aquatic/fish
	name = "Fish"
	desc = "Found in the ocean."
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


/mob/living/basic/aquatic/fish/Destroy()
	var/datum/group_planning/attached = ai_controller?.blackboard[BB_GROUP_DATUM]
	if(attached)
		if(src in attached.group_mobs)
			attached.group_mobs -= src
		if(src in attached.in_progress_mobs)
			attached.in_progress_mobs -= src
		if(src in attached.finished_mobs)
			attached.finished_mobs -= src
	return ..()

/mob/living/basic/aquatic/fish/cod
	name = "Cod"
	icon_state = "cod"
	icon_living = "cod"
	icon_dead = "cod_dead"
	icon_gib = "cod_dead"

/mob/living/basic/aquatic/fish/gupper
	name = "Gupper"
	icon_state = "gupper"
	icon_living = "gupper"
	icon_dead = "gupper_dead"
	icon_gib = "gupper_dead"
