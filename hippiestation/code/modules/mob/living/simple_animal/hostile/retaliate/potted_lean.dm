/mob/living/simple_animal/hostile/retaliate/pottedlean
	name = "potted lean"
	desc = "A gorgeous piece of foliage, seemingly both animated and extremely intoxicated by lean."
	icon = 'hippiestation/icons/mob/animal.dmi'
	icon_state = "pot_lean"
	icon_living = "pot_lean"
	icon_dead = "pot_lean_dead"
	speak = list("....shieeet...")
	emote_see = list("sips.", "grips.", "yawns.", "snores.")
	speak_chance = 1
	turns_per_move = 5
	maxHealth = 65
	health = 65
	melee_damage_lower = 5
	melee_damage_upper = 15
	attacktext = "steps to"
	response_help  = "takes a sip from"
	response_disarm = "tries"
	response_harm   = "wallops"
	density = TRUE
	attack_sound = 'hippiestation/sound/effects/plantAttack.ogg'
	butcher_results = list(/obj/item/reagent_containers/food/snacks/grown/grapes = 3)
	gold_core_spawnable = HOSTILE_SPAWN
	var/attack_inject = "lean"

/mob/living/simple_animal/hostile/retaliate/pottedlean/Initialize()
	. = ..()

/mob/living/simple_animal/hostile/retaliate/pottedlean/AttackingTarget()
	if(prob(50))
		if(isliving(target))
			var/mob/living/L = target
			if(L.reagents)
				L.reagents.add_reagent(attack_inject, rand(1,25))
	. = ..()

/mob/living/simple_animal/hostile/retaliate/pottedlean/attack_hand(mob/living/user)
	if(user.a_intent == INTENT_HELP && user.reagents)
		visible_message("<span class='notice'>[user] takes a sip from [src]</span>")
		user.reagents.add_reagent(attack_inject, 10)
	else
		..()
