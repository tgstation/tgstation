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

	species_type = /mob/living/simple_animal/hostile/carp
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

		if(..())
			src.gib(meat=0)
			src.visible_message("<span class='danger'>[src]'s body explodes in a shower of gore as its offspring burst out!</span>")

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

	//Baby carps grow up when they attack a living mob enough times
	//Unlike adults, they'll attack unconscious mobs (but not dead ones)
	stat_attack = UNCONSCIOUS

	var/growth_stage = 1 //Increased when the baby carp attacks or eats meat.
	var/const/req_growth_to_grow_up = 15 //Baby carps have to attack a living mob 15 times to grow up

/mob/living/simple_animal/hostile/carp/baby/AttackingTarget()
	..()

	//Handle eating
	if(isliving(target))
		var/mob/living/L = target
		
		if(!L.meat_type) return

		increase_growth_stage(1)

/mob/living/simple_animal/hostile/carp/baby/attackby(obj/W, mob/user)
	..()

	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/F = W

		if((F.food_flags & FOOD_MEAT) && (growth_stage < req_growth_to_grow_up)) //Any meaty dish goes!
			playsound(get_turf(src),'sound/items/eatfood.ogg', rand(10,50), 1)
			visible_message("<span class='info'>\The [src] gobbles up \the [W]!")
			user.drop_item(F, force_drop = 1)

			if(prob(25))
				if(!friends.Find(user))
					friends.Add(user)
					to_chat(user, "<span class='info'>You have gained \the [src]'s trust.</span>")
					flick_overlay(image('icons/mob/animal.dmi',src,"heart-ani2",MOB_LAYER+1), list(user.client), 20)

			if(F.reagents)
				for(var/datum/reagent/N in F.reagents.reagent_list)
					reagent_act(N.id, INGEST, N.volume)

			qdel(F)

		else

			to_chat(user, "<span class='info'>\The [src] gracefully refuses \the [W].</span>")

	return 1

/mob/living/simple_animal/hostile/carp/baby/proc/increase_growth_stage(by = 1)
	if(growth_stage >= req_growth_to_grow_up) return

	growth_stage += by

	if(growth_stage >= req_growth_to_grow_up)
		//Start growing up
		desc = "[initial(desc)] <span class='notice'>It ate a lot recently, and it appears to be ready to grow up.</span>"
		spawn(rand(5 SECONDS, 30 SECONDS))
			grow_up()

/mob/living/simple_animal/hostile/carp/baby/reagent_act(id, method, volume)
	..()

	if(id == "nutriment" && method == INGEST)
		increase_growth_stage(volume)

/mob/living/simple_animal/hostile/carp/holocarp
	icon_state = "holocarp"
	icon_living = "holocarp"

	species_type = /mob/living/simple_animal/hostile/carp/holocarp
	can_breed = 0
	pheromones_act = PHEROMONES_NO_EFFECT
	holder_type = null

/mob/living/simple_animal/hostile/carp/holocarp/Die()
	qdel(src)
	return

#undef PHEROMONES_NO_EFFECT
#undef PHEROMONES_NEUTRAL
#undef PHEROMONES_FOLLOW
