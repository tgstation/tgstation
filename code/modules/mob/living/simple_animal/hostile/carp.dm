#define PHEROMONES_NO_EFFECT	0
#define PHEROMONES_NEUTRAL		1
#define PHEROMONES_FOLLOW		2

/mob/living/simple_animal/hostile/carp
	name = "space carp"
	desc = "A ferocious, fang-bearing creature that resembles a fish."
	icon_state = "carp"
	icon_living = "carp"
	icon_dead = "carp_dead"
	icon_gib = "carp_gib"
	speak_chance = 0
	turns_per_move = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	speed = -1
	maxHealth = 25
	health = 25
	size = SIZE_SMALL

	can_breed = 1
	childtype = /mob/living/simple_animal/hostile/carp/baby
	child_amount = 1
	holder_type = /obj/item/weapon/holder/animal/carp


	harm_intent_damage = 8
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	//Space carp aren't affected by atmos.
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	faction = "carp"

	var/pheromones_act = PHEROMONES_NEUTRAL //This variable determines how carps act to pheromones. Big carps won't attack the source,
	//baby carps follow the source and holocarps don't give a shit

/mob/living/simple_animal/hostile/carp/New()
	.=..()
	gender = pick(MALE, FEMALE)
	if(gender==FEMALE)
		child_amount = rand(4,6) //Mother explodes on death, so letting it leave 5 child carps (that can't breed) behind is fair

/mob/living/simple_animal/hostile/carp/examine(mob/user)
	..()
	if(Adjacent(user))
		to_chat(user, "It appears to be [(gender==MALE) ? "male" : "female"].")

/mob/living/simple_animal/hostile/carp/give_birth()
	spawn(rand(100,200))
		if(!src) return

		src.death(0)
		sleep(30)
		src.visible_message("<span class='danger'>[src]'s body explodes in a shower of gore as its offspring burst out!</span>")
		..()
		src.gib(meat=0)

/mob/living/simple_animal/hostile/carp/Process_Spacemove(var/check_drift = 0)
	return 1	//No drifting in space for space carp!	//original comments do not steal

/mob/living/simple_animal/hostile/carp/CanAttack(var/atom/the_target)
	if(ismob(the_target) && the_target.reagents)
		if(pheromones_act == PHEROMONES_NEUTRAL && the_target.reagents.has_reagent("carppheromones"))
			return 0 //Carps who avoid pheromones don't target mobs with pheromones in their system. They just ignore them!
	return ..(the_target)

/mob/living/simple_animal/hostile/carp/FindTarget()
	. = ..()
	if(.)
		emote("nashes at [.]")

/mob/living/simple_animal/hostile/carp/AttackingTarget()
	if(!target) return

	if(pheromones_act == PHEROMONES_FOLLOW && target.reagents && target.reagents.has_reagent("carppheromones"))
		return	//This might be a bit hacky. The purpose of this is to prevent carps who are attracted to pheromones from attacking
				//the source. Instead, it simply follows it.

	. =..()
	var/mob/living/carbon/L = .
	if(istype(L))
		if(prob(15))
			L.Weaken(3)
			L.visible_message("<span class='danger'>\the [src] knocks down \the [L]!</span>")

/mob/living/simple_animal/hostile/carp/baby
	desc = "A ferocious, fang-bearing creature that resembles a fish. This one, despite not being mature yet, is just as agressive as any of its brethren."
	icon_state = "babycarp"
	icon_dead = "babycarp_dead"

	size = SIZE_TINY
	can_breed = 0

	maxHealth = 15
	health = 15

	melee_damage_upper = 8
	melee_damage_lower = 8

	pheromones_act = PHEROMONES_FOLLOW

/mob/living/simple_animal/hostile/carp/holocarp
	icon_state = "holocarp"
	icon_living = "holocarp"
	can_breed = 0
	pheromones_act = PHEROMONES_NO_EFFECT
	holder_type = null

/mob/living/simple_animal/hostile/carp/holocarp/Die()
	qdel(src)
	return

#undef PHEROMONES_NO_EFFECT
#undef PHEROMONES_NEUTRAL
#undef PHEROMONES_FOLLOW
