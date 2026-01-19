// ported from imp-station-14 https://github.com/impstation/imp-station-14/blob/910cbeea10d104c1bb2c10193afed10a7633382c/Resources/Prototypes/_Impstation/Entities/Mobs/NPCs/pets.yml#L215
// Made by mqole for impstation with CC BY-SA 3.0 license
/mob/living/basic/pet/dog/dolby
	name = "\improper Dolby"
	real_name = "dolby"
	desc = "Dobie Digital. Now with Frost Shield!"
	icon = 'troutstation/icons/mob/simple/pets.dmi'
	icon_state = "dolby"
	icon_living = "dolby"
	icon_dead = "dolby_dead"
	butcher_results = list(/obj/item/food/meat/slab/corgi = 2)
	gold_core_spawnable = FRIENDLY_SPAWN
	unique_pet = TRUE
	gender = MALE
	flags_ricochet = RICOCHET_HARD | RICOCHET_SHINY
	receive_ricochet_damage_coeff = 0
	ai_controller = /datum/ai_controller/basic_controller/dog

/mob/living/basic/pet/dog/dolby/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

