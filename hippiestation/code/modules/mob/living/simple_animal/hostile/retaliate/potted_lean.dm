/mob/living/simple_animal/hostile/retaliate/pottedlean
	name = "potted lean"
	desc = "A gorgeous piece of foliage, seemingly both animated and extremely intoxicated by lean."
	icon = 'hippiestation/icons/mob/animal.dmi'
	icon_state = "pot_lean"
	icon_living = "pot_lean"
	icon_dead = "pot_lean_dead"
	speak = list("rhymes","chirps","hollers")
	emote_see = list("sips.", "grips.")
	speak_chance = 1
	turns_per_move = 5
	maxHealth = 65
	health = 65
	melee_damage_lower = 5
	melee_damage_upper = 15
	attacktext = "slaps"
	response_help  = "rubs"
	response_disarm = "checks"
	response_harm   = "splats"
	density = TRUE
	attack_sound = 'hippiestation/sound/effects/plantAttack.ogg'
	butcher_results = list(/obj/item/reagent_containers/food/snacks/grown/grapes = 3)
	gold_core_spawnable = HOSTILE_SPAWN

/mob/living/simple_animal/hostile/retaliate/frog/Initialize()
	. = ..()
