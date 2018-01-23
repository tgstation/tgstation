/mob/living/simple_animal/hostile/retaliate/poison
    var/poison_per_bite = 0
    var/poison_type = "toxin"

/mob/living/simple_animal/hostile/retaliate/poison/AttackingTarget()
    . = ..()
    if(. && isliving(target))
        var/mob/living/L = target
        if(L.reagents && !poison_per_bite == 0)
            L.reagents.add_reagent(poison_type, poison_per_bite)
        return

/mob/living/simple_animal/hostile/retaliate/poison/snake
	name = "snake"
	desc = "A slithery snake. These legless reptiles are the bane of mice and adventurers alike."
	icon_state = "snake"
	icon_living = "snake"
	icon_dead = "snake_dead"
	speak_emote = list("hisses")
	health = 20
	maxHealth = 20
	attacktext = "bites"
	melee_damage_lower = 5
	melee_damage_upper = 6
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "steps on"
	faction = list("neutral","hostile")
	ventcrawler = VENTCRAWLER_ALWAYS
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = FRIENDLY_SPAWN
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE

/mob/living/simple_animal/hostile/retaliate/poison/snake/Found(atom/the_target)
	if(istype(the_target, /mob/living/simple_animal/mouse))
		return the_target

/mob/living/simple_animal/hostile/retaliate/poison/snake/ListTargets(atom/the_target)
	if(istype(the_target, /mob/living/simple_animal/mouse))

		return ..()
	return ..(1)

/mob/living/simple_animal/hostile/retaliate/poison/snake/AttackingTarget()
	if(istype(target, /mob/living/simple_animal/mouse))
		visible_message("<span class='notice'>[name] consumes [target] in a single gulp!</span>", "<span class='notice'>You consume [target] in a single gulp!</span>")
		QDEL_NULL(target)
		adjustBruteLoss(-2)
	else
		return ..()