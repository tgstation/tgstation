/mob/living/basic/orbie
	name = "Orbie"
	desc = "An orb shaped hologram."
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "orbie"
	icon_living = "orbie"
	speed = 1
	maxHealth = 50
	health = 50
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = TCMB
	maximum_survivable_temperature = INFINITY
	death_message = "fades out of existence!"
	var/static/mutable_appearance/eyes_overlay = mutable_appearance('icons/mob/simple/pets.dmi', "orbie_eye_overlay")
	var/static/mutable_appearance/flame_overlay = mutable_appearance('icons/mob/simple/pets.dmi', "orbie_flame_overlay")
//	ai_controller = /datum/ai_controller/basic_controller/tree

/mob/living/basic/orbie/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/seethrough_mob)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_PINE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	var/list/death_loot = string_list(list(/obj/item/stack/sheet/mineral/wood))
	AddElement(/datum/element/death_drops, death_loot)
	update_appearance(UPDATE_OVERLAYS)

/mob/living/basic/orbie/update_overlays()
	. = ..()
	if(stat == DEAD)
		return
	. += eyes_overlay
	. += flame_overlay
