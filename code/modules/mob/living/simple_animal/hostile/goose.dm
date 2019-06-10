/mob/living/simple_animal/hostile/retaliate/goose
	name = "goose"
	desc = "It's loose"
	icon_state = "goose"
	icon_living = "goose"
	icon_dead = "goose_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak_chance = 0
	turns_per_move = 5
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 2)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	emote_taunt = list("hisses")
	taunt_chance = 30
	speed = 0
	maxHealth = 25
	health = 25
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "pecks"
	attack_sound = "goose"
	speak_emote = list("honks")
	faction = list("neutral")
	attack_same = TRUE
	gold_core_spawnable = HOSTILE_SPAWN
	var/icon_resting = "goose_sit"


/mob/living/simple_animal/hostile/retaliate/goose/toggle_ai(togglestatus)
	. = ..()
	if(!key)
		if(AIStatus != AI_ON)
			set_resting(TRUE)
		else
			set_resting(FALSE)

/mob/living/simple_animal/hostile/retaliate/goose/update_resting()
	. = ..()
	if(resting)
		wander = FALSE
	else
		wander = TRUE
	update_icon()

/mob/living/simple_animal/hostile/retaliate/goose/handle_automated_movement()
	. = ..()
	if(prob(5))
		Retaliate()

/mob/living/simple_animal/hostile/retaliate/goose/proc/update_icon()
	if(stat != DEAD)
		icon_state = resting ? icon_resting : icon_living
	else
		icon_state = icon_dead

